lemon.plugin = lemon.plugin or {}
local plugin_list = {}

local PLUGINS = {}
PLUGINS.__index = PLUGINS

if SERVER then
	function PLUGINS:AddCommand(name, func, flag, desc, usage)
		self.Commands[name] = true
		lemon.command:Add(name, function(...) return func(self, ...) end, flag, desc, usage)
	end

	function PLUGINS:RemoveCommand(name)
		if not self.Commands[name] then
			return
		end

		self.Commands[name] = nil
		lemon.command:Remove(name)
	end

	function PLUGINS:RemoveCommands()
		for name, _ in pairs(self.Commands) do
			lemon.command:Remove(name)
		end
		self.Commands = {}
	end

	function PLUGINS:Notify(...)
		lemon.chat:AddText(...)
	end
end

function PLUGINS:AddHook(name, unique, func)
	if not self.Hooks[name] then
		self.Hooks[name] = {}
	end

	self.Hooks[name][unique] = true
	hook.Add(name, unique, function(...) return func(self, ...) end)
end

function PLUGINS:RemoveHook(name, unique)
	if not self.Hooks[name] or not self.Hooks[name][unique] then
		return
	end

	self.Hooks[name][unique] = nil
	hook.Remove(name, unique)
end

function PLUGINS:RemoveHooks(name)
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

function lemon.plugin:GetList()
	return plugin_list
end

function lemon.plugin:Get(name)
	return plugin_list[name]
end

function lemon.plugin:New()
	return setmetatable({Hooks = {}, Commands = {}}, PLUGINS)
end

function lemon.plugin:Register(plugin)
	local dbg = debug.getinfo(2, "S")
	plugin.FileName = (dbg and dbg.source) and dbg.source:match("[/\\]([^/\\]-)$") or "unknown"
	plugin_list[plugin.Name] = plugin

	return lemon.plugin:Load(plugin)
end

function lemon.plugin:Include(file)
	local prefix = file:sub(1, 3)
	if SERVER and prefix == "sv_" then
		include("lemon/plugins/" .. file)
	elseif prefix == "sh_" then
		include("lemon/plugins/" .. file)
		if SERVER then
			AddCSLuaFile("lemon/plugins/" .. file)
		end
	elseif prefix == "cl_" then
		if CLIENT then
			include("lemon/plugins/" .. file)
		else
			AddCSLuaFile("lemon/plugins/" .. file)
		end
	end
end

function lemon.plugin:IncludeAll()
	local files = file.Find("lemon/plugins/*.lua", "LUA")
	for i = 1, #files do
		self:Include(files[i])
	end
end

function lemon.plugin:Load(plugin, reloaded)
	if plugin.Active then return false end

	reloaded = reloaded or false
	if plugin.Load and plugin:Load(reloaded) then
		plugin.Active = true
		return true
	end

	return false
end

function lemon.plugin:Reload(plugin)
	if plugin.CanUnload and not plugin:CanUnload(reloading) then
		return false
	end

	return (plugin.Unload == nil or plugin:Unload(true)) and (plugin.Load == nil or plugin:Load(true))
end

function lemon.plugin:Unload(plugin, reloading)
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