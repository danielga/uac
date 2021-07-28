uac.role = uac.role or {
	list = {}
}

include("sh_entity.lua")
include("sh_player.lua")

local role_list = uac.role.list

function uac.role.GetID(name)
	local role = role_list[name]
	return role ~= nil and role.index or nil
end

function uac.role.GetName(id)
	local role = role_list[id]
	return role ~= nil and role.name or nil
end

function uac.role.IsImmune(executor, target)
	executor, target = role_list[executor], role_list[target]
	return executor ~= nil and target ~= nil and target.index > executor.index
end

function uac.role.GetPermissions(name)
	local role = role_list[name]
	return role ~= nil and role.permissions or nil
end

function uac.role.HasPermission(name, permission)
	if permission == nil or permission == "" then
		return true
	end

	local role = role_list[name]
	if role == nil then
		return false
	end

	local permissions = role.permissions
	for i = 1, #permissions do
		if permissions[i] == permission then
			return true
		end
	end

	return false
end
