uac.auth = uac.auth or {
	users = {},
	access = {
		serverowner = "abcdefghijklmnopqrstuvxyz",
		superadmin = "abcdefghijklmnopqrstuvxy",
		admin = "abcdefghijmpqrtuv",

		all = "",
		none = nil,
		immunity = "a",
		reserv = "b",
		kick = "c",
		ban = "d",
		slay = "e",
		map = "f",
		cvar = "g",
		cfg = "h",
		chat = "i",
		vote = "j",
		password = "k",
		rcon = "l",
		prop = "m",
		ent = "n",
		custom_a = "o", --super
		custom_b = "p", --full
		custom_c = "q", --basic
		custom_d = "r", --lower
		ecs_a = "s", --super
		ecs_b = "t", --full
		ecs_c = "u", --basic
		ecs_d = "v", --lower

		serverowner = "z"
	}
}

local PLAYER = FindMetaTable("Player")

local SpecialPlayer

if SERVER then
	SpecialPlayer = function(ply)
		return game.SinglePlayer() or ply:IsListenServerHost()
	end
else
	SpecialPlayer = function()
		return game.SinglePlayer()
	end
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
