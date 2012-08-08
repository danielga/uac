lemon.command = lemon.command or {}
lemon.command.List = lemon.command.List or {}

function lemon.command:Add(name, func, flag, desc, usage, plugin)
	self.List[name] = {func = func, flag = flag, desc = desc, usage = usage, plugin = plugin}
	lemon.usermessage:SendGlobal("le_com_ACA", name, usage or "")
end

function lemon.command:Remove(name)
	if not self.List[name] then return end

	self.List[name] = nil
	lemon.usermessage:SendGlobal("le_com_ACR", name)
end

function lemon.command:Run(ply, command, arguments)
	command = string.lower(command)
	if self.List[command] ~= nil then
		if ply:HasUserFlag(self.List[command].flag) then
			local did, err
			if self.List[command].plugin then
				did, err = pcall(self.List[command].func, self.List[command].plugin, ply, command, arguments)
			else
				did, err = pcall(self.List[command].func, ply, command, arguments)
			end

			if not did then
				ply:ChatMessage(Color(255, 0, 0, 255), "[Lemon] ", Color(255, 255, 255, 255), "Error: '" .. err .. "'.")
				return false
			end

			return true
		else
			ply:ChatMessage(Color(255, 0, 0, 255), "[Lemon] ", Color(255, 255, 255, 255), "Error: You need the '" .. self.List[command].flag .. "' flag in order to use this command.")
			return false
		end
	end

	local closest_command = ""
	local closest_distance = 99
	for com, data in pairs(self.List) do
		local distance = lemon.string:Levenshtein(command, com)
		if distance < closest_distance then
			closest_distance = distance
			closest_command = com
		end
	end

	if closest_distance <= 0.25 * #closest_command then
		ply:ChatMessage(Color(255, 0, 0, 255), "[Lemon] ", Color(255, 255, 255, 255), "Did you mean '" .. closest_command .. "'? Since it is very close, this command was ran instead.")
		return lemon.command:Run(ply, closest_command, arguments)
	end
	
	if ply:IsValid() then
		ply:ChatMessage(Color(255, 0, 0, 255), "[Lemon] ", Color(255, 255, 255, 255), "Unknown command '" .. command .. "'.")
	end
	
	return false
end

concommand.Add("_le", function(ply, command, args)
	if #args == 0 then
		return
	end

	command = args[1]
	table.remove(args, 1)

	if #args > 0 then // THIS IS FULL OF HAX
		local args_text = table.concat(args, " ")
		args = {}
		for match in string.gmatch(string.sub(args_text, string.len(args_text) + 3, -1), "[^,]+") do
			table.insert(args, match)
		end
	end

	lemon.command:Run(ply, command, args)
end)

function lemon.command:AutoCompleteSync(ply)
	local commands = {}
	for k, v in pairs(self.List) do
		table.insert(commands, k)
		table.insert(commands, v.usage or "")
	end

	lemon.usermessage:Send("le_com_ACS", ply, unpack(commands))
end
hook.Add("LemonPlayerInitialSpawn", "lemon_AutoCompleteSync", function(ply) lemon.command:AutoCompleteSync(ply) end)