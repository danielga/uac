PLUGIN.Name = "Teleport"
PLUGIN.Description = "Adds commands to teleport players and yourself to a target."
PLUGIN.Author = "MetaMan"

PLUGIN:AddPermission("teleport", "Allows users to teleport to and bring others to them")

function PLUGIN:Bring(ply, target)
	if not IsValid(ply) then
		return
	end

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
	:SetPermission("teleport")
	:SetDescription("Bring the specified user to yourself")
	:AddParameter(uac.command.player)

function PLUGIN:Goto(ply, target)
	if not IsValid(ply) then
		return
	end
	
	local pos = target:FindFreeSpace(true)
	if pos then
		ply:SetPos(pos)
		ply:SetAngles((target:EyePos() - ply:GetShootPos()):Angle())
	end
end
PLUGIN:AddCommand({"tp", "goto"}, PLUGIN.Goto)
	:SetPermission("teleport")
	:SetDescription("Teleports yourself to the specified user")
	:AddParameter(uac.command.player)
