uac.player = uac.player or {}

if SERVER then
	util.AddNetworkString("uac_player_Notify")
else
	net.Receive("uac_player_Notify", function(len)
		-- Maximum number of seconds for notifications with this is 65535 which seems reasonable
		notification.AddLegacy(net.ReadString(), net.ReadUInt(8), net.ReadUInt(16))
	end)
end

local PLAYER = FindMetaTable("Player")

function PLAYER:GetUACTable()
	if not self.__uac then
		self.__uac = {}
	end

	return self.__uac
end

function PLAYER:IsImmune(ply)
	if not IsValid(ply) or self == ply then
		return false
	end

	return (self:IsSuperAdmin() and not ply:IsSuperAdmin()) or (self:IsAdmin() and not ply:IsAdmin())
end

if SERVER then
	function PLAYER:Notify(message, type, length)
		net.Start("uac_player_Notify")
			net.WriteString(message)
			net.WriteUInt(type, 8)
			net.WriteUInt(length, 16)
		net.Send(self)
	end
end

function uac.player.GetPlayerFromSteamID(steamid)
	local plys = player.GetHumans()
	for i = 1, #plys do
		local player = plys[i]
		if player:SteamID() == steamid then
			return player
		end
	end

	return NULL
end

local function StringDistanceSort(a, b)
	return a:GetUACTable().__string_distance < b:GetUACTable().__string_distance
end

function uac.player.GetTargets(ply, target, ignore_immunity)
	local found = {}

	if not target then
		return found
	end

	target = target:gsub("^%s*(.-)%s*$", "%1")
	if not target or target == "" then
		return found
	end

	local plys = player.GetAll()
	if target == "*" then
		return plys
	end

	local pre, reverse = target:sub(1, 1), false
	if pre == "!" then
		pre, target, reverse = target:sub(2, 2), target:sub(3), true
	else
		target = target:sub(2)
	end

	local type
	if pre == "@" then
		type = "teamname"
		target = target:lower()

		for i = 1, #plys do
			local v = plys[i]
			local lowteam = team.GetName(v:Team()):lower()
			if lowteam:find(target, nil, true) and (not ignore_immunity and not v:IsImmune(ply)) then
				v:GetUACTable().__string_distance = uac.string.Levenshtein(target, lowteam)
				table.insert(found, v)
			end
		end

		table.sort(found, StringDistanceSort)
	elseif pre == "#" then
		type = "userid"

		local userid = tonumber(target)
		if userid == nil then
			return found, type
		end

		for i = 1, #plys do
			local v = plys[i]
			if v:UserID() == userid and (not ignore_immunity and not v:IsImmune(ply)) then
				table.insert(found, v)
			end
		end
	elseif target:match("^STEAM_[0-5]:[0-9]:[0-9]+$") then
		type = "steamid"

		for i = 1, #plys do
			local v = plys[i]
			if v:SteamID() == target and (not ignore_immunity and not v:IsImmune(ply)) then
				table.insert(found, v)
			end
		end
	else
		type = "name"
		target = target:lower()

		for i = 1, #plys do
			local v = plys[i]
			local lownick = v:Nick():lower()
			if lownick:find(target, nil, true) and (not ignore_immunity and not v:IsImmune(ply)) then
				v:GetUACTable().__string_distance = uac.string.Levenshtein(target, lownick)
				table.insert(found, v)
			end
		end

		table.sort(found, StringDistanceSort)
	end

	return found, type
end