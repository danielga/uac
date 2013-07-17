lemon.lua = lemon.lua or {}

if SERVER then
	util.AddNetworkString("lemon_lua")

	function lemon.lua:RunOnClient(ply, src, by)
		local identifier = "Console"
		if IsValid(by) then
			identifier = string.format("%s (%s)", by:Name(), by:SteamID())
		end

		net.Start("lemon_lua")
			net.WriteString(src)
			net.WriteString(identifier)
		net.Send(ply)
	end

	function lemon.lua:RunOnClients(src, by)
		local identifier = "Console"
		if IsValid(by) then
			identifier = string.format("%s (%s)", by:Name(), by:SteamID())
		end
		
		net.Start("lemon_lua")
			net.WriteString(src)
			net.WriteString(identifier)
		net.Broadcast()
	end

	net.Receive("lemon_lua", function(len, ply)
		local script = net.ReadString()
		if hook.Run("LemonAllowLuaRun", script, ply) == true then	-- Good job finding this but unless
																	-- you're a server owner, fuck off.
			lemon.lua:Run(script, string.format("%s (%s)", ply:Name(), ply:SteamID()))
		end
	end)
else
	function lemon.lua:RunOnServer(src)
		net.Start("lemon_lua")
			net.WriteString(src)
		net.SendToServer()
	end

	net.Receive("lemon_lua", function(len) lemon.lua:Run(net.ReadString(), net.ReadString()) end)
end

function lemon.lua:RunOnShared(src, by)
	self:Run(src, by)
	if SERVER then
		self:RunOnClients(src, by)
	else
		self:RunOnServer(src)
	end
end

function lemon.lua:Run(src, by)
	by = by or "Console"
	if type(by) == "Player" and IsValid(by) then
		by = string.format("%s (%s)", by:Name(), by:SteamID())
	end

	local ret = CompileString(src, by or "lemon lua", false)
	if isfunction(ret) then
		return ret()
	end
end