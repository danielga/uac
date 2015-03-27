util.AddNetworkString("uac_chat_Text")
util.AddNetworkString("uac_chat_CPS")

local PLAYER = FindMetaTable("Player")
if PLAYER then
	function PLAYER:Mute(boolean)
		self:GetUACTable().IsMuted = boolean
	end

	function PLAYER:Gag(boolean)
		self:GetUACTable().IsGagged = boolean
	end

	function PLAYER:ChatText(...)
		local tbl = {...}
		local size = #tbl

		net.Start("uac_chat_Text")
			net.WriteUInt(size, 8)
			for i = 1, size do
				local val = tbl[i]
				local valtype = type(val)
				if valtype == "table" then
					net.WriteBit(true)
					net.WriteUInt(val.r, 8)
					net.WriteUInt(val.g, 8)
					net.WriteUInt(val.b, 8)
					net.WriteUInt(val.a, 8)
				elseif valtype == "string" then
					net.WriteBit(false)
					net.WriteString(val)
				else
					net.WriteBit(false)
					net.WriteString(tostring(val))
				end
			end
		net.Send(self)
	end
end

hook.Add("PlayerSay", "uac.chat.PlayerSay", function(ply, text, global)
	if ply:GetUACTable().IsGagged then return "" end

	if uac.config.GetValue("uac_chat_prefixes"):find(text:sub(1, 1)) then
		local command = (text:match("%w+") or ""):lower()
		local arguments = {}
		for match in text:sub(#command + 3):gmatch("[^,]+") do
			match = match:gsub("^%s*(.-)%s*$", "%1")
			table.insert(arguments, match)
		end

		--[[if uac.command.Run(ply, command, arguments) then
			return ""
		end]]
	end
end)

hook.Add("PlayerCanHearPlayersVoice", "uac.chat.MuteVoice", function(listener, talker)
	if talker:GetUACTable().IsMuted then return false, false end
end)

hook.Add("PlayerInitialSpawn", "uac.chat.ChatPrefixesSync", function(ply)
	net.Start("uac_chat_CPS")
	net.WriteString(uac.config.GetValue("uac_chat_prefixes") or "")
	net.Send(ply)
end)