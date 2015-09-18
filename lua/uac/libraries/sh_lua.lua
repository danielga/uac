uac.lua = uac.lua or {}

if SERVER then
	util.AddNetworkString("uac_lua")

	function uac.lua.RunOnClient(ply, src, by)
		local identifier = "Console"
		if IsValid(by) then
			identifier = string.format("%s (%s)", by:Name(), by:SteamID())
		end

		net.Start("uac_lua")
			net.WriteString(src)
			net.WriteString(identifier)
		net.Send(ply)
	end

	function uac.lua.RunOnClients(src, by)
		local identifier = "Console"
		if IsValid(by) then
			identifier = string.format("%s (%s)", by:Name(), by:SteamID())
		end

		net.Start("uac_lua")
			net.WriteString(src)
			net.WriteString(identifier)
		net.Broadcast()
	end

	net.Receive("uac_lua", function(len, ply)
		local script = net.ReadString()
		if hook.Run("UACAllowLuaRun", script, ply) == true then
			uac.lua.Run(script, string.format("%s (%s)", ply:Name(), ply:SteamID()))
		end
	end)
else
	function uac.lua.RunOnServer(src)
		net.Start("uac_lua")
		net.WriteString(src)
		net.SendToServer()
	end

	net.Receive("uac_lua", function(len)
		uac.lua.Run(net.ReadString(), net.ReadString())
	end)
end

function uac.lua.RunOnShared(src, by)
	uac.lua.Run(src, by)
	if SERVER then
		uac.lua.RunOnClients(src, by)
	else
		uac.lua.RunOnServer(src)
	end
end

function uac.lua.Run(src, by)
	by = by or "Console"
	if type(by) == "Player" and IsValid(by) then
		by = string.format("%s (%s)", by:Name(), by:SteamID())
	end

	local ret = CompileString(src, by or "uac lua", false)
	if isfunction(ret) then
		return ret()
	end
end
