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
