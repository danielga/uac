PLUGIN.Name = "RCON"
PLUGIN.Description = "Adds access to the server console."
PLUGIN.Author = "MetaMan"

function PLUGIN:RemoteConsole(ply, cmd)
	game.ConsoleCommand(cmd .. "\n")
end
PLUGIN:AddCommand("rcon", PLUGIN.RemoteConsole)
	:SetAccess(ACCESS_RCON)
	:SetDescription("Execute command on the server")
	:AddParameter(uac.command.string)