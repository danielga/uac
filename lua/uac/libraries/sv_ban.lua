uac.ban = uac.ban or {}

local SourceBansQueries = {
	["Check player is banned"] = "SELECT bid AS BanID FROM {1}_bans WHERE ((type = 0 AND authid = '{2}') OR (type = 1 AND ip = '{3}')) AND (length = 0 OR ends > UNIX_TIMESTAMP()) AND RemoveType IS NULL",
	["Check player is banned by SteamID"] = "SELECT bid AS BanID FROM {1}_bans WHERE (type = 0 AND authid = '{2}') AND (length = 0 OR ends > UNIX_TIMESTAMP()) AND RemoveType IS NULL",
	["Check player is banned by IP"] = "SELECT bid AS BanID FROM {1}_bans WHERE (type = 1 AND ip = '{2}') AND (length = 0 OR ends > UNIX_TIMESTAMP()) AND RemoveType IS NULL",

	["Get all active bans"] = "SELECT bid AS BanID, type AS BanType, ip AS IPAddress, authid AS SteamID, name AS Name, created AS BanStart, ends AS BanEnd, length AS BanLength, reason AS BanReason, aid AS AdminID, adminIp as AdminIP FROM {1}_bans b WHERE (length = 0 OR ends > UNIX_TIMESTAMP()) AND RemoveType IS NULL",
	["Get all bans"] = "SELECT bid AS BanID, type AS BanType, ip AS IPAddress, authid AS SteamID, name AS Name, created AS BanStart, ends AS BanEnd, length AS BanLength, reason AS BanReason, aid AS AdminID, adminIp as AdminIP, RemovedBy AS UnbannedByID, RemoveType AS UnbanType, RemovedOn AS UnbannedOn, ureason AS UnbanReason FROM {1}_bans b",

	["Log join attempt"] = "INSERT INTO {1}_banlog (sid, time, name, bid) VALUES(IFNULL((SELECT sid FROM {1}_servers WHERE ip = '{2}' AND port = {3} LIMIT 0, 1), -1), {4}, '{5}', {6})",

	["Ban player"] = "INSERT INTO {1}_bans (type, authid, ip, name, created, ends, length, reason, aid, adminIp, sid, country) VALUES (0, '{2}', '{3}', '{4}', UNIX_TIMESTAMP(), UNIX_TIMESTAMP() + {5}, {5}, '{6}', IFNULL((SELECT aid FROM {1}_admins WHERE authid = '{7}'), 0), '{8}', IFNULL((SELECT sid FROM {1}_servers WHERE ip = '{9}' AND port = {10} LIMIT 0, 1), -1), ' ')",
	["Ban player by IP"] = "INSERT INTO {1}_bans (type, ip, name, created, ends, length, reason, aid, adminIp, sid, country) VALUES (1, '{2}', '{3}', UNIX_TIMESTAMP(), UNIX_TIMESTAMP() + {4}, {4}, '{5}', IFNULL((SELECT aid FROM {1}_admins WHERE authid = '{6}'), 0), '{7}', IFNULL((SELECT sid FROM {1}_servers WHERE ip = '{8}' AND port = {9} LIMIT 0, 1), -1), ' ')",
	["Ban player by SteamID"] = "INSERT INTO {1}_bans (type, authid, name, created, ends, length, reason, aid, adminIp, sid, country) VALUES (0, '{2}', '{3}', UNIX_TIMESTAMP(), UNIX_TIMESTAMP() + {4}, {4}, '{5}', IFNULL((SELECT aid FROM {1}_admins WHERE authid = '{6}'), 0), '{7}', IFNULL((SELECT sid FROM {1}_servers WHERE ip = '{8}' AND port = {9} LIMIT 0, 1), -1), ' ')",

	["Unban player"] = "UPDATE {1}_bans SET RemovedBy = IFNULL((SELECT aid FROM {1}_admins WHERE authid = '{2}'), 0), RemoveType = 'U', RemovedOn = UNIX_TIMESTAMP(), ureason = '{3}' WHERE bid = {4}",
}

local UACBansQueries = {
	["Check player is banned"] = "SELECT bid AS BanID FROM {1}_bans WHERE ((type = 0 AND authid = '{2}') OR (type = 1 AND ip = '{3}')) AND (length = 0 OR ends > UNIX_TIMESTAMP()) AND RemoveType IS NULL",
	["Check player is banned by SteamID"] = "SELECT bid AS BanID FROM {1}_bans WHERE (type = 0 AND authid = '{2}') AND (length = 0 OR ends > UNIX_TIMESTAMP()) AND RemoveType IS NULL",
	["Check player is banned by IP"] = "SELECT bid AS BanID FROM {1}_bans WHERE (type = 1 AND ip = '{2}') AND (length = 0 OR ends > UNIX_TIMESTAMP()) AND RemoveType IS NULL",

	["Get all active bans"] = "SELECT bid AS BanID, type AS BanType, ip AS IPAddress, authid AS SteamID, name AS Name, created AS BanStart, ends AS BanEnd, length AS BanLength, reason AS BanReason, aid AS AdminID, adminIp as AdminIP FROM {1}_bans b WHERE (length = 0 OR ends > UNIX_TIMESTAMP()) AND RemoveType IS NULL",
	["Get all bans"] = "SELECT bid AS BanID, type AS BanType, ip AS IPAddress, authid AS SteamID, name AS Name, created AS BanStart, ends AS BanEnd, length AS BanLength, reason AS BanReason, aid AS AdminID, adminIp as AdminIP, RemovedBy AS UnbannedByID, RemoveType AS UnbanType, RemovedOn AS UnbannedOn, ureason AS UnbanReason FROM {1}_bans b",

	["Log join attempt"] = "INSERT INTO {1}_banlog (sid, time, name, bid) VALUES(IFNULL((SELECT sid FROM {1}_servers WHERE ip = '{2}' AND port = {3} LIMIT 0, 1), -1), {4}, '{5}', {6})",

	["Ban player"] = "INSERT INTO {1}_bans (type, authid, ip, name, created, ends, length, reason, aid, adminIp, sid, country) VALUES (0, '{2}', '{3}', '{4}', UNIX_TIMESTAMP(), UNIX_TIMESTAMP() + {5}, {5}, '{6}', IFNULL((SELECT aid FROM {1}_admins WHERE authid = '{7}'), 0), '{8}', IFNULL((SELECT sid FROM {1}_servers WHERE ip = '{9}' AND port = {10} LIMIT 0, 1), -1), ' ')",
	["Ban player by IP"] = "INSERT INTO {1}_bans (type, ip, name, created, ends, length, reason, aid, adminIp, sid, country) VALUES (1, '{2}', '{3}', UNIX_TIMESTAMP(), UNIX_TIMESTAMP() + {4}, {4}, '{5}', IFNULL((SELECT aid FROM {1}_admins WHERE authid = '{6}'), 0), '{7}', IFNULL((SELECT sid FROM {1}_servers WHERE ip = '{8}' AND port = {9} LIMIT 0, 1), -1), ' ')",
	["Ban player by SteamID"] = "INSERT INTO {1}_bans (type, authid, name, created, ends, length, reason, aid, adminIp, sid, country) VALUES (0, '{2}', '{3}', UNIX_TIMESTAMP(), UNIX_TIMESTAMP() + {4}, {4}, '{5}', IFNULL((SELECT aid FROM {1}_admins WHERE authid = '{6}'), 0), '{7}', IFNULL((SELECT sid FROM {1}_servers WHERE ip = '{8}' AND port = {9} LIMIT 0, 1), -1), ' ')",

	["Unban player"] = "UPDATE {1}_bans SET RemovedBy = IFNULL((SELECT aid FROM {1}_admins WHERE authid = '{2}'), 0), RemoveType = 'U', RemovedOn = UNIX_TIMESTAMP(), ureason = '{3}' WHERE bid = {4}",
}

local function GetQuery(querytype)
	local query
	local tblprefix

	if uac.config.GetString("sql_connection_type") == "sourcebans" then
		query = SourceBansQueries[querytype]
		tblprefix = uac.config.GetString("sourcebans_prefix", "sb")
	else
		query = UACBansQueries[querytype]
		tblprefix = uac.config.GetString("uac_prefix", "uac")
	end

	return query, tblprefix
end

function uac.ban.GetList(callback, userdata)
	-- GetQuery("Get all bans")
end

function uac.ban.GetActiveList(callback, userdata)
	-- GetQuery("Get all active bans")
end

function uac.ban.IsBanned(ident, callback, userdata)
	userdata = {callback = callback, userdata = userdata}
	local query, prefix
	if IsValid(ident) then
		userdata.Player = ident
		query, prefix = GetQuery("Check player is banned")
		query = uac.string.Format(query, prefix, ident:SteamID(), ident:IPAddress())
	elseif uac.string.IsSteamIDValid(ident) then
		query, prefix = GetQuery("Check player is banned by SteamID")
		query = uac.string.Format(query, prefix, ident)
	elseif uac.string.IsIPValid(ident) then
		query, prefix = GetQuery("Check player is banned by IP")
		query = uac.string.Format(query, prefix, ident)
	else
		return false
	end

	-- perform query
end

function uac.ban.Add(ident, time, reason, issuer, name)
	local userdata = {Name = name or "", Length = time, Reason = reason, AdminSteamID = "STEAM_ID_SERVER", AdminIP = serverip}
	if IsValid(ident) then
		userdata.SteamID = ident:SteamID()
		userdata.IP = ident:IPAddress()
		userdata.Name = ident:Name()
		userdata.Player = ident

		local uactable = ident:UACGetTable()
		uactable.lastbanupdate = CurTime()
		uactable.banned = true
	elseif uac.string.IsSteamIDValid(ident) then
		userdata.SteamID = ident
	elseif uac.string.IsIPValid(ident) then
		userdata.IP = ident
	else
		return false
	end

	if IsValid(issuer) then
		userdata.Admin = issuer
		userdata.AdminSteamID = issuer:SteamID()
		userdata.AdminIP = issuer:IPAddress()
	end

	return uac.ban.IsBanned(ident, AddBan, userdata)
end

function uac.ban.Remove(ident, reason, issuer)
	local userdata = {steamid = ident, reason = reason, adminsteamid = "STEAM_ID_SERVER"}
	if IsValid(ident) then
		userdata.steamid = ident:SteamID()
		userdata.ip = ident:IPAddress()
		userdata.name = ident:Name()
		userdata.player = ident
	elseif uac.string.IsSteamIDValid(ident) then
		userdata.steamid = ident
	elseif uac.string.IsIPValid(ident) then
		userdata.ip = ident
	else
		return false
	end

	if IsValid(issuer) then
		userdata.admin = issuer
		userdata.adminsteamid = issuer:SteamID()
	end

	return uac.ban.IsBanned(ident, RemoveBan, userdata)
end

local META = FindMetaTable("Player")
if META then
	function META:Ban(minutes, reason, issuer) -- issuer added to the end to allow compatibility with vanilla GMod
		return uac.ban.Add(self, minutes, reason, issuer)
	end

	function META:Unban(reason, issuer) -- in case you want a "let banned players come in with restrictions"
		return uac.ban.Remove(self, reason, issuer)
	end

	function META:IsBanned() -- in case you want a "let banned players come in with restrictions"
		local uactable = self:UACGetTable()
		local curtime = CurTime() -- only update the cached value each 15 seconds if IsBanned is called frequently
		if curtime - (uactable.lastbanupdate or 0) >= 15 then
			uactable.lastbanupdate = curtime
			uac.ban.IsBanned(self, UpdateStatus, self)
		end

		return uactable.banned or false -- returns cached value or false but tries to update it when this function is called
	end
end

hook.Add("PlayerAuthed", "uac.bans.CheckPlayerStatus", function(ply, steamid, uniqueid)
	uac.ban.IsBanned(ply, CheckJoiningPlayerStatus, {player = ply, steamid = steamid, ip = ply:IPAddress()})
end)
