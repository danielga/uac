AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
include("schedules.lua")
include("tasks.lua")

ENT.m_fMaxYawSpeed = 20
ENT.m_iClass = CLASS_COMBINE
--ENT.LastSchedule = SCHED_IDLE_WANDER
ENT.CurSchedule = SCHED_IDLE_WANDER
ENT.Finished = true

AccessorFunc(ENT, "m_iClass", "NPCClass")
AccessorFunc(ENT, "m_fMaxYawSpeed", "MaxYawSpeed")

function ENT:Initialize()
	self:SetModel("models/Police.mdl")
	self:SetHullType(HULL_HUMAN)
	self:SetHullSizeNormal()
	self:SetSolid(SOLID_BBOX) 
	self:SetMoveType(MOVETYPE_STEP)
	self:CapabilitiesAdd(CAP_MOVE_GROUND | CAP_MOVE_JUMP | CAP_MOVE_CLIMB | CAP_MOVE_SHOOT | CAP_AUTO_DOORS | CAP_OPEN_DOORS | CAP_TURN_HEAD | CAP_WEAPON_MELEE_ATTACK1 | CAP_WEAPON_MELEE_ATTACK2 | CAP_WEAPON_RANGE_ATTACK1 | CAP_WEAPON_RANGE_ATTACK2 | CAP_USE_WEAPONS | CAP_USE_SHOT_REGULATOR | CAP_ANIMATEDFACE)
	self:SetMaxYawSpeed(self.m_fMaxYawSpeed)
	self:SetHealth(9999999)
	self:Give("ai_weapon_stunstick")
	self.CurSchedule = SCHED_IDLE_WANDER
	self:AddRelationship("player D_NU 10")

	hook.Add("EntityTakeDamage", "lemonade_EntityTakeDamage", function(victim, inflictor, attacker, dmg, dmginfo)
		if victim == self.Entity then
			dmginfo:SetDamage(0)
		end
	end)

	hook.Add("ScaleNPCDamage", "lemonade_ScaleNPCDamage", function(npc, hitgroup, dmginfo)
		if npc == self.Entity then
			dmginfo:SetDamage(0)
		end
	end)
end

function ENT:Think()
	if self:GetEnemy() and self:GetEnemy() != NULL and self:GetEnemy():IsValid() then
		if self:GetEnemy():Health() <= 0 then
			self:AddEntityRelationship(self:GetEnemy(), D_NU, 10)
			self:SetEnemy(nil)
			self.CurSchedule = SCHED_IDLE_WANDER
			self.Finished = false
			self:TimedSchedule(5)
		else
			self:UpdateEnemyMemory(self:GetEnemy(), self:GetEnemy():GetPos())
		end
	end
end

function ENT:OnTakeDamage(dmginfo)
	dmginfo:SetDamage(0)
	--self.CurSchedule = SCHED_SMALL_FLINCH
	self:SetSchedule(SCHED_SMALL_FLINCH)
end

function ENT:SelectSchedule(npcstate)
	if !self.Finished then return end

	if self.CurSchedule == SCHED_CHASE_ENEMY then
		if self:GetEnemy() and self:GetEnemy():IsValid() and self.Entity:GetPos():Distance(self:GetEnemy():GetPos()) <= 65 then
			self.CurSchedule = SCHED_MELEE_ATTACK1
		else
			self.CurSchedule = SCHED_CHASE_ENEMY
		end
		self:SetSchedule(self.CurSchedule)
	elseif self.CurSchedule == SCHED_MELEE_ATTACK1 then
		if self:GetEnemy() and self:GetEnemy():IsValid() and self.Entity:GetPos():Distance(self:GetEnemy():GetPos()) <= 65 then
			self.CurSchedule = SCHED_MELEE_ATTACK1
		else
			self.CurSchedule = SCHED_CHASE_ENEMY
		end
		self:SetSchedule(self.CurSchedule)
	elseif self.CurSchedule == SCHED_FORCED_GO_RUN then
		self.CurSchedule = SCHED_IDLE_WANDER
		self:TimedSchedule(5)
	elseif self.CurSchedule == SCHED_FORCED_GO then
		self.CurSchedule = SCHED_IDLE_WANDER
		self:TimedSchedule(5)
	else
		self.CurSchedule = SCHED_IDLE_WANDER
		self.Finished = false
		self:TimedSchedule(5)
	end
end

function ENT:StartEngineSchedule(schedule)
	print("StartEngineSchedule " .. schedule)
	self:ScheduleFinished()
	self.bDoingEngineSchedule = true
	self.Finished = false
end

function ENT:EngineScheduleFinish()
	self.bDoingEngineSchedule = nil
	self.Finished = true
end

function ENT:TimedSchedule(time)
	timer.Create("lemonade_schedule", time, 1, function() if self and self:IsValid() then self:SetSchedule(self.CurSchedule) end end)
end

function ENT:RunToVector(vector)
	timer.Destroy("lemonade_schedule")
	self:SetLastPosition(vector)
	self.CurSchedule = SCHED_FORCED_GO_RUN
	self:SetSchedule(self.CurSchedule)
end

function ENT:WalkToVector(vector)
	timer.Destroy("lemonade_schedule")
	self:SetLastPosition(vector)
	self.CurSchedule = SCHED_FORCED_GO
	self:SetSchedule(self.CurSchedule)
end

function ENT:AttackTarget(entity)
	timer.Destroy("lemonade_schedule")
	self:AddEntityRelationship(entity, D_HT, 10)
	self:SetEnemy(entity)
	self:UpdateEnemyMemory(entity, entity:GetPos())
	self.CurSchedule = SCHED_CHASE_ENEMY
	self:SetSchedule(self.CurSchedule)
end