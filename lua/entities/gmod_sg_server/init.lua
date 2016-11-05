/* Copyright (C) 2016 by glebqip */

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
ENT.ServerVer = 1

include("shared.lua")
if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("extra")) then return end

function ENT:Initialize()
	self.LockedGate = false
	self:SetModel("models/props_lab/harddrive02.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(1)

	self.DialingAddress = ""
	self.DCError = 0
	self.On = false

	self.AddressCheck = CurTime()-7
	self.Addresses = {}

	self.StartTimer = false
	self.StartState = 0

	self.SelfDestructCodes = {
		{"12345678","Test1"},
		{"98765432","Test2"},
	}
	self.SelfDestructResetCodes = {
		{"12345678","Test1"},
		{"98765432","Test2"},
	}
	self.SelfDestructClients = {}
	self.SelfDestruct = false
	self.SelfDestructTimer = CurTime()
	self.Iris = false
	--[[
	self.TeleEnts = {}
	self.Teleported = {}
	self.TeleportedT = {}
]]
	self.OldTime = CurTime()
end
hook.Remove("StarGate.Teleport", "SGC_Computer_v1",function(ent,gate,test,blk)
	if gate:GetClass() == "event_horizon" then gate = gate:GetParent() end
	for k,v in pairs(ents.FindByClass("gmod_sg_server")) do
		if gate == self.LockedGate then
			--table.insert(self.Teleported,ent)
		end
	end
end)
function ENT:SpawnFunction(ply, tr)
	if (not tr.Hit) then return end

	local ang = ply:GetAimVector():Angle()
	ang.p,ang.r = 0,0
	ang.y = (ang.y+180)%360

	local ent = ents.Create("gmod_sg_server")
	ent:SetAngles(ang)
	ent:SetPos(tr.HitPos+Vector(0, 0, 20))
	ent:Spawn()
	ent:Activate()

	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then phys:EnableMotion(false) end

	return ent
end

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

--This function is fine copy of stargate:WireGetAddresses()
function ENT:FindFineGates(gate)
	local gate = gate or self.LockedGate
	if not gate.IsStargate then return end --If our gate is supergate - do some	it
	local supergate = not gate.IsGroupStargate
	local grouped = stargate_group_system:GetBool()

	local gates = {}
	local gaddress = gate.GateAddress or ""
	local glocale = grouped and gate.GateLocal
	local ggroup = grouped and gate.GateGroup or ""
	for _,v in pairs(ents.FindByClass("stargate_*")) do
		local address = v.GateAddress or ""
		if supergate then
			if #address ~= 0 and v ~= gate and not v.IsGroupStargate and not v.GatePrivat then table.insert(gates,v) end --it's good supergate!
			continue
		end
		local group = grouped and v.GateGroup or "";
		local locale = v.GateLocal;
		if #address == 0 or #group == 0 and grouped then	continue end --if target gate is not setup - ignore it
		if address == gaddress and group == ggroup then continue end --remove self and gate-duplicates
		if grouped then
			--Check, if our gate a priate, local and not in our group
			if v.GatePrivat or (glocale or locale) and (ggroup ~= group and not (gate.IsUniverseGate and v.IsUniverseGate and #group == 3)) then continue end

			local range = (gate:GetPos() - v:GetPos()):Length()
			local c_range = gate:GetNWInt("SGU_FIND_RANDE",-1)
			--remove distant local SGU gates
			if (gate.GateLocal or v.GateLocal) and v.IsUniverseGate and gate.IsUniverseGate and (c_range < range) then continue end
			table.insert(gates,v)
		else
			local address = v.GateAddress
			local locale = v.GateLocal;
			if v.GatePrivat or not v.IsGroupStargate then continue end
			table.insert(gates,v) --insert all nonprivat gates
		end
	end

	return gates
end

function ENT:Think()
	--for i=1,#self.Teleported do
		--self:SetNW2Bool("Tele"..i,true)
		--if not self.TeleportedT[i] then self.TeleportedT = CurTime() end
	--end
	if self.OffTimer and CurTime()-self.OffTimer > 0.8 then
		self.On = false
		self.OffTimer = nil
		--self.OffSound:Play()
	end
	self:SetNW2Bool("On",self.On)

	--Start emulation
	if self.On and self.State ~= -1 then
		local time = CurTime() - self.StartTimer
		if self.State > 0 and math.random() > 0.95 then self:EmitSound("glebqip/hdd_"..math.random(1,6)..".wav",55,100,0.3) end
		if time > 2 and self.State == 0 then self.State = -2 end
		if time > 3 and self.State == -2 then
			self:EmitSound("glebqip/computer_beep.wav",55)
			self.State = 1
		end
		if time > 4 and self.State == 1 then self.State = 2 end
		if time > 7 and self.State == 2 then self.State = 3 end
		if time > 7.3 and self.State == 3 then self.State = 4 end
		if time > 11 and self.State == 4 then self.State = 5 end
		if time > 15 and self.State == 5 then self.State = 6 end
		if time > 17 and self.State == 6 then
			self.State = -1
			self.Iris = false
		end
	end
	self:SetNW2Int("LoadState",self.State)
	local gate = self.LockedGate
	if (IsValid(gate)) and self.On and self.State == -1 then
		if CurTime()-self.AddressCheck > 10 then

			self.Gates = self:FindFineGates()
			self.AddressCheck = CurTime()
			self:SetNW2Int("AddressCount",#self.Gates)
			local pos = self:GetPos()
			local xmin,xmax,ymin,ymax = pos.x,pos.x,pos.y,pos.y
			for _,gate in ipairs(self.Gates) do --First iteration for find bounding box of all gates
				local pos = gate:GetPos()
				if not xmin or xmin > pos.x then xmin = pos.x end
				if not xmax or xmax < pos.x then xmax = pos.x end
				if not ymin or ymin > pos.y then ymin = pos.y end
				if not ymax or ymax < pos.y then ymax = pos.y end
			end
			local addr = self:GetFineAddress(gate)
			if #addr < 9 and not addr:find("#") then addr = addr.."#" end
			self:SetNW2String("AddressName0",gate.GateName ~= "" and gate.GateName or "N/A")
			self:SetNW2String("Address0",addr)
			self:SetNW2Float("AddressX0",(pos.x-xmin)/(xmax-ymin))
			self:SetNW2Float("AddressY0",(pos.y-ymin)/(ymax-ymin))
			for i,gate in ipairs(self.Gates) do
				local addr = self:GetFineAddress(gate)
				if #addr < 9 and not addr:find("#") then addr = addr.."#" end
				self:SetNW2String("Address"..i,addr)
				self:SetNW2String("AddressName"..i,gate.GateName ~= "" and gate.GateName or "N/A")
				self:SetNW2Bool("AddressBlocked"..i,gate:GetBlocked())
				self:SetNW2Int("AddressDistance"..i,gate:GetPos():Distance(self.LockedGate:GetPos()))
				self:SetNW2Int("AddressGalaxy"..i,gate.GateGroup)
				if gate.IsUniverseGate then
					self:SetNW2Int("AddressType"..i,6)
				elseif gate:GetClass() == "stargate_tollan" then
					self:SetNW2Int("AddressType"..i,5)
				elseif gate:GetClass() == "stargate_atlantis" then
					self:SetNW2Int("AddressType"..i,4)
				elseif gate:GetClass() == "stargate_infinity" then
					self:SetNW2Int("AddressType"..i,3)
				elseif gate:GetClass() == "stargate_movie" then
					self:SetNW2Int("AddressType"..i,2)
				else
					self:SetNW2Int("AddressType"..i,1)
				end
				local pos = gate:GetPos()
				self:SetNW2Int("AddressCRC"..i,util.CRC(addr))
				self:SetNW2Float("AddressX"..i,(pos.x-xmin)/(xmax-ymin))
				self:SetNW2Float("AddressY"..i,(pos.y-ymin)/(ymax-ymin))
				--print(self:FindGateBuAddress(addr))
				--local address = string.Explode("",addr);table.insert(address,"DIAL");
				--print(gate:FindGate(true,address))
				--self:SetNW2Int("AddressX"..i,)
			end
		end

		local enter = 0
		for ent in pairs(self.SelfDestructClients) do
			if not IsValid(ent) or ent.Server ~= self or ent:GetNW2Int("SDState",0) == 0 and not self.SelfDestruct or ent:GetNW2Int("SDRState",0) == 0 and self.SelfDestruct then
				self.SelfDestructClients[ent] = nil
			else
				if self.SelfDestruct or ent.Keys[154] then
					enter = enter + 1
				end
			end
		end
		if enter == 2 and not self.SelfDestruct then
			if IsValid(self.Bomb) then
				self.Bomb:StartDetonation(self.Bomb.detonationCode)
			end
			self.SelfDestruct = true
			self.SelfDestructTimer = CurTime()+120+3
		elseif enter == 2 and self.SelfDestruct then
			if IsValid(self.Bomb) then self.Bomb:AbortDetonation(self.Bomb.abortCode) end
			self.SelfDestruct = false
			self.SelfDestructTimer = CurTime()
		end
		self:SetNW2Bool("SelfDestruct",self.SelfDestruct)
		self:SetNW2Int("SDTimer",IsValid(self.Bomb) and self.Bomb:GetNWInt("BombOverlayTime",0) or 0)
		if math.random() > 0.99 then
			self:EmitSound("glebqip/hdd_"..math.random(1,6)..".wav",55,100,0.3)
		end
		local active = gate.NewActive
		local open = gate.IsOpen
		local inbound = gate.Active and not gate.Outbound
		local ringrot = gate:GetWire("Ring Rotation", 0, true) ~= 0
		local locked = gate:GetWire("Chevron Locked", 0, true)> 0
		local chevron = gate:GetWire("Chevron", 0, true)
		local dialsymb = gate:GetWire("Dialing Symbol", "", true)
		local dialdsymb = gate:GetWire("Dialed Symbol", "", true)
		local ringsymb = gate:GetWire("Ring Symbol", "", true)
		local dialadd = gate:GetWire("Dialing Address", "", true)

		local targeraddr = gate.DialledAddress
		local arrrsize = #gate.DialledAddress-1
		--Some shit hack
		local last = targeraddr[arrrsize]
		local LastChev = dialsymb == last or dialdsymb == last or self.LastDialSymb == last
		if LastChev and dialsymb == "" and not ringrot and chevron ~= 0 and not locked then
			locked = 1
		end
		-- print(gate.Chevron[7])
		--print(gate.ScrAddress)
		self:SetNW2Int("RingAngle", gate:GetRingAng())
		self:SetNW2Bool("Active", active)
		self:SetNW2Bool("Open", open)
		self:SetNW2Bool("Inbound", inbound)
		--print(gate:GetNW2Bool("ActChevronsL"))
		self:SetNW2Bool("RingRotation", ringrot)
		self:SetNW2Bool("RingDir", gate:GetWire("Ring Rotation", 0, true) == 1)
		self:SetNW2Bool("ChevronLocked", locked)
		self:SetNW2Int("Chevron", chevron)
		self:SetNW2String("Chevrons", gate:GetWire("Chevrons", "", true))
		--self:SetNW2String("DialingAddress", gate:GetWire("Dialing Address", "", true))
		self:SetNW2String("DialingSymbol", dialsymb)
		self:SetNW2String("DialedSymbol", dialdsymb)
		self:SetNW2String("RingSymbol", ringsymb)
		self:SetNW2Bool("Local",gate.GateLocal)
		self:SetNW2Bool("Fast",gate.DialType.Fast)
		self:SetNW2Bool("HaveEnergy",gate:CheckEnergy(true,true))

		--Add trigger to error
		if not inbound and not open and (active or chevron > 0) and LastChev then
			self.DialErr = true
			if locked == true then
				self.LockErr = true
			end
			if not gate:HaveEnergy() then
				self.EnerEerr = true
			end
			if dialsymb ~= "" then
				self.LastDialSymb = dialsymb
			end
			if locked then
				self.ErrorSymb = last
			end
		elseif (self.DialErr or self.LockErr) then
			if not open and not inbound and chevron <= 0 and #self.DialingAddress >= 6 then -- we fail dial
				self.DCError = self.EnerEerr and 5 or self.LockErr and 2 or 1
				self.DCErrorTimer = CurTime()

				if self.ErrorSymb then
					if self.DialingAddress[#self.DialingAddress] == self.LastDialSymb then
						self.DialingAddress = self.DialingAddress:sub(1,-2)
					end
					self.ErrorAnim = true
				else
					self.ErrorAnim = false
				end
			end
			self.DialErr = false
			self.LockErr = false
			self.EnerEerr = false
		end
		--print(gate.Shutingdown)
		--Dial error check
		if chevron == 0 and self.ErrorSymb and self.DCError == 0 then --Reset err symbol if we don't need it
			self.ErrorSymb = nil
		end
		if self.DCError ~= 0 and CurTime()-self.DCErrorTimer > 10 or active and chevron >= 0 then
			self.DCError = 0
		end

		local movie = self.LockedGate:GetClass() == "stargate_movie"
		self:SetNW2Bool("IsMovie",movie)
		--Symbol animation triggers
		local LastSecond = not open and LastChev and locked
		local FirstRight = targeraddr[chevron+1] == ringsymb and (not ringrot or LastChev)
		local SecondRight = (targeraddr[chevron] == dialsymb and not LastChev) or locked
		if movie then
			FirstRight = targeraddr[chevron+1] == ringsymb
		end

		if active and not open and SecondRight and self.SymbolAnim and not self.SymbolAnim2 and (not self.SA2Timer and not movie or LastSecond or self.SA2Timer and CurTime()-self.SA2Timer > 0.9) then
			self.SA2Timer = nil
	--if active and not open and SecondRight and self.SymbolAnim and not self.SymbolAnim2 then
			self.SymbolAnim2 = true
			self.SymbolAnim = false
		elseif active and not open and SecondRight and self.SymbolAnim and not self.SymbolAnim2 and not self.SA2Timer then
			self.SA2Timer = CurTime()
		elseif active and not open and FirstRight and not self.SymbolAnim and not self.SymbolAnim2 then
			self.SymbolAnim = true
		elseif (not active or open or inbound or not FirstRight and not SecondRight) and (self.SymbolAnim or self.SymbolAnim2) then
			self.SymbolAnim2 = false
			self.SymbolAnim = false
		end
		if not self.SymbolAnim and not self.SymbolAnim2 and self.DCError == 0 then
			self.DialingAddress = dialadd
			local smadd = ""
			if active and not open and locked then
				if dialsymb ~= "" then
					smadd = dialsymb
				elseif dialdsymb ~= "" and not open and not gate.DialType.Fast then
					smadd = dialdsymb
				elseif self.LastDialSymb ~= self.DialingAddress[#self.DialingAddress] then
					smadd = self.LastDialSymb or ""
				end
				self.DialingAddress = self.DialingAddress..smadd
			end
		end

		self:SetNW2Bool("LastChev",LastChev)
		self:SetNW2Bool("ChevronFirst",self.SymbolAnim)
		self:SetNW2Int("DCError",self.DCError*(self.ErrorAnim and -1 or 1))
		self:SetNW2Int("DCErrorSymbol",self.ErrorSymb or self.LastDialSymb)
		self:SetNW2Bool("ChevronSecond",self.SymbolAnim2)
		self:SetNW2String("DialingAddress",self.DialingAddress)
		local dadddelta = LastSecond and (dialsymb ~= "" and dialsymb or dialdsymb ~= "" and dialdsymb or self.LastDialSymb) or ""
		if #self.DialingAddress < #dialadd then
			dadddelta = dialadd:sub(#self.DialingAddress+1,#dialadd)
		end
		if movie and self.SymbolAnim2 and not LastSecond then dadddelta = dadddelta..dialdsymb end
		self:SetNW2String("DialingAddress",self.DialingAddress)
		self:SetNW2String("DialingAddressDelta",dadddelta)
		if self.Inbound ~= inbound then
				self.Iris = inbound
				self.Inbound = inbound
			end
		--GDO scripts
		if inbound and IsValid(self.IDCReceiver) and self.IDCReceiver.LockedGate ~= self.IDCReceiver.Entity then
			local code = self.IDCReceiver.wireCode
			if self.IDCCode == 0 and code ~= self.IDCCode then
				self.IDCCode = code
				self.IDCReceivedCode = code ~= 0 and tostring(code) or self.IDCReceivedCode
				if code ~= 0 then
					self.IDCState = 1
					self.IDCTimer = CurTime()
					local desc = self.IDCReceiver.wireDesc
					if not self.IDCReceiver.Codes[code] then
						self.IDCCodeState = 2
					elseif desc[1] == "!" then
						self.IDCCodeState = 1
						self.IDCName = desc:sub(2,-1)
					else
						self.IDCCodeState = 0
						self.IDCName = desc
					end
				end
			end
			if self.IDCState == 1 and CurTime()-self.IDCTimer > 0.8 then
				self.IDCState = 2
				self.IDCTimer = CurTime()
			end
			if self.IDCState == 2 and CurTime()-self.IDCTimer > 2.2 then
				self.IDCState = 3
				self.IDCShowState = 0
				self.IDCTimer = CurTime()
				self.LinesTimer = CurTime()-0.1
			end
			if self.IDCState == 3 and CurTime()-self.IDCTimer > #self.IDCReceivedCode*0.1+0.1 then
				self.IDCState = 4
				self.IDCReceiver.GDOStatus = -1
				if self.IDCCodeState == 0 then
					self.IDCReceiver.GDOText = "ACCEPT"
				elseif self.IDCCodeState == 1 then
					self.IDCReceiver.GDOText = "EXPIRED"
				else
					self.IDCReceiver.GDOText = "UNKNOWN"
				end
				self.Iris = self.Iris and self.IDCCodeState ~= 0
			end
		else
			self.IDCState = 0
			if IsValid(self.IDCReceiver) then
				self.IDCReceiver.GDOStatus = 2
				self.IDCReceiver.GDOText = "CODE CHECK"
			end
			self.IDCCode = 0
		end
		self:SetNW2Int("IDCShowState",self.IDCShowState)
		self:SetNW2Int("IDCState",self.IDCState)
		self:SetNW2String("IDCCode",self.IDCReceivedCode)
		self:SetNW2String("IDCName",self.IDCName)
		self:SetNW2Int("IDCCodeState",self.IDCCodeState)
		--self.DirBuffer = {}
		--self:SetNWString("SGAddress", gate:GetWire("Dialing Address", "", true))
		--[[
		local event = self.LockedGate.EventHorizon
		local buff = event.Buffer
		if buff then
			local changed = false
			for k,v in pairs(self.TeleEnts) do
				if not buff[v:EntIndex()] or not IsValid(v) then
					table.remove(self.TeleEnts,k)
					changed = true
				end
			end
			for k,v in pairs(self.LockedGate.EventHorizon.Buffer) do
				if not IsValid(v) then continue end
				local find = false
				for k,e in pairs(self.TeleEnts) do
					if e == v then
						find = true
						break
					end
				end
				if not find then
					table.insert(self.TeleEnts,v)
					changed = true
				end
				--print(self.LockedGate.EventHorizon.Buffer[v:EntIndex()])
			end
			if changed then
				self:SetNW2Int("DecCount",#self.TeleEnts)
				for k,v in pairs(self.TeleEnts) do
					self:SetNW2String("DecEnt"..k,v:GetClass())
					self:SetNW2String("DecModel"..k,v:GetModel())
				end
			end
		else
			self:SetNW2Int("DecCount",0)
		end
		]]
	else
		self.Iris = true
	end
	if IsValid(self.IDCReceiver) and IsValid(self.IDCReceiver.LockedIris) and self.IDCReceiver.LockedIris.Toggle and self.IDCReceiver.LockedIris.IsActivated ~= self.Iris then
		self.IDCReceiver.LockedIris:Toggle()
	end
	self:SetNW2Bool("Connected", IsValid(gate))

	self.DeltaTime = CurTime()-self.OldTime
	self.OldTime = CurTime()
	self:NextThink(CurTime()+0.075)
	return true
end

function ENT:Dial(addr)
	if not IsValid(self.LockedGate) then return end
	self.LockedGate.DialledAddress = {}
	for i=1,#addr do
		table.insert(self.LockedGate.DialledAddress,addr[i]);
	end
	table.insert(self.LockedGate.DialledAddress,"DIAL")
	self.LockedGate:SetDialMode(false,false)
	self.LockedGate:StartDialling()
end

function ENT:Touch(ent)
	if not IsValid(self.LockedGate) and (ent.IsGroupStargate) then
		self.LockedGate = ent
		self.LockedGate:TriggerInput("SGC Type",1)
		self:SetNW2Entity("Gate",ent)
		local ed = EffectData()
		ed:SetEntity(self)
		util.Effect("propspawn", ed, true, true)
	elseif not IsValid(self.IDCReceiver) and (ent.GDOStatus) then
		self.IDCReceiver = ent
		local ed = EffectData()
		ed:SetEntity(self)
		util.Effect("propspawn", ed, true, true)
	elseif not IsValid(self.Bomb) and ent:GetClass() == "naquadah_bomb" then
		self.Bomb = ent
		local ed = EffectData()
		ed:SetEntity(self)
		util.Effect("propspawn", ed, true, true)
	end
end

function ENT:Use(_,_,val)
	if val > 0 then
		if self.On then
			self.OffTimer = CurTime()
		else
			self.On = true
			self.StartTimer = CurTime()
			self.State = 0
		end
	else
		if self.OffTimer then self.OffTimer = nil end
	end
end

--[[
--FUNC CHECK--
print("--START CHECK1--")
local test = Entity(94):WireGetAddresses()
local test2 = ENT:FindFineGates(Entity(94))
for k,gate in pairs(test2) do
	print(ENT:GetFineAddress(gate,Entity(94)),test[k][1])
end
print("--START CHECK2--")
for k,gate in pairs(ents.FindByClass("stargate_*")) do
	if not gate.IsStargate then continue end
	local gates1,gates2 = ENT:FindFineGates(gate),gate:WireGetAddresses()
	if gates1 then
		if #gates1 ~= #gates2 then print("!!!",#gates1,#gates2) end
		for k,v in pairs(gates1) do
			local fine = false
			for k1,v1 in pairs(gates2) do
				if v.GateAddress:find(v1[1]:sub(1,#v.GateAddress)) then fine = true break end
			end
			if not fine then print(1,gate.GateAddress,v.GateAddress) end
		end
		for k1,v1 in pairs(gates2) do
			local fine = false
			for k,v in pairs(gates1) do
				if v1[1]:find(v.GateAddress) then fine = true break end
			end
			if not fine then print(2,gate.GateAddress,v1[1]) end
		end
	else print(v,#gates2) end
end
print("--END CHECK--")
]]
