--Lite lib from Wiremod GPU

local matScreen = CreateMaterial("4:3DialCompRT","UnlitGeneric",{
	["$vertexcolor"] = 1,
	["$vertexalpha"] = 1,
	["$nolod"] = 1,
})

function ENT:ScreenInit(x,y,pos,ang,scale)
  self.XRes = x
  self.YRes = y
  self.SPos = pos
  self.SAng = ang
  self.SScale = scale
  --self.RT = GetRenderTarget("SGC_Mon"..math.random(1,1000), self.XRes, self.YRes)
	--matScreen:SetTexture("$basetexture", self.RT)
end
function ENT:ScreenChange(pos,ang,scale)
  self.SPos = self:LocalToWorld(pos)
  self.SAng = ang
  self.SScale = scale
end

function ENT:DrawScreen(x,y,w,h,s)
  if not self.Screen then return end
	local oldw,oldh = ScrW(),ScrH()
	local OldRT = render.GetRenderTarget()
	matScreen:SetTexture("$basetexture", self.RT)

	render.SetRenderTarget(self.RT)
	  render.SetViewPort(0, 0, self.XRes, self.YRes)
			render.Clear( 0, 0, 0, 0 )
		  cam.Start2D()
		    local succ,err = pcall(self.Screen,self)
		    if not succ then
		      surface.SetAlphaMultiplier(1)
		      ErrorNoHalt(err.."\n")
		    end
	    cam.End2D()
	  render.SetViewPort(0, 0, oldw, oldh)
	render.SetRenderTarget(OldRT)

	cam.Start3D2D(self:LocalToWorld(self.SPos), self:LocalToWorldAngles(self.SAng), self.SScale)
		surface.SetDrawColor(0,0,0,255)
		surface.DrawRect(x,y,w,h)
		surface.SetDrawColor(255,255,255,255)
		surface.SetMaterial(matScreen)
		surface.DrawTexturedRectRotated(self.XRes/2,self.YRes/2,self.XRes*s,self.YRes*s,0)
	cam.End3D2D()
end
