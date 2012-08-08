PLUGIN.Name = "Lua commands"
PLUGIN.Description = "Adds commands that interface with Lua."
PLUGIN.Author = "Agent 47"

function PLUGIN:sv_lua(ply, command, args)
	if not luadev or not luadev.RunOnServer then
		ply:ChatMessage(Color(255, 0, 0, 255), "[Lemon] ", Color(255, 255, 255, 255), "LuaDev is not installed on the server. Command execution failed.")
		return
	end

	local plypos = ply:GetPos()
	local trace = util.GetPlayerTrace(ply)
	local traceRes = util.TraceLine(trace)
	luadev.RunOnServer(string.format([[local me = ]] .. ply .. [[
	local this = ]] .. traceRes.Entity .. [[
	local here = Vector(]] .. plypos.x .. [[, ]] .. plypos.y .. [[, ]] .. plypos.z .. [[)
	local there = Vector(]] .. traceRes.HitPos.x .. [[, ]] .. traceRes.HitPos.y .. [[, ]] .. traceRes.HitPos.z .. [[)
	%s]], table.concat(args, " ")), ply:Nick(), ply)
end
PLUGIN:AddCommand("l", PLUGIN.sv_lua, ACCESS_SERVEROWNER, "Executes Lua code on the server", "<Lua code>")

function PLUGIN:sh_lua(ply, command, args)
	if not luadev or not luadev.RunOnShared then
		ply:ChatMessage(Color(255, 0, 0, 255), "[Lemon] ", Color(255, 255, 255, 255), "LuaDev is not installed on the server. Command execution failed.")
		return
	end

	local trace = util.GetPlayerTrace(ply)
	local traceRes = util.TraceLine(trace)
	luadev.RunOnShared(string.format([[local me = ]] .. ply .. [[
	local this = ]] .. traceRes.Entity .. [[
	local here = Vector(]] .. plypos.x .. [[, ]] .. plypos.y .. [[, ]] .. plypos.z .. [[)
	local there = Vector(]] .. traceRes.HitPos.x .. [[, ]] .. traceRes.HitPos.y .. [[, ]] .. traceRes.HitPos.z .. [[)
	%s]], table.concat(args, " ")), ply:Nick(), ply)
end
PLUGIN:AddCommand("ls", PLUGIN.sh_lua, ACCESS_SERVEROWNER, "Executes Lua code on the server and its clients", "<Lua code>")

function PLUGIN:cls_lua(ply, command, args)
	if not luadev or not luadev.RunOnClients then
		ply:ChatMessage(Color(255, 0, 0, 255), "[Lemon] ", Color(255, 255, 255, 255), "LuaDev is not installed on the server. Command execution failed.")
		return
	end

	local trace = util.GetPlayerTrace(ply)
	local traceRes = util.TraceLine(trace)
	luadev.RunOnClients(string.format([[local me = ]] .. ply .. [[
	local this = ]] .. traceRes.Entity .. [[
	local here = Vector(]] .. plypos.x .. [[, ]] .. plypos.y .. [[, ]] .. plypos.z .. [[)
	local there = Vector(]] .. traceRes.HitPos.x .. [[, ]] .. traceRes.HitPos.y .. [[, ]] .. traceRes.HitPos.z .. [[)
	%s]], table.concat(args, " ")), ply:Nick(), ply)
end
PLUGIN:AddCommand("lcs", PLUGIN.cls_lua, ACCESS_SERVEROWNER, "Executes Lua code on the clients", "<Lua code>")

function PLUGIN:cl_lua(ply, command, args)
	if not luadev or not luadev.RunOnClient then
		ply:ChatMessage(Color(255, 0, 0, 255), "[Lemon] ", Color(255, 255, 255, 255), "LuaDev is not installed on the server. Command execution failed.")
		return
	end

	local targets = lemon.player:GetTarget(ply, args[1], true)

	local trace = util.GetPlayerTrace(ply)
	local traceRes = util.TraceLine(trace)
	local script = string.format([[local me = ]] .. ply .. [[
	local this = ]] .. traceRes.Entity .. [[
	local here = Vector(]] .. plypos.x .. [[, ]] .. plypos.y .. [[, ]] .. plypos.z .. [[)
	local there = Vector(]] .. traceRes.HitPos.x .. [[, ]] .. traceRes.HitPos.y .. [[, ]] .. traceRes.HitPos.z .. [[)
	%s]], table.concat(args, " ", 2))

	for k, v in pairs(targets) do
		luadev.RunOnClient(script, v, ply:Nick(), ply)
	end
end
PLUGIN:AddCommand("lc", PLUGIN.cl_lua, ACCESS_SERVEROWNER, "Executes Lua code on the specified client", "<Player name | SteamID | #UserID | @Team name> <Lua code>")

function PLUGIN:ents_lua(ply, command, args)
	self:sv_lua(ply, command, string.Explode(" ", 
	[[for k, v in pairs(ents.GetAll()) do
		local ent, e = v, v
		local po = ent:GetPhysicsObject():IsValid() and ent:GetPhysicsObject()
		local o, phys = po, po
		]] .. table.concat(args, " ") .. [[
	end]]))
end
PLUGIN:AddCommand("ents", PLUGIN.ents_lua, ACCESS_SERVEROWNER, "Executes Lua code on every server entity", "<Lua code>")

function PLUGIN:plys_lua(ply, command, args)
	self:sv_lua(ply, command, {[[for k, v in pairs(player.GetAll()) do
		local ply, p = v, v
		local po = ply:GetPhysicsObject():IsValid() and ply:GetPhysicsObject()
		local o, phys = po, po
		]] .. table.concat(args, " ") .. [[
	end]]})
end
PLUGIN:AddCommand("plys", PLUGIN.plys_lua, ACCESS_SERVEROWNER, "Executes Lua code on every server player", "<Lua code>")

function PLUGIN:print_lua(ply, command, args)
	self:sv_lua(ply, command, {"print(" .. table.concat(args, " ") .. ")"})
end
PLUGIN:AddCommand("print", PLUGIN.print_lua, ACCESS_SERVEROWNER, "Executes Lua code on the server and prints the result", "<Lua code>")

function PLUGIN:include_lua(ply, command, args)
	self:sv_lua(ply, command, {"include('" .. table.concat(args, " ") .. ".lua')"})
end
PLUGIN:AddCommand("i", PLUGIN.include_lua, ACCESS_SERVEROWNER, "Includes the specified file on the server", "<Lua script filepath>")

function PLUGIN:includesh_lua(ply, command, args)
	self:sh_lua(ply, command, {"include('" .. table.concat(args, " ") .. ".lua')"})
end
PLUGIN:AddCommand("is", PLUGIN.includesh_lua, ACCESS_SERVEROWNER, "Includes the specified file on the server and its clients", "<Lua script filepath>")

function PLUGIN:includecl_lua(ply, command, args)
	self:cl_lua(ply, command, {args[1], "include('" .. table.concat(args, " ", 2) .. ".lua')"})
end
PLUGIN:AddCommand("ic", PLUGIN.includecl_lua, ACCESS_SERVEROWNER, "Includes the specified file on the specified clients", "<Player name | SteamID | #UserID | @Team name> <Lua script filepath>")