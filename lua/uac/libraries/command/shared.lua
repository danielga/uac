uac.command = uac.command or {
	list = {}
}

include("types.lua")

local command_list = uac.command.list
local COMMAND = include("command.lua")

function uac.command.Split(str)
	local command = string.match(str, "^([^%s]*)")
	local argstrpos = #command + 2
	return command, argstrpos - 1 <= #str and string.sub(str, argstrpos) or nil
end

function uac.command.Get(name)
	return command_list[name]
end

function uac.command.GetList()
	return command_list
end

function uac.command.Add(name, data)
	if istable(data) and getmetatable(data) == COMMAND then
		if istable(name) then
			for i = 1, #name do
				command_list[name[i]] = data
			end
		else
			command_list[name] = data
		end

		return data
	end

	local command = setmetatable({
		name = name,
		callback = data,
		permission = nil,
		description = nil,
		state = "server",
		parameters = {}
	}, COMMAND)

	if istable(name) then
		for i = 1, #name do
			command_list[name[i]] = command
		end
	else
		command_list[name] = command
	end

	return command
end

function uac.command.Remove(name)
	command_list[name] = nil
end

function uac.command.Run(ply, command, argstr)
	command = string.lower(command)

	local cmd = command_list[command]
	if cmd ~= nil then
		if ply:HasPermission(cmd.permission) then
			if CLIENT and cmd.state == "server" then
				net.Start("uac_command_execute")
				net.WriteString(command)

				local hasargs = argstr ~= nil
				net.WriteBool(hasargs)
				if hasargs then
					net.WriteString(argstr)
				end

				net.SendToServer()
				return true
			end

			local did, err = cmd:Call(ply, argstr)
			if not did then
				ply:ChatText(uac.color.red, "[UAC] ", uac.color.white, "Error: '" .. err .. "'.")
				return false
			end

			return true
		else
			ply:ChatText(uac.color.red, "[UAC] ", uac.color.white, "Error: You need the '" .. cmd.permission .. "' permission in order to use this command.")
			return false
		end
	end

	local closest_command = ""
	local closest_distance = math.huge
	for com, _ in pairs(command_list) do
		local distance = uac.string.DamerauLevenshteinDistance(command, com)
		if distance < closest_distance then
			closest_distance = distance
			closest_command = com
		end
	end

	if closest_distance <= 0.25 * #closest_command then
		ply:ChatText(uac.color.red, "[UAC] ", uac.color.white, "Did you mean '" .. closest_command .. "'?")
	end

	return false
end

function uac.command.GetAutoComplete(prefix, command, argstr, showusage)
	local ply = LocalPlayer()
	local candidates = {}
	for com, tab in pairs(uac.command.GetList()) do
		if string.sub(com, 1, #command) == command then
			if showusage then
				table.insert(candidates, string.format("%s%s%s%s", prefix, com, tab:GetUsage()))
			else
				local autocompletes = tab:GetAutoComplete(ply, argstr)
				for i = 1, #autocompletes do
					local space, ac = autocompletes[i] ~= "" and " " or "", autocompletes[i]
					table.insert(candidates, string.format("%s%s%s%s", prefix, com, space, ac))
				end
			end
		end
	end

	table.sort(candidates)
	return candidates
end

concommand.Add("uac", function(ply, command, args, argstr)
	if #args == 0 then
		return
	end

	command, argstr = uac.command.Split(argstr)
	return uac.command.Run(ply, command, argstr)
end, function(command, argstr)
	command, argstr = uac.command.Split(string.sub(argstr, 2))
	return uac.command.GetAutoComplete("uac ", command, argstr)
end)
