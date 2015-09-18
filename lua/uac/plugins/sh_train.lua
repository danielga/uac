PLUGIN.Name = "Trains"
PLUGIN.Description = "Adds commands to apply actions on players through trains."
PLUGIN.Author = "MetaMan"

function PLUGIN:TrainFuck(ply, targets)
	for i = 1, #targets do
		local target = targets[i]
		target:SetMoveType(MOVETYPE_WALK)
		local train = ents.Create("uac_train")
		train:SetPos(target:GetPos() + Vector(0, 0, 100) + target:GetForward() * 1000)
		local vec = target:GetPos() + Vector(0, 0, 100) - train:GetPos()
		vec:Normalize()
		train:SetAngles(vec:Angle() - Angle(0, 90, 0))
		train:SetOwner(target)
		train:Spawn()
		train:Activate()

		train:SetHitCallback(function(self, targ)
			if not IsValid(targ) then
				return
			end

			local vel = targ:GetPos() - self:GetPos() + Vector(0, 0, 400)
			vel:Normalize()
			targ:SetLocalVelocity(vel * 2000)
			targ:Kill()
		end)
	end
end
PLUGIN:AddCommand("trainfuck", PLUGIN.TrainFuck)
	:SetAccess(ACCESS_SLAY)
	:SetDescription("Slays a player in a awesome way")
	:AddParameter(uac.command.players)

function PLUGIN:TrainBan(ply, target, time, reason)
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

	train:SetHitCallback(function(self, targ)
		if IsValid(targ) then
			targ:Ban(time, reason)
			targ:Kick(reason)
		end
	end)

	local name = target:Nick()
	local steamid = target:SteamID()
	train:SetEndCallback(function(self, targ, success)
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
	:AddParameter(uac.command.number(0, math.huge, 5))
	:AddParameter(uac.command.string("Banned from server"))

function PLUGIN:TrainKick(ply, target, reason)
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

	train:SetHitCallback(function(self, targ)
		if IsValid(targ) then
			targ:Kick(reason)
		end
	end)
end
PLUGIN:AddCommand("trainkick", PLUGIN.TrainKick)
	:SetAccess(ACCESS_KICK)
	:SetDescription("Kicks a player in a awesome way")
	:AddParameter(uac.command.player)
	:AddParameter(uac.command.string("Kicked from server"))

------------------------------------------------------------

local ENT = {}

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "UAC Train"
ENT.Author = "MetaMan"

ENT.Spawnable = false
ENT.AdminSpawnable = false

if CLIENT then

language.Add("uac_train", "Train")

ENT.RenderGroup = RENDERGROUP_OPAQUE

function ENT:Draw()
	self:DrawModel()
end

elseif SERVER then

ENT.honk = Sound("Trainyard.train_horn_everywhere")
ENT.shadowparams = {}

function ENT:Initialize()
	self:SetColor(uac.color.yellow)
	self:SetModel("models/props_trainstation/train001.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetNotSolid(true)
	self:SetTrigger(true)
	self:StartMotionController()
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:EnableGravity(false)
		phys:Wake()
	end
end

function ENT:SetKick(bool)
	self.kick = bool
end

function ENT:SetHitCallback(func)
	self.hitcallback = func
end

function ENT:SetEndCallback(func)
	self.endcallback = func
end

function ENT:StartTouch(ent)
	if self:GetOwner() == ent and ent:Alive() and not self.done then
		self.done = CurTime() + 1
		if self.hitcallback then
			self.hitcallback(self, ent)
		end
	end
end

function ENT:Think()
	local curtime = CurTime()
	if not IsValid(self:GetOwner()) or (self.done and self.done < curtime) then
		if self.endcallback then
			self.endcallback(self, self:GetOwner(), self.done and self.done >= curtime or false)
		end

		self:Remove()
		return
	end

	if not self.soundplayed and self:GetPos():Distance(self:GetOwner():GetPos()) < 2000 then
		self:EmitSound(self.honk, 100, 90)
		self.soundplayed = true
	end
end

function ENT:PhysicsUpdate(phys, delta)
	phys:Wake()

	if not IsValid(self:GetOwner()) then
		return SIM_NOTHING
	end

	if self:GetOwner():Alive() and not self.done then
		self.shadowparams.pos = self:GetOwner():GetPos() + Vector(0, 0, 100)
		local ang = (self.shadowparams.pos - self:GetPos()):Angle()
		ang.r = -ang.p
		ang.p = 0
		self.shadowparams.angle = ang - Angle(0, 90, 0)
	else
		self.shadowparams.pos = self:GetPos() + -self:GetRight() * 10000
	end

	self.shadowparams.secondstoarrive = 1
	self.shadowparams.maxangular = 1000
	self.shadowparams.maxangulardamp = 2000
	self.shadowparams.maxspeed = 1000
	self.shadowparams.maxspeeddamp = 2000
	self.shadowparams.dampfactor = 0.1
	self.shadowparams.teleportdistance = 90000
	self.shadowparams.deltatime = delta

	phys:ComputeShadowControl(self.shadowparams)
end

end

scripted_ents.Register(ENT, "uac_train")
