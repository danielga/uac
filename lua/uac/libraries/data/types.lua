local rawget = rawget

uac.data.tiny = {}
uac.data.small = {}
uac.data.medium = {}
uac.data.normal = {}
uac.data.big = {}

uac.data.unsigned = {}

local BOOLEAN = {}
local BOOLEAN_INDEX = {}

function BOOLEAN:__index(key)
	local metafunction = BOOLEAN_INDEX[key]
	if metafunction ~= nil then
		return metafunction
	end

	local selfdata = rawget(self, key)
	if selfdata ~= nil then
		return selfdata
	end

	return BOOLEAN_INDEX.GetRow(self, key)
end

function BOOLEAN:__newindex(key, value)
	BOOLEAN_INDEX.SetRow(self, key, value)
end

function BOOLEAN_INDEX:GetType()
	return "boolean"
end

function BOOLEAN_INDEX:GetSQLType()
	return "BOOLEAN"
end

function BOOLEAN_INDEX:CanIndex()
	return false
end

function BOOLEAN_INDEX:CheckType(value)
	return isbool(value)
end

function BOOLEAN_INDEX:IsOptional()
	return self.default ~= nil
end

function BOOLEAN_INDEX:GetName()
	return self.name
end

function BOOLEAN_INDEX:GetDefault()
	return self.default
end

function BOOLEAN_INDEX:GetRow(row)
	if self.rows[row] == nil and self:IsOptional() then
		return self:GetDefault()
	end

	return self.rows[row]
end

function BOOLEAN_INDEX:SetRow(row, value)
	if value ~= nil and not self:CheckType(value) then
		return false
	end

	self.rows[row] = value
	return true
end

function BOOLEAN_INDEX:Translate(row)
	return self:GetRow(row) and "TRUE" or "FALSE"
end

function uac.data.boolean(name, ...)
	local parameter = {
		name = name,
		rows = {}
	}

	local argcount = select("#", ...)
	for i = 1, argcount do
		local arg = select(i, ...)
		if isbool(arg) then
			parameter.default = arg
		else
			error("bad type for default boolean value")
		end
	end

	return setmetatable(parameter, BOOLEAN)
end

local NUMBER = {}
local NUMBER_INDEX = {}

function NUMBER:__index(key)
	local metafunction = NUMBER_INDEX[key]
	if metafunction ~= nil then
		return metafunction
	end

	local selfdata = rawget(self, key)
	if selfdata ~= nil then
		return selfdata
	end

	return NUMBER_INDEX.GetRow(self, key)
end

function NUMBER:__newindex(key, value)
	NUMBER_INDEX.SetRow(self, key, value)
end

function NUMBER_INDEX:GetType()
	return "number"
end

function NUMBER_INDEX:GetSQLType()
	return self.type
end

function NUMBER_INDEX:CanIndex()
	return true
end

function NUMBER_INDEX:CheckType(value)
	return isnumber(value)
end

function NUMBER_INDEX:IsOptional()
	return self.default ~= nil
end

function NUMBER_INDEX:GetName()
	return self.name
end

function NUMBER_INDEX:GetDefault()
	return self.default
end

function NUMBER_INDEX:GetRow(row)
	if self.rows[row] == nil and self:IsOptional() then
		return self:GetDefault()
	end

	return self.rows[row]
end

function NUMBER_INDEX:SetRow(row, value)
	if value ~= nil and not self:CheckType(value) then
		return false
	end

	self.rows[row] = self.integer and math.floor(value) or value
	return true
end

NUMBER_INDEX.Translate = NUMBER_INDEX.GetRow

local NUMBER_TYPES = {
	[uac.data.tiny] = "FLOAT",
	[uac.data.small] = "FLOAT",
	[uac.data.medium] = "FLOAT",
	[uac.data.normal] = "FLOAT",
	[uac.data.big] = "DOUBLE"
}

function uac.data.number(name, ...)
	local parameter = {
		name = name,
		type = "FLOAT",
		integer = false,
		rows = {}
	}

	local argcount = select("#", ...)
	for i = 1, argcount do
		local arg = select(i, ...)
		if NUMBER_TYPES[arg] ~= nil then
			parameter.type = NUMBER_TYPES[arg]
		elseif isnumber(arg) then
			parameter.default = arg
		else
			error("bad type for default number value")
		end
	end

	return setmetatable(parameter, NUMBER)
end

local INTEGER_TYPES = {
	[uac.data.tiny] = "TINYINT",
	[uac.data.small] = "SMALLINT",
	[uac.data.medium] = "MEDIUMINT",
	[uac.data.normal] = "INT",
	[uac.data.big] = "BIGINT"
}

function uac.data.integer(name, ...)
	local parameter = {
		name = name,
		type = "INT",
		integer = true,
		unsigned = false,
		rows = {}
	}

	local argcount = select("#", ...)
	for i = 1, argcount do
		local arg = select(i, ...)
		if INTEGER_TYPES[arg] ~= nil then
			parameter.type = INTEGER_TYPES[arg]
		elseif arg == uac.data.unsigned then
			parameter.unsigned = true
		elseif isnumber(arg) then
			parameter.default = math.floor(arg)
		else
			error("bad type for default integer value")
		end
	end

	if parameter.unsigned then
		parameter.type = "UNSIGNED " .. parameter.type
	end

	return setmetatable(parameter, NUMBER)
end

local STRING = {}
local STRING_INDEX = {}

function STRING:__index(key)
	local metafunction = STRING_INDEX[key]
	if metafunction ~= nil then
		return metafunction
	end

	local selfdata = rawget(self, key)
	if selfdata ~= nil then
		return selfdata
	end

	return STRING_INDEX.GetRow(self, key)
end

function STRING:__newindex(key, value)
	STRING_INDEX.SetRow(self, key, value)
end

function STRING_INDEX:GetType()
	return "string"
end

function STRING_INDEX:GetSQLType()
	return self.type
end

function STRING_INDEX:CanIndex()
	return self.canindex
end

function STRING_INDEX:CheckType(value)
	return isstring(value)
end

function STRING_INDEX:IsOptional()
	return self.default ~= nil
end

function STRING_INDEX:GetName()
	return self.name
end

function STRING_INDEX:GetDefault()
	return self.default
end

function STRING_INDEX:GetRow(row)
	if self.rows[row] == nil and self:IsOptional() then
		return self:GetDefault()
	end

	return self.rows[row]
end

function STRING_INDEX:SetRow(row, value)
	if value ~= nil and not self:CheckType(value) then
		return false
	end

	self.rows[row] = value
	return true
end

STRING_INDEX.Translate = STRING_INDEX.GetRow

local STRING_TYPES = {
	[uac.data.tiny] = "TINYTEXT",
	[uac.data.small] = "TEXT",
	[uac.data.medium] = "MEDIUMTEXT",
	[uac.data.normal] = "MEDIUMTEXT",
	[uac.data.big] = "LONGTEXT"
}

function uac.data.string(name, ...)
	local parameter = {
		name = name,
		canindex = true,
		type = "TEXT",
		rows = {}
	}

	local argcount = select("#", ...)
	for i = 1, argcount do
		local arg = select(i, ...)
		if STRING_TYPES[arg] ~= nil then
			parameter.type = STRING_TYPES[arg]
		elseif isstring(arg) then
			parameter.default = arg
		else
			error("bad type for default string value")
		end
	end

	return setmetatable(parameter, STRING)
end

local BLOB_TYPES = {
	[uac.data.tiny] = "BLOB",
	[uac.data.small] = "BLOB",
	[uac.data.medium] = "MEDIUMBLOB",
	[uac.data.normal] = "MEDIUMBLOB",
	[uac.data.big] = "LONGBLOB"
}

function uac.data.blob(name, ...)
	local parameter = {
		name = name,
		canindex = false,
		type = "BLOB",
		rows = {}
	}

	local argcount = select("#", ...)
	for i = 1, argcount do
		local arg = select(i, ...)
		if BLOB_TYPES[arg] ~= nil then
			parameter.type = BLOB_TYPES[arg]
		elseif isstring(arg) then
			parameter.default = arg
		else
			error("bad type for default blob value")
		end
	end

	return setmetatable(parameter, STRING)
end

return {
	[BOOLEAN] = true,
	[NUMBER] = true,
	[STRING] = true
}
