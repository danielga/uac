PLUGIN.Name = "Role management"
PLUGIN.Description = "Allows users to set someone's role."
PLUGIN.Author = "MetaMan"

PLUGIN:AddPermission("role", "Gives access to role management")

function PLUGIN:SetPlayerRole(ply, target, role)
	target:SetRole(role)
end
PLUGIN:AddCommand("role", PLUGIN.SetPlayerRole)
	:SetPermission("role")
	:SetDescription("Sets the role of the specified user")
	:AddParameter(uac.command.player)
	:AddParameter(uac.command.string)
