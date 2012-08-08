if CLIENT then return end

require("mysqloo")

local mysqloo, tonumber, tobool, timer, Msg, error, pairs, table, os, GetConVarString, GetConVarNumber, math, player = mysqloo, tonumber, tobool, timer, Msg, error, pairs, table, os, GetConVarString, GetConVarNumber, math, player

module("sourcebans")

--Config table
local config = {
	hostname = "server6.lithiumhosting.com",
	hostport = 3306,
	username = "yoybtbvy_servers",
	password = "SuiL~i;P-AfO",
	database = "yoybtbvy_gameservers",
	dbprefix = "sb",
	website  = "triorigaming.info/sourcebans",
	dogroups = true,
	showbanreason = false,
	usegatekeeper = false
}

--Sourcebans sends the commands sm_rehash and sm_psay to the server, as well as kickid and others created by Source (therefore not interesting for us)
--Create such functions (sm_rehash and sm_psay)
--sm_rehash requires no arguments, sm_psay "playername" "message"

local formatex_pattern = "{(%d+)}"
local function FormatEx(text, ...)
    local matched = {}
    local substitutes = {...}

    for match in text:gmatch(formatex_pattern) do
        local match_number = tonumber(match)
        if match_number and not matched[match_number] then
            if not substitutes[match_number] then
                error(("No substitute found for {%i}."):format(match_number))
            end

            matched[match_number] = true
            text = text:gsub(("{%i}"):format(match_number), substitutes[match_number])
        end
    end

    return text
end

--Queries templates

--Can't rely on checking the ban type anymore. The older SourceBans module didn't care about that.
--And so we get SteamID bans for IP addresses. However, I'm still going to do bans the right way (as per SourceBans SourceMod plugin).
--["Check player is banned"] = "SELECT bid AS BanID FROM {1}_bans WHERE ((type = 0 AND authid = '{2}') OR (type = 1 AND ip = '{3}')) AND (length = 0 OR ends > UNIX_TIMESTAMP()) AND RemoveType IS NULL",
--["Check player is banned by SteamID"] = "SELECT bid AS BanID FROM {1}_bans WHERE (type = 0 AND authid = '{2}') AND (length = 0 OR ends > UNIX_TIMESTAMP()) AND RemoveType IS NULL",
--["Check player is banned by IP"] = "SELECT bid AS BanID FROM {1}_bans WHERE (type = 1 AND ip = '{2}') AND (length = 0 OR ends > UNIX_TIMESTAMP()) AND RemoveType IS NULL",

local queries = {
	["Check player is banned"] = "SELECT bid AS BanID FROM {1}_bans WHERE (authid = '{2}' OR ip = '{3}') AND (length = 0 OR ends > UNIX_TIMESTAMP()) AND RemoveType IS NULL",
	["Check player is banned by SteamID"] = "SELECT bid AS BanID FROM {1}_bans WHERE authid = '{2}' AND (length = 0 OR ends > UNIX_TIMESTAMP()) AND RemoveType IS NULL",
	["Check player is banned by IP"] = "SELECT bid AS BanID FROM {1}_bans WHERE ip = '{2}' AND (length = 0 OR ends > UNIX_TIMESTAMP()) AND RemoveType IS NULL",

	["Get all active bans"] = "SELECT bid AS BanID, type AS BanType, ip AS IPAddress, authid AS SteamID, name AS Name, created AS BanStart, ends AS BanEnd, length AS BanLength, reason AS BanReason, aid AS AdminID, adminIp as AdminIP FROM {1}_bans b WHERE (length = 0 OR ends > UNIX_TIMESTAMP()) AND RemoveType IS NULL",
	["Get all bans"] = "SELECT bid AS BanID, type AS BanType, ip AS IPAddress, authid AS SteamID, name AS Name, created AS BanStart, ends AS BanEnd, length AS BanLength, reason AS BanReason, aid AS AdminID, adminIp as AdminIP, RemovedBy AS UnbannedByID, RemoveType AS UnbanType, RemovedOn AS UnbannedOn, ureason AS UnbanReason FROM {1}_bans b",

	["Get all admins"] = "SELECT aid AS AdminID, user AS Name, authid AS SteamID, srv_group AS UserGroup, srv_flags AS Flags, immunity AS Immunity FROM {1}_admins",
	["Get server admins"] = "SELECT a.aid AS AdminID, a.user AS Name, a.authid AS SteamID, a.srv_group AS UserGroup, a.srv_flags AS Flags, a.immunity AS Immunity FROM {1}_admins a, {1}_admins_servers_groups g WHERE g.server_id = IFNULL((SELECT sid FROM {1}_servers WHERE ip = '{2}' AND port = {3} LIMIT 0, 1), -1) AND g.admin_id = a.aid",
	["Get all usergroups"] = "SELECT id AS GroupID, name AS Name, groups_immune AS ImmuneToGroups, flags AS Flags, immunity AS Immunity FROM {1}_srvgroups",

	["Log join attempt"] = "INSERT INTO {1}_banlog (sid, time, name, bid) VALUES(IFNULL((SELECT sid FROM {1}_servers WHERE ip = '{2}' AND port = {3} LIMIT 0, 1), -1), {4}, '{5}', {6})",

	["Ban player by IP"] = "INSERT INTO {1}_bans (type, ip, name, created, ends, length, reason, aid, adminIp, sid, country) VALUES (1, '{2}', '{3}', UNIX_TIMESTAMP(), UNIX_TIMESTAMP() + {4}, {4}, '{5}', IFNULL((SELECT aid FROM {1}_admins WHERE authid = '{6}'), 0), '{7}', IFNULL((SELECT sid FROM {1}_servers WHERE ip = '{8}' AND port = {9} LIMIT 0, 1), -1), ' ')",

	["Ban player by SteamID"] = "INSERT INTO {1}_bans (type, authid, name, created, ends, length, reason, aid, adminIp, sid, country) VALUES (0, '{2}', '{3}', UNIX_TIMESTAMP(), UNIX_TIMESTAMP() + {4}, {4}, '{5}', IFNULL((SELECT aid FROM {1}_admins WHERE authid = '{6}'), 0), '{7}', IFNULL((SELECT sid FROM {1}_servers WHERE ip = '{8}' AND port = {9} LIMIT 0, 1), -1), ' ')",

	["Unban player"] = "UPDATE {1}_bans SET RemovedBy = IFNULL((SELECT aid FROM {1}_admins WHERE authid = '{2}'), 0), RemoveType = 'U', RemovedOn = UNIX_TIMESTAMP(), ureason = '{3}' WHERE bid = {4}",

	["Modify ban"] = "UPDATE {1}_bans SET ends = created + {2}, length = {2}, reason = '{3}' WHERE bid = {4}"
}

--Database connection object
local databasecon

--Admin list sorted by SteamIDs
local admins

--Admin list sorted by AdminIDs
local adminsByID

--User groups sorted by name
local userGroups

--Obtain IP address from server - http://www.facepunch.com/showpost.php?p=23402305&postcount=1382
local serverport = GetConVarNumber("hostport")
local serverip
do
	local function band(x, y)
		local z, i, j = 0, 1
		for j = 0, 31 do
			if x % 2 == 1 and y % 2 == 1 then
				z = z + i
			end
			x = math.floor(x / 2)
			y = math.floor(y / 2)
			i = i * 2
		end

		return z
	end

	local hostip = GetConVarString("hostip")
	if hostip and hostip ~= "" then
		hostip = tonumber(("%u"):format(hostip))
		serverip = ("%u.%u.%u.%u"):format(band(hostip / 2 ^ 24, 0xFF), band(hostip / 2 ^ 16, 0xFF), band(hostip / 2 ^ 8, 0xFF), band(hostip, 0xFF))
	end
end

local function CustomError(error)
	Msg("[SourceBans][" .. os.date() .. "] " .. error .. "\n")
end

local function CustomPrint(msg)
	Msg("[SourceBans] " .. msg .. "\n")
end

--Functions that are later set up
local ConnectDatabase, ProcessPendingRequests, BanPlayerInterna, UnbanPlayerInternall, QueueRequest, GetAdminSteamID, GetAdminIPAddress, LoadAdmins
local GetDataSuccessCallback, GetDataFailureCallback
local CheckBanSuccessCallback, CheckBanFailureCallback
local BanUnbanSuccessCallback, BanUnbanFailureCallback
local LoadUserGroupsSuccessCallback, LoadUserGroupsFailureCallback
local LoadAdminsDataCallback, LoadAdminsFailureCallback
local ConnectionSuccessCallback, ConnectionFailureCallback

function GetDataSuccessCallback(query)
	local data = query:getData()
	if data then
		if query.userdata.type == "G" then
			CustomPrint("Obtained all usergroups.")
		elseif query.userdata.type == "B" then
			CustomPrint("Obtained all bans.")

			for i = 1, #data do
				local ban = data[i]
				ban.AdminSteamID = adminsByID[ban.AdminID] and adminsByID[ban.AdminID].SteamID or "STEAM_ID_SERVER"
				ban.AdminName = adminsByID[ban.AdminID] and adminsByID[ban.AdminID].Name or "CONSOLE"

				if ban.UnbannedByID then
					ban.UnbannedBySteamID = adminsByID[ban.UnbannedByID] and adminsByID[ban.UnbannedByID].SteamID or "STEAM_ID_SERVER"
					ban.UnbannedByName = adminsByID[ban.UnbannedByID] and adminsByID[ban.UnbannedByID].Name or "CONSOLE"
				end
			end
		elseif query.userdata.type == "AB" then
			CustomPrint("Obtained all active bans.")

			for i = 1, #data do
				local ban = data[i]
				ban.AdminSteamID = adminsByID[ban.AdminID] and adminsByID[ban.AdminID].SteamID or "STEAM_ID_SERVER"
				ban.AdminName = adminsByID[ban.AdminID] and adminsByID[ban.AdminID].Name or "CONSOLE"
			end
		elseif query.userdata.type == "A" then
			CustomPrint("Obtained all admins.")
		end

		query.userdata.callback(true, data)
		return
	end

	CustomError("Query was successful but no data returned?")
	query.userdata.callback(false)
end

function GetDataFailureCallback(query, errorText)
	if query.userdata.type == "G" then
		CustomError("Failed to obtain usergroups list: " .. errorText)
	elseif query.userdata.type == "B" then
		CustomError("Failed to obtain ban list: " .. errorText)
	elseif query.userdata.type == "AB" then
		CustomError("Failed to obtain active bans list: " .. errorText)
	elseif query.userdata.type == "A" then
		CustomError("Failed to obtain admins list: " .. errorText)
	end

	query.userdata.callback(false, errorText)
end

function CheckBanSuccessCallback(query)
	CustomPrint("Checking if player is banned.")

	local data = query:getData()
	if data and #data > 0 then
		if query.userdata.type == "C" then
			query.userdata.callback(true)
		elseif query.userdata.type == "B" then
			if query.userdata.steamID then
				CustomPrint("Player with SteamID " .. query.userdata.steamID .. " is being banned.")

				local newquery = databasecon:query(FormatEx(queries["Ban player by SteamID"], config.dbprefix, query.userdata.steamID, query.userdata.name, query.userdata.length, query.userdata.reason, query.userdata.adminSteamID, query.userdata.adminIP, serverip, serverport))
				newquery.userdata = query.userdata
				newquery.onSuccess = BanUnbanSuccessCallback
				newquery.onFailure = BanUnbanFailureCallback
				newquery:start()
			elseif query.userdata.ip then
				CustomPrint("Player with IP " .. query.userdata.ip .. " is being banned.")

				local newquery = databasecon:query(FormatEx(queries["Ban player by IP"], config.dbprefix, query.userdata.ip, query.userdata.name, query.userdata.length, query.userdata.reason, query.userdata.adminSteamID, query.userdata.adminIP, serverip, serverport))
				newquery.userdata = query.userdata
				newquery.onSuccess = BanUnbanSuccessCallback
				newquery.onFailure = BanUnbanFailureCallback
				newquery:start()
			end
		elseif query.userdata.type == "U" then
			if query.userdata.steamID and query.userdata.ip then
				CustomPrint("Player with SteamID " .. query.userdata.steamID .. " and IP " .. query.userdata.ip .. " is being unbanned.")
			elseif query.userdata.steamID then
				CustomPrint("Player with SteamID " .. query.userdata.steamID .. " is being unbanned.")
			elseif query.userdata.ip then
				CustomPrint("Player with IP " .. query.userdata.ip .. " is being unbanned.")
			end

			query.userdata.banID = data[1].BanID
			local newquery = databasecon:query(FormatEx(queries["Unban player"], config.dbprefix, query.userdata.adminSteamID, query.userdata.reason, data[1].BanID))
			newquery.userdata = query.userdata
			newquery.onSuccess = BanUnbanSuccessCallback
			newquery.onFailure = BanUnbanFailureCallback
			newquery:start()
		end

		return
	end

	if query.userdata.type == "C" then
		query.userdata.callback(false)
	end
end

function CheckBanFailureCallback(query, errorText)
	if query.userdata.type == "C" then
		CustomError("Player is banned check failed: " .. errorText)
		query.userdata.callback(false, errorText)
	elseif query.userdata.type == "B" then
		if query.userdata.steamID then
			CustomError("Failed to check bans for player with SteamID " .. query.userdata.steamID .. ": " .. errorText)
			QueueRequest(FormatEx(queries["Check player is banned by SteamID"], config.dbprefix, query.userdata.steamID), CheckBanSuccessCallback, nil, CheckBanFailureCallback, nil, query.userdata)
		elseif query.userdata.ip then
			CustomError("Failed to check bans for player with IP " .. query.userdata.ip .. ": " .. errorText)
			QueueRequest(FormatEx(queries["Check player is banned by IP"], config.dbprefix, query.userdata.ip), CheckBanSuccessCallback, nil, CheckBanFailureCallback, nil, query.userdata)
		end
	elseif query.userdata.type == "U" then
		if query.userdata.steamID and query.userdata.ip then
			CustomError("Failed to check bans for player with SteamID " .. query.userdata.steamID .. " and IP " .. query.userdata.ip .. ": " .. errorText)
			QueueRequest(FormatEx(queries["Check player is banned"], config.dbprefix, query.userdata.steamID, query.userdata.ip), CheckBanSuccessCallback, nil, CheckBanFailureCallback, nil, query.userdata)
		elseif query.userdata.steamID then
			CustomError("Failed to check bans for player with SteamID " .. query.userdata.steamID .. ": " .. errorText)
			QueueRequest(FormatEx(queries["Check player is banned by SteamID"], config.dbprefix, query.userdata.steamID), CheckBanSuccessCallback, nil, CheckBanFailureCallback, nil, query.userdata)
		elseif query.userdata.ip then
			CustomError("Failed to check bans for player with IP " .. query.userdata.ip .. ": " .. errorText)
			QueueRequest(FormatEx(queries["Check player is banned by IP"], config.dbprefix, query.userdata.ip), CheckBanSuccessCallback, nil, CheckBanFailureCallback, nil, query.userdata)
		end
	end
end

function BanUnbanSuccessCallback(query)
	if query.userdata.type == "B" then
		if query.userdata.steamID then
			CustomPrint("Player with SteamID " .. query.userdata.steamID .. " was banned.")
		elseif query.userdata.ip then
			CustomPrint("Player with IP " .. query.userdata.ip .. " was banned.")
		end
	elseif query.userdata.type == "U" then
		if query.userdata.steamID and query.userdata.ip then
			CustomPrint("Player with SteamID " .. query.userdata.steamID .. " and IP " .. query.userdata.ip .. " was unbanned.")
		elseif query.userdata.steamID then
			CustomPrint("Player with SteamID " .. query.userdata.steamID .. " was unbanned.")
		elseif query.userdata.ip then
			CustomPrint("Player with IP " .. query.userdata.ip .. " was unbanned.")
		end
	end
end

function BanUnbanFailureCallback(query, errorText)
	if query.userdata.type == "B" then
		if query.userdata.steamID then
			CustomError("Failed to ban player with SteamID " .. query.userdata.steamID .. ": " .. errorText)
			QueueRequest(FormatEx(queries["Ban player by SteamID"], config.dbprefix, query.userdata.steamID, query.userdata.name, query.userdata.length, query.userdata.reason, query.userdata.adminSteamID, query.userdata.adminIP, serverip, serverport), BanUnbanSuccessCallback, nil, BanUnbanFailureCallback, nil, query.userdata)
		elseif query.userdata.ip then
			CustomError("Failed to ban player with IP " .. query.userdata.ip .. ": " .. errorText)
			QueueRequest(FormatEx(queries["Ban player by IP"], config.dbprefix, query.userdata.ip, query.userdata.name, query.userdata.length, query.userdata.reason, query.userdata.adminSteamID, query.userdata.adminIP, serverip, serverport), BanUnbanSuccessCallback, nil, BanUnbanFailureCallback, nil, query.userdata)
		end
	elseif query.userdata.type == "U" then
		if query.userdata.steamID and query.userdata.ip then
			CustomError("Failed to unban player with SteamID " .. query.userdata.steamID .. " and IP " .. query.userdata.ip .. ": " .. errorText)
		elseif query.userdata.steamID then
			CustomError("Failed to unban player with SteamID " .. query.userdata.steamID .. ": " .. errorText)
		elseif query.userdata.ip then
			CustomError("Failed to unban player with IP " .. query.userdata.ip .. ": " .. errorText)
		end

		QueueRequest(FormatEx(queries["Unban player"], config.dbprefix, query.userdata.adminSteamID, query.userdata.reason, query.userdata.banID), BanUnbanSuccessCallback, nil, BanUnbanFailureCallback, nil, query.userdata)
	end
end

function LoadAdminsSuccessCallback(query)
	CustomPrint("Obtained server admins list.")
end

function LoadAdminsDataCallback(query, data)
	if data then
		data.Name = data.Name or ""
		data.UserGroup = data.UserGroup or ""
		data.Flags = data.Flags or ""

		local group = userGroups[data.UserGroup]
		if group then
			data.Flags = data.Flags .. group.Flags
			if data.Immunity < group.Immunity then
				data.Immunity = group.Immunity
			end
		end

		if string.find(data.Flags, "z") then
			data.RootFlag = true
		end

		admins[data.SteamID] = data
		adminsByID[data.AdminID] = data
	end
end

function LoadAdminsFailureCallback(query, errorText)
	CustomError("Failed to obtain server admins list: " .. errorText .. ".")
	QueueRequest(FormatEx(queries["Get server admins"], config.dbprefix, serverip, serverport), LoadAdminsSuccessCallback, LoadAdminsDataCallback, LoadAdminsFailureCallback, nil, nil)
end

function LoadUserGroupsSuccessCallback(query)
	CustomPrint("Loaded usergroups successfully.")

	local data = query:getData()
	if data then
		for i = 1, #data do
			local group = data[i]
			group.Name = group.Name or ""
			group.ImmuneToGroups = group.ImmuneToGroups or ""
			group.Flags = group.Flags or ""
			userGroups[group.Name] = group
		end
	end

	local query = databasecon:query(FormatEx(queries["Get server admins"], config.dbprefix, serverip, serverport))
	query.onSuccess = LoadAdminsSuccessCallback
	query.onData = LoadAdminsDataCallback
	query.onFailure = LoadAdminsFailureCallback
	query:start()
end

function LoadUserGroupsFailureCallback(query, errorText)
	CustomError("Failed to load usergroups: " .. errorText .. ".")
	QueueRequest(FormatEx(queries["Get all usergroups"], config.dbprefix), LoadUserGroupsSuccessCallback, nil, LoadUserGroupsFailureCallback, nil, nil)
end

function ConnectionSuccessCallback(databasecon)
	CustomPrint("Connection successfully established.")

	if not admins or not userGroups then
		LoadAdmins()
	end

	ProcessPendingRequests()
end

function ConnectionFailureCallback(databasecon, errorText)
	CustomError("Database connection failed: " .. errorText .. ".")
end
--CALLBACKS END

function QueueRequest(query, successcallback, datacallback, failurecallback, abortcallback, userdata)
	if databasecon and databasecon.pending then
		table.insert(databasecon.pending, {Query = query, SuccessCallback = successcallback, DataCallback = datacallback, FailureCallback = failurecallback, AbortCallback = abortcallback, UserData = userdata})
	end
end

function ProcessPendingRequests()
	if databasecon and databasecon.pending then
		for i = 1, #databasecon.pending do
			local query = databasecon:query(databasecon.pending[i].Query)
			query.userdata = databasecon.pending[i].UserData
			query.onSuccess = databasecon.pending[i].SuccessCallback
			query.onData = databasecon.pending[i].DataCallback
			query.onFailure = databasecon.pending[i].FailureCallback
			query.onAborted = databasecon.pending[i].AbortCallback
			query:start()

			databasecon.pending[i] = nil
		end
	end
end

function ConnectDatabase(pending)
	if databasecon then
		databasecon:abortAllQueries()
		databasecon = nil
	end

	databasecon = mysqloo.connect(config.hostname, config.username, config.password, config.database, config.hostport)
	databasecon.onConnected = ConnectionSuccessCallback
	databasecon.onConnectionFailed = ConnectionFailureCallback
	databasecon.pending = pending or {}
	databasecon:connect()
end

function GetAdminSteamID(ply)
	if ply and ply:IsValid() and ply:IsPlayer() then
		return ply:SteamID()
	end

	return "STEAM_ID_SERVER"
end

function GetAdminIPAddress(ply)
	if ply and ply:IsValid() and ply:IsPlayer() then
		return ply:IPAddress()
	end

	return serverip
end

function LoadAdmins()
	admins = {}
	adminsByID = {}

	local query = databasecon:query(FormatEx(queries["Get all usergroups"], config.dbprefix))
	query.onSuccess = LoadUserGroupsSuccessCallback
	query.onFailure = LoadUserGroupsFailureCallback
	query:start()
end

function Activate()
	ConnectDatabase()
end

function SetConfig(key, value)
	if key == "hostport" or key == "serverid" then
		config[key] = tonumber(value)
		return true
	elseif key == "showbanreason" or key == "dogroups" then
		config[key] = tobool(value)
		return true
	elseif config[key] then
		config[key] = value
		return true
	end

	return false
end

function IsSteamIDBanned(steamID, callback)
	steamID = steamID:match("(STEAM_%d:%d:%d+)")
	if not steamID or not callback then
		return false
	end

	local query = databasecon:query(FormatEx(queries["Check player is banned by SteamID"], config.dbprefix, steamID))
	query.userdata = {type = "C", callback = callback}
	query.onSuccess = CheckBanSuccessCallback
	query.onFailure = CheckBanFailureCallback
	query:start()

	return true
end

function IsIPAddressBanned(ip, callback)
	ip = ip:match("(%d+%.%d+%.%d+%.%d+)")
	if not ip or not callback then
		return false
	end

	local query = databasecon:query(FormatEx(queries["Check player is banned by IP"], config.dbprefix, ip))
	query.userdata = {type = "C", callback = callback}
	query.onSuccess = CheckBanSuccessCallback
	query.onFailure = CheckBanFailureCallback
	query:start()

	return true
end

function IsPlayerBanned(ply, callback)
	if not (ply and ply:IsValid() and ply:IsPlayer()) or not callback then
		return false
	end

	local query = databasecon:query(FormatEx(queries["Check player is banned"], config.dbprefix, ply:SteamID(), ply:IPAddress()))
	query.userdata = {type = "C", callback = callback}
	query.onSuccess = CheckBanSuccessCallback
	query.onFailure = CheckBanFailureCallback
	query:start()

	return true
end

function GetUserGroupList(callback)
	return userGroups
end

function GetAdminList()
	return admins
end

function GetBanList(callback)
	if not callback then
		return false
	end

	local query = databasecon:query(FormatEx(queries["Get all bans"], config.dbprefix))
	query.userdata = {type = "B", callback = callback}
	query.onSuccess = GetDataSuccessCallback
	query.onFailure = GetDataFailureCallback
	query:start()

	return true
end

function GetActiveBanList(callback)
	if not callback then
		return false
	end

	local query = databasecon:query(FormatEx(queries["Get all active bans"], config.dbprefix))
	query.userdata = {type = "AB", callback = callback}
	query.onSuccess = GetDataSuccessCallback
	query.onFailure = GetDataFailureCallback
	query:start()

	return true
end

function BanPlayerInternal(steamID, ip, time, reason, admin, name)
	local start = os.time()
	if steamID then
		local query = databasecon:query(FormatEx(queries["Check player is banned by SteamID"], config.dbprefix, steamID))
		query.userdata = {type = "B", name = name, steamID = steamID, length = time, reason = reason, adminSteamID = GetAdminSteamID(admin), adminIP = GetAdminIPAddress(admin)}
		query.onSuccess = CheckBanSuccessCallback
		query.onFailure = CheckBanFailureCallback
		query:start()
	elseif ip then
		local query = databasecon:query(FormatEx(queries["Check player is banned by IP"], config.dbprefix, ip))
		query.userdata = {type = "B", name = name, ip = ip, length = time, reason = reason, adminSteamID = GetAdminSteamID(admin), adminIP = GetAdminIPAddress(admin)}
		query.onSuccess = CheckBanSuccessCallback
		query.onFailure = CheckBanFailureCallback
		query:start()
	end
end

function BanPlayer(ply, time, reason, admin)
	if ply and ply:IsValid() and ply:IsPlayer() then
		BanPlayerInternal(ply:SteamID(), nil, time, reason, admin, ply:Name())
		ply:Kick()
		return true
	end

	return false
end

function BanPlayerBySteamID(steamID, time, reason, admin, name)
	steamID = steamID:match("(STEAM_%d:%d:%d+)")
	if steamID then
		BanPlayerInternal(steamID, nil, time, reason, admin, name)

		local players = player.GetAll()
		for i = 1, #players do
			if players[i]:SteamID() == steamID then
				players[i]:Kick()
			end
		end

		return true
	end

	return false
end

function BanPlayerByIP(ip, time, reason, admin, name)
	ip = ip:match("(%d+%.%d+%.%d+%.%d+)")
	if ip then
		BanPlayerInternal(nil, ip, time, reason, admin, name)

		local players = player.GetAll()
		for i = 1, #players do
			if players[i]:IPAddress() == ip then
				players[i]:Kick()
			end
		end

		return true
	end

	return false
end

function UnbanPlayerInternal(steamID, ip, reason, admin)
	local start = os.time()
	if steamID and ip then
		local query = databasecon:query(FormatEx(queries["Check player is banned"], config.dbprefix, steamID, ip))
		query.userdata = {type = "U", steamID = steamID, ip = ip, reason = reason, adminSteamID = GetAdminSteamID(admin), adminIP = GetAdminIPAddress(admin)}
		query.onSuccess = CheckBanSuccessCallback
		query.onFailure = CheckBanFailureCallback
		query:start()
	elseif steamID then
		local query = databasecon:query(FormatEx(queries["Check player is banned by SteamID"], config.dbprefix, steamID))
		query.userdata = {type = "U", steamID = steamID, reason = reason, adminSteamID = GetAdminSteamID(admin), adminIP = GetAdminIPAddress(admin)}
		query.onSuccess = CheckBanSuccessCallback
		query.onFailure = CheckBanFailureCallback
		query:start()
	elseif ip then
		local query = databasecon:query(FormatEx(queries["Check player is banned by IP"], config.dbprefix, ip))
		query.userdata = {type = "U",  ip = ip, reason = reason, adminSteamID = GetAdminSteamID(admin), adminIP = GetAdminIPAddress(admin)}
		query.onSuccess = CheckBanSuccessCallback
		query.onFailure = CheckBanFailureCallback
		query:start()
	end
end

function UnbanPlayerBySteamID(steamID, reason, admin)
	steamID = steamID:match("(STEAM_%d:%d:%d+)")
	if steamID then
		UnbanPlayerInternal(steamID, nil, reason, admin)
		return true
	end

	return false
end

function UnbanPlayerByIP(ip, reason, admin)
	ip = ip:match("(%d+%.%d+%.%d+%.%d+)")
	if ip then
		UnbanPlayerInternal(nil, ip, reason, admin)
		return true
	end

	return false
end

function UnbanPlayerBySteamIDAndIP(steamID, ip, reason, admin)
	ip = ip:match("(%d+%.%d+%.%d+%.%d+)")
	steamID = steamID:match("(STEAM_%d:%d:%d+)")
	if steamID then
		UnbanPlayerInternal(steamID, ip, reason, admin)
		return true
	end

	return false
end

function CheckStatus()
	if not databasecon then
		return
	end

	local status = databasecon:status()
	if status == mysqloo.DATABASE_CONNECTING or status == mysqloo.DATABASE_CONNECTED then
		return
	elseif status == mysqloo.DATABASE_INTERNAL_ERROR then
		CustomPrint("Internal error.")
		ConnectDatabase(databasecon.pending)
	else
		CustomPrint("Disconnected from database.")
		databasecon:connect()
	end
end
timer.Create("SourceBans module status checker", 60, 0, CheckStatus)

concommand.Add("sm_rehash", function(ply, command, args)
	if not ply or not ply:IsValid() then
		CustomPrint("Admin rehashing command received. Reloading admin list.")
		LoadAdmins()
	end
end, nil, "Reload the admin list from the MySQL database (server console only)")

concommand.Add("sm_psay", function(ply, command, args)
	if not ply or not ply:IsValid() then
		local rec_player = nil
		local receiver = args[1]
		local message = table.concat(args, " ", 2)
		local players = player.GetAll()

		local closest_len = nil
		local closest = nil
		for i = 1, #players do
			local player = players[i]
			local player_name = player:Name()
			if player_name == receiver or player:SteamID() == receiver then
				rec_player = player
				break
			elseif string.find(player_name, receiver) then
				if closest then
					local length = string.len(player_name)
					if length < closest_len then
						closest_len = length
						closest = player
					end
				else
					closest_len = string.len(player_name)
					closest = player
				end
			end
		end

		if not rec_player and closest then
			rec_player = closest
		elseif not rec_player and not closest then
			CustomPrint("Private message command received. Target '" .. receiver .. "' not found.")
			return
		end

		local rec_name = rec_player:Name()
		CustomPrint("Private message command received. Sending message to " .. rec_name .. ".")
		print("(Private: " .. rec_name .. ") CONSOLE: " .. message)
		rec_player:PrintMessage(HUD_PRINTCHAT, "(Private: " .. rec_name .. ") CONSOLE: " .. message)
	end
end, nil, "Send a private message to a player (server console only)")