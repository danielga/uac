PLUGIN.Name = "Player control"
PLUGIN.Description = "Adds commands to control players."
PLUGIN.Author = "Agent 47, DrogenViech"

//--------------------------------------------------

function PLUGIN:KickPlayer(ply, command, args)
	local targets = lemon.player:GetTarget(ply, args[1], false)
	local reason = table.concat(args, " ", 2) or ""
	reason = string.gsub(reason, "[;,:.\\/]", "_")

	for k, v in pairs(targets) do
		v:Kick(reason)
	end
end
PLUGIN:AddCommand("kick", PLUGIN.KickPlayer, ACCESS_KICK, "Kicks the specified user with optional reason", "<Player name | SteamID | #UserID | @Team name> [Reason]")

function PLUGIN:Ban(ply, command, args)
	local targets = lemon.player:GetTarget(ply, args[1], false)
	local time = tonumber(args[2]) or 5
	local reason = args[3] and table.concat(args, " ", 3) or "Banned for " .. time .. " minutes."
	reason = string.gsub(reason, "[;,:.\\/]", "_")
	
	if #targets > 0 then
		for _, v in pairs(targets) do
				v:Ban(time, reason)
				v:Kick(reason)
		end
	elseif string.sub(args[1], 1, 6) == "STEAM_" then
		lemon.ban:Add(args[1], time, reason)
	end
end
PLUGIN:AddCommand("ban", PLUGIN.Ban, ACCESS_BAN, "Bans the specified user with optional reason", "<Player name | SteamID | #UserID | @Team name> [Time] [Reason]")

function PLUGIN:Unban(ply, command, args)
	lemon.ban:Remove(args[1])
end
PLUGIN:AddCommand("unban", PLUGIN.Unban, ACCESS_BAN, "Removes a ban from the database", "<Player name | SteamID | #UserID | @Team name> [Reason]")

//--------------------------------------------------

function PLUGIN:TrainFuck(ply, command, args)
	local targets = lemon.player:GetTarget(ply, args[1], false)
	
	for _, ply in ipairs(targets) do
		ply:SetMoveType(MOVETYPE_WALK)
		local train = ents.Create("lemon_train")
		train:SetPos(ply:GetPos() + Vector(0, 0, 100) + ply:GetForward() * 1000)
		train:SetAngles((ply:GetPos() + Vector(0, 0, 100) - train:GetPos()):Normalize():Angle() - Angle(0, 90, 0))
		train:SetOwner(ply)
		train:Spawn()
		train:Activate()

		train:SetHitCallback(function(train, ply)
			if not ValidEntity(train) or not ValidEntity(ply) then return end

			ply:SetLocalVelocity((ply:GetPos() - train:GetPos() + Vector(0, 0, 400)):Normalize() * 2000)
			ply:Kill()
		end)
	end
end
PLUGIN:AddCommand("trainfuck", PLUGIN.TrainFuck, ACCESS_SLAY, "Slays a player in a awesome way", "<Player name | SteamID | #UserID | @Team name>")

function PLUGIN:TrainBan(ply, command, args)
	local targets = lemon.player:GetTarget(ply, args[1], false)
	local time = tonumber(args[2]) or 5
	local reason = args[3] and table.concat(args, " ", 3) or "Banned for " .. time .. " minutes."
	reason = string.gsub(reason, "[;,:.\\/]", "_")
	
	for _, ply in ipairs(targets) do
		ply:SetMoveType(MOVETYPE_WALK)
		local train = ents.Create("lemon_train")
		train:SetPos(ply:GetPos() + Vector(0, 0, 100) + ply:GetForward() * 1000)
		train:SetAngles((ply:GetPos() + Vector(0, 0, 100) - train:GetPos()):Normalize():Angle() - Angle(0, 90, 0))
		train:SetOwner(ply)
		train:Spawn()
		train:Activate()

		train:SetHitCallback(function(train, ply)
			if not ValidEntity(train) or not ValidEntity(ply) then return end

			self:AddBan(ply:SteamID(), time, reason)
			ply:Kick(reason)
		end)
	end
end
PLUGIN:AddCommand("trainban", PLUGIN.TrainBan, ACCESS_BAN, "Bans a player in a awesome way", "<Player name | SteamID | #UserID | @Team name> [Time] [Reason]")

function PLUGIN:TrainKick(ply, command, args)
	local targets = lemon.player:GetTarget(ply, args[1], false)
	local reason = table.concat(args, " ", 2) or ""
	reason = string.gsub(reason, "[;,:.\\/]", "_")
	
	for _, ply in ipairs(targets) do
		ply:SetMoveType(MOVETYPE_WALK)
		local train = ents.Create("lemon_train")
		train:SetPos(ply:GetPos() + Vector(0, 0, 100) + ply:GetForward() * 1000)
		train:SetAngles((ply:GetPos() + Vector(0, 0, 100) - train:GetPos()):Normalize():Angle() - Angle(0, 90, 0))
		train:SetOwner(ply)
		train:Spawn()
		train:Activate()

		train:SetHitCallback(function(train, ply)
			if not ValidEntity(train) or not ValidEntity(ply) then return end

			ply:Kick(reason)
		end)
	end
end
PLUGIN:AddCommand("trainkick", PLUGIN.TrainKick, ACCESS_KICK, "Kicks a player in a awesome way", "<Player name | SteamID | #UserID | @Team name> [Reason]")

//--------------------------------------------------

function PLUGIN:Crash(ply, command, args)
	local targets = lemon.player:GetTarget(ply, args[1], false)
	
	for k, v in pairs(targets) do
		v:Remove()
	end
end
PLUGIN:AddCommand("crash", PLUGIN.Crash, ACCESS_RCON, "Crashes a player", "<Player name | SteamID | #UserID | @Team name>")

function PLUGIN:EnterVehicle(ply, command, args)
	local targets = lemon.player:GetTarget(ply, args[1], false)
	local vehicle = ply:GetEyeTrace().Entity
	
	if ValidEntity(vehicle) or vehicle:IsVehicle() then
		if #targets == 1 then
			if (ValidEntity(vehicle:GetDriver())) then vehicle:GetDriver():ExitVehicle() end
			targets[1]:EnterVehicle(vehicle)
		end
	end
end
PLUGIN:AddCommand("enter", PLUGIN.EnterVehicle, ACCESS_SLAY, "Forces a user to enter the vehicle you're looking at", "<Player name | SteamID | #UserID | @Team name>")

function PLUGIN:ExitVehicle(ply, command, args)
	local targets = lemon.player:GetTarget(ply, args[1], false)

	for k,v in pairs(targets) do
		if v:InVehicle() then
			v:ExitVehicle()
		end
	end
end
PLUGIN:AddCommand("exit", PLUGIN.ExitVehicle, ACCESS_SLAY, "Forces the specified user to exit the vehicle he's in", "<Player name | SteamID | #UserID | @Team name>")

function PLUGIN:Cexec(ply, command, args)
	local targets = lemon.player:GetTarget(ply, args[1], false)
	local execute = table.concat(args, " ", 2)
	
	for k,v in pairs(targets) do
		v:ConCommand(execute)
	end
end
PLUGIN:AddCommand("cexec", PLUGIN.Cexec, ACCESS_RCON, "Execute command on a user", "<Player name | SteamID | #UserID | @Team name> <Command(s)>")

function PLUGIN:RespawnPlayer(ply, command, args)
	local targets = lemon.player:GetTarget(ply, args[1], false)
	
	for k,v in pairs(targets) do
		if v:Alive() then
			local pos = v:GetPos()
			local ang = v:EyeAngles()
			v:Spawn()
			v:SetPos(pos)
			v:SetEyeAngles(ang)
		end
	end
end
PLUGIN:AddCommand("respawn", PLUGIN.RespawnPlayer, ACCESS_SLAY, "Respawns a user", "<Player name | SteamID | #UserID | @Team name>")

function PLUGIN:SpawnPlayer(ply, command, args)
	local targets = lemon.player:GetTarget(ply, args[1], false)
	
	for k,v in pairs(targets) do
		if v:Alive() then
			v:Spawn()
		end
	end
end
PLUGIN:AddCommand("spawn", PLUGIN.SpawnPlayer, ACCESS_SLAY, "Spawns a user", "<Player name | SteamID | #UserID | @Team name>")

function PLUGIN:SetHealth(ply, command, args)
	local targets = lemon.player:GetTarget(ply, args[1], false)
	local health = tonumber(args[2]) or 1
	health = math.floor(math.Clamp(health, 1, 2147483647))
	
	for k,v in pairs(targets) do
		if v:Alive() then
			v:SetHealth(health)
		end
	end
end
PLUGIN:AddCommand("hp", PLUGIN.SetHealth, ACCESS_SLAY, "Sets a users health", "<Player name | SteamID | #UserID | @Team name> <Health ammount>")

function PLUGIN:EnableGod(ply, command, args)
	local targets = lemon.player:GetTarget(ply, args[1], false)

	for k,v in pairs(targets) do
		if v:Alive() then
			v:GodEnable()
			v.lemon.GodMode = true
		end
	end
end
PLUGIN:AddCommand("god", PLUGIN.EnableGod, ACCESS_SLAY, "Enables godmode for a user", "<Player name | SteamID | #UserID | @Team name>")

function PLUGIN:DisableGod(ply, command, args)
	local targets = lemon.player:GetTarget(ply, args[1], false)

	for k,v in pairs(targets) do
		if v:Alive() then
			v:GodDisable()
			v.lemon.GodMode = false
		end
	end
end
PLUGIN:AddCommand("ungod", PLUGIN.DisableGod, ACCESS_SLAY, "Disables godmode for a user", "<Player name | SteamID | #UserID | @Team name>")

function PLUGIN:Slay(ply, command, args)
	local targets = lemon.player:GetTarget(ply, args[1], false)

	for k,v in pairs(targets) do
		if v:Alive() then
			if v:InVehicle() then
				v:ExitVehicle()
			end
			v:Kill()
		end
	end
end
PLUGIN:AddCommand("slay", PLUGIN.Slay, ACCESS_SLAY, "Kills a user", "<Player name | SteamID | #UserID | @Team name>")

function PLUGIN:SilentSlay(ply, command, args)
	local targets = lemon.player:GetTarget(ply, args[1], false)
	
	for k, v in pairs(targets) do
		if v:Alive() then
			if v:InVehicle() then
				v:ExitVehicle()
			end
			v:KillSilent()
		end
	end
end
PLUGIN:AddCommand("sslay", PLUGIN.SilentSlay, ACCESS_SLAY, "Silently kills a user (No killicon and sound)", "<Player name | SteamID | #UserID | @Team name>")

function PLUGIN:GiveWeapon(ply, command, args)
	local targets = lemon.player:GetTarget(ply, args[1], false)
	local wep = args[2]
	
	for k, v in pairs(targets) do
		if v:Alive() then
			v:Give(wep)
		end
	end
end
PLUGIN:AddCommand("give", PLUGIN.GiveWeapon, ACCESS_SLAY, "Gives the specified item to a user", "<Player name | SteamID | #UserID | @Team name> <Weapon name>")

function PLUGIN:StripWeapons(ply, command, args)
	local targets = lemon.player:GetTarget(ply, args[1], false)
	
	for k,v in pairs(targets) do
		if v:Alive() then
			v:StripWeapons()
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
	local targets = lemon.player:GetTarget(ply, args[1], false)
	if targets[1] then targets = targets[1] end
	
	if ply:Alive() then
		if ply:InVehicle() then
			ply:ExitVehicle()
		end
		
		local pos = self:FindFreeSpace(targets, true)
		if pos then
			ply:SetPos(pos)
		end
	end
end
PLUGIN:AddCommand("tp", PLUGIN.TeleTo, "", "Teleports yourself to the specified user", "<Player name | SteamID | #UserID | @Team name>")
PLUGIN:AddCommand("goto", PLUGIN.TeleTo, "", "Teleports yourself to the specified user", "<Player name | SteamID | #UserID | @Team name>")

function PLUGIN:PublicGod(ply, command, args)
	if ply.lemon.GodMode then
		ply:GodDisable()
		ply.lemon.GodMode = false
	else
		ply:GodEnable()
		ply.lemon.GodMode = true
	end	
end
PLUGIN:AddCommand("godmode", PLUGIN.PublicGod, "", "Enables public godmode", "")

function PLUGIN:EntityTakeDamage(ent, inflictor, attacker, amount, dmginfo)
	if ent:IsPlayer() and ent.lemon and ent.lemon.GodMode then
		dmginfo:ScaleDamage(0)
	end
end

function PLUGIN:PhysgunPickup(ply, ent)
	if ent:IsPlayer() and ply:IsAdmin() then
		ent.lemon.oldMoveType = ent:GetMoveType()
		ent:SetMoveType(MOVETYPE_NONE)
		ent.lemon.PhysgunPickup = true
		return true
	end
end

function PLUGIN:PhysgunDrop(ply, ent)
	if ent:IsPlayer() and ply:IsAdmin() then
		ent.lemon.PhysgunPickup = false
		ent:SetMoveType(ent.lemon.oldMoveType)
	end
end

function PLUGIN:PlayerNoclip(ply)
	if ply.lemon.PhysgunPickup == true then return false end
end

local function GetAverage(tbl)
	if #tbl == 1 then return tbl[1] end

	local average = vector_origin
	
	for key, vec in pairs(tbl) do
		average = average + vec
	end
	
	return average / #tbl
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
	if ply.lemon.PhysgunPickup then
		data:SetVelocity((data:GetOrigin() - CalcVelocity(ply, data:GetOrigin())) * 8)
	end
end