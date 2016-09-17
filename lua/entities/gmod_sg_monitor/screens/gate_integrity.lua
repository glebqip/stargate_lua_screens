---------------------
-- Screen: IDC s1 --
-- Author: glebqip --
-- ID: 2 --
---------------------

local SCR = {
  Name = "Gate integrity monitor",
  ID = 5,
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
    self.Boxes = {}
    self.BoxesTimer = CurTime()
  end

  local MainFrame = surface.GetTextureID("glebqip/integrity screen 1/mainframe")

  --local Gradient = surface.GetTextureID("vgui/gradient_down")
  local CenterGrad = surface.GetTextureID("gui/center_gradient")

  local Red = Color(239,0,0)

  function SCR:Draw(MainColor, SecondColor, ChevBoxesColor)
    surface.SetDrawColor(MainColor)
    surface.SetTexture(MainFrame)
    surface.DrawTexturedRectRotated(256,192,512,512,0)
    surface.SetDrawColor(Color(100,190,120))
    surface.SetTexture(CenterGrad)
    surface.DrawTexturedRect(305,46,189,10,0)


    surface.SetDrawColor(SecondColor)
    for i=1,36 do
      if self.Boxes[i] then
        local x,y = 0,0
        if i > 18 then x = 26 end
        if i > 9 and i < 19 or i > 27 then y = 26 end
        surface.DrawRect(21+i%3*5+x,305+math.ceil(i/3-1)%3*5+y,3,3)
      end
    end

    draw.SimpleText("SIGNAL DATA", "Marlett_21", 305, 32, SecondColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM)
    draw.SimpleText("DECODING", "Marlett_16", 305, 38, SecondColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
  end

  function SCR:Think(curr)
    if not curr then return end
    local connected = self:GetServerBool("Connected",false)
    if CurTime()-self.BoxesTimer > 0.15 and connected then
      for i=1,36 do
        self.Boxes[i] = math.random()>0.4
      end
      self.BoxesTimer = CurTime()
    end
  end
end

return SCR
