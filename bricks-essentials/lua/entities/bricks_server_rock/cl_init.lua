include('shared.lua')

BRS_ROCKS_CSModels = (BRS_ROCKS_CSModels or {})

function ENT:Initialize()
	self.stage = 1

	self.rockModel = ents.CreateClientProp()
	self.rockModel:SetPos( self:GetPos() )
	self.rockModel:SetAngles( self:GetAngles() )
	self.rockModel:SetModel( "models/2rek/brickwall/bwall_rock_1.mdl" )
	self.rockModel:Spawn()

	table.insert( BRS_ROCKS_CSModels, { self, self.rockModel } )

	if( self:GetRockType() and BRICKS_SERVER.CONFIG.CRAFTING.Resources[self:GetRockType()] and BRICKS_SERVER.CONFIG.CRAFTING.Resources[self:GetRockType()][2] ) then
		self.rockModel:SetColor( BRICKS_SERVER.CONFIG.CRAFTING.Resources[self:GetRockType()][2] )
	end
end

function ENT:Think()
	if( not IsValid( self.rockModel ) ) then 
		self.rockModel = ents.CreateClientProp()
		self.rockModel:SetPos( self:GetPos() )
		self.rockModel:SetAngles( self:GetAngles() )
		self.rockModel:SetModel( "models/2rek/brickwall/bwall_rock_1.mdl" )
		self.rockModel:Spawn()

		table.insert( BRS_ROCKS_CSModels, { self, self.rockModel } )
		return
	end

	self.rockModel:SetPos( self:GetPos() )
	self.rockModel:SetAngles( self:GetAngles() )

	if( self:GetStage() == 1 and self.stage != 1 ) then
		self.rockModel:SetBodygroup( 2, 0 )
		self.rockModel:SetBodygroup( 3, 0 )
		if( self:GetRockType() and BRICKS_SERVER.CONFIG.CRAFTING.Resources[self:GetRockType()] and BRICKS_SERVER.CONFIG.CRAFTING.Resources[self:GetRockType()][2] ) then
			self.rockModel:SetColor( BRICKS_SERVER.CONFIG.CRAFTING.Resources[self:GetRockType()][2] )
		end
		self.stage = 1
	elseif( self:GetStage() == 2 and self.stage != 2 ) then
		self.rockModel:SetBodygroup( 3, 1 )
		self.stage = 2
	elseif( self:GetStage() == 3 and self.stage != 3 ) then
		self.rockModel:SetBodygroup( 2, 1 )
		self.stage = 3
	end
end

function ENT:OnRemove()
	if( IsValid( self.rockModel ) ) then
		self.rockModel:Remove()
	end
end

function ENT:Draw()
	self:DrawModel()
end

hook.Add( "EntityRemoved", "BRS.EntityRemoved_Rocks", function( ent )
	if( ent:GetClass() == "bricks_server_rock" ) then
		for k, v in pairs( BRS_ROCKS_CSModels ) do
			if( v[1] == ent ) then
				if( IsValid( v[2] ) ) then
					v[2]:Remove()
				end

				BRS_ROCKS_CSModels[k] = nil
			end
		end
	end
end )