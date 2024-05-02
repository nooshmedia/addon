ENT.Type = "anim"
ENT.Base = "base_gmodentity"
 
ENT.PrintName		= "Tree"
ENT.Category		= "Bricks Server"
ENT.Author			= "Brick Wall"
ENT.AutomaticFrameAdvance = true
ENT.Spawnable		= true

function ENT:SetupDataTables()
    self:NetworkVar( "String", 0, "Resource" )
    self:NetworkVar( "Int", 0, "FarmableHealth" )
end