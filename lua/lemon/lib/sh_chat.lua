lemon.chat = lemon.chat or {}

local color_pattern = "%<c(%d+),(%d+),(%d+)%>"

local chat_colors = {}
chat_colors["<red>"] = "<c255,0,0>"
chat_colors["<blue>"] = "<c0,0,255>"
chat_colors["<black>"] = "<c0,0,0>"
chat_colors["<white>"] = "<c255,255,255>"
chat_colors["<green>"] = "<c0,255,0>"
chat_colors["<yellow>"] = "<c255,255,0>"
chat_colors["<pink>"] = "<c255,130,190>"
chat_colors["<purple>"] = "<c128,0,255>"
chat_colors["<orange>"] = "<c255,128,0>"
chat_colors["<brown>"] = "<c185,122,87>"
chat_colors["<grey>"] = "<c128,128,128>"
chat_colors["<dkgrey>"] = "<c64,64,64>"
chat_colors["<ltgrey>"] = "<c192,192,192>"
chat_colors["<gray>"] = "<c128,128,128>"
chat_colors["<dkgray>"] = "<c64,64,64>"
chat_colors["<ltgray>"] = "<c192,192,192>"
chat_colors["</color>"] = "<c255,255,255>"
chat_colors["</c>"] = "<c255,255,255>"
chat_colors["<cyan>"] = "<c0,255,255>"
chat_colors["<turq>"] = "<c0,255,255>"
chat_colors["<dkred>"] = "<c128,0,0>"
chat_colors["<dkgreen>"] = "<c0,128,0>"
chat_colors["<dkblue>"] = "<c0,0,128>"
chat_colors["<dkyellow>"] = "<c128,128,0>"
chat_colors["<dkpurple>"] = "<c128,0,128>"
chat_colors["<dkcyan>"] = "<c0,128,128>"
chat_colors["<dkturq>"] = "<c0,128,128>"
chat_colors["<ltred>"] = "<c255,128,128>"
chat_colors["<ltgreen>"] = "<c128,255,128>"
chat_colors["<ltblue>"] = "<c128,128,255>"
chat_colors["<ltyellow>"] = "<c255,255,128>"
chat_colors["<ltpurple>"] = "<c255,128,255>"
chat_colors["<ltcyan>"] = "<c128,255,255>"
chat_colors["<ltturq>"] = "<c128,255,255>"
chat_colors["</color>"] = "<c255,255,255>"
chat_colors["</c>"] = "<c255,255,255>"
chat_colors["^0"] = "<c0,0,0>"
chat_colors["^1"] = "<c255,0,0>"
chat_colors["^2"] = "<c0,255,0>"
chat_colors["^3"] = "<c255,255,0>"
chat_colors["^4"] = "<c0,0,255>"
chat_colors["^5"] = "<c0,255,255>"
chat_colors["^6"] = "<c255,0,255>"
chat_colors["^7"] = "<c255,255,255>"
chat_colors["^8"] = "<c192,192,192>"
chat_colors["^9"] = "<c192,192,192>"

function lemon.chat:ParseTextColors(str)
	for pattern, color in pairs(chat_colors) do
		str = str:gsub(pattern, color)
	end

	local outResults = {}
	local theStart = 1
	local theSplitStart, theSplitEnd, r, g, b, a = str:find(color_pattern, theStart)
	a = a or 255

	while theSplitStart do		
		table.insert(outResults, str:sub(theStart, theSplitStart - 1))

		if r and g and b and a then
			table.insert(outResults, Color(r, g, b, a))
		end

		theStart = theSplitEnd + 1
		theSplitStart, theSplitEnd, r, g, b, a = str:sub(color_pattern, theStart)
		a = a or 255
	end

	table.insert(outResults, str:sub(theStart))

	if outResults[1] == "" then
		table.remove(outResults, 1)
	end

	return outResults
end

if CLIENT then
	function lemon.chat:AddParsedText(...)
		local args = {...}
		local tbl = {}

		for i = 1, #args do
			local v = args[i]
			if type(v) == "string" then
				local items = self:ParseTextColors(v)
				for k = 1, #args do
					table.insert(tbl, items[k])
				end
			else
				table.insert(tbl, v)
			end
		end

		chat.AddText(unpack(tbl))
	end

	net.Receive("lemon_chatmessage", function(len)
		local num = net.ReadUInt(8)
		local data = {}
		for i = 1, num do
			table.insert(data, net.ReadBit() == 1 and Color(net.ReadUInt(8), net.ReadUInt(8), net.ReadUInt(8), net.ReadUInt(8)) or net.ReadString())
		end

		chat.AddText(unpack(data))
	end)
	
	--[[
	hook.Add("OnPlayerChat", "lemon.chat.OverrideNormalChat", function(player, text, teamonly, isdead)
		if lemon.ServerHasLemon then
			if teamonly and isdead then
				lemon.chat:AddParsedText(Color(255, 0, 0), "*DEAD* ", Color(0, 255, 0), "(TEAM) ", team.GetColor(player:Team()), player:Nick() .. ": ", Color(255, 255, 255), text)
			elseif teamonly then
				lemon.chat:AddParsedText(Color(0, 255, 0), "(TEAM) ", team.GetColor(player:Team()), player:Nick() .. ": ", Color(255, 255, 255), text)
			elseif isdead then
				lemon.chat:AddParsedText(Color(255, 0, 0), "*DEAD* ", team.GetColor(player:Team()), player:Nick() .. ": ", Color(255, 255, 255), text)
			else
				lemon.chat:AddParsedText(team.GetColor(player:Team()), player:Nick() .. ": ", Color(255, 255, 255), text)
			end

			return true
		end
	end)
	]]
end