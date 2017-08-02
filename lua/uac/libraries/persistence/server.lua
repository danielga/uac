uac.persistence = uac.persistence or {}

include("sqlite.lua")
include("mysql.lua")

local current_system

function uac.persistence.Initialize()
	-- we already initialized, courtesy of another library
	if current_system ~= nil then
		return
	end

	local remote = uac.config.GetValue("sql_connection_type") == "remote" or
		uac.config.GetValue("sql_connection_type") == "sourcebans"

	if remote and uac.persistence.mysql ~= nil then
		current_system = uac.persistence.mysql
	else
		if remote then
			-- print an error about missing tmysql4 and warn that local was automatically selected

		elseif uac.config.GetValue("sql_connection_type") ~= "local" then
			-- print an error about bad configs and warn that local was automatically selected

		end

		current_system = uac.persistence.sqlite
	end

	local success, err = current_system.Initialize()
	if not success then
		-- print an error about being unable to initialize database connection

	end

	return success
end
hook.Add("Initialize", "uac.persistence.Initialize", function()
	uac.persistence.Initialize()
end)

function uac.persistence.Query(query, callback, errorcallback, userdata)
	if current_system == nil and not uac.persistence.Initialize() then
		return false
	end

	return current_system.Query(query, callback, errorcallback, userdata)
end

function uac.persistence.EscapeString(input)
	if current_system == nil and not uac.persistence.Initialize() then
		return ""
	end

	return current_system.EscapeString(input)
end
