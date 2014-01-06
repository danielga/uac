lemon.player = lemon.player or {}

if SERVER then
	NOTIFY_GENERIC = 0
	NOTIFY_ERROR = 1
	NOTIFY_UNDO = 2
	NOTIFY_HINT = 3
	NOTIFY_CLEANUP = 4

	util.AddNetworkString("lemon_player_ServerAnswer")
	util.AddNetworkString("lemon_player_Notify")

	hook.Add("PlayerAuthed", "lemon.player.PlayerAuthed", function(ply, steamid, uniqueid)
		net.Start("lemon_player_ServerAnswer")
			net.WriteBit(true)
		net.Send(ply)
	end)
else
	net.Receive("lemon_player_ServerAnswer", function(len)
		lemon.ServerHasLemon = net.ReadBit() == 1
	end)

	net.Receive("lemon_player_Notify", function(len)
		-- Maximum number of seconds for notifications with this is 65535 which seems reasonable
		notification.AddLegacy(net.ReadString(), net.ReadUInt(8), net.ReadUInt(16))
	end)
end

local META = FindMetaTable("Player")
if META then
	function META:GetLemonTable()
		if not self.lemon then self.lemon = {} end
		return self.lemon
	end

	function META:IsImmune(ply)
		if not IsValid(ply) or self == ply then return false end
		return (self:IsSuperAdmin() and not ply:IsSuperAdmin()) or (self:IsAdmin() and not ply:IsAdmin())
	end

	if SERVER then
		function META:Notify(message, type, length)
			net.Start("lemon_player_Notify")
				net.WriteString(message)
				net.WriteUInt(type, 8)
				net.WriteUInt(length, 16)
			net.Send(self)
		end
	end
end

function lemon.player:GetPlayerFromSteamID(steamid)
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
	return a:GetLemonTable().__string_distance < b:GetLemonTable().__string_distance
end

function lemon.player:GetTargets(ply, target, ignore_immunity)
	local found = {}

	if not target then return found end

	target = target:gsub("^%s*(.-)%s*$", "%1")

	if not target or target == "" then return found end

	local plys = player.GetAll()
	if target == "*" then return plys end

	local pre = target:sub(1, 1)
	if pre == "@" then
		target = target:lower():sub(2)

		for i = 1, #plys do
			local v = plys[i]
			local lowteam = team.GetName(v:Team()):lower()
			if lowteam:find(target, nil, true) and (not ignore_immunity and not v:IsImmune(ply)) then
				v:GetLemonTable().__string_distance = lemon.string:Levenshtein(target, lowteam)
				table.insert(found, v)
			end
		end

		table.sort(found, StringDistanceSort)
	elseif pre == "#" then
		target = target:sub(2)

		local userid = tonumber(target)
		if userid == nil then return found end

		for i = 1, #plys do
			local v = plys[i]
			if v:UserID() == userid and (not ignore_immunity and not v:IsImmune(ply)) then
				table.insert(found, v)
			end
		end
	elseif target:match("^STEAM_[0-5]:[0-9]:[0-9]+$") then
		for i = 1, #plys do
			local v = plys[i]
			if v:SteamID() == target and (not ignore_immunity and not v:IsImmune(ply)) then
				table.insert(found, v)
			end
		end
	else
		target = target:lower()

		for i = 1, #plys do
			local v = plys[i]
			local lownick = v:Nick():lower()
			if lownick:find(target, nil, true) and (not ignore_immunity and not v:IsImmune(ply)) then
				v:GetLemonTable().__string_distance = lemon.string:Levenshtein(target, lownick)
				table.insert(found, v)
			end
		end

		table.sort(found, StringDistanceSort)
	end

	return found
end