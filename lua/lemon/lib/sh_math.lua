lemon.math = lemon.math or {}

local function APMakeTable(v)
	v = tostring(v)
	if not v:match("^%d+$") then
		error("Invalid number (must be positive integer).")
	end

	local t = {}
	for k = 1, v:len() do
		t[k] = v:sub(k, k)
	end

	return t
end

local int = "%i"
local function APMakeString(v)
	local len = #v
	local num = 0
	local pos = 0
	for i = 1, len / 2 do
		pos = len - i + 1
		num = v[i]
		v[i] = v[pos]
		v[pos] = num
	end

	return int:rep(#v):format(unpack(v))
end

function lemon.math:Add(a, b) -- only recommended for big numbers which Lua can't handle properly (must be positive integers)
	local A = APMakeTable(a)
	local B = APMakeTable(b)

	local pos1 = #A
	local pos2 = #B
	local pos3 = 1
	local C = {}
	local overflow = 0
	while pos1 > 0 or pos2 > 0 do
		local digit = (A[pos1] or 0) + (B[pos2] or 0) + overflow
		overflow = 0
		if digit > 9 then
			overflow = 1
			digit = digit - 10
		end

		C[pos3] = digit
		pos1 = pos1 - 1
		pos2 = pos2 - 1
		pos3 = pos3 + 1
	end

	if overflow == 1 then
		C[pos3] = 1
	end

	return APMakeString(C)
end

function lemon.math:Sub(a, b) -- only recommended for big numbers which Lua can't handle properly (must be positive integers)
	local A = APMakeTable(a)
	local B = APMakeTable(b)

	local pos1 = #A
	local pos2 = #B
	local pos3 = 1
	local C = {}
	local overflow = 0
	while pos1 > 0 or pos2 > 0 do
		local digit = (A[pos1] or 0) - (B[pos2] or 0) - overflow
		overflow = 0
		if digit < 0 then
			overflow = 1
			digit = digit + 10
		end

		C[pos3] = digit
		pos1 = pos1 - 1
		pos2 = pos2 - 1
		pos3 = pos3 + 1
	end

	if overflow == 1 then
		C[pos3] = 1
	end

	return APMakeString(C)
end