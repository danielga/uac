PLUGIN.Name = "Help"
PLUGIN.Description = "Prints the whole list of commands and their description (if it exists) on the console."
PLUGIN.Author = "MetaMan"

function PLUGIN:Help(ply, cmd)
	for command, data in pairs(uac.command.GetList()) do
		if cmd == nil or command:find(cmd, 1, true) then
			local usage = data:GetUsage()
			if usage == nil then
				print(("%-20s%s"):format(command, data:GetDescription() or ""))
			else
				print(("%-20s%s %s"):format(command, usage, data:GetDescription() or ""))
			end
		end
	end
end
PLUGIN:AddCommand("help", PLUGIN.Help)
	:SetState("shared")
	:SetAccess(ACCESS_ALL)
	:SetDescription("Prints a list of commands or help specific to a command")
	:AddParameter(uac.command.string(uac.command.optional))
