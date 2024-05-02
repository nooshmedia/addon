-- Level notifications
util.AddNetworkString("BRS.Net.LevelNotify")
function BRICKS_SERVER.Func.AddLvlNotify( ply, levelOrExp, amount )
	net.Start( "BRS.Net.LevelNotify" )
		net.WriteBool( levelOrExp )
		net.WriteUInt( amount, 32 )
	net.Send( ply )
end

local playerMeta = FindMetaTable("Player")

util.AddNetworkString("BRS.Net.SetExperience")
util.AddNetworkString("BRS.Net.SetLevel")
util.AddNetworkString("BRS.Net.SendLevelupEffect")

-- Experience functions
function playerMeta:SetExperience(amount, nosave)
	local finalAmount = math.max( (amount or 0), 0 )

	net.Start( "BRS.Net.SetExperience" )
		net.WriteUInt( finalAmount, 32 )
	net.Send( self )

	self.BRS_EXPERIENCE = finalAmount

	if( not nosave ) then
		self:BRS_Essentials_SaveStat( "experience" )
	end
end

function playerMeta:CheckLevelUp()
	if( self:GetLevel() < BRICKS_SERVER.CONFIG.LEVELING["Max Level"] ) then
		if( BRICKS_SERVER.Func.GetCurLevelExp( self ) >= BRICKS_SERVER.Func.GetExpToLevel( self:GetLevel(), self:GetLevel()+1 ) ) then
			self:AddLevel( 1 )
			self:CheckLevelUp()

			net.Start( "BRS.Net.SendLevelupEffect" )
			net.Send( self )
		end
	end
end

function playerMeta:AddExperience( amount, reason )
	if( (amount or 0) <= 0 ) then return end

	if( self:GetNW2Int( "brs_experience_booster", 1 ) > 1 ) then
		amount = amount*self:GetNW2Int( "brs_experience_booster", 1 )
	end

	self:SetExperience( self:GetExperience() + amount )
	BRICKS_SERVER.Func.AddLvlNotify( self, false, amount )
	self:CheckLevelUp()
	
	if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "logging" ) ) then
		self:BRS_AddLog( "Experience", { reason, amount } )
	end

	hook.Run( "BricksServerBuiltInHooks_ExperienceIncrease", self, amount, reason )
end

function playerMeta:TakeExperience( amount, reason )
	if( not ( ( self:GetExperience() ) <= 0 and self:GetLevel() <= 0 )) then
		if( ( self:GetExperience() - amount ) < 0 and self:GetLevel() > 0 ) then
			BRICKS_SERVER.Func.AddLvlNotify( self, false, -amount )
			self:SetExperience( self:GetExperience() - amount )
			self:SetExperience( (BRICKS_SERVER.CONFIG.LEVELING["Original EXP Required"]*(BRICKS_SERVER.CONFIG.LEVELING["EXP Required Increase"]^(self:GetLevel()-1) ))+self:GetExperience() )
			self:TakeLevel( 1 )
		elseif( ( self:GetExperience() - amount ) > 0 ) then
			BRICKS_SERVER.Func.AddLvlNotify( self, false, -amount )
			self:SetExperience( math.Clamp(self:GetExperience() - amount, 0, BRICKS_SERVER.CONFIG.LEVELING["Original EXP Required"]*(BRICKS_SERVER.CONFIG.LEVELING["EXP Required Increase"]^(self:GetLevel()) ) ) )
		elseif( ( self:GetExperience() - amount ) <= 0 and self:GetLevel() == 0 ) then
			BRICKS_SERVER.Func.AddLvlNotify( self, false, self:GetExperience() )
			self:SetExperience( math.Clamp(self:GetExperience() - amount, 0, BRICKS_SERVER.CONFIG.LEVELING["Original EXP Required"]*(BRICKS_SERVER.CONFIG.LEVELING["EXP Required Increase"]^(self:GetLevel()) ) ) )
		end
	end
end

function playerMeta:GetExperience()
	return (self.BRS_EXPERIENCE or 0)
end

-- Level functions
function playerMeta:SetLevel( amount, nosave )
	if( amount == nil ) then return end
	
	local newLevel = math.Clamp( amount, 0, BRICKS_SERVER.CONFIG.LEVELING["Max Level"] )

	net.Start( "BRS.Net.SetLevel" )
		net.WriteUInt( newLevel, 32 )
	net.Send( self )

	self.BRS_LEVEL = newLevel
	if( not nosave ) then
		self:BRS_Essentials_SaveStat( "level" )
	end
end

function playerMeta:AddLevel(amount)
	self:SetLevel(self:GetLevel() + amount)
	BRICKS_SERVER.Func.AddLvlNotify( self, true, amount )
	
	hook.Run( "BricksServerBuiltInHooks_LevelUp", self, amount )
end

function playerMeta:TakeLevel(amount)
	self:SetLevel( self:GetLevel() - amount )
	BRICKS_SERVER.Func.AddLvlNotify( self, true, -amount )
end

function playerMeta:GetLevel()
	return (self.BRS_LEVEL or 0)
end

concommand.Add( "setlevel", function( ply, cmd, args )
	if( IsValid( ply ) and not BRICKS_SERVER.Func.HasAdminAccess( ply ) ) then return end

	if( not args[1] or not args[2] or not isnumber( tonumber( args[2] ) ) ) then return end

	local victimPly = player.GetBySteamID64( args[1] )
	if( not IsValid( victimPly ) or not victimPly:IsPlayer() ) then return end

	local newLevel = math.Clamp( tonumber( args[2] ), 0, BRICKS_SERVER.CONFIG.LEVELING["Max Level"] )

	victimPly:SetLevel( newLevel )
	victimPly:SetExperience( BRICKS_SERVER.Func.GetExpToLevel( 0, newLevel ) )
	
	DarkRP.notify( ply, 1, 5, "Set " .. victimPly:Nick() .. "'s level to " .. newLevel )
	DarkRP.notify( victimPly, 1, 5, "An admin has set your level to " .. newLevel )
end )

concommand.Add( "addexperience", function( ply, cmd, args )
	if( IsValid( ply ) and not BRICKS_SERVER.Func.HasAdminAccess( ply ) ) then return end

	if( not args[1] or not args[2] or not isnumber( tonumber( args[2] ) ) ) then return end

	local victimPly = player.GetBySteamID64( args[1] )
	if( not IsValid( victimPly ) or not victimPly:IsPlayer() ) then return end

	if( not IsValid( victimPly ) or not victimPly:IsPlayer() ) then return end

	local experience = tonumber( args[2] )

	victimPly:AddExperience( experience, "Admin" )
	
	DarkRP.notify( ply, 1, 5, "Given " .. victimPly:Nick() .. " " .. string.Comma( experience ) .. " EXP!" )
	DarkRP.notify( victimPly, 1, 5, "An admin has given you " .. string.Comma( experience ) .. " EXP!" )
end )