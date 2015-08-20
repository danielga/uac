PLUGIN.Name = "Slay"
PLUGIN.Description = "Adds commands to slay players."
PLUGIN.Author = "MetaMan"

function PLUGIN:Slay(ply, target)
	if target:Alive() then
		target:Kill()
	end
end
PLUGIN:AddCommand("slay", PLUGIN.Slay)
	:SetAccess(ACCESS_SLAY)
	:SetDescription("Kills a user")
	:AddParameter(uac.command.player)

function PLUGIN:SilentSlay(ply, target)
	if target:Alive() then
		target:KillSilent()
	end
end
PLUGIN:AddCommand("sslay", PLUGIN.SilentSlay)
	:SetAccess(ACCESS_SLAY)
	:SetDescription("Silently kills a user (no killicon and sound)")
	:AddParameter(uac.command.player)
