PLUGIN.Name = "Give"
PLUGIN.Description = "Adds a command to give items to players."
PLUGIN.Author = "MetaMan"

PLUGIN:AddPermission("give", "Allows users to give items")

function PLUGIN:Give(ply, target, item)
	if target:Alive() then
		target:Give(item)
	end
end
PLUGIN:AddCommand("give", PLUGIN.Give)
	:SetPermission("give")
	:SetDescription("Gives the specified item to a user")
	:AddParameter(uac.command.player)
	:AddParameter(uac.command.string)
