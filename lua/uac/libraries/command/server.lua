AddCSLuaFile("shared.lua")
AddCSLuaFile("types.lua")
AddCSLuaFile("command.lua")
include("shared.lua")

util.AddNetworkString("uac_command_execute")

net.Receive("uac_command_execute", function(len, ply)
	local command, argstr = net.ReadString(), net.ReadBool() and net.ReadString() or nil
	uac.command.Run(ply, command, argstr)
end)
