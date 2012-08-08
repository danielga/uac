FLAGS_SERVEROWNER = "abcdefghijklmnopqrstuvxyz"
FLAGS_SUPERADMIN = "abcdefghijklmnopqrstuvxy"
FLAGS_ADMIN = "abcdefghijmpqrtuv"

ACCESS_ALL = "0"
ACCESS_NONE = nil
ACCESS_IMMUNITY = "a"
ACCESS_RESERV = "b"
ACCESS_KICK = "c"
ACCESS_BAN = "d"
ACCESS_SLAY = "e"
ACCESS_MAP = "f"
ACCESS_CVAR = "g"
ACCESS_CFG = "h"
ACCESS_CHAT = "i"
ACCESS_VOTE = "j"
ACCESS_PASSWORD = "k"
ACCESS_RCON = "l"
ACCESS_PROP = "m"
ACCESS_ENT = "n"
ACCESS_CUSTOM_A = "o" --super
ACCESS_CUSTOM_B = "p" --full
ACCESS_CUSTOM_C = "q" --basic
ACCESS_CUSTOM_D = "r" --lower
ACCESS_ECS_A = "s" --super
ACCESS_ECS_B = "t" --full
ACCESS_ECS_C = "u" --basic
ACCESS_ECS_D = "v" --lower

ACCESS_SERVEROWNER = "z"

--shitty method to translate strings to flags, I KNOW! now shut up.
ACCESS_SOLVETABLE = {
	["FLAGS_SERVEROWNER"] = FLAGS_SERVEROWNER,
	["FLAGS_SUPERFUCK"] = FLAGS_SUPERFUCK,
	["FLAGS_SUPERADMIN"] = FLAGS_SUPERADMIN,
	["FLAGS_RED"] = FLAGS_RED,
	["FLAGS_YELLOW"] = FLAGS_YELLOW,
	["FLAGS_LOWER"] = FLAGS_LOWER,
	["ACCESS_ALL"] = ACCESS_ALL,
	["ACCESS_NONE"] = ACCESS_NONE,
	["ACCESS_IMMUNITY"] = ACCESS_IMMUNITY,
	["ACCESS_RESERV"] = ACCESS_RESERV,
	["ACCESS_KICK"] = ACCESS_KICK,
	["ACCESS_BAN"] = ACCESS_BAN,
	["ACCESS_SLAY"] = ACCESS_SLAY,
	["ACCESS_MAP"] = ACCESS_MAP,
	["ACCESS_CVAR"] = ACCESS_CVAR,
	["ACCESS_CFG"] = ACCESS_CFG,
	["ACCESS_CHAT"] = ACCESS_CHAT,
	["ACCESS_VOTE"] = ACCESS_VOTE,
	["ACCESS_PASSWORD"] = ACCESS_PASSWORD,
	["ACCESS_RCON"] = ACCESS_RCON,
	["ACCESS_PROP"] = ACCESS_PROP,
	["ACCESS_ENT"] = ACCESS_ENT,
	["ACCESS_CUSTOM_A"] = ACCESS_CUSTOM_A,
	["ACCESS_CUSTOM_B"] = ACCESS_CUSTOM_B,
	["ACCESS_CUSTOM_C"] = ACCESS_CUSTOM_C,
	["ACCESS_CUSTOM_D"] = ACCESS_CUSTOM_D,
	["ACCESS_ECS_A"] = ACCESS_ECS_A,
	["ACCESS_ECS_B"] = ACCESS_ECS_B,
	["ACCESS_ECS_C"] = ACCESS_ECS_C,
	["ACCESS_ECS_D"] = ACCESS_ECS_D
}

local meta = FindMetaTable("Player")
if not meta then return end

function meta:HasUserFlag(flag)
	if self.IsFullyAuthenticated and not self:IsFullyAuthenticated() then return false end

	if not flag then return false end
	if flag == "" then return true end
	if string.find(self:GetNetworkedString("LemonUserFlags", ""), flag, 1, true) then return true end

	return false
end

function meta:GetUserFlags()
	if self.IsFullyAuthenticated and not self:IsFullyAuthenticated() then return "" end

	return self:GetNetworkedString("LemonUserFlags", "")
end

function meta:IsAdmin()
	if self.IsFullyAuthenticated and not self:IsFullyAuthenticated() then return false end

	if self:IsSuperAdmin() then return true end
	return self:IsUserGroup("admin")
end

function meta:IsSuperAdmin()
	if self.IsFullyAuthenticated and not self:IsFullyAuthenticated() then return false end

	return self:IsUserGroup("superadmin")
end

function meta:IsUserGroup(name)	
	if self.IsFullyAuthenticated and not self:IsFullyAuthenticated() then return false end

	return self:GetNetworkedString("UserGroup") == name
end