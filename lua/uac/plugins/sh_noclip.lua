PLUGIN.Name = "Noclip"
PLUGIN.Description = "Adds a command to noclip players."
PLUGIN.Author = "MetaMan"

function PLUGIN:Noclip(ply, target)
	if target ~= nil then
		if target:GetMoveType() == MOVETYPE_NOCLIP then
			target:SetMoveType(MOVETYPE_WALK)
		else
			target:SetMoveType(MOVETYPE_NOCLIP)
		end
	else
		if ply:GetMoveType() == MOVETYPE_NOCLIP then
			ply:SetMoveType(MOVETYPE_WALK)
		else
			ply:SetMoveType(MOVETYPE_NOCLIP)
		end
	end
end
PLUGIN:AddCommand("noclip", PLUGIN.Noclip)
	:SetAccess(ACCESS_SLAY)
	:SetDescription("Toggles noclip for a user/yourself")
	:AddParameter(uac.command.player)