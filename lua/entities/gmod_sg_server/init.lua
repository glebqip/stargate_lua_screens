/* Copyright (C) 2016 by glebqip */
resource.AddWorkshop("761096308")

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
  local gate = self.LockedGate
  if (IsValid(gate)) and true then
    self:SetNW2Int("RingAngle", gate:GetRingAng())
    self:SetNW2Bool("Active", gate.NewActive)
    self:SetNW2Bool("Open", gate.IsOpen)
    self:SetNW2Bool("Inbound", gate.Active and not gate.Outbound)
    --print(gate:GetNW2Bool("ActChevronsL"))
    self:SetNW2Bool("RingRotation", gate:GetWire("Ring Rotation", 0, true) ~= 0)
    self:SetNW2Bool("ChevronLocked", gate:GetWire("Chevron Locked", 0, true)> 0)
    self:SetNW2Int("Chevron", gate:GetWire("Chevron", 0, true))
    self:SetNW2String("Chevrons", gate:GetWire("Chevrons", "", true))
    self:SetNW2String("DialingAddress", gate:GetWire("Dialing Address", "", true))
    self:SetNW2String("DialingSymbol", gate:GetWire("Dialing Symbol", "", true))
    self:SetNW2String("DialedSymbol", gate:GetWire("Dialed Symbol", "", true))
    self:SetNW2String("RingSymbol", gate:GetWire("Ring Symbol", "", true))
    self:SetNW2Bool("Local",gate.GateLocal)

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

function ENT:UpdateTransmitState() return TRANSMIT_ALWAYS end
