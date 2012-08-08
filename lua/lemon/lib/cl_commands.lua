lemon.command = lemon.command or {}
lemon.command.AutoComplete = lemon.command.AutoComplete or {}

function lemon.command:GetAutoComplete(command, args, showusage)
	args = string.Split(args, " ")
	args = args[2]

	local candidates = {}

	for com, usage in pairs(self.AutoComplete) do
		if string.sub(com, 1, string.len(args)) == args then
			if usage ~= "" and showusage then
				table.insert(candidates, string.format("%s %s %s", command, usage, com))
			else
				table.insert(candidates, string.format("%s %s", command, com))
			end
		end
	end

	return candidates
end

function lemon.command:Run(ply, command, arguments)
	RunConsoleCommand("_le", command, unpack(arguments))
end

concommand.Add("le", function(ply, command, arguments)
	if #arguments == 0 then
		return
	end

	command = arguments[1]
	table.remove(arguments, 1)
	return lemon.command:Run(ply, command, arguments)
end, function(command, args)
	return lemon.command:GetAutoComplete(command, args)
end)

usermessage.Hook("le_com_ACS", function(data)
	lemon.command.AutoComplete = {}

	for i = 1, #data.Items / 2 do
		lemon.command.AutoComplete[data.Items[i * 2 - 1]] = data.Items[i * 2]
	end
end)

usermessage.Hook("le_com_ACA", function(data)
	lemon.command.AutoComplete[data:ReadString()] = data:ReadString()
end)

usermessage.Hook("le_com_ACR", function(data)
	lemon.command.AutoComplete[data:ReadString()] = nil
end)