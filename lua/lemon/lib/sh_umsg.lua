lemon.usermessage = lemon.usermessage or {}
lemon.umsg = lemon.usermessage

lemon.usermessage.UMSG_TYPE_END = -1
lemon.usermessage.UMSG_TYPE_STOP = 0
lemon.usermessage.UMSG_TYPE_STRING = 1
lemon.usermessage.UMSG_TYPE_UNFINISHED_STRING = 2
lemon.usermessage.UMSG_TYPE_EMPTY_STRING = 3
lemon.usermessage.UMSG_TYPE_NUMBER = 4
lemon.usermessage.UMSG_TYPE_VECTOR = 5
lemon.usermessage.UMSG_TYPE_ANGLE = 6
lemon.usermessage.UMSG_TYPE_BOOL = 7
lemon.usermessage.UMSG_TYPE_CHAR = 8
lemon.usermessage.UMSG_TYPE_ENTITY = 9
lemon.usermessage.UMSG_TYPE_COLOR = 10
lemon.usermessage.UMSG_TYPE_PHYSOBJ = 11

if CLIENT then

	lemon.usermessage.List = lemon.usermessage.List or {}

	local FAKEMSG = {}
	FAKEMSG.__index = FAKEMSG

	function FAKEMSG:Init()
		self.Read = 0
		self.Items = {}
	end

	function FAKEMSG:GetNumberOfValues()
		return #self.Items
	end

	function FAKEMSG:ReadValue()
		if self.Read < #self.Items then
			self.Read = self.Read + 1
			return self.Items[self.Read]
		end
	end

	function FAKEMSG:SetValue(index, value)
		if !index then return end

		self.Items[index] = value
	end

	function FAKEMSG:Reset()
		self.Read = 0
	end

	function FAKEMSG:SetTable(tbl)
		self.Items = table.Copy(tbl)
	end

	local types = {"Angle", "Bool", "Char", "Entity", "Float", "Long", "Short", "String", "Vector", "VectorNormal"}
	for _, readtype in pairs(types) do
		FAKEMSG["Read" .. readtype] = function(self) return self:ReadValue() end
	end

	local function FakeMsg(tbl)
		local fakemsg = {}
		setmetatable(fakemsg, FAKEMSG)

		fakemsg:Init()
		fakemsg:SetTable(tbl)

		return fakemsg
	end

	local function IsColor(color) --SO MUCH CHECKING AND SO MUCH ACCURATE!
		return type(color) == "table" and table.Count(color) == 4 and color.r and color.g and color.b and color.a
	end

	usermessage.Hook("le_umsg", function(um)
		local name = um:ReadString()
		local umsgtype = um:ReadChar()
		local loops = 0

		if !lemon.usermessage.List[name] then lemon.usermessage.List[name] = {} end

		while umsgtype != lemon.usermessage.UMSG_TYPE_END and umsgtype != lemon.usermessage.UMSG_TYPE_STOP do
			loops = loops + 1
			if loops >= 260 then
				print("[lemon] Usermessage system failed. Please warn an admin or superadmin.")
				break
			end

			if umsgtype == lemon.usermessage.UMSG_TYPE_STRING then
				table.insert(lemon.usermessage.List[name], um:ReadString())
			elseif umsgtype == lemon.usermessage.UMSG_TYPE_UNFINISHED_STRING then
				local index = table.getn(lemon.usermessage.List[name])
				if index == 0 then
					print("[lemon] Empty table for this usermessage. (" .. name .. ")")
					index = 1
				end

				if not lemon.usermessage.List[name][index] then
					print("[lemon] Unexistant string for this usermessage on index " .. index .. ". (" .. name .. ")")
					lemon.usermessage.List[name][index] = um:ReadString()
				else
					lemon.usermessage.List[name][index] = lemon.usermessage.List[name][index] .. um:ReadString()
				end
			elseif umsgtype == lemon.usermessage.UMSG_TYPE_EMPTY_STRING then
				table.insert(lemon.usermessage.List[name], "")
			elseif umsgtype == lemon.usermessage.UMSG_TYPE_NUMBER then
				table.insert(lemon.usermessage.List[name], um:ReadFloat())
			elseif umsgtype == lemon.usermessage.UMSG_TYPE_VECTOR then
				table.insert(lemon.usermessage.List[name], um:ReadVector())
			elseif umsgtype == lemon.usermessage.UMSG_TYPE_ANGLE then
				table.insert(lemon.usermessage.List[name], um:ReadAngle())
			elseif umsgtype == lemon.usermessage.UMSG_TYPE_BOOL then
				table.insert(lemon.usermessage.List[name], um:ReadBool())
			elseif umsgtype == lemon.usermessage.UMSG_TYPE_ENTITY then
				table.insert(lemon.usermessage.List[name], um:ReadEntity())
			elseif umsgtype == lemon.usermessage.UMSG_TYPE_CHAR then
				table.insert(lemon.usermessage.List[name], string.char(um:ReadChar() + 128))
			elseif umsgtype == lemon.usermessage.UMSG_TYPE_COLOR then
				local r, g, b, a = um:ReadChar() + 128, um:ReadChar() + 128, um:ReadChar() + 128, um:ReadChar() + 128
				table.insert(lemon.usermessage.List[name], Color(r, g, b, a))
			elseif umsgtype == lemon.usermessage.UMSG_TYPE_PHYSOBJ then
				local ent, phys = um:ReadEntity(), um:ReadChar()
				table.insert(lemon.usermessage.List[name], ent:GetPhysicsObjectNum(phys))
			else
				print("[lemon] Unhandled item type on the usermessage system (" .. umsgtype .. ").")
			end
			umsgtype = um:ReadChar()
		end

		if umsgtype == lemon.usermessage.UMSG_TYPE_END then
			local fakemsg = FakeMsg(lemon.usermessage.List[name])
			usermessage.IncomingMessage(name, fakemsg)
			lemon.usermessage.List[name] = nil
		end
	end)

end