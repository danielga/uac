-- This system should load/save data (using the appropriate system according to the configs)
-- Use a table/column-row system, each system/plugin can create a table and make it synchronizable/savable
-- Use types (similar to uac.command) to tell the type of each column and check the values being placed there
-- Mark a table/row as dirty for synchronization/save
-- The above should facilitate the connection between this system and sql

uac.data = uac.data or {
	list = {}
}

local data_list = uac.data.list

local TABLE = {}
TABLE.__index = TABLE

function TABLE:AddColumn(name, type)
	if self.columnscount ~= 0 then
		return false
	end

	table.insert(columns, {
		name = name,
		type = type
	})
	self.columnscount = self.columnscount + 1
	return true
end

-- this is incomplete/incorrect
-- maybe do it in a SQL INSERT DUPLICATE style?
function TABLE:AddRow(...)
	local argsnum = select("#", ...)
	if argsnum ~= self.columnscount then
		return false
	end

	table.insert(self.data, {...})
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
		data = {},
		datacount = 0,
		synchronizable = false,
		savable = false
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