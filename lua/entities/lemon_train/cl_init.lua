include("shared.lua")

ENT.RenderGroup = RENDERGROUP_OPAQUE

/*
function ENT:Initialize()
	language.Add("lemon_train", "Train")
end
*/

function ENT:Draw()
	self:DrawModel()
end

