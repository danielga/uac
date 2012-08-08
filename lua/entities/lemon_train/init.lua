AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.Honk = Sound("Trainyard.train_horn_everywhere")
ENT.ShadowParams = {}

function ENT:Initialize()
	self:SetColor(255, 255, 0, 255)
	self:SetModel("models/props_trainstation/train001.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetNotSolid(true)
	self:SetTrigger(true)
	self:StartMotionController()
	local phys = self:GetPhysicsObject()
	if ValidEntity(phys) then
		phys:EnableGravity(false)
		phys:Wake()
	end
end

function ENT:SetKick(bool)
	self.Kick = bool
end

function ENT:SetHitCallback(func)
	self.HitCallback = func
end

function ENT:SetEndCallback(func)
	self.EndCallback = func
end

function ENT:StartTouch(ent)
	if self:GetOwner() == ent and ent:Alive() and not self.Done then
		self.Done = CurTime() + 8
		if self.HitCallback then
			self.HitCallback(self, ent)
		end
	end
end

function ENT:Think()
	if not ValidEntity(self:GetOwner()) or (self.Done and self.Done < CurTime()) then
		if self.EndCallback then
			self.EndCallback(self, self:GetOwner())
		end

		self.Entity:Remove()
		return
	end

	if not self.SoundPlayed and self:GetPos():Distance(self:GetOwner():GetPos()) < 2000 then
		self:EmitSound(self.Honk, 100, 90)
		self.SoundPlayed = true
	end
end

function ENT:PhysicsUpdate(phys, delta)
	phys:Wake()

	if not ValidEntity(self:GetOwner()) then return SIM_NOTHING end
	
	if self:GetOwner():Alive() and not self.Done then
		self.ShadowParams.pos = self:GetOwner():GetPos() + Vector(0, 0, 100)
		local ang = (self.ShadowParams.pos - self:GetPos()):Angle()
		ang.r = -ang.p
		ang.p = 0
		self.ShadowParams.angle = ang - Angle(0, 90, 0)
	else
		self.ShadowParams.pos = self:GetPos() + -self:GetRight() * 10000
	end
	
	self.ShadowParams.secondstoarrive = 1
	self.ShadowParams.maxangular = 1000
	self.ShadowParams.maxangulardamp = 2000
	self.ShadowParams.maxspeed = 1000
	self.ShadowParams.maxspeeddamp = 2000
	self.ShadowParams.dampfactor = 0.1
	self.ShadowParams.teleportdistance = 90000
	self.ShadowParams.deltatime = delta

	phys:ComputeShadowControl(self.ShadowParams)
end