AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self:SetModel("models/2rek/brickwall/bwall_rock_1_phys_3.mdl")

	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	
    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end

	self:GetPhysicsObject():EnableMotion( false )

	local rockTable = BRICKS_SERVER.CONFIG.CRAFTING.RockTypes[self.rockType or ""]
	if( rockTable ) then
		self:SetRockType( self.rockType or "" )
	end

	self:SetRHealth( 100 )
	self:SetStage( 1 )
end

function ENT:AcceptInput(ply, caller)

end

function ENT:HitRock( Damage, attacker )
	if( not Damage or Damage <= 0 ) then return end

	self:SetRHealth( self:GetRHealth()-Damage )

	if( self:GetStage() <= 1 and (self:GetRHealth()/100)*100 <= 50 ) then
		self:SetModel("models/2rek/brickwall/bwall_rock_1_phys_2.mdl")
		self:PhysicsInit( SOLID_VPHYSICS )
		self:GetPhysicsObject():EnableMotion( false )
		self:SetStage( 2 )
	elseif( self:GetStage() <= 2 and (self:GetRHealth()/100)*100 <= 0 ) then
		self:SetModel("models/2rek/brickwall/bwall_rock_1_phys_1.mdl")
		self:PhysicsInit( SOLID_VPHYSICS )
		self:GetPhysicsObject():EnableMotion( false )
		self:SetStage( 3 )

		local rockTable = BRICKS_SERVER.CONFIG.CRAFTING.RockTypes[self:GetRockType()]
		if( BRICKS_SERVER.CONFIG.CRAFTING.Resources[(self:GetRockType() or "")] ) then
			if( not BRICKS_SERVER.CONFIG.CRAFTING["Add Resources Directly To Inventory"] ) then
				local resourceEnt = ents.Create( "bricks_server_resource_" .. string.Replace( string.lower( (self:GetRockType() or "") ), " ", "" ) )
				if( IsValid( resourceEnt ) ) then
					resourceEnt:SetPos( self:GetPos()+Vector( 0, 0, 50 ) )
					resourceEnt:Spawn()
				end
			elseif( IsValid( attacker ) and attacker:IsPlayer() ) then
				local itemData = { "bricks_server_resource", (BRICKS_SERVER.CONFIG.CRAFTING.Resources[self:GetRockType() or ""][1] or ""), self:GetRockType() }
                attacker:BRS():AddInventoryItem( itemData, 1 )
			end

			if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "levelling" ) and IsValid( attacker ) and attacker:IsPlayer() ) then
				attacker:AddExperience( (BRICKS_SERVER.CONFIG.LEVELING["EXP Gained - Rock Mined"] or 0), "Mining" )
			end
		end
	end
end