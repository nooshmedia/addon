AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self:SetModel("models/2rek/brickwall/bwall_vault_doors.mdl")

	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	
    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	
	self:GetPhysicsObject():EnableMotion( false )
	
	self:SetRobber( nil )
	self:SetMoneyBags( BRICKS_SERVER.CONFIG.BANKVAULT["Money Bags"] )
	self:SetRobberyCooldown( CurTime()+BRICKS_SERVER.CONFIG.BANKVAULT["Robbery Cooldown"] )
	self:SetAlarmCooldown( 0 )
	self:SetUnlockTimer( 0 )
	self:SetLocked( true )
	self:SetAlarm( false )
end

util.AddNetworkString( "BRS.Net.BankUse" )
function ENT:Use( ply )
	if( IsValid( ply ) ) then
		if( CurTime() < self:GetUseCooldown() ) then return end
		
		self:SetUseCooldown( CurTime()+1 )
		
		if( IsValid( self:GetRobber() ) ) then return end
		
		if( (BRICKS_SERVER.CONFIG.BANKVAULT.RobberTeams or {})[RPExtraTeams[ply:Team()].command] ) then
			local policeCount = 0
			for k, v in pairs( player.GetAll() ) do
				if( (BRICKS_SERVER.CONFIG.ARMORY.PoliceJobs or {})[(v:getJobTable() or {}).command or ""] ) then
					policeCount = policeCount+1
				end
			end

			if( self:GetLocked() == true and CurTime() >= self:GetRobberyCooldown() and policeCount >= BRICKS_SERVER.CONFIG.BANKVAULT["Police Requirement"] and self:GetAlarm() == false ) then
				self:SetRobber( ply )
				
				net.Start( "BRS.Net.BankUse" )
					net.WriteEntity( self )
				net.Send( ply )
			elseif( self:GetLocked() == false and self:GetMoneyBags() > 0 ) then
				self:SpawnMoneyBag()
			elseif( self:GetLocked() == true and CurTime() >= self:GetRobberyCooldown() and policeCount < BRICKS_SERVER.CONFIG.BANKVAULT["Police Requirement"] and self:GetAlarm() == false ) then
				DarkRP.notify( ply, 1, 3, "There are not enough police online, needs " .. BRICKS_SERVER.CONFIG.BANKVAULT["Police Requirement"] .. "!" )
			end
		end
	end
end

function ENT:SpawnMoneyBag()
	if( self:GetMoneyBags() <= 0 ) then return end

	self:SetMoneyBags( self:GetMoneyBags()-1 )
	
	local bankbag = ents.Create( "bricks_server_bank_bag" )
	if ( !IsValid( bankbag ) ) then return end
	bankbag:SetPos( self:GetPos() + self:GetForward()*30 + Vector( 0, 0, 20 ) )
	bankbag:SetAngles( self:GetAngles() )
	bankbag:Spawn()
end

function ENT:LockVault()
	self:SetLocked( true )
	self:SetUnlockTimer( 0 )
	self:SetRobberyCooldown( CurTime()+BRICKS_SERVER.CONFIG.BANKVAULT["Robbery Cooldown"] )
	self:DoMyAnimationThing( "close", 1 )
	self:SetMoneyBags( BRICKS_SERVER.CONFIG.BANKVAULT["Money Bags"] )
end

function ENT:UnlockVault()
	self:SetRobber( nil )
	self:SetLocked( false )
	self:SetUnlockTimer( CurTime()+BRICKS_SERVER.CONFIG.BANKVAULT["Open Time"] )
	self:DoMyAnimationThing( "open", 1 )
	self:EmitSound( "ambient/materials/creaking.wav" )
end

function ENT:TripAlarm()
	if( BRICKS_SERVER.CONFIG.BANKVAULT["Alarm Duration"] <= 0 ) then return end

	self:SetAlarmCooldown( CurTime()+BRICKS_SERVER.CONFIG.BANKVAULT["Alarm Duration"] )
	self:SetAlarm( true )
	
    self.AlarmSound = CreateSound( self, Sound( "ambient/alarms/alarm1.wav" ) )
    self.AlarmSound:SetSoundLevel( 65 )
    self.AlarmSound:PlayEx( 1, 100 )
end

function ENT:StopAlarm()
	if( self.AlarmSound ) then
		self.AlarmSound:Stop()
		self.AlarmSound = nil
	end
	self:SetAlarm( false )
end

function ENT:Think()
	if( self:GetLocked() == false ) then
		if( CurTime() >= self:GetUnlockTimer() ) then
			self:LockVault()
		end
	else
		
	end	
	
	if( self:GetAlarm() == true ) then
		if( CurTime() >= self:GetAlarmCooldown() ) then
			self:StopAlarm()
		end
	else
		
	end
	
	if( IsValid( self:GetRobber() ) ) then
		if( self:GetRobber():GetPos():DistToSqr( self:GetPos() ) > 10000 ) then
			self:SetRobber( nil )
		elseif( not self:GetRobber():Alive() ) then
			self:SetRobber( nil )
		end
	end
	
	self:NextThink( CurTime() ) 
	return true
end

function ENT:OnTakeDamage( dmgInfo )

end

function ENT:DoMyAnimationThing( SequenceName, PlaybackRate )
	PlaybackRate = PlaybackRate or 1
	local sequenceID, sequenceDuration = self:LookupSequence( SequenceName )
	if (sequenceID != -1) then
		
		self:ResetSequence(sequenceID)
		self:SetPlaybackRate(PlaybackRate)
		self:ResetSequenceInfo()
		self:SetCycle(0)
		return CurTime() + sequenceDuration * (1 / PlaybackRate) 
	else
		return CurTime()
	end
end

function ENT:OnRemove()
	if( self.AlarmSound ) then
		self.AlarmSound:Stop()
	end
end

util.AddNetworkString( "BRS.Net.BankFail" )
net.Receive( "BRS.Net.BankFail", function( len, ply ) 
	local ReceivedEnt = net.ReadEntity()
	
	if( not ReceivedEnt ) then return end
	if( not IsValid( ReceivedEnt ) ) then return end
	if( ReceivedEnt:GetClass() != "bricks_server_bank_vault" ) then return end
	
	if( not IsValid( ReceivedEnt:GetRobber() ) ) then return end
	if( ReceivedEnt:GetRobber() != ply ) then return end
	
	ReceivedEnt:SetRobber( nil )
	
	if( ReceivedEnt:GetAlarm() == false and ReceivedEnt:GetLocked() == true ) then
		ReceivedEnt:TripAlarm()
	end
end )

util.AddNetworkString( "BRS.Net.BankUnlock" )
net.Receive( "BRS.Net.BankUnlock", function( len, ply ) 
	local ReceivedEnt = net.ReadEntity()
	
	if( not ReceivedEnt ) then return end
	if( not IsValid( ReceivedEnt ) ) then return end
	if( ReceivedEnt:GetClass() != "bricks_server_bank_vault" ) then return end
	
	if( not IsValid( ReceivedEnt:GetRobber() ) ) then return end
	if( ReceivedEnt:GetRobber() != ply ) then return end
	
	ReceivedEnt:UnlockVault()
end )

util.AddNetworkString( "BRS.Net.BankConvertMoney" )
net.Receive( "BRS.Net.BankConvertMoney", function( len, ply )
	local NPCEnt = net.ReadEntity()

	if( not IsValid( NPCEnt ) or NPCEnt:GetClass() != "bricks_server_npc" ) then return end

	local NPCTable = BRICKS_SERVER.CONFIG.NPCS[NPCEnt:GetNPCKeyVar() or 0]
	if( not NPCTable or (NPCTable.Type or "") != "Money Launderer" ) then return end

	if( ply:GetPos():DistToSqr( NPCEnt:GetPos() ) > 10000 ) then
		DarkRP.notify( ply, 1, 5, "BRICKS SERVER ERROR: You are too far away!" )
		return
	end

	local moneyCarrying = ply:GetNW2Int( "BRS_MoneyBagAmount", 0 )
	if( moneyCarrying > 0 ) then
		local convertedMoney = math.ceil( moneyCarrying*NPCEnt:GetNW2Float( "BRS_Launderer_Multiplier", 1 ) )
		ply:SetNW2Int( "BRS_MoneyBagAmount", 0 )
		ply:addMoney( convertedMoney )

		DarkRP.notify( ply, 1, 5, "You received " .. DarkRP.formatMoney( convertedMoney ) .. " from laundering money!" )
	else
		DarkRP.notify( ply, 1, 5, "You aren't carrying any money bags!" )
	end
end )