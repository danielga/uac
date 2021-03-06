uac.config = uac.config or {
	list = {}
}

local config_list = uac.config.list

function uac.config.Delete(name)
	uac.config.Set(name, nil)
end

function uac.config.Exists(name)
	return config_list[name] ~= nil
end

function uac.config.Set(name, conf)
	config_list[name] = conf
end

function uac.config.Get(name)
	return config_list[name]
end

function uac.config.SetValue(name, value)
	if not uac.config.Exists(name) then
		return
	end

	config_list[name].value = value
end

function uac.config.GetValue(name, default)
	local conf = uac.config.Get(name)
	return conf ~= nil and conf.value or default
end

local function tobool(val)
	if val == false or val == 0 or val == "false" then
		return false
	end

	return (val == true or val == 1 or val == "true") and true or nil
end

function uac.config.GetBool(name, default)
	local value = tobool(uac.config.GetValue(name))
	return value ~= nil and value or default
end

function uac.config.GetString(name, default)
	local value = uac.config.GetValue(name)
	return (value ~= nil and value ~= "") and tostring(value) or default
end

function uac.config.GetNumber(name, default)
	local value = tonumber(uac.config.GetValue(name))
	return value ~= nil and value or default
end

function uac.config.GetList()
	return config_list
end

function uac.config.Reset()
	config_list = {}
end

function uac.config.LoadValuesFromFile(filepath)
	local text = file.Read(filepath, "DATA")
	if not text then return end
	local keyvalues = util.KeyValuesToTable(text)
	if keyvalues then
		for k, v in pairs(keyvalues) do
			config_list[k] = v
		end
	end
end

function uac.config.SaveValuesToFile(filepath)
	local keyvalues = util.TableToKeyValues(config_list)
	if keyvalues then
		file.Write(filepath, keyvalues)
	end
end

------------------------------------------------------------------

if not file.Exists("uac/default_config.txt", "DATA") then
	file.Write("uac/default_config.txt",
[["Settings" // This is the default configuration file. If you wish to modify any of these settings, please do so in a new file named config.txt
{
	"uac_chat_prefixes"
	{
		"name"			"Chat prefixes"
		"description"	"Chat prefixes for UAC (must be one letter long, ASCII)"
		"value"			"-!"
		"type"			"string"
	}

	// SQL database connection details
	// The next setting allows you to select which kind of database you want to use (local, remote or sourcebans)
	// local and remote are pretty similar except remote requires mysqloo and a mysql database (can be remote or local depending on configs, it's called remote because it's not handled by the game directly)
	// sourcebans also requires mysqloo and a database configured for sourcebans (UAC will also create some tables of its own on that database)
	"sql_connection_type"
	{
		"name"			"SQL connection type"
		"description"	"Which type of SQL database UAC should use"
		"value"			"local"
		"type"			"string"
		"options"
		{
			"1"		"local"
			"2"		"remote"
			"3"		"sourcebans"
		}
	}
	// If you chose the mysql database (remote or sourcebans) then you need to set up your connection details below
	"sql_host"
	{
		"name"			"SQL hostname"
		"description"	"The hostname through which UAC will try to connect"
		"value"			""
		"type"			"string"
	}
	"sql_host_port"
	{
		"name"			"SQL host port"
		"description"	"The port through which UAC will try to connect"
		"value"			""
		"type"			"number"
	}
	"sql_database"
	{
		"name"			"SQL database name"
		"description"	"The database name UAC will use"
		"value"			""
		"type"			"string"
	}
	"sql_username"
	{
		"name"			"SQL database username"
		"description"	"The username which allows UAC to connect to the SQL database"
		"value"			""
		"type"			"string"
	}
	"sql_password"
	{
		"name"			"SQL database password"
		"description"	"The password which allows UAC to connect to the SQL database"
		"value"			""
		"type"			"string"
	}

	// SQL details for databases of "sourcebans" type
	"sourcebans_prefix"
	{
		"name"			"SourceBans tables prefix"
		"description"	"Allows UAC to correctly identify SourceBans tables (eg. sb_bans)"
		"value"			"sb"
		"type"			"string"
	}

	// SQL details for UAC data
	"uac_prefix"
	{
		"name"			"UAC tables prefix"
		"description"	"Allows UAC to correctly identify its tables (eg. uac_bans)"
		"value"			"uac"
		"type"			"string"
	}
}]])
end

uac.config.LoadValuesFromFile("uac/default_config.txt")
uac.config.LoadValuesFromFile("uac/config.txt")
