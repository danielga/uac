PLUGIN.Name = "Map commands"
PLUGIN.Description = "Adds commands to restart/change maps."
PLUGIN.Author = "MetaMan"

function PLUGIN:ChangeMap(ply, map, time)
	timer.Create("uac_changemap", time, 1, function()
		game.ConsoleCommand("changelevel " .. map .. "\n")
	end)
end
PLUGIN:AddCommand("changemap", PLUGIN.ChangeMap)
	:SetAccess(ACCESS_MAP)
	:SetDescription("Changes the map")
	:AddParameter(uac.command.string)
	:AddParameter(uac.command.number(0, math.huge, 0))

function PLUGIN:CancelChangeMap(ply, command, args)
	timer.Destroy("uac_changemap")
end
PLUGIN:AddCommand("cancelchangemap", PLUGIN.CancelChangeMap)
	:SetAccess(ACCESS_MAP)
	:SetDescription("Cancels changemap")

function PLUGIN:RestartMap(ply, time)
	timer.Create("uac_restartmap", time, 1, function()
		game.ConsoleCommand("changelevel " .. game.GetMap() .. "\n")
	end)
end
PLUGIN:AddCommand("restart", PLUGIN.RestartMap)
	:SetAccess(ACCESS_MAP)
	:SetDescription("Restarts the current map")
	:AddParameter(uac.command.number(0, math.huge, 0))

function PLUGIN:CancelRestartMap(ply, command, args)
	timer.Destroy("uac_restartmap")
end
PLUGIN:AddCommand("cancelrestart", PLUGIN.CancelRestartMap)
	:SetAccess(ACCESS_MAP)
	:SetDescription("Cancels restart")