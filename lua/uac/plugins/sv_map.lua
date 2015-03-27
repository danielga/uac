local PLUGIN = uac.plugin.New()

PLUGIN.Name = "Map commands"
PLUGIN.Description = "Adds commands to change maps."
PLUGIN.Author = "Agent 47"

function PLUGIN:ChangeMap(ply, command, args)
	if IsValid(ply) and ply:IsPlayer() and #args < 1 then
		ply:ChatText(Color(255, 0, 0, 255), "[UAC] ", Color(255, 0, 0, 255), "You need to provide a map name.")
		return
	end

	local map = args[1]
	local time = 0
	if args[2] then time = math.max(tonumber(args[2]) or 0, 0) end

	timer.Create("uac_mapchange", time, 1, function()
		game.ConsoleCommand("changelevel " .. map .. "\n")
	end)
end
PLUGIN:AddCommand("mapchange", PLUGIN.ChangeMap, ACCESS_MAP, "Changes the map", "<Map name> [Countdown time]")

function PLUGIN:CancelMapChange(ply, command, args)
	timer.Destroy("uac_mapchange")
end
PLUGIN:AddCommand("cancelmapchange", PLUGIN.CancelMapChange, ACCESS_MAP, "Cancels mapchange", "")

function PLUGIN:RestartMap(ply, command, args)
	local map = game.GetMap()
	local time = 0
	if args[1] then time = math.max(tonumber(args[1]) or 0, 0) end

	timer.Create("uac_restartmap", time, 1, function()
		game.ConsoleCommand("changelevel " .. map .. "\n")
	end)
end
PLUGIN:AddCommand("restart", PLUGIN.RestartMap, ACCESS_MAP, "Restarts the current map", "[Countdown time]")

function PLUGIN:CancelRestartMap(ply, command, args)
	timer.Destroy("uac_restartmap")
end
PLUGIN:AddCommand("cancelrestart", PLUGIN.CancelRestartMap, ACCESS_MAP, "Cancels restart", "")

uac.plugin.Register(PLUGIN)