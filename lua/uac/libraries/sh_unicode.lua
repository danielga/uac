uac.unicode = uac.unicode or {
	uppercase = {},
	lowercase = {},
	titlecase = {},
	decomposition = {},
	similar = {}
}

local uppercase = uac.unicode.uppercase
local lowercase = uac.unicode.lowercase
local titlecase = uac.unicode.titlecase
local decomposition = uac.unicode.decomposition
local similar = uac.unicode.similar

if not file.IsDir("uac/unicode", "DATA") then
	file.CreateDir("uac/unicode")
end

local tonumber = tonumber
local string_gmatch = string.gmatch
local string_gsub = string.gsub
local string_sub = string.sub
local string_char = string.char
local string_format = string.format
local string_byte = string.byte
local string_Split = string.Split
local string_Trim = string.Trim
local math_floor = math.floor
local table_concat = table.concat
local file_Read = file.Read
local lshift = bit.lshift

function uac.unicode.CodePoint(seq, offset)
	if #seq == 0 then
		return -1
	end

	offset = offset or 1

	local codepoint = string_byte(seq, offset)
	local length = 1
	if codepoint < 128 then
		return codepoint, length
	elseif codepoint < 192 then
		codepoint = -1
	elseif codepoint < 224 then
		length = 2
		if #seq < offset + 1 then
			return -1, length
		end

		codepoint = (codepoint % 32) * 64 + (string_byte(seq, offset + 1) % 64)
	elseif codepoint < 240 then
		length = 3
		if #seq < offset + 2 then
			return -1, length
		end

		local b1, b2 = string_byte(seq, offset + 1, offset + 2)
		codepoint = (codepoint % 16) * 4096 + (b1 % 64) * 64 + (b2 % 64)
	elseif codepoint < 248 then
		length = 4
		if #seq < offset + 3 then
			return -1, length
		end

		local b1, b2, b3 = string_byte(seq, offset + 1, offset + 3)
		codepoint = (codepoint % 8) * 262144 + (b1 % 64) * 4096 + (b2 % 64) * 64 + (b3 % 64)
	else
		codepoint = -1
	end

	return codepoint, length
end

function uac.unicode.Character(codepoint)
	if codepoint < 0 then
		return ""
	elseif codepoint < 2 ^ 7 then
		return string_char(codepoint)
	elseif codepoint < 2 ^ 11 then
		return string_char(
			192 + math_floor(codepoint / 64),
			128 + (codepoint % 64)
		)
	elseif codepoint < 2 ^ 16 then
		return string_char(
			224 + math_floor(codepoint / 4096),
			128 + (math_floor(codepoint / 64) % 64),
			128 + (codepoint % 64)
		)
	elseif codepoint < 2 ^ 21 then
		return string_char(
			240 + math_floor(codepoint / 262144),
			128 + (math_floor(codepoint / 4096) % 64),
			128 + (math_floor(codepoint / 64) % 64),
			128 + (codepoint % 64)
		)
	end

	return ""
end

function uac.unicode.SequenceLength(str, offset)
	local byte = string_byte(str, offset)
	if byte == nil then
		return 0
	elseif byte >= 240 then
		return 4
	elseif byte >= 224 then
		return 3
	elseif byte >= 192 then
		return 2
	end

	return 1
end

local SequenceLength = uac.unicode.SequenceLength
function uac.unicode.Sequence(str, offset)
	offset = offset or 1
	if offset <= 0 then
		offset = 1
	end

	local length = SequenceLength(str, offset)
	return string_sub(str, offset, offset + length - 1), offset + length
end

local Sequence = uac.unicode.Sequence
function uac.unicode.Iterator(str, offset, noseq)
	offset = offset or 1
	if offset <= 0 then
		offset = 1
	end

	if noseq then
		return function()
			if offset > #str then
				return nil, #str + 1
			end
			
			local len = SequenceLength(str, offset)
			local lastOffset = offset
			offset = offset + len
			return len, lastOffset
		end
	end

	return function()
		if offset > #str then
			return nil, #str + 1
		end
		
		local char, pos = Sequence(str, offset)
		local lastOffset = offset
		offset = pos
		return char, lastOffset
	end
end

local Iterator = uac.unicode.Iterator
function uac.unicode.DecomposeSequence(str, offset)
	local seq = Sequence(str, offset)
	local decomposed = decomposition[seq]
	if decomposed == nil then
		return seq
	end
	
	local decomp = ""
	for seq in Iterator(decomposed) do
		decomp = decomp .. uac.unicode.DecomposeSequence(seq)
	end

	return decomp
end

local DecomposeSequence = uac.unicode.DecomposeSequence
function uac.unicode.Decompose(str)
	local map = {}
	local invmap = {}
	local t = {}
	
	local outoffset = 1
	for seq, offset in Iterator(str) do
		local decomposition = DecomposeSequence(seq)
		t[#t + 1] = decomposition

		map[offset] = outoffset
		invmap[outoffset] = offset
		outoffset = outoffset + #decomposition
	end

	map[#str + 1] = outoffset
	invmap[outoffset] = #str + 1
	return table_concat(t), map, invmap
end

local function Compare(left, right)
	local l = lowercase[left] ~= nil and lowercase[left] or left
	local r = lowercase[right] ~= nil and lowercase[right] or right
	if l == r then
		return true
	end

	local similars = similar[left]
	if similars ~= nil then
		for i = 1, #similars do
			local s = similars[i]
			local l = lowercase[s] ~= nil and lowercase[s] or s
			local r = lowercase[right] ~= nil and lowercase[right] or right
			if l == r then
				return true
			end
		end
	end

	return false
end

local Decompose = uac.unicode.Decompose
function uac.unicode.Similar(left, right)
	left, map, invmap = Decompose(left)
	right = Decompose(right)

	for len, lpos in Iterator(left, 1, true) do
		local match = true
		local lastpos = lpos
		local iterator = Iterator(left, lpos)
		for rseq, rpos in Iterator(right) do
			local lseq, pos = iterator()
			lastpos = pos + 1
			if not Compare(lseq, rseq) then
				match = false
				break
			end
		end

		if match then
			return true, map[lpos], invmap[lastpos] - 1
		end
	end

	return false
end

local Character = uac.unicode.Character
function uac.unicode.ParseUnicodeData()
	local data = file_Read("data/uac/unicodedata8.0.0.txt", "GAME")
	if data == nil then
		return false
	end

	data = string_Split(data, "\n")
	if data == nil then
		return false
	end

	for i = 1, #data do
		local line = string_Trim(data[i])
		if #line == 0 or string_sub(line, 1, 1) == "#" then
			continue
		end

		local columns = string_Split(line, ";")
		local codepoint = tonumber("0x" .. (columns[1] or "0")) or 0

		if columns[6] ~= nil and #columns[6] ~= 0 then
			local decomps = string_Split(columns[6], " ")
			local decomp = ""
			for i = 1, #decomps do
				local codepoint = tonumber("0x" .. decomps[i])
				if codepoint ~= nil then
					decomp = decomp .. Character(codepoint)
				end
			end

			decomposition[Character(codepoint)] = decomp
		end

		if columns[13] ~= nil and #columns[13] ~= 0 then
			uppercase[Character(codepoint)] = Character(tonumber("0x" .. columns[13]))
		end

		if columns[14] ~= nil and #columns[14] ~= 0 then
			lowercase[Character(codepoint)] = Character(tonumber("0x" .. columns[14]))
		end

		if columns[15] ~= nil and #columns[15] ~= 0 then
			titlecase[Character(codepoint)] = Character(tonumber("0x" .. columns[15]))
		end
	end

	return true
end

function uac.unicode.ParseSimilarData()
	local data = file_Read("data/uac/unicode/similar.txt", "GAME")
	if data == nil then
		return false
	end

	data = string_Split(data, "\n")
	if data == nil then
		return false
	end

	for i = 1, #data do
		local line = string_Trim(data[i])
		if #line == 0 or string_sub(line, 1, 1) == "#" then
			continue
		end

		local columns = string_Split(line, ";")
		local seq = Character(tonumber("0x" .. columns[1]))

		if columns[2] ~= nil and #columns[2] ~= 0 then
			local similars = {}

			local codepoints = string_Split(columns[2], " ")
			for i = 1, #codepoints do
				similars[i] = Character(tonumber("0x" .. codepoints[i]))
			end

			if #similars ~= 0 then
				similar[seq] = similars
			end
		end
	end

	return true
end

uac.unicode.ParseUnicodeData()
uac.unicode.ParseSimilarData()