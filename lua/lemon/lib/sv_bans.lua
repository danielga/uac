lemon.ban = lemon.ban or {}
lemon.ban.List = lemon.ban.List or {}

local function GetSourceBansListSuccessCallback(succeeded, data, userdata)
	if userdata then
		if succeeded and data then
			local newdata = {}
			for i = 1, #data do
				newdata[i] = {}
				newdata[i]["Name"] = data[i]["name"]
				newdata[i]["SteamID"] = data[i]["authid"]
				newdata[i]["IPAddress"] = data[i]["ip"]
				newdata[i]["Start"] = data[i]["created"]
				newdata[i]["End"] = data[i]["ends"]
				newdata[i]["Length"] = data[i]["length"]
				newdata[i]["Reason"] = data[i]["reason"]
				newdata[i]["AdminID"] = data[i]["aid"]
			end
			userdata(true, newdata)
		else
			userdata(false, data)
		end
	end
end

local function GetLemonBansListSuccessCallback(succeeded, data, userdata)
	if userdata then
		if succeeded and data then
			local newdata = {}
			for i = 1, #data do
				newdata[i] = {}
				newdata[i]["Name"] = data[i]["name"]
				newdata[i]["SteamID"] = data[i]["authid"]
				newdata[i]["Start"] = data[i]["created"]
				newdata[i]["End"] = data[i]["ends"]
				newdata[i]["Length"] = data[i]["length"]
				newdata[i]["Reason"] = data[i]["reason"]
				newdata[i]["AdminID"] = data[i]["aid"]
			end
			userdata(true, newdata)
		else
			userdata(false, data)
		end
	end
end

function lemon.ban:GetList(callback)
	if lemon.config:GetValue("SQL_CONNECTION_TYPE") == "sourcebans" then
		lemon.sql:Query(lemon.ban.SourceBansQueries["Get all active bans"]:format(lemon.config:GetValue("SOURCEBANS_PREFIX")), GetSourceBansListSuccessCallback, callback)
	else
		lemon.sql:Query(lemon.ban.LemonQueries["Get all active bans"]:format(lemon.config:GetValue("LEMON_BANS_TABLE")), GetLemonBansListSuccessCallback, callback)
	end
end

function lemon.ban:IsBanned(ident)
	local ident_type = type(ident)
	if ident_type == "Player" then
		return self.List[ident:SteamID()] != nil
	elseif ident_type == "string" then
		return self.List[ident] != nil
	end

	return false
end

function lemon.ban:Add(ident, time, reason)
	local sql_table = lemon.config:GetValue("LEMON_BANS_TABLE")

	local ident_type = type(ident)
	if ident_type == "Player" then
		ident = ident:SteamID()
	elseif ident_type == "string" then
		ident = string.match(ident, "(STEAM_%d:%d:%d+)")
		if not ident then
			return
		end
	else
		return
	end

	game.ConsoleCommand("banid " .. time .. " " .. ident)
	local start = os.time()
	self.List[ident] = {Reason = reason, Length = time, Start = start}

	lemon.sql:Query("SELECT * FROM " .. sql_table .. " WHERE steamid = " .. ident, function(succeeded, data)
		if succeeded and data then
			lemon.sql:Query("UPDATE " .. sql_table .. " SET reason = " .. reason .. ", length = " .. time .. ", start = " .. start .. " WHERE steamid = " .. ident)
		else
			lemon.sql:Query("INSERT INTO " .. sql_table .. " (steamid, reason, length, start) VALUES (" .. ident .. ", " .. reason .. ", " .. time .. ", " .. start .. ")")
		end
	end)
end

function lemon.ban:Remove(ident, reason)
	local ban = self.List[ident]
	if ban then
		if os.time() < ban.Start + ban.Length * 60 then
			game.ConsoleCommand("removeid " .. ident)
		end

		local sql_table = lemon.config:GetValue("LEMON_BANS_TABLE")
		self.List[ident] = nil

		lemon.sql:Query("SELECT * FROM " .. sql_table .. " WHERE steamid = " .. steamid, function(succeeded, data)
			if succeeded and data then
				lemon.sql:Query("DELETE FROM " .. sql_table .. " WHERE steamid = " .. steamid)
			end
		end)
	end
end

local META = FindMetaTable("Player")
if META then
	function META:Ban(minutes, reason)
		lemon.ban:Add(self, minutes, reason)
	end
end