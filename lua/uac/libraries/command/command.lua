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

function COMMAND:GetPermission()
	return self.permission
end

function COMMAND:SetPermission(permission)
	self.permission = permission
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
	local parameters = self.parameters
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
		for k = 1, #branches do
			table.insert(autocomplete, string.format("%s,%s", tab[i], branches[k]))
		end
	end

	return autocomplete
end

function COMMAND:GetAutoComplete(ply, argstr)
	local parameters = self.parameters
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
	local parameters = self.parameters
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

return COMMAND
