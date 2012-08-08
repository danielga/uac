lemon.player = lemon.player or {}

if SERVER then
	hook.Add("PlayerInitialSpawn", "lemon_player_PlayerInitialSpawn", function(ply)
		if not ply.lemon then ply.lemon = {} end
		
		umsg.Start("lemon_ServerAnswer", ply)
			umsg.Bool(true)
		umsg.End()

		hook.Call("LemonPlayerInitialSpawn", nil, ply)
	end)

	hook.Add("PostGamemodeLoaded", "lemon_player_PostGamemodeLoaded", function(ply)
		if lemon.config:GetBool("GATEKEEPER_ENABLED") then
			local errored = pcall(require, "gatekeeper")
			if errored or !gatekeeper then
				lemon.config:SetValue("GATEKEEPER_ENABLED", false)
			end
		end
	end)

	lemon.player.KickOriginal = _R.Player.Kick
	function lemon.player:Kick(ply, reason)
		if IsValid(ply) and ply:IsPlayer() then
			if lemon.config:GetBool("GATEKEEPER_ENABLED") then
				gatekeeper.Drop(ply:UserID(), reason)
			else
				lemon.player.KickOriginal(ply, reason)
			end
		end
	end

	local META = FindMetaTable("Player")
	if META then
		function META:Kick(reason)
			lemon.player:Kick(self, reason)
		end
	end
end

function lemon.player:GetPlayerFromSteamID(steamid)
	for _, player in ipairs(player.GetAll()) do
		if player:SteamID() == steamid then
			return player
		end
	end

	return NULL
end

function lemon.player:GetImmunity(ply, tar)
	if tar == ply then
		return true
	end

	if tar:IsUserGroup("superadmin") and not ply:IsUserGroup("superadmin") then
		ply:ChatMessage(Color(255, 0, 0, 255), "[Lemon] ", Color(255, 255, 255, 255), ply:Name(), " is immune to this command.")
		return false
	end

	if tar:IsUserGroup("admin") and not tar:IsUserGroup("admin") then
		ply:ChatMessage(Color(255, 0, 0, 255), "[Lemon] ", Color(255, 255, 255, 255), ply:Name(), " is immune to this command.")
		return false
	end

	return true
end

local empty_table = {}
function lemon.player:GetTarget(ply, target, ignore_immunity)
	local found = {}

	target = string.Trim(target)

	if not target or target == "" then
		ply:ChatMessage(Color(255, 0, 0, 255), "[Lemon] ", Color(255, 255, 255, 255), "You didn't provide an identifier.")
		return empty_table
	end

	target = string.lower(target)

	if string.sub(target, 1, 1) == "@" then
		target = string.sub(target, 2)

		if target == "all" then
			found = player.GetAll()
		else
			for k, v in pairs(player.GetAll()) do
				if string.find(string.lower(team.GetName(v:Team())), target) and (not ignore_immunity and self:GetImmunity(ply, v)) then
					table.insert(found, v)
				end
			end
		end
	elseif string.sub(target, 1, 1) == "#" then
		target = string.sub(target, 2)

		for k, v in pairs(player.GetAll()) do
			if string.lower(v:UserID()) == target and (not ignore_immunity and self:GetImmunity(ply, v)) then
				table.insert(found, v)
			end
		end
	else
		for k, v in pairs(player.GetAll()) do
			if (string.find(string.lower(v:Nick()), target) or string.find(string.lower(v:SteamID()), target)) and (not ignore_immunity and self:GetImmunity(ply, v)) then
				table.insert(found, v)
			end
		end
	end

	return found
end