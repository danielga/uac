if not file.IsDir("uac", "DATA") then
	file.CreateDir("uac")
end

AddCSLuaFile("cl_core.lua")

uac = uac or {}

-- LIBRARIES INITIALIZATION
local files = file.Find("uac/lib/*.lua", "LUA")
for i = 1, #files do
	local file = files[i]
	local prefix = file:sub(1, 3)
	if prefix == "sv_" then
		include("uac/lib/" .. file)
	elseif prefix == "sh_" then
		include("uac/lib/" .. file)
		AddCSLuaFile("uac/lib/" .. file)
	elseif prefix == "cl_" then
		AddCSLuaFile("uac/lib/" .. file)
	end
end
-- END OF LIBRARIES INITIALIZATION

-- PLUGINS INITIALIZATION
uac.plugin.Include()
-- END OF PLUGINS INITIALIZATION