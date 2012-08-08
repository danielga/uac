ENT.Type = "ai"
ENT.Base = "base_ai"
ENT.PrintName = "Lemonade"
ENT.Author = "Agent 47"
ENT.Information = "Admin NPC"
ENT.Category = "SNPCs"
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.AutomaticFrameAdvance = false

function ENT:OnRemove()

end

function ENT:PhysicsCollide(data, physobj)

end

function ENT:PhysicsUpdate(physobj)

end

function ENT:SetAutomaticFrameAdvance(bUsingAnim)
	self.AutomaticFrameAdvance = bUsingAnim
end