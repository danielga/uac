uac.string = uac.string or {}

local type = type
local tonumber = tonumber
local tostring = tostring
local math_min = math.min
local math_abs = math.abs
local string_byte = string.byte
local string_gmatch = string.gmatch
local string_format = string.format
local string_sub = string.sub
local string_gsub = string.gsub
local string_find = string.find

function uac.string.Levenshtein(s, t)
	local d, sn, tn = {}, #s, #t

	for i = 0, sn do
		d[i * tn] = i
	end

	for j = 0, tn do
		d[j] = j
	end

	for i = 1, sn do
		local si = string_byte(s, i)
		for j = 1, tn do
			d[i * tn + j] = math_min(d[(i - 1) * tn + j] + 1, d[i * tn + j - 1] + 1, d[(i - 1) * tn + j - 1] + (si == string_byte(t, j) and 0 or 1))
		end
	end

	return d[#d]
end

function uac.string.DamerauLevenshtein(s, t, lim)
	local s_len, t_len = #s, #t
	if lim and math_abs(s_len - t_len) >= lim then
		return lim
	end

	if isstring(s) then
		s = {string_byte(s, 1, s_len)}
	end

	if isstring(t) then
		t = {string_byte(t, 1, t_len)}
	end

	local num_columns = t_len + 1

	local d = {}
	for i = 0, s_len do
		d[i * num_columns] = i
	end

	for j = 0, t_len do
		d[j] = j
	end

	for i = 1, s_len do
		local i_pos = i * num_columns
		local best = lim
		for j = 1, t_len do
			local add_cost = (s[i] ~= t[j] and 1 or 0)
			local val = math_min(d[i_pos - num_columns + j] + 1, d[i_pos + j - 1] + 1, d[i_pos - num_columns + j - 1] + add_cost)
			d[i_pos + j] = val

			if i > 1 and j > 1 and s[i] == t[j - 1] and s[i - 1] == t[j] then
				d[i_pos + j] = math_min(val, d[i_pos - num_columns - num_columns + j - 2] + add_cost)
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

function uac.string.Format(text, ...)
	local matched = {}
	local substitutes = {...}

	for match in string_gmatch(text, "({%d+})") do
		local match_number = tonumber(string_sub(match, 2, -2))
		if match_number ~= nil and matched[match_number] == nil then
			if select(match_number, ...) == nil then
				error(string_format("No substitute found for {%i}.", match_number))
			end

			matched[match_number] = true
			text = string_gsub(text, match, tostring(select(match_number, ...)))
		end
	end

	return text
end

function uac.string.IsSteamIDValid(steamid)
	return isstring(steamid) and string_find(steamid, "^STEAM_%d:%d:%d+$") ~= nil
end

function uac.string.IsSteamID64Valid(steamid64)
	return isstring(steamid64) and #steamid64 == 17 and string_find(steamid64, "^7656119%d+$") ~= nil
end

function uac.string.IsIPValid(ip)
	return isstring(ip) and string_find(ip, "^%d+.%d+.%d+.%d+$") ~= nil
end

function uac.string.EncodeULEB128(values, ...)
	local bytes = ""

	local is_table = istable(values)
	local size = is_table and #values or select("#", values, ...)
	for i = 1, size do
		local value = is_table and values[i] or select(i, values, ...)

		repeat
			local byte = bit.band(value, 0x7F)
			value = bit.rshift(value, 7)
			bytes = bytes .. string.char(value == 0 and byte or bit.bor(byte, 0x80))
		until value == 0
	end

	return bytes
end

function uac.string.DecodeULEB128(bytes)
	local offset = 1
	local values = {}

	while offset <= #bytes do
		local value = 0
		local byte = 0
		local shift = 0

		repeat
			byte = string.byte(bytes, offset)
			value = bit.bor(value, bit.lshift(bit.band(byte, 0x7F), shift))
			offset = offset + 1
			shift = shift + 7
		until bit.band(byte, 0x80) == 0 or offset > #bytes

		table.insert(values, value)
	end

	return values
end
