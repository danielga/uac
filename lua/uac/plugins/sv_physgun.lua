PLUGIN.Name = "Physgun"
PLUGIN.Description = "Allows admins to pick up players with their physgun."
PLUGIN.Author = "MetaMan"

function PLUGIN:PhysgunPickup(ply, ent)
	if ent:IsPlayer() and not ent:GetUACTable().physgunpickup and ply:IsAdmin() then
		local uactable = ent:GetUACTable()
		uactable.oldmovetype = ent:GetMoveType()
		ent:SetMoveType(MOVETYPE_NONE)
		ent:SetOwner(ply)
		uactable.physgunpickup = true
		return true
	end
end
PLUGIN:AddHook("PhysgunPickup", "UAC physgun plugin (physgun players)", PLUGIN.PhysgunPickup)

function PLUGIN:PhysgunDrop(ply, ent)
	if ent:IsPlayer() and ent:GetUACTable().physgunpickup and ply:IsAdmin() then
		local uactable = ent:GetUACTable()
		uactable.physgunpickup = false
		ent:SetMoveType(uactable.oldmovetype)
		ent:SetOwner()
		uactable.oldmovetype = nil
	end
end
PLUGIN:AddHook("PhysgunDrop", "UAC physgun plugin (physgun players)", PLUGIN.PhysgunDrop)

function PLUGIN:PlayerNoclip(ply)
	if ply:GetUACTable().physgunpickup then
		return false
	end
end
PLUGIN:AddHook("PlayerNoclip", "UAC physgun plugin (physgun players)", PLUGIN.PlayerNoclip)
