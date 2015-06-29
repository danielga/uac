AddCSLuaFile("client.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

util.AddNetworkString("uac_command_EXE")

net.Receive("uac_command_EXE", function(len, ply)
	local command = net.ReadString()
	local argstr = net.ReadString()
	uac.command.Run(ply, command, argstr)
end)