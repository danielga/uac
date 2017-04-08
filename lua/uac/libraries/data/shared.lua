-- This system should load/save data (using the appropriate system according to the configs)
-- Use a table/column-row system, each system/plugin can create a table and make it synchronizable/savable
-- Use types (similar to uac.command) to tell the type of each column and check the values being placed there
-- Mark a table/row as dirty for synchronization/save
-- The above should facilitate the connection between this system and sql

AddCSLuaFile()
AddCSLuaFile("types.lua")
AddCSLuaFile("key.lua")
AddCSLuaFile("table.lua")

uac.data = uac.data or {
	list = {}
}

local data_list = uac.data.list
local TYPES = include("types.lua")
local KEY = include("key.lua")
local TABLE = include("table.lua")

local function AddColumn(table, column)
	local metatable = getmetatable(column)
	assert(metatable ~= nil and TYPES[metatable], "column object is not valid")

	local count = #table.columns + 1
	column.index = count
	table.columns[count] = column
	table.columns[column:GetName()] = column
end

local function AddKey(table, name, columns)
	assert(isstring(name), "key name is not a string")
	assert(#name ~= 0, "key name can't be empty")
	assert(istable(columns), "key column list is not a table")
	assert(#columns ~= 0, "key column list can't be empty")

	for i = 1, #columns do
		local colname = columns[i]
		local column = table:GetColumn(colname)

		assert(column ~= nil, "key has an inexistent column")
		assert(column:CanIndex(), "key has a non-indexable column")

		columns[i] = column
		columns[colname] = column
	end

	local count = #table.keys + 1
	local key = setmetatable({
		name = name,
		index = count,
		columns = columns,
		lookup = {}
	}, KEY)
	table.keys[count] = key
	table.keys[name] = key
end

function uac.data.AddTable(name, columns, keys)
	assert(isstring(name), "table name is not a string")
	assert(#name ~= 0, "table name can't be empty")
	assert(istable(columns), "columns is not a table")
	assert(#columns ~= 0, "columns table can't be empty")

	local tab = setmetatable({
		name = name,
		columns = {},
		synchronizable = false,
		savable = false,
		keys = {}
	}, TABLE)

	for i = 1, #columns do
		AddColumn(table, columns[i])
	end

	for name, columns in pairs(keys) do
		AddKey(table, name, columns)
	end

	data_list[name] = tab
	return tab
end

function uac.data.GetTable(name)
	return data_list[name]
end

function uac.data.RemoveTable(name)
	data_list[name] = nil
end
