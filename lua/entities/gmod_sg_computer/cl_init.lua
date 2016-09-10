include("shared.lua")
include("cl_gpudraw_lite.lua")

surface.CreateFont("SGC_SG1", {
	font = "Stargate Address Glyphs Concept",
	size = 35,
	weight = 400,
	antialias = true,
	additive = false,
})
surface.CreateFont("SGC_Symb", {
	font = "Stargate Address Glyphs Concept",
	size = 90,
	weight = 400,
	antialias = true,
	additive = false,
})
surface.CreateFont("Marlett_15", {
	font="Marlett",
	size=15,
	weight=800,
	antialias= true,
	additive = false,
})
surface.CreateFont("Marlett_22", {
	font="Marlett",
	size=22,
	weight=800,
	antialias= true,
	additive = false,
})
surface.CreateFont("Marlett_25", {
	font="Marlett",
	size=25,
	weight=800,
	antialias= true,
	additive = false,
})
surface.CreateFont("Marlett_27", {
	font="Marlett",
	size=27,
	weight=800,
	antialias= true,
	additive = false,
})
surface.CreateFont("Marlett_29", {
	font="Marlett",
	size=29,
	weight=800,
	antialias= true,
	additive = false,
})

if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
	ENT.Category = SGLanguage.GetMessage("entity_main_cat")
	ENT.PrintName = SGLanguage.GetMessage("sgc_computer")
end


function ENT:Initialize()
	self:ScreenInit(512,384,Vector(11.75,-512/2*0.04,384/2*0.04+3.9),Angle(0,90,85.5),0.04)
  --Colors:Movie
	self.MainColor = Color(42,125,225)
	self.ChevBoxesColor = self.MainColor
	self.SecondColor = Color(229,238,179)
  --Colors:First series
	self.MainColor = Color(40,167,240)
	self.ChevBoxesColor = self.MainColor
	self.SecondColor = Color(200,200,200)
  --Colors:
  --self.MainColor = Color(30,180,200)
  --self.ChevBoxesColor = self.MainColor
  --self.SecondColor = Color(200,200,182)
  --self.SecondColor = Color(208,208,144)

	--Dial screen
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
end

local MainFrame = surface.GetTextureID("glebqip/dial screen 1/MainFrame")
local Boxes = surface.GetTextureID("glebqip/dial screen 1/Boxes")

local Ring = surface.GetTextureID("glebqip/dial screen 1/Ring")
local RingArcs = surface.GetTextureID("glebqip/dial screen 1/RingArcs")

local Chevron = surface.GetTextureID("glebqip/dial screen 1/Chevron")
local Chevron7 = surface.GetTextureID("glebqip/dial screen 1/Chevron7")
local ChevronBox = surface.GetTextureID("glebqip/dial screen 1/ChevronBox")

local Gradient = surface.GetTextureID("gui/gradient_down")
local Red = Color(239,0,0)
function ENT:Draw()
	self:DrawModel()
	self:DrawScreen(0,-10,512,410,0.96)
	return true
end

--hi garrysmod.com, i am so lazy
function draw.OutlinedBox( x, y, w, h, thickness)
	for i=0, thickness - 1 do
		surface.DrawOutlinedRect( x + i, y + i, w - i * 2, h - i * 2 )
	end
end

function ENT:Screen()
	local Alpha = math.abs(math.sin(CurTime()*math.pi/2))

	surface.SetDrawColor(self.MainColor)
	surface.SetTexture(MainFrame)
	surface.DrawTexturedRectRotated(256,192,512,512,0)

	surface.SetTexture(Gradient)
  for i=0,8 do
      local state = (CurTime() - self.GradientsTimers[i+1])/self.GradientSpeeds[i+1]
      if state < 1 then
          local size = math.min(1,state*1.4)*47
          local alpha = 1-math.max(0,state*1.4-1)*2.5
					surface.SetDrawColor(self.MainColor.r,self.MainColor.g,self.MainColor.b,alpha*255)
          surface.DrawTexturedRect(10 + i*17,299 + (47-size),14,size)
      end
  end
	surface.SetAlphaMultiplier(1)

	surface.SetDrawColor(self.SecondColor)
	surface.SetTexture(RingArcs)
  surface.DrawTexturedRectRotated(257,166,256,256,0)
	surface.SetTexture(Ring)
  surface.DrawTexturedRectRotated(257,166,256,256,self:GetNW2Int("RingAngle",0)-4.615)

  for i=1,36 do
      if self.Boxes2[i] then
          local x,y = 0,0
          if i > 18 then
              x = 34
          end
          if i > 9 and i < 18 or i > 27 then
              y = 32
          end
          if self.Boxes2[i] then
              surface.DrawRect(24+i%3*6+x,229+math.ceil(i/3-1)%3*6+y,4,4)
          end
      end
  end

	surface.SetDrawColor(self.MainColor)
  for i=0,12 do
      if self.Digits[13-i] then
					draw.SimpleText(self.Digits[13-i], "Marlett_15", 87, 45+i*13, self.MainColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
					--[[
					surface.SetFont( "Marlett_15" )
					surface.SetTextPos()
					surface.GetTextSize( string text )
          surface.DrawText(Digits[13-i],2,1,font("Marlett",15))
					]]
      end
  end
	surface.SetDrawColor(color_white)
  for i=1,24 do
      if self.Boxes1[i] then
          surface.DrawRect(171+i%8*8,298+math.ceil(i/8-1)*16,6,15)
      end
  end
	surface.SetDrawColor(self.MainColor)
	surface.SetTexture(Boxes)
  surface.DrawTexturedRectRotated(202,322,128,64,0)

  local ChevronState = math.Clamp((CurTime()-self.OpenCTimer)*4,0,1)
  if not self:GetNW2Bool("Open") then ChevronState = 1-ChevronState end
  for i=1,9  do
      local ang = 180-(360/9)*i
      local rad = math.rad(ang)
      local X,Y = math.sin(rad)*(113-ChevronState*6), math.cos(rad)*(113-ChevronState*6)
      local X2,Y2 = math.sin(rad)*(122+ChevronState*6), math.cos(rad)*(122+ChevronState*6)
      local active = self:GetNW2String("Chevrons")[i == 9 and 7 or i>5 and i-2 or i > 3 and i+4 or i] == "1"
			surface.SetDrawColor(active and Red or self.SecondColor)
      if i < 9 then
					surface.SetTexture(Chevron)
          surface.DrawTexturedRectRotated(257+X,166+Y,32,32,ang+180)
      else
					surface.SetTexture(Chevron7)
          surface.DrawTexturedRectRotated(257+X,166+Y,32,32,0)
      end
			surface.SetDrawColor(active and Red or self.ChevBoxesColor)
			surface.SetTexture(ChevronBox)
      surface.DrawTexturedRectRotated(257+X2,166+Y2,16,16,ang+180)
  end
	surface.SetDrawColor(self.MainColor)
  for i=0,6 do
			draw.OutlinedBox(440, 37+i*43, 64, 40, 2)
  end
	--local DialingAddress = "123456#"
  for i=0,#self.DialingAddress do
			draw.SimpleText(self.DialingAddress[i+1], "SGC_SG1", 472,58+i*43, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
  end

	surface.SetDrawColor(Color(12,96,104))
  if self.EndTimer then
      local anim = math.abs(math.sin((CurTime()-self.EndTimer)%0.4/0.4*math.pi))*150---EndTimer
      for i=0,6 do
					surface.SetAlphaMultiplier(anim/150)
          surface.DrawRect(439,37+i*43,65,41)
      end
  end
	surface.SetAlphaMultiplier(1)

  for i=1,#self.DialingAddress do
			draw.SimpleText(i, "Marlett_25", 436,33+i*43, self.SecondColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
  end

	surface.SetDrawColor(color_white)
  --local OpenChev = CurTime()%2
	if self.SymbolAnim or self.SymbolAnim2 then
		local x,y,scale = 0,0,0
		local symbol = ""
		local alpha = 0
	  local Sm2 = self.SymbolAnim2 and (CurTime()-self.SymbolAnim2) < 0.6
	  if Sm2 then
	      local anim = math.min(1,(CurTime()-self.SymbolAnim2)*1.66)
	      x,y = 256+anim*216+1,165-anim*150+anim*43*(#self.DialingAddress+1)
				scale = 3-(anim*3)/90*78
				symbol = self:GetNW2String("RingSymbol","")
	      local xanim = 1-anim*0.801
	      local yanim = 1-anim*0.842
				alpha = math.max(0,xanim)
				xb,yb,wb,hb = -326/2*xanim+x,-256/2*yanim+y,326*xanim,257*yanim
	      --surface.drawRectOL(,Color(255,255,255,math.max(0,ianim)*255),1)
	      --surface.pushRotatedMatrix(x,y,0,3-(anim*3)/90*78)
	          --surface.drawText(0,0,SG.RingSymbol,1,1,Color(255,255,255,255),font("Stargate Address Glyphs Concept",90))
	      --surface.popMatrix()
	  elseif self.SymbolAnim then
	      local anim = math.min(1,(CurTime()-self.SymbolAnim)*1.5)
	      x,y = 256,59+anim*106
				scale = anim*3
				symbol = self:GetNW2String("DialingSymbol","")
				alpha = anim
				xb,yb,wb,hb = -325/2*anim+x+2,-257/2*anim+y+1,325*anim,257*anim
	      --surface.drawRectOL(-325/2*anim+x,-257/2*anim+y,325*anim,257*anim,Color(255,255,255,anim*255),1)
	      --surface.pushRotatedMatrix(x,y,0,anim*3)
	        --  surface.drawText(0,0,self:GetNW2String("DialingSymbol",""),1,1,color_white,font("Stargate Address Glyphs Concept",90))
	      --surface.popMatrix()
	  end
	  self.Matrix = Matrix()
	  self.Matrix:Translate(Vector(x,y,0))
	  	self.Matrix:Scale(Vector(scale,scale,scale))
	  self.Matrix:Translate(-Vector(0,0,0))
		--surface.SetAlphaMultiplier(alpha)
			surface.SetDrawColor(Color(255,255,255,alpha*255))
			draw.OutlinedBox(xb,yb,wb,hb,2)
		--surface.SetAlphaMultiplier(1)
	  cam.PushModelMatrix(self.Matrix)

			draw.SimpleText(symbol, "SGC_Symb", 0,0, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		cam.PopModelMatrix()
	end

	surface.SetDrawColor(self.MainColor)
	surface.SetAlphaMultiplier(Alpha)
  --local MainColorA = Color(MainColor.r,MainColor.g,MainColor.b,Alpha)
  if self:GetNW2Bool("Inbound",false) then
			surface.SetDrawColor(Red)
      surface.DrawRect(97,39,38,38)
      surface.DrawRect(97,254,38,38)
      surface.DrawRect(380,39,38,38)
      surface.DrawRect(380,254,38,38)
      --surface.drawText(328,310,"OFFWORLD",1,1, red,font("Marlett",27))
      --surface.drawText(328,332,"ACTIVATION",1,1, red,font("Marlett",29))
			draw.SimpleText("OFFWORLD", "Marlett_27", 328,310, Red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText("ACTIVATION", "Marlett_29", 328,332, Red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
  elseif self:GetNW2Bool("Open",false) then
  elseif self:GetNW2Bool("ChevronLocked",false) then
			draw.SimpleText("SEQUENCE", "Marlett_22", 328,311, self.MainColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText("COMPLETE", "Marlett_27", 328,331, self.MainColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
  elseif self:GetNW2Bool("Active",false) then
			draw.SimpleText("SEQUENCE", "Marlett_25", 328,311, self.MainColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText("IN PROGRESS", "Marlett_25", 328,331, self.MainColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
  else
			draw.SimpleText("IDLE", "Marlett_22", 238,297, self.MainColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
  end
	surface.SetAlphaMultiplier(1)
end

function ENT:Think()
	local active = self:GetNW2Bool("Active",false)
	local open = self:GetNW2Bool("Open",false)
	local inbound = self:GetNW2Bool("Inbound",false)
	local connected = self:GetNW2Bool("Connected",false)
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
	if CurTime()-self.Boxes2Timer > 0.25 and connected then
	    for i=1,36 do
	        self.Boxes2[i] = math.random()>0.4
	    end
	    self.Boxes2Timer = CurTime()
	end
	if CurTime()-self.DigitsTimer > 0.15 then
	    if connected and active and math.random()>0.2 then
	        local str = ""
	        local typ = math.random()>0.3
	        for i=math.random(2,4),math.random(6,11) do
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
	    if CurTime() - self.GradientsTimers[i] > self.GradientSpeeds[i] and active and (inbound or self:GetNW2Bool("RingRotation",false)) then
	        self.GradientSpeeds[i] = math.Rand(0.4,0.8)
	        self.GradientsTimers[i] = CurTime()
	    end
	end

	local dialadd = self:GetNW2String("DialingAddress","")
	local dialsymb = self:GetNW2String("DialingSymbol","")
	local dialdsymb = self:GetNW2String("DialedSymbol","")
	local ringsymb = self:GetNW2String("RingSymbol","")
	local ringrot = self:GetNW2Bool("RingRotation",false)

	local LastChev = self:GetNW2Int("Chevron",0) > 7 or dialsymb == "#" or dialdsymb == "#"
	local LastSecond = not open and LastChev and self:GetNW2Bool("ChevronLocked",false)
	if active and (dialsymb == dialdsymb and not LastChev or LastSecond) and self.SymbolAnim and not self.SymbolAnim2 then
	    self.SymbolAnim2 = CurTime()
	    self.SymbolAnim = nil
	elseif active and not open and dialsymb ~= "" and dialsymb == ringsymb and (not ringrot or LastChev) and not self.SymbolAnim and not self.SymbolAnim2 then
	    self.SymbolAnim = CurTime()
	elseif (not active or open or inbound or ringrot and (not LastChev or dialsymb ~= ringsymb)) and (self.SymbolAnim or self.SymbolAnim2) then
	    self.SymbolAnim2 = nil
	    self.SymbolAnim = nil
	end
	if not self.SymbolAnim and not self.SymbolAnim2 or self.SymbolAnim2 and (CurTime()-self.SymbolAnim2) > 0.6 then
	    if LastSecond and dialadd[#dialadd] ~= "#" and SG.Chevron < 9 then
	        self.DialingAddress = dialadd..dialdsymb
	        if not self.EndTimer then
	            self.EndTimer = CurTime()
	        end
	    else
	        if not open and self:GetNW2Bool("ChevronLocked",false) and not self.EndTimer then
	            self.EndTimer = CurTime()
	        end
	        self.DialingAddress = dialadd
	    end
	end
	if self.OldDialingAddress ~= self.DialingAddress then
	    if #self.OldDialingAddress < #self.DialingAddress then
	        --SEncoded:stop()
	        --SEncoded:play()
	    end
	    self.OldDialingAddress = self.DialingAddress
	end
	--[[
	local endT = self.EndTimer and (CurTime()-EndTimer)%0.4 == 0
	if self.OldLocked ~= endT and endT then
	    SLock:stop()
	    SLock:play()
	    self.OldLocked = endT
	end
	if (self:GetNW2Bool("Open",false) or not self:GetNW2Bool("Active",false) orself. EndTimer and CurTime()-self.EndTimer > 1.2) and self.EndTimer then
	    self.EndTimer = nil
	end
	]]
end
