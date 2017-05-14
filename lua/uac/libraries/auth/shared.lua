local ENTITY = FindMetaTable("Entity")

function ENTITY:IsImmune(ply)
	return self == NULL
end

function ENTITY:GetPermissions()
	return uac.role.GetPermissions("superadmin")
end

function ENTITY:HasPermission(permission)
	return self == NULL
end

function ENTITY:GetRole()
	return self == NULL and "superadmin" or nil
end

function ENTITY:SetRole(role)
end

function ENTITY:IsSuperAdmin()
	return self == NULL
end

function ENTITY:IsAdmin()
	return self == NULL
end

local PLAYER = FindMetaTable("Player")

function PLAYER:IsImmune(ply)
	return IsValid(ply) and ply:IsPlayer() and uac.role.IsImmune(ply:GetRole(), self:GetRole())
end

function PLAYER:GetPermissions()
	return uac.role.GetPermissions(self:GetRole())
end

function PLAYER:HasPermission(permission)
	return uac.role.HasPermission(self:GetRole(), permission)
end

function PLAYER:GetRole()
	return self:GetNW2String("UACRole", "user")
end

function PLAYER:SetRole(role)
	return self:SetNW2String("UACRole", role)
end

function PLAYER:IsSuperAdmin()
	return self:HasPermission("superadmin")
end

function PLAYER:IsAdmin()
	return self:IsSuperAdmin() or self:HasPermission("admin")
end
