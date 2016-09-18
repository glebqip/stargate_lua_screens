include("shared.lua")
include("cl_gpudraw_lite.lua")

surface.CreateFont("SGC_SG1", {font="Stargate Address Glyphs Concept", size=35, weight=400, antialias=true, additive=false})
surface.CreateFont("SGC_Symb", {font="Stargate Address Glyphs Concept", size=90, weight=400, antialias=true, additive=false, })
surface.CreateFont("Marlett_10", {font="Marlett", size=10, weight=800, antialias=true, additive=false, })
surface.CreateFont("Marlett_11", {font="Marlett", size=11, weight=800, antialias=true, additive=false, })
surface.CreateFont("Marlett_12", {font="Marlett", size=12, weight=800, antialias=true, additive=false, })
surface.CreateFont("Marlett_15", {font="Marlett", size=15, weight=800, antialias=true, additive=false, })
surface.CreateFont("Marlett_16", {font="Marlett", size=16, weight=800, antialias=true, additive=false, })
surface.CreateFont("Marlett_18", {font="Marlett", size=18, weight=800, antialias=true, additive=false, })
surface.CreateFont("Marlett_21", {font="Marlett", size=21, weight=800, antialias=true, additive=false, })
surface.CreateFont("Marlett_22", {font="Marlett", size=22, weight=800, antialias=true, additive=false, })
surface.CreateFont("Marlett_25", {font="Marlett", size=25, weight=800, antialias=true, additive=false, })
surface.CreateFont("Marlett_27", {font="Marlett", size=27, weight=800, antialias=true, additive=false, })
surface.CreateFont("Marlett_29", {font="Marlett", size=29, weight=800, antialias=true, additive=false, })
surface.CreateFont("Marlett_35", {font="Marlett", size=35, weight=800, antialias=true, additive=false, })
surface.CreateFont("Marlett_45", {font="Marlett", size=45, weight=800, antialias=true, additive=false, })
surface.CreateFont("Marlett_50", {font="Marlett", size=50, weight=800, antialias=true, additive=false, })
surface.CreateFont("Marlett_61", {font="Marlett", size=61, weight=800, antialias=true, additive=false, })
surface.CreateFont("Marlett_Open", {font="Marlett", size=46, weight=800, antialias=true, additive=false, })
surface.CreateFont("Marlett_Err", {font="Marlett", size=19, weight=800, antialias=true, additive=false, })
surface.CreateFont("Marlett_Error", {font="Marlett", size=56, weight=800, antialias=true, additive=false, })
surface.CreateFont("NOSignal", {font="Arial Black", size=30, weight=800, antialias=false, additive=false, })

local Select = surface.GetTextureID("glebqip/Select")

local SelfDestructCode = surface.GetTextureID("glebqip/active screen 1/sd_code")
local SelfDestructStandby = surface.GetTextureID("glebqip/active screen 1/sd_standby")

if (SGLanguage ~=nil and SGLanguage.GetMessage ~=nil) then
  ENT.Category = SGLanguage.GetMessage("entity_main_cat")
  ENT.PrintName = SGLanguage.GetMessage("sgc_computer")
end

function ENT:Initialize()
  self:LoadScreens()

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

  self.NoSignalXDir = 1
  self.NoSignalYDir = 1
  self.NoSignalX = 0
  self.NoSignalY = 0
  self.Server =nil
  self.IDCSound = CreateSound(self,"glebqip/idc_loop.wav")
  self.IDCSound:SetSoundLevel(55)
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
local function AnimFromToXY(srcx,srcy,targetx,targety,state)
  return Lerp(state,srcx,targetx), Lerp(state,srcy,targety)
end
function ENT:Screen()
  if not self:GetNW2Bool("On",false) then return end
  if false and not self:GetNW2Bool("ServerConnected",false) then
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

  elseif not self:GetNW2Bool("ServerConnected",false) or not IsValid(self.Server) then
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
    surface.SetAlphaMultiplier(1)
    local code = self:GetNW2String("SDCode","")
    if self:GetNW2Int("CurrScreen",0) ~= 3 and self.Server:GetNW2Bool("SelfDestruct",false) and CurTime()%1 > 0.5 then
      surface.SetDrawColor(255,255,255)
      surface.DrawRect(46,106,420,172)
      surface.SetDrawColor(200,40,40)
      surface.DrawRect(52,112,408,160)
      surface.SetDrawColor(45,165,235)
      surface.DrawRect(58,118,396,148)
      draw.SimpleText("DESTRUCT", "Marlett_61", 256,165, Color(200,40,40), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
      draw.SimpleText("SEQUENCE ACTIVATED", "Marlett_35", 256,212, Color(200,40,40), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
      draw.SimpleText("CODE 2165132146", "Marlett_21", 256,236, Color(200,40,40), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    if self.SDOpTimer or self.SDClTimer and CurTime()-self.SDClTimer <= 0.17 then
      mat = Matrix()
      local anim = 0
      if self.SDOpTimer then
        anim = 1-math.Clamp((CurTime()-self.SDOpTimer)*6,0,1)
      else
        anim = math.Clamp((CurTime()-self.SDClTimer)*6,0,1)
      end
      local x,y = AnimFromToXY(256,166,556,466,anim)
      local sd2t = self.SDEnTimer and CurTime()-self.SDEnTimer
      mat:Translate(Vector(x,y,0))
      mat:Scale(Vector(1-anim,1-anim,1-anim))
      mat:Translate(Vector(0,0,0))
      local color = Color(200,200,182)
      if self:GetNW2Int("SDState",0) == -2 then
        color = Color(114,55,37,255)
      end
      cam.PushModelMatrix(mat)
      surface.SetDrawColor(0,0,0)
      surface.DrawRect(-163,-70,327,140)
      for i=1,#code do
        draw.SimpleText("X", "Marlett_35", -143+i*32,-32, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
      end
      surface.SetDrawColor(color)
      if sd2t and sd2t < 0.20 then
        local anim = (sd2t)*5
        surface.DrawRect(-127,-50,256*anim,36)
      elseif sd2t and sd2t < 0.60 and sd2t%0.2 > 0.1 then
        surface.DrawRect(-127,-50,256,36)
      elseif self:GetNW2Int("SDState",0) == -2 then
        surface.DrawRect(-127,-50,256,36)
        draw.SimpleText("Entered code is not valid", "Marlett_21", -143,45, Color(200, 100, 100), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

      end
      surface.SetDrawColor(self.MainColor)
      surface.SetTexture(SelfDestructCode)
      surface.DrawTexturedRectRotated(0,0 ,512,256,0)
      cam.PopModelMatrix()
    end
    if self.SDStTimer then
      mat = Matrix()
      local anim = 0
      anim = 1-math.Clamp((CurTime()-self.SDStTimer)*6,0,1)
      local x,y = AnimFromToXY(256,166,556,466,anim)
      mat:Translate(Vector(x,y,0))
      mat:Scale(Vector(1-anim,1-anim,1-anim))
      mat:Translate(Vector(0,0,0))
      cam.PushModelMatrix(mat)
      surface.SetDrawColor(0,0,0)
      surface.DrawRect(-163,-70,327,140)
      surface.SetDrawColor(Color(114,55,37,255))
      surface.SetTexture(SelfDestructStandby)
      surface.DrawTexturedRectRotated(0,0 ,512,256,0)
      draw.SimpleText(self:GetNW2String("SDName",""), "Marlett_22", 0,-23, Color(114,55,37,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
      cam.PopModelMatrix()
    end

    local menu = self:GetNW2Int("MenuChoosed",0)
    local scrool = self:GetNW2Int("MenuScrool",0)
    if menu > 0 then
      surface.SetDrawColor(0,0,0)
      surface.DrawRect(292,168,9,79)
      surface.SetDrawColor(127,228,223)
      local maxscrool = math.max(0,(#self.Screens-8))
      local scroolsize = math.floor(75/(maxscrool+1))
      surface.DrawRect(293,171+(75-scroolsize)/maxscrool*scrool,7,scroolsize)

      surface.SetTexture(Select)
      surface.DrawTexturedRectRotated(256,192,256,256,0)

      surface.SetDrawColor(229,242,217)
      surface.DrawRect(156,149+(menu-scrool)*12,132,11)
      for i=1+scrool,math.min(8+scrool,#self.Screens) do
        draw.SimpleText(self.Screens[i].Name, "Marlett_15", 157,154+(i-scrool)*12, menu == i and Color(0,0,0) or Color(229,242,217), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
      end
    end
  elseif self.Server:GetNW2Bool("On",false) then
    local LoadState = self.Server:GetNW2Int("LoadState",-1)
    if LoadState > 1 then
      draw.SimpleText("Stargate command BIOS", "Marlett_21", 40,0, Color(150,150,150), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
      draw.SimpleText("Copyright (C) 1990-99", "Marlett_21", 40,20, Color(150,150,150), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

      if LoadState > 2 then
        draw.SimpleText("Processor: Intel Pentium MMX 233 MHz", "Marlett_21", 10,20*3, Color(150,150,150), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
      end
      if LoadState > 3 then
        local time = math.min(25000,(CurTime()-self.StartTime)*25000/3)
        draw.SimpleText(string.format("Memory test: %d %s",time,time == 25000 and "OK" or ""), "Marlett_21", 10,20*4, Color(150,150,150), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
      end
      if LoadState > 4 then
        local time = math.min(0x25A80000,(CurTime()-self.StartTime2)*0x25A80000/2)
        draw.SimpleText(string.format("Сhecking resources: 0x%X %s",time,time == 0x25A80000 and "OK" or ""), "Marlett_21", 10,20*5, Color(150,150,150), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
      end
      if LoadState > 5 then
        draw.SimpleText("Booting"..string.rep(".",CurTime()%0.5*6+0.5), "Marlett_21", 10,20*7, Color(150,150,150), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
      end
    end
  end

  surface.SetAlphaMultiplier(1)
end

function ENT:Think()
  if self.CurrScreen ~= 5 or self.Screens[5].State ~= 2 then
    self.IDCSound:Stop()
  else
    self.IDCSound:Play()
    self.IDCSound:ChangeVolume(0.4)
  end
  --Reload screen scripts on change
  if self.RequestScreenReload then
    self.RequestScreenReload = false
    self:LoadScreens()
  end
  self.Server = self:GetNW2Entity("Server")
  if not IsValid(self.Server) then
    return
  end
  if self.CurrScreen ~= self:GetNW2Int("CurrScreen",0) then
    self.CurrScreen = self:GetNW2Int("CurrScreen",0)
    if self.Screens[self.CurrScreen] then
      self.Screens[self.CurrScreen]:Initialize(true)
    end
  end
  if self:GetNW2Int("CurrScreen",0) > 0 then
    for k,v in pairs(self.Screens) do
      v:Think(self.CurrScreen == k)
    end
  end
  local LoadState = self.Server:GetNW2Int("LoadState",-1)
  if LoadState > 0 then
    if LoadState > 3 then
      if not self.StartTime then
        self.StartTime = CurTime()
      end
    else
      self.StartTime = nil
      self.StartTime2 = nil
    end
    if LoadState > 4 and not self.StartTime2 then
      self.StartTime2 = CurTime()
    end
  end
  local SDState = self:GetNW2Int("SDState",0)
  if SDState == 1 and not self.SDOpTimer then
    self.SDOpTimer = CurTime()--(1-math.Clamp((CurTime()-(self.SDClTimer or CurTime()))*6,0,1))
    self.SDClTimer = nil
  end
  if (SDState == -1 or SDState == 0 or SDState == 3) and not self.SDClTimer and self.SDOpTimer then
    self.SDClTimer = CurTime()--(1-math.Clamp((CurTime()-(self.SDOpTimer or CurTime()))*6,0,1))
    self.SDOpTimer = nil
  end
  if self.SDClTimer and CurTime()-self.SDClTimer > 0.2 then
    self.SDClTimer = nil
  end
  if SDState == 2 and not self.SDEnTimer then
    self.SDEnTimer = CurTime()
  elseif SDState ~= 2 and self.SDEnTimer then
    self.SDEnTimer = nil
  end
  if SDState == -1 and not self.SDStTimer and not self.SDOpTimer and not self.SDEnTimer then
    self.SDStTimer = CurTime()
  elseif SDState ~= -1 and self.SDStTimer then
    self.SDStTimer = nil
  end
  local timer = self.Server:GetNW2Int("SDTimer",0)
  if self.Server:GetNW2Bool("SelfDestruct",false) and timer ~= self.DestructTime then
    if self.DSound then self:EmitSound("glebqip/self_destruct_beep3.wav",65,100,0.2) end
    self.DSound = timer%1 < 0.5
    self.DestructTime = timer
  end
end

function ENT:OnRemove()
  self.IDCSound:Stop()
end
