lemon = lemon or {}

//INITIALIZE LIBRARIES
for k, file in pairs(file.FindInLua("lemon/lib/*.lua")) do
	if string.sub(file, 1, 3) == "sv_" then
		include("lemon/lib/" .. file)
	elseif string.sub(file, 1, 3) == "sh_" then
		include("lemon/lib/" .. file)
		AddCSLuaFile("lemon/lib/" .. file)
	elseif string.sub(file, 1, 3) == "cl_" then
		AddCSLuaFile("lemon/lib/" .. file)
	end
end
//END OF INITIALIZE LIBRARIES

//INITIALIZE PLUGINS
for k, file in pairs(file.FindInLua("lemon/plugins/*.lua")) do
	if string.sub(file, 1, 3) == "sv_" then
		lemon.plugin:Load(file)
	elseif string.sub(file, 1, 3) == "sh_" then
		lemon.plugin:Load(file)
		AddCSLuaFile("lemon/plugins/" .. file)
	elseif string.sub(file, 1, 3) == "cl_" then
		AddCSLuaFile("lemon/plugins/" .. file)
	end
end
//END OF INITIALIZE PLUGINS