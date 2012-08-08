PLUGIN.Name = "Spawn protection"
PLUGIN.Description = "Gives godmode for the set ammount to players when they spawn."
PLUGIN.Author = "DrogenViech"

function PLUGIN:DisableGod(ply)
	if ValidEntity(ply) then
		ply:GodDisable()
		local r, g, b, a = ply:GetColor()
		ply:SetColor(r, g, b, 255)
	end
end


function PLUGIN:PlayerSpawn(ply)
	if tonumber(mp_spawnprotection:GetString()) ~= 0 then
		ply:GodEnable()
		local r, g, b, a = ply:GetColor()
		ply:SetColor(r, g, b, 100)
		timer.Create("lemon.ClearSpawnProtection " .. ply:UserID(), tonumber(mp_spawnprotection:GetString()), 1, self.DisableGod, self, ply)
	end
end

function PLUGIN:Load(reloaded)
	mp_spawnprotection = CreateConVar("mp_spawnprotection", "10", {FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Godmode after spawning in seconds (0 to disable)")
end