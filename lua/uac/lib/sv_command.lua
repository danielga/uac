uac.command = uac.command or {}
local command_list = {}

util.AddNetworkString("uac_command_EXE")
util.AddNetworkString("uac_command_ACA")
util.AddNetworkString("uac_command_ACR")
util.AddNetworkString("uac_command_ACS")

function uac.command.Add(name, func, flag, desc, usage)
	command_list[name] = {Function = func, Flag = flag, Description = desc, Usage = usage}
	net.Start("uac_command_ACA")
	net.WriteString(name)
	net.WriteString(usage or "")
	net.Broadcast(msg)
end

function uac.command.Remove(name)
	if not command_list[name] then return end

	command_list[name] = nil

	net.Start("uac_command_ACR")
	net.WriteString(name)
	net.Broadcast(msg)
end

function uac.command.Get(name)
	return command_list[name]
end

function uac.command.GetList()
	return command_list
end

function uac.command.Run(ply, command, arguments)
	command = command:lower()
	local command_table = command_list[command]
	if command_table ~= nil then
		if ply:HasUserFlag(command_table.Flag) then
			local did, err = pcall(command_table.Function, ply, command, arguments)
			if not did then
				ply:ChatText(Color(255, 0, 0, 255), "[UAC] ", Color(255, 255, 255, 255), "Error: '" .. err .. "'.")
				return false
			end

			return true
		else
			ply:ChatText(Color(255, 0, 0, 255), "[UAC] ", Color(255, 255, 255, 255), "Error: You need the '" .. command_table.Flag .. "' flag in order to use this command.")
			return false
		end
	end

	local closest_command = nil
	local closest_distance = nil
	for com, _ in pairs(command_list) do
		local distance = uac.string:Levenshtein(command, com)
		if closest_distance == nil or distance < closest_distance then
			closest_distance = distance
			closest_command = com
		end
	end

	if closest_distance and closest_distance <= 0.25 * #closest_command then
		ply:ChatText(Color(255, 0, 0, 255), "[UAC] ", Color(255, 255, 255, 255), "Did you mean '" .. closest_command .. "'?")
	end

	return false
end

net.Receive("uac_command_EXE", function(len, ply)
	local command = net.ReadString()
	local args = {}
	for i = 1, net.ReadUInt(8) do
		table.insert(args, net.ReadString())
	end
	uac.command.Run(ply, command, args)
end)

function uac.command.AutoCompleteSync(ply)
	local num = table.Count(command_list)

	net.Start("uac_command_ACS")
		net.WriteUInt(num, 8)
		for command, comdata in pairs(command_list) do
			net.WriteString(command)
			net.WriteString(comdata.Usage or "")
		end
	net.Send(ply)
end
hook.Add("PlayerInitialSpawn", "uac.command.AutoCompleteSync", function(ply)
	uac.command.AutoCompleteSync(ply)
end)