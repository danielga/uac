-- Execution of file should be able to continue even if tmysql4 is missing
local module_filename = SERVER and "gmsv_tmysql4_" or "gmcl_tmysql4_"
if system.IsWindows() then
	module_filename = module_filename .. (jit.arch == "x86" and "win32.dll" or "win64.dll")
elseif system.IsLinux() then
	module_filename = module_filename .. (jit.arch == "x86" and "linux.dll" or "linux64.dll")
elseif system.IsOSX() then
	module_filename = module_filename .. (jit.arch == "x86" and "osx.dll" or "osx64.dll")
else
	return
end

if not file.Exists("lua/bin/" .. module_filename, "MOD") then
	return
end

local success = pcall(require, "tmysql4")
if not success then
	return
end

uac.persistence.mysql = uac.persistence.mysql or {}

local mysql = uac.persistence.mysql

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
