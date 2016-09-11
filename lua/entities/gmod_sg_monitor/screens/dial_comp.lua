---------------------
-- Screen: Dial --
-- Author: glebqip --
-- ID: 1 --
---------------------
local SCR = {}
if SERVER then
else
  local MainFrame = surface.GetTextureID("glebqip/dial screen 1/MainFrame")
  local Boxes = surface.GetTextureID("glebqip/dial screen 1/Boxes")
  local Ring = surface.GetTextureID("glebqip/dial screen 1/Ring")
  local RingArcs = surface.GetTextureID("glebqip/dial screen 1/RingArcs")
  local Chevron = surface.GetTextureID("glebqip/dial screen 1/Chevron")
  local Chevron7 = surface.GetTextureID("glebqip/dial screen 1/Chevron7")
  local ChevronBox = surface.GetTextureID("glebqip/dial screen 1/ChevronBox")
  local Gradient = surface.GetTextureID("vgui/gradient_down")
  local Red = Color(239,0,0)

  function SCR:Initialize()
    -- Blinking boxes
    self.Boxes1 = {}
    self.Boxes2 = {}
    self.Boxes1Timer = CurTime()
    self.Boxes2Timer = CurTime()

    --Gradient anim boxes
    self.GradientsTimers = {}
    self.GradientSpeeds = {}

    --Random digits
    self.Digits = {}
    self.DigitsTimer = CurTime()
    --Chevron open animation
    self.OpenCTimer = CurTime()-1
    --Dial symbol animation
    self.SymbolAnim = nil
    self.SymbolAnim2 = nil
    --End timer
    self.EndTimer = nil
    for i=1,9 do
      self.GradientSpeeds[i] = math.Rand(0.4,0.8)
      self.GradientsTimers[i] = CurTime()-self.GradientSpeeds[i]/math.random()
    end

    self.DialingAddress = ""
    self.OldDialingAddress = ""

    self.Matrix = Matrix()
    self.Dialed = false
    self.Locked = false
    self.LastDialSymb = ""
    self.ErrorTimer = nil

    self.Timer8 = nil
  end

  function SCR:Draw(MainColor, SecondColor, ChevBoxesColor)
    local Alpha = math.abs(math.sin(CurTime()*math.pi/2))
    local NLocal = not self:GetServerBool("Local",false)

    surface.SetDrawColor(MainColor)
    surface.SetTexture(MainFrame)
    surface.DrawTexturedRectRotated(256,192,512,512,0)

    surface.SetTexture(Gradient)
    for i=0,8 do
      local state = (CurTime() - self.GradientsTimers[i+1])/self.GradientSpeeds[i+1]
      if state < 1 then
        local size = math.min(1,state*1.4)*47
        local alpha = 1-math.max(0,state*1.4-1)*2.5
        surface.SetDrawColor(MainColor.r,MainColor.g,MainColor.b,alpha*255)
        surface.DrawTexturedRect(10 + i*17,299 + (47-size),14,size)
      end
    end
    surface.SetAlphaMultiplier(1)

    surface.SetDrawColor(SecondColor)
    surface.SetTexture(RingArcs)
    surface.DrawTexturedRectRotated(257,166,256,256,0)
    surface.SetTexture(Ring)
    surface.DrawTexturedRectRotated(257,166,256,256,self:GetServerInt("RingAngle",0)-4.615)

    for i=1,36 do
      if self.Boxes2[i] then
        local x,y = 0,0
        if i > 18 then x = 34 end
        if i > 9 and i < 18 or i > 27 then y = 32 end
        if self.Boxes2[i] then
          surface.DrawRect(24+i%3*6+x,229+math.ceil(i/3-1)%3*6+y,4,4)
        end
      end
    end

    surface.SetDrawColor(MainColor)
    for i=0,12 do
      if self.Digits[13-i] then
        draw.SimpleText(self.Digits[13-i], "Marlett_15", 87, 45+i*13, MainColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
      end
    end

    surface.SetDrawColor(color_white)
    for i=1,24 do
      if self.Boxes1[i] then
        surface.DrawRect(171+i%8*8,298+math.ceil(i/8-1)*16,6,15)
      end
    end

    surface.SetDrawColor(MainColor)
    surface.SetTexture(Boxes)
    surface.DrawTexturedRectRotated(202,322,128,64,0)

    local ChevronState = math.Clamp((CurTime()-self.OpenCTimer)*4,0,1)
    if self.Error then
      ChevronState = math.max(1-ChevronState,0.6-(CurTime()-self.ErrorStart))
    end
    if not self:GetServerBool("Open") then ChevronState = 1-ChevronState end
    for i=1,9 do
      local ang = 180-(360/9)*i
      local rad = math.rad(ang)
      local X,Y = math.sin(rad)*(113-ChevronState*6), math.cos(rad)*(113-ChevronState*6)
      local X2,Y2 = math.sin(rad)*(122+ChevronState*6), math.cos(rad)*(122+ChevronState*6)
      local active = self:GetServerString("Chevrons","")[i == 9 and 7 or i>5 and i-2 or i > 3 and i+4 or i] == "1" or self.Error
      surface.SetDrawColor(active and Red or SecondColor)
      if i < 9 then
        surface.SetTexture(Chevron)
        surface.DrawTexturedRectRotated(257+X,166+Y,32,32,ang+180)
      else
        surface.SetTexture(Chevron7)
        surface.DrawTexturedRectRotated(257+X,166+Y,32,32,0)
      end
      surface.SetDrawColor(active and Red or ChevBoxesColor)
      surface.SetTexture(ChevronBox)
      surface.DrawTexturedRectRotated(257+X2,166+Y2,16,16,ang+180)
    end
    surface.SetDrawColor(MainColor)
    if NLocal then
      local tm8 = self.Timer8 and math.min(1,CurTime()-self.Timer8)*3
      if not tm8 or tm8 < 1 then
        for i=1,7 do
          local state = (CurTime() - self.GradientsTimers[i+1])/self.GradientSpeeds[i+1]
          if state < 1 then
            local size = math.min(1,state*1.4)*40
            local alpha = 1-math.max(0,state*1.4-1)*2.5
            surface.SetDrawColor(MainColor.r,MainColor.g,MainColor.b,alpha*255)
            surface.DrawTexturedRect(437 + i*8-4,309 + (40-size),14,size)
          end
        end
        if tm8 then
          surface.SetDrawColor(color_black)
          surface.DrawRect(440, 35+7*39+40, 64, -40*tm8)
        end
      end
      surface.SetDrawColor(MainColor)
      for i=0,7 do
        draw.OutlinedBox(440, 35+i*39, 64, 40, 2)
      end
    else
      for i=0,6 do
        draw.OutlinedBox(440, 37+i*43, 64, 40, 2)
      end
    end
    --local DialingAddress = "123456#"
    if not self:GetServerBool("Inbound",false) then
      local color = color_white
      if self.Error then
        local anim = math.max(0,0.6-(CurTime()-self.ErrorStart))
        color = Color(Red.r+255-Red.r,255*anim,255*anim)
      end
      for i=0,#self.DialingAddress do
        if NLocal then
          draw.SimpleText(self.DialingAddress[i+1], "SGC_SG1", 472,56+i*39, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        else
          draw.SimpleText(self.DialingAddress[i+1], "SGC_SG1", 472,58+i*43, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
      end
    end

    if self.EndTimer then
      local anim = math.abs(math.sin((CurTime()-self.EndTimer)%0.4/0.4*math.pi))*240---EndTimer
      for i=0,#self.DialingAddress-1 do
        surface.SetDrawColor(Color(12,96,104,math.min(255,anim)))
        if NLocal then
          surface.DrawRect(439,35+i*39,65,41)
        else
          surface.DrawRect(439,37+i*43,65,41)
        end
      end
    end
    surface.SetAlphaMultiplier(1)

    for i=1,#self.DialingAddress + (self.Timer8 and #self.DialingAddress < 8 and 1 or 0) do
      if NLocal then
        local tm8 = self.Timer8 and math.min(1,CurTime()-self.Timer8)*3
        draw.SimpleText(i, "Marlett_29", 436,15+i*39, i == 8 and tm8 and Red or SecondColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        if i == 8 and tm8 and tm8 < 1 then
          surface.SetDrawColor(color_black)
          surface.DrawRect(420, 4+8*39, 20, 20-20*tm8)
        end
      else
        draw.SimpleText(i, "Marlett_25", 436,33+i*43, SecondColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
      end
    end

    surface.SetDrawColor(color_white)
    --local OpenChev = CurTime()%2
    if self.SymbolAnim or self.SymbolAnim2 or self.Error then
      local x,y,scale = 0,0,0
      local symbol = ""
      local alpha = 0
      local Sm2 = self.SymbolAnim2 and (CurTime()-self.SymbolAnim2) < 0.6
      local color = color_white
      local xb,yb,wb,hb
      if Sm2 then
        local anim = math.min(1,(CurTime()-self.SymbolAnim2)*1.66)
        if NLocal then
          x,y = 258 + anim*214,167 - anim*150 + anim*39*(#self.DialingAddress+1)
        else
          x,y = 258 + anim*214,165 - anim*150 + anim*43*(#self.DialingAddress+1)
        end
        scale = 2.4-(anim*2.4)/90*76
        symbol = self:GetServerString("RingSymbol","")
        local xanim = 1-anim*0.8
        local yanim = 1-anim*0.842
        alpha = math.max(0,xanim)
        xb,yb = -325/2*xanim + (1-xanim)*1 + x, -256/2*yanim + y
        wb,hb = 325*xanim,257*yanim
      elseif self.SymbolAnim then
        local anim = math.min(1,(CurTime()-self.SymbolAnim)*1.5)
        x,y = 258,59+anim*106
        scale = anim*2.4
        symbol = self:GetServerString("DialingSymbol","")
        alpha = anim
        xb,yb,wb,hb = -325/2*anim+x,-257/2*anim+y+1,325*anim,257*anim
      end
      if self.Error then
        x,y = 258,59+106
        scale = 2.4
        symbol = self.LastDialSymb
        color = Red or Color(165,72,45)
        alpha = 1
        local timer = CurTime() - self.ErrorTimer
        if timer > 0 and timer < 4 then
          surface.SetDrawColor(color_black)
          surface.DrawRect(x-100,y+75,200,50,2)
          surface.SetDrawColor(color)
          draw.OutlinedBox(x-100,y+75,200,50,2)
          if self.Error == 1 then
            draw.SimpleText("DIAL ERROR", "Marlett_Err", x,y+85, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText("LINE 352", "Marlett_Err", x,y+85+15, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText("\"NOT FOUND\"", "Marlett_Err", x,y+85+30, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
          elseif self.Error == 2 then
            draw.SimpleText("DIAL ERROR", "Marlett_Err", x,y+85, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText("LINE 352", "Marlett_Err", x,y+85+15, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText("\"OCCUPIED\"", "Marlett_Err", x,y+85+30, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
          end
        elseif timer < 0 then
          local anim = math.max(0,-timer*1.66)
          local animC = math.max(0,0.6-(CurTime()-self.ErrorStart))
          color = Color(Red.r+255-Red.r,255*anim,255*anim)
          if NLocal then
            x,y = 258 + anim*214,167 - anim*150 + anim*39*(#self.DialingAddress+1)
          else
            x,y = 258 + anim*214,165 - anim*150 + anim*43*(#self.DialingAddress+1)
          end
          scale = 2.4-(anim*2.4)/90*76
          local xanim = 1-anim*0.8
          alpha = math.max(0,xanim)
        end
        if timer > 4 then
          self.ErrorTimer = false
          self.Error = false
        end
      end
      self.Matrix = Matrix()
      self.Matrix:Translate(Vector(x,y,0))
      self.Matrix:Scale(Vector(scale,scale,scale))
      self.Matrix:Translate(Vector(0,0,0))
      --surface.SetAlphaMultiplier(alpha)
      surface.SetDrawColor(Color(255,255,255,alpha*255))
      if xb then draw.OutlinedBox(xb,yb,wb,hb,2) end
      --surface.SetAlphaMultiplier(1)
      cam.PushModelMatrix(self.Matrix)
      draw.SimpleText(symbol, "SGC_Symb", 0,0, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
      cam.PopModelMatrix()
    end

    surface.SetDrawColor(MainColor)
    surface.SetAlphaMultiplier(Alpha)
    --local MainColorA = Color(MainColor.r,MainColor.g,MainColor.b,Alpha)
    if self.Error then
      surface.SetDrawColor(Red)
      surface.DrawRect(246,296,172,7)
      draw.SimpleText("ERROR", "Marlett_Error", 330,317+5, Red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
      surface.DrawRect(246,340,172,7)
    elseif self:GetServerBool("Inbound",false) then
      surface.SetDrawColor(Red)
      surface.DrawRect(97,39,38,38)
      surface.DrawRect(97,254,38,38)
      surface.DrawRect(380,39,38,38)
      surface.DrawRect(380,254,38,38)
      --surface.drawText(328,310,"OFFWORLD",1,1, red,font("Marlett",27))
      --surface.drawText(328,332,"ACTIVATION",1,1, red,font("Marlett",29))
      draw.SimpleText("OFFWORLD", "Marlett_27", 328,310, Red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
      draw.SimpleText("ACTIVATION", "Marlett_29", 328,332, Red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    elseif self:GetServerBool("Open",false) then
      surface.SetDrawColor(Red)
      surface.DrawRect(246,296,168,9)
      draw.SimpleText("LOCKED", "Marlett_Open", 330,317+5, Red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
      surface.DrawRect(246,338,168,9)
    elseif self:GetServerBool("ChevronLocked",false) then
      draw.SimpleText("SEQUENCE", "Marlett_22", 328,311, MainColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
      draw.SimpleText("COMPLETE", "Marlett_27", 328,331, MainColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    elseif self:GetServerBool("Active",false) then
      draw.SimpleText("SEQUENCE", "Marlett_25", 328,311, MainColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
      draw.SimpleText("IN PROGRESS", "Marlett_25", 328,331, MainColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    else
      draw.SimpleText("IDLE", "Marlett_22", 238,297, MainColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end
  end

  function SCR:Think(curr)
    local connected = self:GetServerBool("Connected",false)
    local active = self:GetServerBool("Active",false)
    local open = self:GetServerBool("Open",false)
    local inbound = self:GetServerBool("Inbound",false)
    local chevron = self:GetServerInt("Chevron",0)
    local locked = self:GetServerBool("ChevronLocked",false)
    if not curr then return end
    if self.Open ~= open then
      self.OpenCTimer = CurTime()
      self.Open = open
    end
    if CurTime()-self.Boxes1Timer > 0.5 and connected then
      for i=1,24 do
        self.Boxes1[i] = math.random()>0.6
      end
      self.Boxes1Timer = CurTime()
    end
    if CurTime()-self.Boxes2Timer > 0.15 and connected then
      for i=1,36 do
        self.Boxes2[i] = math.random()>0.4
      end
      self.Boxes2Timer = CurTime()
    end
    if CurTime()-self.DigitsTimer > 0.15 then
      if connected and active and math.random()>0.2 then
        local str = ""
        local typ = math.random()>0.3
        for _=math.random(2,4),math.random(6,11) do
          if typ then
            str = str..tostring(math.random(0,9))
          else
            str = str..tostring(math.random(0,1))
          end
        end
        table.insert(self.Digits,1,str)
      else
        table.insert(self.Digits,1,"")
      end
      table.remove(self.Digits,14)
      self.DigitsTimer = CurTime()
    end

    for i=1,9 do
      if CurTime() - self.GradientsTimers[i] > self.GradientSpeeds[i] and active and (inbound or open or self:GetServerBool("RingRotation",false)) then
        self.GradientSpeeds[i] = math.Rand(0.4,0.8)
        self.GradientsTimers[i] = CurTime()
      end
    end

    local dialadd = self:GetServerString("DialingAddress","")
    local dialsymb = self:GetServerString("DialingSymbol","")
    local dialdsymb = self:GetServerString("DialedSymbol","")
    local ringsymb = self:GetServerString("RingSymbol","")
    local ringrot = self:GetServerBool("RingRotation",false)

    local LastChev = chevron > 7 or dialsymb == "#" or dialdsymb == "#" or chevron > 6 and dialsymb == "" and dialdsymb == ""
    --Dial error check
    if not inbound and not open and (active or chevron > 0) and LastChev then
      self.Dialed = true
      if locked then
        self.Locked = true
      end
      if dialsymb ~= "" then
        self.LastDialSymb = dialsymb
      end
    elseif (self.Dialed or self.Locked) then
      print(not open , not inbound , chevron <= 0 , #self.DialingAddress >= 6)
      if not open and not inbound and chevron <= 0 and #self.DialingAddress >= 6 then -- we fail dial
        self.Error = self.Locked and 2 or 1
        self.ErrorTimer = CurTime()
        self.ErrorStart = self.ErrorTimer

        if #self.DialingAddress == 9 or self.DialingAddress[#self.DialingAddress] == "#" then
          self.LastDialSymb = self.DialingAddress:sub(-1,-1)
          print(self.LastChev)
          self.DialingAddress = self.DialingAddress:sub(1,-2)
          self.ErrorTimer = CurTime()+0.6
          self:EmitSound("alexalx/glebqip/dp_locked.wav")
        end
      end
      self.Dialed = false
      self.Locked = false
    end

    local LastSecond = not open and LastChev and locked
    if active and (dialsymb == dialdsymb and not LastChev or LastSecond) and self.SymbolAnim and not self.SymbolAnim2 then
      self.SymbolAnim2 = CurTime()
      self.SymbolAnim = nil
      self:EmitSound("alexalx/glebqip/dp_locked.wav")
    elseif active and not open and dialsymb ~= "" and dialsymb == ringsymb and (not ringrot or LastChev) and not self.SymbolAnim and not self.SymbolAnim2 then
      self.SymbolAnim = CurTime()
      self:EmitSound("alexalx/glebqip/dp_locking.wav")
    elseif (not active or open or inbound or ringrot and (not LastChev or dialsymb ~= ringsymb)) and (self.SymbolAnim or self.SymbolAnim2) then
      self.SymbolAnim2 = nil
      self.SymbolAnim = nil
    end
    if (not self.SymbolAnim and not self.SymbolAnim2 or self.SymbolAnim2 and (CurTime()-self.SymbolAnim2) > 0.6) and not self.Error then
      local smadd = (dialsymb ~= "" and dialsymb or dialdsymb ~= "" and dialdsymb or self.LastDialSymb)
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
    if self.OldDialingAddress ~= self.DialingAddress then
      if #self.OldDialingAddress < #self.DialingAddress then
        self:EmitSound("alexalx/glebqip/dp_encoded.wav")
      end
      self.OldDialingAddress = self.DialingAddress
    end
    local endT = self.EndTimer and (CurTime()-self.EndTimer)%0.4 > 0.2
    if self.OldLocked ~= endT then
      if endT then self:EmitSound("alexalx/glebqip/dp_lock.wav") end
      self.OldLocked = endT
    end
    if self.EndTimer ~= nil and (open or not active) then
      self.EndTimer = nil
    elseif self.EndTimer and CurTime()-self.EndTimer > 1.2 then
      self.EndTimer = false
    end

    --SG1 The fifth race series 8 chevron anim
    if not self:GetServerBool("Local",false) and not inbound and (#dialadd == 7 and not LastChev or #dialadd > 7) and not self.Timer8 then
      self.Timer8 = CurTime()
    end
    if (self:GetServerBool("Local",false) or #self.DialingAddress < 7 or inbound) and self.Timer8 then
      self.Timer8 = false
    end
    print(self.Entity)  
  end
end
return 1,SCR
