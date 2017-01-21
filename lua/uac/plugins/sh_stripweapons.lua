PLUGIN.Name = "Strip weapons"
PLUGIN.Description = "Adds a command to strip players of weapons."
PLUGIN.Author = "MetaMan"

function PLUGIN:StripWeapons(ply, target)
	if target:Alive() then
		target:StripWeapons()
	end
end
PLUGIN:AddCommand("strip", PLUGIN.StripWeapons)
	:SetAccess(uac.auth.access.slay)
	:SetDescription("Strips a player of their weapons")
	:AddParameter(uac.command.player)
