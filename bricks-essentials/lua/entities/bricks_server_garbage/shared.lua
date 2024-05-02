ENT.Type = "anim"
ENT.Base = "base_gmodentity"
 
ENT.PrintName		= "Garbage"
ENT.Category		= "Bricks Server"
ENT.Author			= "Brick Wall"
ENT.AutomaticFrameAdvance = true
ENT.Spawnable		= true

function ENT:SetupDataTables()
    self:NetworkVar( "Entity", 0, "Collector" )
end