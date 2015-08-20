AddCSLuaFile("shared.lua")

uac.auth = uac.auth or {
	users = {}
}

local users_list = uac.auth.users

include("shared.lua")

hook.Remove("PlayerInitialSpawn", "PlayerAuthSpawn") -- we don't want stuff to break right?

function uac.auth.UpdateUserFlags(steamid, flags)
	if users_list[steamid] then
		users_list[steamid].flags = flags
	else
		users_list[steamid] = {usergroup = "", flags = flags}
	end

	local prefix = uac.config.GetValue("uac_prefix")

	-- insert if not exists, update otherwise, upsert/merge?
end

function uac.auth.UpdateUserGroup(steamid, usergroup)
	if users_list[steamid] then
		users_list[steamid].usergroup = usergroup
	else
		users_list[steamid] = {usergroup = usergroup, flags = ""}
	end

	local prefix = uac.config.GetValue("uac_prefix")

	-- insert if not exists, update otherwise, upsert/merge?
end

function uac.auth.LoadUsersList()
	local prefix = uac.config.GetValue("uac_prefix")

	-- try to create table at initialization
	-- select all users on LoadUsersList
end

hook.Add("PlayerAuthed", "uac.auth.AuthPlayer", function(player)
	if game.SinglePlayer() or player:IsListenServerHost() then
		player:SetUserGroup("superadmin")
		return
	end

	local data = users_list[player:SteamID()]
	if data ~= nil then
		player:SetUserGroup(data.usergroup)
		player:SetUserFlags(data.flags)
	end
end)

function uac.auth.LoadUsersFile(filepath)
	local data = file.Read(filepath, "DATA")
	if data == nil then
		return
	end

	data = util.KeyValuesToTable(data)
	if data == nil then
		return
	end

	for steamid, tbl in pairs(data) do
		steamid = steamid:upper()
		users_list[steamid] = {usergroup = tbl.usergroup or "users", flags = tbl.flags or ""}

		local player = uac.player.GetPlayerFromSteamID(steamid)
		if IsValid(player) and player:IsPlayer() then
			player:SetUserGroup(data.usergroup)
			player:SetUserFlags(data.flags)
		else
			uac.auth.UpdateUserGroup(steamid, data.usergroup)
			uac.auth.UpdateUserFlags(steamid, data.flags)
		end
	end
end

function uac.auth.SaveUsersFile(filepath)
	local data = util.TableToKeyValues(users_list, "Users")
	if data ~= nil then
		file.Write(filepath, data)
	end
end

------------------------------------------------------------------

local PLAYER = FindMetaTable("Player")

function PLAYER:SetUserFlags(flags)
	flags = flags or ""
	uac.auth.UpdateUserFlags(self:SteamID(), flags)
	self:SetNWString("UserFlags", flags)
end

function PLAYER:SetUserGroup(name)
	name = name or ""
	uac.auth.UpdateUserGroup(self:SteamID(), name)
	self:SetNWString("UserGroup", name)
end

------------------------------------------------------------------

if not file.Exists("uac/default_users.txt", "DATA") then
	local default_users =
[[// This is the default users file. If you wish to add users, please do so in a new file named users.txt
"Users"
{
//	"Example"
//	{
//		"flags"			"abcdefghijklmnopqrstuvwxyz"
//		"usergroup"		"superadmin"
//		"steamid"		"STEAM_0:0:0"
//	}
}]]

	file.Write("uac/default_users.txt", default_users)
end

hook.Add("Initialize", "uac.auth.LoadUsers", function()
	uac.auth.LoadUsersFile("uac/users.txt")
	uac.auth.LoadUsersList()
end)
