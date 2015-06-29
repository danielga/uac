PLUGIN.Name = "Respawn"
PLUGIN.Description = "Adds a command to respawn players."
PLUGIN.Author = "MetaMan"

function PLUGIN:RespawnPlayer(ply, target)
	local pos = target:GetPos()
	local ang = target:EyeAngles()
	target:Spawn()
	target:SetPos(pos)
	target:SetEyeAngles(ang)
end
PLUGIN:AddCommand("respawn", PLUGIN.RespawnPlayer)
	:SetAccess(ACCESS_SLAY)
	:SetDescription("Respawns a user")
	:AddParameter(uac.command.player)