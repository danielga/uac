lemon.chat = lemon.chat or {}
lemon.chat.Prefixes = lemon.chat.Prefixes or {"-", "!"}

local PLAYER = FindMetaTable("Player")
function PLAYER:Mute(boolean)
	ply.lemon.IsMuted = boolean
end

function PLAYER:Gag(boolean)
	ply.lemon.IsGagged = boolean
end

function PLAYER:ChatMessage(...)
	lemon.chat:AddText(self, ...)
end

function PLAYER:ParsedChatMessage(...)
	lemon.chat:AddParsedText(self, ...)
end

local function GetType(var)
	local vartype = type(var)
	if vartype == "table" && table.Count(var) == 4 && var.r && var.g && var.b && var.a then
		return "Color"
	end

	return vartype
end
	
function lemon.chat:AddParsedText(first, ...)
	local args = {...}
	local tbl = {}
	local nofirst = false
	if type(first) == "string" then
		local items = lemon.chat:ParseTextColors(first)
		for k, v in ipairs(items) do
			table.insert(tbl, v)
		end
		nofirst = true
	end

	for k, v in ipairs(args) do
		if type(v) == "string" then
			local items = lemon.chat:ParseTextColors(v)
			for i, j in ipairs(items) do
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

	if firsttype == "CRecipientFilter" || firsttype == "Player" || firsttype == "table" then
		lemon.usermessage:Send("lemon_chatmessage", first, ...)
	else
		lemon.usermessage:SendGlobal("lemon_chatmessage", first, ...)
	end
end

hook.Add("PlayerSay", "lemon_chat_PlayerSay", function(ply, text, global)
	if ply.lemon.IsGagged then return "" end

	local prefix = string.sub(text, 1, 1)
	if table.HasValue(lemon.chat.Prefixes, prefix) then
		local command = string.lower(string.match(text, "%w+") or "")
		local arguments = {}
		for match in string.gmatch(string.sub(text, string.len(command) + 3, -1), "[^,]+") do
			table.insert(arguments, match)
		end

		lemon.command:Run(ply, command, arguments)
	end
end)

hook.Add("PlayerCanHearPlayersVoice", "lemon_chat_PlayerCanHearPlayersVoice", function(listener, talker)
	if talker.lemon.IsMuted then return false, false end
end)