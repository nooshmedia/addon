AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:StartPrinting()
	self:DoMyAnimationThing( "print", 1 )
	self:SetSkin( 1 )

	local Speed = BRICKS_SERVER.CONFIG.PRINTERS.Tiers[self:GetTier() or 1].PrintSpeed
	timer.Create( tostring( self ) .. "_PrinterTimer", Speed, 0, function()
		if( IsValid( self ) ) then
			local StorageAmount = BRICKS_SERVER.CONFIG.PRINTERS.Tiers[self:GetTier() or 1].MoneyStorage

			self:SetHolding( math.Clamp( self:GetHolding()+(BRICKS_SERVER.CONFIG.PRINTERS.Tiers[self:GetTier() or 1].PrintAmount*(1+(BRICKS_SERVER.CONFIG.PRINTERS["Money Increase Per Level"]*self:GetLevel()))), 0, StorageAmount ) )
			
			self:SetInk( math.Clamp( self:GetInk()-BRICKS_SERVER.CONFIG.PRINTERS["Ink Lost Per Print"], 0, BRICKS_SERVER.CONFIG.PRINTERS.Tiers[self:GetTier() or 1].MaxInk ) )

			self:AddExperience( BRICKS_SERVER.CONFIG.PRINTERS["Printer EXP Per Print"] )

			if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "levelling" ) ) then
				self:SetPlayerEXPStored( (self:GetPlayerEXPStored() or 0)+(BRICKS_SERVER.CONFIG.LEVELING["EXP Gained - Money Printing"] or 0) )
			end
		else
			timer.Remove( tostring( self ) .. "_PrinterTimer" )
		end
	end )
end

function ENT:Initialize()
	self:SetModel("models/2rek/brickwall/bwall_printer.mdl")

	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	
	self:SetTier( 1 )
	self:SetHolding( 0 )
	self:SetHealth( BRICKS_SERVER.CONFIG.PRINTERS.Tiers[self:GetTier() or 1].Health )
	self:SetInk( BRICKS_SERVER.CONFIG.PRINTERS.Tiers[self:GetTier() or 1].MaxInk )
	
	self:SetOverheated( false )
	self:SetStatus( true )
	
    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	
	self:SetColor( BRICKS_SERVER.CONFIG.PRINTERS.Tiers[self:GetTier() or 1].ModelColor )
	
    self.sound = CreateSound(self, Sound("ambient/levels/labs/equipment_printer_loop1.wav"))
    self.sound:SetSoundLevel(52)
    self.sound:PlayEx(1, 100)
end

function ENT:Use( ply )
	if( IsValid( ply ) ) then
		if( self:GetHolding() > 0 ) then
			ply:addMoney( self:GetHolding() )
			DarkRP.notify( ply, 1, 4, "You withdrew " .. DarkRP.formatMoney( self:GetHolding() ) .. " from a printer!" )
			self:SetHolding( 0 )

			if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "levelling" ) and (self:GetPlayerEXPStored() or 0) > 0 ) then
				ply:AddExperience( (self:GetPlayerEXPStored() or 0), "Printing" )
				self:SetPlayerEXPStored( 0 )
			end
		end
	end
end

function ENT:Think()
	local StorageAmount = BRICKS_SERVER.CONFIG.PRINTERS.Tiers[self:GetTier() or 1].MoneyStorage

	if( timer.Exists( tostring( self ) .. "_PrinterTimer" ) ) then
		if( self:GetInk() <= 0 or self:GetHolding() >= StorageAmount ) then
			if( self:GetStatus() == true ) then
				timer.Pause( tostring( self ) .. "_PrinterTimer" )
				self:DoMyAnimationThing( "idle", 1 )
				self:SetSkin( 0 )
				self:SetStatus( false )
			end
		else
			if( self:GetStatus() != true ) then
				timer.UnPause( tostring( self ) .. "_PrinterTimer" )
				self:DoMyAnimationThing( "print", 1 )
				self:SetSkin( 1 )
				self:SetStatus( true )
			end
		end
	elseif( BRICKS_SERVER.CONFIG.PRINTERS.Tiers[self:GetTier() or 0] ) then
		self:StartPrinting()
		self:SetStatus( true )
	end
	
	if( self:GetInk() <= 0 or self:GetHolding() >= StorageAmount ) then
		if( self.sound ) then
			self.sound:Stop()
			self.sound = nil
		end
	else
		if( not self.sound ) then
			self.sound = CreateSound(self, Sound("ambient/levels/labs/equipment_printer_loop1.wav"))
			self.sound:SetSoundLevel(52)
			self.sound:PlayEx(1, 100)
		end
	end

	self:NextThink( CurTime() )
	return true
end

function ENT:OnTakeDamage( dmgInfo )
	self:SetHealth( math.Clamp( self:Health()-dmgInfo:GetDamage(), 0, BRICKS_SERVER.CONFIG.PRINTERS.Tiers[self:GetTier() or 1].Health ) )
	if( self:Health() <= 0 ) then
		self:Overheat()
	end
end

function ENT:Overheat()
	if( self:GetOverheated() != true ) then
		self:SetOverheated( true )
		self:Ignite( 2 )

		timer.Simple( 2, function()
			if( IsValid( self ) ) then
				local ply = self:Getowning_ent()

				local vPoint = self:GetPos()
				local effectdata = EffectData()
				effectdata:SetStart(vPoint)
				effectdata:SetOrigin(vPoint)
				effectdata:SetScale(1)
				util.Effect("Explosion", effectdata)
				DarkRP.notify( ply, 1, 4, DarkRP.getPhrase("money_printer_exploded") )
				self:Remove()

				if( IsValid( ply ) ) then
					local printers = ply:GetPrinters()

					local printerSlot = printers[self:GetSlotID()]
					if( printerSlot and printerSlot[1] == true ) then
						printerSlot[5] = os.time()+BRICKS_SERVER.CONFIG.PRINTERS["Replace Cooldown"]

						ply:SetPrinters( printers )
					end
				end
			end
		end )
	end
end

function ENT:UpgradePrinter()
	if( self:GetTier() < #BRICKS_SERVER.CONFIG.PRINTERS.Tiers and BRICKS_SERVER.CONFIG.PRINTERS.Tiers[self:GetTier()] ) then
		self:SetTier( (self:GetTier() or 0)+1 )
		self:SetHealth( BRICKS_SERVER.CONFIG.PRINTERS.Tiers[self:GetTier() or 1].Health )
		self:SetColor( BRICKS_SERVER.CONFIG.PRINTERS.Tiers[self:GetTier() or 1].ModelColor )

		if( timer.Exists( tostring( self ) .. "_PrinterTimer" ) ) then
			timer.Remove( tostring( self ) .. "_PrinterTimer" )
		end
	end
end

function ENT:SetPrinterTier( tier )
	if( BRICKS_SERVER.CONFIG.PRINTERS.Tiers[tier] ) then
		self:SetTier( tier )
		self:SetHealth( BRICKS_SERVER.CONFIG.PRINTERS.Tiers[tier].Health )
		self:SetColor( BRICKS_SERVER.CONFIG.PRINTERS.Tiers[tier].ModelColor )

		if( timer.Exists( tostring( self ) .. "_PrinterTimer" ) ) then
			timer.Remove( tostring( self ) .. "_PrinterTimer" )
		end
	end
end

function ENT:AddExperience( amount )
	if( not IsValid( self:Getowning_ent() ) ) then return end
	local ply = self:Getowning_ent()

	if( not BRICKS_SERVER.CONFIG.PRINTERS.PrinterSlots[self:GetSlotID()] ) then return end

	local slotTable = BRICKS_SERVER.CONFIG.PRINTERS.PrinterSlots[self:GetSlotID()]
	local plyPrinters = ply:GetPrinters()

	if( not plyPrinters or not plyPrinters[self:GetSlotID()] or plyPrinters[self:GetSlotID()][1] == false ) then return end
	
	if( not BRS_ACTIVE_PRINTERS or not BRS_ACTIVE_PRINTERS[ply:SteamID64()] or not BRS_ACTIVE_PRINTERS[ply:SteamID64()][self:GetSlotID()] or not IsValid( BRS_ACTIVE_PRINTERS[ply:SteamID64()][self:GetSlotID()] ) ) then return end

	if( (plyPrinters[self:GetSlotID()][3] or 1) < BRICKS_SERVER.CONFIG.PRINTERS["Max Level"] ) then
		if( ply:GetNW2Int( "brs_printerexp_booster", 1 ) > 1 ) then
			amount = amount*ply:GetNW2Int( "brs_printerexp_booster", 1 )
		end

		plyPrinters[self:GetSlotID()][4] = (plyPrinters[self:GetSlotID()][4] or 0)+amount

		if( plyPrinters[self:GetSlotID()][4] >= BRICKS_SERVER.Func.GetPrinterExpToLevel( (plyPrinters[self:GetSlotID()][3] or 1), (plyPrinters[self:GetSlotID()][3] or 1)+1 ) ) then
			plyPrinters[self:GetSlotID()][3] = math.Clamp( (plyPrinters[self:GetSlotID()][3] or 1)+1, 0, BRICKS_SERVER.CONFIG.PRINTERS["Max Level"] )
			self:SetLevel( plyPrinters[self:GetSlotID()][3] )
			plyPrinters[self:GetSlotID()][4] = 0
		end

		ply:SetPrinters( plyPrinters )
	end
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
		MsgN("ERROR: Didn't find a sequence by the name of ", SequenceName)
		return CurTime()
	end
end

function ENT:SpawnFunction( ply, tr, ClassName )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 10
	local SpawnAng = ply:EyeAngles()
	SpawnAng.p = 0
	SpawnAng.y = SpawnAng.y + 180
	
	local ent = ents.Create( ClassName )
	ent:SetPos( SpawnPos )
	ent:SetAngles( SpawnAng+Angle( 0, 180, 0 ) )
	ent:Spawn()
	ent:Activate()
	
	return ent
	
end

function ENT:OnRemove()
	if( self.sound ) then
		self.sound:Stop()
	end

	if( timer.Exists( tostring( self ) .. "_PrinterTimer" ) ) then
		timer.Remove( tostring( self ) .. "_PrinterTimer" )
	end
end

function ENT:StartTouch( Toucher )
	if( not IsValid( Toucher ) ) then return end
	
	if( Toucher:GetClass() == "bricks_server_repair" ) then
		if( self:Health() < BRICKS_SERVER.CONFIG.PRINTERS.Tiers[self:GetTier() or 1].Health ) then
			Toucher:Remove()
			self:SetHealth( BRICKS_SERVER.CONFIG.PRINTERS.Tiers[self:GetTier() or 1].Health )
		end	
	elseif( Toucher:GetClass() == "bricks_server_ink" ) then
		if( self:GetInk() < BRICKS_SERVER.CONFIG.PRINTERS.Tiers[self:GetTier() or 1].MaxInk ) then
			Toucher:Remove()
			self:SetInk( BRICKS_SERVER.CONFIG.PRINTERS.Tiers[self:GetTier() or 1].MaxInk )
		end
	end
end

function ENT:AcceptInput(ply, caller)

end

hook.Add( "PlayerDisconnected", "BRS.PlayerDisconnected_Printers", function( ply )
	for k, v in pairs( ents.FindByClass( "bricks_server_printer" ) ) do
		if( IsValid( v ) and v:Getowning_ent() == ply ) then
			v:Remove()
		end
	end
end )