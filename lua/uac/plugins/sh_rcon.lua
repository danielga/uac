PLUGIN.Name = "RCon"
PLUGIN.Description = "Adds access to the server console."
PLUGIN.Author = "MetaMan"

PLUGIN:AddPermission("rcon", "Allows users to run commands on the server")

function PLUGIN:RemoteConsole(ply, cmd)
	game.ConsoleCommand(cmd .. "\n")
end
PLUGIN:AddCommand("rcon", PLUGIN.RemoteConsole)
	:SetPermission("rcon")
	:SetDescription("Execute command on the server")
	:AddParameter(uac.command.string)
