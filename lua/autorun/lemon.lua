if SERVER then
	AddCSLuaFile()
	AddCSLuaFile("lemon/cl_core.lua")
	include("lemon/sv_core.lua")
elseif CLIENT then
	include("lemon/cl_core.lua")
end