lemon = lemon or {}

-- LIBRARIES INITIALIZATION
local files = file.Find("lemon/lib/*.lua", "LUA")
for i = 1, #files do
	local file = files[i]
	local prefix = file:sub(1, 3)
	if prefix == "sv_" then
		include("lemon/lib/" .. file)
	elseif prefix == "sh_" then
		include("lemon/lib/" .. file)
		AddCSLuaFile("lemon/lib/" .. file)
	elseif prefix == "cl_" then
		AddCSLuaFile("lemon/lib/" .. file)
	end
end
-- END OF LIBRARIES INITIALIZATION

-- PLUGINS INITIALIZATION
lemon.plugin.Include()
-- END OF PLUGINS INITIALIZATION