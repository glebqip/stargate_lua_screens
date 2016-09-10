include('shared.lua')
if true then return end

if (SGLanguage!=nil and SGLanguage.GetMessage!=nil) then
ENT.Category = SGLanguage.GetMessage("entity_main_cat");
ENT.PrintName = SGLanguage.GetMessage("sgc_computer");
end

local sg1 = {
	font = "Stargate Address Glyphs SG1",
	size = 24,
	weight = size,
	antialias = true,
	additive = additive,
}
surface.CreateFont("SGC_SG1", sg1);

local fontData =
{
	font="lucida console",
	size=20,
	weight=800,
	antialias= true,
	additive = false,
}
surface.CreateFont("SGC_Font", fontData)

function ENT:Initialize()
	self.RT = GetRenderTarget("SGC_COMPUTER", 512, 512)
end

function ENT:Draw()
	self:DrawModel()
	self:RenderScreen()
	return true
end

local matScreen = CreateMaterial("SGCRT","UnlitGeneric",{
	["$vertexcolor"] = 1,
	["$vertexalpha"] = 1,
	["$ignorez"] = 1,
	["$nolod"] = 1,
})

function ENT:RenderScreen()
	if (not self.RT) then return end

	local pos, ang = self:LocalToWorld(Vector(6.5,-28,36)),self:LocalToWorldAngles(Angle(0,90,90))

	local OldTex = matScreen:GetTexture("$basetexture")
	matScreen:SetTexture("$basetexture", self.RT)

	--local res = monitor.RS
	cam.Start3D2D(pos, ang, 0.1)
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

		surface.SetMaterial(matScreen)
	cam.End3D2D()

end
