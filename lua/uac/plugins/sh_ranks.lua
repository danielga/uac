PLUGIN.Name = "Rank setting"
PLUGIN.Description = "Allows users with Server Owner flags to set someone's rank/usergroup."
PLUGIN.Author = "MetaMan"

function PLUGIN:UsergroupPlayer(ply, target, usergroup)
	target:SetUserGroup(usergroup)
end
PLUGIN:AddCommand("rank", PLUGIN.UsergroupPlayer)
	:SetAccess(uac.auth.access.owner)
	:SetDescription("Sets the usergroup of the specified user")
	:AddParameter(uac.command.player)
	:AddParameter(uac.command.string)

function PLUGIN:FlagPlayer(ply, target, flags)
	target:SetUserFlags(flags)
end
PLUGIN:AddCommand("flags", PLUGIN.FlagPlayer)
	:SetAccess(uac.auth.access.owner)
	:SetDescription("Sets the flags of the specified user")
	:AddParameter(uac.command.player)
	:AddParameter(uac.command.string)
