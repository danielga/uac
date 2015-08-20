

local PLAYER = FindMetaTable("Player")

local function SpecialPlayer(ply)
	return game.SinglePlayer() or ply:IsListenServerHost()
end

function PLAYER:HasUserFlag(flag)
	if SpecialPlayer(self) then
		return true
	end

	if flag == nil then
		return false
	end

	if flag == "" then
		return true
	end

	if self:GetUserFlags():find(flag, 1, true) then
		return true
	end

	return false
end

function PLAYER:GetUserFlags()
	return self:GetNWString("UserFlags", "")
end

function PLAYER:IsAdmin()
	return self:IsSuperAdmin() or self:IsUserGroup("admin") or SpecialPlayer(self)
end

function PLAYER:IsSuperAdmin()
	return self:IsUserGroup("superadmin") or SpecialPlayer(self)
end

function PLAYER:IsUserGroup(name)
	return self:GetUserGroup() == name
end

function PLAYER:GetUserGroup()
	return self:GetNWString("UserGroup", "")
end
