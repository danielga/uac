-- Execution of file should be able to continue even if tmysql4 is missing
local success = pcall(require, "tmysql4")
if not success then
	return
end

uac.sql.mysql = uac.sql.mysql or {}

local mysql = uac.sql.mysql

function mysql.Initialize()
	if mysql.dbconnection == nil then
		local con, err = tmysql.initialize(
			uac.config.GetString("sql_host"),
			uac.config.GetString("sql_username"),
			uac.config.GetString("sql_password"),
			uac.config.GetString("sql_database"),
			uac.config.GetNumber("sql_host_port")
		)
		if con == nil then
			return false, err
		end

		mysql.dbconnection = con
	end

	return true
end

local function QueryCallback(results, data)
	results = results[1]
	if not results.status then
		if data.errorcallback ~= nil then
			data.errorcallback(results.error, data.userdata)
		end

		return
	end

	if data.callback ~= nil then
		data.callback(results.data, results.lastid, data.userdata)
	end
end

function mysql.Query(query, callback, errorcallback, userdata)
	if mysql.dbconnection == nil then
		return false
	end

	local data = {
		callback = callback,
		errorcallback = errorcallback,
		userdata = userdata
	}
	mysql.dbconnection:Query(query, QueryCallback, data)
	return true
end

function mysql.EscapeString(input)
	return "\"" .. mysql.dbconnection:Escape(tostring(input)) .. "\""
end
