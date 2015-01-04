
lemon.sql = lemon.sql or {}

-- Execution of file should be able to continue even if mysqloo is missing
pcall(require, "mysqloo")

local function RetryConnection()
	local con = lemon.sql.Connection
	if (lemon.config.GetValue("sql_connection_type") == "remote" or lemon.config.GetValue("sql_connection_type") == "sourcebans") and not lemon.config.GetBool("sql_redirected") and not lemon.sql.Retrying then
		if con ~= nil then
			local status = con:status()
			if status == mysqloo.DATABASE_NOT_CONNECTED or status == mysqloo.DATABASE_INTERNAL_ERROR then
				lemon.sql.Initialized = false
				lemon.sql.Retrying = true

				local recreate = status == mysqloo.DATABASE_INTERNAL_ERROR
				timer.Simple(30, function()
					lemon.sql.Connect(recreate)
				end)
			end
		else
			lemon.sql.Initialized = false
			lemon.sql.Retrying = true
			timer.Simple(30, function()
				lemon.sql.Connect()
			end)
		end
	end
end

local function ConnectSuccessCallback(database)
	lemon.sql.Initialized = true
end

local function ConnectFailureCallback(database, error)
	ErrorNoHalt(error)
	RetryConnection()
end

function lemon.sql.Connect(recreate)
	if (lemon.config.GetValue("sql_connection_type") == "remote" or lemon.config.GetValue("sql_connection_type") == "sourcebans") and not lemon.config.GetBool("sql_redirected") and mysqloo == nil then
		lemon.config.Set("sql_connection_type", "local")
	end

	if (lemon.config.GetValue("sql_connection_type") == "remote" or lemon.config.GetValue("sql_connection_type") == "sourcebans") and not lemon.config.GetBool("sql_redirected") then
		if recreate or lemon.sql.DatabaseConnection == nil then
			lemon.sql.Initialized = false
			lemon.sql.Retrying = false

			lemon.sql.DatabaseConnection = mysqloo.connect(lemon.config.GetValue("sql_host"), lemon.config.GetValue("sql_username"), lemon.config.GetValue("sql_password"), lemon.config.GetValue("sql_database"), lemon.config.GetNumber("sql_host_port"))
			if lemon.sql.DatabaseConnection == nil then
				RetryConnection()
				return false
			end
			
			lemon.sql.DatabaseConnection.onConnected = ConnectSuccessCallback
			lemon.sql.DatabaseConnection.onConnectionFailed = ConnectFailureCallback
		end

		lemon.sql.DatabaseConnection:connect()
	else
		lemon.sql.Initialized = true
		lemon.sql.Retrying = false
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

function lemon.sql.Query(query, callback, userdata)
	if lemon.config.GetValue("sql_connection_type") == "remote" or lemon.config.GetValue("sql_connection_type") == "sourcebans" then
		if lemon.config.GetBool("sql_redirected") then
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

			local parameters = {username = lemon.config.GetValue("sql_username"), password = lemon.config.GetValue("sql_password"), database = lemon.config.GetValue("sql_database"), query = query}

			HTTP({url = lemon.config.GetValue("sql_redirector_url"), method = "post", parameters = parameters, success = success, failed = failed})
			return true
		else
			if lemon.sql.Initialized and not lemon.sql.Retrying then
				local databasequery = lemon.sql.DatabaseConnection:query(query)
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
function lemon.sql.EscapeString(input, quotes)
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

lemon.sql.Connect()