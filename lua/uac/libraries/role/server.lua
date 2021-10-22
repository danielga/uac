AddCSLuaFile("client.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("sh_player.lua")

include("shared.lua")

util.AddNetworkString("uac_role_synchronize")
util.AddNetworkString("uac_role_add")
util.AddNetworkString("uac_role_remove")
util.AddNetworkString("uac_role_move")
util.AddNetworkString("uac_role_permissions")

local role_list = uac.role.list

hook.Add("PlayerAuthed", "uac.role.PlayerAuthed", function(ply, steamid)
	-- get player role and set their permissions
end)

hook.Add("PlayerInitialSpawn", "uac.role.SynchronizeList", function(ply)
	local list_size = #role_list

	net.Start("uac_role_synchronize")
		net.WriteUInt(list_size, 8)

		for i = 1, list_size do
			local role = role_list[i]
			net.WriteString(role.name)
			net.WriteString(uac.string.EncodeULEB128(role.rawpermissions))
		end
	net.Send(ply)
end)

function uac.role.Add(name, permissions, is_default, no_broadcast, index)
	if role_list[name] ~= nil then
		return
	end

	-- verify all permissions are valid here
	local raw_permissions = {}
	for i = 1, #permissions do
		raw_permissions[i] = uac.permission.GetID(permissions[i])
	end

	if index ~= nil then
		for i = #role_list, index, -1 do
			local role_move = role_list[i]
			role_move.index = i + 1
			role_list[i + 1] = role_move
		end
	else
		index = #role_list + 1
	end

	local role = {
		name = name,
		index = index,
		permissions = permissions,
		rawpermissions = raw_permissions,
		isdefault = is_default or false
	}
	role_list[index] = role
	role_list[name] = role

	if not no_broadcast then
		net.Start("uac_role_add")
			net.WriteUInt(index, 8)
			net.WriteString(name)
			net.WriteString(uac.string.EncodeULEB128(raw_permissions))
		net.Broadcast()
	end
end

function uac.role.Remove(name)
	local role = role_list[name]
	if role == nil or role.isdefault then
		return
	end

	local index = role.index
	for i = index, #role_list - 1 do
		local role_move = role_list[i + 1]
		role_move.index = i
		role_list[i] = role_move
	end

	role_list[#role_list] = nil
	role_list[name] = nil

	net.Start("uac_role_remove")
		net.WriteUInt(index, 8)
	net.Broadcast()
end

function uac.role.Move(name, index)
	local role = role_list[name]
	if role == nil then
		return
	end

	local old = role.index
	if old == index then
		return
	end

	if old > index then
		for i = old - 1, index, -1 do
			local role_move = role_list[i]
			role_move.index = i + 1
			role_list[i + 1] = role_move
		end
	else
		for i = old, index - 1 do
			local role_move = role_list[i + 1]
			role_move.index = i
			role_list[i] = role_move
		end
	end

	role_list[index] = role

	net.Start("uac_role_move")
	net.WriteUInt(old, 8)
	net.WriteUInt(index, 8)
	net.Broadcast()
end

function uac.role.SetPermissions(name, permissions)
	local role = role_list[name]
	if role == nil then
		return
	end

	-- verify all permissions are valid here
	local raw_permissions = {}
	for i = 1, #permissions do
		raw_permissions[i] = uac.permission.GetID(permissions[i])
	end

	role.permissions = permissions
	role.rawpermissions = raw_permissions

	net.Start("uac_role_permissions")
	net.WriteUInt(role.index, 8)
	net.WriteString(uac.string.EncodeULEB128(raw_permissions))
	net.Broadcast()
end

function uac.role.LoadList()

end

function uac.role.SaveList()

end

-- these default roles depend on default permissions that might or might not
-- be available at the time of this script loading
hook.Add("Initialize", "uac.role.Load", function()
	uac.role.Add("superadmin", {
		"superadmin",
		"admin",
		"cexec",
		"lua",
		"ban",
		"role",
		"rcon",
		"teleport",
		"vehicle",
		"give",
		"god",
		"health",
		"kick",
		"map",
		"noclip",
		"respawn",
		"slay",
		"strip"
	}, true, true)

	uac.role.Add("admin", {
		"admin",
		"teleport",
		"vehicle",
		"give",
		"god",
		"health",
		"kick",
		"map",
		"noclip",
		"respawn",
		"slay",
		"strip"
	}, true, true)

	uac.role.Add("user", {}, true, true)

	uac.role.LoadList()
end)

