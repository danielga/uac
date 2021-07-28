local PLAYER = FindMetaTable("Player")

function PLAYER:IsImmune(ply)
	return IsValid(ply) and ply:IsPlayer() and uac.role.IsImmune(ply:GetUserGroup(), self:GetUserGroup())
end

function PLAYER:GetPermissions()
	return uac.role.GetPermissions(self:GetUserGroup())
end

function PLAYER:HasPermission(permission)
	return uac.role.HasPermission(self:GetUserGroup(), permission)
end
