AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self:SetModel("models/props_c17/SuitCase_Passenger_Physics.mdl")

	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	
    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:SetMass(105)
	end
	
	self:SetMoney( math.random( BRICKS_SERVER.CONFIG.BANKVAULT["Money Bag Amount"][1], BRICKS_SERVER.CONFIG.BANKVAULT["Money Bag Amount"][2] ) )
end

function ENT:Use( ply )
	if( IsValid( ply ) ) then
		if( (ply.BRS_MONEYBAG_COOLDOWN or 0) > CurTime() ) then return end
		ply.BRS_MONEYBAG_COOLDOWN = CurTime()+1

		if( ply:GetNW2Int( "BRS_MoneyBagAmount", 0 ) <= 0 or BRICKS_SERVER.CONFIG.BANKVAULT["Can Pickup Multiple Bags"] ) then
			self:Remove()
			ply:SetNW2Int( "BRS_MoneyBagAmount", ply:GetNW2Int( "BRS_MoneyBagAmount", 0 )+(self:GetMoney() or 0) )
			DarkRP.notify( ply, 1, 4, "You picked up a money bag, take it to a money launderer!" )
		else
			DarkRP.notify( ply, 1, 4, "You are already carrying a money bag!" )
		end
	end
end

function ENT:Think()

end

function ENT:OnRemove()

end

function ENT:StartTouch( touchEnt )
	if( not IsValid( touchEnt ) ) then return end
	
	if( touchEnt:GetClass() == "bricks_server_bank_vault" ) then
		self:Remove()
		touchEnt:SetMoneyBags( math.Clamp( touchEnt:GetMoneyBags()+1, 0, BRICKS_SERVER.CONFIG.BANKVAULT["Money Bags"] ) )
	end
end

function ENT:AcceptInput(ply, caller)

end

hook.Add( "PlayerDeath", "BRS.PlayerDeath_EssentialsBank", function( ply )
	if( ply:GetNW2Int( "BRS_MoneyBagAmount", 0 ) > 0 ) then
		local bankbag = ents.Create( "bricks_server_bank_bag" )
		if ( !IsValid( bankbag ) ) then return end
		bankbag:SetPos( ply:GetPos() + Vector( 0, 0, 20 ) )
		bankbag:SetAngles( ply:GetAngles() )
		bankbag:Spawn()
		bankbag:SetMoney( ply:GetNW2Int( "BRS_MoneyBagAmount", 0 ) )

		ply:SetNW2Int( "BRS_MoneyBagAmount", 0 )
	end
end )