PLUGIN.Name = "Goto"
PLUGIN.Description = "Adds a command to teleport to players."
PLUGIN.Author = "MetaMan"

function PLUGIN:TeleTo(ply, target)
	local pos = target:FindFreeSpace(true)
	if pos then
		ply:SetPos(pos)
		ply:SetAngles((target:EyePos() - ply:GetShootPos()):Angle())
	end
end
PLUGIN:AddCommand({"tp", "goto"}, PLUGIN.TeleTo)
	:SetAccess(ACCESS_SLAY)
	:SetDescription("Teleports yourself to the specified user")
	:AddParameter(uac.command.player)
