PLUGIN.Name = "Bring"
PLUGIN.Description = "Adds a command to bring players to yourself."
PLUGIN.Author = "MetaMan"

function PLUGIN:Bring(ply, target)
	if ply:Alive() then
		if ply:InVehicle() then
			ply:ExitVehicle()
		end

		local pos = ply:FindFreeSpace(false)
		if pos then
			target:SetPos(pos)
			target:SetAngles((ply:EyePos() - target:GetShootPos()):Angle())
		end
	end
end
PLUGIN:AddCommand("bring", PLUGIN.Bring)
	:SetAccess(ACCESS_SLAY)
	:SetDescription("Bring the specified user to yourself")
	:AddParameter(uac.command.player)
