PLUGIN.Name = "Enter vehicle"
PLUGIN.Description = "Adds a command to force players into a vehicle."
PLUGIN.Author = "MetaMan"

function PLUGIN:EnterVehicle(ply, target)
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
	:SetAccess(uac.auth.access.slay)
	:SetDescription("Forces a user to enter the vehicle you're looking at")
	:AddParameter(uac.command.player)
