uac = uac or {
	libraries = {}
}

local included_libs = uac.libraries

if not file.IsDir("uac", "DATA") then
	file.CreateDir("uac")
end

function uac.IncludeLibrary(path)
	if path then
		if file.IsDir(("uac/libraries/%s"):format(path), "LUA") then
			local sv_file = ("uac/libraries/%s/server.lua"):format(path)
			local sh_file = ("uac/libraries/%s/shared.lua"):format(path)
			local cl_file = ("uac/libraries/%s/client.lua"):format(path)

			if file.Exists(sv_file, "LUA") and SERVER then
				print("[UAC] Library: " .. path)
				include(sv_file)
			elseif file.Exists(cl_file, "LUA") and CLIENT then
				print("[UAC] Library: " .. path)
				include(cl_file)
			elseif file.Exists(sh_file, "LUA") then
				print("[UAC] Library: " .. path)
				include(sh_file)
			end
		else
			local sh_file = ("uac/libraries/sh_%s.lua"):format(path)
			local sv_file = ("uac/libraries/sv_%s.lua"):format(path)
			local cl_file = ("uac/libraries/cl_%s.lua"):format(path)

			if file.Exists(sh_file, "LUA") then
				print("[UAC] Library: " .. path)

				if SERVER then
					AddCSLuaFile(sh_file)
				end

				include(sh_file)
			end

			if file.Exists(sv_file, "LUA") and SERVER then
				print("[UAC] Library: " .. path)

				include(sv_file)
			end

			if file.Exists(cl_file, "LUA") then
				print("[UAC] Library: " .. path)

				if CLIENT then
					include(cl_file)
				else
					AddCSLuaFile(cl_file)
				end
			end
		end
	else
		local files, directories = file.Find("uac/libraries/*", "LUA")
		for i = 1, #files do
			local match = files[i]:match("^%a%a_(%w+)%.lua$")
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
