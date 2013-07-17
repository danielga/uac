local PLUGIN = lemon.plugin:New()

PLUGIN.Name = "Help"
PLUGIN.Description = "Prints the whole list of commands and their description (if it exists) on the console."
PLUGIN.Author = "Agent 47, DrogenViech"

function PLUGIN:Help(ply, cmd, args)
	if args[1] then
		for command, data in pairs(lemon.command:GetList()) do
			if command:find(args[1]) then
				ply:PrintMessage(HUD_PRINTCONSOLE, ("%s%s%s"):format(command, (" "):rep(20 - #command), data.Description or ""))
			end
		end
	else
		for command, data in pairs(lemon.command:GetList()) do
			ply:PrintMessage(HUD_PRINTCONSOLE, ("%s%s%s"):format(command, (" "):rep(20 - #command), data.Description or ""))
		end
	end
end
PLUGIN:AddCommand("help", PLUGIN.Help, "", "Prints a list of commands or help specific to a command", "[Command name]")

lemon.plugin:Register(PLUGIN)