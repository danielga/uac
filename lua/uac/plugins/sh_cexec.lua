PLUGIN.Name = "Client commands"
PLUGIN.Description = "Adds a command to execute commands on players."
PLUGIN.Author = "MetaMan"

function PLUGIN:Cexec(ply, target, cmd)
	target:ConCommand(cmd)
end
PLUGIN:AddCommand("cexec", PLUGIN.Cexec)
	:SetAccess(ACCESS_RCON)
	:SetDescription("Execute command on a user")
	:AddParameter(uac.command.player)
	:AddParameter(uac.command.string)
