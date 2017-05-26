PLUGIN.Name = "Player noclip toggling"
PLUGIN.Description = "Adds a command to noclip players."
PLUGIN.Author = "MetaMan"

PLUGIN:AddPermission("noclip", "Allows users to toggle noclip on players")

function PLUGIN:Noclip(ply, target)
	if target ~= uac.command.optional then
		if target:GetMoveType() == MOVETYPE_NOCLIP then
			target:SetMoveType(MOVETYPE_WALK)
		else
			target:SetMoveType(MOVETYPE_NOCLIP)
		end
	else
		if not IsValid(ply) then
			return
		end
		
		if ply:GetMoveType() == MOVETYPE_NOCLIP then
			ply:SetMoveType(MOVETYPE_WALK)
		else
			ply:SetMoveType(MOVETYPE_NOCLIP)
		end
	end
end
PLUGIN:AddCommand("noclip", PLUGIN.Noclip)
	:SetPermission("noclip")
	:SetDescription("Toggles noclip for a user/yourself")
	:AddParameter(uac.command.player(uac.command.optional))
