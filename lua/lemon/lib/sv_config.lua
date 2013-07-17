lemon.config = lemon.config or {}
local config_list = {}

function lemon.config:Set(name, value)
	config_list[name] = value
end

function lemon.config:Get(name)
	return config_list[name]
end

function lemon.config:GetBool(name)
	local value = self:GetValue(name)
	return value == true or value == "true" or value == 1
end

function lemon.config:GetString(name)
	return tostring(self:GetValue(name))
end

function lemon.config:GetNumber(name)
	return tonumber(self:GetValue(name))
end

function lemon.config:SetList(valuestable)
	for name, value in pairs(valuestable) do
		config_list[name] = value
	end
end

function lemon.config:GetList()
	return config_list
end

function lemon.config:DeleteValue(name)
	self:SetValue(name, nil)
end

function lemon.config:Reset()
	--much better than setting each value to nil
	config_list = {}
end

function lemon.config:LoadValuesFromFile(filepath)
	local text = file.Read(filepath, "DATA")
	if not text then return end
	local keyvalues = lemon.string:ParseINIData(text)
	if keyvalues then
		self:SetList(keyvalues)
	end
end

function lemon.config:SaveValuesToFile(filepath)
	local keyvalues = lemon.string:CreateINIData(config_list)
	if keyvalues then
		file.Write(filepath, keyvalues)
	end
end

------------------------------------------------------------------

if not file.Exists("lemon/default_config.txt", "DATA") then
	file.Write("lemon/default_config.txt",
[[; This is the default configuration file. If you wish to modify any of these settings, please do so in a new file named config.txt
; SQL database connection details
; The next setting allows you to select which kind of database you want to use (local, remote or sourcebans)
; local and remote are pretty similar except remote requires mysqloo and a mysql database (can be remote or local depending on configs, it's called remote because it's not handled by the game directly)
; sourcebans also requires mysqloo and a database configured for sourcebans (Lemon will also create some tables of its own on that database)
SQL_CONNECTION_TYPE=local
; If you chose the mysql database (remote or sourcebans) then you need to set up your connection details below
SQL_HOST=
SQL_HOST_PORT=
SQL_DATABASE=
SQL_USERNAME=
SQL_PASSWORD=
; The next setting allows you to tell Lemon to use the PHP redirection script (only for remote and sourcebans)
; Redirection is useful for "remote" databases that don't allow remote access (those free webhosts) and only requires a database and a PHP script with JSON output (the only additional info it needs is the database name, username and a password, defined above)
SQL_REDIRECTED=false
; The next setting defines the URL for the file that redirects remote SQL queries to the real database
SQL_REDIRECTOR_URL=

; SQL details for databases of "sourcebans" type
; The next setting allows Lemon to correctly identify SourceBans tables (eg. sb_bans)
SOURCEBANS_PREFIX=sb

; SQL details for Lemon data
; The next setting allows Lemon to correctly identify its tables (eg. lemon_bans)
LEMON_PREFIX=lemon]])
end

hook.Add("Initialize", "lemon.auth.LoadUsersList", function()
	lemon.config:LoadValuesFromFile("lemon/default_config.txt")
	lemon.config:LoadValuesFromFile("lemon/config.txt")
end)