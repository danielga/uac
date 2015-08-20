PLUGIN.Name = "Crash"
PLUGIN.Description = "Adds a command to crash players."
PLUGIN.Author = "MetaMan"

function PLUGIN:Crash(ply, target)
	target:Remove()
end
PLUGIN:AddCommand("crash", PLUGIN.Crash)
	:SetAccess(ACCESS_RCON)
	:SetDescription("Crashes a player")
	:AddParameter(uac.command.player)
