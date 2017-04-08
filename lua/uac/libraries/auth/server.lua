AddCSLuaFile("shared.lua")
include("shared.lua")

uac.auth = uac.auth or {
	users = {}
}

local users_list = uac.auth.users

hook.Remove("PlayerInitialSpawn", "PlayerAuthSpawn") -- we don't want stuff to break right?

function uac.auth.SetRole(steamid, role)
	users_list[steamid] = role
end

function uac.auth.LoadUsersList()

end

function uac.auth.SaveUsersList()

end

hook.Add("PlayerAuthed", "uac.auth.GameHost", function(ply)
	if ply:IsGameHost() then
		ply:SetRole("superadmin")
	end
end)

hook.Add("NetworkIDValidated", "uac.auth.UpdateRole", function(name, steamid)
	local role = users_list[steamid]
	if role ~= nil then
		local ply = uac.player.GetPlayerFromSteamID(steamid)
		if ply ~= nil then
			ply:SetRole(role)
		end
	end
end)

hook.Add("Initialize", "uac.auth.LoadUsers", function()
	uac.auth.LoadUsersList()
end)
