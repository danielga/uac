lemon.netmessage = lemon.netmessage or {}
lemon.net = lemon.netmessage

local netmessage_list = {}

local NETMSG_TYPE_END = 0
local NETMSG_TYPE_STOP = 1
local NETMSG_TYPE_STRING = 2
local NETMSG_TYPE_UNFINISHED_STRING = 3
local NETMSG_TYPE_EMPTY_STRING = 4
local NETMSG_TYPE_NUMBER = 5
local NETMSG_TYPE_VECTOR = 6
local NETMSG_TYPE_ANGLE = 7
local NETMSG_TYPE_BOOL = 8
local NETMSG_TYPE_ENTITY = 9
local NETMSG_TYPE_COLOR = 10
local NETMSG_TYPE_PHYSOBJ = 11

local translation = {
	["string"] = NETMSG_TYPE_STRING,
	["number"] = NETMSG_TYPE_NUMBER,
	["Vector"] = NETMSG_TYPE_VECTOR,
	["Angle"] = NETMSG_TYPE_ANGLE,
	["boolean"] = NETMSG_TYPE_BOOL,
	["Entity"] = NETMSG_TYPE_ENTITY,
	["Player"] = NETMSG_TYPE_ENTITY,
	["NPC"] = NETMSG_TYPE_ENTITY,
	["Weapon"] = NETMSG_TYPE_ENTITY,
	["table"] = NETMSG_TYPE_COLOR,
	["PhysObj"] = NETMSG_TYPE_PHYSOBJ
}

local sizes = {
	[NETMSG_TYPE_STRING] = function(value) return #value + 1 end,
	[NETMSG_TYPE_UNFINISHED_STRING] = function(value) return #value + 1 end,
	[NETMSG_TYPE_EMPTY_STRING] = function(value) return 1 end,
	[NETMSG_TYPE_NUMBER] = function(value) return 8 end,
	[NETMSG_TYPE_VECTOR] = function(value) return 12 end,
	[NETMSG_TYPE_ANGLE] = function(value) return 12 end,
	[NETMSG_TYPE_BOOL] = function(value) return 1 end,
	[NETMSG_TYPE_ENTITY] = function(value) return 4 end,
	[NETMSG_TYPE_COLOR] = function(value) return 4 end,
	[NETMSG_TYPE_PHYSOBJ] = function(value) return 3 end
}

if SERVER then
	util.AddNetworkString("lemon_netmsg")
end

local MSGMETA = {}
MSGMETA.__index = MSGMETA

function MSGMETA:Init()
	self.Read = 0
	self.Length = 0
	self.Data = nil
end

function MSGMETA:ReadValue(extra)
	if not self.Data then return end
	
	if self.Read < #self.Data then
		self.Read = self.Read + 1
		return self.Data[self.Read]
	end
end

function MSGMETA:SetValue(index, value)
	if not self.Data or not index then return end

	self.Data[index] = value
end

function MSGMETA:Reset()
	self.Read = 0
end

function MSGMETA:SetHeader(head)
	self.Header = head
end

function MSGMETA:ReadHeader()
	return self.Header
end

function MSGMETA:SetData(data)
	self.Data = data
end

function MSGMETA:GetData()
	return self.Data
end

function MSGMETA:SetLength(len)
	self.Length = len
end

function MSGMETA:GetLength()
	return self.Length
end

local function CreateMessage(data, head, len)
	local msg = {}
	setmetatable(msg, MSGMETA)

	msg:Init()
	msg:SetHeader(head)
	msg:SetData(data)
	msg:SetLength(len)

	return msg
end

local function OverrideNet(msg)
	for name, func in pairs(net) do
		if name == "ReadHeader" then
			net.BackupReadHeader = net.ReadHeader
			net.ReadHeader = function() return msg:ReadHeader() end
			continue
		end

		if name == "ReadTable" then
			net.BackupReadTable = net.ReadTable
			net.ReadTable = function() return msg:GetData() end
			continue
		end

		if name:sub(1, 4) == "Read" then
			net[("Backup%s"):format(name)] = net[name]
			net[name] = function(extra) return msg:ReadValue(extra) end
		end
	end
end

local function RepositionNet()
	for name, func in pairs(net) do
		if name:sub(1, 4) == "Read" then
			local oldread = ("Backup%s"):format(name)
			net[name] = net[oldread]
			net[oldread] = nil
		end
	end
end

local function IsColor(color) --SO MUCH CHECKING AND SO MUCH ACCURATE!
	return type(color) == "table" and table.Count(color) == 4 and color.r and color.g and color.b and color.a
end

net.Receive("lemon_netmsg", function(len, ply)
	local header = net.ReadInt(16)
	local netmsgtype = net.ReadUInt(8)
	local loops = 0
	len = 0

	if not netmessage_list[header] then netmessage_list[header] = {} end

	while netmsgtype ~= NETMSG_TYPE_END and netmsgtype ~= NETMSG_TYPE_STOP do
		loops = loops + 1
		if loops >= 65000 then
			print("[lemon] Net message system failed. Please warn an admin or superadmin.")
			break
		end

		if netmsgtype == NETMSG_TYPE_STRING then
			local str = net.ReadString()
			table.insert(netmessage_list[header], str)
			len = len + sizes[netmsgtype](str)
		elseif netmsgtype == NETMSG_TYPE_UNFINISHED_STRING then
			local index = #netmessage_list[header]
			if index == 0 then
				print("[lemon] Empty table for this net message. (ID " .. header .. ")")
				index = 1
			end

			local str = net.ReadString()
			if not netmessage_list[header][index] then
				print("[lemon] Unexistant string for this net message on index " .. index .. ". (ID " .. header .. ")")
				netmessage_list[header][index] = str
			else
				netmessage_list[header][index] = ("%s%s"):format(netmessage_list[header][index], str)
			end

			len = len + sizes[netmsgtype](str) - 1 -- Do not count the unfinished string zero terminator
		elseif netmsgtype == NETMSG_TYPE_EMPTY_STRING then
			local str = ""
			table.insert(netmessage_list[header], str)
			len = len + sizes[netmsgtype](str)
		elseif netmsgtype == NETMSG_TYPE_NUMBER then
			local num = net.ReadDouble()
			table.insert(netmessage_list[header], num)
			len = len + sizes[netmsgtype](num)
		elseif netmsgtype == NETMSG_TYPE_VECTOR then
			local vec = net.ReadVector()
			table.insert(netmessage_list[header], vec)
			len = len + sizes[netmsgtype](vec)
		elseif netmsgtype == NETMSG_TYPE_ANGLE then
			local ang = net.ReadAngle()
			table.insert(netmessage_list[header], ang)
			len = len + sizes[netmsgtype](ang)
		elseif netmsgtype == NETMSG_TYPE_BOOL then
			local bool = net.ReadBit() == 1
			table.insert(netmessage_list[header], bool)
			len = len + sizes[netmsgtype](bool)
		elseif netmsgtype == NETMSG_TYPE_ENTITY then
			local ent = net.ReadEntity()
			table.insert(netmessage_list[header], ent)
			len = len + sizes[netmsgtype](ent)
		elseif netmsgtype == NETMSG_TYPE_COLOR then
			local r, g, b, a = net.ReadUInt(8), net.ReadUInt(8), net.ReadUInt(8), net.ReadUInt(8)
			local col = Color(r, g, b, a)
			table.insert(netmessage_list[header], col)
			len = len + sizes[netmsgtype](col)
		elseif netmsgtype == NETMSG_TYPE_PHYSOBJ then
			local ent, phys = net.ReadEntity(), net.ReadUInt(8)
			phys = IsValid(ent) and ent:GetPhysicsObjectNum(phys) or NULL
			table.insert(netmessage_list[header], phys)
			len = len + sizes[netmsgtype](phys)
		else
			print("[lemon] Unhandled item type on the netmessage system (" .. netmsgtype .. ").")
		end

		netmsgtype = net.ReadUInt(8)
	end

	if netmsgtype == NETMSG_TYPE_END then
		local msg = CreateMessage(netmessage_list[header], header, len)
		netmessage_list[header] = nil
		OverrideNet(msg)
		--local func = net.Receivers[name:lower()]
		--if not func then return end
		--func(len, ply)
		net.Incoming(len, ply)
		RepositionNet()
	end
end)

local maxsize = 65535 - 10		-- Header size = 6? (2 bytes for message name ID and 4 for message length)
								-- Better waste more than less, in this case, or fuck shit up
function lemon.netmessage:Send(name, arg1, ...)
	name = util.NetworkStringToID(name)
	if name < 0 then
		print("[lemon] Net message system failed to find message ID. Please warn an admin or superadmin.")
		return
	end

	local tbl
	local recipient
	if SERVER then
		recipient = arg1
		if not type(recipient) == "table" and not (IsValid(recipient) and recipient:IsPlayer()) then
			error("[lemon] Uncapable to send net message because recipient was of incorrect type or invalid (type was " .. type(recipient) .. ")", 2)
		end

		tbl = {...}
	else
		tbl = {arg1, ...}
	end
	net.Start("lemon_netmsg")

		--net.WriteString(name)
		net.WriteInt(name, 16)
		--local namelen = #name
		local namelen = 2
		local size = namelen + 1
		local maxwrite = maxsize - size
		for i = 1, #tbl do
			local v = tbl[i]
			local itemtype = translation[type(v)]
			if itemtype == nil then continue end
			local itemsize = sizes[itemtype] and sizes[itemtype](v) or 0

			if size + itemsize >= maxwrite and itemtype ~= NETMSG_TYPE_STRING then
				net.WriteUInt(NETMSG_TYPE_STOP, 8)
				if SERVER then net.Send(recipient) else net.SendToServer() end

				net.Start("lemon_netmsg")
				--net.WriteString(name)
				net.WriteInt(name, 16)
				size = namelen + 1
			end

			if itemtype == NETMSG_TYPE_STRING then
				if itemsize == 1 then
					net.WriteUInt(NETMSG_TYPE_EMPTY_STRING, 8)
					size = size + itemsize
				elseif itemsize >= maxwrite then
					local len = 1
					while true do
						local newlen = math.min(len + maxwrite, itemsize - 1)
						str = v:sub(len, newlen)
						net.WriteUInt(NETMSG_TYPE_UNFINISHED_STRING, 8)
						net.WriteString(str)
						size = size + (newlen - len + 1)
						len = newlen + 1

						if len >= itemsize then
							break
						end

						net.WriteUInt(NETMSG_TYPE_STOP, 8)
						if SERVER then net.Send(recipient) else net.SendToServer() end

						net.Start("lemon_netmsg")
						--net.WriteString(name)
						net.WriteInt(name, 16)
						size = namelen + 1
					end
				else
					net.WriteUInt(NETMSG_TYPE_STRING, 8)
					net.WriteString(v)
					size = size + itemsize
				end
			elseif itemtype == NETMSG_TYPE_NUMBER then
				net.WriteUInt(NETMSG_TYPE_NUMBER, 8)
				net.WriteDouble(v)
				size = size + itemsize
			elseif itemtype == NETMSG_TYPE_VECTOR then
				net.WriteUInt(NETMSG_TYPE_VECTOR, 8)
				net.WriteVector(v)
				size = size + itemsize
			elseif itemtype == NETMSG_TYPE_ANGLE then
				net.WriteUInt(NETMSG_TYPE_ANGLE, 8)
				net.WriteAngle(v)
				size = size + itemsize
			elseif itemtype == NETMSG_TYPE_BOOL then
				net.WriteUInt(NETMSG_TYPE_BOOL, 8)
				net.WriteBit(v)
				size = size + itemsize
			elseif itemtype == NETMSG_TYPE_ENTITY then
				net.WriteUInt(NETMSG_TYPE_ENTITY, 8)
				net.WriteEntity(v)
				size = size + itemsize
			elseif itemtype == NETMSG_TYPE_COLOR then
				net.WriteUInt(NETMSG_TYPE_COLOR, 8)
				net.WriteUInt(math.Clamp(v.r, 0, 255), 8)
				net.WriteUInt(math.Clamp(v.g, 0, 255), 8)
				net.WriteUInt(math.Clamp(v.b, 0, 255), 8)
				net.WriteUInt(math.Clamp(v.a, 0, 255), 8)
				size = size + itemsize
			elseif itemtype == NETMSG_TYPE_PHYSOBJ then
				net.WriteUInt(NETMSG_TYPE_PHYSOBJ, 8)
				local parent = v:GetEntity()
				net.WriteEntity(parent)
				for i = 0, parent:GetPhysicsObjectCount() do
					local obj = parent:GetPhysicsObjectNum(i)
					if obj == v then
						net.WriteUInt(i, 8)
						size = size + itemsize
						break
					end
				end
			end
		end

		net.WriteUInt(NETMSG_TYPE_END, 8)
	if SERVER then net.Send(arg1) else net.SendToServer() end
end

if SERVER then
	function lemon.netmessage:SendOmit(name, recipient, ...)
		local send = {}
		if type(recipient) == "table" then
			local plys = player.GetAll()
			for i = 1, #plys do
				local ply = plys[i]
				if not table.HasValue(recipient, ply) then
					table.insert(send, ply)
				end
			end
		elseif IsValid(recipient) and recipient:IsPlayer() then
			local plys = player.GetAll()
			for i = 1, #plys do
				local ply = plys[i]
				if ply ~= recipient then
					table.insert(send, ply)
				end
			end
		else
			error("[lemon] Uncapable to send net message because recipient was of incorrect type (type was " .. rectype .. ")", 2)
		end

		return self:Send(name, send, ...)
	end

	function lemon.netmessage:Broadcast(name, ...)
		return self:Send(name, player.GetAll(), ...)
	end
end

if CLIENT then
	lemon.netmessage.SendToServer = lemon.netmessage.Send
	lemon.netmessage.Send = nil
end