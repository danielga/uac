PLUGIN.Name = "Player (re)spawn"
PLUGIN.Description = "Adds commands to (re)spawn players."
PLUGIN.Author = "MetaMan"

PLUGIN:AddPermission("respawn", "Allows users to (re)spawn players")

function PLUGIN:RespawnPlayer(ply, target)
	local pos = target:GetPos()
	local ang = target:EyeAngles()
	target:Spawn()
	target:SetPos(pos)
	target:SetEyeAngles(ang)
end
PLUGIN:AddCommand("respawn", PLUGIN.RespawnPlayer)
	:SetPermission("respawn")
	:SetDescription("Respawns a user")
	:AddParameter(uac.command.player(uac.command.optional))

function PLUGIN:SpawnPlayer(ply, target)
	target:Spawn()
end
PLUGIN:AddCommand("spawn", PLUGIN.SpawnPlayer)
	:SetPermission("respawn")
	:SetDescription("Spawns a user")
	:AddParameter(uac.command.player)
