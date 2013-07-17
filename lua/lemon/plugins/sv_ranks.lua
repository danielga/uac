local PLUGIN = lemon.plugin:New()

PLUGIN.Name = "Rank setting"
PLUGIN.Description = "Allows users with RCON flags to set someone's rank/usergroup."
PLUGIN.Author = "Agent 47"

function PLUGIN:UsergroupPlayer(ply, command, args)
	local target = lemon.player:GetTargets(ply, args[1], false)[1]
	if not IsValid(target) or not target:IsPlayer() then return end

	local usergroup = args[2]
	if not usergroup then return end

	target:SetUserGroup(usergroup)
end
PLUGIN:AddCommand("rank", PLUGIN.UsergroupPlayer, ACCESS_RCON, "Sets the usergroup of the specified user", "<Player name | SteamID | #UserID | @Team name> <Usergroup>")

function PLUGIN:FlagPlayer(ply, command, args)
	local target = lemon.player:GetTargets(ply, args[1], false)[1]
	if not IsValid(target) or not target:IsPlayer() then return end

	local flags = args[2]
	if not flags then return end

	target:SetUserFlags(flags)
end
PLUGIN:AddCommand("flags", PLUGIN.FlagPlayer, ACCESS_RCON, "Sets the flags of the specified user", "<Player name | SteamID | #UserID | @Team name> <Flags>")

lemon.plugin:Register(PLUGIN)