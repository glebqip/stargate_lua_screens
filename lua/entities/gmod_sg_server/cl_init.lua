include("shared.lua")

if (SGLanguage ~=nil and SGLanguage.GetMessage ~=nil) then
  ENT.Category = SGLanguage.GetMessage("entity_main_cat")
  ENT.PrintName = SGLanguage.GetMessage("sgc_computer")
end

local sprite = Material("sprites/glow04_noz")
function ENT:Draw()
  self:DrawModel()
  render.SetMaterial(sprite)
  if self:GetNW2Bool("On",false) then
    if not self:GetNW2Bool("Connected",false) then
      render.DrawSprite( self:LocalToWorld(Vector(9.9,2.4,0.4)), 3, 3, Color(200,0,0) )
    end
    render.DrawSprite( self:LocalToWorld(Vector(9.9,2.4,-0.4)), 3, 3, Color(0,200,0) )
  end
  return true
end


function ENT:Initialize()
  self.OnSound = CreateSound(self,"glebqip/computer_loop.wav")
  self.OnSound:SetSoundLevel(55)
end

function ENT:Think()
  if self.On then
    self.OnSound:PlayEx(0.6,100)
  end
  if self.On ~= self:GetNW2Bool("On",false) then
    if self.On then
      self.OnSound:Stop()
      self:EmitSound("glebqip/computer_end.wav",55)
    end
      self.On = self:GetNW2Bool("On",false)
  end
end

function ENT:SolveHook(name,old,new)
  if not self.HookBinds[name] then return end
  for id, tbl in pairs(self.HookBinds[name]) do
    if not IsValid(tbl[2]) then
      print("Removing hook",name,id)
      self.HookBinds[name][id] = nil
      continue
    end
    tbl[1](self,name,old,new)
  end
end

function ENT:BindNW2Hook(ent,hookname, name, func)
  if not self.HookBinds then
    self.HookBinds = {}
    self.HookCleanups = {}
  end
  if not self.HookBinds[hookname] then
    self:SetNWVarProxy(hookname,self.SolveHook)
    self.HookBinds[hookname] = {} --create table with funcs
  end
  self.HookBinds[hookname][name.."."..ent:EntIndex()] = {func,ent}
  print(ent,hookname)
end

function ENT:OnRemove()
  self.OnSound:Stop()
  self:EmitSound("glebqip/computer_end.wav",55)
end
