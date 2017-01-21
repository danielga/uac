PLUGIN.Name = "Slay"
PLUGIN.Description = "Adds commands to slay players."
PLUGIN.Author = "MetaMan"

function PLUGIN:Slay(ply, target)
	if target:Alive() then
		target:Kill()
	end
end
PLUGIN:AddCommand("slay", PLUGIN.Slay)
	:SetAccess(uac.auth.access.slay)
	:SetDescription("Kills a user")
	:AddParameter(uac.command.player)

function PLUGIN:SilentSlay(ply, target)
	if target:Alive() then
		target:KillSilent()
	end
end
PLUGIN:AddCommand("sslay", PLUGIN.SilentSlay)
	:SetAccess(uac.auth.access.slay)
	:SetDescription("Silently kills a user (no killicon and sound)")
	:AddParameter(uac.command.player)
