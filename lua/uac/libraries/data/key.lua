local KEY = {}
local KEY_INDEX = {}

function KEY:__index(key)
	local metafunction = KEY_INDEX[key]
	if metafunction ~= nil then
		return metafunction
	end

	local selfdata = rawget(self, key)
	if selfdata ~= nil then
		return selfdata
	end

	return KEY_INDEX.Find(self, key)
end

function KEY:__newindex(key, value)
	KEY_INDEX.Add(self, key, value)
end

function KEY_INDEX:GetName()
	return self.name
end

function KEY_INDEX:Add(index, data)
	local pos, unique = self:Find(data)
	if pos ~= nil then
		return false
	end

	self.lookup[index] = unique
	self.lookup[unique] = index
	return true, unique
end

function KEY_INDEX:Remove(index)
	if self.lookup[index] == nil then
		return false
	end

	local unique
	if isnumber(index) then
		unique = self.lookup[index]
	else
		unique = index
		index = self.lookup[unique]
	end

	self.lookup[index] = nil
	self.lookup[unique] = nil
	return true
end

function KEY_INDEX:Find(data)
	local unique = self:GetUnique(data)
	return unique ~= nil and self.lookup[unique] or nil, unique
end

function KEY_INDEX:GetUnique(data)
	local unique
	for i = 1, #self.columns do
		local column = self.columns[i]
		local piece = data[column:GetName()] or (column:IsOptional() and column:GetDefault() or nil)
		if piece == nil then
			return
		end

		piece = tostring(piece)
		if unique ~= nil then
			unique = unique .. "/" .. piece
		else
			unique = piece
		end
	end

	return unique
end

function KEY_INDEX:GetColumns()
	return self.columns
end

function KEY_INDEX:GetColumn(index)
	return self.columns[index]
end

return KEY
