---------------------
-- Screen: IDC s1 --
-- Author: glebqip --
-- ID: 2 --
---------------------

local SCR = {
  Name = "Energy output (film)",
  ID = 6,
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
    self.Digits = {}
    self.DigitsTimer = CurTime()-10

    self.Lines = {}
    self.LinesTimer = CurTime()-3
    self.Active = false
  end

  local MainFrame = surface.GetTextureID("glebqip/energy output f/mainframe")

  local Gradient = surface.GetTextureID("vgui/gradient_down")

  local Red = Color(239,0,0)

  function SCR:Draw(MainColor, SecondColor, ChevBoxesColor)
    local py = (CurTime()-self.DigitsTimer)%0.2*5-1
    for i=1,#self.Digits do
      if self.Digits[i] then
        draw.SimpleText(self.Digits[i], "Marlett_12", 97, 43+(i-1)*13+py*13, MainColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
      end
    end
    surface.SetDrawColor(MainColor)
    surface.SetTexture(MainFrame)
    surface.DrawTexturedRectRotated(256,192,512,512,0)

    local anim = (CurTime()-self.LinesTimer)%3
    local st, en = 0,1--math.Clamp(anim < 3 and anim*2 or 4-anim,0,1)
    if anim > 2 then st = anim-2 end
    if anim < 1 then en = anim end
    surface.SetDrawColor(Color(45,150,60))
    if #self.Lines > 0 then
      draw.DrawTLine(126+Lerp(st*17,0,20),193,126+Lerp(en*17,0,20),193,2)
      draw.DrawTLine(452+Lerp((st-(1-1/17))*17,0,20),193,452+Lerp((en-(1-1/17))*17,0,21),193,2)
      --surface.DrawLine(126+310+29*st,193,126+347,193)
      local st, en = 0,1--math.Clamp(anim < 3 and anim*2 or 4-anim,0,1)
      if anim < 1 then en = math.min(anim+anim*40/305-20/305,1) end
      if anim > 2 then
        anim = anim-2
        st = math.max(anim+anim*40/305-20/305,0)
      end
      for i=math.ceil(#self.Lines*st),(#self.Lines)*en do
        local x1 = math.floor(301/#self.Lines*i)
        local x2 = math.floor(301/#self.Lines*(i+1));
        local y1 = self.Lines[i] or 0
        local y2 = math.floor(self.Lines[i+1] or 0) ;oldy = y2
        --draw.DrawTLine(240+x1,263+y1,238+x2,263+y2,2)
        draw.DrawTLine(146+x1,193+y1,146+x2,193+y2,2)
      end
    else
      draw.DrawTLine(126+Lerp(st,0,347),193,126+Lerp(en,0,347),193,2)
    end
  end

  function SCR:Think(curr)
    if not curr then return end
    if CurTime()-self.DigitsTimer > 0.2 then
      str = ""
      if self:GetServerBool("Connected",false) then
        if math.random() > 0.4 then
          for _=1,15 do
            str = str..tostring(math.random(0,9))
          end
        end
        table.insert(self.Digits,1,str)
      else
        table.insert(self.Digits,1,"")
      end
      table.remove(self.Digits,26)
      self.DigitsTimer = CurTime()
    end

    local active = self:GetServerBool("Connected",false) and self:GetServerBool("Active",false)
    local double = not self:GetServerBool("Local",false)
    local open = self:GetServerBool("Open",false)
    if active ~= self.Active then
      self.Active = active
    end
    if CurTime()-self.LinesTimer > 3 then
      if self.Active then
        local power = (open and 120 or 80) + (double and 25 or 0)
        local max = math.Rand(0.2,1)
        for i=1,50 do
          if math.random() > 0.7 then
            max = math.Rand(0.05,1)
          end
          local maxval = max*power*(i%2 == 0 and -1 or 1)
          self.Lines[i] = math.Rand(maxval/2,maxval)
        end
      elseif not self.Active and #self.Lines > 0 then
        self.Lines = {}
      end
      self.LinesTimer = CurTime()
    end
  end
end

return SCR
