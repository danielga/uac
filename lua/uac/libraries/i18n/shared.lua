AddCSLuaFile()

local meta = {}

function meta:__call(key, ...)
    return uac.i18n.Translate(key, ...)
end

uac.i18n = setmetatable(uac.i18n or {}, meta)
uac.i18n.default_language = "en"
uac.i18n.languages = {}

local language_convar = GetConVar("gmod_language")
function uac.i18n.GetCurrentLanguage()
    return language_convar:GetString()
end

function uac.i18n.Load(identifier)
    if file.Exists("uac/libraries/i18n/languages/" .. identifier .. ".lua", "LUA") then
        uac.i18n.languages[identifier] = include("languages/" .. identifier .. ".lua")
    end
end
uac.i18n.Load(uac.i18n.default_language)

function uac.i18n.Translate(key, ...)
    local current_language = uac.i18n.GetCurrentLanguage()
    local lang = uac.i18n.languages[current_language]
    local format = lang and lang[key]
    if (not lang or not format) and current_language ~= uac.i18n.default_language then
        lang = uac.i18n.languages[uac.i18n.default_language]
        format = lang and lang[key]
    end

    if not format then
        return
    end

    return string.format(format, ...)
end

if SERVER then
    local languages = file.Find("uac/libraries/i18n/languages/*.lua", "LUA")
    for i = 1, #languages do
        AddCSLuaFile("languages/" .. languages[i])
    end
end
