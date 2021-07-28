uac.misc = uac.misc or {
	is_dedicated_server = game.IsDedicated() -- always returns false in the client
}

if SERVER then
	if uac.misc.is_dedicated_server then
		util.AddNetworkString("uac_misc_is_dedicated_server")
	else
		util.AddNetworkString("uac_misc_is_not_dedicated_server")
	end
else
	for i = 1, 2047 do
		local netstring = util.NetworkIDToString(i)
		if netstring == nil then
			break
		end

		if netstring == "uac_misc_is_dedicated_server" then
			uac.misc.is_dedicated_server = true
			break
		end
	end
end

function uac.misc.IsDedicatedServer()
	return uac.misc.is_dedicated_server
end
