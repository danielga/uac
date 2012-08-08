if SERVER then
	AddCSLuaFile("autorun/lemon.lua")
	AddCSLuaFile("lemon/cl_core.lua")

	include("lemon/sv_core.lua")

	lemon.config:SetValuesFromFile("lua/lemon/config.txt")
elseif CLIENT then
	include("lemon/cl_core.lua")
end