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
  if WireLib then
    self.Inputs = WireLib.CreateSpecialInputs(self,{"Keyboard"},{"ENTITY"})
  end
  self.Keys = {}

  self.MenuChoosed = 0
  self.MenuScrool = 0
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
  if self.RequestScreenReload then
    self.RequestScreenReload = false
    self:LoadScreens()
    self.RequestScreenReload = false
  end
  local srv = self.Server
  self:SetNW2Bool("ServerConnected",IsValid(srv))
  if not IsValid(srv) then
    self:NextThink(CurTime()+0.05)
    return true
  end

  if not self.Server.On then self.Screen = 0 end
  if self.Server.State == -1 and self.Screen == 0 and self.Server.On then
    self.Screen = 1
  elseif (self.Server.State ~= -1 or not self.Server.On) and self.Screen ~= 0 then
    self.Screen = 0
    self.MenuChoosed = 0
  end
  self:SetNW2Entity("Server",srv)
  self:SetNW2Int("CurrScreen",self.Screen)
  self:SetNW2Int("MenuChoosed",self.MenuChoosed)
  self:SetNW2Int("MenuScrool",self.MenuScrool)
  if self.Inputs.Keyboard.Path then
    local keyb = self.Inputs.Keyboard.Path[1].Entity
    for k,v in pairs(self.Keys) do
      if not keyb.ActiveKeys[v] then
        self:Trigger(k,false)
        self.Keys[k] = nil
      end
    end
    for k,v in pairs(keyb.ActiveKeys) do
      local key = keyb:GetRemappedKey(k)
      if not self.Keys[key] then
        self:Trigger(key,true)
        self.Keys[key] = k
      end
    end
  end
  for k,v in pairs(self.Screens) do
    v:Think(self.Screen == k)
  end
  self:NextThink(CurTime()+0.05)
  return true
end

function ENT:Trigger(key, value)
  if key == 13 and value and self.MenuChoosed > 0 then
    self.Screen = self.MenuChoosed
    self.MenuChoosed = 0
  end
  if key == 158 and value then
    if self.MenuChoosed > 0 then
      self.MenuChoosed = 0
    else
      self.MenuChoosed = 1
      self.MenuScrool = 0
    end
  end
  if self.MenuChoosed > 0 and key == 18 and value then
    self.MenuChoosed = math.min(#self.Screens,self.MenuChoosed + 1)
  end
  if self.MenuChoosed > 0 and key == 17 and value then
    self.MenuChoosed = math.max(1,self.MenuChoosed - 1)
  end
  if self.MenuScrool < self.MenuChoosed-8 then
    self.MenuScrool = self.MenuChoosed-8
  end
  if self.MenuScrool > self.MenuChoosed-1 then
    self.MenuScrool = self.MenuChoosed-1
  end
  for k,v in pairs(self.Screens) do
    if v:Trigger(self.Screen == k,key,value) then return end
  end
end

function ENT:Touch(ent)
  if not IsValid(self.Server) and ent.ServerVer == self.ClientVer then
    self.Server = ent
    local ed = EffectData()
    ed:SetEntity(self)
    util.Effect("propspawn", ed, true, true)
  elseif not IsValid(self.Server) and ent.ActiveKeys then
    self.Keyboard = ent
    local ed = EffectData()
    ed:SetEntity(self)
    util.Effect("propspawn", ed, true, true)
  end
end
function ENT:UpdateTransmitState() return TRANSMIT_ALWAYS end
