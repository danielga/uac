lemon.auth = lemon.auth or {}
lemon.auth.UsersList = {}

function lemon.auth:UpdateUserFlags(steamid, flags)
	local sql_table = lemon.sql:PrepareString(lemon.config:GetValue("LEMON_USERS_TABLE"))

	lemon.sql:Query("SELECT * FROM " .. sql_table .. " WHERE steamid = " .. lemon.sql:PrepareString(steamid), function(succeeded, data)
		if succeeded and data then
			lemon.sql:Query("UPDATE " .. sql_table .. " SET flags = " .. lemon.sql:PrepareString(flags) .. " WHERE steamid = " .. lemon.sql:PrepareString(steamid))
		else
			lemon.sql:Query("INSERT INTO " .. sql_table .. " (steamid, flags) VALUES (" .. lemon.sql:PrepareString(steamid) .. ", " .. lemon.sql:PrepareString(flags) .. ")")
		end
	end)
end

function lemon.auth:UpdateUserGroup(steamid, usergroup)
	local sql_table = lemon.sql:PrepareString(lemon.config:GetValue("LEMON_USERS_TABLE"))

	lemon.sql:Query("SELECT * FROM " .. sql_table .. " WHERE steamid = " .. lemon.sql:PrepareString(steamid), function(succeeded, data)
		if succeeded and data then
			lemon.sql:Query("UPDATE " .. sql_table .. " SET usergroup = " .. lemon.sql:PrepareString(usergroup) .. " WHERE steamid = " .. lemon.sql:PrepareString(steamid))
		else
			lemon.sql:Query("INSERT INTO " .. sql_table .. " (steamid, usergroup) VALUES (" .. lemon.sql:PrepareString(steamid) .. ", " .. lemon.sql:PrepareString(usergroup) .. ")")
		end
	end)
end

function lemon.auth:LoadUsersList() //There should never be the need to load (more than once) the whole list.
	local sql_table = lemon.sql:PrepareString(lemon.config:GetValue("LEMON_USERS_TABLE"))

	lemon.sql:Query("SELECT * FROM " .. sql_table, function(succeeded, data)
		if succeeded and data then
			for _, plydata in pairs(data) do
				self.UsersList[plydata.steamid] = {usergroup = plydata.usergroup or "users", flags = plydata.flags or ""}
			end

			for _, player in ipairs(player.GetAll()) do
				local plydata = self.UsersList[player:SteamID()]
				if plydata then
					player:SetUserGroup(plydata.usergroup)
					player:SetUserFlags(plydata.flags)
				end
			end
		else
			lemon.sql:Query("CREATE TABLE " .. sql_table .. " (steamid CHAR(20), usergroup CHAR(50), flags CHAR(50))")
		end
	end)
end
hook.Add("PostGamemodeLoaded", "lemon.auth.LoadUsersList", function() lemon.auth:LoadUsersList() end)

function lemon.auth:SaveUsersList() //There should never be the need to save the whole list.
	local sql_table = lemon.sql:PrepareString(lemon.config:GetValue("LEMON_USERS_TABLE"))

	lemon.sql:Query("SELECT * FROM " .. sql_table, function(succeeded, data)
		if succeeded and data then
			for steamid, data in pairs(self.UsersList) do
				self:UpdateUserFlags(steamid, data.flags or "")
				self:UpdateUserGroup(steamid, data.usergroup or "users")
			end
		else
			lemon.sql:Query("CREATE TABLE " .. sql_table .. " (steamid CHAR(20), usergroup CHAR(50), flags CHAR(50))")

			for steamid, data in pairs(self.UsersList) do
				self:UpdateUserFlags(steamid, data.flags or "")
				self:UpdateUserGroup(steamid, data.usergroup or "users")
			end
		end
	end)
end

function lemon.auth:ClearUsersList() //In case there's a fucked up table or just can't bother to remove admins one by one.
	local sql_table = lemon.sql:PrepareString(lemon.config:GetValue("LEMON_USERS_TABLE"))
	self.UsersList = {}

	lemon.sql:Query("SELECT * FROM " .. sql_table, function(succeeded, data)
		if succeeded and data then
			lemon.sql:Query("DROP TABLE " .. sql_table)
		end
	end)
end

function lemon.auth:AuthPlayer(player)
	local data = self.UsersList[player:SteamID()]
	if data then
		player:SetUserGroup(data.usergroup)
		player:SetUserFlags(data.flags)
	end
end
hook.Add("LemonPlayerInitialSpawn", "lemon.auth.AuthPlayer", function(ply) lemon.auth:AuthPlayer(ply) end)

function lemon.auth:LoadUsersFile(filepath)
	if file.Exists(filepath) then
		local data = file.Read(filepath)
		data = util.KeyValuesToTable(data)
		if data then
			for steamid, tab in pairs(data) do
				steamid = string.upper(steamid)
				self.UsersList[steamid] = {usergroup = tab.usergroup or "users", flags = tab.flags or ""}

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
end

function lemon.auth:SaveUsersFile(filepath)
	if self.UsersList then
		local data = util.TableToKeyValues(self.UsersList)
		local secondquote = string.find(data, "\"", 2, true)
		data = string.sub(data, secondquote)
		data = "\"Users" .. data
		if data then
			file.Write(filepath, data)
		end
	end
end

//------------------------------------------------------------------

local meta = FindMetaTable("Player")
if not meta then return end

function meta:SetUserFlags(flags)
	if self.IsFullyAuthenticated and not self:IsFullyAuthenticated() then return end

	flags = flags or ""

	local steamid = self:SteamID()
	if not lemon.auth.UsersList[steamid] then lemon.auth.UsersList[steamid] = {} end
	lemon.auth.UsersList[steamid].flags = flags

	lemon.auth:UpdateUserFlags(self:SteamID(), flags)

	self:SetNetworkedString("LemonUserFlags", flags)
end

function meta:SetUserGroup(name)
	if self.IsFullyAuthenticated and not self:IsFullyAuthenticated() then return end

	local steamid = self:SteamID()
	if not lemon.auth.UsersList[steamid] then lemon.auth.UsersList[steamid] = {} end
	lemon.auth.UsersList[steamid].usergroup = name

	lemon.auth:UpdateUserGroup(self:SteamID(), name)

	self:SetNetworkedString("UserGroup", name)
end