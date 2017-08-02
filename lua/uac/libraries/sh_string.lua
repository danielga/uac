uac.string = uac.string or {}

local type = type
local tonumber = tonumber
local tostring = tostring
local select = select
local setmetatable = setmetatable
local ipairs = ipairs
local error = error
local assert = assert
local math_min = math.min
local math_abs = math.abs
local string_byte = string.byte
local string_gmatch = string.gmatch
local string_format = string.format
local string_sub = string.sub
local string_gsub = string.gsub
local string_find = string.find
local string_char = string.char
local table_concat = table.concat
local table_insert = table.insert
local bit_bor = bit.bor
local bit_band = bit.band
local bit_rshift = bit.rshift
local bit_lshift = bit.lshift

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
			local byte = bit_band(value, 0x7F)
			value = bit_rshift(value, 7)
			bytes = bytes .. string_char(value == 0 and byte or bit_bor(byte, 0x80))
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
			byte = string_byte(bytes, offset)
			value = bit_bor(value, bit_lshift(bit_band(byte, 0x7F), shift))
			offset = offset + 1
			shift = shift + 7
		until bit_band(byte, 0x80) == 0 or offset > #bytes

		table_insert(values, value)
	end

	return values
end

local Base64Encode = util.Base64Encode
function uac.string.Base64Encode(input)
	local data = Base64Encode(input)
	return data and string_gsub(data, "[\r\n]", "") or data
end

local db64table = {
	[ 43] = 62, [ 47] = 63, [ 48] = 52, [ 49] = 53, [ 50] = 54, [ 51] = 55,
	[ 52] = 56, [ 53] = 57, [ 54] = 58, [ 55] = 59, [ 56] = 60, [ 57] = 61,
	[ 61] =  0, [ 65] =  0, [ 66] =  1, [ 67] =  2, [ 68] =  3, [ 69] =  4,
	[ 70] =  5, [ 71] =  6, [ 72] =  7, [ 73] =  8, [ 74] =  9, [ 75] = 10,
	[ 76] = 11, [ 77] = 12, [ 78] = 13, [ 79] = 14, [ 80] = 15, [ 81] = 16,
	[ 82] = 17, [ 83] = 18, [ 84] = 19, [ 85] = 20, [ 86] = 21, [ 87] = 22,
	[ 88] = 23, [ 89] = 24, [ 90] = 25, [ 97] = 26, [ 98] = 27, [ 99] = 28,
	[100] = 29, [101] = 30, [102] = 31, [103] = 32, [104] = 33, [105] = 34,
	[106] = 35, [107] = 36, [108] = 37, [109] = 38, [110] = 39, [111] = 40,
	[112] = 41, [113] = 42, [114] = 43, [115] = 44, [116] = 45, [117] = 46,
	[118] = 47, [119] = 48, [120] = 49, [121] = 50, [122] = 51
}

function uac.string.Base64Decode(input)
	input = string_gsub(input, "%s+", "") -- remove whitespace (newlines, spaces)

	local m = #input % 4
	assert(m == 0, "invalid encoding: input is not divisible by 4")

	local out = {}
	local done = false

	for i = 1, #input, 4 do
		if i + 3 > #input then
			break
		end

		assert(not done, "invalid encoding: trailing characters")

		local a, b, c, d = string_byte(input, i, i + 3)

		assert(db64table[a] and db64table[b] and db64table[c] and db64table[d], "invalid encoding: invalid character")

		local x = bit_bor(bit_band(bit_lshift(db64table[a], 2), 0xfc), bit_band(bit_rshift(db64table[b], 4), 0x03))
		local y = bit_bor(bit_band(bit_lshift(db64table[b], 4), 0xf0), bit_band(bit_rshift(db64table[c], 2), 0x0f))
		local z = bit_bor(bit_band(bit_lshift(db64table[c], 6), 0xc0), bit_band(db64table[d], 0x3f))

		if c == 0x3d then
			assert(d == 0x3d, "invalid encoding: invalid character")
			out[#out + 1] = string_char(x)
			done = true
		elseif d == 0x3d then
			out[#out + 1] = string_char(x, y)
			done = true
		else
			out[#out + 1] = string_char(x, y, z)
		end
	end

	return table_concat(out)
end
