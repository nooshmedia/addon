ENT.Type = "anim"
ENT.Base = "base_gmodentity"
 
ENT.PrintName		= "Rock"
ENT.Category		= "Bricks Server"
ENT.Author			= "Brick Wall"
ENT.AutomaticFrameAdvance = true
ENT.Spawnable		= true

function ENT:SetupDataTables()
    self:NetworkVar( "String", 0, "RockType" )
    self:NetworkVar( "Int", 0, "RHealth" )
    self:NetworkVar( "Int", 1, "Stage" )
end