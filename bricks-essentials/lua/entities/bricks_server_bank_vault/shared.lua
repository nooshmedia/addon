ENT.Type = "anim"
ENT.Base = "base_gmodentity"
 
ENT.PrintName		= "Bank Vault"
ENT.Category		= "Bricks Server"
ENT.Author			= "Brick Wall"

ENT.Spawnable		= true
ENT.AutomaticFrameAdvance = true

function ENT:SetupDataTables()
	self:NetworkVar( "Entity", 0, "Robber" )
	self:NetworkVar( "Int", 0, "MoneyBags" )
	self:NetworkVar( "Int", 1, "RobberyCooldown" )
	self:NetworkVar( "Int", 2, "AlarmCooldown" )
	self:NetworkVar( "Int", 3, "UnlockTimer" )
	self:NetworkVar( "Int", 4, "UseCooldown" )
	self:NetworkVar( "Bool", 0, "Locked" )
	self:NetworkVar( "Bool", 1, "Alarm" )
end