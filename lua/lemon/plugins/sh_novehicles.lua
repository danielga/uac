PLUGIN.Name = "No vehicles"
PLUGIN.Description = "Removes the vehicles to prevent crashes on Linux."
PLUGIN.Author = "DrogenViech"

if SERVER then
	function PLUGIN:PlayerSpawnVehicle(ply, model, name, t)
		t.Class = string.lower(t.Class)
		if t.Class == "prop_vehicle_airboat" or t.Class == "prop_vehicle_jeep_old" or t.Class == "prop_vehicle_jeep" then
			ply:ChatMessage(Color(255, 0, 0, 255), "[Lemon] ", Color(255, 255, 255, 255), "The buggy, jalopy and airboat are banned, they crash linux servers (Blame VALVe)")
			return false
		end
	end
elseif CLIENT then
	function PLUGIN:Unload(reload)
		list.Set("Vehicles", "Jeep", self.Jeep)
		list.Set("Vehicles", "Airboat", self.Airboat)
		list.Set("Vehicles", "Jalopy", self.Jalopy)
	end
	
	function PLUGIN:Load(reload)
		local vehiclelist = list.Get("Vehicles")
		self.Jeep, self.Airboat, self.Jalopy = vehiclelist.Jeep, vehiclelist.Airboat, vehiclelist.Jalopy
		list.Set("Vehicles", "Jeep", nil)
		list.Set("Vehicles", "Airboat", nil)
		list.Set("Vehicles", "Jalopy", nil)
	end
end