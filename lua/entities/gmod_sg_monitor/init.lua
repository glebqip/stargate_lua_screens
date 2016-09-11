/* Copyright (C) 2016 by glebqip */
resource.AddWorkshop("761096308")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_gpudraw_lite.lua")
for _,filename in pairs(file.Find("entities/gmod_sg_monitor/screens/*.lua","LUA")) do AddCSLuaFile("entities/gmod_sg_monitor/screens/"..filename) end
ENT.ClientVer = 1

include("shared.lua")
if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("extra")) then return end

function ENT:Initialize()
  self:SetModel("models/props_lab/monitor01a.mdl")
  self:PhysicsInit(SOLID_VPHYSICS)
  self:SetMoveType(MOVETYPE_VPHYSICS)
  self:SetSolid(SOLID_VPHYSICS)

  self.Screen = 0
  self:LoadScreens()
end

function ENT:SpawnFunction(ply, tr)
  if (not tr.Hit) then return end

  local ang = ply:GetAimVector():Angle()
  ang.p,ang.r = 0,0
  ang.y = (ang.y+180)%360

  local ent = ents.Create("gmod_sg_monitor")
  ent:SetAngles(ang)
  ent:SetPos(tr.HitPos+Vector(0, 0, 20))
  ent:Spawn()
  ent:Activate()
  ent.SpawnedPly = ply

  local phys = ent:GetPhysicsObject()
  if IsValid(phys) then phys:EnableMotion(false) end
  return ent
end

function ENT:Think()
  if not self.Server.On then self.Screen = 0 end
  if self.RequestScreenReload then
    self.RequestScreenReload = false
    self:LoadScreens()
    self.RequestScreenReload = false
  end
  local srv = self.Server
  self:SetNW2Bool("ServerConnected",IsValid(srv))
  if (IsValid(srv)) then
    self:SetNW2Entity("Server",srv)
    self:SetNW2Int("CurrScreen",self.Screen)
    --[[
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
    ]]
    --self:SetNWString("SGAddress", gate:GetWire("Dialing Address", "", true))
  end
  self:NextThink(CurTime()+0.075)
  return true
end

function ENT:Touch(ent)
  if not IsValid(self.Server) then
    if ent.ServerVer == self.ClientVer then --valid server
      self.Server = ent
      local ed = EffectData()
      ed:SetEntity(self)
      util.Effect("propspawn", ed, true, true)
    end
  end
end
function ENT:UpdateTransmitState() return TRANSMIT_ALWAYS end
