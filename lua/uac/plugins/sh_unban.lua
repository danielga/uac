PLUGIN.Name = "Ban"
PLUGIN.Description = "Adds a command to ban players."
PLUGIN.Author = "MetaMan"

function PLUGIN:Unban(ply, target, reason)
	uac.ban.Remove(target, reason, ply)
end
PLUGIN:AddCommand("unban", PLUGIN.Unban)
	:SetAccess(ACCESS_BAN)
	:SetDescription("Removes a ban from the database")
	:AddParameter(uac.command.player)
	:AddParameter(uac.command.string("Unbanned from server"))