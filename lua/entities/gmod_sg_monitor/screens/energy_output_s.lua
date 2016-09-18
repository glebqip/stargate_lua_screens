---------------------
-- Screen: IDC s1 --
-- Author: glebqip --
-- ID: 2 --
---------------------

local SCR = {
  Name = "Energy output (series)",
  ID = 7,
}

if SERVER then
  function SCR:Initialize()
  end

  function SCR:Think(curr)
  end
  function SCR:Trigger(curr,key,value)
  end
else
  function SCR:Initialize()
    self.Lines = {}
    self.Lines2 = {}
    self.Lines3 = {}
    self.LinesTimer = CurTime()-3
    self.Active = false

    self.String1 = "4572 FGO895"
    self.FileIter = 0
  end

  local MainFrame = surface.GetTextureID("glebqip/energy output s/mainframe")
  local Circle = surface.GetTextureID("glebqip/energy output s/rw_circle")

  local GradientL = surface.GetTextureID("gui/gradient")
  local GradientR = surface.GetTextureID("vgui/gradient-r")


  local Red = Color(239,0,0)

  function SCR:Draw(MainColor, SecondColor, ChevBoxesColor)
    local anim = (CurTime()-self.LinesTimer)%3
    local st, en = 0,1--math.Clamp(anim < 3 and anim*2 or 4-anim,0,1)
    if anim <= 1 then st,en = 0,0 end
    if anim > 1 then en = math.min(1,anim-1) end
    if anim > 2 then st = math.min(1,anim-2) end

    surface.SetDrawColor(Color(141,150,110))
    for i=1+math.ceil((#self.Lines2-1)*st),math.ceil((#self.Lines2-1)*en) do
      local x1 = math.floor(89/#self.Lines2*i)
      local x2 = math.floor(89/#self.Lines2*(i+1))
      local y1 = self.Lines2[i] or 0
      local y2 = math.floor(self.Lines2[i+1])
      surface.DrawLine(15+x1,224+y1,15+x2,224+y2)
    end
    surface.SetDrawColor(Color(133,60,38))
    for i=1+math.ceil((#self.Lines3-1)*st),math.ceil((#self.Lines3-1)*en) do
      local x1 = math.floor(89/#self.Lines3*i)
      local x2 = math.floor(89/#self.Lines3*(i+1));
      local y1 = self.Lines3[i] or 0
      local y2 = math.floor(self.Lines3[i+1])
      surface.DrawLine(15+x1,224+y1,15+x2,224+y2)
    end

    local st, en = 0,1--math.Clamp(anim < 3 and anim*2 or 4-anim,0,1)
    if anim > 2 then st = anim-2 end
    if anim < 1 then en = anim end
    surface.SetTexture(GradientL)
    surface.SetDrawColor(Color(75,42,47))
    surface.DrawTexturedRect(134,345,371,29)
    surface.SetTexture(GradientR)
    surface.SetDrawColor(Color(14,26,52))
    surface.DrawTexturedRect(134,345,371,29)

    surface.SetDrawColor(Color(0,0,0))
    if st > 0 then
      surface.DrawRect(134,345,371*st,29)
    else
      surface.DrawRect(134+371*en,345,371-371*en,29)
    end


    surface.SetDrawColor(MainColor)
    surface.SetTexture(MainFrame)
    surface.DrawTexturedRectRotated(256,192,512,512,0)
    surface.SetTexture(Circle)
    surface.SetDrawColor(Color(255,255,255))
    surface.DrawTexturedRectRotated(25,237,16,16,90)
    draw.SimpleText("STARGATE ENERGY OUTPUT", "Marlett_29", 134, 35, Color(138,170,222), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    draw.SimpleText("SGO 463-TR 5029", "Marlett_15", 470, 55, Color(138,170,222), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

    for i=-100,100,10 do
      draw.SimpleText(-i, "Marlett_16", 161, 202+i*1.18, Color(141,150,110), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    if self:GetServerBool("Open") then
      draw.SimpleText("HIGH rad. alert.", "Marlett_15", 13, 50, Color(141,150,110), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
    draw.SimpleText(self.String1, "Marlett_15", 13, 65, Color(141,150,110), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    draw.SimpleText("Start file:"..self.FileIter, "Marlett_15", 13, 80, Color(141,150,110), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    draw.SimpleText("Resonance of", "Marlett_15", 13, 105, Color(141,150,110), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    draw.SimpleText("Stargate:", "Marlett_15", 13, 120, Color(141,150,110), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    if self:GetServerBool("Open") then
      draw.SimpleText("245 Khz", "Marlett_15", 30, 135, Color(141,150,110), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    elseif self:GetServerBool("Active",false) then
      draw.SimpleText("50 Khz", "Marlett_15", 30, 135, Color(141,150,110), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    else
      draw.SimpleText("20 Khz", "Marlett_15", 30, 135, Color(141,150,110), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    draw.SimpleText("AMPLITUDE PEAK", "Marlett_10", 70, 232, Color(141,150,110), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.SimpleText("SGC-68477 345", "Marlett_11", 70, 242, Color(141,150,110), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    draw.SimpleText("Stargate Energy", "Marlett_15", 13, 290, Color(141,150,110), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    draw.SimpleText("Field Output", "Marlett_15", 13, 305, Color(141,150,110), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    draw.SimpleText("locked in", "Marlett_15", 13, 320, Color(141,150,110), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    draw.SimpleText("magnatomic flux", "Marlett_15", 13, 335, Color(141,150,110), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    surface.SetDrawColor(Color(45,150,60))
    if #self.Lines > 0 then
      draw.DrawTLine(183+Lerp(st*17,0,20),202,183+Lerp(en*17,0,20),202,2)
      draw.DrawTLine(475+Lerp((st-(1-1/17))*17,0,20),202,475+Lerp((en-(1-1/17))*17,0,21),202,2)
      --surface.DrawLine(126+310+29*st,193,126+347,193)
      local st, en = 0,1--math.Clamp(anim < 3 and anim*2 or 4-anim,0,1)
      if anim < 1 then en = math.min(anim+anim*40/305-20/305,1) end
      if anim > 2 then
        anim = anim-2
        st = math.max(anim+anim*40/305-20/305,0)
      end
      for i=math.ceil(#self.Lines*st),(#self.Lines)*en do
        local x1 = math.floor(269/#self.Lines*i)
        local x2 = math.floor(269/#self.Lines*(i+1));
        local y1 = self.Lines[i] or 0
        local y2 = math.floor(self.Lines[i+1] or 0) ;oldy = y2
        --draw.DrawTLine(240+x1,263+y1,238+x2,263+y2,2)
        draw.DrawTLine(203+x1,202+y1,203+x2,202+y2,2)
      end
    else
      if st > 0 then
        draw.DrawTLine(183+Lerp(st,0,313),202,497,202,2)
      else
        draw.DrawTLine(183,202,183+Lerp(en,0,313),202,2)
      end
    end
  end

  function SCR:Think(curr)
    if not curr then return end

    local active = self:GetServerBool("Connected",false) and self:GetServerBool("Active",false)
    local double = not self:GetServerBool("Local",false)
    local open = self:GetServerBool("Open",false)
    if active ~= self.Active then
      self.Active = active
    end
    if CurTime()-self.LinesTimer > 3 then
      if self.Active then
        self:EmitSound("glebqip/energy_big.wav",65,100,0.55)
        local power = (open and 1 or 0.7) + (double and 0.25 or 0)
        local max = math.Rand(0.05,1)
        for i=1,50 do
          if math.random() > 0.7 then
            max = math.Rand(0.05,1)
          end
          local maxval = max*power*98*(i%2 == 0 and -1 or 1)
          self.Lines[i] = math.Rand(maxval/4,maxval)
        end
      elseif not self.Active and #self.Lines > 0 then
        self.Lines = {}
        self.Lines2 = {}
        self.Lines3 = {}
      end
      for i=1,20 do
        local maxval = 28
        self.Lines2[i] = -math.Rand(2,maxval)
        self.Lines3[i] = -math.Rand(5,maxval-5)
      end
      self.FileIter = self.FileIter + 1
      if self.FileIter > 1000 then self.FileIter = 1 end

      if math.random() > 0.6 then
        self.String1 = ""
        for i=1,4 do
          self.String1 = self.String1..math.random(0,9)
        end
        self.String1 = self.String1.." FGO"
        for i=1,3 do
          self.String1 = self.String1..math.random(0,9)
        end
      end
      self.LinesTimer = CurTime()
    end
  end
end

return SCR
