PLUGIN.Name = "RCON"
PLUGIN.Description = "Adds access to the server console."
PLUGIN.Author = "DrogenViech"

function PLUGIN:RemoteConsole(ply, command, args)
	if ValidEntity(ply) and ply:IsPlayer() and #args < 1 then
		ply:ChatMessage(Color(255, 0, 0, 255), "[Lemon] ", Color(255, 255, 255, 255), "You need to provide a command.")
		return
	end

	local str = table.concat(args, " ")
	game.ConsoleCommand(str)
end
PLUGIN:AddCommand("rcon", PLUGIN.RemoteConsole, ACCESS_RCON, "Execute command on the server")