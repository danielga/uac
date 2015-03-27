uac.auth = uac.auth or {}
local users_list = {}

hook.Remove("PlayerInitialSpawn", "PlayerAuthSpawn") -- we don't want stuff to break right?

function uac.auth.UpdateUserFlags(steamid, flags)
	if users_list[steamid] then
		if users_list[steamid].flags == flags then
			return
		else
			users_list[steamid].flags = flags
		end
	else
		users_list[steamid] = {usergroup = "", flags = flags}
	end

	local prefix = uac.sql.EscapeString(uac.config.GetValue("uac_prefix"))
	steamid = uac.sql.EscapeString(steamid)

	uac.sql.Query("SELECT * FROM " .. prefix .. "_users WHERE steamid = '" .. steamid .. "'", function(succeeded, data)
		if succeeded and #data > 0 then
			uac.sql.Query("UPDATE " .. prefix .. "_users SET flags = '" .. uac.sql:EscapeString(flags) .. "' WHERE steamid = '" .. steamid .. "'")
		else
			uac.sql.Query("INSERT INTO " .. prefix .. "_users (steamid, flags) VALUES ('" .. steamid .. "', '" .. uac.sql:EscapeString(flags) .. "')")
		end
	end)
end

function uac.auth.UpdateUserGroup(steamid, usergroup)
	if users_list[steamid] then
		if users_list[steamid].usergroup == usergroup then
			return
		else
			users_list[steamid].usergroup = usergroup
		end
	else
		users_list[steamid] = {usergroup = usergroup, flags = ""}
	end

	local prefix = uac.sql.EscapeString(uac.config.GetValue("uac_prefix"))
	steamid = uac.sql.EscapeString(steamid)

	uac.sql.Query("SELECT * FROM " .. prefix .. "_users WHERE steamid = '" .. steamid .. "'", function(succeeded, data)
		if succeeded and #data > 0 then
			uac.sql.Query("UPDATE " .. prefix .. "_users SET usergroup = '" .. uac.sql:EscapeString(usergroup) .. "' WHERE steamid = '" .. steamid .. "'")
		else
			uac.sql.Query("INSERT INTO " .. prefix .. "_users (steamid, usergroup) VALUES ('" .. steamid .. "', '" .. uac.sql:EscapeString(usergroup) .. "')")
		end
	end)
end

function uac.auth.LoadUsersList()
	local prefix = uac.sql.EscapeString(uac.config.GetValue("uac_prefix"))

	uac.sql.Query("SELECT * FROM " .. prefix .. "_users", function(succeeded, data)
		if succeeded and #data > 0 then
			for i = 1, #data do
				local plydata = data[i]
				users_list[plydata.steamid] = {usergroup = plydata.usergroup or "users", flags = plydata.flags or ""}
			end

			local plys = player.GetAll()
			for i = 1, #plys do
				local player = plys[i]
				local plydata = users_list[player:SteamID()]
				if plydata then
					player:SetUserGroup(plydata.usergroup)
					player:SetUserFlags(plydata.flags)
				end
			end
		else
			uac.sql.Query("CREATE TABLE " .. prefix .. "_users (steamid CHAR(20), usergroup CHAR(50), flags CHAR(50))")
		end
	end)
end

hook.Add("PlayerAuthed", "uac.auth.AuthPlayer", function(player)
	local data = users_list[player:SteamID()]
	if data then
		player:SetUserGroup(data.usergroup)
		player:SetUserFlags(data.flags)
	end
end)

function uac.auth.LoadUsersFile(filepath)
	local data = file.Read(filepath, "DATA")
	if not data then return end
	data = util.KeyValuesToTable(data)
	if data then
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
end

function uac.auth.SaveUsersFile(filepath)
	local data = util.TableToKeyValues(users_list)
	if not data then return end
	data = data:gsub("[^\n]*", "\"Users\"")
	if data then
		file.Write(filepath, data)
	end
end

------------------------------------------------------------------

local meta = FindMetaTable("Player")
if not meta then return end

function meta:SetUserFlags(flags)
	if not self:IsFullyAuthenticated() then return end

	flags = flags or ""
	uac.auth:UpdateUserFlags(self:SteamID(), flags)

	self:SetNWString("UserFlags", flags)
end

function meta:SetUserGroup(name)
	if not self:IsFullyAuthenticated() then return end

	name = name or ""
	uac.auth:UpdateUserGroup(self:SteamID(), name)

	self:SetNWString("UserGroup", name)
end

------------------------------------------------------------------

if not file.Exists("uac/default_users.txt", "DATA") then
	file.Write("uac/default_users.txt", 
[[// This is the default users file. If you wish to add users, please do so in a new file named users.txt
"Users"
{
//	"Example"
//	{
//		"flags"			"abcdefghijklmnopqrstuvwxyz"
//		"usergroup"		"superadmin"
//		"steamid"		"STEAM_0:0:0"
//	}
}]])
end

hook.Add("Initialize", "uac.Auth.LoadUsers", function()
	uac.auth.LoadUsersFile("uac/users.txt")
	uac.auth.LoadUsersList()
end)