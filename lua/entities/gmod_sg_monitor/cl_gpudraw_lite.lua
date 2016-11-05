--Lite lib from Wiremod GPU

ENT.material = CreateMaterial("4:3DialComp","UnlitGeneric",{
	["$vertexcolor"] = 1,
	["$vertexalpha"] = 0,
	["$nolod"] = 1,
})
--[[
local mat_pngrt = CreateMaterial("PngRT", "UnlitGeneric", {
	["$basetexture"] = "", ["$ignorez"] = 1,
	["$vertexcolor"] = 1, ["$vertexalpha"] = 1,
	["$nolod"] = 1,
})
function draw.PngToRT(tex)
	local m_type = type(tex)
	tex = tex:GetTexture("$basetexture")
	mat_pngrt:SetTexture("$basetexture", tex)
	return mat_pngrt
end]]

function ENT:ScreenInit(x,y,pos,ang,scale)
  self.XRes = x
  self.YRes = y
  self.SPos = pos
  self.SAng = ang
  self.SScale = scale
  --self.RT = GetRenderTarget("SGC_Mon"..math.random(1,1000), self.XRes, self.YRes)
	--self.material:SetTexture("$basetexture", self.RT)
end
function ENT:ScreenChange(pos,ang,scale)
  self.SPos = pos
  self.SAng = ang
  self.SScale = scale
end

function ENT:DrawRT(x,y,w,h,s)
  if not self.Screen then return end
	render.PushRenderTarget(self.RT,0,0,512 or self.XRes, 512 or self.YRes)
		render.Clear( 0, 0, 0, 0 )
	  cam.Start2D()
	    local succ,err = pcall(self.Screen,self)
	    if not succ then
	      surface.SetAlphaMultiplier(1)
	      ErrorNoHalt(err.."\n")
	    end
    cam.End2D()
	render.PopRenderTarget()
end

function ENT:DrawScreen(x,y,w,h,s)
  if not self.Screen then print(1) return end
	self.material:SetTexture("$basetexture", self.RT)
	cam.Start3D2D(self:LocalToWorld(self.SPos), self:LocalToWorldAngles(self.SAng), self.SScale)
		surface.SetDrawColor(0,0,0,255)
		surface.DrawRect(x,y,w,h)
		render.ClearStencil()
		render.SetStencilEnable(true)
		render.SetStencilTestMask(1);render.SetStencilWriteMask(1);render.SetStencilReferenceValue(1)
		render.SetStencilPassOperation(STENCIL_REPLACE)
		render.SetStencilFailOperation(STENCIL_KEEP)
		render.SetStencilZFailOperation(STENCIL_KEEP)
		render.SetStencilCompareFunction(STENCIL_ALWAYS)
			surface.SetDrawColor(0,0,0,255)
      surface.DrawRect(x,y,w,h)
    render.SetStencilCompareFunction(STENCIL_EQUAL)
			surface.SetDrawColor(255,255,255,255)
			surface.SetMaterial(self.material)
			local w,h = self.XRes,self.YRes
			surface.DrawTexturedRectRotated((w+(512-w))/2,(h+(512-h))/2,512*s,512*s,0)
    render.SetStencilEnable(false)
		render.SetStencilTestMask(0);render.SetStencilWriteMask(0);render.SetStencilReferenceValue(0)
	cam.End3D2D()
end
