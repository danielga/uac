lemon.usermessage = lemon.usermessage or {}

local function IsColor(color) --SO MUCH CHECKING AND SO MUCH ACCURATE!
	return type(color) == "table" and table.Count(color) == 4 and color.r and color.g and color.b and color.a
end

local function GetItemTypeAndSize(item)
	local itemtype = type(item)

	if itemtype == "string" then
		local strlen = string.len(item)
		if strlen == 1 then
			return itemtype, 1
		else
			return itemtype, strlen + 1
		end
	elseif itemtype == "number" then
		return itemtype, 4
	elseif itemtype == "Vector" then
		return itemtype, 12
	elseif itemtype == "Angle" then
		return itemtype, 12
	elseif itemtype == "boolean" then
		return itemtype, 1
	elseif itemtype == "Entity" or itemtype == "Player" or itemtype == "NPC" or itemtype == "Weapon" then
		return itemtype, 2
	elseif itemtype == "PhysObj" then
		return itemtype, 3
	elseif IsColor(item) then
		return itemtype, 4
	end

	return itemtype, 0
end

local maxsize = 245
local function PrepareTable(name, ...)
	local tbl = {...}
	local newtbl = {}
	local index = 1
	local namelen = string.len(name) + 1

	newtbl[index] = {}
	table.insert(newtbl[index], name)
	local size = 8 + namelen

	for k, v in ipairs(tbl) do
		local itemtype, itemsize = GetItemTypeAndSize(v)

		if size >= maxsize or (size + itemsize > maxsize and itemtype ~= "string") then
			table.insert(newtbl[index], UMSG_TYPE_STOP)
			index = index + 1
			newtbl[index] = {}
			table.insert(newtbl[index], name)
			size = 8 + namelen
		end

		local remain = maxsize - size
		size = size + itemsize + 1

		if itemtype == "string" then
			if itemsize == 1 then
				if v ~= "" then
					table.insert(newtbl[index], UMSG_TYPE_CHAR)
					table.insert(newtbl[index], string.byte(v))
				else
					table.insert(newtbl[index], UMSG_TYPE_EMPTY_STRING)
				end
			elseif size - 1 > maxsize then
				local len = remain
				local str = string.sub(v, 1, len)
				table.insert(newtbl[index], UMSG_TYPE_STRING)
				table.insert(newtbl[index], str)

				while true do
					if len >= itemsize - 1 then
						break
					end

					table.insert(newtbl[index], UMSG_TYPE_STOP)
					index = index + 1
					newtbl[index] = {}
					table.insert(newtbl[index], name)
					size = 8 + namelen

					local templen = math.Clamp((len + 1 + maxsize) - size, 0, itemsize - 1)
					str = string.sub(v, len + 1, templen)
					len = templen
					table.insert(newtbl[index], UMSG_TYPE_UNFINISHED_STRING)
					table.insert(newtbl[index], str)
					local _, tempsize = GetItemTypeAndSize(str)
					size = size + tempsize
				end
			else
				table.insert(newtbl[index], UMSG_TYPE_STRING)
				table.insert(newtbl[index], v)
			end
		elseif itemtype == "number" then
			table.insert(newtbl[index], UMSG_TYPE_NUMBER)
			table.insert(newtbl[index], v)
		elseif itemtype == "Vector" then
			table.insert(newtbl[index], UMSG_TYPE_VECTOR)
			table.insert(newtbl[index], v)
		elseif itemtype == "Angle" then
			table.insert(newtbl[index], UMSG_TYPE_ANGLE)
			table.insert(newtbl[index], v)
		elseif itemtype == "boolean" then
			table.insert(newtbl[index], UMSG_TYPE_BOOL)
			table.insert(newtbl[index], v)
		elseif itemtype == "Entity" or itemtype == "Player" or itemtype == "NPC" or itemtype == "Weapon" then
			table.insert(newtbl[index], UMSG_TYPE_ENTITY)
			table.insert(newtbl[index], v)
		elseif itemtype == "PhysObj" then
			table.insert(newtbl[index], UMSG_TYPE_PHYSOBJ)
			table.insert(newtbl[index], v)
		elseif IsColor(v) then
			table.insert(newtbl[index], UMSG_TYPE_COLOR)
			table.insert(newtbl[index], v)
			size = size + itemsize + 1
		end
	end
	
	table.insert(newtbl[index], UMSG_TYPE_END)
	return newtbl
end

function lemon.usermessage:Send(name, recipient, ...)
	local tbl = PrepareTable(name, ...)

	if type(recipient) == "table" then
		local rec = RecipientFilter()
		for _, ply in pairs(recipient) do
			rec:AddPlayer(ply)
		end
		recipient = rec
	elseif recipient == nil then
		recipient = RecipientFilter()
		rec:AddAllPlayers()
	end

	for k, v in ipairs(tbl) do
		umsg.Start("le_umsg", recipient)
			umsg.String(v[1])
			local i = 2
			while true do
				local itemtype = v[i]
				umsg.Char(itemtype)
				i = i + 1

				if itemtype == UMSG_TYPE_STRING or itemtype == UMSG_TYPE_UNFINISHED_STRING then
					umsg.String(v[i])
				elseif itemtype == UMSG_TYPE_EMPTY_STRING then
					i = i - 1
				elseif itemtype == UMSG_TYPE_CHAR then
					umsg.Char(v[i] - 128)
				elseif itemtype == UMSG_TYPE_NUMBER then
					umsg.Float(v[i])
				elseif itemtype == UMSG_TYPE_VECTOR then
					umsg.Vector(v[i])
				elseif itemtype == UMSG_TYPE_ANGLE then
					umsg.Angle(v[i])
				elseif itemtype == UMSG_TYPE_BOOL then
					umsg.Bool(v[i])
				elseif itemtype == UMSG_TYPE_ENTITY then
					umsg.Entity(v[i])
				elseif itemtype == UMSG_TYPE_COLOR then
					umsg.Char(math.Clamp(v[i].r, 0, 255) - 128)
					umsg.Char(math.Clamp(v[i].g, 0, 255) - 128)
					umsg.Char(math.Clamp(v[i].b, 0, 255) - 128)
					umsg.Char(math.Clamp(v[i].a, 0, 255) - 128)
				elseif itemtype == UMSG_TYPE_PHYSOBJ then
					local parent = v:GetEntity()
					umsg.Entity(parent)
					for i = 0, parent:GetPhysicsObjectCount() do
						local obj = parent:GetPhysicsObjectNum(i)
						if obj == v then
							umsg.Char(i)
							break
						end
					end
				elseif itemtype == UMSG_TYPE_STOP or itemtype == UMSG_TYPE_END then
					break
				end

				i = i + 1
			end
		umsg.End()
	end

	return true
end

function lemon.usermessage:SendGlobal(name, ...)
	local recipient = RecipientFilter()
	recipient:AddAllPlayers()
	self:Send(name, recipient, ...)
end