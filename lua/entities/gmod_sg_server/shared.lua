if (StarGate!=nil and StarGate.LifeSupportAndWire!=nil) then StarGate.LifeSupportAndWire(ENT); end

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "SGC Computer server"
ENT.Author = "glebqip"
ENT.Category = "Stargate Carter Addon Pack"

list.Set("CAP.Entity", ENT.PrintName, ENT);

ENT.Spawnable = false
ENT.AdminSpawnable = false
local stargate_group_system = GetConVar("stargate_group_system")
--No, builtin functions are total crap of tables and repeates
function ENT:GetFineAddress(gate,ogate)
	local ogate = ogate or self.LockedGate

	local grouped = stargate_group_system:GetBool()
	local address = gate.GateAddress
	if #address == 0 then return "" end

	local range = (ogate:GetPos() - gate:GetPos()):Length();
	local c_range = ogate:GetNetworkedInt("SGU_FIND_RANDE");
	if grouped then
		local group = gate.GateGroup
		local mgroup = ogate.GateGroup
		if (mgroup != group and (not gate.IsUniverseGate or not ogate.IsUniverseGate) or c_range > 0 and range>c_range and #mgroup==3) then
			if (#group == #mgroup and #group >= 2) then
				address = address..group:sub(1,1)
			else
				address = address..group
			end
		end
		if (#group==2 and #mgroup==3) then
			address = address.."#";
		end
	else
		if (gate:GetClass() == "stargate_universe" and ogate:GetClass() ~= "stargate_universe") or	(gate:GetClass() ~= "stargate_universe" and ogate:GetClass() == "stargate_universe") then
			 address = address.."@!";
		elseif gate:GetClass() == "stargate_atlantis" and ogate:GetClass() == "stargate_atlantis" and #address == 7 and ogate:GetGalaxy() and gate:GetGalaxy() then
		elseif #address == 7 and ogate:GetGalaxy() and gate:GetGalaxy() and ((gate:GetClass() ~= "stargate_atlantis" and ogate:GetClass() ~= "stargate_atlantis") and (gate:GetClass() ~= "stargate_universe" and ogate:GetClass() ~= "stargate_universe")) then
		elseif gate:GetGalaxy() or ogate:GetGalaxy() or gate.IsUniverseGate and ogate.IsUniverseGate and c_range > 0 and range>c_range then
			 address = address.."@";
		end
	end
	return address
end
