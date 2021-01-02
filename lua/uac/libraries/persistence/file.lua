uac.persistence.file = uac.persistence.file or {}

local pfile = uac.persistence.file

if not file.IsDir("uac/persistence", "DATA") then
	file.CreateDir("uac/persistence")
end

function pfile.Initialize()
	return true
end

function pfile.Query(query, callback, errorcallback, userdata)
	return true
end

function pfile.EscapeString(...)
	return ...
end
