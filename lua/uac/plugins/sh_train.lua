PLUGIN.Name = "Player control"
PLUGIN.Description = "Adds commands to control players."
PLUGIN.Author = "MetaMan"

function PLUGIN:TrainFuck(ply, targets)
	for i = 1, #targets do
		local ply = targets[i]
		ply:SetMoveType(MOVETYPE_WALK)
		local train = ents.Create("uac_train")
		train:SetPos(ply:GetPos() + Vector(0, 0, 100) + ply:GetForward() * 1000)
		local vec = ply:GetPos() + Vector(0, 0, 100) - train:GetPos()
		vec:Normalize()
		train:SetAngles(vec:Angle() - Angle(0, 90, 0))
		train:SetOwner(ply)
		train:Spawn()
		train:Activate()

		train:SetHitCallback(function(train, ply)
			if not IsValid(ply) then
				return
			end

			local vec = ply:GetPos() - train:GetPos() + Vector(0, 0, 400)
			vec:Normalize()
			ply:SetLocalVelocity(vec * 2000)
			ply:Kill()
		end)
	end
end
PLUGIN:AddCommand("trainfuck", PLUGIN.TrainFuck)
	:SetAccess(ACCESS_SLAY)
	:SetDescription("Slays a player in a awesome way")
	:AddParameter(uac.command.players)
	:AddParameter(uac.command.string)

function PLUGIN:TrainBan(ply, target, time, reason)
	time = time or 5
	reason = reason or ("Banned for " .. time .. " minutes.")
	reason = reason:gsub("[;,:.\\/]", "_")
	
	target:SetMoveType(MOVETYPE_WALK)
	local train = ents.Create("uac_train")
	train:SetPos(target:GetPos() + Vector(0, 0, 100) + target:GetForward() * 1000)
	local vec = target:GetPos() + Vector(0, 0, 100) - train:GetPos()
	vec:Normalize()
	train:SetAngles(vec:Angle() - Angle(0, 90, 0))
	train:SetOwner(target)
	train:Spawn()
	train:Activate()

	train:SetHitCallback(function(train, target)
		if IsValid(target) then
			target:Ban(time, reason)
			target:Kick(reason)
		end
	end)

	local name = target:Nick()
	local steamid = target:SteamID()
	train:SetEndCallback(function(train, target, success)
		if success then
			return
		end

		uac.ban.Add(steamid, time, reason, ply, name)
	end)
end
PLUGIN:AddCommand("trainban", PLUGIN.TrainBan)
	:SetAccess(ACCESS_BAN)
	:SetDescription("Bans a player in a awesome way")
	:AddParameter(uac.command.player)
	:AddParameter(uac.command.number)
	:AddParameter(uac.command.string)

function PLUGIN:TrainKick(ply, target, reason)
	reason = reason or ""
	reason = reason:gsub("[;,:.\\/]", "_")

	target:SetMoveType(MOVETYPE_WALK)
	local train = ents.Create("uac_train")
	train:SetPos(target:GetPos() + Vector(0, 0, 100) + target:GetForward() * 1000)
	local vec = target:GetPos() + Vector(0, 0, 100) - train:GetPos()
	vec:Normalize()
	train:SetAngles(vec:Angle() - Angle(0, 90, 0))
	train:SetOwner(target)
	train:Spawn()
	train:Activate()

	train:SetHitCallback(function(train, target)
		if IsValid(target) then
			target:Kick(reason)
		end
	end)
end
PLUGIN:AddCommand("trainkick", PLUGIN.TrainKick)
	:SetAccess(ACCESS_KICK)
	:SetDescription("Kicks a player in a awesome way")
	:AddParameter(uac.command.player)
	:AddParameter(uac.command.string)