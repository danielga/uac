uac.string = uac.string or {}

function uac.string.DamerauLevenshteinDistance(a, b)
	local s_len, t_len = #a, #b

	if type(a) == "string" then
		a = {string.byte(a, 1, s_len)}
	end

	if type(b) == "string" then
		b = {string.byte(b, 1, t_len)}
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
		for j = 1, t_len do
			local add_cost = (a[i] ~= b[j] and 1 or 0)
			local val = math.min(d[i_pos - num_columns + j] + 1, d[i_pos + j - 1] + 1, d[i_pos - num_columns + j - 1] + add_cost)
			d[i_pos + j] = val

			if i > 1 and j > 1 and a[i] == b[j - 1] and a[i - 1] == b[j] then
				d[i_pos + j] = math.min(val, d[i_pos - num_columns - num_columns + j - 2] + add_cost)
			end
		end
	end

	return d[#d]
end

function uac.string.DamerauLevenshteinDistance(a, b)
	local a_len = #a
	local b_len = #b
	local maxdist = a_len + b_len

	local da = {}

	local d = {}
	d[1] = maxdist

	for i = 1, a_len do
		d[i * (a_len + 2)] = maxdist
		d[i * (a_len + 2) + 1] = i
	end

	for j = 1, b_len do
		d[j] = maxdist
		d[a_len + 2 + j] = j
	end

	for i = 1, a_len do
		local a_byte = string.byte(a, i)
		local db = 0

		for j = 1, b_len do
			local b_byte = string.byte(b, j)
			local k = da[b_byte] or 0
			local l = db
			local cost = 0
			if a_byte == b_byte then
				db = j
			else
				cost = 1
			end

			d[i][j] = math.min(	d[i - 1][j - 1] + cost, //substitution
								d[i][j - 1] + 1, //insertion
								d[i - 1][j] + 1, //deletion
								d[k - 1][l - 1] + (i - k - 1) + 1 + (j - l - 1)) //transposition
		end

		da[a_byte] = i
	end

	return d[a_len][b_len]
end

function uac.string.Format(text, ...)
	local matched = {}

	for match in string.gmatch(text, "({%d+})") do
		local match_number = tonumber(string.sub(match, 2, -2))
		if match_number ~= nil and matched[match_number] == nil then
			local substitute = select(match_number, ...)
			if substitute == nil then
				error(string.format("No substitute found for {%i}.", match_number))
			end

			matched[match_number] = true
			text = string.gsub(text, match, tostring(substitute))
		end
	end

	return text
end

function uac.string.IsSteamIDValid(steamid)
	return isstring(steamid) and string.find(steamid, "^STEAM_%d:%d:%d+$") ~= nil
end

function uac.string.IsSteamID64Valid(steamid64)
	return isstring(steamid64) and #steamid64 == 17 and string.find(steamid64, "^7656119%d+$") ~= nil
end

function uac.string.IsIPValid(ip)
	return isstring(ip) and string.find(ip, "^%d+.%d+.%d+.%d+$") ~= nil
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

local Base64Encode = util.Base64Encode
function uac.string.Base64Encode(input)
	local data = Base64Encode(input)
	return data and string.gsub(data, "[\r\n]", "") or data
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
	input = string.gsub(input, "%s+", "") -- remove whitespace (newlines, spaces)

	local m = #input % 4
	assert(m == 0, "invalid encoding: input is not divisible by 4")

	local out = {}
	local done = false

	for i = 1, #input, 4 do
		if i + 3 > #input then
			break
		end

		assert(not done, "invalid encoding: trailing characters")

		local a, b, c, d = string.byte(input, i, i + 3)

		assert(db64table[a] and db64table[b] and db64table[c] and db64table[d], "invalid encoding: invalid character")

		local x = bit.bor(bit.band(bit.lshift(db64table[a], 2), 0xfc), bit.band(bit.rshift(db64table[b], 4), 0x03))
		local y = bit.bor(bit.band(bit.lshift(db64table[b], 4), 0xf0), bit.band(bit.rshift(db64table[c], 2), 0x0f))
		local z = bit.bor(bit.band(bit.lshift(db64table[c], 6), 0xc0), bit.band(db64table[d], 0x3f))

		if c == 0x3d then
			assert(d == 0x3d, "invalid encoding: invalid character")
			out[#out + 1] = string.char(x)
			done = true
		elseif d == 0x3d then
			out[#out + 1] = string.char(x, y)
			done = true
		else
			out[#out + 1] = string.char(x, y, z)
		end
	end

	return table.concat(out)
end
