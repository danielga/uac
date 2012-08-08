lemon.plugin = lemon.plugin or {}
lemon.plugin.List = lemon.plugin.List or {}

lemon.plugin.hookCall = lemon.plugin.hookCall or hook.Call
function hook.Call(name, gm, ...)
	if lemon and lemon.plugin and lemon.plugin.List then
		for _, plugin in pairs(lemon.plugin.List) do
			if plugin[name] then
				local retValues = {pcall(plugin[name], plugin, ...)}
				if retValues[1] and retValues[2] != nil then
					table.remove(retValues, 1)
					return unpack(retValues)
				elseif not retValues[1] then
					ErrorNoHalt(retValues[2])
				end
			end
		end
	end

	return lemon.plugin.hookCall(name, gm, ...)
end

local PLUGINS
if SERVER then
	PLUGINS = {}
	function PLUGINS:AddCommand(name, func, flag, desc, usage)
		assert(type(name) == "string" and type(flag) == "string" and type(func) == "function", "[Lemon] PLUGINS:AddCommand used incorrectly.")
		if self then
			lemon.command:Add(name, func, flag, desc, usage, self)
		else
			lemon.command:Add(name, func, flag, desc, usage)
		end
	end
end

function lemon.plugin:Get(name)
	if self.List[name] then
		return self.List[name]
	end
end

function lemon.plugin:Load(name, reloaded)
	PLUGIN = {}
	if SERVER then setmetatable(PLUGIN, {__index = PLUGINS}) end

	include("lemon/plugins/" .. name)
	name = string.sub(name, 1, -5)
	name = string.sub(name, 4, -1)

	self.List[name] = PLUGIN
	self.List[name].pname = name

	if PLUGIN.Load then
		self.List[name].Load(self.List[name], reloaded)
	end
	
	PLUGIN = nil

	return true
end

function lemon.plugin:Reload(name)
	if self:UnloadPlugin(name, true) then
		self:LoadPlugin(name, true)
	end
end

function lemon.plugin:Unload(name, reloading)
	if self.List[name].CanUnload and self.List[name].CanUnload(self.List[name], reloading) then
		self.List[name].Unload(self.List[name], reloading)
	else
		return false
	end

	if SERVER and not reloading then
		for com, tab in pairs(lemon.command.List) do
			if tab.plugin.pname == name then
				lemon.command:Remove(name)
			end
		end
	end

	self.List[name] = nil

	return true
end