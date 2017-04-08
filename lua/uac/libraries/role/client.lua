include("shared.lua")

local role_list = uac.role.list

net.Receive("uac_role_synchronize", function(len)
	local new_role_list = {}

	local list_size = net.ReadUInt(8)

	for i = 1, list_size do
		local name, raw_permissions, permissions = net.ReadString(), uac.string.DecodeULEB128(net.ReadString()), {}

		-- verify all permissions are valid here
		for i = 1, #raw_permissions do
			permissions[i] = uac.permission.GetName(raw_permissions[i])
		end

		local role = {name = name, index = i, permissions = permissions, rawpermissions = raw_permissions}
		new_role_list[i] = role
		new_role_list[name] = role
	end

	uac.role.list = new_role_list
	role_list = new_role_list
end)

net.Receive("uac_role_add", function(len)
	local index, name, raw_permissions, permissions = net.ReadUInt(8), net.ReadString(), uac.string.DecodeULEB128(net.ReadString()), {}

	-- verify all permissions are valid here
	for i = 1, #raw_permissions do
		permissions[i] = uac.permission.GetName(raw_permissions[i])
	end

	for i = #role_list, index, -1 do
		local role = role_list[i]
		role.index = i + 1
		role_list[i + 1] = role
	end

	local role = {name = name, index = index, permissions = permissions, rawpermissions = raw_permissions}
	role_list[index] = role
	role_list[name] = role
end)

net.Receive("uac_role_remove", function(len)
	local index = net.ReadUInt(8)

	for i = index, #role_list - 1 do
		local role = role_list[i + 1]
		role.index = i
		role_list[i] = role
	end

	role_list[#role_list] = nil
	role_list[name] = nil
end)

net.Receive("uac_role_move", function(len)
	local old, index = net.ReadUInt(8), net.ReadUInt(8)

	local role = role_list[old]
	if old > index then
		for i = old - 1, index, -1 do
			local role = role_list[i]
			role.index = i + 1
			role_list[i + 1] = role
		end
	else
		for i = old, index - 1 do
			local role = role_list[i + 1]
			role.index = i
			role_list[i] = role
		end
	end

	role_list[index] = role
end)

net.Receive("uac_role_permissions", function(len)
	local index, raw_permissions, permissions = net.ReadUInt(8), uac.string.DecodeULEB128(net.ReadString()), {}

	-- verify all permissions are valid here
	for i = 1, #raw_permissions do
		permissions[i] = uac.permission.GetName(raw_permissions[i])
	end

	role_list[index].permissions = permissions
	role_list[index].rawpermissions = raw_permissions
end)
