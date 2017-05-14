PLUGIN.Name = "Vehicle driver management"
PLUGIN.Description = "Adds commands to force players into and out of a vehicle."
PLUGIN.Author = "MetaMan"

PLUGIN:AddPermission("vehicle", "Allows users to force others to enter/exit vehicles")

function PLUGIN:EnterVehicle(ply, target)
	if not IsValid(ply) then
		return
	end

	local vehicle = ply:GetEyeTrace().Entity
	if not IsValid(vehicle) then
		return
	end

	if target:Alive() then
		if IsValid(vehicle) and vehicle:IsVehicle() then
			if IsValid(vehicle:GetDriver()) then vehicle:GetDriver():ExitVehicle() end
			target:EnterVehicle(vehicle)
		end
	end
end
PLUGIN:AddCommand("enter", PLUGIN.EnterVehicle)
	:SetPermission("vehicle")
	:SetDescription("Forces a user to enter the vehicle you're looking at")
	:AddParameter(uac.command.player)

function PLUGIN:ExitVehicle(ply, target)
	if target:InVehicle() then
		target:ExitVehicle()
	end
end
PLUGIN:AddCommand("exit", PLUGIN.ExitVehicle)
	:SetPermission("vehicle")
	:SetDescription("Forces the specified user to exit the vehicle he's in")
	:AddParameter(uac.command.player)
