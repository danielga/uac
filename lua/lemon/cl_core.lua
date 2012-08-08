lemon = lemon or {}

//INITIALIZE LIBRARIES
for k, file in pairs(file.FindInLua("lemon/lib/*.lua")) do
	if string.sub(file, 1, 3) == "sh_" or string.sub(file, 1, 3) == "cl_" then
		include("lemon/lib/" .. file)
	end
end
//END OF INITIALIZE LIBRARIES

//INITIALIZE PLUGINS
for k, file in pairs(file.FindInLua("lemon/plugins/*.lua")) do
	if string.sub(file, 1, 3) == "sh_" or string.sub(file, 1, 3) == "cl_" then
		lemon.plugin:Load(file)
	end
end
//END OF INITIALIZE PLUGINS

usermessage.Hook("lemon_ServerAnswer", function(umsg)
	lemon.ServerHasLemon = umsg:ReadBool()
end)