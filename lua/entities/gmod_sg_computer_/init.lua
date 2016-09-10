/*   Copyright (C) 2010 by Llapp   */

if (StarGate==nil or StarGate.CheckModule==nil or not StarGate.CheckModule("extra")) then return end
include("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

function ENT:Initialize()
	self.Entity:SetModel("models/props/cs_office/tv_plasma.mdl") ;
	self.Entity:PhysicsInit( SOLID_VPHYSICS ) ;
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS );
	self.Entity:SetSolid( SOLID_VPHYSICS );

	self.LockedGate = self.Entity
end

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end

	local ang = ply:GetAimVector():Angle(); ang.p = 0; ang.r = 0; ang.y = (ang.y+180) % 360;

	local ent = ents.Create("gmod_sg_computer_");
	ent:SetAngles(ang);
	ent:SetPos(tr.HitPos+Vector(0,0,20));
	ent:Spawn();
	ent:Activate();

	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then phys:EnableMotion(false) end

	return ent
end

function ENT:Think()
	local gate = self.LockedGate
	if (IsValid(gate)) then
		self:SetNWInt("SGChevron",gate:GetWire("Chevron",0,true));
		self:SetNWBool("SGChevronLock",util.tobool(gate:GetWire("Chevron Locked",0,true)));
		self:SetNWString("SGAddress",gate:GetWire("Dialing Address","",true));
	end
	self.Entity:NextThink(CurTime()+0.1)
	return true;
end

function ENT:Touch(ent)
	if self.LockedGate == self.Entity then
		if (ent.IsGroupStargate) then
			self.LockedGate = ent
			local ed = EffectData()
			ed:SetEntity( self.Entity )
			util.Effect( "propspawn", ed, true, true )
		end
	end
end

function ENT:UpdateTransmitState() return TRANSMIT_ALWAYS end
