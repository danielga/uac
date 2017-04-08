local TABLE = {__index = {}}
local TABLE_INDEX = TABLE.__index

function TABLE_INDEX:GetColumn(index)
	return self.columns[index]
end

function TABLE_INDEX:AddRow(data)
	for i = 1, #self.keys do
		if not self.keys[i]:Add(index, data) then
			for k = i - 1, 1, -1 do
				self.keys[k]:Remove(index)
			end

			return self
		end
	end

	for i = 1, #self.columns do
		local column = self.columns[i]
		local var = data[column:GetName()]
		if not column:SetRow(index, var) then
			for k = i - 1, 1, -1 do
				self.columns[k]:SetRow(index, nil)
			end

			for k = 1, #self.keys do
				self.keys[k]:Remove(index)
			end

			return self
		end
	end

	return self
end

function TABLE_INDEX:RemoveRow(data)
	for i = 1, #self.keys do
		local index = self.keys[i]:Find(data)
		if index ~= nil then
			for k = 1, #self.keys do
				self.keys[k]:Remove(index)
			end

			for k = 1, #self.columns do
				self.columns[k]:SetRow(index, nil)
			end

			return true
		end
	end

	return false
end

function TABLE_INDEX:GetRow(data)
	for i = 1, #self.keys do
		local index = self.keys[i]:Find(data)
		if index ~= nil then
			local data = {}
			for k = 1, #self.columns do
				data[k] = self.columns[k]:GetRow(index)
			end

			return data
		end
	end
end

function TABLE_INDEX:IsSynchronizable()
	return self.synchronizable
end

function TABLE_INDEX:SetSynchronizable(sync)
	self.synchronizable = sync
end

function TABLE_INDEX:IsSavable()
	return self.savable
end

function TABLE_INDEX:SetSavable(save)
	self.savable = save
end

return TABLE
