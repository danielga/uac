PLUGIN.Name = "Help"
PLUGIN.Description = "Prints the whole list of commands and their description (if it exists) on the console."
PLUGIN.Author = "MetaMan"

function PLUGIN:Help(ply, cmd)
	for command, data in pairs(uac.command.GetList()) do
		if cmd == uac.command.optional or string.find(command, cmd, 1, true) then
			local usage = data:GetUsage()
			if usage == nil then
				print(string.format("%-20s%s", command, data:GetDescription() or ""))
			else
				print(string.format("%-20s%s %s", command, usage, data:GetDescription() or ""))
			end
		end
	end
end
PLUGIN:AddCommand("help", PLUGIN.Help)
	:SetState("self")
	:SetDescription("Prints a list of commands or help specific to a command")
	:AddParameter(uac.command.string(uac.command.optional))
