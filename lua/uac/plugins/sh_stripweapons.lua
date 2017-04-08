PLUGIN.Name = "Weapon stripping"
PLUGIN.Description = "Adds a command to strip players of weapons."
PLUGIN.Author = "MetaMan"

PLUGIN:AddPermission("strip", "Allows users to strip players of their weapons")

function PLUGIN:StripWeapons(ply, target, weapon)
	if target:Alive() then
		if weapon ~= nil then
			target:StripWeapon(weapon)
		else
			target:StripWeapons()
		end
	end
end
PLUGIN:AddCommand("strip", PLUGIN.StripWeapons)
	:SetPermission("strip")
	:SetDescription("Strips a player of their weapon(s)")
	:AddParameter(uac.command.player)
	:AddParameter(uac.command.string(uac.command.optional))
