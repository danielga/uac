uac = uac or {}

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
				include(sv_file)
			elseif file.Exists(cl_file, "LUA") and CLIENT then
				include(cl_file)
			elseif file.Exists(sh_file, "LUA") then
				include(sh_file)
			end
		else
			local sh_file = ("uac/libraries/sh_%s.lua"):format(path)
			local sv_file = ("uac/libraries/sv_%s.lua"):format(path)
			local cl_file = ("uac/libraries/cl_%s.lua"):format(path)

			if file.Exists(sh_file, "LUA") then
				if SERVER then
					AddCSLuaFile(sh_file)
				end

				include(sh_file)
			end

			if file.Exists(sv_file, "LUA") and SERVER then
				include(sv_file)
			end

			if file.Exists(cl_file, "LUA") then
				if CLIENT then
					include(cl_file)
				else
					AddCSLuaFile(cl_file)
				end
			end
		end
	else
		local included_libs = {}

		local files, directories = file.Find("uac/libraries/*", "LUA")
		for i = 1, #files do
			local match = files[i]:match("^%a%a_(%w+)%.lua$")
			if not included_libs[match] then
				included_libs[match] = true
				uac.IncludeLibrary(match)
			end
		end

		for i = 1, #directories do
			local dir = directories[i]
			if not included_libs[dir] then
				included_libs[dir] = true
				uac.IncludeLibrary(dir)
			end
		end
	end
end

uac.IncludeLibrary()