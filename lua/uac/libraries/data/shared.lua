-- This system should load/save data (using the appropriate system according to the configs)
-- Use a table/column-row system, each system/plugin can create a table and make it synchronizable/savable
-- Use types (similar to uac.command) to tell the type of each column and check the values being placed there
-- Mark a table/row as dirty for synchronization/save
-- The above should facilitate the connection between this system and sql

uac.data = uac.data or {
	list = {}
}

include("types.lua")

local data_list = uac.data.list

local KEY = {}
KEY.__index = KEY

function KEY:Name()
	return self.name
end

function KEY:Add(data, index)
	local pos, unique = self:Find(data)
	if pos ~= nil then
		return false
	end

	self.last = unique
	self.lookup[index] = unique
	self.lookup[unique] = index
	self.lookupcount = self.lookupcount + 1
	return true, unique
end

function KEY:Remove(index)
	if self.lookup[index] == nil then
		return false
	end

	local unique
	if type(index) == "number" then
		unique = self.lookup[index]
	else
		unique = index
		index = self.lookup[unique]
	end

	if self.last == unique then
		self.last = nil
	end

	self.lookup[index] = nil
	self.lookup[unique] = nil
	self.lookupcount = self.lookupcount - 1
	return true
end

function KEY:Revert()
	return self.last ~= nil and self:Remove(self.last)
end

function KEY:Find(data)
	local unique = self:Unique(data)
	return unique ~= nil and self.lookup[unique] or nil, unique
end

function KEY:Unique(data)
	local unique
	for i = 1, self.columnscount do
		local column = self.columns[i]
		local piece = data[column:Name()] or (column:IsOptional() and column:Default() or nil)
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

function KEY:Columns()
	return self.columns
end

function KEY:Column(index)
	return self.columns[index]
end

local TABLE = {}
TABLE.__index = TABLE

function TABLE:AddColumn(column)
	if self.datacount ~= 0 then
		error("table already has values")
	end

	self.columnscount = self.columnscount + 1
	column.index = self.columnscount
	self.columns[self.columnscount] = column
	self.columns[column:Name()] = column
	return self
end

function TABLE:RemoveColumn(name)
	if self.datacount ~= 0 then
		error("table already has values")
	end

	for i = 1, self.keyscount do
		if self.keys[i]:Column(name) ~= nil then
			error("column is part of a key")
		end
	end

	local column = self.columns[name]
	if column == nil then
		return false
	end

	table.remove(self.columns, column.index)
	self.columns[name] = nil
	self.columnscount = self.columnscount - 1
	return true
end

function TABLE:GetColumn(index)
	return self.columns[index]
end

function TABLE:AddRow(data)
	local index = self.datacount + 1
	for i = 1, self.keyscount do
		if not self.keys[i]:Add(data, index) then
			for k = i - 1, 1, -1 do
				self.keys[k]:Revert()
			end

			return self
		end
	end

	for i = 1, self.columnscount do
		local column = self.columns[i]
		local var = data[column:Name()]
		if not column:Set(index, var) then
			for k = i - 1, 1, -1 do
				self.columns[k]:Set(index, nil)
			end

			for k = 1, self.keyscount do
				self.keys[k]:Revert()
			end

			return self
		end
	end

	self.datacount = index
	return self
end

function TABLE:RemoveRow(data)
	for i = 1, self.keyscount do
		local index = self.keys[i]:Find(data)
		if index ~= nil then
			for k = 1, self.keyscount do
				self.keys[k]:Remove(index)
			end

			for k = 1, self.columnscount do
				self.columns[k]:Set(index, nil)
			end

			return true
		end
	end

	return false
end

function TABLE:GetRow(data)
	for i = 1, self.keyscount do
		local index = self.keys[i]:Find(data)
		if index ~= nil then
			local data = {}
			for k = 1, self.columnscount do
				data[k] = self.columns[k]:Get(index)
			end

			return data
		end
	end
end

function TABLE:SetPrimaryKey(tab)
	return self:AddKey("primary", tab)
end

function TABLE:AddKey(name, columns)
	assert(type(name) == "string", "key name is not a string")
	assert(#name ~= 0, "key name can't be empty")
	assert(type(columns) == "table", "key column list is not a table")
	assert(#columns ~= 0, "key column list can't be empty")

	for i = 1, #columns do
		local name = columns[i]
		local column = self:GetColumn(name)
		if column == nil then
			error("key has an inexistent column")
		elseif not column:CanIndex() then
			error("key has a non-indexable column")
		end

		columns[i] = column
		columns[name] = column
	end

	self.keyscount = self.keyscount + 1
	local key = setmetatable({
		name = name,
		columns = columns,
		columnscount = #columns,
		lookup = {},
		lookupcount = 0,
		index = self.keyscount
	}, KEY)
	self.keys[self.keyscount] = key
	self.keys[name] = key
	return self
end

function TABLE:RemoveKey(name)
	assert(type(name) == "string", "key name is not a string")
	assert(#name ~= 0, "key name can't be empty")

	local key = self.keys[name]
	if key == nil then
		return false
	end

	table.remove(self.keys, key.index)
	self.keys[name] = nil
	self.keyscount = self.keyscount - 1
	return true
end

function TABLE:GetSynchronizable()
	return self.synchronizable
end

function TABLE:SetSynchronizable(sync)
	self.synchronizable = sync
end

function TABLE:GetSavable()
	return self.savable
end

function TABLE:SetSavable(save)
	self.savable = save
end

function uac.data.AddTable(name)
	local table = setmetatable({
		name = name,
		columns = {},
		columnscount = 0,
		datacount = 0,
		synchronizable = false,
		savable = false,
		keys = {},
		keyscount = 0
	}, TABLE)
	data_list[name] = table
	return table
end

function uac.data.GetTable(name)
	return data_list[name]
end

function uac.data.RemoveTable(name)
	data_list[name] = nil
end