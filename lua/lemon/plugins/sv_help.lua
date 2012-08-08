PLUGIN.Name = "Help"
PLUGIN.Description = "Prints the whole list of commands and their description (if it exists) on the console."
PLUGIN.Author = "Agent 47, DrogenViech"

function PLUGIN:Help(ply, cmd, args)
	if args[1] then
		for command, data in pairs(lemon.command.List) do
			if string.find(command, args[1]) then
				ply:PrintMessage(HUD_PRINTCONSOLE, string.format("%s%s%s", command, string.rep(" ", 20 - #command), data.desc or ""))
			end
		end
	else
		for command, data in pairs(lemon.command.List) do
			ply:PrintMessage(HUD_PRINTCONSOLE, string.format("%s%s%s", command, string.rep(" ", 20 - #command), data.desc or ""))
		end
	end
end
PLUGIN:AddCommand("help", PLUGIN.Help, "", "Prints a list of commands or help specific to a command", "[Command name]")