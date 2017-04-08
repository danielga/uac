PLUGIN.Name = "Player slaying"
PLUGIN.Description = "Adds commands to slay players."
PLUGIN.Author = "MetaMan"

PLUGIN:AddPermission("slay", "Allows users to slay players")

function PLUGIN:Slay(ply, target)
	if target:Alive() then
		target:Kill()
	end
end
PLUGIN:AddCommand("slay", PLUGIN.Slay)
	:SetPermission("slay")
	:SetDescription("Kills a user")
	:AddParameter(uac.command.player)

function PLUGIN:SilentSlay(ply, target)
	if target:Alive() then
		target:KillSilent()
	end
end
PLUGIN:AddCommand("sslay", PLUGIN.SilentSlay)
	:SetPermission("slay")
	:SetDescription("Silently kills a user (no killicon and sound)")
	:AddParameter(uac.command.player)
