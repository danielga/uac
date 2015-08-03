include("shared.lua")

function uac.command.GetAutoComplete(prefix, command, argstr, showusage)
	local ply = LocalPlayer()
	local candidates = {}
	for com, tab in pairs(uac.command.GetList()) do
		if string.sub(com, 1, #command) == command then
			if showusage then
				table.insert(candidates, string.format("%s%s%s%s", prefix, com, tab:GetUsage()))
			else
				local autocompletes = tab:GetAutoComplete(ply, argstr)
				for i = 1, #autocompletes do
					local space, ac = autocompletes[i] ~= "" and " " or "", autocompletes[i]
					table.insert(candidates, string.format("%s%s%s%s", prefix, com, space, ac))
				end
			end
		end
	end

	table.sort(candidates)
	return candidates
end

concommand.Add("uac", function(ply, command, args, argstr)
	if #args == 0 then
		return
	end

	command, argstr = uac.command.Split(argstr)

	net.Start("uac_command_execute")
	net.WriteString(command)

	local hasargs = argstr ~= nil
	net.WriteBool(hasargs)
	if hasargs then
		net.WriteString(argstr)
	end

	net.SendToServer()

	return uac.command.Run(ply, command, argstr)
end, function(command, argstr)
	command, argstr = uac.command.Split(string.sub(argstr, 2))
	return uac.command.GetAutoComplete("uac ", command, argstr)
end)