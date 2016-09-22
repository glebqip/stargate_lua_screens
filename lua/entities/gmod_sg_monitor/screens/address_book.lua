---------------------
-- Screen: IDC s1 --
-- Author: glebqip --
-- ID: 2 --
---------------------

local SCR = {
  Name = "Address book",
  ID = 8,
}

if SERVER then
  function SCR:Initialize()
    self.Selected = 0
    self.Scrool = 0
    self.Scrooling = false
  end

  function SCR:Think(curr,dT)
    if self.Scrooling then
      self.Scrool = math.Clamp(self.Scrool + dT*4*self.Scrooling,0,self:GetServerInt("AddressCount")+1)
      self:SetMonitorFloat("ABScrool",self.Scrool)
    end
    if self.Selected < math.floor(self.Scrool) and math.floor(self.Scrool) < self:GetServerInt("AddressCount") then
      self.Selected = math.floor(self.Scrool)
    end
    local max = math.floor(self.Scrool) ~= self.Scrool and 7 or 6
    if self.Selected > math.floor(self.Scrool)+max then
      self.Selected = math.floor(self.Scrool)+max
    end
    self:SetMonitorInt("ABSelected",self.Selected)
    --
  end
  function SCR:Trigger(curr,key,value)
    if not curr then return end
    if self:GetMonitorBool("ServerConnected",false) then
       -- \, iris toggle
      if key == 92 and value then self.Entity.Server.Iris = not self.Entity.Server.Iris end
      -- Backspace, close gate
      if key == 127 and self:GetServerBool("Connected",false) and self:GetServerBool("Active",false) and value then self.Entity.Server.LockedGate:AbortDialling() end
    end
    if key == 13 and value then
      self.Entity.Screens[1].EnteredAddress = self:GetServerString("Address"..(self:GetMonitorInt("ABSelected",0)+1),"")
      if #self.Entity.Screens[1].EnteredAddress < 9 then
        self.Entity.Screens[1].EnteredAddress = self.Entity.Screens[1].EnteredAddress.."#"
      end
      self.Entity.Screen = 1
    end
    if key == 17 and value then self.Selected = math.Clamp(self.Selected-1,0,self:GetServerInt("AddressCount")-1) end
    if key == 18 and value then self.Selected = math.Clamp(self.Selected+1,0,self:GetServerInt("AddressCount")-1) end
    if key == 151 and value then self.Scrooling = 1 end
    if key == 151 and not value then self.Scrooling = false end
    if key == 152 and value then self.Scrooling = -1 end
    if key == 152 and not value then self.Scrooling = false end

  end
else
  function SCR:Initialize()
    self.Symbols = {}
    self.SymbolsTimer = CurTime()-1
  end

  local MainFrame = surface.GetTextureID("glebqip/address book 1/mainframe")
  local Address7 = surface.GetTextureID("glebqip/address book 1/address")
  local Address8 = surface.GetTextureID("glebqip/address book 1/address8")
  local Address9 = surface.GetTextureID("glebqip/address book 1/address9")

  local Red = Color(239,0,0)

  function SCR:Draw(MainColor, SecondColor, ChevBoxesColor)
    local scr = self:GetMonitorFloat("ABScrool",0)%1
    local scrg = math.floor(self:GetMonitorFloat("ABScrool",0))
    local add = scrg-self:GetMonitorInt("ABSelected",0)
    for i=0,math.min(7,self:GetServerInt("AddressCount",0)-scrg-1) do
      surface.SetFont("Marlett_15")
      local text = self:GetServerString("AddressName"..(i+scrg+1),"")
      if surface.GetTextSize(text) > 88 then
        for i=8,15 do
          if surface.GetTextSize(text:sub(1,i).."...") > 88 then
            text = text:sub(1,i-1).."..."
            break
          end
        end
      end
      draw.SimpleText(text, "Marlett_15", 19, 65+(i-scr)*35, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
      local min = #self:GetServerString("Address"..(i+scrg+1),"")-6
      local addr = self:GetServerString("Address"..(i+scrg+1),"")
      for i1=1,#addr do
        draw.SimpleText(addr[i1], "SGC_ABS1", 293+(i1-1-min)*21, 79+(i-scr)*35, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
      end
      if min >= 2 then
        surface.SetTexture(Address9)
      elseif min == 1 then
        surface.SetTexture(Address8)
      else
        surface.SetTexture(Address7)
      end
      draw.SimpleText(Format("0x%08X",self:GetServerString("AddressCRC"..(i+scrg+1),"")), "Marlett_9", 421, 65+(i-scr)*35, MainColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
      if self:GetServerBool("AddressBlocked"..(i+scrg+1),false) then
        draw.SimpleText("BLOCKED!", "Marlett_12", 19, 80+(i-scr)*35, Red, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        surface.SetDrawColor(Red)
      else
        surface.SetDrawColor(MainColor)
      end
      surface.DrawTexturedRectRotated(212,73+(i-scr)*35,512,32,0)
    end
    if self:GetServerBool("AddressBlocked"..(self:GetMonitorInt("ABSelected",0)+1),false) then
      surface.SetDrawColor(SecondColor)
    else
      surface.SetDrawColor(Red)
    end
    draw.OutlinedBox(14, 57+(0-scr-add)*35,396,32,1)
    for i=1,#self.Symbols do
      if self.Symbols[i] then
        if i < 8 then
          draw.SimpleText(self.Symbols[i], "SGC_ABS", 1+i*28, 352, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        else
          draw.SimpleText(self.Symbols[i], "SGC_ABS", 262+(i-7)*28, 352, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
      end
    end

    surface.SetDrawColor(MainColor)
    surface.SetTexture(MainFrame)
    surface.DrawTexturedRectRotated(256,192,512,512,0)
    draw.SimpleText("BILINEAR SEARCH ALGORITHM", "Marlett_15", 18, 333, SecondColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
    draw.SimpleText(os.date("!%d.%m.%y %H:%M:%S"), "Marlett_12", 473, 30, MainColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
    draw.SimpleText("1", "Marlett_12", 226, 346, SecondColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.SimpleText("2", "Marlett_12", 261, 357, SecondColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

  end

  local randstr = "#?"
  for i=48,57 do randstr = randstr..string.char(i) end
  for i=64,90 do randstr = randstr..string.char(i) end
  function SCR:Think(curr)
    if not curr then return end
    if CurTime()-self.SymbolsTimer > 0.1 then
      str = ""
      for i=1,14 do
        if math.random() > 0.5 then self.Symbols[i] = randstr[math.random(1,#randstr)] end
      end
      self.SymbolsTimer = CurTime()
    end
  end
end

return SCR
