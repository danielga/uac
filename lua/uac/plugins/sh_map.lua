PLUGIN.Name = "Map commands"
PLUGIN.Description = "Adds commands to restart/change maps."
PLUGIN.Author = "MetaMan"

function PLUGIN:ChangeMap(ply, map, time)
	time = math.max(time or 0, 0)

	timer.Create("uac_mapchange", time, 1, function()
		game.ConsoleCommand("changelevel " .. map .. "\n")
	end)
end
PLUGIN:AddCommand("mapchange", PLUGIN.ChangeMap)
	:SetAccess(ACCESS_MAP)
	:SetDescription("Changes the map")
	:AddParameter(uac.command.string)
	:AddParameter(uac.command.number)

function PLUGIN:CancelMapChange(ply, command, args)
	timer.Destroy("uac_mapchange")
end
PLUGIN:AddCommand("cancelmapchange", PLUGIN.CancelMapChange)
	:SetAccess(ACCESS_MAP)
	:SetDescription("Cancels mapchange")

function PLUGIN:RestartMap(ply, time)
	local map = game.GetMap()
	time = math.max(time or 0, 0)

	timer.Create("uac_restartmap", time, 1, function()
		game.ConsoleCommand("changelevel " .. map .. "\n")
	end)
end
PLUGIN:AddCommand("restart", PLUGIN.RestartMap)
	:SetAccess(ACCESS_MAP)
	:SetDescription("Restarts the current map")
	:AddParameter(uac.command.number)

function PLUGIN:CancelRestartMap(ply, command, args)
	timer.Destroy("uac_restartmap")
end
PLUGIN:AddCommand("cancelrestart", PLUGIN.CancelRestartMap)
	:SetAccess(ACCESS_MAP)
	:SetDescription("Cancels restart")