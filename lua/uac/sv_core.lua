if not file.IsDir("uac", "DATA") then
	file.CreateDir("uac")
end

AddCSLuaFile("cl_core.lua")
AddCSLuaFile("sh_core.lua")

include("sh_core.lua")