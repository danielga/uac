uac.persistence.sqlite = uac.persistence.sqlite or {}

local sqlite = uac.persistence.sqlite

function sqlite.Initialize()
	return true
end

function sqlite.Query(query, callback, errorcallback, userdata)
	local ret = sql.Query(query)
	if ret == false then
		if errorcallback ~= nil then
			errorcallback(sql.LastError(), userdata)
		end

		return
	end

	if callback ~= nil then
		callback(ret, sql.Query("SELECT last_insert_rowid() AS id;")[1].id, userdata)
	end

	return true
end

sqlite.EscapeString = sql.SQLStr
