AddCSLuaFile("client.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

util.AddNetworkString("uac_command_execute")

net.Receive("uac_command_execute", function(len, ply)
	local command = net.ReadString()
	local argstr = net.ReadBool() and net.ReadString() or nil
	uac.command.Run(ply, command, argstr)
end)
