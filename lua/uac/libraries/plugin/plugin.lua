local PLUGIN = {__index = {}}
local PLUGIN_INDEX = PLUGIN.__index

function PLUGIN_INDEX:GetCommands()
	return self.commands
end

function PLUGIN_INDEX:AddCommand(name, func)
	local command = uac.command.Add(name, function(...)
		return func(self, ...)
	end)

	local commands = self.commands
	commands[name] = {
		enabled = true,
		command = command
	}

	return command
end

function PLUGIN_INDEX:RemoveCommand(name)
	local commands = self.commands
	if not commands[name] then
		return
	end

	commands[name] = nil
	uac.command.Remove(name)
end

function PLUGIN_INDEX:EnableCommands()
	for name, data in pairs(self.commands) do
		if not data.enabled then
			data.enabled = true
			uac.command.Add(name, data.command)
		end
	end
end

function PLUGIN_INDEX:DisableCommands()
	for name, data in pairs(self.commands) do
		if data.enabled then
			data.enabled = false
			uac.command.Remove(name)
		end
	end
end

function PLUGIN_INDEX:GetHooks()
	return self.hooks
end

function PLUGIN_INDEX:AddHook(name, unique, func)
	local hooks = self.hooks
	if not hooks[name] then
		hooks[name] = {}
	end

	local callback = function(...)
		return func(self, ...)
	end

	hooks[name][unique] = {
		enabled = true,
		callback = callback
	}

	hook.Add(name, unique, callback)
end

function PLUGIN_INDEX:RemoveHook(name, unique)
	local hooks = self.hooks
	if not hooks[name] or not hooks[name][unique] then
		return
	end

	hooks[name][unique] = nil
	hook.Remove(name, unique)
end

function PLUGIN_INDEX:EnableHooks()
	for name, hooks in pairs(self.hooks) do
		for unique, data in pairs(hooks) do
			if not data.enabled then
				data.enabled = false
				hook.Add(name, unique, data.callback)
			end
		end
	end
end

function PLUGIN_INDEX:DisableHooks()
	for name, hooks in pairs(self.hooks) do
		for unique, data in pairs(hooks) do
			if data.enabled then
				data.enabled = false
				hook.Remove(name, unique)
			end
		end
	end
end

function PLUGIN_INDEX:GetHooks()
	return self.hooks
end

function PLUGIN_INDEX:AddPermission(name, description)
	uac.permission.Add(name, description)
end

return PLUGIN
