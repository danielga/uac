uac.sql = uac.sql or {}

include("sqlite.lua")
include("mysql.lua")

local current_system

function uac.sql.Initialize()
	-- we already initialized, courtesy of another library
	if current_system ~= nil then
		return
	end

	local remote = uac.config.GetValue("sql_connection_type") == "remote" or
		uac.config.GetValue("sql_connection_type") == "sourcebans"

	if remote and uac.sql.mysql ~= nil then
		current_system = uac.sql.mysql
	else
		if remote then
			-- print an error about missing tmysql4 and warn that local was automatically selected

		elseif uac.config.GetValue("sql_connection_type") ~= "local" then
			-- print an error about bad configs and warn that local was automatically selected

		end

		current_system = uac.sql.sqlite
	end

	local success, err = current_system.Initialize()
	if not success then
		-- print an error about being unable to initialize database connection
		
	end

	return success
end
hook.Add("Initialize", "uac.sql.Initialize", uac.sql.Initialize)

function uac.sql.Query(query, callback, errorcallback, userdata)
	if current_system == nil and not uac.sql.Initialize() then
		return false
	end

	return current_system.Query(query, callback, errorcallback, userdata)
end

function uac.sql.EscapeString(input)
	if current_system == nil and not uac.sql.Initialize() then
		return ""
	end

	return current_system.EscapeString(input)
end
