resource.AddSingleFile("data/uac/unicode/data_9.0.0.dat")
resource.AddSingleFile("data/uac/unicode/similar_1.0.0.dat")

uac.unicode = uac.unicode or {}

uac.unicode.uppercase = {}
uac.unicode.lowercase = {}
uac.unicode.titlecase = {}
uac.unicode.decomposition = {}
uac.unicode.similar = {}

local uppercase = uac.unicode.uppercase
local lowercase = uac.unicode.lowercase
local titlecase = uac.unicode.titlecase
local decomposition = uac.unicode.decomposition
local similar = uac.unicode.similar

if not file.IsDir("uac/unicode", "DATA") then
	file.CreateDir("uac/unicode")
end

function uac.unicode.CodePoint(seq, offset)
	offset = offset or 1

	local len = #seq
	if len == 0 or offset > len then
		return -1
	end

	local codepoint = string.byte(seq, offset)
	if codepoint < 128 then
		return codepoint, 1
	elseif codepoint < 192 then
		return -1
	elseif codepoint < 224 then
		if offset + 1 > len then
			return -1, 2
		end

		local b1 = string.byte(seq, offset + 1)
		return (codepoint % 32) * 64 + b1 % 64, 2
	elseif codepoint < 240 then
		if offset + 2 > len then
			return -1, 3
		end

		local b1, b2 = string.byte(seq, offset + 1, offset + 2)
		return (codepoint % 16) * 4096 + (b1 % 64) * 64 + (b2 % 64), 3
	elseif codepoint < 248 then
		if offset + 3 > len then
			return -1, 4
		end

		local b1, b2, b3 = string.byte(seq, offset + 1, offset + 3)
		return (codepoint % 8) * 262144 + (b1 % 64) * 4096 + (b2 % 64) * 64 + b3 % 64, 4
	end

	return -1
end

function uac.unicode.Character(codepoint)
	if codepoint < 0 then
		return ""
	elseif codepoint < 128 then
		return string.char(codepoint)
	elseif codepoint < 2048 then
		return string.char(
			192 + math.floor(codepoint / 64),
			128 + (codepoint % 64)
		)
	elseif codepoint < 65536 then
		return string.char(
			224 + math.floor(codepoint / 4096),
			128 + (math.floor(codepoint / 64) % 64),
			128 + (codepoint % 64)
		)
	elseif codepoint < 2097152 then
		return string.char(
			240 + math.floor(codepoint / 262144),
			128 + (math.floor(codepoint / 4096) % 64),
			128 + (math.floor(codepoint / 64) % 64),
			128 + (codepoint % 64)
		)
	end

	return ""
end

function uac.unicode.SequenceLength(str, offset)
	local byte = string.byte(str, offset)
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
	return string.sub(str, offset, offset + length - 1), offset + length
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
local DecomposeSequence
function uac.unicode.DecomposeSequence(str, offset)
	local seq = Sequence(str, offset)
	local decomposed = decomposition[seq]
	if decomposed == nil then
		return seq
	end

	local decomp = ""
	for dseq in Iterator(decomposed) do
		decomp = decomp .. DecomposeSequence(dseq)
	end

	return decomp
end

DecomposeSequence = uac.unicode.DecomposeSequence
function uac.unicode.Decompose(str)
	local map = {}
	local invmap = {}
	local t = {}

	local outoffset = 1
	for seq, offset in Iterator(str) do
		local decomp = DecomposeSequence(seq)
		t[#t + 1] = decomp

		map[offset] = outoffset
		invmap[outoffset] = offset
		outoffset = outoffset + #decomp
	end

	map[#str + 1] = outoffset
	invmap[outoffset] = #str + 1
	return table.concat(t), map, invmap
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
			local ls = lowercase[s] ~= nil and lowercase[s] or s
			if ls == r then
				return true
			end
		end
	end

	return false
end

local Decompose = uac.unicode.Decompose
function uac.unicode.Similar(left, right)
	local map, invmap
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
	local Major, minor, revision, decompressed = 0, 0, 0, false
	local files = file.Find("data/uac/unicode/data_*", "GAME")
	for i = 1, #files do
		local M, m, r, ext = string.match(files[i], "^data_(%d+)%.(%d+)%.(%d+)%.(%w+)$")
		if M and m and r and ext then
			M, m, r = tonumber(M), tonumber(m), tonumber(r)

			if M > Major then
				Major = M
			end

			if m > minor then
				minor = m
			end

			if r > revision then
				revision = r
			end

			if not decompressed and ext == "txt" then
				decompressed = true
			end
		end
	end

	if Major == 0 and minor == 0 and revision == 0 then
		return false
	end

	local data
	if not decompressed then
		data = file.Read("data/uac/unicode/data_" .. Major .. "." .. minor .. "." .. revision .. ".dat", "GAME")
		if data == nil then
			return false
		end

		data = util.Decompress(data)
		if data == nil then
			return false
		end

		file.Write("uac/unicode/data_" .. Major .. "." .. minor .. "." .. revision .. ".txt", data)
	else
		data = file.Read("uac/unicode/data_" .. Major .. "." .. minor .. "." .. revision .. ".txt", "DATA")
		if data == nil then
			return false
		end
	end

	data = string.Split(data, "\n")
	if data == nil then
		return false
	end

	for i = 1, #data do
		local line = string.Trim(data[i])
		if #line == 0 or string.sub(line, 1, 1) == "#" then
			continue
		end

		local columns = string.Split(line, ";")
		local codepoint = tonumber("0x" .. (columns[1] or "0")) or 0

		if columns[6] ~= nil and #columns[6] ~= 0 then
			local decomps = string.Split(columns[6], " ")
			local decomp = ""
			for k = 1, #decomps do
				local cpdecomp = tonumber("0x" .. decomps[k])
				if cpdecomp ~= nil then
					decomp = decomp .. Character(cpdecomp)
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
	local Major, minor, revision, decompressed = 0, 0, 0, false
	local files = file.Find("data/uac/unicode/similar_*", "GAME")
	for i = 1, #files do
		local M, m, r, ext = string.match(files[i], "^similar_(%d+)%.(%d+)%.(%d+)%.(%w+)$")
		if M and m and r and ext then
			M, m, r = tonumber(M), tonumber(m), tonumber(r)

			if M > Major then
				Major = M
			end

			if m > minor then
				minor = m
			end

			if r > revision then
				revision = r
			end

			if not decompressed and ext == "txt" then
				decompressed = true
			end
		end
	end

	if Major == 0 and minor == 0 and revision == 0 then
		return false
	end

	local data
	if not decompressed then
		data = file.Read("data/uac/unicode/similar_" .. Major .. "." .. minor .. "." .. revision .. ".dat", "GAME")
		if data == nil then
			return false
		end

		data = util.Decompress(data)
		if data == nil then
			return false
		end

		file.Write("uac/unicode/similar_" .. Major .. "." .. minor .. "." .. revision .. ".txt", data)
	else
		data = file.Read("uac/unicode/similar_" .. Major .. "." .. minor .. "." .. revision .. ".txt", "DATA")
		if data == nil then
			return false
		end
	end

	data = uac.string.DecodeULEB128(data)
	if data == nil then
		return false
	end

	local i, datalen = 1, #data
	while i <= datalen do
		local seq = Character(data[i])
		i = i + 1

		local similars = {}

		while i <= datalen and data[i] ~= 0 do
			table.insert(similars, Character(data[i]))
			i = i + 1
		end

		if #similars ~= 0 then
			similar[seq] = similars
		end

		i = i + 1
	end

	return true
end

uac.unicode.ParseUnicodeData()
uac.unicode.ParseSimilarData()
