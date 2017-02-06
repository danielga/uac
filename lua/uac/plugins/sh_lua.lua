PLUGIN.Name = "Lua commands"
PLUGIN.Description = "Adds commands that interface with Lua."
PLUGIN.Author = "MetaMan"

function PLUGIN:AllowLuaRun(src, by)
	if by:HasUserFlag(uac.auth.access.owner) then
		return true
	end
end
PLUGIN:AddHook("UACAllowLuaRun", "UAC Lua commands plugin", PLUGIN.AllowLuaRun)

local common_code =	[[
local me = Entity(%i)
local this = Entity(%i)
local here = Vector(%g, %g, %g)
local there = Vector(%g, %g, %g)
%s
]]
function PLUGIN:sv_lua(ply, code)
	local plypos = ply:GetPos()
	local trace = util.GetPlayerTrace(ply)
	local traceRes = util.TraceLine(trace)
	uac.lua.Run(string.format(
		common_code,
		ply:EntIndex(),
		traceRes.Entity:EntIndex(),
		plypos.x,
		plypos.y,
		plypos.z,
		traceRes.HitPos.x,
		traceRes.HitPos.y,
		traceRes.HitPos.z,
		code
	), ply)
end
PLUGIN:AddCommand("l", PLUGIN.sv_lua)
	:SetAccess(uac.auth.access.owner)
	:SetDescription("Executes Lua code on the server")
	:AddParameter(uac.command.string)

function PLUGIN:sh_lua(ply, code)
	local plypos = ply:GetPos()
	local trace = util.GetPlayerTrace(ply)
	local traceRes = util.TraceLine(trace)
	uac.lua.RunOnShared(string.format(
		common_code,
		ply:EntIndex(),
		traceRes.Entity:EntIndex(),
		plypos.x,
		plypos.y,
		plypos.z,
		traceRes.HitPos.x,
		traceRes.HitPos.y,
		traceRes.HitPos.z,
		code
	), ply)
end
PLUGIN:AddCommand("ls", PLUGIN.sh_lua)
	:SetAccess(uac.auth.access.owner)
	:SetDescription("Executes Lua code on the server and its clients")
	:AddParameter(uac.command.string)

function PLUGIN:cls_lua(ply, code)
	local plypos = ply:GetPos()
	local trace = util.GetPlayerTrace(ply)
	local traceRes = util.TraceLine(trace)
	uac.lua.RunOnClients(string.format(
		common_code,
		ply:EntIndex(),
		traceRes.Entity:EntIndex(),
		plypos.x,
		plypos.y,
		plypos.z,
		traceRes.HitPos.x,
		traceRes.HitPos.y,
		traceRes.HitPos.z,
		code
	), ply)
end
PLUGIN:AddCommand("lcs", PLUGIN.cls_lua)
	:SetAccess(uac.auth.access.owner)
	:SetDescription("Executes Lua code on the clients")
	:AddParameter(uac.command.string)

function PLUGIN:cl_lua(ply, targets, code)
	local plypos = ply:GetPos()
	local trace = util.GetPlayerTrace(ply)
	local traceRes = util.TraceLine(trace)
	local script = string.format(
		common_code,
		ply:EntIndex(),
		traceRes.Entity:EntIndex(),
		plypos.x,
		plypos.y,
		plypos.z,
		traceRes.HitPos.x,
		traceRes.HitPos.y,
		traceRes.HitPos.z,
		code
	)

	for i = 1, #targets do
		uac.lua.RunOnClient(targets[i], script, ply)
	end
end
PLUGIN:AddCommand("lc", PLUGIN.cl_lua)
	:SetAccess(uac.auth.access.owner)
	:SetDescription("Executes Lua code on the specified client")
	:AddParameter(uac.command.players)
	:AddParameter(uac.command.string)

function PLUGIN:me_lua(ply, code)
	local plypos = ply:GetPos()
	local trace = util.GetPlayerTrace(ply)
	local traceRes = util.TraceLine(trace)
	local script = string.format(
		common_code,
		ply:EntIndex(),
		traceRes.Entity:EntIndex(),
		plypos.x,
		plypos.y,
		plypos.z,
		traceRes.HitPos.x,
		traceRes.HitPos.y,
		traceRes.HitPos.z,
		code
	)

	uac.lua.RunOnClient(ply, script, ply)
end
PLUGIN:AddCommand("lm", PLUGIN.me_lua)
	:SetAccess(uac.auth.access.owner)
	:SetDescription("Executes Lua code on yourself")
	:AddParameter(uac.command.string)

local ents_code = [[
local allents = ents.GetAll()
for i = 1, #allents do
	local ent, e = allents[i], allents[i]
	local po = IsValid(ent:GetPhysicsObject()) and ent:GetPhysicsObject()
	local o, phys = po, po
	%s
end
]]
function PLUGIN:ents_lua(ply, code)
	self:sv_lua(ply, string.format(ents_code, code))
end
PLUGIN:AddCommand("ents", PLUGIN.ents_lua)
	:SetAccess(uac.auth.access.owner)
	:SetDescription("Executes Lua code on every server entity")
	:AddParameter(uac.command.string)

local plys_code = [[
local plys = player.GetAll()
for i = 1, #plys do
	local ply, p = plys[i], plys[i]
	local po = IsValid(ply:GetPhysicsObject()) and ply:GetPhysicsObject()
	local o, phys = po, po
	%s
end
]]
function PLUGIN:plys_lua(ply, code)
	self:sv_lua(ply, string.format(plys_code, code))
end
PLUGIN:AddCommand("plys", PLUGIN.plys_lua)
	:SetAccess(uac.auth.access.owner)
	:SetDescription("Executes Lua code on every server player")
	:AddParameter(uac.command.string)

local print_code = "print(%s)"
function PLUGIN:print_lua(ply, code)
	self:sv_lua(ply, string.format(print_code, code))
end
PLUGIN:AddCommand("print", PLUGIN.print_lua)
	:SetAccess(uac.auth.access.owner)
	:SetDescription("Executes Lua code on the server and prints the result")
	:AddParameter(uac.command.string)

local include_code = "include('%s')"
function PLUGIN:include_lua(ply, filename)
	self:sv_lua(ply, string.format(include_code, filename))
end
PLUGIN:AddCommand("i", PLUGIN.include_lua)
	:SetAccess(uac.auth.access.owner)
	:SetDescription("Includes the specified file on the server")
	:AddParameter(uac.command.string)

function PLUGIN:includesh_lua(ply, filename)
	self:sh_lua(ply, string.format(include_code, filename))
end
PLUGIN:AddCommand("is", PLUGIN.includesh_lua)
	:SetAccess(uac.auth.access.owner)
	:SetDescription("Includes the specified file on the server and its clients")
	:AddParameter(uac.command.string)

function PLUGIN:includecl_lua(ply, targets, code)
	self:cl_lua(ply, targets, string.format(include_code, code))
end
PLUGIN:AddCommand("ic", PLUGIN.includecl_lua)
	:SetAccess(uac.auth.access.owner)
	:SetDescription("Includes the specified file on the specified clients")
	:AddParameter(uac.command.players)
	:AddParameter(uac.command.string)
