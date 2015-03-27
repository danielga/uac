uac.sql = uac.sql or {}

-- Execution of file should be able to continue even if mysqloo is missing
pcall(require, "mysqloo")

local function RetryConnection()
	local con = uac.sql.Connection
	if (uac.config.GetValue("sql_connection_type") == "remote" or uac.config.GetValue("sql_connection_type") == "sourcebans") and not uac.config.GetBool("sql_redirected") and not uac.sql.Retrying then
		if con ~= nil then
			local status = con:status()
			if status == mysqloo.DATABASE_NOT_CONNECTED or status == mysqloo.DATABASE_INTERNAL_ERROR then
				uac.sql.Initialized = false
				uac.sql.Retrying = true

				local recreate = status == mysqloo.DATABASE_INTERNAL_ERROR
				timer.Simple(30, function()
					uac.sql.Connect(recreate)
				end)
			end
		else
			uac.sql.Initialized = false
			uac.sql.Retrying = true
			timer.Simple(30, function()
				uac.sql.Connect()
			end)
		end
	end
end

local function ConnectSuccessCallback(database)
	uac.sql.Initialized = true
end

local function ConnectFailureCallback(database, error)
	ErrorNoHalt(error)
	RetryConnection()
end

function uac.sql.Connect(recreate)
	if (uac.config.GetValue("sql_connection_type") == "remote" or uac.config.GetValue("sql_connection_type") == "sourcebans") and not uac.config.GetBool("sql_redirected") and mysqloo == nil then
		uac.config.Set("sql_connection_type", "local")
	end

	if (uac.config.GetValue("sql_connection_type") == "remote" or uac.config.GetValue("sql_connection_type") == "sourcebans") and not uac.config.GetBool("sql_redirected") then
		if recreate or uac.sql.DatabaseConnection == nil then
			uac.sql.Initialized = false
			uac.sql.Retrying = false

			uac.sql.DatabaseConnection = mysqloo.connect(uac.config.GetValue("sql_host"), uac.config.GetValue("sql_username"), uac.config.GetValue("sql_password"), uac.config.GetValue("sql_database"), uac.config.GetNumber("sql_host_port"))
			if uac.sql.DatabaseConnection == nil then
				RetryConnection()
				return false
			end
			
			uac.sql.DatabaseConnection.onConnected = ConnectSuccessCallback
			uac.sql.DatabaseConnection.onConnectionFailed = ConnectFailureCallback
		end

		uac.sql.DatabaseConnection:connect()
	else
		uac.sql.Initialized = true
		uac.sql.Retrying = false
	end

	return true
end

local function QuerySuccessCallback(query, data)
	if query.Callback then
		query.Callback(true, data, query.Userdata)
	end
end

local function QueryFailureCallback(query, error, strquery)
	ErrorNoHalt(error)
	RetryConnection()

	if query.Callback then
		query.Callback(false, error, query.Userdata)
	end
end

function uac.sql.Query(query, callback, userdata)
	if uac.config.GetValue("sql_connection_type") == "remote" or uac.config.GetValue("sql_connection_type") == "sourcebans" then
		if uac.config.GetBool("sql_redirected") then
			local success = function(code, body, headers)
				if not callback then
					return
				end
				
				if body == "NULL" then
					callback(false, "Body is NULL.", userdata)
					return
				end

				local decoded = util.JSONToTable(body)
				if decoded == nil or decoded.success == nil then
					callback(false, "Body contains invalid data or not all fields are set.", userdata)
					return
				end

				decoded.success = tobool(decoded.success)
				callback(decoded.success, decoded.success and decoded.data or decoded.error, userdata)
			end

			local failed = function(err)
				if callback then
					callback(false, err, userdata)
				end
			end

			local parameters = {username = uac.config.GetValue("sql_username"), password = uac.config.GetValue("sql_password"), database = uac.config.GetValue("sql_database"), query = query}

			HTTP({url = uac.config.GetValue("sql_redirector_url"), method = "post", parameters = parameters, success = success, failed = failed})
			return true
		else
			if uac.sql.Initialized and not uac.sql.Retrying then
				local databasequery = uac.sql.DatabaseConnection:query(query)
				if databasequery ~= nil then
					databasequery.Callback = callback
					databasequery.Userdata = userdata
					databasequery.onSuccess = QuerySuccessCallback
					databasequery.onFailure = QueryFailureCallback
					databasequery:start()
					return true
				end
			end
		end
	else
		local ret = sql.Query(query)
		if callback then
			callback(ret and true or false, ret and ret or sql.LastError(), userdata)
		end

		return true
	end

	if callback then
		callback(false, "Failed to create query.", userdata)
	end

	return false
end

local escape_list = {'\n', 'n', '\r', 'r', '\\', '\\', '\'', '\'', '"', '"', '\032', 'Z'}
function uac.sql.EscapeString(input, quotes)
	local str = tostring(input)

	for i = 1, #escape_list / 2 do
		str = str:gsub(escape_list[i * 2 - 1], "\\" .. escape_list[i * 2])
	end

	if quotes then
		return "'" .. str .. "'"
	end

	return str
end

------------------------------------------------------------------

uac.sql.Connect()