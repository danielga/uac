lemon.command = lemon.command or {}
local auto_complete = {}

function lemon.command:Get(name)
	return auto_complete[name]
end

function lemon.command:GetList()
	return auto_complete
end

function lemon.command:GetAutoComplete(command, args, showusage)
	args = args:match("^%s([^%s]+)")

	local candidates = {}

	for com, usage in pairs(auto_complete) do
		if not args or com:sub(1, args:len()) == args then
			if showusage and usage ~= "" then
				table.insert(candidates, ("%s %s %s"):format(command, com, usage))
			else
				table.insert(candidates, ("%s %s"):format(command, com))
			end
		end
	end

	return candidates
end

function lemon.command:Run(ply, command, arguments)
	net.Start("lemon_command_EXE")
		net.WriteString(command)
		local size = #arguments
		net.WriteUInt(size, 8)
		for i = 1, size do
			net.WriteString(arguments[i])
		end
	net.SendToServer()
end

concommand.Add("le", function(ply, command, args, str)
	if #args == 0 then
		return
	end

	command = args[1]
	args = {}
	for match in str:sub(#command + 2):gmatch("[^,]+") do
		match = match:gsub("^%s*(.-)%s*$", "%1")
		table.insert(args, match)
	end

	return lemon.command:Run(ply, command, args)
end, function(command, args)
	return lemon.command:GetAutoComplete(command, args)
end)

net.Receive("lemon_command_ACS", function(len)
	auto_complete = {}

	for i = 1, net.ReadUInt(8) do
		auto_complete[net.ReadString()] = net.ReadString()
	end
end)

net.Receive("lemon_command_ACA", function(len)
	auto_complete[net.ReadString()] = net.ReadString()
end)

net.Receive("lemon_command_ACR", function(len)
	auto_complete[net.ReadString()] = nil
end)