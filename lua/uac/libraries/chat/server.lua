AddCSLuaFile("client.lua")

util.AddNetworkString("uac_chat_Text")
util.AddNetworkString("uac_chat_CPS")

local PLAYER = FindMetaTable("Player")

function PLAYER:Mute(boolean)
	self:GetUACTable().muted = boolean
end

function PLAYER:Gag(boolean)
	self:GetUACTable().gagged = boolean
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
		else
			net.WriteBit(false)
			net.WriteString(tostring(val))
		end
	end

	net.Send(self)
end

hook.Add("PlayerSay", "uac.chat.PlayerSay", function(ply, text, global)
	if ply:GetUACTable().gagged then
		return ""
	end

	if uac.config.GetValue("uac_chat_prefixes"):find(text:sub(1, 1)) then
		local command, argstr = uac.command.Split(text:sub(2))
		if uac.command.Run(ply, command, argstr) then
			return ""
		end
	end
end)

hook.Add("PlayerCanHearPlayersVoice", "uac.chat.MuteVoice", function(listener, talker)
	if talker:GetUACTable().muted then
		return false, false
	end
end)

hook.Add("PlayerInitialSpawn", "uac.chat.ChatPrefixesSync", function(ply)
	local chat_prefixes = uac.config.GetValue("uac_chat_prefixes")
	if not chat_prefixes or chat_prefixes == "" then
		return
	end

	net.Start("uac_chat_CPS")
	net.WriteString(chat_prefixes)
	net.Send(ply)
end)