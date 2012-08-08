lemon.chat = lemon.chat or {}

lemon.chat.ColorPattern = "%<c(%d+),(%d+),(%d+)%>"

lemon.chat.Colors = {}
lemon.chat.Colors["<red>"] = "<c255,0,0>"
lemon.chat.Colors["<blue>"] = "<c0,0,255>"
lemon.chat.Colors["<black>"] = "<c0,0,0>"
lemon.chat.Colors["<white>"] = "<c255,255,255>"
lemon.chat.Colors["<green>"] = "<c0,255,0>"
lemon.chat.Colors["<yellow>"] = "<c255,255,0>"
lemon.chat.Colors["<pink>"] = "<c255,130,190>"
lemon.chat.Colors["<purple>"] = "<c128,0,255>"
lemon.chat.Colors["<orange>"] = "<c255,128,0>"
lemon.chat.Colors["<brown>"] = "<c185,122,87>"
lemon.chat.Colors["<grey>"] = "<c128,128,128>"
lemon.chat.Colors["<dkgrey>"] = "<c64,64,64>"
lemon.chat.Colors["<ltgrey>"] = "<c192,192,192>"
lemon.chat.Colors["<gray>"] = "<c128,128,128>"
lemon.chat.Colors["<dkgray>"] = "<c64,64,64>"
lemon.chat.Colors["<ltgray>"] = "<c192,192,192>"
lemon.chat.Colors["</color>"] = "<c255,255,255>"
lemon.chat.Colors["</c>"] = "<c255,255,255>"
lemon.chat.Colors["<cyan>"] = "<c0,255,255>"
lemon.chat.Colors["<turq>"] = "<c0,255,255>"
lemon.chat.Colors["<dkred>"] = "<c128,0,0>"
lemon.chat.Colors["<dkgreen>"] = "<c0,128,0>"
lemon.chat.Colors["<dkblue>"] = "<c0,0,128>"
lemon.chat.Colors["<dkyellow>"] = "<c128,128,0>"
lemon.chat.Colors["<dkpurple>"] = "<c128,0,128>"
lemon.chat.Colors["<dkcyan>"] = "<c0,128,128>"
lemon.chat.Colors["<dkturq>"] = "<c0,128,128>"
lemon.chat.Colors["<ltred>"] = "<c255,128,128>"
lemon.chat.Colors["<ltgreen>"] = "<c128,255,128>"
lemon.chat.Colors["<ltblue>"] = "<c128,128,255>"
lemon.chat.Colors["<ltyellow>"] = "<c255,255,128>"
lemon.chat.Colors["<ltpurple>"] = "<c255,128,255>"
lemon.chat.Colors["<ltcyan>"] = "<c128,255,255>"
lemon.chat.Colors["<ltturq>"] = "<c128,255,255>"
lemon.chat.Colors["</color>"] = "<c255,255,255>"
lemon.chat.Colors["</c>"] = "<c255,255,255>"
lemon.chat.Colors["^0"] = "<c0,0,0>"
lemon.chat.Colors["^1"] = "<c255,0,0>"
lemon.chat.Colors["^2"] = "<c0,255,0>"
lemon.chat.Colors["^3"] = "<c255,255,0>"
lemon.chat.Colors["^4"] = "<c0,0,255>"
lemon.chat.Colors["^5"] = "<c0,255,255>"
lemon.chat.Colors["^6"] = "<c255,0,255>"
lemon.chat.Colors["^7"] = "<c255,255,255>"
lemon.chat.Colors["^8"] = "<c192,192,192>"
lemon.chat.Colors["^9"] = "<c192,192,192>"

function lemon.chat:ParseTextColors(str)
	for k, v in pairs(self.Colors) do
		str = string.Replace(str, k, v)
	end

	local outResults = {}
	local theStart = 1
	local theSplitStart, theSplitEnd, r, g, b, a = string.find(str, self.ColorPattern, theStart)
	a = a or 255

	while theSplitStart do		
		table.insert(outResults, string.sub(str, theStart, theSplitStart - 1))

		if r and g and b and a then
			table.insert(outResults, Color(r, g, b, a))
		end

		theStart = theSplitEnd + 1
		theSplitStart, theSplitEnd, r, g, b, a = string.find(str, self.ColorPattern, theStart)
		a = a or 255
	end

	table.insert(outResults, string.sub(str, theStart))

	if outResults[1] == "" then
		table.remove(outResults, 1)
	end

	return outResults
end

if CLIENT then
	function lemon.chat:AddParsedText(...)
		local args = {...}
		local tbl = {}

		for k, v in ipairs(args) do
			if type(v) == "string" then
				local items = self:ParseTextColors(v)
				for i, j in ipairs(items) do
					table.insert(tbl, j)
				end
			else
				table.insert(tbl, v)
			end
		end

		chat.AddText(unpack(tbl))
	end

	usermessage.Hook("lemon_chatmessage", function(data)
		chat.AddText(unpack(data.Items))
	end)
	/*
	hook.Add("OnPlayerChat", "lemon_chat_OverrideNormalChat", function(player, text, teamonly, isdead)
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
	*/
end