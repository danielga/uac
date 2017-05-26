uac.command.optional = {}

local BOOLEAN = {__index = {}}
local BOOLEAN_INDEX = BOOLEAN.__index

function BOOLEAN_INDEX:Type()
	return "boolean"
end

function BOOLEAN_INDEX:Check(val)
	return isbool(val)
end

function BOOLEAN_INDEX:IsOptional()
	return self.optional
end

function BOOLEAN_INDEX:GetDefault()
	return self.default
end

function BOOLEAN_INDEX:Process(ply, arg)
	if arg == nil then
		if not self:IsOptional() then
			return nil, "no value"
		end

		return self:GetDefault()
	end

	if arg ~= "true" and arg ~= "false" then
		return nil, "invalid value"
	end

	return arg == "true"
end

function BOOLEAN_INDEX:AutoComplete(ply, arg)
	local autocomplete = {}
	if arg ~= nil then
		if string.lower("true", "^" .. arg, 1, true) then
			table.insert(autocomplete, "true")
		elseif string.lower("false", "^" .. arg, 1, true) then
			table.insert(autocomplete, "false")
		end
	end

	return autocomplete
end

function BOOLEAN_INDEX:Usage()
	if self:IsOptional() then
		return "[true | false]"
	end

	return "<true | false>"
end

function uac.command.boolean(default)
	local parameter = setmetatable({optional = false}, BOOLEAN)
	if default == nil then
		return parameter
	end

	parameter.optional = true
	if default == uac.command.optional then
		parameter.default = uac.command.optional
		return parameter
	end

	assert(parameter:Check(default), "bad type for default boolean value")
	parameter.default = default
	return parameter
end

local NUMBER = {__index = {}}
local NUMBER_INDEX = NUMBER.__index

function NUMBER_INDEX:Type()
	return "number"
end

function NUMBER_INDEX:Check(val)
	if not isnumber(val) then
		return false, "bad type"
	end

	if self.min ~= nil and self.max ~= nil then
		return val >= self.min and val <= self.max, "bad value"
	end

	return true
end

function NUMBER_INDEX:IsOptional()
	return self.optional
end

function NUMBER_INDEX:GetDefault()
	return self.default
end

function NUMBER_INDEX:Process(ply, arg)
	arg = tonumber(arg)
	if arg == nil then
		if not self:IsOptional() then
			return nil, "no value"
		end

		return self:GetDefault()
	end

	if self.min ~= nil and self.max ~= nil then
		arg = math.Clamp(arg, self.min, self.max)
	end

	return arg
end

function NUMBER_INDEX:AutoComplete(ply, arg)
	local num = tonumber(arg)
	if num == nil then
		return {}
	end

	if self.min ~= nil and self.max ~= nil then
		num = math.Clamp(num, self.min, self.max)
	end

	return {tostring(num)}
end

function NUMBER_INDEX:Usage()
	if self:IsOptional() then
		return "[number]"
	end

	return "<number>"
end

function uac.command.number(left, right, default)
	local parameter = setmetatable({optional = false}, NUMBER)
	if left ~= nil then
		if right ~= nil then
			assert(parameter:Check(left) and parameter:Check(right), "bad types for min and max values")
			assert(left <= right, "bad numbers for min and max")
			parameter.min = left
			parameter.max = right

			if default ~= nil then
				parameter.optional = true

				local good, err = parameter:Check(default)
				assert(good, err .. " for default value with min and max")

				parameter.default = default
			else
				parameter.default = uac.command.optional
			end
		else
			parameter.optional = true

			if left ~= uac.command.optional then
				assert(parameter:Check(left), "bad type for default number value")
				parameter.default = left
			else
				parameter.default = uac.command.optional
			end
		end
	end

	return parameter
end

local STRING = {__index = {}}
local STRING_INDEX = STRING.__index

function STRING_INDEX:Type()
	return "string"
end

function STRING_INDEX:Check(val)
	return isstring(val)
end

function STRING_INDEX:IsOptional()
	return self.optional
end

function STRING_INDEX:GetDefault()
	return self.default
end

function STRING_INDEX:Process(ply, arg)
	if arg == nil then
		if not self:IsOptional() then
			return nil, "no value"
		end

		return self:GetDefault()
	end

	return arg
end

function STRING_INDEX:AutoComplete(ply, arg)
	return {arg}
end

function STRING_INDEX:Usage()
	if self:IsOptional() then
		return "[string]"
	end

	return "<string>"
end

function uac.command.string(default)
	local parameter = setmetatable({optional = false}, STRING)
	if default == nil then
		return parameter
	end

	parameter.optional = true
	if default == uac.command.optional then
		parameter.default = uac.command.optional
		return parameter
	end

	assert(parameter:Check(default), "bad type for default string value")
	parameter.default = default
	return parameter
end

local PLAYER = {__index = {}}
local PLAYER_INDEX = PLAYER.__index

function PLAYER_INDEX:Type()
	return "Player"
end

function PLAYER_INDEX:Check(val)
	return IsValid(val) and val:IsPlayer()
end

function PLAYER_INDEX:IsOptional()
	return self.optional
end

function PLAYER_INDEX:GetDefault()
end

function PLAYER_INDEX:Process(ply, arg)
	if arg == nil and not self:IsOptional() then
		return nil, "no value"
	end

	local target = uac.player.GetTargets(ply, arg)[1]
	if target == nil then
		return nil, "no target"
	end

	return target
end

function PLAYER_INDEX:AutoComplete(ply, arg)
	local autocomplete, type = uac.player.GetTargets(ply, arg)
	if #autocomplete == 0 and arg ~= nil and #arg == 0 then
		autocomplete = player.GetAll()
		type = "all"
	end

	for i = 1, #autocomplete do
		autocomplete[i] = autocomplete[i]:Nick()
	end

	return autocomplete
end

function PLAYER_INDEX:Usage()
	if self:IsOptional() then
		return "[@teamname | #userid | steamid | playername]"
	end

	return "<@teamname | #userid | steamid | playername>"
end

function uac.command.player(optional)
	local isoptional = optional == uac.command.optional
	assert(optional == nil or isoptional, "bad value for optional flag")
	return setmetatable({optional = isoptional, default = optional}, PLAYER)
end

local PLAYERS = {__index = {}}
local PLAYERS_INDEX = PLAYERS.__index

function PLAYERS_INDEX:Type()
	return "Player"
end

function PLAYERS_INDEX:Check(val)
	return IsValid(val) and val:IsPlayer()
end

function PLAYERS_INDEX:IsOptional()
	return self.optional
end

function PLAYERS_INDEX:GetDefault()
end

function PLAYERS_INDEX:Process(ply, arg)
	if arg == nil and not self:IsOptional() then
		return nil, "no value"
	end

	local targets = uac.player.GetTargets(ply, arg)
	if #targets == 0 then
		return nil, "no targets"
	end

	return targets
end

function PLAYERS_INDEX:AutoComplete(ply, arg)
	local autocomplete, type = uac.player.GetTargets(ply, arg)
	if #autocomplete == 0 and arg ~= nil and #arg == 0 then
		autocomplete = player.GetAll()
		type = "all"
	end

	for i = 1, #autocomplete do
		autocomplete[i] = autocomplete[i]:Nick()
	end

	return autocomplete
end

function PLAYERS_INDEX:Usage()
	if self:IsOptional() then
		return "[@teamname | #userid | steamid | playername]"
	end

	return "<@teamname | #userid | steamid | playername>"
end

function uac.command.players(optional)
	local isoptional = optional == uac.command.optional
	assert(optional == nil or isoptional, "bad value for optional flag")
	return setmetatable({optional = isoptional, default = optional}, PLAYERS)
end
