uac.string = uac.string or {}

function uac.string.Levenshtein(s, t)
	local d, sn, tn = {}, #s, #t

	for i = 0, sn do
		d[i * tn] = i
	end

	for j = 0, tn do
		d[j] = j
	end

	for i = 1, sn do
		local si = s:byte(i)
		for j = 1, tn do
			d[i * tn + j] = math.min(d[(i - 1) * tn + j] + 1, d[i * tn + j - 1] + 1, d[(i - 1) * tn + j - 1] + (si == t:byte(j) and 0 or 1))
		end
	end

	return d[#d]
end

function uac.string.DamerauLevenshtein(s, t, lim)
	local s_len, t_len = #s, #t
	if lim and math.abs(s_len - t_len) >= lim then
		return lim
	end
	
	if type(s) == "string" then
		s = {s:byte(1, s_len)}
	end

	if type(t) == "string" then
		t = {t:byte(1, t_len)}
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
			local val = math.min(d[i_pos - num_columns + j] + 1, d[i_pos + j - 1] + 1, d[i_pos - num_columns + j - 1] + add_cost)
			d[i_pos + j] = val

			if i > 1 and j > 1 and s[i] == t[j - 1] and s[i - 1] == t[j] then
				d[i_pos + j] = math.min(val, d[i_pos - num_columns - num_columns + j - 2] + add_cost)
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

local formatex_pattern = "({%d+})"
local no_substitute_error = "No substitute found for {%i}."
function uac.string.Format(text, ...)
	local matched = {}
	local substitutes = {...}

	for match in text:gmatch(formatex_pattern) do
		local match_number = tonumber(match:sub(2, -2))
		if match_number ~= nil and matched[match_number] == nil then
			if substitutes[match_number] == nil then
				error(no_substitute_error:format(match_number))
			end

			matched[match_number] = true
			text = text:gsub(match, tostring(substitutes[match_number]))
		end
	end

	return text
end

function uac.string.IsSteamIDValid(steamid)
	return type(steamid) == "string" and steamid:find("^STEAM_%d:%d:%d+$") ~= nil
end

function uac.string.IsSteamID64Valid(steamid64)
	return type(steamid64) == "string" and steamid64:find("^%d+$") ~= nil
end

function uac.string.IsIPValid(ip)
	return type(steamid64) == "ip" and ip:find("^%d+.%d+.%d+.%d+$") ~= nil
end