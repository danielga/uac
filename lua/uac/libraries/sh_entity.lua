local ENTITY = FindMetaTable("Entity")

function ENTITY:GetUACTable()
	if not self.__uac then
		self.__uac = {}
	end

	return self.__uac
end
