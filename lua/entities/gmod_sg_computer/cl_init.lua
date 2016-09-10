include("shared.lua")
include("cl_gpudraw_lite.lua")
ENT.ScreenFunctions = {}
for _,filename in pairs(file.Find("entities/gmod_sg_computer/screens/*.lua","LUA")) do include("entities/gmod_sg_computer/screens/"..filename) end


surface.CreateFont("SGC_SG1", {font="Stargate Address Glyphs Concept", size=35, weight=400, antialias=true, additive=false})
surface.CreateFont("SGC_Symb", {font="Stargate Address Glyphs Concept", size=90, weight=400, antialias=true, additive=false, })
surface.CreateFont("Marlett_15", {font="Marlett", size=15, weight=800, antialias=true, additive=false, })
surface.CreateFont("Marlett_22", {font="Marlett", size=22, weight=800, antialias=true, additive=false, })
surface.CreateFont("Marlett_25", {font="Marlett", size=25, weight=800, antialias=true, additive=false, })
surface.CreateFont("Marlett_27", {font="Marlett", size=27, weight=800, antialias=true, additive=false, })
surface.CreateFont("Marlett_29", {font="Marlett", size=29, weight=800, antialias=true, additive=false, })
surface.CreateFont("Marlett_Open", {font="Marlett", size=46, weight=800, antialias=true, additive=false, })
surface.CreateFont("Marlett_Err", {font="Marlett", size=19, weight=800, antialias=true, additive=false, })
surface.CreateFont("Marlett_Error", {font="Marlett", size=56, weight=800, antialias=true, additive=false, })


if (SGLanguage ~=nil and SGLanguage.GetMessage ~=nil) then
	ENT.Category = SGLanguage.GetMessage("entity_main_cat")
	ENT.PrintName = SGLanguage.GetMessage("sgc_computer")
end


function ENT:Initialize()
	self:ScreenInit(512, 384, Vector(11.75, -512/2*0.04, 384/2*0.04+3.9), Angle(0, 90, 85.5), 0.04)
	--Colors:Movie
	self.MainColor = Color(42, 125, 225)
	self.ChevBoxesColor = self.MainColor
	self.SecondColor = Color(229, 238, 179)
	--Colors:First series
	self.MainColor = Color(40, 167, 240)
	self.ChevBoxesColor = self.MainColor
	self.SecondColor = Color(200, 200, 200)
	--Colors:
	self.MainColor = Color(30, 180, 200)
	self.ChevBoxesColor = self.MainColor
	self.SecondColor = Color(200, 200, 182)
	--self.SecondColor = Color(208, 208, 144)
	for _, v in pairs(self.ScreenFunctions) do
		v[1](self)
	end
	self.CurrScreen = 1
end

function ENT:Draw()
	self:DrawModel()
	self:DrawScreen(0, -10, 512, 410, 0.96)
	return true
end

--hi garrysmod.com, i am so lazy
function draw.OutlinedBox(x, y, w, h, thickness)
	for i=0, thickness - 1 do
		surface.DrawOutlinedRect(x + i, y + i, w - i * 2, h - i * 2)
	end
end

function ENT:Screen()
	self.ScreenFunctions[self.CurrScreen][2](self)
	surface.SetAlphaMultiplier(1)
end

function ENT:Think()
for _, v in pairs(self.ScreenFunctions) do
	v[3](self)
end
end
