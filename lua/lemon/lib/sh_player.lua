lemon.player = lemon.player or {}

if SERVER then
	util.AddNetworkString("lemon_player_ServerAnswer")

	hook.Add("PlayerAuthed", "lemon.player.PlayerAuthed", function(ply, steamid, uniqueid)
		net.Start("lemon_player_ServerAnswer")
			net.WriteBit(true)
		net.Send(ply)
	end)
else
	net.Receive("lemon_player_ServerAnswer", function(msg)
		lemon.ServerHasLemon = net.ReadBit() == 1
	end)
end

local META = FindMetaTable("Player")
if META then
	function META:GetLemonTable()
		if not self.lemon then self.lemon = {} end
		return self.lemon
	end

	function META:IsImmune(ply)
		return lemon.player:IsImmune(self, ply)
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

function lemon.player:IsImmune(tar, ply)
	return not (tar == ply) or (tar:IsSuperAdmin() and not ply:IsSuperAdmin()) or (tar:IsAdmin() and not ply:IsAdmin())
end

function lemon.player:GetTargets(ply, target, ignore_immunity)
	if not target then return {} end

	target = target:gsub("^%s*(.-)%s*$", "%1")

	if not target or target == "" then
		return {}
	end

	target = target:lower()

	local found = {}
	local plys = player.GetAll()
	local pre = target:sub(1, 1)
	if pre == "@" then
		target = target:sub(2)

		if target == "all" then
			found = plys
		else
			for i = 1, #plys do
				local v = plys[i]
				if team.GetName(v:Team()):lower():find(target) and (not ignore_immunity and v:IsImmune(ply)) then
					table.insert(found, v)
				end
			end
		end
	elseif pre == "#" then
		target = target:sub(2)

		local userid = tonumber(target)
		if userid == nil then return {} end

		for i = 1, #plys do
			local v = plys[i]
			if v:UserID() == userid and (not ignore_immunity and v:IsImmune(ply)) then
				table.insert(found, v)
			end
		end
	else
		for i = 1, #plys do
			local v = plys[i]
			if (v:Nick():lower():find(target) or v:SteamID():lower():find(target)) and (not ignore_immunity and v:IsImmune(ply)) then
				table.insert(found, v)
			end
		end
	end

	return found
end