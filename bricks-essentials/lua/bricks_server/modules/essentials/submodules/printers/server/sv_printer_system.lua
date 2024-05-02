local playerMeta = FindMetaTable("Player")

util.AddNetworkString( "BRS.Net.SetPrinters" )
function playerMeta:SetPrinters( printersTable, nosave )
	if( not printersTable ) then return end

	net.Start( "BRS.Net.SetPrinters" )
		net.WriteTable( printersTable )
	net.Send( self )

	self.BRS_PRINTERS = (printersTable or {})

	if( not nosave ) then
		self:BRS_Essentials_SaveStat( "printers" )
	end
end

function playerMeta:GetPrinters()
	return (self.BRS_PRINTERS or {})
end

util.AddNetworkString( "BRS.Net.UnlockPrinter" )
net.Receive( "BRS.Net.UnlockPrinter", function( len, ply )
	local slotID = net.ReadUInt( 8 )

	if( not slotID ) then return end
	if( not BRICKS_SERVER.CONFIG.PRINTERS.PrinterSlots[slotID] ) then return end

	local slotTable = BRICKS_SERVER.CONFIG.PRINTERS.PrinterSlots[slotID]
	local plyPrinters = ply:GetPrinters()

	if( plyPrinters and plyPrinters[slotID] and plyPrinters[slotID][1] == true ) then return end
	
	if( slotTable.Price ) then
		if( ply:getDarkRPVar( "money" ) < slotTable.Price ) then
			DarkRP.notify( ply, 1, 5, "You don't have enough money to unlock this slot!" )
			return
		end
	end

	if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "levelling" ) and slotTable.Level ) then
		if( ply:GetLevel() < slotTable.Level ) then
			DarkRP.notify( ply, 1, 5, "You are not the right level to unlock this slot!" )
			return
		end
	end

	if( slotTable.Group ) then
		if( not BRICKS_SERVER.Func.IsInGroup( ply, slotTable.Group ) ) then
			DarkRP.notify( ply, 1, 5, "You are not the right group to unlock this slot!" )
			return
		end
	end

	if( slotTable.Price ) then
		ply:addMoney( -slotTable.Price )
		DarkRP.notify( ply, 1, 5, "You have unlocked printer slot " .. slotID .. " for " .. DarkRP.formatMoney( slotTable.Price ) .. "!" )
	else
		DarkRP.notify( ply, 1, 5, "You have unlocked printer slot " .. slotID .. "!" )
	end

	plyPrinters[slotID] = {
		[1] = true,
		[2] = 1,
		[3] = 1,
		[4] = 0
	}

	ply:SetPrinters( plyPrinters )
end )

BRS_ACTIVE_PRINTERS = BRS_ACTIVE_PRINTERS or {}
util.AddNetworkString( "BRS.Net.PlacePrinter" )
net.Receive( "BRS.Net.PlacePrinter", function( len, ply )
	local slotID = net.ReadUInt( 8 )

	if( not slotID ) then return end
	if( not BRICKS_SERVER.CONFIG.PRINTERS.PrinterSlots[slotID] ) then return end

	local slotTable = BRICKS_SERVER.CONFIG.PRINTERS.PrinterSlots[slotID]
	local plyPrinters = ply:GetPrinters()

	if( not plyPrinters or not plyPrinters[slotID] or plyPrinters[slotID][1] == false ) then return end

	if( plyPrinters[slotID][5] ) then
		if( os.time() >= (plyPrinters[slotID][5] or 0) ) then
			plyPrinters[slotID][5] = nil
			ply:SetPrinters( plyPrinters )
		else
			DarkRP.notify( ply, 1, 5, "You can't place a printer when it is on cooldown!" )
			return
		end
	end
	
	if( BRS_ACTIVE_PRINTERS and BRS_ACTIVE_PRINTERS[ply:SteamID64()] and BRS_ACTIVE_PRINTERS[ply:SteamID64()][slotID] and IsValid( BRS_ACTIVE_PRINTERS[ply:SteamID64()][slotID] ) ) then
		DarkRP.notify( ply, 1, 5, "This printer has already been placed, it must destroyed before replacing it!" )
		return
	end

	local printerEnt = ents.Create( "bricks_server_printer" )
	if ( !IsValid( printerEnt ) ) then 
		DarkRP.notify( ply, 1, 5, "There was an error when spawning this printer!" )
		return 
	end
	printerEnt:SetAngles( ply:GetAngles() )
	printerEnt:SetPos( ply:GetPos()+(ply:GetForward()*40)+(printerEnt:GetUp()*10) )
	printerEnt:Spawn()

	printerEnt:Setowning_ent( ply )
	printerEnt:SetPrinterTier( plyPrinters[slotID][2] or 1 )
	printerEnt:SetLevel( plyPrinters[slotID][3] or 0 )
	printerEnt:SetSlotID( slotID )

	BRS_ACTIVE_PRINTERS = BRS_ACTIVE_PRINTERS or {}
	BRS_ACTIVE_PRINTERS[ply:SteamID64()] = BRS_ACTIVE_PRINTERS[ply:SteamID64()] or {}
	BRS_ACTIVE_PRINTERS[ply:SteamID64()][slotID] = printerEnt
end )

util.AddNetworkString("BRS.Net.PrinterUpgrade")
net.Receive( "BRS.Net.PrinterUpgrade", function( len, ply )
	local slotID = net.ReadUInt( 8 )

	if( not slotID ) then return end
	if( not BRICKS_SERVER.CONFIG.PRINTERS.PrinterSlots[slotID] ) then return end

	local slotTable = BRICKS_SERVER.CONFIG.PRINTERS.PrinterSlots[slotID]
	local plyPrinters = ply:GetPrinters()

	if( not plyPrinters or not plyPrinters[slotID] or plyPrinters[slotID][1] == false ) then return end

	local newPrinterTier = (plyPrinters[slotID][2] or 1)+1
	if( BRICKS_SERVER.CONFIG.PRINTERS.Tiers[newPrinterTier] ) then
		local upgradeCost = (BRICKS_SERVER.CONFIG.PRINTERS.Tiers[newPrinterTier].UpgradeCost or 0)
		if( ply:getDarkRPVar( "money" ) >= upgradeCost ) then
			ply:addMoney( -upgradeCost )
			plyPrinters[slotID][2] = newPrinterTier

			if( BRS_ACTIVE_PRINTERS and BRS_ACTIVE_PRINTERS[ply:SteamID64()] and BRS_ACTIVE_PRINTERS[ply:SteamID64()][slotID] and IsValid( BRS_ACTIVE_PRINTERS[ply:SteamID64()][slotID] ) ) then
				BRS_ACTIVE_PRINTERS[ply:SteamID64()][slotID]:SetPrinterTier( plyPrinters[slotID][2] )
			end

			DarkRP.notify( ply, 0, 5, "Printer successfully upgraded to " .. (BRICKS_SERVER.CONFIG.PRINTERS.Tiers[plyPrinters[slotID][2]].Name or "ERROR") .. " tier for " .. DarkRP.formatMoney( upgradeCost ) .. "!" )
			ply:SetPrinters( plyPrinters )
		else
			DarkRP.notify( ply, 1, 5, "You don't have enough money to upgrade this printer!" )
		end
	end
end )

util.AddNetworkString( "BRS.Net.AdminUnlockPrinter" )
net.Receive( "BRS.Net.AdminUnlockPrinter", function( len, ply )
	if( not BRICKS_SERVER.Func.HasAdminAccess( ply ) ) then return end

	local victimID64 = net.ReadString()
	local slotID = net.ReadUInt( 8 )

	if( not victimID64 or not slotID ) then return end
	local requestedPly = player.GetBySteamID64( victimID64 )

	if( IsValid( requestedPly ) and BRICKS_SERVER.CONFIG.PRINTERS.PrinterSlots[slotID] ) then
		local slotTable = BRICKS_SERVER.CONFIG.PRINTERS.PrinterSlots[slotID]
		local victimPrinters = requestedPly:GetPrinters()

		victimPrinters[slotID] = {
			[1] = true,
			[2] = 1,
			[3] = 1,
			[4] = 0
		}
	
		requestedPly:SetPrinters( victimPrinters )

		ply:BRS():AdminSendInventory( requestedPly )

		DarkRP.notify( ply, 1, 5, "You have unlocked " .. requestedPly:Nick() .. "'s printer slot " .. slotID .. "!" )
		DarkRP.notify( requestedPly, 1, 5, "An admin has unlocked your printer slot " .. slotID .. "!" )
	else
		DarkRP.notify( ply, 1, 5, "Error unlocking printer slot!" )
	end
end )

util.AddNetworkString("BRS.Net.PrinterAdminUpgrade")
net.Receive( "BRS.Net.PrinterAdminUpgrade", function( len, ply )
	if( not BRICKS_SERVER.Func.HasAdminAccess( ply ) ) then return end

	local victimID64 = net.ReadString()
	local slotID = net.ReadUInt( 8 )

	if( not victimID64 or not slotID ) then return end
	local requestedPly = player.GetBySteamID64( victimID64 )

	if( IsValid( requestedPly ) and BRICKS_SERVER.CONFIG.PRINTERS.PrinterSlots[slotID] ) then
		local slotTable = BRICKS_SERVER.CONFIG.PRINTERS.PrinterSlots[slotID]
		local victimPrinters = requestedPly:GetPrinters()
	
		if( not victimPrinters or not victimPrinters[slotID] or victimPrinters[slotID][1] == false ) then return end
	
		local newPrinterTier = (victimPrinters[slotID][2] or 1)+1
		if( BRICKS_SERVER.CONFIG.PRINTERS.Tiers[newPrinterTier] ) then
			victimPrinters[slotID][2] = newPrinterTier

			if( BRS_ACTIVE_PRINTERS and BRS_ACTIVE_PRINTERS[victimID64] and BRS_ACTIVE_PRINTERS[victimID64][slotID] and IsValid( BRS_ACTIVE_PRINTERS[victimID64][slotID] ) ) then
				BRS_ACTIVE_PRINTERS[victimID64][slotID]:SetPrinterTier( victimPrinters[slotID][2] )
			end

			requestedPly:SetPrinters( victimPrinters )

			ply:BRS():AdminSendInventory( requestedPly )

			DarkRP.notify( ply, 0, 5, "You have upgraded " .. requestedPly:Nick() .. "'s printer to " .. (BRICKS_SERVER.CONFIG.PRINTERS.Tiers[victimPrinters[slotID][2]].Name or "ERROR") .. " tier!" )
			DarkRP.notify( requestedPly, 0, 5, "Printer upgraded to " .. (BRICKS_SERVER.CONFIG.PRINTERS.Tiers[victimPrinters[slotID][2]].Name or "ERROR") .. " tier by an admin!" )
		end
	else
		DarkRP.notify( ply, 1, 5, "Error upgrading printer!" )
	end
end )

util.AddNetworkString("BRS.Net.PrinterAdminSetLevel")
net.Receive( "BRS.Net.PrinterAdminSetLevel", function( len, ply )
	if( not BRICKS_SERVER.Func.HasAdminAccess( ply ) ) then return end

	local victimID64 = net.ReadString()
	local slotID = net.ReadUInt( 8 )
	local newLevel = math.Clamp( net.ReadUInt( 32 ), 1, BRICKS_SERVER.CONFIG.PRINTERS["Max Level"] )

	if( not victimID64 or not slotID or not newLevel ) then return end
	local requestedPly = player.GetBySteamID64( victimID64 )

	if( IsValid( requestedPly ) and BRICKS_SERVER.CONFIG.PRINTERS.PrinterSlots[slotID] ) then
		local slotTable = BRICKS_SERVER.CONFIG.PRINTERS.PrinterSlots[slotID]
		local victimPrinters = requestedPly:GetPrinters()
	
		if( not victimPrinters or not victimPrinters[slotID] or victimPrinters[slotID][1] == false ) then return end
	
		victimPrinters[slotID][3] = newLevel

		if( BRS_ACTIVE_PRINTERS and BRS_ACTIVE_PRINTERS[victimID64] and BRS_ACTIVE_PRINTERS[victimID64][slotID] and IsValid( BRS_ACTIVE_PRINTERS[victimID64][slotID] ) ) then
			BRS_ACTIVE_PRINTERS[victimID64][slotID]:SetLevel( newLevel )
		end

		requestedPly:SetPrinters( victimPrinters )

		ply:BRS():AdminSendInventory( requestedPly )

		DarkRP.notify( ply, 0, 5, "You have set " .. requestedPly:Nick() .. "'s printer slot " .. slotID .. "'s level to " .. newLevel .. " !" )
		DarkRP.notify( requestedPly, 0, 5, "Your printer slot " .. slotID .. "'s level has been set to " .. newLevel .. " by an admin!" )
	else
		DarkRP.notify( ply, 1, 5, "Error setting printer level!" )
	end
end )

util.AddNetworkString("BRS.Net.PrinterAdminRemove")
net.Receive( "BRS.Net.PrinterAdminRemove", function( len, ply )
	if( not BRICKS_SERVER.Func.HasAdminAccess( ply ) ) then return end

	local victimID64 = net.ReadString()
	local slotID = net.ReadUInt( 8 )

	if( not victimID64 or not slotID ) then return end
	local requestedPly = player.GetBySteamID64( victimID64 )

	if( IsValid( requestedPly ) and BRICKS_SERVER.CONFIG.PRINTERS.PrinterSlots[slotID] ) then
		local slotTable = BRICKS_SERVER.CONFIG.PRINTERS.PrinterSlots[slotID]
		local victimPrinters = requestedPly:GetPrinters()
	
		if( not victimPrinters or not victimPrinters[slotID] or victimPrinters[slotID][1] == false ) then return end

		victimPrinters[slotID] = nil

		if( BRS_ACTIVE_PRINTERS and BRS_ACTIVE_PRINTERS[victimID64] and BRS_ACTIVE_PRINTERS[victimID64][slotID] and IsValid( BRS_ACTIVE_PRINTERS[victimID64][slotID] ) ) then
			BRS_ACTIVE_PRINTERS[victimID64][slotID]:Remove()
		end

		requestedPly:SetPrinters( victimPrinters )

		ply:BRS():AdminSendInventory( requestedPly )

		DarkRP.notify( ply, 1, 5, "You have removed " .. requestedPly:Nick() .. "'s printer slot " .. slotID .. "!" )
		DarkRP.notify( requestedPly, 1, 5, "An admin has removed your printer slot " .. slotID .. "!" )
	else
		DarkRP.notify( ply, 1, 5, "Error removing printer!" )
	end
end )