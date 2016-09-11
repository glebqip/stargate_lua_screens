---------------------
-- Screen: IDC s1 --
-- Author: glebqip --
-- ID: 2 --
---------------------


local SCR = {}
if SERVER then
else
  function SCR:Initialize()
    self.Boxes = {}
    self.BoxesTimer = CurTime()

    self.Digits1 = {}
    self.Digits1Timer = CurTime()-1
    self.Digits2 = {}
    self.Digits2Timer = CurTime()-3

    self.IOpenCTimer = CurTime()-1
  end

  local MainFrame = surface.GetTextureID("glebqip/idc screen 1/MainFrame")
  local Ring = surface.GetTextureID("glebqip/dial screen 1/Ring")
  local RingArcs = surface.GetTextureID("glebqip/dial screen 1/RingArcs")
  local Chevron = surface.GetTextureID("glebqip/dial screen 1/Chevron")
  local Chevron7 = surface.GetTextureID("glebqip/dial screen 1/Chevron7")
  local ChevronBox = surface.GetTextureID("glebqip/dial screen 1/ChevronBox")

  local OpenRed = surface.GetTextureID("glebqip/idc screen 1/OpenRed")

  local Red = Color(239,0,0)

  function draw.DrawTLine(x1,y1,x2,y2,sz)
    if x1 == x2 then
      -- vertical line
      local wid = (sz or 1) / 2
      surface.DrawRect(x1-wid, y1, wid*2, y2-y1)
    elseif y1 == y2 then
      -- horizontal line
      local wid = (sz or 1) / 2
      surface.DrawRect(x1, y1-wid, x2-x1, wid*2)
    else
      -- other lines
      local x3 = (x1 + x2) / 2
      local y3 = (y1 + y2) / 2
      local wx = math.sqrt((x2-x1) ^ 2 + (y2-y1) ^ 2)
      local angle = math.deg(math.atan2(y1-y2, x2-x1))
      render.SetTexture()
      surface.DrawTexturedRectRotated(x3, y3, wx, (sz or 1), angle)
    end
  end

  function SCR:Draw(MainColor, SecondColor, ChevBoxesColor)
    local open = self:GetNW2Bool("Open",false)
    local py = (CurTime()-self.Digits1Timer)%0.5*2-1
    if CurTime()-self.Digits2Timer < 4 then
      local anim = (CurTime()-self.Digits2Timer)%4
      local x,w = 0,0
      if anim < 1 then
        w = 1-anim
        x = anim
      elseif anim > 3 then
        w = anim-3
      end
      for i=0,3 do
        if self.Digits2[i+1] then
          draw.SimpleText(self.Digits2[i+1], "Marlett_10", 259,338+i*10, SecondColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
          --scr.drawText(259,402+i*10,self.Digits2[i+1],0,1,SecondColor,font("Marlett",10)) --FIXME
        end
      end
      if w > 0 then
        surface.SetDrawColor(Color(0,0,0))
        surface.DrawRect(255+x*152,332,152*w,41)
      end
    end

    if #self.Digits1 > 0 then
      for i=0,#self.Digits1-1 do
        if self.Digits1[i+1] then
          --scr.drawText(92,97+(i+py)*9,Digits[i+1],0,1,SecondColor,font("Marlett",10))
          draw.SimpleText(self.Digits1[i+1], "Marlett_12", 92,33+(i+py)*11+2, SecondColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
      end
    end
    if open then
      surface.SetDrawColor(Color(109,196,255,100))
      surface.DrawRect(88,350,158,22)
    end
    surface.SetDrawColor(MainColor)
    surface.SetTexture(MainFrame)
    surface.DrawTexturedRectRotated(256,192,512,512,0)
    surface.SetDrawColor(SecondColor)
    surface.SetTexture(RingArcs)
    surface.DrawTexturedRectRotated(381,105,196,196,0)
    surface.SetTexture(Ring)
    surface.DrawTexturedRectRotated(381,105,197,197,self:GetNW2Int("RingAngle",0)-4.615)

    surface.SetTexture(OpenRed)
    if open then
      for i=0,(CurTime()-self.IOpenCTimer > 2 and 2 or 0) do
        local anim = (CurTime()+i*2-self.IOpenCTimer)%4
        if anim < 3 then
          surface.SetDrawColor(Red)
          surface.DrawTexturedRectRotated(381,105,256*anim/3,256*anim/3,0)
        elseif anim < 4 then
          surface.SetDrawColor(Color(220,0,0,(4-anim)*255))
          surface.DrawTexturedRectRotated(381,105,256,256,0)
        end
      end

      surface.SetDrawColor(Red)
      draw.DrawTLine(381,31,381,179,2)
      draw.DrawTLine(307,105,456,105,2)
    else
      surface.SetDrawColor(MainColor)
      draw.DrawTLine(381,83,381,127,2)
      draw.DrawTLine(359,105,403,105,2)
    end

    surface.SetDrawColor(SecondColor)
    for i=1,36 do
      if self.Boxes[i] then
        local x,y = 0,0
        if i > 18 then x = 34 end
        if i > 9 and i < 18 or i > 27 then y = 32 end
        if self.Boxes[i] then
          surface.DrawRect(436+i%3*6+x,313+math.ceil(i/3-1)%3*6+y,4,4)
        end
      end
    end

    local ChevronState = math.Clamp((CurTime()-self.IOpenCTimer)*4,0,1)
    if not self:GetNW2Bool("Open") then ChevronState = 1-ChevronState end
    for i=1,9 do
      local ang = 180-(360/9)*i
      local rad = math.rad(ang)
      local X,Y = math.sin(rad)*(86-ChevronState*4.5), math.cos(rad)*(86-ChevronState*4.5)
      local X2,Y2 = math.sin(rad)*(93+ChevronState*4.5), math.cos(rad)*(93+ChevronState*4.5)
      local active = self:GetNW2String("Chevrons")[i == 9 and 7 or i>5 and i-2 or i > 3 and i+4 or i] == "1"
      surface.SetDrawColor(active and Red or SecondColor)
      if i < 9 then
        surface.SetTexture(Chevron)
        surface.DrawTexturedRectRotated(381+X,105+Y,25,25,ang+180)
      else
        surface.SetTexture(Chevron7)
        surface.DrawTexturedRectRotated(381+X,105+Y,25,25,0)
      end
      surface.SetDrawColor(active and Red or ChevBoxesColor)
      surface.SetTexture(ChevronBox)
      surface.DrawTexturedRectRotated(381+X2,105+Y2,12,12,ang+180)
    end

    draw.SimpleText("RECEIVING DATA", "Marlett_21", 90, 19, SecondColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

    draw.SimpleText("CONDITION:", "Marlett_15", 255, 210, MainColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

    if open then
      draw.SimpleText("ACTIVE", "Marlett_15", 330, 210, Color(20,160,20), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    else
      local Alpha = math.abs(math.sin(CurTime()*math.pi/2))
      surface.SetAlphaMultiplier(Alpha)
      draw.SimpleText("IDLE", "Marlett_15", 330, 210, MainColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
    if open then draw.SimpleText("PROCESSING", "Marlett_15", 8, 366, SecondColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER) end
  end

  function SCR:Think(curr)
    if not curr then return end
    local connected = self:GetNW2Bool("Connected",false)
    local active = self:GetNW2Bool("Active",false)
    local open = self:GetNW2Bool("Open",false)

    if self.Open ~= open then
      self.IOpenCTimer = CurTime()
      self.Open = open
    end
    if CurTime()-self.BoxesTimer > 0.15 and connected then
      for i=1,36 do
        self.Boxes[i] = math.random()>0.4
      end
      self.BoxesTimer = CurTime()
    end
    if CurTime()-self.Digits1Timer > 0.5 then
        if connected and active then
            str = ""
            for _=1,25 do
                str = str..tostring(math.random(0,9))
            end
            table.insert(self.Digits1,1,str)
        else
            table.insert(self.Digits1,1,nil)
        end
        table.remove(self.Digits1,33)
        self.Digits1Timer = CurTime()
    end
    if CurTime()-self.Digits2Timer > 4 then
      if connected and active then
          for i=1,4 do
              str = ""
              for i=1,36 do
                  str = str..tostring(math.random(0,9))
              end
              self.Digits2[i] = str
          end
      else
          if self.Digits2[1] then self.Digits2 = {} end
      end
      self.Digits2Timer = CurTime()
    end
  end
end

return 2,SCR
