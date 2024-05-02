ENT.Type = "anim"
ENT.Base = "base_gmodentity"
 
ENT.PrintName		= "Resource Base"
ENT.Category		= "Bricks Server"
ENT.Author			= "Brick Wall"
ENT.AutomaticFrameAdvance = true
ENT.Spawnable		= false
ENT.ResourceType = ""

function ENT:SetupDataTables()
	self:NetworkVar( "Int", 0, "Amount" )
	self:NetworkVar( "String", 0, "ResourceType" )
end