PLUGIN.Name = "Goto"
PLUGIN.Description = "Adds a command to teleport to players."
PLUGIN.Author = "MetaMan"

function PLUGIN:FindFreeSpace(ply, behind)
	local plypos = ply:GetPos()
	local plyang = ply:EyeAngles()	
	local yaw =  math.floor(plyang.y / 45 + 0.5) * 45 --snap to 45 degree.
	
	local size = Vector(32, 32, 72)
	local StartPos = plypos + Vector(0, 0, size.z / 2) --start in the middle of the player
	
	--now find free space behind or infront of player.
	d = {0, 45, -45}
	for i = 1, 3 do --try 0, then 45, then -45
		local Pos
		if not behind then
			Pos = StartPos - Vector(math.cos(yaw - d[i]), math.sin(yaw - d[i])) * size * 1.5
		else
			Pos = StartPos + Vector(math.cos(yaw - d[i]), math.sin(yaw - d[i])) * size * 1.5
		end

		local tr = {}
		tr.start = Pos
		tr.endpos = Pos
		tr.mins = size / 2 * -1
		tr.maxs = size / 2

		local trace = util.TraceHull(tr)
		if not trace.Hit then
			return Pos - Vector(0, 0, size.z / 2)
		end
	end

	return nil
end

function PLUGIN:TeleTo(ply, target)
	local pos = self:FindFreeSpace(target, true)
	if pos then
		ply:SetPos(pos)
		ply:SetAngles((target:EyePos() - ply:GetShootPos()):Angle())
	end
end
PLUGIN:AddCommand({"tp", "goto"}, PLUGIN.TeleTo)
	:SetAccess(ACCESS_SLAY)
	:SetDescription("Teleports yourself to the specified user")
	:AddParameter(uac.command.player)