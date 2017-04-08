PLUGIN.Name = "Map management"
PLUGIN.Description = "Adds commands to restart/change maps."
PLUGIN.Author = "MetaMan"

PLUGIN:AddPermission("map", "Gives access to map management")

function PLUGIN:ChangeMap(ply, map, time)
	if not file.Exists("maps/" .. map .. ".bsp", "GAME") then
		return
	end

	timer.Create("uac_changemap", time, 1, function()
		game.ConsoleCommand("changelevel " .. map .. "\n")
	end)
end
PLUGIN:AddCommand("changemap", PLUGIN.ChangeMap)
	:SetPermission("map")
	:SetDescription("Changes the map")
	:AddParameter(uac.command.string)
	:AddParameter(uac.command.number(0, math.huge, 0))

function PLUGIN:CancelChangeMap(ply, command, args)
	timer.Remove("uac_changemap")
end
PLUGIN:AddCommand("cancelchangemap", PLUGIN.CancelChangeMap)
	:SetPermission("map")
	:SetDescription("Cancels changemap")

function PLUGIN:RestartMap(ply, time)
	timer.Create("uac_restartmap", time, 1, function()
		game.ConsoleCommand("changelevel " .. game.GetMap() .. "\n")
	end)
end
PLUGIN:AddCommand("restart", PLUGIN.RestartMap)
	:SetPermission("map")
	:SetDescription("Restarts the current map")
	:AddParameter(uac.command.number(0, math.huge, 0))

function PLUGIN:CancelRestartMap(ply, command, args)
	timer.Remove("uac_restartmap")
end
PLUGIN:AddCommand("cancelrestart", PLUGIN.CancelRestartMap)
	:SetPermission("map")
	:SetDescription("Cancels restart")
