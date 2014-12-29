lemon.ban = lemon.ban or {}

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

local LemonBansQueries = {
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

----------------------------------------------------------------

local function GetQuery(querytype)
	local query
	local tblprefix

	if lemon.config:GetValue("sql_connection_type") == "sourcebans" then
		query = SourceBansQueries[querytype]
		tblprefix = lemon.config:GetValue("sourcebans_prefix")
	else
		query = LemonBansQueries[querytype]
		tblprefix = lemon.config:GetValue("lemon_prefix")
	end

	if query then return lemon.string:Format(query, tblprefix) end
end

----------------------------------------------------------------

function lemon.ban.GetList(callback, userdata)
	lemon.sql.Query(GetQuery("Get all bans"), callback, userdata)
end

function lemon.ban.GetActiveList(callback, userdata)
	lemon.sql.Query(GetQuery("Get all active bans"), callback, userdata)
end

----------------------------------------------------------------

local function IsBannedCheck(succeeded, data, userdata)
	if succeeded and #data > 0 and IsValid(userdata.Player) then
		userdata.Player:GetLemonTable().LastBanUpdate = CurTime()
		userdata.Player:GetLemonTable().IsBanned = true
	end

	if userdata.Callback then
		userdata.Callback(succeeded, data, userdata.Userdata)
	end
end

function lemon.ban.IsBanned(ident, callback, userdata)
	local userdata = {Callback = callback, Userdata = userdata}
	local query
	if IsValid(ident) then
		userdata.Player = ident
		query = lemon.string.Format(GetQuery("Check player is banned"), ident:SteamID(), ident:IPAddress())
	elseif lemon.string.IsSteamIDValid(ident) then
		query = lemon.string.Format(GetQuery("Check player is banned by SteamID"), ident)
	elseif lemon.string.IsIPValid(ident) then
		query = lemon.string.Format(GetQuery("Check player is banned by IP"), ident)
	else
		return false
	end

	return lemon.sql.Query(query, IsBannedCheck, userdata)
end

----------------------------------------------------------------

local function VerifyBan(succeeded, data, userdata)
	if not succeeded then
		if IsValid(userdata.Player) then
			if IsValid(userdata.Admin) then
				userdata.Admin:ChatText(Color(255, 0, 0, 255), "[lemon] ", Color(255, 255, 255, 255), "Unable to ban player " .. userdata.Player:Name() .. " (" .. userdata.SteamID .. "). Error: " .. data .. "\n")
			else
				MsgC(Color(255, 0, 0, 255), "[lemon] ")
				MsgC(Color(255, 255, 255, 255), "Unable to ban player " .. userdata.Player:Name() .. " (" .. userdata.SteamID .. "). Error: " .. data .. "\n")
			end

			return
		end

		if IsValid(userdata.Admin) then
			userdata.Admin:ChatText(Color(255, 0, 0, 255), "[lemon] ", Color(255, 255, 255, 255), "Unable to ban player with " .. userdata.SteamID and ("SteamID " .. userdata.SteamID) or ("IP " .. userdata.IP) .. " (" .. userdata.Name == "" and "no name provided" or ("named " .. userdata.Name) .. "). Error: " .. data .. "\n")
		else
			MsgC(Color(255, 0, 0, 255), "[lemon] ")
			MsgC(Color(255, 255, 255, 255), "Unable to ban player with " .. userdata.SteamID and ("SteamID " .. userdata.SteamID) or ("IP " .. userdata.IP) .. " (" .. userdata.Name == "" and "no name provided" or ("named " .. userdata.Name) .. "). Error: " .. data .. "\n")
		end

		-- Add temporary ban a la Sourcebans
		return
	end

	if IsValid(userdata.Player) then
		userdata.Player:GetLemonTable().LastBanUpdate = CurTime()
		userdata.Player:GetLemonTable().IsBanned = true

		if IsValid(userdata.Admin) then
			userdata.Admin:ChatText(Color(255, 0, 0, 255), "[lemon] ", Color(255, 255, 255, 255), "Banned player " .. userdata.Player:Name() .. " (" .. userdata.SteamID .. ").\n")
		else
			MsgC(Color(255, 0, 0, 255), "[lemon] ")
			MsgC(Color(255, 255, 255, 255), "Banned player " .. userdata.Player:Name() .. " (" .. userdata.SteamID .. ").\n")
		end

		return
	end

	if IsValid(userdata.Admin) then
		userdata.Admin:ChatText(Color(255, 0, 0, 255), "[lemon] ", Color(255, 255, 255, 255), "Banned player with " .. userdata.SteamID and ("SteamID " .. userdata.SteamID) or ("IP " .. userdata.IP) .. " (" .. userdata.Name == "" and "no name provided" or ("named " .. userdata.Name) .. ").\n")
	else
		MsgC(Color(255, 0, 0, 255), "[lemon] ")
		MsgC(Color(255, 255, 255, 255), "Banned player with " .. userdata.SteamID and ("SteamID " .. userdata.SteamID) or ("IP " .. userdata.IP) .. " (" .. userdata.Name == "" and "no name provided" or ("named " .. userdata.Name) .. ").\n")
	end

	-- Success message
end

local function AddBan(succeeded, data, userdata)
	if not succeeded then
		if IsValid(userdata.Player) then
			if IsValid(userdata.Admin) then
				userdata.Admin:ChatText(Color(255, 0, 0, 255), "[lemon] ", Color(255, 255, 255, 255), "Unable to ban player " .. userdata.Player:Name() .. " (" .. userdata.SteamID .. "). Error: " .. data .. "\n")
			else
				MsgC(Color(255, 0, 0, 255), "[lemon] ")
				MsgC(Color(255, 255, 255, 255), "Unable to ban player " .. userdata.Player:Name() .. " (" .. userdata.SteamID .. "). Error: " .. data .. "\n")
			end

			return
		end

		if IsValid(userdata.Admin) then
			userdata.Admin:ChatText(Color(255, 0, 0, 255), "[lemon] ", Color(255, 255, 255, 255), "Unable to ban player with " .. userdata.SteamID and ("SteamID " .. userdata.SteamID) or ("IP " .. userdata.IP) .. ". Error: " .. data .. "\n")
		else
			MsgC(Color(255, 0, 0, 255), "[lemon] ")
			MsgC(Color(255, 255, 255, 255), "Unable to ban player with " .. userdata.SteamID and ("SteamID " .. userdata.SteamID) or ("IP " .. userdata.IP) .. ". Error: " .. data .. "\n")
		end

		-- Add temporary ban a la Sourcebans
		return
	end

	if #data == 0 then
		local query
		if userdata.SteamID and userdata.IP then
			query = lemon.string.Format(GetQuery("Ban player"), userdata.SteamID, userdata.IP, userdata.Name, userdata.Length, userdata.Reason, userdata.AdminSteamID, userdata.AdminIP, serverip, serverport)
		elseif userdata.SteamID then
			query = lemon.string.Format(GetQuery("Ban player by SteamID"), userdata.SteamID, userdata.Name, userdata.Length, userdata.Reason, userdata.AdminSteamID, userdata.AdminIP, serverip, serverport)
		elseif userdata.IP then
			query = lemon.string.Format(GetQuery("Ban player by IP"), userdata.IP, userdata.Name, userdata.Length, userdata.Reason, userdata.AdminSteamID, userdata.AdminIP, serverip, serverport)
		end
			
		lemon.sql:Query(query, VerifyBan, userdata)
	else
		if IsValid(userdata.Player) then
			userdata.Player:GetLemonTable().LastBanUpdate = CurTime()
			userdata.Player:GetLemonTable().IsBanned = true

			if IsValid(userdata.Admin) then
				userdata.Admin:ChatText(Color(255, 0, 0, 255), "[lemon] ", Color(255, 255, 255, 255), "Unable to ban player " .. userdata.Player:Name() .. " (" .. userdata.SteamID .. ") because he is already banned.\n")
			else
				MsgC(Color(255, 0, 0, 255), "[lemon] ")
				MsgC(Color(255, 255, 255, 255), "Unable to ban player " .. userdata.Player:Name() .. " (" .. userdata.SteamID .. ") because he is already banned.\n")
			end

			return
		end

		if IsValid(userdata.Admin) then
			userdata.Admin:ChatText(Color(255, 0, 0, 255), "[lemon] ", Color(255, 255, 255, 255), "Unable to ban player with " .. userdata.SteamID and ("SteamID " .. userdata.SteamID) or ("IP " .. userdata.IP) .. " because he is already banned.\n")
		else
			MsgC(Color(255, 0, 0, 255), "[lemon] ")
			MsgC(Color(255, 255, 255, 255), "Unable to ban player with " .. userdata.SteamID and ("SteamID " .. userdata.SteamID) or ("IP " .. userdata.IP) .. " because he is already banned.\n")
		end

		-- Is already banned, warn
	end
end

function lemon.ban.Add(ident, time, reason, issuer, name)
	local userdata = {Name = name or "", Length = time, Reason = reason, AdminSteamID = "STEAM_ID_SERVER", AdminIP = serverip}
	if IsValid(ident) then
		userdata.SteamID = ident:SteamID()
		userdata.IP = ident:IPAddress()
		userdata.Name = ident:Name()
		userdata.Player = ident

		ident:GetLemonTable().LastBanUpdate = CurTime()
		ident:GetLemonTable().IsBanned = true
	elseif lemon.string.IsSteamIDValid(ident) then
		userdata.SteamID = ident
	elseif lemon.string.IsIPValid(ident) then
		userdata.IP = ident
	else
		return false
	end

	if IsValid(issuer) then
		userdata.Admin = issuer
		userdata.AdminSteamID = issuer:SteamID()
		userdata.AdminIP = issuer:IPAddress()
	end

	return lemon.ban.IsBanned(ident, AddBan, userdata)
end

----------------------------------------------------------------

local function VerifyUnban(succeeded, data, userdata)
	if not succeeded then
		if IsValid(userdata.Player) then
			if IsValid(userdata.Admin) then
				userdata.Admin:ChatText(Color(255, 0, 0, 255), "[lemon] ", Color(255, 255, 255, 255), "Unable to unban player " .. userdata.Player:Name() .. " (" .. userdata.SteamID .. "). Error: " .. data .. "\n")
			else
				MsgC(Color(255, 0, 0, 255), "[lemon] ")
				MsgC(Color(255, 255, 255, 255), "Unable to unban player " .. userdata.Player:Name() .. " (" .. userdata.SteamID .. "). Error: " .. data .. "\n")
			end

			return
		end

		if IsValid(userdata.Admin) then
			userdata.Admin:ChatText(Color(255, 0, 0, 255), "[lemon] ", Color(255, 255, 255, 255), "Unable to unban player with " .. userdata.SteamID and ("SteamID " .. userdata.SteamID) or ("IP " .. userdata.IP) .. ". Error: " .. data .. "\n")
		else
			MsgC(Color(255, 0, 0, 255), "[lemon] ")
			MsgC(Color(255, 255, 255, 255), "Unable to unban player with " .. userdata.SteamID and ("SteamID " .. userdata.SteamID) or ("IP " .. userdata.IP) .. ". Error: " .. data .. "\n")
		end

		-- Warn
		return
	end

	if IsValid(userdata.Player) then
		userdata.Player:GetLemonTable().LastBanUpdate = CurTime()
		userdata.Player:GetLemonTable().IsBanned = false

		if IsValid(userdata.Admin) then
			userdata.Admin:ChatText(Color(255, 0, 0, 255), "[lemon] ", Color(255, 255, 255, 255), "Unbanned player " .. userdata.Player:Name() .. " (" .. userdata.SteamID .. ").\n")
		else
			MsgC(Color(255, 0, 0, 255), "[lemon] ")
			MsgC(Color(255, 255, 255, 255), "Unbanned player " .. userdata.Player:Name() .. " (" .. userdata.SteamID .. ").\n")
		end

		return
	end

	if IsValid(userdata.Admin) then
		userdata.Admin:ChatText(Color(255, 0, 0, 255), "[lemon] ", Color(255, 255, 255, 255), "Unbanned player with " .. userdata.SteamID and ("SteamID " .. userdata.SteamID) or ("IP " .. userdata.IP) .. ".\n")
	else
		MsgC(Color(255, 0, 0, 255), "[lemon] ")
		MsgC(Color(255, 255, 255, 255), "Unbanned player with " .. userdata.SteamID and ("SteamID " .. userdata.SteamID) or ("IP " .. userdata.IP) .. ".\n")
	end
end

local function RemoveBan(succeeded, data, userdata)
	if not succeeded then
		if IsValid(userdata.Player) then
			if IsValid(userdata.Admin) then
				userdata.Admin:ChatText(Color(255, 0, 0, 255), "[lemon] ", Color(255, 255, 255, 255), "Unable to unban player " .. userdata.Player:Name() .. " (" .. userdata.SteamID .. "). Error: " .. data .. "\n")
			else
				MsgC(Color(255, 0, 0, 255), "[lemon] ")
				MsgC(Color(255, 255, 255, 255), "Unable to unban player " .. userdata.Player:Name() .. " (" .. userdata.SteamID .. "). Error: " .. data .. "\n")
			end

			return
		end

		if IsValid(userdata.Admin) then
			userdata.Admin:ChatText(Color(255, 0, 0, 255), "[lemon] ", Color(255, 255, 255, 255), "Unable to unban player with " .. userdata.SteamID and ("SteamID " .. userdata.SteamID) or ("IP " .. userdata.IP) .. ". Error: " .. data .. "\n")
		else
			MsgC(Color(255, 0, 0, 255), "[lemon] ")
			MsgC(Color(255, 255, 255, 255), "Unable to unban player with " .. userdata.SteamID and ("SteamID " .. userdata.SteamID) or ("IP " .. userdata.IP) .. ". Error: " .. data .. "\n")
		end

		-- Warn
		return
	end

	if #data > 0 then
		lemon.sql.Query(lemon.string.Format(GetQuery("Unban player"), userdata.AdminSteamID, userdata.Reason, data[1].bid), VerifyUnban, userdata)
	else
		if IsValid(userdata.Player) then
			userdata.Player:GetLemonTable().LastBanUpdate = CurTime()
			userdata.Player:GetLemonTable().IsBanned = false

			if IsValid(userdata.Admin) then
				userdata.Admin:ChatText(Color(255, 0, 0, 255), "[lemon] ", Color(255, 255, 255, 255), "Unable to unban player " .. userdata.Player:Name() .. " (" .. userdata.SteamID .. ") because he is not banned.\n")
			else
				MsgC(Color(255, 0, 0, 255), "[lemon] ")
				MsgC(Color(255, 255, 255, 255), "Unable to unban player " .. userdata.Player:Name() .. " (" .. userdata.SteamID .. ") because he is not banned.\n")
			end

			return
		end

		if IsValid(userdata.Admin) then
			userdata.Admin:ChatText(Color(255, 0, 0, 255), "[lemon] ", Color(255, 255, 255, 255), "Unable to unban player with " .. userdata.SteamID and ("SteamID " .. userdata.SteamID) or ("IP " .. userdata.IP) .. " because he is not banned.\n")
		else
			MsgC(Color(255, 0, 0, 255), "[lemon] ")
			MsgC(Color(255, 255, 255, 255), "Unable to unban player with " .. userdata.SteamID and ("SteamID " .. userdata.SteamID) or ("IP " .. userdata.IP) .. " because he is not banned.\n")
		end

		-- Is not banned, warn
	end
end

function lemon.ban.Remove(ident, reason, issuer)
	local userdata = {SteamID = ident, Reason = reason, AdminSteamID = "STEAM_ID_SERVER"}
	if IsValid(ident) then
		userdata.SteamID = ident:SteamID()
		userdata.IP = ident:IPAddress()
		userdata.Name = ident:Name()
		userdata.Player = ident
	elseif lemon.string.IsSteamIDValid(ident) then
		userdata.SteamID = ident
	elseif lemon.string.IsIPValid(ident) then
		userdata.IP = ident
	else
		return false
	end

	if IsValid(issuer) then
		userdata.Admin = issuer
		userdata.AdminSteamID = issuer:SteamID()
	end

	return lemon.ban.IsBanned(ident, RemoveBan, userdata)
end

----------------------------------------------------------------

local META = FindMetaTable("Player")
if META then
	function META:Ban(minutes, reason, issuer) -- issuer added to the end to allow compatibility with vanilla GMod
		return lemon.ban.Add(self, minutes, reason, issuer)
	end

	function META:Unban(reason, issuer) -- in case you want a "let banned players come in with restrictions"
		return lemon.ban.Remove(self, reason, issuer)
	end

	local function UpdateStatus(succeeded, data, userdata)
		if succeeded and #data > 0 and IsValid(userdata) then
			userdata:GetLemonTable().IsBanned = true
		end
	end

	function META:IsBanned() -- in case you want a "let banned players come in with restrictions"
		local plytable = self:GetLemonTable()
		local curtime = CurTime() -- only update the cached value each 15 seconds if IsBanned is called frequently
		if curtime - (plytable.LastBanUpdate or 0) >= 15 then
			plytable.LastBanUpdate = curtime
			lemon.ban.IsBanned(self, UpdateStatus, self)
		end
		
		return plytable.IsBanned or false -- returns cached value or false but tries to update it when this function is called
	end
end

----------------------------------------------------------------

local function CheckJoiningPlayerStatus(succeeded, data, userdata)
	if not succeeded then
		-- Warn
		return
	end

	if IsValid(userdata.Player) then
		local plytable = userdata.Player:GetLemonTable()
		plytable.LastBanUpdate = CurTime()

		if #data > 0 then
			plytable.IsBanned = true
			-- Return true on a BannedPlayerConnect hook to allow the player to join the server
			if not hook.Run("BannedPlayerConnect", userdata.Player, data[1].reason) then
				userdata.Player:Kick(data[1].reason)
			end
		end
	elseif #data > 0 then
		-- Can log some shit here.
	end
end

hook.Add("PlayerAuthed", "lemon.bans.CheckPlayerStatus", function(ply, steamid, uniqueid)
	lemon.ban.IsBanned(self, CheckJoiningPlayerStatus, {Player = ply, SteamID = steamid, IP = ply:IPAddress()})
end)