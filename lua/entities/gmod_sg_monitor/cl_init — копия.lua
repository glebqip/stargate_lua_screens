include("shared.lua")
surface.CreateFont("SGC_SG1", {
	font = "Stargate Address Glyphs SG1",
	size = 24,
	weight = size,
	antialias = true,
	additive = additive,
})
surface.CreateFont("SGC_Font", {
	font="lucida console",
	size=20,
	weight=800,
	antialias= true,
	additive = false,
})

if WireGPU_AddMonitor then
	--Add a CRT screen to wiregpu
	WireGPU_AddMonitor("CRT Monitor (4:3)","models/props_lab/monitor01a.mdl",12.4,4,0,0.03,-60,60,-48,48)
	WireGPU_Monitors["models/props_lab/monitor01a.mdl"].rot = Angle(0,90,85.5)
end

if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
	ENT.Category = SGLanguage.GetMessage("entity_main_cat")
	ENT.PrintName = SGLanguage.GetMessage("sgc_computer")
end

function ENT:Initialize()
	self.GPU = GPULib.WireGPU(self)
	self.RT = GetRenderTarget("SGC_COMPUTER", 512, 384)
end

function ENT:Draw()
	self:DrawModel()
	if self.GPU then
		self:DrawModel()
		self.GPU:RenderToGPU(function() self:RenderScreen() end)
		--self:RenderScreen()
		self.GPU:Render(0,0,512,512)
	else
		local pos, ang = self:LocalToWorld(Vector(6.5,-28,36)),self:LocalToWorldAngles(Angle(0,90,90))
		cam.Start3D2D(pos, ang, 0.1)
			self:RenderScreen()
		cam.End3D2D()
	end
	--self:RenderScreen()
	return true
end

local matScreen = CreateMaterial("SGCRT","UnlitGeneric",{
	["$vertexcolor"] = 1,
	["$vertexalpha"] = 1,
	["$ignorez"] = 1,
	["$nolod"] = 1,
})

function ENT:RenderScreen()
surface.SetDrawColor(255,255,255,255)
	surface.DrawRect(0,0,512,384)

	if true then return end
	surface.SetDrawColor(0,0,0,255)
	--surface.DrawRect(-36,-28,34,56)
	surface.DrawRect(0,0,560,340)
	surface.SetDrawColor(255,255,255,255)

	surface.SetFont("SGC_Font")
	surface.SetTextColor( 255, 255, 255, 255 )
	surface.SetTextPos( 0, 0 )

	local chevron = self:GetNWInt("SGChevron",0);
	local address = self:GetNWString("SGAddress","");

	local chevpos = {10,45,80,115,150,185,220,255,290}
	for i=1,9 do
		if (chevron>=i) then
			surface.SetFont("SGC_SG1")
			surface.SetTextPos( 475, chevpos[i]+3 )
			surface.DrawText(address[i]);
			surface.SetFont("SGC_Font")
			surface.SetTextPos( 450, chevpos[i]+3 )
			surface.DrawText(i);
		end
		if (i<=7 or chevron==8 and i==8 or chevron==9) then
			surface.DrawOutlinedRect( 470, chevpos[i], 40, 30 )
		end
	end

	surface.DrawOutlinedRect( 105, 10, 340, 240 )
	surface.DrawRect(105,10,15,15)
	surface.DrawRect(430,10,15,15)
	surface.DrawRect(105,235,15,15)
	surface.DrawRect(430,235,15,15)

	surface.DrawOutlinedRect( 10, 10, 80, 150 )
	surface.DrawLine( 10, 170, 10, 250 )
	surface.DrawLine( 90, 170, 90, 250 )

	surface.DrawOutlinedRect( 10, 260, 160, 60 )
	surface.DrawOutlinedRect( 180, 260, 80, 60 )

	surface.DrawCircle( 275, 125, 85, Color(255,255,255,255) )
	--surface.DrawCircle( 275, 125, 96, Color(255,255,255,255) )
	--surface.DrawCircle( 275, 125, 100, Color(255,255,255,255) )
	surface.DrawCircle( 275, 125, 108, Color(255,255,255,255) )

	surface.DrawLine( 275, 100, 275, 150 )
	surface.DrawLine( 250, 125, 300, 125 )
end

function ENT:OnRemove()
	if not self.GPU then return end
	self.GPU:Finalize()
end
