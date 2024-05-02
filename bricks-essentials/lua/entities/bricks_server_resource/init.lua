AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	if( BRICKS_SERVER.CONFIG.CRAFTING.Resources[self.ResourceType] ) then
		self:SetModel( BRICKS_SERVER.CONFIG.CRAFTING.Resources[self.ResourceType][1] or "models/props_junk/rock001a.mdl" )
		if( BRICKS_SERVER.CONFIG.CRAFTING.Resources[self.ResourceType][2] ) then
			self:SetColor( BRICKS_SERVER.CONFIG.CRAFTING.Resources[self.ResourceType][2] )
		end
	else
		self:SetModel( "models/props_junk/rock001a.mdl" )
	end
	
	self:SetResourceType( self.ResourceType )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	
    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end

	self:SetAmount( 1 )

	timer.Create( "BRS_TIMER_RESOURCE_" .. tostring( self ), (BRICKS_SERVER.CONFIG.CRAFTING["Resource Despawn Time"] or 300), 1, function()
		if( IsValid( self ) ) then
			self:Remove()
		end
	end )
end

function ENT:Use( ply )

end

function ENT:OnRemove()
	if( timer.Exists( "BRS_TIMER_RESOURCE_" .. tostring( self ) ) ) then
		timer.Remove( "BRS_TIMER_RESOURCE_" .. tostring( self ) )
	end
end

function ENT:SpawnFunction( ply, tr, ClassName )
	if ( !tr.Hit ) then return end

	local SpawnPos = tr.HitPos + tr.HitNormal * 20
	local SpawnAng = ply:EyeAngles()
	SpawnAng.p = 0
	SpawnAng.y = SpawnAng.y + 180

	local ent = ents.Create( ClassName )
	ent:SetPos( SpawnPos )
	ent:SetAngles( SpawnAng )
	ent:Spawn()
	ent:Activate()

	return ent
end