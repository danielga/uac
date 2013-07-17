lemon.auth = lemon.auth or {}
local users_list = {}

hook.Remove("PlayerInitialSpawn", "PlayerAuthSpawn") -- we don't want stuff to break right?

function lemon.auth:UpdateUserFlags(steamid, flags)
	if users_list[steamid] then
		if users_list[steamid].flags == flags then
			return
		else
			users_list[steamid].flags = flags
		end
	else
		users_list[steamid] = {usergroup = "", flags = flags}
	end

	local prefix = lemon.sql:EscapeString(lemon.config:Get("LEMON_PREFIX"))
	steamid = lemon.sql:EscapeString(steamid)

	lemon.sql:Query("SELECT * FROM " .. prefix .. "_users WHERE steamid = '" .. steamid .. "'", function(succeeded, data)
		if succeeded and #data > 0 then
			lemon.sql:Query("UPDATE " .. prefix .. "_users SET flags = '" .. lemon.sql:EscapeString(flags) .. "' WHERE steamid = '" .. steamid .. "'")
		else
			lemon.sql:Query("INSERT INTO " .. prefix .. "_users (steamid, flags) VALUES ('" .. steamid .. "', '" .. lemon.sql:EscapeString(flags) .. "')")
		end
	end)
end

function lemon.auth:UpdateUserGroup(steamid, usergroup)
	if users_list[steamid] then
		if users_list[steamid].usergroup == usergroup then
			return
		else
			users_list[steamid].usergroup = usergroup
		end
	else
		users_list[steamid] = {usergroup = usergroup, flags = ""}
	end

	local prefix = lemon.sql:EscapeString(lemon.config:Get("LEMON_PREFIX"))
	steamid = lemon.sql:EscapeString(steamid)

	lemon.sql:Query("SELECT * FROM " .. prefix .. "_users WHERE steamid = '" .. steamid .. "'", function(succeeded, data)
		if succeeded and #data > 0 then
			lemon.sql:Query("UPDATE " .. prefix .. "_users SET usergroup = '" .. lemon.sql:EscapeString(usergroup) .. "' WHERE steamid = '" .. steamid .. "'")
		else
			lemon.sql:Query("INSERT INTO " .. prefix .. "_users (steamid, usergroup) VALUES ('" .. steamid .. "', '" .. lemon.sql:EscapeString(usergroup) .. "')")
		end
	end)
end

function lemon.auth:LoadUsersList()
	local prefix = lemon.sql:EscapeString(lemon.config:Get("LEMON_PREFIX"))

	lemon.sql:Query("SELECT * FROM " .. prefix .. "_users", function(succeeded, data)
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
			lemon.sql:Query("CREATE TABLE " .. prefix .. "_users (steamid CHAR(20), usergroup CHAR(50), flags CHAR(50))")
		end
	end)
end

hook.Add("PlayerAuthed", "lemon.auth.AuthPlayer", function(player)
	local data = users_list[player:SteamID()]
	if data then
		player:SetUserGroup(data.usergroup)
		player:SetUserFlags(data.flags)
	end
end)

function lemon.auth:LoadUsersFile(filepath)
	local data = file.Read(filepath, "DATA")
	if not data then return end
	data = util.KeyValuesToTable(data)
	if data then
		for steamid, tbl in pairs(data) do
			steamid = steamid:upper()
			users_list[steamid] = {usergroup = tbl.usergroup or "users", flags = tbl.flags or ""}

			local player = self:GetPlayerFromSteamID(steamid)
			if IsValid(player) and player:IsPlayer() then
				player:SetUserGroup(data.usergroup)
				player:SetUserFlags(data.flags)
			else
				self:UpdateUserGroup(steamid, data.usergroup)
				self:UpdateUserFlags(steamid, data.flags)
			end
		end
	end
end

function lemon.auth:SaveUsersFile(filepath)
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
	lemon.auth:UpdateUserFlags(self:SteamID(), flags)

	self:SetNWString("UserFlags", flags)
	--local old_ug = self:GetDTString(3):match("{UserGroup:([^}]*)}")
	--self:SetDTString(3, ("{UserFlags:%s}{UserGroup:%s}"):format(flags, old_ug or ""))
end

function meta:SetUserGroup(name)
	if not self:IsFullyAuthenticated() then return end

	name = name or ""
	lemon.auth:UpdateUserGroup(self:SteamID(), name)

	self:SetNWString("UserGroup", name)
	--local old_uf = self:GetDTString(3):match("{UserFlags:([^}]*)}")
	--self:SetDTString(3, ("{UserFlags:%s}{UserGroup:%s}"):format(old_uf or "", name))
end

------------------------------------------------------------------

if not file.Exists("lemon/default_users.txt", "DATA") then
	file.Write("lemon/default_users.txt", 
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

hook.Add("Initialize", "lemon.auth.LoadUsersList", function()
	lemon.auth:LoadUsersFile("lemon/users.txt")
	lemon.auth:LoadUsersList()
end)