ENT.Type = "anim"
ENT.Base = "base_gmodentity"
 
ENT.PrintName		= "Money Bag"
ENT.Category		= "Bricks Server"
ENT.Author			= "Brick Wall"
ENT.AutomaticFrameAdvance = true
ENT.Spawnable		= true

function ENT:SetupDataTables()
	self:NetworkVar( "Int", 0, "Money" )
end