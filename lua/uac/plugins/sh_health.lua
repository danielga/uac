PLUGIN.Name = "Player health management"
PLUGIN.Description = "Adds a command to set players health."
PLUGIN.Author = "MetaMan"

PLUGIN:AddPermission("health", "Allows users to set players health")

function PLUGIN:SetHealth(ply, target, health)
	if target:Alive() then
		target:SetHealth(math.floor(health))
	end
end
PLUGIN:AddCommand("hp", PLUGIN.SetHealth)
	:SetPermission("health")
	:SetDescription("Sets a users health")
	:AddParameter(uac.command.player)
	:AddParameter(uac.command.number(1, 2147483647))
