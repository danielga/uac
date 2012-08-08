lemon.string = lemon.string or {}

//Locals for faster access (these are functions that should be "faster" than normal and are rarely changed)
local string_explode, string_len, string_byte, string_gsub = string.Explode, string.len, string.byte, string.gsub
local string_gfind, string_sub, string_match, string_format, string_char = string.gfind, string.sub, string.match, string.format, string.char
local table_getn, table_insert, table_concat = table.getn, table.insert, table.concat
local math_abs, math_min, math_floor, math_random = math.abs, math.min, math.floor, math.random
local pairs, tonumber, tostring, type = pairs, tonumber, tostring, type

function lemon.string:ParseINIData(text)
	local t = {}
	local section
	local lines = string_explode("\n", text)
	for i = 1, #lines do
		local s = string_match(lines[i], "^%[([^%]]+)%]$")
		if s then
			section = s
			t[section] = t[section] or {}
		end
		local key, value = string_match(lines[i], "^([%w_]+)%s-=%s-(.+)$")
		if tonumber(value) then value = tonumber(value) end
		if value == "true" then value = true end
		if value == "false" then value = false end
		if key and value then
			if section then
				t[section][key] = value
			else
				t[key] = value
			end
		end
	end
	
	return t
end

function lemon.string:CreateINIData(t)
	local contents = ""
	for section, s in pairs(t) do
		if type(s) == "table" then
			local sec = string_format("[%s]\n", section)
			for key, value in pairs(s) do
				sec = sec .. string_format("%s=%s\n", key, tostring(value))
			end
			contents = contents .. sec .. "\n"
		else
			contents = contents .. string_format("%s=%s\n", section, tostring(s)) .. "\n"
		end
	end

	return contents
end

function lemon.string:Levenshtein(s, t)
	local d, sn, tn = {}, string_len(s), string_len(t)
	for i = 0, sn do d[i * tn] = i end
	for j = 0, tn do d[j] = j end
	for i = 1, sn do
		local si = string_byte(s, i)
		for j = 1, tn do
			d[i * tn + j] = math_min(d[(i - 1) * tn + j] + 1, d[i * tn + j - 1] + 1, d[(i - 1) * tn + j - 1] + (si == string_byte(t, j) and 0 or 1))
		end
	end

	return d[table_getn(d)]
end

function lemon.string:DamerauLevenshtein(s, t, lim)
	local s_len, t_len = #s, #t -- Calculate the sizes of the strings or arrays
	if lim and math_abs(s_len - t_len) >= lim then -- If sizes differ by lim, we can stop here
		return lim
	end
	
	-- Convert string arguments to arrays of ints (ASCII values)
	if type(s) == "string" then
		s = {string_byte(s, 1, s_len)}
	end

	if type(t) == "string" then
		t = {string_byte(t, 1, t_len)}
	end

	local num_columns = t_len + 1 -- We use this a lot

	local d = {} -- (s_len+1) * (t_len+1) is going to be the size of this array
	-- This is technically a 2D array, but we're treating it as 1D. Remember that 2D access in the
	-- form my_2d_array[ i, j ] can be converted to my_1d_array[ i * num_columns + j ], where
	-- num_columns is the number of columns you had in the 2D array assuming row-major order and
	-- that row and column indices start at 0 (we're starting at 0).

	for i = 0, s_len do
		d[i * num_columns] = i -- Initialize cost of deletion
	end

	for j = 0, t_len do
		d[j] = j -- Initialize cost of insertion
	end

	for i = 1, s_len do
		local i_pos = i * num_columns
		local best = lim -- Check to make sure something in this row will be below the limit
		for j = 1, t_len do
			local add_cost = (s[i] ~= t[j] and 1 or 0)
			local val = math_min(d[i_pos - num_columns + j] + 1, /*Cost of deletion*/ d[i_pos + j - 1] + 1, /*Cost of insertion*/ d[i_pos - num_columns + j - 1] + add_cost /*Cost of substitution, it might not cost anything if it's the same*/)
			d[i_pos + j] = val

			-- Is this eligible for tranposition?
			if i > 1 and j > 1 and s[i] == t[j - 1] and s[i - 1] == t[j] then
				d[i_pos + j] = math_min(val, /*Current cost*/ d[i_pos - num_columns - num_columns + j - 2] + add_cost /*Cost of transposition*/)
			end

			if lim and val < best then
				best = val
			end
		end

		if lim and best >= lim then
			return lim
		end
	end

	return d[#d]
end

function lemon.string:StripQuotes(s)
	return string_gsub(s, "^[\"]*(.-)[\"]*[\r]?[\n]?$", "%1")
end

function lemon.string:SplitArgs(args)
	if args == nil or args == "" then return nil end
	local argv = {}
	local argc = 0
	local quoteFlag = false
	local strStore = ""

	for a in string_gfind(args, ".+") do
		if a ~= nil then
			if quoteFlag == false then
				if string_sub(a, 1, 1) == "\"" and string_sub(a, -1, -1) ~= "\"" then
					quoteFlag = true
					strStore = a
				else
					a = stripQuotes(a)
					table_insert(argv, a)
					argc = argc + 1
				end
			else
				if string_sub(a, -1, -1) == "\"" then
					quoteFlag = false
					strStore = strStore .. " " .. a
					strStore = stripQuotes(strStore)
					table_insert(argv, strStore)
					argc = argc + 1
				else
					strStore = strStore .. " " .. a
				end
			end
		end
	end

	return argv, argc
end

local Chars = {}
for Loop = 0, 255 do
	Chars[Loop + 1] = string_char(Loop)
end
local String = table_concat(Chars)
local Built = {['.'] = Chars}

local AddLookup = function(CharSet)
	local Substitute = string_gsub(String, '[^' .. CharSet .. ']', '')
	local Lookup = {}
	for Loop = 1, string_len(Substitute) do
		Lookup[Loop] = string_sub(Substitute, Loop, Loop)
	end
	Built[CharSet] = Lookup

	return Lookup
end

function lemon.string:RandomString(Length, CharSet)
	local CharSet = CharSet or '.'

	if CharSet == '' then
		return ''
	else
		local Result = {}
		local Lookup = Built[CharSet] or AddLookup(CharSet)
		local Range = table_getn(Lookup)

		for Loop = 1,Length do
			Result[Loop] = Lookup[math_random(1, Range)]
		end

		return table_concat(Result)
	end
end

function lemon.string:FormatTime(s)
	if type(s) ~= "number" then return "00:00:00:00" end
	local days = math_floor(s / 86400)
	s = s - (days * 86400)
	local hours = math_floor(s / 3600)
	s = s - (hours * 3600)
 	local minutes = math_floor(s / 60)
 	s = s - (minutes * 60)
 	return string_format("%0.2i:%0.2i:%0.2i:%0.2i", days, hours, minutes, s)
end