lemon.hook = lemon.hook or {}
local hook_list = {}

function lemon.hook:Add(name, unique, func)
	if not hook_list[name] then
		hook_list[name] = {}
	end

	hook_list[name][unique] = func
	hook.Add(name, unique, func)
end

function lemon.hook:Remove(name, unique)
	if not hook_list[name] then
		return
	end

	hook_list[name][unique] = nil
	hook.Remove(name, unique)
end

function lemon.hook:RemoveAll(name)
	if name and not hook_list[name] then
		return
	end

	if name then
		for unique, _ in pairs(hook_list[name]) do
			hook.Remove(name, unique)
		end
		hook_list[name] = nil
	else
		for name, list in pairs(hook_list) do
			for unique, _ in pairs(list) do
				hook.Remove(name, unique)
			end
		end
		hook_list = {}
	end
end