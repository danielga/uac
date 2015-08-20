local ENTITY = FindMetaTable("Entity")

function ENTITY:UACGetTable()
	if not self.__uac then
		self.__uac = {}
	end

	return self.__uac
end
