PLUGIN.Name = "Physgun"
PLUGIN.Description = "Allows admins to pick up players with their physgun."
PLUGIN.Author = "MetaMan"

function PLUGIN:PhysgunPickup(ply, ent)
	if ent:IsPlayer() and not ent:GetUACTable().PhysgunPickup and ply:IsAdmin() then
		ent:GetUACTable().OldMoveType = ent:GetMoveType()
		ent:SetMoveType(MOVETYPE_NONE)
		ent:SetOwner(ply)
		ent:GetUACTable().PhysgunPickup = true
		return true
	end
end
PLUGIN:AddHook("PhysgunPickup", "UAC physgun plugin (physgun players)", PLUGIN.PhysgunPickup)

function PLUGIN:PhysgunDrop(ply, ent)
	if ent:IsPlayer() and ent:GetUACTable().PhysgunPickup and ply:IsAdmin() then
		ent:GetUACTable().PhysgunPickup = false
		ent:SetMoveType(ent:GetUACTable().OldMoveType)
		ent:SetOwner()
		ent:GetUACTable().OldMoveType = nil
	end
end
PLUGIN:AddHook("PhysgunDrop", "UAC physgun plugin (physgun players)", PLUGIN.PhysgunDrop)

function PLUGIN:PlayerNoclip(ply)
	if ply:GetUACTable().PhysgunPickup then
		return false
	end
end
PLUGIN:AddHook("PlayerNoclip", "UAC physgun plugin (physgun players)", PLUGIN.PlayerNoclip)