PLUGIN.Name = "Godmode"
PLUGIN.Description = "Adds commands to enable/disable godmode on players."
PLUGIN.Author = "MetaMan"

PLUGIN:AddPermission("god", "Allows users to manage god mode status")

function PLUGIN:EnableGod(ply, target)
	if target:Alive() then
		target:GodEnable()
		target:GetUACTable().godmode = true
	end
end
PLUGIN:AddCommand("god", PLUGIN.EnableGod)
	:SetPermission("god")
	:SetDescription("Enables godmode for a user")
	:AddParameter(uac.command.player)

function PLUGIN:DisableGod(ply, target)
	if target:Alive() then
		target:GodDisable()
		target:GetUACTable().godmode = false
	end
end
PLUGIN:AddCommand("ungod", PLUGIN.DisableGod)
	:SetPermission("god")
	:SetDescription("Disables godmode for a user")
	:AddParameter(uac.command.player)

function PLUGIN:EntityTakeDamage(victim, dmginfo)
	if victim:IsPlayer() and victim:GetUACTable().godmode then
		dmginfo:SetDamage(0)
	end
end
PLUGIN:AddHook("EntityTakeDamage", "UAC godmode plugin (cancel damage on godded players)", PLUGIN.EntityTakeDamage)
