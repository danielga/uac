PLUGIN.Name = "Fall damage"
PLUGIN.Description = "Adds realistic fall damage."
PLUGIN.Author = "DrogenViech"

function PLUGIN:GetFallDamage(ply, speed)
	if GetConVarNumber("mp_falldamage") == 1 then
		speed = speed - 580
		return speed * (100 / (1024 - 580))
	end
	return 0
end