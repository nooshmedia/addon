AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self:SetModel("models/2rek/brickwall/bwall_armory.mdl")

	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	
    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	
	self:GetPhysicsObject():EnableMotion( false )
	
	self:SetBodygroup( 1, 1 )
	self:LockArmory()
end

util.AddNetworkString( "BRS.Net.ArmoryUse" )
function ENT:Use( ply )
	if( (ply.BRS_ARMORY_COOLDOWN or 0) > CurTime() ) then return end
	
	ply.BRS_ARMORY_COOLDOWN = CurTime()+1

	if( (BRICKS_SERVER.CONFIG.ARMORY.RobberTeams or {})[ply:getJobTable().command] ) then
		if( not IsValid( self:GetRobber() ) and self:GetLocked() == true and CurTime() >= self:GetRobberyCooldown() and CurTime() >= self:GetFailCooldown() ) then
			local policeCount = 0
			for k, v in pairs( player.GetAll() ) do
				if( (BRICKS_SERVER.CONFIG.ARMORY.PoliceJobs or {})[(v:getJobTable() or {}).command or ""] ) then
					policeCount = policeCount+1
				end
			end
			
			if( policeCount >= BRICKS_SERVER.CONFIG.ARMORY["Police Requirement"] ) then
				self:StartRobbery( ply )
			else
				DarkRP.notify( ply, 1, 3, "There are not enough police, " .. BRICKS_SERVER.CONFIG.ARMORY["Police Requirement"] .. " police needed!" )
			end
		else
			DarkRP.notify( ply, 1, 3, "The armory is still on cooldown!" )
		end
	elseif( (BRICKS_SERVER.CONFIG.ARMORY.PoliceJobs or {})[ply:getJobTable().command] ) then
		net.Start( "BRS.Net.ArmoryUse" )
		net.Send( ply )
	end
end

function ENT:Think()
	if( IsValid( self:GetRobber() ) ) then
		if( self:GetRobber():GetPos():DistToSqr( self:GetPos() ) > 20000 ) then
			self:RobberyFail()
		elseif( not self:GetRobber():Alive() ) then
			self:RobberyFail()
		end
	end
	
	if( IsValid( self:GetRobber() ) and self:GetLocked() == true and CurTime() >= self:GetRobberyCooldown() ) then
		if( CurTime() >= self:GetUnlockTimer() ) then
			timer.Simple( 5, function() 
				if( IsValid( self ) ) then
					self:LockArmory()
				end
			end )
			self:RobberySuccess()
			self:UnlockArmory()
		end
	end
	
	if( CurTime() >= self:GetRobberyCooldown() and self:GetLocked() == true ) then
		if( (self:GetMoneyValue() == 0 and ((BRICKS_SERVER.CONFIG.ARMORY["Reward Money"] or {})[1] or 0) != 0) or (self:GetShipmentValue() == 0 and ((BRICKS_SERVER.CONFIG.ARMORY["Shipment Reward Amount"] or {})[1] or 0) != 0) ) then
			self:ResetContents()
			self:SetRobberyCooldown( 0 )
		end
	end
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

end

function ENT:RobberyFail()
	if( IsValid( self:GetRobber() ) ) then
		DarkRP.notify( self:GetRobber(), 1, 3, "Robbery failed!" )
	end
	
	self:SetRobber( nil )
	self:SetUnlockTimer( 0 )
	self:SetFailCooldown( CurTime()+BRICKS_SERVER.CONFIG.ARMORY["Fail Cooldown"] )
end

function ENT:RobberySuccess()
	if( IsValid( self:GetRobber() ) ) then
		self:GetRobber():addMoney( (self:GetMoneyValue() or 0) )
		if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "levelling" ) ) then
			self:GetRobber():AddExperience( BRICKS_SERVER.CONFIG.LEVELING["EXP Gained - Armory Robbery"], "ROBBERY" )
			DarkRP.notify( self:GetRobber(), 1, 10, "Robbery Successful: +" .. DarkRP.formatMoney(self:GetMoneyValue()) .. ", +" .. string.Comma(BRICKS_SERVER.CONFIG.LEVELING["EXP Gained - Armory Robbery"]) .. " EXP and +" .. self:GetShipmentValue() .. " shipments." )
		else
			DarkRP.notify( self:GetRobber(), 1, 10, "Robbery Successful:: +" .. DarkRP.formatMoney(self:GetMoneyValue()) .. ", +" .. self:GetShipmentValue() .. " shipments." )
		end
	
		for i = 1, self:GetShipmentValue() do
			local foundKey, shipmentName = table.Random( BRICKS_SERVER.CONFIG.ARMORY.RewardShipments )
			local found, foundKey = DarkRP.getShipmentByName( shipmentName )

			if( found ) then
				local crate = ents.Create(found.shipmentClass or "spawned_shipment")
				crate.SID = self:GetRobber().SID
				crate:Setowning_ent(self:GetRobber())
				crate:SetContents(foundKey,10)

				crate:SetPos(self:GetPos()+(self:GetForward()*30))
				crate.nodupe = true
				crate.ammoadd = found.spareammo
				crate.clip1 = found.clip1
				crate.clip2 = found.clip2
				crate:Spawn()
				crate:SetCollisionGroup( COLLISION_GROUP_DEBRIS_TRIGGER )
				crate:SetPlayer(self:GetRobber())
			end
		end
	end

	self:SetMoneyValue( 0 )
	self:SetShipmentValue( 0 )
	self:SetBodygroup( 1, 1 )
end

function ENT:LockArmory()
	self:SetLocked( true )
	self:SetUnlockTimer( 0 )
	self:SetRobberyCooldown( CurTime()+BRICKS_SERVER.CONFIG.ARMORY["Robbery Cooldown"] )
	self:DoMyAnimationThing( "close", 1 )
end

function ENT:UnlockArmory()
	self:SetRobber( nil )
	self:SetLocked( false )
	self:SetUnlockTimer( 0 )
	self:DoMyAnimationThing( "open", 1 )
	self:EmitSound( "ambient/materials/creaking.wav" )
end

function ENT:StartRobbery( robber )
	if( IsValid( self:GetRobber() ) or self:GetLocked() != true or CurTime() < self:GetRobberyCooldown() ) then return end

	self:SetRobber( robber )
	self:SetUnlockTimer( CurTime()+BRICKS_SERVER.CONFIG.ARMORY["Open Time"] )
end

function ENT:ResetContents()
	local MoneyValue = math.random( ((BRICKS_SERVER.CONFIG.ARMORY["Reward Money"] or {})[1] or 1), ((BRICKS_SERVER.CONFIG.ARMORY["Reward Money"] or {})[2] or 100) )
	self:SetMoneyValue( MoneyValue )
	
	local ShipmentValue = math.random(  ((BRICKS_SERVER.CONFIG.ARMORY["Shipment Reward Amount"] or {})[1] or 1), ((BRICKS_SERVER.CONFIG.ARMORY["Shipment Reward Amount"] or {})[2] or 3) )
	self:SetShipmentValue( ShipmentValue )
	
	self:SetBodygroup( 1, 0 )
end

--[[ POLICE FUNCTONS ]]--
util.AddNetworkString( "BRS.Net.ArmoryEquipItem" )
net.Receive( "BRS.Net.ArmoryEquipItem", function( len, ply )
	local ItemKey = net.ReadUInt( 8 )
	
	if( not ItemKey or not BRICKS_SERVER.CONFIG.ARMORY.Items[ItemKey] ) then return end
	if( not (BRICKS_SERVER.CONFIG.ARMORY.PoliceJobs or {})[RPExtraTeams[ply:Team()].command] ) then return end
	
	local itemTable = BRICKS_SERVER.CONFIG.ARMORY.Items[ItemKey]
	local itemTypeTable = BRICKS_SERVER.DEVCONFIG.ArmoryTypes[itemTable.Type or ""]

	if( not itemTypeTable or not itemTypeTable.GiveItem ) then return end

	if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "levelling" ) and itemTable.Level ) then
		if( ply:GetLevel() < itemTable.Level ) then
			DarkRP.notify( ply, 1, 5, "You are not the right level to equip this item!" )
			return
		end
	end

	if( itemTable.Group ) then
		if( not BRICKS_SERVER.Func.IsInGroup( ply, itemTable.Group ) ) then
			DarkRP.notify( ply, 1, 5, "You are not the right group to equip this item!" )
			return
		end
	end

	if( itemTable.Restrictions ) then
		if( not itemTable.Restrictions[RPExtraTeams[ply:Team()].command] ) then
			DarkRP.notify( ply, 1, 5, "You are not the right job to equip this item!" )
			return
		end
	end

	local giveItem, errorMsg = itemTypeTable.GiveItem( ply, itemTable.ReqInfo )
	
	if( giveItem == false ) then
		DarkRP.notify( ply, 1, 5, errorMsg or "Error equipping item!" )
	else
		DarkRP.notify( ply, 1, 5, "You have equipped " .. itemTable.Name .. " from the armory!" )
	end
end )

hook.Add( "canDropWeapon", "BRS.canDropWeapon_Armory", function( ply, wep )
	if( IsValid( ply ) ) then
		if( (BRICKS_SERVER.CONFIG.ARMORY.PoliceJobs or {})[RPExtraTeams[ply:Team()].command] ) then
			for k, v in pairs( BRICKS_SERVER.CONFIG.ARMORY.Items ) do
				if( v.Type == "Weapon" and wep:GetClass() == ((v.ReqInfo or {})[1] or "") ) then
					return false
				end
			end
		end
	end
end )