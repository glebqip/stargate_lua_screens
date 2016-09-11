include("shared.lua")
include("cl_gpudraw_lite.lua")
local Screens = {}
for _,filename in pairs(file.Find("entities/gmod_sg_monitor/screens/*.lua","LUA")) do
  local ID,SCR = include("entities/gmod_sg_monitor/screens/"..filename)
  Screens[ID] = function(ent)
    local tbl = {}
    for k,v in pairs(SCR) do
      tbl[k] = v
    end
    tbl.Entity = ent
    tbl.GetMonitorBool = function(_, id, default) return ent:GetNW2Bool(id, default) end
    tbl.GetMonitorInt = function(_, id, default) return ent:GetNW2Int(id, default) end
    tbl.GetMonitorString = function(_, id, default) return ent:GetNW2String(id, default) end
    tbl.GetServerBool = function(_,id, default)
      if not IsValid(ent.Server) then return default end
      return ent.Server:GetNW2Bool(id, default)
    end
    tbl.GetServerInt = function(_,id, default)
      if not IsValid(ent.Server) then return default end
      return ent.Server:GetNW2Int(id, default)
    end
    tbl.GetServerString = function(_,id, default)
      if not IsValid(ent.Server) then return default end
      return ent.Server:GetNW2String(id, default)
    end
    tbl.EmitSound = function(_,...) return ent:EmitSound(...) end
    return tbl
  end
end

surface.CreateFont("SGC_SG1", {font="Stargate Address Glyphs Concept", size=35, weight=400, antialias=true, additive=false})
surface.CreateFont("SGC_Symb", {font="Stargate Address Glyphs Concept", size=90, weight=400, antialias=true, additive=false, })
surface.CreateFont("Marlett_10", {font="Marlett", size=10, weight=800, antialias=true, additive=false, })
surface.CreateFont("Marlett_12", {font="Marlett", size=12, weight=800, antialias=true, additive=false, })
surface.CreateFont("Marlett_15", {font="Marlett", size=15, weight=800, antialias=true, additive=false, })
surface.CreateFont("Marlett_21", {font="Marlett", size=21, weight=800, antialias=true, additive=false, })
surface.CreateFont("Marlett_22", {font="Marlett", size=22, weight=800, antialias=true, additive=false, })
surface.CreateFont("Marlett_25", {font="Marlett", size=25, weight=800, antialias=true, additive=false, })
surface.CreateFont("Marlett_27", {font="Marlett", size=27, weight=800, antialias=true, additive=false, })
surface.CreateFont("Marlett_29", {font="Marlett", size=29, weight=800, antialias=true, additive=false, })
surface.CreateFont("Marlett_Open", {font="Marlett", size=46, weight=800, antialias=true, additive=false, })
surface.CreateFont("Marlett_Err", {font="Marlett", size=19, weight=800, antialias=true, additive=false, })
surface.CreateFont("Marlett_Error", {font="Marlett", size=56, weight=800, antialias=true, additive=false, })
surface.CreateFont("NOSignal", {font="Arial Black", size=30, weight=800, antialias=false, additive=false, })

if (SGLanguage ~=nil and SGLanguage.GetMessage ~=nil) then
  ENT.Category = SGLanguage.GetMessage("entity_main_cat")
  ENT.PrintName = SGLanguage.GetMessage("sgc_computer")
end

function ENT:Initialize()
  self:ScreenInit(512, 384, Vector(11.75, -512/2*0.04, 384/2*0.04+3.9), Angle(0, 90, 85.5), 0.04)
  --Colors:Movie
  self.MainColor = Color(42, 125, 225)
  self.ChevBoxesColor = self.MainColor
  self.SecondColor = Color(229, 238, 179)
  --Colors:First series
  self.MainColor = Color(40, 167, 240)
  self.ChevBoxesColor = self.MainColor
  self.SecondColor = Color(200, 200, 200)
  --Colors:
  self.MainColor = Color(30, 180, 200)
  self.ChevBoxesColor = self.MainColor
  self.SecondColor = Color(200, 200, 182)
  --self.SecondColor = Color(208, 208, 144)
  self.Screens = {}
  for k, v in pairs(Screens) do
    self.Screens[k] = v(self)
    self.Screens[k]:Initialize(self)
  end

  self.NoSignalXDir = 1
  self.NoSignalYDir = 1
  self.NoSignalX = 0
  self.NoSignalY = 0
  self.Server =nil
end

function ENT:Draw()
  self:DrawModel()
  self:DrawScreen(0, -10, 512, 410, 0.96)
  return true
end

--hi garrysmod.com, i am so lazy
function draw.OutlinedBox(x, y, w, h, thickness)
  for i=0, thickness - 1 do
    surface.DrawOutlinedRect(x + i, y + i, w - i * 2, h - i * 2)
  end
end

function ENT:Screen()
  if not self:GetNW2Bool("ServerConnected",false) then
    for i=0,7 do
      local r = i%4 < 2 and 255 or 0
      local g = i%8 < 4 and 255 or 0
      local b = i%2 == 0 and 255 or 0
      surface.SetDrawColor(r,g,b)
      surface.DrawRect(512/8*i,1,64,384-130-1)
      surface.SetDrawColor(r/2,g/2,b/2)
      for i1=1,4 do
        surface.SetDrawColor(r/5*i1,g/5*i1,b/5*i1)
        surface.DrawRect(512/8*i,334-20*i1,64,20)
      end
      surface.SetDrawColor(255-i*36.4,255-i*36.4,255-i*36.4)
      surface.DrawRect(512/8*i,334,64,49)

      surface.SetDrawColor(0,0,0,130)
      surface.DrawRect(256-75,192-13,150,26)
      draw.SimpleText("NO SIGNAL", "NOSignal", 256,192, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

  elseif not self:GetNW2Bool("ServerConnected",false) then
    self.NoSignalX = self.NoSignalX + 30*FrameTime()*self.NoSignalXDir
    if self.NoSignalX+210 > 512 then self.NoSignalXDir = -1 elseif self.NoSignalX < 0 then self.NoSignalXDir = 1 end
    self.NoSignalY = self.NoSignalY + 30*FrameTime()*self.NoSignalYDir
    if self.NoSignalY+130 > 384 then self.NoSignalYDir = -1 elseif self.NoSignalY < 0 then self.NoSignalYDir = 1 end

    local x,y = self.NoSignalX,self.NoSignalY
    --self.NoSignalX = self.NoSignalX + 10*FrameTime()
    surface.SetDrawColor(200,200,220)
    surface.DrawRect(x + 0,y + 0,210,30)
    draw.SimpleText("NO SIGNAL", "NOSignal", x+105,y+15, Color(0,0,0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    for i=0,2 do
      surface.SetDrawColor(i==0 and 255 or 0,i==1 and 255 or 0,i==2 and 255 or 0)
      surface.DrawRect(x + 70*i,y + 30,70,100)
    end
    --draw.SimpleText("POST PLACEHOLDER", "Marlett_21", 0,0, color, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
  elseif self:GetNW2Int("CurrScreen",0) > 0 then
    self.Screens[self:GetNW2Int("CurrScreen",0)]:Draw(self.MainColor,self.SecondColor,self.ChevBoxesColor)
  else
    draw.SimpleText("POST PLACEHOLDER", "Marlett_21", 0,0, color, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
  end

  surface.SetAlphaMultiplier(1)
end

function ENT:Think()
  self.Server = self:GetNW2Entity("Server")
  if self:GetNW2Int("CurrScreen",0) > 0 then
    self.Screens[self:GetNW2Int("CurrScreen",0)]:Think(true)
  end
  for k, v in pairs(self.Screens) do
    --v:Think(k==self:GetNW2Int("CurrScreen",0))
  end
end
