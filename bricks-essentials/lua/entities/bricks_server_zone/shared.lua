ENT.Type = "anim"
ENT.Base = "base_gmodentity"
 
ENT.PrintName		= "Zone"
ENT.Category		= "Bricks Server"
ENT.Author			= "Brick Wall"
ENT.AutomaticFrameAdvance = true
ENT.Spawnable		= true

function ENT:SetupDataTables()

end

function ENT:Initialize()
    self:SetCollisionGroup( COLLISION_GROUP_IN_VEHICLE )
	self:SetSolid( SOLID_BBOX )
    self:DrawShadow( false )
    
    if( SERVER ) then
        self:SetTrigger( true )
    end
end