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
