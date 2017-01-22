uac = uac or {
	libraries = {}
}

local included_libs = uac.libraries

if not file.IsDir("uac", "DATA") then
	file.CreateDir("uac")
end

function uac.IncludeLibrary(path)
	if path then
		local folder = string.format("uac/libraries/%s", path)

		local sv_file = folder .. "/server.lua"
		local sh_file = folder .. "/shared.lua"
		local cl_file = folder .. "/client.lua"

		if SERVER and file.Exists(sv_file, "LUA") then
			print("[UAC] Library (serverside) directory: " .. path)
			include(sv_file)
			return
		elseif CLIENT and file.Exists(cl_file, "LUA") then
			print("[UAC] Library (clientside) directory: " .. path)
			include(cl_file)
			return
		elseif file.Exists(sh_file, "LUA") then
			print("[UAC] Library (shared) directory: " .. path)
			include(sh_file)
			return
		end

		sh_file = string.format("uac/libraries/sh_%s.lua", path)
		sv_file = string.format("uac/libraries/sv_%s.lua", path)
		cl_file = string.format("uac/libraries/cl_%s.lua", path)

		if file.Exists(sh_file, "LUA") then
			print("[UAC] Library (shared) file: " .. path)

			if SERVER then
				AddCSLuaFile(sh_file)
			end

			include(sh_file)
		end

		if SERVER and file.Exists(sv_file, "LUA") then
			print("[UAC] Library (serverside) file: " .. path)
			include(sv_file)
		end

		if file.Exists(cl_file, "LUA") then
			print("[UAC] Library (clientside) file: " .. path)

			if CLIENT then
				include(cl_file)
			else
				AddCSLuaFile(cl_file)
			end
		end
	else
		local files, directories = file.Find("uac/libraries/*", "LUA")
		for i = 1, #files do
			local match = string.match(files[i], "^%a%a_(%w+)%.lua$")
			if not included_libs[match] then
				uac.IncludeLibrary(match)
				included_libs[match] = uac[match] or true
			end
		end

		for i = 1, #directories do
			local dir = directories[i]
			if not included_libs[dir] then
				uac.IncludeLibrary(dir)
				included_libs[dir] = uac[dir] or true
			end
		end
	end
end

uac.IncludeLibrary()
