uac.command = uac.command or {
	list = {},
	boolean = {
		Process = function(self, ply, arg)
			return tobool(arg)
		end,
		AutoComplete = function(self, ply, arg)
			if arg ~= nil then
				local autocomplete = {}
				if ("true"):find("^" .. arg, 1, true) then
					table.insert(autocomplete, "true")
				elseif ("false"):find("^" .. arg, 1, true) then
					table.insert(autocomplete, "false")
				end

				return autocomplete
			end

			return {"true", "false"}
		end,
		Usage = function(self)
			return "<true | false>"
		end
	},
	number = {
		Process = function(self, ply, arg)
			return tonumber(arg)
		end,
		AutoComplete = function(self, ply, arg)
			local num = tonumber(arg)
			return {num ~= nil and tostring(num) or ""}
		end,
		Usage = function(self)
			return "<number>"
		end
	},
	string = {
		Process = function(self, ply, arg)
			return arg
		end,
		AutoComplete = function(self, ply, arg)
			return {arg or ""}
		end,
		Usage = function(self)
			return "<string>"
		end
	},
	player = {
		Process = function(self, ply, arg)
			return uac.player.GetTargets(ply, arg)[1]
		end,
		AutoComplete = function(self, ply, arg)
			local targets, type = uac.player.GetTargets(ply, arg)
			if #targets == 0 then
				targets = player.GetAll()
				type = "all"
			end

			local autocomplete = {}
			for i = 1, #targets do
				table.insert(autocomplete, targets[i]:Nick())
			end

			return autocomplete
		end,
		Usage = function(self)
			return "<@teamname | #userid | steamid | playername>"
		end
	},
	players = {
		Process = function(self, ply, arg)
			return uac.player.GetTargets(ply, arg)
		end,
		AutoComplete = function(self, ply, arg)
			local targets, type = uac.player.GetTargets(ply, arg)
			if #targets == 0 then
				targets = player.GetAll()
				type = "all"
			end

			local autocomplete = {}
			for i = 1, #targets do
				table.insert(autocomplete, targets[i]:Nick())
			end

			return autocomplete
		end,
		Usage = function(self)
			return "<@teamname | #userid | steamid | playername>"
		end
	}
}

local command_list = uac.command.list

local COMMAND = {}
COMMAND.__index = COMMAND

function COMMAND:GetParameters()
	return self.parameters
end

function COMMAND:GetParameter(num)
	return self.parameters[num]
end

function COMMAND:AddParameter(param)
	table.insert(self.parameters, param)
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
		local res = parameters[i].Usage()
		table.insert(args, res)
	end

	return table.concat(args, ",")
end

local function GetSplitter(argstr)
	local pos = 1
	return function(all)
		if not pos then
			return
		end

		if all then
			local data = argstr:sub(pos)
			pos = nil
			return data
		end

		local match = argstr:match("[^,]+", pos)
		if match then
			match = match:Trim()
			if pos + #match < #argstr then
				pos = pos + #match + 1
			else
				pos = nil
			end
		end

		return match
	end
end

local function AutoCompleteBranch(tab, branches)
	if #tab == 0 then
		return branches
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
	local autocomplete = {}
	if argstr ~= nil then
		local splitter = GetSplitter(argstr)
		local parameters = self:GetParameters()
		for i = 1, #parameters do
			local data = splitter()
			local res = parameters[i].AutoComplete(nil, ply, data)
			autocomplete = AutoCompleteBranch(autocomplete, res)
		end
	else
		local parameters = self:GetParameters()
		for i = 1, #parameters do
			local res = parameters[i].AutoComplete(nil, ply)
			autocomplete = AutoCompleteBranch(autocomplete, res)
		end
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
		local res = parameters[i].Process(nil, ply, data)
		table.insert(args, res)
	end

	return pcall(self.callback, ply, unpack(args))
end

function uac.command.Split(str)
	local command = str:match("^([^%s]+)") or ""
	local argstr = str:sub(#command + 2)
	return command, (argstr ~= nil and #argstr > 0) and argstr or nil
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
	command = command:lower()
	local cmd = command_list[command]
	if cmd ~= nil then
		if ply:HasUserFlag(cmd.flag) then
			local did, err = cmd:Call(ply, argstr)
			if not did then
				ply:ChatText(Color(255, 0, 0, 255), "[UAC] ", Color(255, 255, 255, 255), "Error: '" .. err .. "'.")
				return false
			end

			return true
		else
			ply:ChatText(Color(255, 0, 0, 255), "[UAC] ", Color(255, 255, 255, 255), "Error: You need the '" .. cmd.flag .. "' flag in order to use this command.")
			return false
		end
	end

	local closest_command = nil
	local closest_distance = nil
	for com, _ in pairs(command_list) do
		local distance = uac.string.Levenshtein(command, com)
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