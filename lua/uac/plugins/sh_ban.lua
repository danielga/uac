PLUGIN.Name = "Ban"
PLUGIN.Description = "Adds a command to ban players."
PLUGIN.Author = "MetaMan"

function PLUGIN:Ban(ply, target, time, reason)
	reason = reason:gsub("[;,:.\\/]", "_")

	target:Ban(time, reason)
	target:Kick(reason)
end
PLUGIN:AddCommand("ban", PLUGIN.Ban)
	:SetAccess(ACCESS_BAN)
	:SetDescription("Bans the specified user with optional reason")
	:AddParameter(uac.command.player)
	:AddParameter(uac.command.number(0, math.huge, 5))
	:AddParameter(uac.command.string("Banned from server"))
