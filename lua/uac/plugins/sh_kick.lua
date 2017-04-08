PLUGIN.Name = "Player kicking"
PLUGIN.Description = "Adds a command to kick players."
PLUGIN.Author = "MetaMan"

PLUGIN:AddPermission("kick", "Allows users to kick players")

function PLUGIN:Kick(ply, target, reason)
	reason = string.gsub(reason, "[;,:.\\/]", "_")
	target:Kick(reason)
end
PLUGIN:AddCommand("kick", PLUGIN.Kick)
	:SetPermission("kick")
	:SetDescription("Kicks the specified user with optional reason")
	:AddParameter(uac.command.player)
	:AddParameter(uac.command.string("Kicked from server"))
