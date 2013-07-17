lemon = lemon or {}

-- LIBRARIES INITIALIZATION
local files = file.Find("lemon/lib/*.lua", "LUA")
for i = 1, #files do
	local file = files[i]
	local prefix = file:sub(1, 3)
	if prefix == "sh_" or prefix == "cl_" then
		include("lemon/lib/" .. file)
	end
end
-- END OF LIBRARIES INITIALIZATION

-- PLUGINS INITIALIZATION
lemon.plugin:IncludeAll()
-- END OF PLUGINS INITIALIZATION