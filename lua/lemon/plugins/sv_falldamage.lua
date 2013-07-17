local PLUGIN = lemon.plugin:New()

PLUGIN.Name = "Fall damage"
PLUGIN.Description = "Adds realistic fall damage."
PLUGIN.Author = "DrogenViech"

function PLUGIN:GetFallDamage(ply, speed)
	if GetConVarNumber("mp_falldamage") >= 1 then -- might be better to apply fall damage in case mp_falldamage > 1
		return (speed - 580) * (100 / (1024 - 580))
	end

	return 0
end
PLUGIN:AddHook("GetFallDamage", "Lemon realistic fall damage plugin", PLUGIN.GetFallDamage)

lemon.plugin:Register(PLUGIN)