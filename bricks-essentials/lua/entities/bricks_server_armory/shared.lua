ENT.Type = "anim"
ENT.Base = "base_gmodentity"
 
ENT.PrintName		= "Armory"
ENT.Category		= "Bricks Server"
ENT.Author			= "Brick Wall"

ENT.Spawnable		= true

function ENT:SetupDataTables()
	self:NetworkVar( "Entity", 0, "Robber" )
	self:NetworkVar( "Int", 0, "MoneyValue" )
	self:NetworkVar( "Int", 1, "ShipmentValue" )
	self:NetworkVar( "Int", 2, "RobberyCooldown" )
	self:NetworkVar( "Int", 3, "UnlockTimer" )
	self:NetworkVar( "Int", 4, "FailCooldown" )
	self:NetworkVar( "Bool", 0, "Locked" )
end