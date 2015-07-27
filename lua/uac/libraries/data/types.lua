uac.data.tiny = {}
uac.data.small = {}
uac.data.medium = {}
uac.data.normal = {}
uac.data.big = {}

uac.data.unsigned = {}

local function SetupParameter(parameter, type, types, ...)
	local isint = type == "integer"
	local argcount = select("#", ...)
	for i = 1, argcount do
		local arg = select(i, ...)
		local sqltype = types[arg]
		if sqltype ~= nil then
			parameter.type = sqltype
		elseif isint and arg == uac.data.unsigned then
			parameter.unsigned = true
		elseif parameter:Check(arg) then
			parameter.default = isint and math.floor(arg) or arg
		else
			error("bad type for default " .. type .. " value")
		end
	end

	if isint and parameter.unsigned then
		parameter.type = "UNSIGNED " .. parameter.type
	end

	return parameter
end

local BOOLEAN = {}
BOOLEAN.__index = BOOLEAN

function BOOLEAN:Type()
	return "boolean"
end

function BOOLEAN:SQLType()
	return "BOOLEAN"
end

function BOOLEAN:CanIndex()
	return false
end

function BOOLEAN:Check(value)
	return type(value) == "boolean"
end

function BOOLEAN:IsOptional()
	return self.default ~= nil
end

function BOOLEAN:Name()
	return self.name
end

function BOOLEAN:Default()
	return self.default
end

function BOOLEAN:Get(row)
	if self.rows[row] == nil and self:IsOptional() then
		return self:Default()
	end

	return self.rows[row]
end

function BOOLEAN:Set(row, value)
	if value ~= nil and not self:Check(value) then
		return false
	end

	self.rows[row] = value
	return true
end

function BOOLEAN:Translate(row)
	return self:Get(row) and "TRUE" or "FALSE"
end

function uac.data.boolean(name, extra)
	local parameter = setmetatable({
		name = name,
		rows = {}
	}, BOOLEAN)

	if extra ~= nil then
		assert(parameter:Check(extra), "bad type for default boolean value")
		parameter.default = extra
	end

	return parameter
end

local NUMBER = {}
NUMBER.__index = NUMBER

function NUMBER:Type()
	return "number"
end

function NUMBER:SQLType()
	return self.type
end

function NUMBER:CanIndex()
	return true
end

function NUMBER:Check(value)
	return type(value) == "number"
end

function NUMBER:IsOptional()
	return self.default ~= nil
end

function NUMBER:Name()
	return self.name
end

function NUMBER:Default()
	return self.default
end

function NUMBER:Get(row)
	if self.rows[row] == nil and self:IsOptional() then
		return self:Default()
	end

	return self.rows[row]
end

function NUMBER:Set(row, value)
	if value ~= nil and not self:Check(value) then
		return false
	end

	self.rows[row] = self.integer and math.floor(value) or value
	return true
end

NUMBER.Translate = NUMBER.Get

local NUMBER_TYPES = {
	[uac.data.tiny] = "FLOAT",
	[uac.data.small] = "FLOAT",
	[uac.data.medium] = "FLOAT",
	[uac.data.normal] = "FLOAT",
	[uac.data.big] = "DOUBLE"
}

function uac.data.number(name, ...)
	local parameter = setmetatable({
		name = name,
		type = "FLOAT",
		integer = false,
		rows = {}
	}, NUMBER)

	return SetupParameter(parameter, "number", NUMBER_TYPES, ...)
end

local INTEGER_TYPES = {
	[uac.data.tiny] = "TINYINT",
	[uac.data.small] = "SMALLINT",
	[uac.data.medium] = "MEDIUMINT",
	[uac.data.normal] = "INT",
	[uac.data.big] = "BIGINT"
}

function uac.data.integer(name, ...)
	local parameter = setmetatable({
		name = name,
		type = "INT",
		integer = true,
		unsigned = false,
		rows = {}
	}, NUMBER)

	return SetupParameter(parameter, "integer", INTEGER_TYPES, ...)
end

local STRING = {}
STRING.__index = STRING

function STRING:Type()
	return "string"
end

function STRING:SQLType()
	return self.type
end

function STRING:CanIndex()
	return true
end

function STRING:Check(value)
	return type(value) == "string"
end

function STRING:IsOptional()
	return self.default ~= nil
end

function STRING:Name()
	return self.name
end

function STRING:Default()
	return self.default
end

function STRING:Get(row)
	if self.rows[row] == nil and self:IsOptional() then
		return self:Default()
	end

	return self.rows[row]
end

function STRING:Set(row, value)
	if value ~= nil and not self:Check(value) then
		return false
	end

	self.rows[row] = value
	return true
end

STRING.Translate = STRING.Get

local STRING_TYPES = {
	[uac.data.tiny] = "TINYTEXT",
	[uac.data.small] = "TEXT",
	[uac.data.medium] = "MEDIUMTEXT",
	[uac.data.normal] = "MEDIUMTEXT",
	[uac.data.big] = "LONGTEXT"
}

function uac.data.string(name, ...)
	local parameter = setmetatable({
		name = name,
		type = "TEXT",
		rows = {}
	}, STRING)

	return SetupParameter(parameter, "string", STRING_TYPES, ...)
end

local BLOB = {}
BLOB.__index = BLOB

function BLOB:Type()
	return "string"
end

function BLOB:SQLType()
	return self.type
end

function BLOB:CanIndex()
	return false
end

function BLOB:Check(value)
	return type(value) == "string"
end

function BLOB:IsOptional()
	return self.default ~= nil
end

function BLOB:Name()
	return self.name
end

function BLOB:Default()
	return self.default
end

function BLOB:Get(row)
	if self.rows[row] == nil and self:IsOptional() then
		return self:Default()
	end

	return self.rows[row]
end

function BLOB:Set(row, value)
	if value ~= nil and not self:Check(value) then
		return false
	end

	self.rows[row] = value
	return true
end

BLOB.Translate = BLOB.Get

local BLOB_TYPES = {
	[uac.data.tiny] = "BLOB",
	[uac.data.small] = "BLOB",
	[uac.data.medium] = "MEDIUMBLOB",
	[uac.data.normal] = "MEDIUMBLOB",
	[uac.data.big] = "LONGBLOB"
}

function uac.data.blob(name, ...)
	local parameter = setmetatable({
		name = name,
		type = "BLOB",
		rows = {}
	}, BLOB)

	return SetupParameter(parameter, "blob", BLOB_TYPES, ...)
end