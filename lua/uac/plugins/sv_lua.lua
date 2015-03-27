local PLUGIN = uac.plugin.New()

PLUGIN.Name = "Lua commands"
PLUGIN.Description = "Adds commands that interface with Lua."
PLUGIN.Author = "Agent 47"

function PLUGIN:AllowLuaRun(src, by)
	if by:HasUserFlag(ACCESS_SERVEROWNER) then
		return true
	end
end
PLUGIN:AddHook("UACAllowLuaRun", "UAC Lua commands plugin", PLUGIN.AllowLuaRun)

local common_code =	[[local me = Entity(%i)
					local this = Entity(%i)
					local here = Vector(%g, %g, %g)
					local there = Vector(%g, %g, %g)
					%s]]
function PLUGIN:sv_lua(ply, command, args)
	local plypos = ply:GetPos()
	local trace = util.GetPlayerTrace(ply)
	local traceRes = util.TraceLine(trace)
	uac.lua.Run(	common_code:format(
						ply:EntIndex(),
						traceRes.Entity:EntIndex(),
						plypos.x,
						plypos.y,
						plypos.z,
						traceRes.HitPos.x,
						traceRes.HitPos.y,
						traceRes.HitPos.z,
						table.concat(args, " ")
					), ply)
end
PLUGIN:AddCommand("l", PLUGIN.sv_lua, ACCESS_SERVEROWNER, "Executes Lua code on the server", "<Lua code>")

function PLUGIN:sh_lua(ply, command, args)
	local plypos = ply:GetPos()
	local trace = util.GetPlayerTrace(ply)
	local traceRes = util.TraceLine(trace)
	uac.lua.RunOnShared(	common_code:format(
								ply:EntIndex(),
								traceRes.Entity:EntIndex(),
								plypos.x,
								plypos.y,
								plypos.z,
								traceRes.HitPos.x,
								traceRes.HitPos.y,
								traceRes.HitPos.z,
								table.concat(args, " ")
							), ply)
end
PLUGIN:AddCommand("ls", PLUGIN.sh_lua, ACCESS_SERVEROWNER, "Executes Lua code on the server and its clients", "<Lua code>")

function PLUGIN:cls_lua(ply, command, args)
	local plypos = ply:GetPos()
	local trace = util.GetPlayerTrace(ply)
	local traceRes = util.TraceLine(trace)
	uac.lua.RunOnClients(	common_code:format(
								ply:EntIndex(),
								traceRes.Entity:EntIndex(),
								plypos.x,
								plypos.y,
								plypos.z,
								traceRes.HitPos.x,
								traceRes.HitPos.y,
								traceRes.HitPos.z,
								table.concat(args, " ")
							), ply)
end
PLUGIN:AddCommand("lcs", PLUGIN.cls_lua, ACCESS_SERVEROWNER, "Executes Lua code on the clients", "<Lua code>")

function PLUGIN:cl_lua(ply, command, args)
	local targets = uac.player.GetTargets(ply, args[1], true)
	local plypos = ply:GetPos()
	local trace = util.GetPlayerTrace(ply)
	local traceRes = util.TraceLine(trace)
	local script =	common_code:format(
						ply:EntIndex(),
						traceRes.Entity:EntIndex(),
						plypos.x,
						plypos.y,
						plypos.z,
						traceRes.HitPos.x,
						traceRes.HitPos.y,
						traceRes.HitPos.z,
						table.concat(args, " ", 2)
					)

	for i = 1, #targets do
		local v = targets[i]
		uac.lua.RunOnClient(v, script, ply)
	end
end
PLUGIN:AddCommand("lc", PLUGIN.cl_lua, ACCESS_SERVEROWNER, "Executes Lua code on the specified client", "<Player name | SteamID | #UserID | @Team name> <Lua code>")

function PLUGIN:me_lua(ply, command, args)
	local plypos = ply:GetPos()
	local trace = util.GetPlayerTrace(ply)
	local traceRes = util.TraceLine(trace)
	local script =	common_code:format(
						ply:EntIndex(),
						traceRes.Entity:EntIndex(),
						plypos.x,
						plypos.y,
						plypos.z,
						traceRes.HitPos.x,
						traceRes.HitPos.y,
						traceRes.HitPos.z,
						table.concat(args, " ", 2)
					)

	uac.lua.RunOnClient(ply, script, ply)
end
PLUGIN:AddCommand("lm", PLUGIN.me_lua, ACCESS_SERVEROWNER, "Executes Lua code on yourself", "<Lua code>")

local ents_code =	[[local allents = ents.GetAll()
					for i = 1, #allents do
						local ent, e = allents[i], allents[i]
						local po = IsValid(ent:GetPhysicsObject()) and ent:GetPhysicsObject()
						local o, phys = po, po
						%s
					end]]
function PLUGIN:ents_lua(ply, command, args)
	self:sv_lua(ply, command, {ents_code:format(table.concat(args, " "))})
end
PLUGIN:AddCommand("ents", PLUGIN.ents_lua, ACCESS_SERVEROWNER, "Executes Lua code on every server entity", "<Lua code>")

local plys_code =	[[local plys = player.GetAll()
					for i = 1, #plys do
						local ply, p = plys[i], plys[i]
						local po = IsValid(ply:GetPhysicsObject()) and ply:GetPhysicsObject()
						local o, phys = po, po
						%s
					end]]
function PLUGIN:plys_lua(ply, command, args)
	self:sv_lua(ply, command, {plys_code:format(table.concat(args, " "))})
end
PLUGIN:AddCommand("plys", PLUGIN.plys_lua, ACCESS_SERVEROWNER, "Executes Lua code on every server player", "<Lua code>")

local print_code = "print(%s)"
function PLUGIN:print_lua(ply, command, args)
	self:sv_lua(ply, command, {print_code:format(table.concat(args, " "))})
end
PLUGIN:AddCommand("print", PLUGIN.print_lua, ACCESS_SERVEROWNER, "Executes Lua code on the server and prints the result", "<Lua code>")

local include_code = "include('%s.lua')"
function PLUGIN:include_lua(ply, command, args)
	self:sv_lua(ply, command, {include_code:format(table.concat(args, " "))})
end
PLUGIN:AddCommand("i", PLUGIN.include_lua, ACCESS_SERVEROWNER, "Includes the specified file on the server", "<Lua script filepath>")

function PLUGIN:includesh_lua(ply, command, args)
	self:sh_lua(ply, command, {include_code:format(table.concat(args, " "))})
end
PLUGIN:AddCommand("is", PLUGIN.includesh_lua, ACCESS_SERVEROWNER, "Includes the specified file on the server and its clients", "<Lua script filepath>")

function PLUGIN:includecl_lua(ply, command, args)
	self:cl_lua(ply, command, {args[1], include_code:format(table.concat(args, " ", 2))})
end
PLUGIN:AddCommand("ic", PLUGIN.includecl_lua, ACCESS_SERVEROWNER, "Includes the specified file on the specified clients", "<Player name | SteamID | #UserID | @Team name> <Lua script filepath>")

uac.plugin.Register(PLUGIN)