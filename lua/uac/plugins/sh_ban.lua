PLUGIN.Name = "Ban"
PLUGIN.Description = "Adds commands manage bans."
PLUGIN.Author = "MetaMan"

PLUGIN:AddPermission("ban", "Gives access to ban management")

function PLUGIN:Ban(ply, target, time, reason)
	reason = string.gsub(reason, "[;,:.\\/]", "_")

	target:Ban(time, reason)
	target:Kick(reason)
end
PLUGIN:AddCommand("ban", PLUGIN.Ban)
	:SetPermission("ban")
	:SetDescription("Bans the specified user with optional reason")
	:AddParameter(uac.command.player)
	:AddParameter(uac.command.number(0, math.huge, 5))
	:AddParameter(uac.command.string("Banned from server"))

function PLUGIN:Unban(ply, target, reason)
	uac.ban.Remove(target, reason, ply)
end
PLUGIN:AddCommand("unban", PLUGIN.Unban)
	:SetPermission("ban")
	:SetDescription("Removes a ban from the database")
	:AddParameter(uac.command.player)
	:AddParameter(uac.command.string("Unbanned from server"))
