local PLUGIN = lemon.plugin:New()

PLUGIN.Name = "Player control"
PLUGIN.Description = "Adds commands to control players."
PLUGIN.Author = "Agent 47, DrogenViech"

function PLUGIN:KickPlayer(ply, command, args)
	local targets = lemon.player:GetTargets(ply, args[1], false)
	local reason = table.concat(args, " ", 2) or ""
	reason = reason:gsub("[;,:.\\/]", "_")

	for i = 1, #targets do
		targets[i]:Kick(reason)
	end
end
PLUGIN:AddCommand("kick", PLUGIN.KickPlayer, ACCESS_KICK, "Kicks the specified user with optional reason", "<Player name | SteamID | #UserID | @Team name> [Reason]")

function PLUGIN:Ban(ply, command, args)
	local targets = lemon.player:GetTargets(ply, args[1], false)
	local time = tonumber(args[2]) or 5
	local reason = args[3] and table.concat(args, " ", 3) or "Banned for " .. time .. " minutes."
	reason = reason:gsub("[;,:.\\/]", "_")
	
	if #targets > 0 then
		for i = 1, #targets do
			local p = targets[i]
			p:Ban(time, reason)
			p:Kick(reason)
		end
	elseif args[1]:sub(1, 6) == "STEAM_" then
		lemon.ban:Add(args[1], time, reason)
	end
end
PLUGIN:AddCommand("ban", PLUGIN.Ban, ACCESS_BAN, "Bans the specified user with optional reason", "<Player name | SteamID | #UserID | @Team name> [Time] [Reason]")

function PLUGIN:Unban(ply, command, args)
	lemon.ban:Remove(args[1])
end
PLUGIN:AddCommand("unban", PLUGIN.Unban, ACCESS_BAN, "Removes a ban from the database", "<Player name | SteamID | #UserID | @Team name> [Reason]")

--------------------------------------------------

function PLUGIN:TrainFuck(ply, command, args)
	local targets = lemon.player:GetTargets(ply, args[1], false)
	
	for i = 1, #targets do
		local ply = targets[i]
		ply:SetMoveType(MOVETYPE_WALK)
		local train = ents.Create("lemon_train")
		train:SetPos(ply:GetPos() + Vector(0, 0, 100) + ply:GetForward() * 1000)
		local vec = ply:GetPos() + Vector(0, 0, 100) - train:GetPos()
		vec:Normalize()
		train:SetAngles(vec:Angle() - Angle(0, 90, 0))
		train:SetOwner(ply)
		train:Spawn()
		train:Activate()

		train:SetHitCallback(function(train, ply)
			if not IsValid(ply) then return end

			local vec = ply:GetPos() - train:GetPos() + Vector(0, 0, 400)
			vec:Normalize()
			ply:SetLocalVelocity(vec * 2000)
			ply:Kill()
		end)
	end
end
PLUGIN:AddCommand("trainfuck", PLUGIN.TrainFuck, ACCESS_SLAY, "Slays a player in a awesome way", "<Player name | SteamID | #UserID | @Team name>")

function PLUGIN:TrainBan(ply, command, args)
	local targets = lemon.player:GetTargets(ply, args[1], false)
	local time = tonumber(args[2]) or 5
	local reason = args[3] and table.concat(args, " ", 3) or "Banned for " .. time .. " minutes."
	reason = reason:gsub("[;,:.\\/]", "_")
	
	for i = 1, #targets do
		local ply = targets[i]
		ply:SetMoveType(MOVETYPE_WALK)
		local train = ents.Create("lemon_train")
		train:SetPos(ply:GetPos() + Vector(0, 0, 100) + ply:GetForward() * 1000)
		train:SetAngles((ply:GetPos() + Vector(0, 0, 100) - train:GetPos()):Normalize():Angle() - Angle(0, 90, 0))
		train:SetOwner(ply)
		train:Spawn()
		train:Activate()

		train:SetHitCallback(function(train, ply)
			if IsValid(ply) then
				ply:Ban(time, reason)
				ply:Kick(reason)
			end
		end)

		local steamid = ply:SteamID()
		train:SetEndCallback(function(train, ply, success)
			if success then return end
			lemon.ban:Add(steamid, time, reason)
		end)
	end
end
PLUGIN:AddCommand("trainban", PLUGIN.TrainBan, ACCESS_BAN, "Bans a player in a awesome way", "<Player name | SteamID | #UserID | @Team name> [Time] [Reason]")

function PLUGIN:TrainKick(ply, command, args)
	local targets = lemon.player:GetTargets(ply, args[1], false)
	local reason = table.concat(args, " ", 2) or ""
	reason = reason:gsub("[;,:.\\/]", "_")
	
	for i = 1, #targets do
		local ply = targets[i]
		ply:SetMoveType(MOVETYPE_WALK)
		local train = ents.Create("lemon_train")
		train:SetPos(ply:GetPos() + Vector(0, 0, 100) + ply:GetForward() * 1000)
		train:SetAngles((ply:GetPos() + Vector(0, 0, 100) - train:GetPos()):Normalize():Angle() - Angle(0, 90, 0))
		train:SetOwner(ply)
		train:Spawn()
		train:Activate()

		train:SetHitCallback(function(train, ply)
			if not IsValid(ply) then return end
			ply:Kick(reason)
		end)
	end
end
PLUGIN:AddCommand("trainkick", PLUGIN.TrainKick, ACCESS_KICK, "Kicks a player in a awesome way", "<Player name | SteamID | #UserID | @Team name> [Reason]")

--------------------------------------------------

function PLUGIN:Crash(ply, command, args)
	local targets = lemon.player:GetTargets(ply, args[1], false)
	
	for i = 1, #targets do
		targets[i]:Remove()
	end
end
PLUGIN:AddCommand("crash", PLUGIN.Crash, ACCESS_RCON, "Crashes a player", "<Player name | SteamID | #UserID | @Team name>")

function PLUGIN:EnterVehicle(ply, command, args)
	local targets = lemon.player:GetTargets(ply, args[1], false)
	local vehicle = ply:GetEyeTrace().Entity
	if IsValid(targets[1]) then
		targets = targets[1]
	else
		return
	end
	
	if targets:Alive() then
		if IsValid(vehicle) and vehicle:IsVehicle() then
			if IsValid(vehicle:GetDriver()) then vehicle:GetDriver():ExitVehicle() end
			targets:EnterVehicle(vehicle)
		end
	end
end
PLUGIN:AddCommand("enter", PLUGIN.EnterVehicle, ACCESS_SLAY, "Forces a user to enter the vehicle you're looking at", "<Player name | SteamID | #UserID | @Team name>")

function PLUGIN:ExitVehicle(ply, command, args)
	local targets = lemon.player:GetTargets(ply, args[1], false)

	for i = 1, #targets do
		local p = targets[i]
		if p:InVehicle() then
			p:ExitVehicle()
		end
	end
end
PLUGIN:AddCommand("exit", PLUGIN.ExitVehicle, ACCESS_SLAY, "Forces the specified user to exit the vehicle he's in", "<Player name | SteamID | #UserID | @Team name>")

function PLUGIN:Cexec(ply, command, args)
	local targets = lemon.player:GetTargets(ply, args[1], false)
	local execute = table.concat(args, " ", 2)
	
	for i = 1, #targets do
		targets[i]:ConCommand(execute)
	end
end
PLUGIN:AddCommand("cexec", PLUGIN.Cexec, ACCESS_RCON, "Execute command on a user", "<Player name | SteamID | #UserID | @Team name> <Command(s)>")

function PLUGIN:RespawnPlayer(ply, command, args)
	local targets = lemon.player:GetTargets(ply, args[1], false)
	
	for i = 1, #targets do
		local p = targets[i]
		local pos = p:GetPos()
		local ang = p:EyeAngles()
		p:Spawn()
		p:SetPos(pos)
		p:SetEyeAngles(ang)
	end
end
PLUGIN:AddCommand("respawn", PLUGIN.RespawnPlayer, ACCESS_SLAY, "Respawns a user", "<Player name | SteamID | #UserID | @Team name>")

function PLUGIN:SpawnPlayer(ply, command, args)
	local targets = lemon.player:GetTargets(ply, args[1], false)
	
	for i = 1, #targets do
		targets[i]:Spawn()
	end
end
PLUGIN:AddCommand("spawn", PLUGIN.SpawnPlayer, ACCESS_SLAY, "Spawns a user", "<Player name | SteamID | #UserID | @Team name>")

function PLUGIN:SetHealth(ply, command, args)
	local targets = lemon.player:GetTargets(ply, args[1], false)
	local health = tonumber(args[2]) or 1
	health = math.floor(math.Clamp(health, 1, 2147483647))
	
	for i = 1, #targets do
		local p = targets[i]
		if p:Alive() then
			p:SetHealth(health)
		end
	end
end
PLUGIN:AddCommand("hp", PLUGIN.SetHealth, ACCESS_SLAY, "Sets a users health", "<Player name | SteamID | #UserID | @Team name> <Health ammount>")

function PLUGIN:EnableGod(ply, command, args)
	local targets = lemon.player:GetTargets(ply, args[1], false)

	for i = 1, #targets do
		local p = targets[i]
		if p:Alive() then
			p:GodEnable()
			p:GetLemonTable().GodMode = true
		end
	end
end
PLUGIN:AddCommand("god", PLUGIN.EnableGod, ACCESS_SLAY, "Enables godmode for a user", "<Player name | SteamID | #UserID | @Team name>")

function PLUGIN:DisableGod(ply, command, args)
	local targets = lemon.player:GetTargets(ply, args[1], false)

	for i = 1, #targets do
		local p = targets[i]
		if p:Alive() then
			p:GodDisable()
			p:GetLemonTable().GodMode = false
		end
	end
end
PLUGIN:AddCommand("ungod", PLUGIN.DisableGod, ACCESS_SLAY, "Disables godmode for a user", "<Player name | SteamID | #UserID | @Team name>")

function PLUGIN:Slay(ply, command, args)
	local targets = lemon.player:GetTargets(ply, args[1], false)

	for i = 1, #targets do
		local p = targets[i]
		if p:InVehicle() then
			p:ExitVehicle()
		end

		p:Kill()
	end
end
PLUGIN:AddCommand("slay", PLUGIN.Slay, ACCESS_SLAY, "Kills a user", "<Player name | SteamID | #UserID | @Team name>")

function PLUGIN:SilentSlay(ply, command, args)
	local targets = lemon.player:GetTargets(ply, args[1], false)
	
	for i = 1, #targets do
		local p = targets[i]
		if p:InVehicle() then
			p:ExitVehicle()
		end

		p:KillSilent()
	end
end
PLUGIN:AddCommand("sslay", PLUGIN.SilentSlay, ACCESS_SLAY, "Silently kills a user (no killicon and sound)", "<Player name | SteamID | #UserID | @Team name>")

function PLUGIN:GiveWeapon(ply, command, args)
	local targets = lemon.player:GetTargets(ply, args[1], false)
	local wep = args[2]
	
	for i = 1, #targets do
		local p = targets[i]
		if p:Alive() then
			p:Give(wep)
		end
	end
end
PLUGIN:AddCommand("give", PLUGIN.GiveWeapon, ACCESS_SLAY, "Gives the specified item to a user", "<Player name | SteamID | #UserID | @Team name> <Weapon name>")

function PLUGIN:StripWeapons(ply, command, args)
	local targets = lemon.player:GetTargets(ply, args[1], false)
	
	for i = 1, #targets do
		local p = targets[i]
		if p:Alive() then
			p:StripWeapons()
		end
	end
end
PLUGIN:AddCommand("strip", PLUGIN.StripWeapons, ACCESS_SLAY, "Removes a users weapons", "<Player name | SteamID | #UserID | @Team name>")

function PLUGIN:FindFreeSpace(ply, behind)
	local plypos = ply:GetPos()
	local plyang = ply:EyeAngles()	
	local yaw =  math.floor(plyang.y / 45 + 0.5) * 45 --snap to 45 degree.
	
	local size = Vector(32, 32, 72)
	local StartPos = plypos + Vector(0, 0, size.z / 2) --start in the middle of the player
	
	--now find free space behind or infront of player.
	d = {0, 45, -45}
	for i = 1, 3 do --try -45, then 0, then 45
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

function PLUGIN:TeleTo(ply, command, args)
	local target = lemon.player:GetTargets(ply, args[1], false)
	if IsValid(target[1]) then
		target = target[1]
	else
		return
	end
	
	local pos = self:FindFreeSpace(target, true)
	if pos then
		ply:SetPos(pos)
		ply:SetAngles((target:EyePos() - ply:GetShootPos()):Angle())
	end
end
PLUGIN:AddCommand("tp", PLUGIN.TeleTo, ACCESS_SLAY, "Teleports yourself to the specified user", "<Player name | SteamID | #UserID | @Team name>")
PLUGIN:AddCommand("goto", PLUGIN.TeleTo, ACCESS_SLAY, "Teleports yourself to the specified user", "<Player name | SteamID | #UserID | @Team name>")

function PLUGIN:Bring(ply, command, args)
	local target = lemon.player:GetTargets(ply, args[1], false)
	if IsValid(target[1]) then
		target = target[1]
	else
		return
	end
	
	if ply:Alive() then
		if ply:InVehicle() then
			ply:ExitVehicle()
		end
		
		local pos = self:FindFreeSpace(ply, false)
		if pos then
			target:SetPos(pos)
			target:SetAngles((ply:EyePos() - target:GetShootPos()):Angle())
		end
	end
end
PLUGIN:AddCommand("bring", PLUGIN.Bring, ACCESS_SLAY, "Bring the specified user to yourself", "<Player name | SteamID | #UserID | @Team name>")

function PLUGIN:NoclipPlayer(ply, command, args)
	if args[1] then
		local targets = lemon.player:GetTargets(ply, args[1], false)

		for i = 1, #targets do
			local p = targets[i]
			if p:GetMoveType() == MOVETYPE_NOCLIP then
				p:SetMoveType(MOVETYPE_WALK)
			else
				p:SetMoveType(MOVETYPE_NOCLIP)
			end
		end
	else
		if ply:GetMoveType() == MOVETYPE_NOCLIP then
			ply:SetMoveType(MOVETYPE_WALK)
		else
			ply:SetMoveType(MOVETYPE_NOCLIP)
		end
	end
end
PLUGIN:AddCommand("noclip", PLUGIN.NoclipPlayer, ACCESS_SLAY, "Toggles noclip for a user/yourself", "[Player name | SteamID | #UserID | @Team name]")

function PLUGIN:EntityTakeDamage(victim, dmginfo)
	if victim:IsPlayer() and victim:GetLemonTable().GodMode then
		dmginfo:SetDamage(0)
	end
end
PLUGIN:AddHook("EntityTakeDamage", "Lemon player control plugin (cancel damage on godded players)", PLUGIN.EntityTakeDamage)

function PLUGIN:PhysgunPickup(ply, ent)
	if ent:IsPlayer() and not ent:GetLemonTable().PhysgunPickup and ply:IsAdmin() then
		ent:GetLemonTable().OldMoveType = ent:GetMoveType()
		ent:SetMoveType(MOVETYPE_NONE)
		ent:SetOwner(ply)
		ent:GetLemonTable().PhysgunPickup = true
		return true
	end
end
PLUGIN:AddHook("PhysgunPickup", "Lemon player control plugin (physgun players)", PLUGIN.PhysgunPickup)

function PLUGIN:PhysgunDrop(ply, ent)
	if ent:IsPlayer() and ent:GetLemonTable().PhysgunPickup and ply:IsAdmin() then
		ent:GetLemonTable().PhysgunPickup = false
		ent:SetMoveType(ent:GetLemonTable().OldMoveType)
		ent:SetOwner()
		ent:GetLemonTable().OldMoveType = nil
	end
end
PLUGIN:AddHook("PhysgunDrop", "Lemon player control plugin (physgun players)", PLUGIN.PhysgunDrop)

function PLUGIN:PlayerNoclip(ply)
	if ply:GetLemonTable().PhysgunPickup then return false end
end
PLUGIN:AddHook("PlayerNoclip", "Lemon player control plugin (physgun players)", PLUGIN.PlayerNoclip)
--[[
local function GetAverage(tbl)
	local size = #tbl
	if size == 1 then return tbl[1] end

	local average = vector_origin
	
	for i = 1, size do
		average = average + tbl[i]
	end
	
	return average / size
end

local function CalcVelocity(self, pos)
	self._pos_velocity = self._pos_velocity or {}
	
	if #self._pos_velocity > 10 then
		table.remove(self._pos_velocity, 1)
	end
	
	table.insert(self._pos_velocity, pos)
	
	return GetAverage(self._pos_velocity)
end

function PLUGIN:Move(ply, data)
	if ply:GetLemonTable().PhysgunPickup then
		data:SetVelocity((data:GetOrigin() - CalcVelocity(ply, data:GetOrigin())) * 8)
	end
end
PLUGIN:AddHook("Move", "Lemon player control plugin (accelerating bunny hopping)", PLUGIN.Move)
]]

lemon.plugin:Register(PLUGIN)