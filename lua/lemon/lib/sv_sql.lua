lemon.sql = lemon.sql or {}

-- Execution of file should be able to continue even if mysqloo is missing
pcall(require, "mysqloo")

local function RetryConnection()
	local con = lemon.sql.Connection
	if (lemon.config:Get("SQL_CONNECTION_TYPE") == "remote" or lemon.config:Get("SQL_CONNECTION_TYPE") == "sourcebans") and not lemon.config:GetBool("SQL_REDIRECTED") and not lemon.sql.Retrying then
		if con ~= nil then
			local status = con:status()
			if status == mysqloo.DATABASE_NOT_CONNECTED or status == mysqloo.DATABASE_INTERNAL_ERROR then
				lemon.sql.Initialized = false
				lemon.sql.Retrying = true

				local recreate = status == mysqloo.DATABASE_INTERNAL_ERROR
				timer.Simple(30, function() lemon.sql:Connect(recreate) end)
			end
		else
			lemon.sql.Initialized = false
			lemon.sql.Retrying = true
			timer.Simple(30, function() lemon.sql:Connect() end)
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

function lemon.sql:Connect(recreate)
	if (lemon.config:Get("SQL_CONNECTION_TYPE") == "remote" or lemon.config:Get("SQL_CONNECTION_TYPE") == "sourcebans") and not lemon.config:GetBool("SQL_REDIRECTED") and mysqloo == nil then
		lemon.config:Set("SQL_CONNECTION_TYPE", "local")
	end

	if (lemon.config:Get("SQL_CONNECTION_TYPE") == "remote" or lemon.config:Get("SQL_CONNECTION_TYPE") == "sourcebans") and not lemon.config:GetBool("SQL_REDIRECTED") then
		if recreate or self.DatabaseConnection == nil then
			self.Initialized = false
			self.Retrying = false

			self.DatabaseConnection = mysqloo.connect(lemon.config:Get("SQL_HOST"), lemon.config:Get("SQL_USERNAME"), lemon.config:Get("SQL_PASSWORD"), lemon.config:Get("SQL_DATABASE"), lemon.config:GetNumber("SQL_HOST_PORT"))
			if self.DatabaseConnection == nil then
				RetryConnection()
				return false
			end
			
			self.DatabaseConnection.onConnected = ConnectSuccessCallback
			self.DatabaseConnection.onConnectionFailed = ConnectFailureCallback
		end

		self.DatabaseConnection:connect()
	else
		self.Initialized = true
		self.Retrying = false
	end

	return true
end
hook.Add("Initialize", "lemon.sql.Connect", function() lemon.sql:Connect() end)

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

function lemon.sql:Query(query, callback, userdata)
	if lemon.config:Get("SQL_CONNECTION_TYPE") == "remote" or lemon.config:Get("SQL_CONNECTION_TYPE") == "sourcebans" then
		if lemon.config:GetBool("SQL_REDIRECTED") then
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

			local parameters = {username = lemon.config:Get("SQL_USERNAME"), password = lemon.config:Get("SQL_PASSWORD"), database = lemon.config:Get("SQL_DATABASE"), query = query}

			HTTP({url = lemon.config:Get("SQL_REDIRECTOR_URL"), method = "post", parameters = parameters, success = success, failed = failed})
			return true
		else
			if self.Initialized and not self.Retrying then
				local databasequery = self.DatabaseConnection:query(query)
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
function lemon.sql:EscapeString(input, quotes)
	local str = tostring(input)

	for i = 1, #escape_list / 2 do
		str = str:gsub(escape_list[i * 2 - 1], "\\" .. escape_list[i * 2])
	end

	if quotes then
		return "'" .. str .. "'"
	end

	return str
end