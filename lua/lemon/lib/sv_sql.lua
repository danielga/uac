lemon.sql = lemon.sql or {}
lemon.sql.Initialized = lemon.sql.Initialized or false

local function ConnectSuccessCallback(database)
	if database.callback then
		database.callback(true)
	end

	lemon.sql.Initialized = true
end

local function ConnectFailureCallback(database, error)
	if database.callback then
		database.callback(false, error)
	end

	print(error)
end

function lemon.sql:Connect(callback)
	if lemon.config:GetValue("SQL_CONNECTION_TYPE") != "local" then
		local errored = pcall(require, "tmysql")
		if errored or !tmysql then
			lemon.config:SetValue("SQL_CONNECTION_TYPE", "local")
			self.Initialized = false
			return
		end

		if self.Initialized then
			self.DatabaseConnection = nil
			self.Initialized = false
		end

		self.DatabaseConnection = mysqloo.connect(lemon.config:GetValue("SQL_HOST"), lemon.config:GetValue("SQL_USERNAME"), lemon.config:GetValue("SQL_PASSWORD"), lemon.config:GetValue("SQL_DATABASE"), lemon.config:GetValue("SQL_HOSTPORT"))
		self.DatabaseConnection.callback = callback
		self.DatabaseConnection.onConnected = ConnectSuccessCallback
		self.DatabaseConnection.onConnectionFailed = ConnectFailureCallback
		self.DatabaseConnection:connect()
	end
end
hook.Add("PostGamemodeLoaded", "lemon.sql.Connect", function() lemon.sql:Connect() end)

local function QuerySuccessCallback(query)
	if query.callback then
		query.callback(true, queryObj:getData(), query.userdata)
	end
end

local function QueryFailureCallback(query, error)
	if query.callback then
		query.callback(false, error, query.userdata)
	end

	print(error)
end

function lemon.sql:Query(query, callback, userdata)
	if lemon.config:GetValue("SQL_CONNECTION_TYPE") == "local" then
		local ret = sql.Query(query)
		if callback then
			callback(ret and true or false, ret, userdata)
		end
	else
		if self.Initialized then
			local databasequery = self.DatabaseConnection:query(query)
			query.callback = callback
			query.userdata = userdata
			databasequery.onSuccess = QuerySuccessCallback
			databasequery.onFailure = QueryFailureCallback
			databasequery:start()
		end
	end
end

function lemon.sql:PrepareString(input, noQuotes)
	local str = tostring(input)
	if str:find('\\"') then
		return
	end

	str = str:gsub('"', '\\"')

	if noQuotes then
		return str
	end

	return "\"" .. str .. "\""
end