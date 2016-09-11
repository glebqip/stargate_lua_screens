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
  if self.OffTimer and CurTime()-self.OffTimer > 1.8 then
    self.On = false
    print(2)
    self.OffTimer = nil
  end
  self:SetNW2Bool("On",self.On)
  local gate = self.LockedGate
  if (IsValid(gate)) and self.On then
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


    local LastChev = chevron > 7 or dialsymb == "#" or dialdsymb == "#" or chevron > 6 and dialsymb == "" and dialdsymb == ""
    --Dial error check
    if not inbound and not open and (active or chevron > 0) and LastChev then
      self.DialErr = true
      if locked then
        self.LockErr = true
      end
      if dialsymb ~= "" then
        self.LastDialSymb = dialsymb
      end
    elseif (self.DialErr or self.LockErr) then
      if not open and not inbound and chevron <= 0 and #self.DialingAddress >= 6 then -- we fail dial
        self.DCError = self.LockErr and 2 or 1
        self.DCErrorTimer = CurTime()
        --self.DCErrorStart = self.DCErrorTimer

        if #self.DialingAddress == 9 or self.DialingAddress[#self.DialingAddress] == "#" then
          self.LastDialSymb = self.DialingAddress:sub(-1,-1)
          self.DialingAddress = self.DialingAddress:sub(1,-2)
          self.ErrorAnim = true
          --self.DCErrorTimer = CurTime()+0.6
        else
          self.ErrorAnim = false
        end
      end
      self.DialErr = false
      self.LockErr = false
    end
    if self.DCError ~= 0 and CurTime()-self.DCErrorTimer > 10 or active then
      self.DCError = 0
    end
    local LastSecond = not open and LastChev and locked
    if active and (dialsymb == dialdsymb and not LastChev or LastSecond) and self.SymbolAnim and not self.SymbolAnim2 then
      self.SymbolAnim2 = true
      self.SymbolAnim = false
    elseif active and not open and dialsymb ~= "" and dialsymb == ringsymb and (not ringrot or LastChev) and not self.SymbolAnim and not self.SymbolAnim2 then
      self.SymbolAnim = true
    elseif (not active or open or inbound or ringrot and (not LastChev or dialsymb ~= ringsymb)) and (self.SymbolAnim or self.SymbolAnim2) then
      self.SymbolAnim2 = false
      self.SymbolAnim = false
    end
    if not self.SymbolAnim and not self.SymbolAnim2 and self.DCError == 0 then
      local smadd = (dialsymb ~= "" and dialsymb or dialdsymb ~= "" and dialdsymb or self.LastDialSymb)
      if self.LastDialSymb == self.DialingAddress[#self.DialingAddress] then
        smadd = ""
      end
      if LastSecond and dialadd[#dialadd] ~= "#" and chevron < 9 then
        self.DialingAddress = dialadd..smadd
        if self.EndTimer == nil then
          self.EndTimer = CurTime()
        end
      else
        if active and not open and locked then
          if self.EndTimer == nil then
            self.EndTimer = CurTime()
          end
          self.DialingAddress = dialadd..smadd
        elseif dialadd ~= "" or not self.Error and chevron >= 0 then
          self.DialingAddress = dialadd
        end
      end
    end

    self:SetNW2Bool("LastChev",LastChev)
    self:SetNW2Bool("ChevronFirst",self.SymbolAnim)
    self:SetNW2Int("DCError",self.DCError*(self.ErrorAnim and -1 or 1))
    self:SetNW2Int("DCErrorSymbol",self.LastDialSymb)
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

function ENT:Touch(ent)
  if not IsValid(self.LockedGate) then
    if (ent.IsGroupStargate) then --IsStargate
      self.LockedGate = ent
      local ed = EffectData()
      ed:SetEntity(self)
      util.Effect("propspawn", ed, true, true)
    end
  end
end

function ENT:Use(_,_,val)
  if val > 0 then
    if self.On then
      self.OffTimer = CurTime()
    else
      self.On = true
    end
  else
    if self.OffTimer then self.OffTimer = nil end
  end
end

function ENT:UpdateTransmitState() return TRANSMIT_ALWAYS end
