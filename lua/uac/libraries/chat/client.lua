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
	if autocomplete == nil then
		return
	end

	local chatx, chaty = chat.GetChatBoxPos()

	draw.RoundedBox(8, chatx + autocomplete.box.x, chaty + autocomplete.box.y, autocomplete.box.w, autocomplete.box.h, boxcolor)

	surface.SetFont("ChatFont")
	surface.SetTextColor(textcolor)
	for i = 1, #autocomplete do
		surface.SetTextPos(chatx + autocomplete[i].x, chaty + autocomplete[i].y)
		surface.DrawText(autocomplete[i].text)
	end
end

hook.Add("StartChat", "uac.chat.StartChat", function()
	hook.Add("HUDPaint", "uac.chat.HUDPaint", HUDPaint)
end)

hook.Add("FinishChat", "uac.chat.FinishChat", function()
	hook.Remove("HUDPaint", "uac.chat.HUDPaint")
end)

local previous_index
local tabbed = false
hook.Add("OnChatTab", "uac.chat.OnChatTab", function(str)
	if chat_prefixes ~= nil and autocomplete ~= nil and #autocomplete > 0 and str:find(("^[%s]"):format(chat_prefixes)) then
		previous_index = previous_index ~= nil and previous_index + 1 or 1
		previous_index = previous_index > math.min(#autocomplete, 5) and 1 or previous_index
		tabbed = true
		print(previous_index, autocomplete[previous_index].text)
		return autocomplete[previous_index].text .. " "
	end
end)

hook.Add("ChatTextChanged", "uac.chat.ChatTextChanged", function(text)
	if tabbed then
		tabbed = false
		return
	end

	previous_index = nil

	if text == "" then
		autocomplete = nil
		return
	end

	local prefix = text:sub(1, 1)
	if chat_prefixes ~= nil and chat_prefixes:find(prefix) then
		surface.SetFont("ChatFont")
		local spacew = surface.GetTextSize(" ")

		local maxw = 0
		local maxh = 5 -- border size
		local command, argstr = uac.command.Split(text:sub(2))
		local autocompletes = uac.command.GetAutoComplete(prefix, command, argstr)
		autocomplete = {}
		for i = 1, math.min(#autocompletes, 5) do
			local text = autocompletes[i]
			local textw, texth = surface.GetTextSize(text)
			maxh = maxh + texth
			table.insert(autocomplete, {text = text, x = 5, y = -maxh - 5})
			textw = textw + spacew
			if textw > maxw then
				maxw = textw
			end
			maxh = maxh + 3
		end

		if #autocomplete == 0 then
			autocomplete = nil
			return
		end

		maxh = maxh + 5 - 3 -- another border size - spacing

		-- all y are offset by 5 because this is the spacing between chatbox and autocomplete
		autocomplete.box = {x = 0, y = -maxh - 5, w = maxw + 2 * 5, h = maxh}
	end
end)