uac.command = uac.command or {
	list = {}
}

include("types.lua")

local command_list = uac.command.list

local COMMAND = {}
COMMAND.__index = COMMAND

function COMMAND:GetParameters()
	return self.parameters
end

function COMMAND:GetParameter(num)
	return self.parameters[num]
end

function COMMAND:AddParameter(parameter)
	if isfunction(parameter) then
		parameter = parameter() -- check result

	else
		assert(istable(parameter), "incorrect type for parameter") -- check parameter
	end

	table.insert(self.parameters, parameter)
	return self
end

function COMMAND:GetAccess()
	return self.flag
end

function COMMAND:SetAccess(access)
	self.flag = access
	return self
end

function COMMAND:GetDescription()
	return self.description
end

function COMMAND:SetDescription(desc)
	self.description = desc
	return self
end

function COMMAND:GetState()
	return self.state
end

function COMMAND:SetState(state)
	self.state = state
	return self
end

function COMMAND:GetUsage()
	local parameters = self:GetParameters()
	local numparams = #parameters
	if numparams == 0 then
		return
	end

	local args = {}
	for i = 1, numparams do
		local res = parameters[i]:Usage()
		table.insert(args, res)
	end

	return table.concat(args, ",")
end

local function ReturnNothing() end

local function GetSplitter(argstr)
	if argstr == nil then
		return ReturnNothing
	end

	local strlen = #argstr
	local pos = strlen > 0 and 1 or 0
	return function(all)
		if pos > strlen then
			return
		end

		if all then
			pos = strlen + 1
			return string.sub(argstr, pos)
		end

		local match = string.match(argstr, "[^,]*", pos)
		if match ~= nil then
			pos = pos + #match + 1
			match = string.Trim(match)
		end

		return match
	end
end

local function AutoCompleteBranch(tab, branches)
	if #tab == 0 then
		return branches
	elseif #branches == 0 then
		return tab
	end

	local autocomplete = {}
	for i = 1, #tab do
		for i = 1, #branches do
			table.insert(autocomplete, string.format("%s,%s", tab[i], branches[i]))
		end
	end

	return autocomplete
end

function COMMAND:GetAutoComplete(ply, argstr)
	local parameters = self:GetParameters()
	local splitter = GetSplitter(argstr)
	local autocomplete = {}
	for i = 1, #parameters do
		local data = splitter()
		if data == nil then
			break -- no more data, stop trying to autocomplete
		end

		local res = parameters[i]:AutoComplete(ply, data)
		autocomplete = AutoCompleteBranch(autocomplete, res)
	end

	if #autocomplete == 0 then
		table.insert(autocomplete, "")
	end

	return autocomplete
end

function COMMAND:Call(ply, argstr)
	if (self.state == "client" and SERVER) or (self.state == "server" and CLIENT) then
		return true
	end

	local splitter = GetSplitter(argstr)
	local parameters = self:GetParameters()
	local args = {}
	for i = 1, #parameters do
		local data = splitter()
		local result, err = parameters[i]:Process(ply, data)
		if result == nil then
			return false, err
		end

		table.insert(args, result)
	end

	return pcall(self.callback, ply, unpack(args))
end

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
		flag = nil,
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
		if ply:HasUserFlag(cmd.flag) then
			local did, err = cmd:Call(ply, argstr)
			if not did then
				ply:ChatText(uac.color.red, "[UAC] ", uac.color.white, "Error: '" .. err .. "'.")
				return false
			end

			return true
		else
			ply:ChatText(uac.color.red, "[UAC] ", uac.color.white, "Error: You need the '" .. cmd.flag .. "' flag in order to use this command.")
			return false
		end
	end

	local closest_command = ""
	local closest_distance = math.huge
	for com, _ in pairs(command_list) do
		local distance = uac.string.Levenshtein(command, com)
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