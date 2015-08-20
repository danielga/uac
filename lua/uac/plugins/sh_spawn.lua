PLUGIN.Name = "Spawn"
PLUGIN.Description = "Adds a command to spawn players."
PLUGIN.Author = "MetaMan"

function PLUGIN:SpawnPlayer(ply, target)
	target:Spawn()
end
PLUGIN:AddCommand("spawn", PLUGIN.SpawnPlayer)
	:SetAccess(ACCESS_SLAY)
	:SetDescription("Spawns a user")
	:AddParameter(uac.command.player)
