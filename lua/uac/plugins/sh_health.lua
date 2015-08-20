PLUGIN.Name = "Health"
PLUGIN.Description = "Adds a command to set players health."
PLUGIN.Author = "MetaMan"

function PLUGIN:SetHealth(ply, target, health)
	if target:Alive() then
		target:SetHealth(math.floor(health))
	end
end
PLUGIN:AddCommand("hp", PLUGIN.SetHealth)
	:SetAccess(ACCESS_SLAY)
	:SetDescription("Sets a users health")
	:AddParameter(uac.command.player)
	:AddParameter(uac.command.number(1, 2147483647))
