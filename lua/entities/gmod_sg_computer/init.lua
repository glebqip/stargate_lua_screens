/*   Copyright (C) 2016 by glebqip   */
resource.AddWorkshop("761096308")
if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("extra")) then return end
include("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_gpudraw_lite.lua")

function ENT:Initialize()
	self:SetModel("models/props_lab/monitor01a.mdl")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
end

function ENT:SpawnFunction( ply, tr )
	if ( not tr.Hit ) then return end

	local ang = ply:GetAimVector():Angle()
		ang.p = 0
		ang.r = 0
		ang.y = (ang.y+180) % 360

	local ent = ents.Create("gmod_sg_computer")
	ent:SetAngles(ang)
	ent:SetPos(tr.HitPos+Vector(0,0,20))
	ent:Spawn()
	ent:Activate()

	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then phys:EnableMotion(false) end

	return ent
end

function ENT:Think()
	local gate = self.LockedGate
	if (IsValid(gate)) then
		self:SetNW2Int("RingAngle",gate:GetRingAng())
		self:SetNW2Bool("Active",gate.Active)
		self:SetNW2Bool("Open",gate.IsOpen)
		self:SetNW2Bool("Inbound",gate.Inbound)
		self:SetNW2Bool("RingRotation",gate.RingRotation ~= 0)
		self:SetNW2Bool("ChevronLocked",gate.ChevronLocked)
		self:SetNW2String("Chevrons",string.Implode("",gate.WireChevrons))
		--self:SetNWString("SGAddress",gate:GetWire("Dialing Address","",true))
	end
	self:SetNW2Bool("Connected",IsValid(gate))
	self:NextThink(CurTime()+0.075)
	return true
end

function ENT:Touch(ent)
	if not IsValid(self.LockedGate) then
		if (ent.IsGroupStargate) then --IsStargate
			self.LockedGate = ent
			local ed = EffectData()
			ed:SetEntity( self )
			util.Effect( "propspawn", ed, true, true )
		end
	end
end

function ENT:UpdateTransmitState() return TRANSMIT_ALWAYS end
