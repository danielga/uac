PLUGIN.Name = "Health"
PLUGIN.Description = "Adds a command to set players health."
PLUGIN.Author = "MetaMan"

function PLUGIN:SetHealth(ply, target, health)
	health = math.floor(math.Clamp(health, 1, 2147483647))

	if target:Alive() then
		target:SetHealth(health)
	end
end
PLUGIN:AddCommand("hp", PLUGIN.SetHealth)
	:SetAccess(ACCESS_SLAY)
	:SetDescription("Sets a users health")
	:AddParameter(uac.command.player)
	:AddParameter(uac.command.number)