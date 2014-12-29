lemon.config = lemon.config or {}
local config_list = {}

function lemon.config.Delete(name)
	lemon.config.Set(name, nil)
end

function lemon.config.Exists(name)
	return config_list[name] ~= nil
end

function lemon.config.Set(name, conf)
	config_list[name] = conf
end

function lemon.config.Get(name)
	return config_list[name]
end

function lemon.config.SetValue(name, value)
	if not lemon.config.Exists(name) then return end

	config_list[name].value = value
end

function lemon.config.GetValue(name, default)
	local conf = lemon.config.Get(name)
	return conf and conf.value or default
end

function lemon.config.GetBool(name, default)
	local value = lemon.config.GetValue(name)
	return value == nil and default or (value == true or value == "true" or value == 1)
end

function lemon.config.GetString(name, default)
	local value = lemon.config.GetValue(name)
	return value == nil and default or tostring(value)
end

function lemon.config.GetNumber(name, default)
	local value = lemon.config.GetValue(name)
	return value == nil and default or tonumber(value)
end

function lemon.config.GetList()
	return config_list
end

function lemon.config.Reset()
	--much better than setting each value to nil
	config_list = {}
end

function lemon.config.LoadValuesFromFile(filepath)
	local text = file.Read(filepath, "DATA")
	if not text then return end
	local keyvalues = util.KeyValuesToTable(text)
	if keyvalues then
		for k, v in pairs(keyvalues) do
			config_list[k] = v
		end
	end
end

function lemon.config.SaveValuesToFile(filepath)
	local keyvalues = util.TableToKeyValues(config_list)
	if keyvalues then
		file.Write(filepath, keyvalues)
	end
end

------------------------------------------------------------------

if not file.Exists("lemon/default_config.txt", "DATA") then
	file.Write("lemon/default_config.txt",
[["Settings" // This is the default configuration file. If you wish to modify any of these settings, please do so in a new file named config.txt
{
	"lemon_chat_prefixes"
	{
		"name"			"Chat prefixes"
		"description"	"Chat prefixes for Lemon (must be one letter long, ASCII)"
		"value"			"-!"
		"type"			"string"
	}

	// SQL database connection details
	// The next setting allows you to select which kind of database you want to use (local, remote or sourcebans)
	// local and remote are pretty similar except remote requires mysqloo and a mysql database (can be remote or local depending on configs, it's called remote because it's not handled by the game directly)
	// sourcebans also requires mysqloo and a database configured for sourcebans (Lemon will also create some tables of its own on that database)
	"sql_connection_type"
	{
		"name"			"SQL connection type"
		"description"	"Which type of SQL database Lemon should use"
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
		"description"	"The hostname through which Lemon will try to connect"
		"value"			""
		"type"			"string"
	}
	"sql_host_port"
	{
		"name"			"SQL host port"
		"description"	"The port through which Lemon will try to connect"
		"value"			""
		"type"			"number"
	}
	"sql_database"
	{
		"name"			"SQL database name"
		"description"	"The database name Lemon will use"
		"value"			""
		"type"			"string"
	}
	"sql_username"
	{
		"name"			"SQL database username"
		"description"	"The username which allows Lemon to connect to the SQL database"
		"value"			""
		"type"			"string"
	}
	"sql_password"
	{
		"name"			"SQL database password"
		"description"	"The password which allows Lemon to connect to the SQL database"
		"value"			""
		"type"			"string"
	}
	// The next setting allows you to tell Lemon to use the PHP redirection script (only for remote and sourcebans)
	// Redirection is useful for "remote" databases that don't allow remote access (those free webhosts) and only requires a database and a PHP script with JSON output (the only additional info it needs is the database name, username and a password, defined above)
	"sql_redirected"
	{
		"name"			"SQL redirection"
		"description"	"Defines whether or not Lemon should use a website script to transfer data between the database"
		"value"			"false"
		"type"			"boolean"
	}
	"sql_redirector_url"
	{
		"name"			"SQL redirector"
		"description"	"Defines the URL for the script that redirects remote SQL queries to the real database"
		"value"			"false"
		"type"			"boolean"
	}

	// SQL details for databases of "sourcebans" type
	"sourcebans_prefix"
	{
		"name"			"SourceBans tables prefix"
		"description"	"Allows Lemon to correctly identify SourceBans tables (eg. sb_bans)"
		"value"			"sb"
		"type"			"string"
	}

	// SQL details for Lemon data
	"lemon_prefix"
	{
		"name"			"Lemon tables prefix"
		"description"	"Allows Lemon to correctly identify its tables (eg. lemon_bans)"
		"value"			"sb"
		"type"			"lemon"
	}
}]])
end

lemon.config.LoadValuesFromFile("lemon/default_config.txt")
lemon.config.LoadValuesFromFile("lemon/config.txt")