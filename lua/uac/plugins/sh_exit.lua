PLUGIN.Name = "Exit vehicle"
PLUGIN.Description = "Adds a command to force players out of a vehicle."
PLUGIN.Author = "MetaMan"

function PLUGIN:ExitVehicle(ply, target)
	if target:InVehicle() then
		target:ExitVehicle()
	end
end
PLUGIN:AddCommand("exit", PLUGIN.ExitVehicle)
	:SetAccess(ACCESS_SLAY)
	:SetDescription("Forces the specified user to exit the vehicle he's in")
	:AddParameter(uac.command.player)