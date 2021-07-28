uac.permission = uac.permission or {}

uac.permission.list = {}

local permission_list = uac.permission.list

function uac.permission.Add(name, description)
	if permission_list[name] ~= nil then
		return
	end

	local permission = {name = name, description = description}
	local index = table.insert(permission_list, permission)
	permission.index = index
	permission_list[name] = permission
end

function uac.permission.GetID(name)
	local permission = permission_list[name]
	return permission ~= nil and permission.index or nil
end

function uac.permission.GetName(id)
	local permission = permission_list[id]
	return permission ~= nil and permission.name or nil
end

-- default permissions
uac.permission.Add("superadmin", "Gives users the status of Super Admin (for addons that use Garry's stuff)")
uac.permission.Add("admin", "Gives users the status of Admin (for addons that use Garry's stuff)")
