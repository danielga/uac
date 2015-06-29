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

----------------------------------------------------------------

local function GetQuery(querytype)
	local query
	local tblprefix

	if uac.config.GetValue("sql_connection_type") == "sourcebans" then
		query = SourceBansQueries[querytype]
		tblprefix = uac.config.GetValue("sourcebans_prefix")
	else
		query = UACBansQueries[querytype]
		tblprefix = uac.config.GetValue("uac_prefix")
	end

	if query then return uac.string.Format(query, tblprefix) end
end

----------------------------------------------------------------

function uac.ban.GetList(callback, userdata)
	uac.sql.Query(GetQuery("Get all bans"), callback, userdata)
end

function uac.ban.GetActiveList(callback, userdata)
	uac.sql.Query(GetQuery("Get all active bans"), callback, userdata)
end

----------------------------------------------------------------

local function IsBannedCheck(succeeded, data, userdata)
	if succeeded and #data > 0 and IsValid(userdata.Player) then
		userdata.Player:GetUACTable().LastBanUpdate = CurTime()
		userdata.Player:GetUACTable().IsBanned = true
	end

	if userdata.Callback then
		userdata.Callback(succeeded, data, userdata.Userdata)
	end
end

function uac.ban.IsBanned(ident, callback, userdata)
	local userdata = {Callback = callback, Userdata = userdata}
	local query
	if IsValid(ident) then
		userdata.Player = ident
		query = uac.string.Format(GetQuery("Check player is banned"), ident:SteamID(), ident:IPAddress())
	elseif uac.string.IsSteamIDValid(ident) then
		query = uac.string.Format(GetQuery("Check player is banned by SteamID"), ident)
	elseif uac.string.IsIPValid(ident) then
		query = uac.string.Format(GetQuery("Check player is banned by IP"), ident)
	else
		return false
	end

	return uac.sql.Query(query, IsBannedCheck, userdata)
end

----------------------------------------------------------------

local function VerifyBan(succeeded, data, userdata)
	if not succeeded then
		if IsValid(userdata.Player) then
			if IsValid(userdata.Admin) then
				userdata.Admin:ChatText(Color(255, 0, 0, 255), "[UAC] ", Color(255, 255, 255, 255), "Unable to ban player " .. userdata.Player:Name() .. " (" .. userdata.SteamID .. "). Error: " .. data .. "\n")
			else
				MsgC(Color(255, 0, 0, 255), "[UAC] ")
				MsgC(Color(255, 255, 255, 255), "Unable to ban player " .. userdata.Player:Name() .. " (" .. userdata.SteamID .. "). Error: " .. data .. "\n")
			end

			return
		end

		if IsValid(userdata.Admin) then
			userdata.Admin:ChatText(Color(255, 0, 0, 255), "[UAC] ", Color(255, 255, 255, 255), "Unable to ban player with " .. userdata.SteamID and ("SteamID " .. userdata.SteamID) or ("IP " .. userdata.IP) .. " (" .. userdata.Name == "" and "no name provided" or ("named " .. userdata.Name) .. "). Error: " .. data .. "\n")
		else
			MsgC(Color(255, 0, 0, 255), "[UAC] ")
			MsgC(Color(255, 255, 255, 255), "Unable to ban player with " .. userdata.SteamID and ("SteamID " .. userdata.SteamID) or ("IP " .. userdata.IP) .. " (" .. userdata.Name == "" and "no name provided" or ("named " .. userdata.Name) .. "). Error: " .. data .. "\n")
		end

		-- Add temporary ban a la Sourcebans
		return
	end

	if IsValid(userdata.Player) then
		userdata.Player:GetUACTable().LastBanUpdate = CurTime()
		userdata.Player:GetUACTable().IsBanned = true

		if IsValid(userdata.Admin) then
			userdata.Admin:ChatText(Color(255, 0, 0, 255), "[UAC] ", Color(255, 255, 255, 255), "Banned player " .. userdata.Player:Name() .. " (" .. userdata.SteamID .. ").\n")
		else
			MsgC(Color(255, 0, 0, 255), "[uac] ")
			MsgC(Color(255, 255, 255, 255), "Banned player " .. userdata.Player:Name() .. " (" .. userdata.SteamID .. ").\n")
		end

		return
	end

	if IsValid(userdata.Admin) then
		userdata.Admin:ChatText(Color(255, 0, 0, 255), "[UAC] ", Color(255, 255, 255, 255), "Banned player with " .. userdata.SteamID and ("SteamID " .. userdata.SteamID) or ("IP " .. userdata.IP) .. " (" .. userdata.Name == "" and "no name provided" or ("named " .. userdata.Name) .. ").\n")
	else
		MsgC(Color(255, 0, 0, 255), "[UAC] ")
		MsgC(Color(255, 255, 255, 255), "Banned player with " .. userdata.SteamID and ("SteamID " .. userdata.SteamID) or ("IP " .. userdata.IP) .. " (" .. userdata.Name == "" and "no name provided" or ("named " .. userdata.Name) .. ").\n")
	end

	-- Success message
end

local function AddBan(succeeded, data, userdata)
	if not succeeded then
		if IsValid(userdata.Player) then
			if IsValid(userdata.Admin) then
				userdata.Admin:ChatText(Color(255, 0, 0, 255), "[UAC] ", Color(255, 255, 255, 255), "Unable to ban player " .. userdata.Player:Name() .. " (" .. userdata.SteamID .. "). Error: " .. data .. "\n")
			else
				MsgC(Color(255, 0, 0, 255), "[UAC] ")
				MsgC(Color(255, 255, 255, 255), "Unable to ban player " .. userdata.Player:Name() .. " (" .. userdata.SteamID .. "). Error: " .. data .. "\n")
			end

			return
		end

		if IsValid(userdata.Admin) then
			userdata.Admin:ChatText(Color(255, 0, 0, 255), "[UAC] ", Color(255, 255, 255, 255), "Unable to ban player with " .. userdata.SteamID and ("SteamID " .. userdata.SteamID) or ("IP " .. userdata.IP) .. ". Error: " .. data .. "\n")
		else
			MsgC(Color(255, 0, 0, 255), "[UAC] ")
			MsgC(Color(255, 255, 255, 255), "Unable to ban player with " .. userdata.SteamID and ("SteamID " .. userdata.SteamID) or ("IP " .. userdata.IP) .. ". Error: " .. data .. "\n")
		end

		-- Add temporary ban a la Sourcebans
		return
	end

	if #data == 0 then
		local query
		if userdata.SteamID and userdata.IP then
			query = uac.string.Format(GetQuery("Ban player"), userdata.SteamID, userdata.IP, userdata.Name, userdata.Length, userdata.Reason, userdata.AdminSteamID, userdata.AdminIP, serverip, serverport)
		elseif userdata.SteamID then
			query = uac.string.Format(GetQuery("Ban player by SteamID"), userdata.SteamID, userdata.Name, userdata.Length, userdata.Reason, userdata.AdminSteamID, userdata.AdminIP, serverip, serverport)
		elseif userdata.IP then
			query = uac.string.Format(GetQuery("Ban player by IP"), userdata.IP, userdata.Name, userdata.Length, userdata.Reason, userdata.AdminSteamID, userdata.AdminIP, serverip, serverport)
		end
			
		uac.sql.Query(query, VerifyBan, userdata)
	else
		if IsValid(userdata.Player) then
			userdata.Player:GetUACTable().LastBanUpdate = CurTime()
			userdata.Player:GetUACTable().IsBanned = true

			if IsValid(userdata.Admin) then
				userdata.Admin:ChatText(Color(255, 0, 0, 255), "[UAC] ", Color(255, 255, 255, 255), "Unable to ban player " .. userdata.Player:Name() .. " (" .. userdata.SteamID .. ") because he is already banned.\n")
			else
				MsgC(Color(255, 0, 0, 255), "[UAC] ")
				MsgC(Color(255, 255, 255, 255), "Unable to ban player " .. userdata.Player:Name() .. " (" .. userdata.SteamID .. ") because he is already banned.\n")
			end

			return
		end

		if IsValid(userdata.Admin) then
			userdata.Admin:ChatText(Color(255, 0, 0, 255), "[UAC] ", Color(255, 255, 255, 255), "Unable to ban player with " .. userdata.SteamID and ("SteamID " .. userdata.SteamID) or ("IP " .. userdata.IP) .. " because he is already banned.\n")
		else
			MsgC(Color(255, 0, 0, 255), "[UAC] ")
			MsgC(Color(255, 255, 255, 255), "Unable to ban player with " .. userdata.SteamID and ("SteamID " .. userdata.SteamID) or ("IP " .. userdata.IP) .. " because he is already banned.\n")
		end

		-- Is already banned, warn
	end
end

function uac.ban.Add(ident, time, reason, issuer, name)
	local userdata = {Name = name or "", Length = time, Reason = reason, AdminSteamID = "STEAM_ID_SERVER", AdminIP = serverip}
	if IsValid(ident) then
		userdata.SteamID = ident:SteamID()
		userdata.IP = ident:IPAddress()
		userdata.Name = ident:Name()
		userdata.Player = ident

		ident:GetUACTable().LastBanUpdate = CurTime()
		ident:GetUACTable().IsBanned = true
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

----------------------------------------------------------------

local function VerifyUnban(succeeded, data, userdata)
	if not succeeded then
		if IsValid(userdata.Player) then
			if IsValid(userdata.Admin) then
				userdata.Admin:ChatText(Color(255, 0, 0, 255), "[UAC] ", Color(255, 255, 255, 255), "Unable to unban player " .. userdata.Player:Name() .. " (" .. userdata.SteamID .. "). Error: " .. data .. "\n")
			else
				MsgC(Color(255, 0, 0, 255), "[UAC] ")
				MsgC(Color(255, 255, 255, 255), "Unable to unban player " .. userdata.Player:Name() .. " (" .. userdata.SteamID .. "). Error: " .. data .. "\n")
			end

			return
		end

		if IsValid(userdata.Admin) then
			userdata.Admin:ChatText(Color(255, 0, 0, 255), "[UAC] ", Color(255, 255, 255, 255), "Unable to unban player with " .. userdata.SteamID and ("SteamID " .. userdata.SteamID) or ("IP " .. userdata.IP) .. ". Error: " .. data .. "\n")
		else
			MsgC(Color(255, 0, 0, 255), "[UAC] ")
			MsgC(Color(255, 255, 255, 255), "Unable to unban player with " .. userdata.SteamID and ("SteamID " .. userdata.SteamID) or ("IP " .. userdata.IP) .. ". Error: " .. data .. "\n")
		end

		-- Warn
		return
	end

	if IsValid(userdata.Player) then
		userdata.Player:GetUACTable().LastBanUpdate = CurTime()
		userdata.Player:GetUACTable().IsBanned = false

		if IsValid(userdata.Admin) then
			userdata.Admin:ChatText(Color(255, 0, 0, 255), "[UAC] ", Color(255, 255, 255, 255), "Unbanned player " .. userdata.Player:Name() .. " (" .. userdata.SteamID .. ").\n")
		else
			MsgC(Color(255, 0, 0, 255), "[UAC] ")
			MsgC(Color(255, 255, 255, 255), "Unbanned player " .. userdata.Player:Name() .. " (" .. userdata.SteamID .. ").\n")
		end

		return
	end

	if IsValid(userdata.Admin) then
		userdata.Admin:ChatText(Color(255, 0, 0, 255), "[UAC] ", Color(255, 255, 255, 255), "Unbanned player with " .. userdata.SteamID and ("SteamID " .. userdata.SteamID) or ("IP " .. userdata.IP) .. ".\n")
	else
		MsgC(Color(255, 0, 0, 255), "[UAC] ")
		MsgC(Color(255, 255, 255, 255), "Unbanned player with " .. userdata.SteamID and ("SteamID " .. userdata.SteamID) or ("IP " .. userdata.IP) .. ".\n")
	end
end

local function RemoveBan(succeeded, data, userdata)
	if not succeeded then
		if IsValid(userdata.Player) then
			if IsValid(userdata.Admin) then
				userdata.Admin:ChatText(Color(255, 0, 0, 255), "[UAC] ", Color(255, 255, 255, 255), "Unable to unban player " .. userdata.Player:Name() .. " (" .. userdata.SteamID .. "). Error: " .. data .. "\n")
			else
				MsgC(Color(255, 0, 0, 255), "[UAC] ")
				MsgC(Color(255, 255, 255, 255), "Unable to unban player " .. userdata.Player:Name() .. " (" .. userdata.SteamID .. "). Error: " .. data .. "\n")
			end

			return
		end

		if IsValid(userdata.Admin) then
			userdata.Admin:ChatText(Color(255, 0, 0, 255), "[UAC] ", Color(255, 255, 255, 255), "Unable to unban player with " .. userdata.SteamID and ("SteamID " .. userdata.SteamID) or ("IP " .. userdata.IP) .. ". Error: " .. data .. "\n")
		else
			MsgC(Color(255, 0, 0, 255), "[UAC] ")
			MsgC(Color(255, 255, 255, 255), "Unable to unban player with " .. userdata.SteamID and ("SteamID " .. userdata.SteamID) or ("IP " .. userdata.IP) .. ". Error: " .. data .. "\n")
		end

		-- Warn
		return
	end

	if #data > 0 then
		uac.sql.Query(uac.string.Format(GetQuery("Unban player"), userdata.AdminSteamID, userdata.Reason, data[1].bid), VerifyUnban, userdata)
	else
		if IsValid(userdata.Player) then
			userdata.Player:GetUACTable().LastBanUpdate = CurTime()
			userdata.Player:GetUACTable().IsBanned = false

			if IsValid(userdata.Admin) then
				userdata.Admin:ChatText(Color(255, 0, 0, 255), "[UAC] ", Color(255, 255, 255, 255), "Unable to unban player " .. userdata.Player:Name() .. " (" .. userdata.SteamID .. ") because he is not banned.\n")
			else
				MsgC(Color(255, 0, 0, 255), "[UAC] ")
				MsgC(Color(255, 255, 255, 255), "Unable to unban player " .. userdata.Player:Name() .. " (" .. userdata.SteamID .. ") because he is not banned.\n")
			end

			return
		end

		if IsValid(userdata.Admin) then
			userdata.Admin:ChatText(Color(255, 0, 0, 255), "[UAC] ", Color(255, 255, 255, 255), "Unable to unban player with " .. userdata.SteamID and ("SteamID " .. userdata.SteamID) or ("IP " .. userdata.IP) .. " because he is not banned.\n")
		else
			MsgC(Color(255, 0, 0, 255), "[UAC] ")
			MsgC(Color(255, 255, 255, 255), "Unable to unban player with " .. userdata.SteamID and ("SteamID " .. userdata.SteamID) or ("IP " .. userdata.IP) .. " because he is not banned.\n")
		end

		-- Is not banned, warn
	end
end

function uac.ban.Remove(ident, reason, issuer)
	local userdata = {SteamID = ident, Reason = reason, AdminSteamID = "STEAM_ID_SERVER"}
	if IsValid(ident) then
		userdata.SteamID = ident:SteamID()
		userdata.IP = ident:IPAddress()
		userdata.Name = ident:Name()
		userdata.Player = ident
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
	end

	return uac.ban.IsBanned(ident, RemoveBan, userdata)
end

----------------------------------------------------------------

local META = FindMetaTable("Player")
if META then
	function META:Ban(minutes, reason, issuer) -- issuer added to the end to allow compatibility with vanilla GMod
		return uac.ban.Add(self, minutes, reason, issuer)
	end

	function META:Unban(reason, issuer) -- in case you want a "let banned players come in with restrictions"
		return uac.ban.Remove(self, reason, issuer)
	end

	local function UpdateStatus(succeeded, data, userdata)
		if succeeded and #data > 0 and IsValid(userdata) then
			userdata:GetUACTable().IsBanned = true
		end
	end

	function META:IsBanned() -- in case you want a "let banned players come in with restrictions"
		local plytable = self:GetUACTable()
		local curtime = CurTime() -- only update the cached value each 15 seconds if IsBanned is called frequently
		if curtime - (plytable.LastBanUpdate or 0) >= 15 then
			plytable.LastBanUpdate = curtime
			uac.ban.IsBanned(self, UpdateStatus, self)
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
		local plytable = userdata.Player:GetUACTable()
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

hook.Add("PlayerAuthed", "uac.bans.CheckPlayerStatus", function(ply, steamid, uniqueid)
	uac.ban.IsBanned(self, CheckJoiningPlayerStatus, {Player = ply, SteamID = steamid, IP = ply:IPAddress()})
end)