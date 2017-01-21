PLUGIN.Name = "Godmode"
PLUGIN.Description = "Adds commands to enable/disable godmode on players."
PLUGIN.Author = "MetaMan"

function PLUGIN:EnableGod(ply, target)
	if target:Alive() then
		target:GodEnable()
		target:UACGetTable().godmode = true
	end
end
PLUGIN:AddCommand("god", PLUGIN.EnableGod)
	:SetAccess(uac.auth.access.slay)
	:SetDescription("Enables godmode for a user")
	:AddParameter(uac.command.player)

function PLUGIN:DisableGod(ply, target)
	if target:Alive() then
		target:GodDisable()
		target:UACGetTable().godmode = false
	end
end
PLUGIN:AddCommand("ungod", PLUGIN.DisableGod)
	:SetAccess(uac.auth.access.slay)
	:SetDescription("Disables godmode for a user")
	:AddParameter(uac.command.player)

function PLUGIN:EntityTakeDamage(victim, dmginfo)
	if victim:IsPlayer() and victim:UACGetTable().godmode then
		dmginfo:SetDamage(0)
	end
end
PLUGIN:AddHook("EntityTakeDamage", "UAC godmode plugin (cancel damage on godded players)", PLUGIN.EntityTakeDamage)
