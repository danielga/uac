uac.player = uac.player or {}

if SERVER then
	util.AddNetworkString("uac_player_notify")
else
	net.Receive("uac_player_notify", function(len)
		-- Maximum number of seconds for notifications with this is 65535 which seems reasonable
		notification.AddLegacy(net.ReadString(), net.ReadUInt(8), net.ReadUInt(16))
	end)
end

local PLAYER = FindMetaTable("Player")

function PLAYER:FindFreeSpace(behind)
	local plypos = self:GetPos()
	local plyang = self:EyeAngles()
	local yaw =  math.floor(plyang.y / 45 + 0.5) * 45 --snap to 45 degree.

	local size = Vector(32, 32, 72)
	local StartPos = plypos + Vector(0, 0, size.z / 2) --start in the middle of the player

	--now find free space behind or infront of player.
	d = {0, 45, -45}
	for i = 1, 3 do --try 0, then 45, then -45
		local Pos
		if not behind then
			Pos = StartPos - Vector(math.cos(yaw - d[i]), math.sin(yaw - d[i])) * size * 1.5
		else
			Pos = StartPos + Vector(math.cos(yaw - d[i]), math.sin(yaw - d[i])) * size * 1.5
		end

		local tr = {}
		tr.start = Pos
		tr.endpos = Pos
		tr.mins = size / 2 * -1
		tr.maxs = size / 2

		local trace = util.TraceHull(tr)
		if not trace.Hit then
			return Pos - Vector(0, 0, size.z / 2)
		end
	end

	return nil
end

function PLAYER:IsImmune(ply)
	if not IsValid(ply) or self == ply then
		return false
	end

	return (self:IsSuperAdmin() and not ply:IsSuperAdmin()) or (self:IsAdmin() and not ply:IsAdmin())
end

if SERVER then
	function PLAYER:Notify(message, type, length)
		net.Start("uac_player_notify")
			net.WriteString(message)
			net.WriteUInt(type, 8)
			net.WriteUInt(length, 16)
		net.Send(self)
	end
end

function uac.player.GetPlayerFromSteamID(steamid)
	local plys = player.GetHumans()
	for i = 1, #plys do
		local ply = plys[i]
		if ply:SteamID() == steamid then
			return ply
		end
	end

	return NULL
end

local function ReversePlayerList(list)
	local reverse = {}
	local players = player.GetAll()
	for i = 1, #players do
		local ply = players[i]
		if not table.HasValue(list, ply) then
			table.insert(reverse, ply)
		end
	end

	return reverse
end

local function CompareStrings(target, possible)
	local targetlen = #target
	local targetdist = targetlen * 0.5

	local distance = uac.string.Levenshtein(target, possible)
	return uac.unicode.Similar(possible, target) or distance <= targetdist, distance
end

local function StringDistanceSort(a, b)
	return a:UACGetTable().__string_distance < b:UACGetTable().__string_distance
end

function uac.player.GetTargets(ply, target, ignore_immunity)
	local found = {}

	if target == nil then
		return found
	end

	target = target:Trim()
	if target == nil or target == "" then
		return found
	end

	local plys = player.GetAll()
	if target == "*" then
		return plys
	end

	local pre, reverse = string.sub(target, 1, 1), false
	if pre == "!" then
		pre, target, reverse = string.sub(target, 2, 2), string.sub(target, 2), true
	end

	local type
	if pre == "@" then
		type = "teamname"
		target = string.lower(string.sub(target, 2))

		for i = 1, #plys do
			local v = plys[i]
			local lowteam = string.lower(team.GetName(v:Team()))
			if ignore_immunity or not v:IsImmune(ply) then
				local good, distance = CompareStrings(target, lowteam)
				if good then
					v:UACGetTable().__string_distance = distance
					table.insert(found, v)
				end
			end
		end

		if reverse then
			found = ReversePlayerList(found)
		end

		table.sort(found, StringDistanceSort)

		for i = 1, #found do
			found[i]:UACGetTable().__string_distance = nil
		end
	elseif pre == "#" then
		type = "userid"

		local userid = tonumber(string.sub(target, 2))
		if userid == nil then
			return found, type
		end

		for i = 1, #plys do
			local v = plys[i]
			if v:UserID() == userid and (not ignore_immunity and not v:IsImmune(ply)) then
				table.insert(found, v)
			end
		end

		if reverse then
			found = ReversePlayerList(found)
		end
	elseif uac.string.IsSteamIDValid(target) then
		type = "steamid"

		for i = 1, #plys do
			local v = plys[i]
			if v:SteamID() == target and (not ignore_immunity and not v:IsImmune(ply)) then
				table.insert(found, v)
			end
		end

		if reverse then
			found = ReversePlayerList(found)
		end
	else
		type = "name"
		target = string.lower(target)

		for i = 1, #plys do
			local v = plys[i]
			local lownick = string.lower(v:Nick())
			if ignore_immunity or not v:IsImmune(ply) then
				local good, distance = CompareStrings(target, lownick)
				if good then
					v:UACGetTable().__string_distance = distance
					table.insert(found, v)
				end
			end
		end

		if reverse then
			found = ReversePlayerList(found)
		end

		table.sort(found, StringDistanceSort)

		for i = 1, #found do
			found[i]:UACGetTable().__string_distance = nil
		end
	end

	return found, type
end
