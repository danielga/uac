uac.plugin = uac.plugin or {
	list = {}
}

local plugin_list = uac.plugin.list

local PLUGIN = {}
PLUGIN.__index = PLUGIN

function PLUGIN:GetCommands()
	return self.commands
end

function PLUGIN:AddCommand(name, func)
	local command = uac.command.Add(name, function(...)
		return func(self, ...)
	end)

	local commands = self:GetCommands()
	commands[name] = {
		enabled = true,
		command = command
	}

	return command
end

function PLUGIN:RemoveCommand(name)
	local commands = self:GetCommands()
	if not commands[name] then
		return
	end

	commands[name] = nil
	uac.command.Remove(name)
end

function PLUGIN:EnableCommands()
	for name, data in pairs(self:GetCommands()) do
		if not data.enabled then
			data.enabled = false
			uac.command.Add(name, data.command)
		end
	end
end

function PLUGIN:DisableCommands()
	for name, data in pairs(self:GetCommands()) do
		if data.enabled then
			data.enabled = false
			uac.command.Remove(name)
		end
	end
end

function PLUGIN:GetHooks()
	return self.hooks
end

function PLUGIN:AddHook(name, unique, func)
	local hooks = self:GetHooks()
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

function PLUGIN:RemoveHook(name, unique)
	local hooks = self:GetHooks()
	if not hooks[name] or not hooks[name][unique] then
		return
	end

	hooks[name][unique] = nil
	hook.Remove(name, unique)
end

function PLUGIN:EnableHooks()
	for name, hooks in pairs(self:GetHooks()) do
		for unique, data in pairs(hooks) do
			if not data.enabled then
				data.enabled = false
				hook.Add(name, unique, data.callback)
			end
		end
	end
end

function PLUGIN:DisableHooks()
	for name, hooks in pairs(self:GetHooks()) do
		for unique, data in pairs(hooks) do
			if data.enabled then
				data.enabled = false
				hook.Remove(name, unique)
			end
		end
	end
end

function uac.plugin.GetList()
	return plugin_list
end

function uac.plugin.Get(name)
	return plugin_list[name]
end

function uac.plugin.Include(name)
	if name then
		local loaded = false
		local plugin = setmetatable({
			enabled = true,
			name = name,
			hooks = {},
			commands = {}
		}, PLUGIN)
		_G.PLUGIN = plugin

		local folder = string.format("uac/plugins/%s", name)
		if file.IsDir(folder, "LUA") then
			local sv_file = string.format("%s/server.lua", folder)
			local sh_file = string.format("%s/shared.lua", folder)
			local cl_file = string.format("%s/client.lua", folder)

			plugin.folder = folder

			if file.Exists(sv_file, "LUA") and SERVER then
				loaded = true
				include(sv_file)
			elseif file.Exists(cl_file, "LUA") and CLIENT then
				loaded = true
				include(cl_file)
			elseif file.Exists(sh_file, "LUA") then
				loaded = true
				include(sh_file)
			end
		else
			local sh_file = string.format("uac/plugins/sh_%s.lua", name)
			local sv_file = string.format("uac/plugins/sv_%s.lua", name)
			local cl_file = string.format("uac/plugins/cl_%s.lua", name)

			plugin.folder = "uac/plugins"

			if file.Exists(sh_file, "LUA") then
				loaded = true

				if SERVER then
					AddCSLuaFile(sh_file)
				end

				include(sh_file)
			end

			if file.Exists(sv_file, "LUA") and SERVER then
				loaded = true
				include(sv_file)
			end

			if file.Exists(cl_file, "LUA") then
				loaded = true

				if CLIENT then
					include(cl_file)
				else
					AddCSLuaFile(cl_file)
				end
			end
		end

		_G.PLUGIN = nil

		if loaded then
			print("[UAC] Plugin: \"" .. name .. "\"")
			plugin_list[name] = plugin
			uac.plugin.Load(name)
		end
	else
		local included_plugins = {}

		local files, directories = file.Find("uac/plugins/*", "LUA")
		for i = 1, #files do
			local match = string.match(files[i], "^%a%a_(%w+)%.lua$")
			if match ~= nil and not included_plugins[match] then
				included_plugins[match] = true
				uac.plugin.Include(match)
			end
		end

		for i = 1, #directories do
			local dir = directories[i]
			if not included_plugins[dir] then
				included_plugins[dir] = true
				uac.plugin.Include(dir)
			end
		end
	end
end
hook.Add("Initialize", "uac.plugin.Include", uac.plugin.Include)

function uac.plugin.Load(name, reloaded)
	local plugin = plugin_list[name]
	if not plugin or plugin.enabled then
		return false
	end

	reloaded = reloaded or false
	if plugin.Load and plugin.Load(reloaded) then
		plugin.enabled = true
		return true
	end

	plugin:EnableCommands()
	plugin:EnableHooks()

	return false
end

function uac.plugin.Reload(name)
	if not uac.plugin.Unload(name, true) then
		return false
	end

	return uac.plugin.Load(name, true)
end

function uac.plugin.Unload(name, reloading)
	local plugin = plugin_list[name]
	if not plugin or not plugin.Enabled then
		return false
	end

	plugin:DisableCommands()
	plugin:DisableHooks()

	reloading = reloading or false
	if (plugin.CanUnload and not plugin:CanUnload(reloading)) or (plugin.Unload and not plugin:Unload(reloading)) then
		return false
	end

	plugin.enabled = false

	return true
end