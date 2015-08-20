PLUGIN.Name = "Kick"
PLUGIN.Description = "Adds a command to kick players."
PLUGIN.Author = "MetaMan"

function PLUGIN:Kick(ply, target, reason)
	reason = reason:gsub("[;,:.\\/]", "_")
	target:Kick(reason)
end
PLUGIN:AddCommand("kick", PLUGIN.Kick)
	:SetAccess(ACCESS_KICK)
	:SetDescription("Kicks the specified user with optional reason")
	:AddParameter(uac.command.player)
	:AddParameter(uac.command.string("Kicked from server"))
