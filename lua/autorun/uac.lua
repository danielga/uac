if SERVER then
	AddCSLuaFile()
	include("uac/sv_core.lua")
elseif CLIENT then
	include("uac/cl_core.lua")
end
