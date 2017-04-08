AddCSLuaFile()
AddCSLuaFile("plugin.lua")

uac.plugin = uac.plugin or {
	list = {}
}

local plugin_list = uac.plugin.list
local PLUGIN = include("plugin.lua")

function uac.plugin.Include(name)
	if name ~= nil then
		local loaded = false
		local plugin = setmetatable({
			enabled = true,
			name = name,
			hooks = {},
			commands = {}
		}, PLUGIN)
		_G.PLUGIN = plugin

		local folder = string.format("uac/plugins/%s", name)

		local sv_file = folder .. "/server.lua"
		local sh_file = folder .. "/shared.lua"
		local cl_file = folder .. "/client.lua"

		plugin.folder = folder

		if SERVER and file.Exists(sv_file, "LUA") then
			loaded = true
			include(sv_file)
		elseif CLIENT and file.Exists(cl_file, "LUA") then
			loaded = true
			include(cl_file)
		elseif file.Exists(sh_file, "LUA") then
			loaded = true
			include(sh_file)
		end

		if not loaded then
			sh_file = string.format("uac/plugins/sh_%s.lua", name)
			sv_file = string.format("uac/plugins/sv_%s.lua", name)
			cl_file = string.format("uac/plugins/cl_%s.lua", name)

			plugin.folder = "uac/plugins"

			if file.Exists(sh_file, "LUA") then
				loaded = true

				if SERVER then
					AddCSLuaFile(sh_file)
				end

				include(sh_file)
			end

			if SERVER and file.Exists(sv_file, "LUA") then
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
	if plugin == nil or plugin.enabled then
		return false
	end

	reloaded = reloaded or false
	if plugin.Load ~= nil and not plugin:Load(reloaded) then
		return false
	end

	plugin.enabled = true
	plugin:EnableCommands()
	plugin:EnableHooks()

	return true
end

function uac.plugin.Reload(name)
	if not uac.plugin.Unload(name, true) then
		return false
	end

	return uac.plugin.Load(name, true)
end

function uac.plugin.Unload(name, reloading)
	local plugin = plugin_list[name]
	if plugin == nil or not plugin.enabled then
		return false
	end

	reloading = reloading or false
	if (plugin.CanUnload ~= nil and not plugin:CanUnload(reloading)) or
		(plugin.Unload ~= nil and not plugin:Unload(reloading)) then
		return false
	end

	plugin:DisableCommands()
	plugin:DisableHooks()
	plugin.enabled = false

	return true
end
