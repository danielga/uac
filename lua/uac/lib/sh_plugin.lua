uac.plugin = uac.plugin or {}
local plugin_list = {}

local PLUGIN = {}
PLUGIN.__index = PLUGIN

if SERVER then
	function PLUGIN:AddCommand(name, func, flag, desc, usage)
		self.Commands[name] = true
		uac.command.Add(name, function(...) return func(self, ...) end, flag, desc, usage)
	end

	function PLUGIN:RemoveCommand(name)
		if not self.Commands[name] then
			return
		end

		self.Commands[name] = nil
		uac.command.Remove(name)
	end

	function PLUGIN:RemoveCommands()
		for name, _ in pairs(self.Commands) do
			uac.command.Remove(name)
		end
		self.Commands = {}
	end
end

function PLUGIN:AddHook(name, unique, func)
	if not self.Hooks[name] then
		self.Hooks[name] = {}
	end

	self.Hooks[name][unique] = true
	hook.Add(name, unique, function(...) return func(self, ...) end)
end

function PLUGIN:RemoveHook(name, unique)
	if not self.Hooks[name] or not self.Hooks[name][unique] then
		return
	end

	self.Hooks[name][unique] = nil
	hook.Remove(name, unique)
end

function PLUGIN:RemoveHooks(name)
	if name and not self.Hooks[name] then
		return
	end

	if name then
		for unique, _ in pairs(self.Hooks[name]) do
			hook.Remove(name, unique)
		end
		self.Hooks[name] = nil
	else
		for name, list in pairs(self.Hooks) do
			for unique, _ in pairs(list) do
				hook.Remove(name, unique)
			end
		end
		self.Hooks = {}
	end
end

function uac.plugin.GetList()
	return plugin_list
end

function uac.plugin.Get(name)
	return plugin_list[name]
end

function uac.plugin.New()
	return setmetatable({Hooks = {}, Commands = {}}, PLUGIN)
end

function uac.plugin.Register(plugin)
	local dbg = debug.getinfo(2, "S")
	plugin.FileName = (dbg and dbg.source) and dbg.source:match("[/\\]([^/\\]-)$") or "unknown"
	plugin_list[plugin.Name] = plugin

	return uac.plugin.Load(plugin)
end

function uac.plugin.Include(path)
	if path then
		local prefix = path:sub(1, 3)
		if SERVER and prefix == "sv_" then
			include("uac/plugins/" .. path)
		elseif prefix == "sh_" then
			include("uac/plugins/" .. path)
			if SERVER then
				AddCSLuaFile("uac/plugins/" .. path)
			end
		elseif prefix == "cl_" then
			if CLIENT then
				include("uac/plugins/" .. path)
			else
				AddCSLuaFile("uac/plugins/" .. path)
			end
		end
	else
		local files = file.Find("uac/plugins/*.lua", "LUA")
		for i = 1, #files do
			uac.plugin.Include(files[i])
		end
	end
end

function uac.plugin.Load(plugin, reloaded)
	if plugin.Active then
		return false
	end

	reloaded = reloaded or false
	if plugin.Load and plugin.Load(reloaded) then
		plugin.Active = true
		return true
	end

	return false
end

function uac.plugin.Reload(plugin)
	if plugin.CanUnload and not plugin:CanUnload(reloading) then
		return false
	end

	return (plugin.Unload == nil or plugin:Unload(true)) and (plugin.Load == nil or plugin:Load(true))
end

function uac.plugin.Unload(plugin, reloading)
	if not plugin.Active then return false end

	reloading = reloading or false
	if (plugin.CanUnload and not plugin:CanUnload(reloading)) or (plugin.Unload and not plugin:Unload(reloading)) then
		return false
	end

	if SERVER then plugin:RemoveCommands() end
	plugin:RemoveHooks()
	plugin.Active = false

	return true
end