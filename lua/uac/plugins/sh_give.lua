PLUGIN.Name = "Give"
PLUGIN.Description = "Adds a command to give items to players."
PLUGIN.Author = "MetaMan"

function PLUGIN:Give(ply, target, item)
	if target:Alive() then
		target:Give(item)
	end
end
PLUGIN:AddCommand("give", PLUGIN.Give)
	:SetAccess(uac.auth.access.slay)
	:SetDescription("Gives the specified item to a user")
	:AddParameter(uac.command.player)
	:AddParameter(uac.command.string)
