lemon.chat = lemon.chat or {}
local chat_prefixes = {"-", "!"}

util.AddNetworkString("lemon_chatmessage")

local PLAYER = FindMetaTable("Player")
if PLAYER then
	function PLAYER:Mute(boolean)
		ply:GetLemonTable().IsMuted = boolean
	end

	function PLAYER:Gag(boolean)
		ply:GetLemonTable().IsGagged = boolean
	end

	function PLAYER:Notify(...)
		lemon.chat:AddText(self, ...)
	end

	function PLAYER:ParsedNotify(...)
		lemon.chat:AddParsedText(self, ...)
	end
end

local function GetType(var)
	if type(var) == "table" && table.Count(var) == 4 && var.r && var.g && var.b && var.a then
		return "Color"
	end

	return type(var)
end
	
function lemon.chat:AddParsedText(first, ...)
	local args = {...}
	local tbl = {}
	local nofirst = false
	if type(first) == "string" then
		local items = lemon.chat:ParseTextColors(first)
		for i = 1, #items do
			local v = items[i]
			table.insert(tbl, v)
		end
		nofirst = true
	end

	for i = 1, #args do
		local v = args[i]
		if type(v) == "string" then
			local items = lemon.chat:ParseTextColors(v)
			for k = 1, #args do
				local j = args[k]
				table.insert(tbl, j)
			end
		else
			table.insert(tbl, v)
		end
	end

	if nofirst then
		lemon.chat:AddText(unpack(tbl))
	else
		lemon.chat:AddText(first, unpack(tbl))
	end
end

function lemon.chat:AddText(first, ...)
	local firsttype = GetType(first)
	local tbl = (firsttype == "Player" or firsttype == "table") and {...} or {first, ...}
	local size = #tbl

	net.Start("lemon_chatmessage")
		net.WriteUInt(size, 8)
		for i = 1, size do
			local val = tbl[i]
			local valtype = GetType(val)
			if valtype == "Color" then
				net.WriteBit(true)
				net.WriteUInt(val.r, 8)
				net.WriteUInt(val.g, 8)
				net.WriteUInt(val.b, 8)
				net.WriteUInt(val.a, 8)
			elseif valtype == "string" then
				net.WriteBit(false)
				net.WriteString(val)
			end
		end

	if targeted then
		net.Send(first)
	else
		net.Broadcast()
	end
end

hook.Add("PlayerSay", "lemon.chat.PlayerSay", function(ply, text, global)
	if ply:GetLemonTable().IsGagged then return "" end

	local prefix = text:sub(1, 1)
	if table.HasValue(chat_prefixes, prefix) then
		local command = (text:match("%w+") or ""):lower()
		local arguments = {}
		for match in text:sub(#command + 3, -1):gmatch("[^,]+") do
			match = match:gsub("^%s*(.-)%s*$", "%1")
			table.insert(arguments, match)
		end

		if lemon.command:Run(ply, command, arguments) then
			return ""
		end
	end
end)

hook.Add("PlayerCanHearPlayersVoice", "lemon.chat.MuteVoice", function(listener, talker)
	if talker:GetLemonTable().IsMuted then return false, false end
end)