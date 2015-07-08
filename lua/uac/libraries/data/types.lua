local BOOLEAN = {}
BOOLEAN.__index = BOOLEAN

function BOOLEAN:Type()
	return "boolean"
end

function BOOLEAN:Check(value)
	return isbool(value)
end

function BOOLEAN:IsOptional()
	return self.optional
end

function BOOLEAN:GetName()
	return self.name
end

function BOOLEAN:GetDefault()
	return self.default
end

function BOOLEAN:GetValue()
	return self.value
end

function BOOLEAN:SetValue(value)
	if not self:Check(value) then
		return false
	end

	self.value = value
	return true
end

function BOOLEAN:Translate()
	return self:GetValue() and "TRUE" or "FALSE"
end

function uac.data.boolean(default)
	local parameter = setmetatable({optional = false}, BOOLEAN)
	if default == nil then
		return parameter
	end

	parameter.optional = true

	assert(parameter:Check(default), "bad type for default boolean value")
	parameter.default = default
	return parameter
end