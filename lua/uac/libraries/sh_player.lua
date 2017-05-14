uac.player = uac.player or {}

local ENTITY = FindMetaTable("Entity")
local PLAYER = FindMetaTable("Player")

if SERVER then
	util.AddNetworkString("uac_player_notify")

	function ENTITY:Notify(message, type, length)
	end

	function PLAYER:Notify(message, type, length)
		net.Start("uac_player_notify")
		net.WriteString(message)
		net.WriteUInt(type, 8)
		net.WriteUInt(length, 16)
		net.Send(self)
	end
else
	net.Receive("uac_player_notify", function(len)
		-- Maximum number of seconds for notifications with this is 65535 which seems reasonable
		notification.AddLegacy(net.ReadString(), net.ReadUInt(8), net.ReadUInt(16))
	end)

	function ENTITY:Notify(message, type, length)
	end

	function ENTITY:IsListenServerHost()
		return false
	end

	function PLAYER:Notify(message, type, length)
		if self == LocalPlayer() then
			notification.AddLegacy(message, type, length)
		end
	end

	function PLAYER:IsListenServerHost()
		return not uac.misc.IsDedicatedServer() and self:EntIndex() == 1
	end
end

function ENTITY:IsGameHost()
	return self == NULL
end

function ENTITY:FindFreeSpace(behind)
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
end

function PLAYER:IsGameHost()
	return game.SinglePlayer() or self:IsListenServerHost()
end

function uac.player.GetPlayerFromSteamID(steamid)
	local plys = player.GetAll()
	for i = 1, #plys do
		local ply = plys[i]
		if ply:SteamID() == steamid or ply:SteamID64() == steamid then
			return ply
		end
	end
end

local function PlayerListComplement(set, subset)
	local complement = {}
	for i = 1, #set do
		local ply = set[i]
		if not table.HasValue(subset, ply) then
			table.insert(complement, ply)
		end
	end

	return complement
end

local function CompareStrings(target, possible)
	local targetdist = #target * 0.5

	local distance = uac.string.Levenshtein(target, possible)
	return uac.unicode.Similar(possible, target) or distance <= targetdist, distance
end

local function StringDistanceSort(a, b)
	return a:GetUACTable().__string_distance < b:GetUACTable().__string_distance
end

function uac.player.GetTargets(executor, target, ignore_immunity, every_match)
	local found = {}

	if target == nil or #target == 0 then
		return found
	end

	target = string.Trim(target)
	if #target == 0 then
		return found
	end

	local plys = player.GetAll()
	if target == "*" then
		return plys
	end

	local pre, complement = string.sub(target, 1, 1), false
	if pre == "!" then
		pre, target, complement = string.sub(target, 2, 2), string.sub(target, 2), true
	end

	local sort = false
	local type
	if target == "@this" and IsValid(executor) then
		type = "this"

		local entity = executor:GetEyeTrace().Entity
		if IsValid(entity) and entity:IsPlayer() and entity:IsImmune(executor) then
			table.insert(found, entity)
		end
	elseif target == "@me" then
		type = "me"
		table.insert(found, executor)
	elseif target == "@all" then
		type = "all"

		if not ignore_immunity then
			for i = 1, #plys do
				local ply = plys[i]
				if not ply:IsImmune(executor) then
					table.insert(found, ply)
				end
			end
		end
	elseif target == "@random" then
		type = "random"

		if not ignore_immunity then
			for i = 1, #plys do
				local ply = plys[i]
				if not ply:IsImmune(executor) then
					table.insert(found, ply)
				end
			end
		end

		if #plys ~= 0 then
			found = {found[math.random(#found)]}
		end
	elseif pre == "@" then
		type = "teamname"
		target = string.lower(string.sub(target, 2))

		for i = 1, #plys do
			local ply = plys[i]
			if ignore_immunity or not ply:IsImmune(executor) then
				local teamname = string.lower(team.GetName(ply:Team()))
				local good, distance = CompareStrings(target, teamname)
				if good then
					ply:GetUACTable().__string_distance = distance
					table.insert(found, ply)
				end
			end
		end

		sort = true
	else
		local ply = player.GetByUniqueID(target)
		local userid = tonumber(target)

		if ply and ply:IsPlayer() then
			type = "uniqueid"
			table.insert(found, ply)
		elseif userid then
			type = "userid"

			for i = 1, #plys do
				local ply = plys[i]
				if (ignore_immunity or not ply:IsImmune(executor)) and ply:UserID() == userid then
					table.insert(found, ply)
				end
			end
		elseif uac.string.IsSteamIDValid(target) then
			type = "steamid"

			for i = 1, #plys do
				local ply = plys[i]
				if (ignore_immunity or not ply:IsImmune(executor)) and ply:SteamID() == target then
					table.insert(found, ply)

					if not every_match then
						break
					end
				end
			end
		elseif uac.string.IsSteamID64Valid(target) then
			type = "steamid64"

			for i = 1, #plys do
				local ply = plys[i]
				if (ignore_immunity or not ply:IsImmune(executor)) and ply:SteamID64() == target then
					table.insert(found, ply)

					if not every_match then
						break
					end
				end
			end
		elseif SERVER and uac.string.IsIPValid(target) then
			type = "ip"

			for i = 1, #plys do
				local ply = plys[i]
				if (ignore_immunity or not ply:IsImmune(executor)) and string.find(ply:IPAddress(), "^" .. target) then
					table.insert(found, ply)

					if not every_match then
						break
					end
				end
			end
		else
			type = "name"
			target = string.lower(target)

			for i = 1, #plys do
				local ply = plys[i]
				if ignore_immunity or not ply:IsImmune(executor) then
					local nick = string.lower(ply:Nick())
					local good, distance = CompareStrings(target, nick)
					if good then
						ply:GetUACTable().__string_distance = distance
						table.insert(found, ply)
					end
				end
			end

			sort = true
		end
	end

	if complement then
		found = PlayerListComplement(plys, found)
	end

	if sort then
		table.sort(found, StringDistanceSort)

		for i = 1, #found do
			found[i]:GetUACTable().__string_distance = nil
		end

		if not every_match and #found > 1 then
			found = {found[1]}
		end
	end

	return found, type
end
