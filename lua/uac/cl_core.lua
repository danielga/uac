uac = uac or {}

-- LIBRARIES INITIALIZATION
local files = file.Find("uac/lib/*.lua", "LUA")
for i = 1, #files do
	local file = files[i]
	local prefix = file:sub(1, 3)
	if prefix == "sh_" or prefix == "cl_" then
		include("uac/lib/" .. file)
	end
end
-- END OF LIBRARIES INITIALIZATION

-- PLUGINS INITIALIZATION
uac.plugin.Include()
-- END OF PLUGINS INITIALIZATION