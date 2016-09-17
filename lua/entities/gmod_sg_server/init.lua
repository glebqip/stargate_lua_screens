/* Copyright (C) 2016 by glebqip */

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
ENT.ServerVer = 1

include("shared.lua")
if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("extra")) then return end

function ENT:Initialize()
  self:SetModel("models/props_lab/harddrive02.mdl")
  self:PhysicsInit(SOLID_VPHYSICS)
  self:SetMoveType(MOVETYPE_VPHYSICS)
  self:SetSolid(SOLID_VPHYSICS)
  self:SetUseType(1)

  self.DialingAddress = ""
  self.DCError = 0
  self.On = false

  self.OnSound = CreateSound(self,"glebqip/computer_loop.wav")
  self.OnSound:SetSoundLevel(55)
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
end

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

function ENT:Think()
  if self.OffTimer and CurTime()-self.OffTimer > 0.8 then
    self.On = false
    self.OffTimer = nil

    self.OnSound:Stop()
    self:EmitSound("glebqip/computer_end.wav",55)
    --self.OffSound:Play()
  end
  if self.On then
    self.OnSound:Play()
  end
  self:SetNW2Bool("On",self.On)

  --Start emulation
  if self.On and self.State > -1 then
    local time = CurTime() - self.StartTimer
    if self.State > 0 and math.random() > 0.95 then
      self:EmitSound("glebqip/hdd_"..math.random(1,6)..".wav",55,100,0.3)
    end
    if time > 3 and self.State == 0 then
      self:EmitSound("glebqip/computer_beep.wav",55)
      self.State = 1
    end
    if time > 4 and self.State == 1 then
      self.State = 2
    end
    if time > 7 and self.State == 2 then
      self.State = 3
    end
    if time > 7.3 and self.State == 3 then
      self.State = 4
    end
    if time > 11 and self.State == 4 then
      self.State = 5
      --self:EmitSound("glebqip/hdd_"..math.random(1,6)..".wav",55)
    end
    if time > 15 and self.State == 5 then
      self.State = 6
      --self:EmitSound("glebqip/hdd_"..math.random(1,6)..".wav",55)
    end
    if time > 17 and self.State == 6 then
      self.State = -1
      --self:EmitSound("glebqip/hdd_"..math.random(1,6)..".wav",55)
    end
  end
  self:SetNW2Int("LoadState",self.State)
  local gate = self.LockedGate
  if (IsValid(gate)) and self.On and self.State == -1 then
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
      self.SelfDestruct = true
      self.SelfDestructTimer = CurTime()+120+3
    elseif enter == 2 and self.SelfDestruct then
      self.SelfDestruct = false
      self.SelfDestructTimer = CurTime()
    end
    self:SetNW2Bool("SelfDestruct",self.SelfDestruct)
    self:SetNW2Int("SDTimer",self.SelfDestructTimer)
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

    --Symbol animation triggers
    local LastSecond = not open and LastChev and locked
    local FirstRight = targeraddr[chevron+1] == ringsymb and (not ringrot or LastChev)
    local SecondRight = (targeraddr[chevron] == dialsymb and not LastChev) or locked

    if active and not open and SecondRight and self.SymbolAnim and not self.SymbolAnim2 then
      self.SymbolAnim2 = true
      self.SymbolAnim = false
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
          smadd = self.LastDialSymb
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
    self:SetNW2String("DialingAddress",self.DialingAddress)
    self:SetNW2String("DialingAddressDelta",dadddelta)

    --self:SetNWString("SGAddress", gate:GetWire("Dialing Address", "", true))
  end
  self:SetNW2Bool("Connected", IsValid(gate))
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
    local ed = EffectData()
    ed:SetEntity(self)
    util.Effect("propspawn", ed, true, true)
  elseif not IsValid(self.IDCReceiver) and (ent.GDOStatus) then
    self.IDCReceiver = ent
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

function ENT:OnRemove()
  self.OnSound:Stop()
end
function ENT:UpdateTransmitState() return TRANSMIT_ALWAYS end
