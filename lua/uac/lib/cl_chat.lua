local chat_prefixes = "-!"
net.Receive("uac_chat_CPS", function(len)
	chat_prefixes = net.ReadString()
end)

net.Receive("uac_chat_Text", function(len)
	local num = net.ReadUInt(8)
	local data = {}
	for i = 1, num do
		table.insert(data, net.ReadBit() == 1 and Color(net.ReadUInt(8), net.ReadUInt(8), net.ReadUInt(8), net.ReadUInt(8)) or net.ReadString())
	end

	chat.AddText(unpack(data))
end)

local boxcolor = Color(120, 120, 120, 120)
local textcolor = Color(255, 255, 255, 255)
local autocomplete
local function HUDPaint()
	if not autocomplete then return end

	local chatx, chaty = chat.GetChatBoxPos()

	draw.RoundedBox(8, chatx + autocomplete.Box.X, chaty + autocomplete.Box.Y, autocomplete.Box.W, autocomplete.Box.H, boxcolor)

	surface.SetFont("ChatFont")
	surface.SetTextColor(textcolor)
	for i = 1, #autocomplete do
		surface.SetTextPos(chatx + autocomplete[i].CX, chaty + autocomplete[i].CY)
		surface.DrawText(autocomplete[i].C)
		if autocomplete[i].U then
			surface.SetTextPos(chatx + autocomplete[i].UX, chaty + autocomplete[i].UY)
			surface.DrawText(autocomplete[i].U)
		end
	end
end

hook.Add("StartChat", "uac.chat.StartChat", function()
	hook.Add("HUDPaint", "uac.chat.HUDPaint", HUDPaint)
end)

hook.Add("FinishChat", "uac.chat.FinishChat", function()
	hook.Remove("HUDPaint", "uac.chat.HUDPaint")
end)

hook.Add("OnChatTab", "uac.chat.OnChatTab", function(str)
	if chat_prefixes and autocomplete and #autocomplete > 0 and str:match(("^[%s][^ ]*$"):format(chat_prefixes)) then
		return autocomplete[1].C .. " "
	end
end)

hook.Add("ChatTextChanged", "uac.chat.ChatTextChanged", function(text)
	if text == "" then
		autocomplete = nil
		return
	end

	local prefix = text:sub(1, 1)
	if chat_prefixes and chat_prefixes:find(prefix) then
		local command = text:sub(2):match("^([^%s]+)")
		local comlen = command and #command or 0

		autocomplete = {}

		surface.SetFont("ChatFont")
		local spacew = surface.GetTextSize(" ")

		local added = 0
		local maxw = 0
		local maxh = 5 -- border size
		for name, usage in pairs(uac.command.GetList()) do
			if added >= 5 then break end

			if not command or name:sub(1, comlen) == command then
				if usage ~= "" then
					local text = ("%s%s"):format(prefix, name)
					local textw, texth = surface.GetTextSize(text)
					maxh = maxh + texth
					table.insert(autocomplete, {C = text, CX = 5, CY = -maxh - 5, U = usage, UX = 5 + spacew + textw, UY = -maxh - 5})
					textw = textw + spacew + surface.GetTextSize(usage)
					if textw > maxw then maxw = textw end
					maxh = maxh + 3
				else
					local text = ("%s%s"):format(prefix, name)
					local textw, texth = surface.GetTextSize(text)
					if textw > maxw then maxw = textw end
					maxh = maxh + texth
					table.insert(autocomplete, {C = text, CX = 5, CY = -maxh - 5})
					maxh = maxh + 3
				end

				added = added + 1
			end
		end

		if added == 0 then
			autocomplete = nil
			return
		end

		maxh = maxh + 5 - 3 -- another border size - spacing

		-- all y are offset by 5 because this is the spacing between chatbox and autocomplete
		autocomplete.Box = {X = 0, Y = -maxh - 5, W = maxw + 2 * 5, H = maxh}
	end
end)