lemon.config = lemon.config or {}
lemon.config.List = lemon.config.List or {}

function lemon.config:SetValue(name, value)
	self.List[name] = value
end

function lemon.config:SetValues(valuestable)
	for name, value in pairs(valuestable) do
		self.List[name] = value
	end
end

function lemon.config:GetValue(name)
	return self.List[name]
end

function lemon.config:GetBool(name)
	return tobool(self:GetValue(name))
end

function lemon.config:GetString(name)
	return tostring(self:GetValue(name))
end

function lemon.config:GetNumber(name)
	return tonumber(self:GetValue(name))
end

function lemon.config:GetValues()
	return self.List
end

function lemon.config:DeleteValue(name)
	self:SetValue(name, nil)
end

function lemon.config:Reset()
	for name, value in pairs(self.List) do
		self:DeleteValue(name)
	end
end

function lemon.config:SetValuesFromFile(filepath)
	local text = file.Read(filepath, true)
	local keyvalues = lemon.string:ParseINIData(text)
	if keyvalues then
		table.Merge(self.List, keyvalues)
	end
end

function lemon.config:SaveValuesToFile(filepath)
	local keyvalues = lemon.string:CreateINIData(self.List)
	if keyvalues then
		file.Write(filepath, keyvalues)
	end
end