lemon.netmessage = lemon.netmessage or {}
lemon.net = lemon.netmessage

local NETMSG_MODE_READ = 1
local NETMSG_MODE_WRITE = 2

local NETMSG_TYPE_END = 0
local NETMSG_TYPE_STRING = 1
local NETMSG_TYPE_NUMBER = 2
local NETMSG_TYPE_VECTOR = 3
local NETMSG_TYPE_ANGLE = 4
local NETMSG_TYPE_BOOL = 5
local NETMSG_TYPE_ENTITY = 6
local NETMSG_TYPE_COLOR = 7
local NETMSG_TYPE_PHYSOBJ = 8

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

local function WriteString(str)
	net.WriteUInt(NETMSG_TYPE_STRING, 8)
	net.WriteString(str)
end

local function WriteNumber(num, extra)
	net.WriteUInt(NETMSG_TYPE_NUMBER, 8)
	if extra == 64 then --try to implement floats
		net.WriteBit(signed)
		net.WriteUInt(extra, 7)
		net.WriteDouble(num)
	else
		local signed = num < 0
		if signed then
			net.WriteBit(signed)
			net.WriteUInt(extra, 7)
			net.WriteInt(num, extra)
		else
			net.WriteBit(signed)
			net.WriteUInt(extra, 7)
			net.WriteUInt(num, extra)
		end
	end
end

local function WriteBoolean(bool)
	net.WriteUInt(NETMSG_TYPE_BOOL, 8)
	net.WriteBit(bool)
end

local function WriteVector(vec)
	net.WriteUInt(NETMSG_TYPE_VECTOR, 8)
	net.WriteFloat(vec.x)
	net.WriteFloat(vec.y)
	net.WriteFloat(vec.z)
end

local function WriteAngle(ang)
	net.WriteUInt(NETMSG_TYPE_ANGLE, 8)
	net.WriteFloat(ang.y)
	net.WriteFloat(ang.p)
	net.WriteFloat(ang.r)
end

local function WriteColor(col)
	net.WriteUInt(NETMSG_TYPE_COLOR, 8)
	net.WriteUInt(col.r, 8)
	net.WriteUInt(col.g, 8)
	net.WriteUInt(col.b, 8)
	net.WriteUInt(col.a, 8)
end

local function WriteEntity(ent)
	net.WriteUInt(NETMSG_TYPE_ENTITY, 8)
	net.WriteEntity(ent)
end

local function WritePhysObj(phys)
	net.WriteUInt(NETMSG_TYPE_PHYSOBJ, 8)
	local parent = phys:GetEntity()
	net.WriteEntity(parent)
	for i = 0, parent:GetPhysicsObjectCount() do
		local obj = parent:GetPhysicsObjectNum(i)
		if obj == phys then
			net.WriteUInt(i, 8)
			return
		end
	end

	net.WriteUInt(0, 8)
end

local writer = {
	[NETMSG_TYPE_STRING] = function(value) return WriteString, (1 + #value + 1) * 8, nil end,
	[NETMSG_TYPE_NUMBER] = function(value)
		local signed = value < 0
		if (signed and value >= –32768 and value <= 32767) or (not signed and value >= 0 and value <= 65535) then
			return WriteNumber, (1 + 1 + 1) * 8, 8
		elseif (signed and value >= –32768 and value <= 32767) or (not signed and value >= 0 and value <= 65535) then
			return WriteNumber, (1 + 1 + 2) * 8, 16
		elseif (signed and value >= –2147483648 and value <= 2147483647) or (not signed and value >= 0 and value <= 4294967295) then
			return WriteNumber, (1 + 1 + 4) * 8, 32
		else
			return WriteNumber, (1 + 1 + 8) * 8, nil --try to implement floats
		end
	end,
	[NETMSG_TYPE_VECTOR] = function(value) return WriteVector, (1 + 12) * 8, nil end,
	[NETMSG_TYPE_ANGLE] = function(value) return WriteAngle, (1 + 12) * 8, nil end,
	[NETMSG_TYPE_BOOL] = function(value) return WriteBoolean, 1 * 8 + 1, nil end,
	[NETMSG_TYPE_ENTITY] = function(value) return WriteEntity, (1 + 4) * 8, nil end,
	[NETMSG_TYPE_COLOR] = function(value) return WriteColor, (1 + 4) * 8, nil end,
	[NETMSG_TYPE_PHYSOBJ] = function(value) return WritePhysObj, (1 + 4 + 1) * 8, nil end
}

local readers = {
	[NETMSG_TYPE_STRING] = function() local str = net.ReadString() return str, (1 + #str + 1) * 8 end,
	[NETMSG_TYPE_NUMBER] = function()
		local signed = net.ReadBit() == 1
		local bits = net.ReadUInt(7) --try to implement floats
		return bits == 64 and net.ReadDouble() or (signed and net.ReadInt(bits) or net.ReadUInt(bits)), (1 + 1) * 8 + bits
	end,
	[NETMSG_TYPE_VECTOR] = function() return Vector(net.ReadFloat(), net.ReadFloat(), net.ReadFloat()), (1 + 12) * 8, nil end,
	[NETMSG_TYPE_ANGLE] = function() return Angle(net.ReadFloat(), net.ReadFloat(), net.ReadFloat()), (1 + 12) * 8, nil end,
	[NETMSG_TYPE_BOOL] = function() return net.ReadBit(), 1 * 8 + 1, nil end,
	[NETMSG_TYPE_ENTITY] = function() return net.ReadEntity(), (1 + 4) * 8, nil end,
	[NETMSG_TYPE_COLOR] = function() return Color(net.ReadUInt(8), net.ReadUInt(8), net.ReadUInt(8), net.ReadUInt(8)), (1 + 16) * 8, nil end,
	[NETMSG_TYPE_PHYSOBJ] = function()
		local ent, phys = net.ReadEntity(), net.ReadUInt(8)
		return IsValid(ent) and ent:GetPhysicsObjectNum(phys) or NULL, (1 + 4 + 1) * 8, nil
	end
}

if SERVER then
	util.AddNetworkString("lemon_netmessage")
end

local MSGMETA = {}
MSGMETA.__index = MSGMETA

function MSGMETA:Read()
	if self.Mode == NETMSG_MODE_WRITE then
		error("[lemon] Trying to read from a netmessage writer.")
	end
	
	if self.Offset < #self.Data then
		self.Offset = self.Offset + 1
		return self.Data[self.Offset]
	end
end

local maxsize = 65535 * 8 --[[max message size]] - 2 * 2 * 8 --[[2 headers size]]
function MSGMETA:Write(value)
	if self.Mode == NETMSG_MODE_READ then
		error("[lemon] Trying to write to a netmessage reader.")
	end

	local translated = translation[type(value)]
	local func, size, extra = writer[translated](value)
	if self.Size + size > maxsize then
		error("[lemon] Trying to write more than " .. maxsize .. " bits to a netmessage.")
	end

	self.Offset = self.Offset + 1
	self.Data[self.Offset] = {func = func, value = value, extra = extra}
	self.Size = self.Size + size
end

function MSGMETA:Readable()
	return self.Mode == NETMSG_MODE_READ
end

function MSGMETA:Writeable()
	return self.Mode == NETMSG_MODE_WRITE
end

function MSGMETA:SetOffset(off)
	self.Offset = off
end

function MSGMETA:GetSize()
	return self.Size
end

function MSGMETA:GetName()
	return self.Name
end

function MSGMETA:GetHeader()
	return self.Header
end

function lemon.netmessage:New(name)
	local header = util.NetworkStringToID(name)
	if header < 0 then
		error("[lemon] Net message system failed to find message ID.")
	end

	local msg = {}
	setmetatable(msg, MSGMETA)

	msg.Name = name
	msg.Header = header
	msg.Offset = 0
	msg.Mode = NETMSG_MODE_WRITE
	msg.Size = 0
	msg.Data = {}

	return msg
end

local function IsColor(color) --SO MUCH CHECKING AND SO MUCH ACCURATE!
	return type(color) == "table" and table.Count(color) == 4 and color.r and color.g and color.b and color.a
end

net.Receive("lemon_netmessage", function(len, ply)
	local name = util.NetworkIDToString(net.ReadUInt(16))
	if not name then return end
	name = name:lower()

	local data = {}

	local netmsgtype = net.ReadUInt(8)
	while netmsgtype ~= NETMSG_TYPE_END do
		local value, size = readers[netmsgtype]()
		table.insert(data, value)
		len = len + size

		netmsgtype = net.ReadUInt(8)
	end

	local receiver = net.Receivers[name]
	if not receiver then return end

	local msg = {}
	setmetatable(msg, MSGMETA)

	msg.Name = name
	msg.Header = header
	msg.Offset = 0
	msg.Mode = NETMSG_MODE_READ
	msg.Size = len
	msg.Data = data

	receiver(msg, ply)
end)

function lemon.netmessage:Send(msg, recipient)
	if getmetatable(msg) ~= MSGMETA then
		error("[lemon] Invalid message type.")
	end

	if not msg:Writeable() then
		error("[lemon] Trying to send a read-only message.")
	end

	local rectype = type(recipient)
	if rectype ~= "Player" and rectype ~= "table" then
		error("[lemon] Invalid recipient type.")
	end

	net.Start("lemon_netmessage")
		net.WriteUInt(msg.Header, 16)

		for i = 1, #msg.Data do
			local data = msg.Data[i]
			data.func(data.value, data.extra)
		end

		net.WriteUInt(NETMSG_TYPE_END, 8)
	if SERVER then net.Send(recipient) else net.SendToServer() end
end

if SERVER then
	function lemon.netmessage:SendOmit(msg, recipient)
		local send = {}

		local rectype = type(recipient)
		if rectype == "table" then
			local plys = player.GetAll()
			for i = 1, #plys do
				local ply = plys[i]
				if not table.HasValue(recipient, ply) then
					table.insert(send, ply)
				end
			end
		elseif rectype == "Player" and IsValid(recipient) then
			local plys = player.GetAll()
			for i = 1, #plys do
				local ply = plys[i]
				if ply ~= recipient then
					table.insert(send, ply)
				end
			end
		end

		return self:Send(msg, send)
	end

	function lemon.netmessage:Broadcast(msg)
		return self:Send(msg, player.GetAll())
	end
end