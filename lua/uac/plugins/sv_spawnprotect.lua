local PLUGIN = uac.plugin.New()

PLUGIN.Name = "Spawn protection"
PLUGIN.Description = "Gives godmode for the set ammount to players when they spawn."
PLUGIN.Author = "DrogenViech"

local mp_spawnprotection
function PLUGIN:DisableGod(ply)
	if IsValid(ply) then
		ply:GodDisable()
		local color = ply:GetColor()
		color.a = 255
		ply:SetColor(color)
	end
end

function PLUGIN:PlayerSpawn(ply)
	local length = mp_spawnprotection:GetInt()
	if length ~= nil and length > 0 then
		ply:GodEnable()
		local color = ply:GetColor()
		color.a = 100
		ply:SetColor(color)
		timer.Create("uac.ClearSpawnProtection " .. ply:UserID(), length, 1, function()
			self:DisableGod(ply)
		end)
	end
end
PLUGIN:AddHook("PlayerSpawn", "UAC spawn protection plugin", PLUGIN.PlayerSpawn)

function PLUGIN:Load(reloaded)
	mp_spawnprotection = CreateConVar("mp_spawnprotection", 10, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Godmode after spawning in seconds (0 to disable)")
end

uac.plugin.Register(PLUGIN)