
ENT.Type = "anim"
ENT.Base = "base_gmodentity"
 
ENT.PrintName		= "Printer"
ENT.Category		= "Bricks Server"
ENT.Author			= "Brick Wall"
ENT.AutomaticFrameAdvance = true
ENT.Spawnable		= true

function ENT:SetupDataTables()
	self:NetworkVar( "Entity", 0, "owning_ent" )
	self:NetworkVar( "Int", 0, "Holding" )
	self:NetworkVar( "Int", 1, "Ink" )
	self:NetworkVar( "Int", 2, "Tier" )
	self:NetworkVar( "Int", 3, "Level" )
	self:NetworkVar( "Int", 4, "SlotID" )
	if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "levelling" ) ) then
		self:NetworkVar( "Int", 5, "PlayerEXPStored" )
	end

	self:NetworkVar( "Bool", 0, "Overheated" )
	self:NetworkVar( "Bool", 1, "Status" )
end