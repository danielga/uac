include("shared.lua")

local autocomfmt = "%s%s"
local autocomusage = "%s%s %s"
function uac.command.GetAutoComplete(prefix, command, argstr, showusage)
	local ply = LocalPlayer()
	local candidates = {}
	for com, tab in pairs(uac.command.GetList()) do
		if com:sub(1, #command) == command then
			if showusage then
				table.insert(candidates, autocomusage:format(prefix, com, tab:GetUsage()))
			else
				if argstr then
					local autocompletes = tab:GetAutoComplete(ply, argstr)
					for i = 1, #autocompletes do
						table.insert(candidates, autocomusage:format(prefix, com, autocompletes[i]))
					end
				else
					table.insert(candidates, autocomfmt:format(prefix, com))
				end
			end
		end
	end

	return candidates
end

concommand.Add("uac", function(ply, command, args, argstr)
	if #args == 0 then
		return
	end

	command, argstr = uac.command.Split(argstr)

	net.Start("uac_command_EXE")
	net.WriteString(command)
	net.WriteString(argstr)
	net.SendToServer()

	return uac.command.Run(ply, command, argstr)
end, function(command, argstr)
	command, argstr = uac.command.Split(argstr:sub(2))
	return uac.command.GetAutoComplete("uac ", command, argstr)
end)