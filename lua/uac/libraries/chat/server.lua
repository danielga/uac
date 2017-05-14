AddCSLuaFile("client.lua")

util.AddNetworkString("uac_chat_text")
util.AddNetworkString("uac_chat_prefixes")

local ENTITY = FindMetaTable("Entity")

function ENTITY:IsMuted()
	return false
end

function ENTITY:Mute(boolean)
end

function ENTITY:IsGagged()
	return false
end

function ENTITY:Gag(boolean)
end

function ENTITY:ChatText(...)
	if self == NULL then
		MsgC(...)
		MsgN()
	end
end

local PLAYER = FindMetaTable("Player")

if SERVER then

function PLAYER:IsMuted()
	return self:GetUACTable().muted
end

function PLAYER:Mute(boolean)
	self:GetUACTable().muted = boolean
end

else

PLAYER.Mute = PLAYER.SetMuted

end

function PLAYER:IsGagged()
	return self:GetUACTable().gagged
end

function PLAYER:Gag(boolean)
	self:GetUACTable().gagged = boolean
end

function PLAYER:ChatText(...)
	local size = select("#", ...)

	net.Start("uac_chat_text")

	net.WriteUInt(size, 8)
	for i = 1, size do
		local val = select(i, ...)
		if istable(val) and isnumber(val.r) and isnumber(val.g) and isnumber(val.b) and isnumber(val.a) then
			net.WriteBool(true)
			net.WriteUInt(val.r, 8)
			net.WriteUInt(val.g, 8)
			net.WriteUInt(val.b, 8)
			net.WriteUInt(val.a, 8)
		else
			net.WriteBool(false)
			net.WriteString(tostring(val))
		end
	end

	net.Send(self)
end

hook.Add("PlayerSay", "uac.chat.PlayerSay", function(ply, text, global)
	if ply:IsGagged() then
		return ""
	end

	if string.find(uac.config.GetValue("uac_chat_prefixes"), string.sub(text, 1, 1)) then
		local command, argstr = uac.command.Split(string.sub(text, 2))
		if uac.command.Run(ply, command, argstr) then
			return ""
		end
	end
end)

hook.Add("PlayerCanHearPlayersVoice", "uac.chat.MuteVoice", function(listener, talker)
	if talker:IsMuted() then
		return false, false
	end
end)

hook.Add("PlayerInitialSpawn", "uac.chat.ChatPrefixesSync", function(ply)
	local chat_prefixes = uac.config.GetValue("uac_chat_prefixes")
	if not chat_prefixes or chat_prefixes == "" then
		return
	end

	net.Start("uac_chat_prefixes")
	net.WriteString(chat_prefixes)
	net.Send(ply)
end)
