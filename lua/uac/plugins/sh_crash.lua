PLUGIN.Name = "Crash"
PLUGIN.Description = "Adds a command to crash players."
PLUGIN.Author = "MetaMan"

function PLUGIN:Crash(ply, target)
	target:Remove()
end
PLUGIN:AddCommand("crash", PLUGIN.Crash)
	:SetAccess(uac.auth.access.rcon)
	:SetDescription("Crashes a player")
	:AddParameter(uac.command.player)
