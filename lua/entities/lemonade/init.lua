AddCSLuaFile("shared.lua")
include("shared.lua")

local ACTIVITY_IDLE = 0
local ACTIVITY_WANDER = 1
local ACTIVITY_CHASE = 2

function ENT:Initialize()
	self:SetModel("models/Police.mdl")
	self:SetHealth(999999999)
	self:StartActivity(ACT_IDLE)
	self:SetEnemy(nil)
	self:SetCurrentActivity(ACTIVITY_WANDER)

	self.Weapon = ents.Create("prop_dynamic")
	self.Weapon:SetModel("models/weapons/w_stunbaton.mdl")
	self.Weapon:Spawn()
	self.Weapon:SetNotSolid(true)

	local bone = self:LookupBone("ValveBiped.baton_parent")
	local pos, ang = self:GetBonePosition(bone)
	self.Weapon:SetPos(self:GetPos())
	self.Weapon:SetAngles(ang)
	self.Weapon:FollowBone(self, bone)
	self.Weapon:SetLocalPos(Vector(1, 0, -1))
	self.Weapon:SetLocalAngles(Angle(0, 94.47, 0))
end

function ENT:GetCurrentActivity()
	return self.CurrentActivity
end

function ENT:SetCurrentActivity(act)
	self.CurrentActivity = act
end

function ENT:GetEnemy()
	return self.Enemy
end

function ENT:SetEnemy(enemy)
	self.Enemy = enemy
end

function ENT:FindSpots(tbl)
	local tbl = tbl or {}
	tbl.pos = tbl.pos or self:WorldSpaceCenter()
	tbl.radius = tbl.radius or 1000
	tbl.stepdown = tbl.stepdown or 20
	tbl.stepup = tbl.stepup or 20
	tbl.type = tbl.type or "any"

	local path = Path("Follow")
	local areas = navmesh.Find(tbl.pos, tbl.radius, tbl.stepdown, tbl.stepup)
	local found = {}

	for _, area in pairs(areas) do
		local spots
		if tbl.type == "hiding" then
			spots = area:GetHidingSpots()
		elseif tbl.type == "exposed" then
			spots = area:GetExposedSpots()
		elseif tbl.type == "any" then
			spots = area:GetExposedSpots()
			table.Add(spots, area:GetHidingSpots())
		end

		for k, vec in pairs(spots) do
			path:Invalidate()
			path:Compute(self, vec, 1)
			table.insert(found, {vector = vec, distance = path:GetLength()})
		end
	end

	return found
end

function ENT:OnInjured(dmg_info)
	if self:GetCurrentActivity() ~= ACTIVITY_CHASE then
		self:SetEnemy(Entity(1))
		self:SetCurrentActivity(ACTIVITY_CHASE)
	end
end

function ENT:OnKilled(dmg_info)
	self:EmitSound(string.format("npc/metropolice/die%i.wav", math.random(1, 2)))
	self:BecomeRagdoll(dmg_info)
end

function ENT:StunstickAttack(target, single)
	if single then
		self:StartActivity(ACT_MELEE_ATTACK_SWING)
		coroutine.wait(0.5)
		self:EmitSound(string.format("weapons/stunstick/stunstick_fleshhit%i.wav", math.random(1, 2)))
		self:GetEnemy():TakeDamage(15, self, self.Weapon)
		return "ok"
	end

	while true do
		self:StartActivity(ACT_MELEE_ATTACK_SWING)
		coroutine.wait(0.5)
		self:EmitSound(string.format("weapons/stunstick/stunstick_fleshhit%i.wav", math.random(1, 2)))
		self:GetEnemy():TakeDamage(15, self, self.Weapon)
	end

	return "ok"
end

function ENT:ChaseTarget(target)
	local path = Path("Chase")
	path:SetMinLookAheadDistance(300)
	path:SetGoalTolerance(20)

	self:StartActivity(ACT_RUN)
	self.loco:SetDesiredSpeed(200)

	while self:GetCurrentActivity() == ACTIVITY_CHASE and self:GetRangeTo(target) > 40 do
		path:Compute(self, target:GetPos())
		path:Chase(self, target)

		if self.loco:IsStuck() then
			self:HandleStuck()
			return "stuck"
		end

		coroutine.yield()
	end

	return "ok"
end

function ENT:Wander()
	local pos = self:FindSpot("random", {type = "any", radius = 5000})
	if not pos then pos = self:GetPos() + Vector(math.Rand(-1, 1), math.Rand(-1, 1), 0) * 1000 end

	self:StartActivity(ACT_WALK)
	self.loco:SetDesiredSpeed(60)
	
	local path = Path("Follow")
	path:SetMinLookAheadDistance(300)
	path:SetGoalTolerance(20)
	path:Compute(self, pos)

	if not path:IsValid() then return "failed" end

	while self:GetCurrentActivity() == ACTIVITY_WANDER and path:IsValid() do
		path:Update(self)

		if self.loco:IsStuck() then
			self:HandleStuck()
			return "stuck"
		end

		coroutine.yield()
	end

	self:StartActivity(ACT_IDLE)
	return "ok"
end

function ENT:RunBehaviour()
	while true do
		if self:GetCurrentActivity() == ACTIVITY_CHASE and IsValid(self:GetEnemy()) then
			if self:ChaseTarget(self:GetEnemy()) == "ok" then
				self:StunstickAttack(self:GetEnemy(), true)
			end

			self:SetEnemy(nil)
			self:SetCurrentActivity(ACTIVITY_WANDER)
		elseif self:GetCurrentActivity() == ACTIVITY_WANDER then
			self:Wander()
		end

		coroutine.yield()
	end
end