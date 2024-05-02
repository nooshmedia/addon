util.AddNetworkString( "BRS.Net.OpenMarketplace" )

local playerMeta = FindMetaTable("Player")

util.AddNetworkString( "BRS.Net.UpdateMarketplace" )
function playerMeta:UpdateMarketplace()
	net.Start( "BRS.Net.UpdateMarketplace" )
		net.WriteTable( BRS_MARKETPLACE or {} )
	net.Send( self )
end

function BRICKS_SERVER.Func.UpdateMarketplaceEntry( marketKey, key, value, insert )
	if( BRS_MARKETPLACE[marketKey] ) then
		if( not insert ) then
			BRS_MARKETPLACE[marketKey][key] = value
		end

		if( BRICKS_SERVER.ESSENTIALS.LUACFG.UseMySQL != true ) then
			if( not file.Exists( "bricks_server/marketplace", "DATA" ) ) then
				file.CreateDir( "bricks_server/marketplace" )
			end

			file.Write( "bricks_server/marketplace/" .. marketKey .. ".txt", util.TableToJSON( BRS_MARKETPLACE[marketKey] ) )
		else
			if( not insert ) then
				local keysToKeys = { "amount", "currentbid", "time", "starttime", "itemdata", "owner", "bidders", "ownercollected", "winnercollected" }
				if( not keysToKeys[key] ) then return end
				BRS_UpdateMarketDBValue( "bricks_server_marketplace", marketKey, keysToKeys[key], value )
			else
				BRS_InsertMarketDBValue( "bricks_server_marketplace", marketKey, BRS_MARKETPLACE[marketKey] )
			end
		end
	end
end

function BRICKS_SERVER.Func.DeleteMarketplaceEntry( marketKey )
	if( BRS_MARKETPLACE[marketKey] ) then
		BRS_MARKETPLACE[marketKey] = nil

		if( BRICKS_SERVER.ESSENTIALS.LUACFG.UseMySQL != true ) then
			if( file.Exists( "bricks_server/marketplace/" .. marketKey .. ".txt", "DATA" ) ) then
				file.Delete( "bricks_server/marketplace/" .. marketKey .. ".txt" )
			end
		else
			BRS_DeleteMarketDBValue( "bricks_server_marketplace", marketKey )
		end
	end
end

function BRICKS_SERVER.Func.UpdateMarketplace()
	for k, v in pairs( BRS_PLYSIN_MARKETPLACE or {} ) do
		if( IsValid( k ) ) then
			k:UpdateMarketplace()
		else
			BRS_PLYSIN_MARKETPLACE[k] = nil
		end
	end
end

util.AddNetworkString( "BRS.Net.MarketplaceClose" )
net.Receive( "BRS.Net.MarketplaceClose", function( len, ply )
	if( not BRS_PLYSIN_MARKETPLACE or not BRS_PLYSIN_MARKETPLACE[ply] ) then return end

	BRS_PLYSIN_MARKETPLACE[ply] = nil
end )

util.AddNetworkString( "BRS.Net.MarketplaceAdd" )
net.Receive( "BRS.Net.MarketplaceAdd", function( len, ply )
	local inventoryKey = net.ReadUInt( 10 )
	local amount = net.ReadUInt( 10 )
	local auctionPrice = net.ReadUInt( 32 )
	local auctionTime = net.ReadUInt( 32 )

	if( not inventoryKey or not amount or not auctionPrice or not auctionTime ) then return end

	local plyInventory = ply:BRS():GetInventory()

	if( not plyInventory or not plyInventory[inventoryKey] ) then return end

	if( amount > (plyInventory[inventoryKey][1] or 1) ) then
		DarkRP.notify( ply, 1, 5, "You don't have enough of this item!" )
		return
	end

	if( auctionTime < (BRICKS_SERVER.CONFIG.MARKETPLACE["Minimum Auction Time"] or 300) or auctionTime > (BRICKS_SERVER.CONFIG.MARKETPLACE["Maximum Auction Time"] or 86400) ) then
		DarkRP.notify( ply, 1, 5, "Minimum time is " .. (BRICKS_SERVER.CONFIG.MARKETPLACE["Minimum Auction Time"] or 300) .. ", maximum is " .. (BRICKS_SERVER.CONFIG.MARKETPLACE["Maximum Auction Time"] or 86400) .. "!" )
		return
	end

	if( auctionPrice < (BRICKS_SERVER.CONFIG.MARKETPLACE["Minimum Starting Price"] or 1000) ) then
		DarkRP.notify( ply, 1, 5, "Minimum price is " .. (BRICKS_SERVER.CONFIG.MARKETPLACE["Minimum Starting Price"] or 1000) .. "!" )
		return
	end

	if( not ply:SteamID64() ) then return end
	
	local newAuction = { amount, auctionPrice, auctionTime, os.time(), (plyInventory[inventoryKey][2] or {}), ply:SteamID64(), ply:Nick() }

	plyInventory[inventoryKey][1] = (plyInventory[inventoryKey][1] or 1)-amount

	if( plyInventory[inventoryKey][1] < 1 ) then
		plyInventory[inventoryKey] = nil
	end

	ply:BRS():SetInventory( plyInventory )

	if( not BRS_MARKETPLACE ) then
		BRS_MARKETPLACE = {}
	end

	local marketKey = table.insert( BRS_MARKETPLACE, newAuction )

	BRICKS_SERVER.Func.UpdateMarketplaceEntry( marketKey, "", "", true )
	BRICKS_SERVER.Func.UpdateMarketplace()

	DarkRP.notify( ply, 1, 5, "Your auction has been created!" )
end )

util.AddNetworkString( "BRS.Net.MarketplaceCancel" )
net.Receive( "BRS.Net.MarketplaceCancel", function( len, ply )
	local marketKey = net.ReadUInt( 16 )
	local ownerSteamID64 = net.ReadString()

	if( not marketKey or not ownerSteamID64 or not BRS_MARKETPLACE or not BRS_MARKETPLACE[marketKey] or BRS_MARKETPLACE[marketKey][6] != ownerSteamID64 ) then return end

	local marketItem = BRS_MARKETPLACE[marketKey]
	if( os.time() >= ((marketItem[4] or 0)+(marketItem[3] or 0)) ) then
		DarkRP.notify( ply, 1, 5, "The auction has already ended for this item!" )
		return
	end

	if( (ownerSteamID64 == ply:SteamID64() and marketItem[6] == ply:SteamID64()) or BRICKS_SERVER.Func.HasAdminAccess( ply ) ) then
		BRS_MARKETPLACE[marketKey][3] = 0
		BRICKS_SERVER.Func.UpdateMarketplaceEntry( marketKey, 3, 0 )

		BRICKS_SERVER.Func.UpdateMarketplace()	

		if( ownerSteamID64 == ply:SteamID64() and marketItem[6] == ply:SteamID64() ) then
			DarkRP.notify( ply, 1, 5, "Auction cancelled!" )
		elseif( BRICKS_SERVER.Func.HasAdminAccess( ply ) ) then
			DarkRP.notify( ply, 1, 5, "Auction cancelled by admin!" )
		end
	end
end )

util.AddNetworkString( "BRS.Net.MarketplaceBid" )
net.Receive( "BRS.Net.MarketplaceBid", function( len, ply )
	local marketKey = net.ReadUInt( 16 )
	local bidAmount = net.ReadUInt( 32 )
	local ownerSteamID64 = net.ReadString() -- Confirm same item

	if( not marketKey or not bidAmount or not ownerSteamID64 or ownerSteamID64 == ply:SteamID64() ) then return end

	if( not BRS_MARKETPLACE or not BRS_MARKETPLACE[marketKey] or (BRS_MARKETPLACE[marketKey][6] or "") != ownerSteamID64 ) then
		DarkRP.notify( ply, 1, 5, "BRICKS SERVER ERROR: Invalid item!" )
		return
	end

	local marketItem = BRS_MARKETPLACE[marketKey]

	if( (table.GetWinningKey( marketItem[8] or {} ) or "") == ply:SteamID() ) then
		DarkRP.notify( ply, 1, 5, "You are already the highest bidder!" )
		return
	end

	if( bidAmount < math.floor( (marketItem[2] or 1000)*(BRICKS_SERVER.CONFIG.MARKETPLACE["Minimum Bid Increment"] or 1.1) ) ) then
		DarkRP.notify( ply, 1, 5, "You must bid at least 10% more than the current value!" )
		return
	end

	if( os.time() >= ((marketItem[4] or 0)+(marketItem[3] or 0)) ) then
		DarkRP.notify( ply, 1, 5, "The auction has already ended for this item!" )
		return
	end

	local currencyTable
    if( BRICKS_SERVER.DEVCONFIG.Currencies[(BRICKS_SERVER.CONFIG.MARKETPLACE or {})["Currency"] or ""] ) then
        currencyTable = BRICKS_SERVER.DEVCONFIG.Currencies[(BRICKS_SERVER.CONFIG.MARKETPLACE or {})["Currency"] or ""]
    end

    if( not currencyTable ) then 
        DarkRP.notify( ply, 1, 5, "BRICKS SERVER ERROR: Invalid Currency" )
        return 
    end

	local moneyToTake = bidAmount
	if( (BRS_MARKETPLACE[marketKey][8] or {})[ply:SteamID()] ) then
		moneyToTake = bidAmount-((BRS_MARKETPLACE[marketKey][8] or {})[ply:SteamID()] or 0)
	end

	if( currencyTable.getFunction( ply ) >= moneyToTake ) then
		currencyTable.addFunction( ply, -moneyToTake )

		if( not BRS_MARKETPLACE[marketKey][8] ) then
			BRS_MARKETPLACE[marketKey][8] = {}
		end

		BRS_MARKETPLACE[marketKey][2] = bidAmount
		BRS_MARKETPLACE[marketKey][8][ply:SteamID()] = bidAmount

		BRICKS_SERVER.Func.UpdateMarketplaceEntry( marketKey, 2, bidAmount )
		BRICKS_SERVER.Func.UpdateMarketplaceEntry( marketKey, 8, BRS_MARKETPLACE[marketKey][8] )
		BRICKS_SERVER.Func.UpdateMarketplace()

		DarkRP.notify( ply, 1, 5, "Bid of " .. currencyTable.formatFunction( bidAmount ) .. " placed!" )
	else
		DarkRP.notify( ply, 1, 5, "You don't have enough money for this bid!" )
	end
end )

util.AddNetworkString( "BRS.Net.MarketplaceCollect" )
net.Receive( "BRS.Net.MarketplaceCollect", function( len, ply )
	local marketKey = net.ReadUInt( 16 )
	local ownerSteamID64 = net.ReadString() -- Confirm same item

	if( not marketKey or not ownerSteamID64 ) then return end

	if( not BRS_MARKETPLACE or not BRS_MARKETPLACE[marketKey] or (BRS_MARKETPLACE[marketKey][6] or "") != ownerSteamID64 ) then
		DarkRP.notify( ply, 1, 5, "BRICKS SERVER ERROR: Invalid item!" )
		return
	end

	local marketItem = BRS_MARKETPLACE[marketKey]

	if( os.time() < ((marketItem[4] or 0)+(marketItem[3] or 0)) ) then
		DarkRP.notify( ply, 1, 5, "The auction is still on going!" )
		return
	end

	local currencyTable
    if( BRICKS_SERVER.DEVCONFIG.Currencies[(BRICKS_SERVER.CONFIG.MARKETPLACE or {})["Currency"] or ""] ) then
        currencyTable = BRICKS_SERVER.DEVCONFIG.Currencies[(BRICKS_SERVER.CONFIG.MARKETPLACE or {})["Currency"] or ""]
    end

    if( not currencyTable ) then 
        DarkRP.notify( ply, 1, 5, "BRICKS SERVER ERROR: Invalid Currency" )
        return 
	end
	
	local changed = false
	if( (table.GetWinningKey( marketItem[8] or {} ) or "") == ply:SteamID() and (marketItem[3] or 0) > 0 ) then -- winner gets item
		if( not marketItem[10] ) then
			changed = true
			BRS_MARKETPLACE[marketKey][10] = true
			BRICKS_SERVER.Func.UpdateMarketplaceEntry( marketKey, 10, true )
			ply:BRS():AddInventoryItem( (marketItem[5] or {}), (marketItem[1] or 1) )

			local infoTable = BRICKS_SERVER.Func.GetEntTypeField( ((marketItem[5] or {})[1] or ""), "GetInfo" )( marketItem[5] or {} )

			DarkRP.notify( ply, 1, 5, "Collected " .. infoTable[1] .. " from an auction you won!" )
		end
	elseif( BRS_MARKETPLACE[marketKey][8] and BRS_MARKETPLACE[marketKey][8][ply:SteamID()] ) then -- losers get money back
		changed = true
		local moneyBack = (BRS_MARKETPLACE[marketKey][8] or {})[ply:SteamID()]
		BRS_MARKETPLACE[marketKey][8][ply:SteamID()] = nil
		BRICKS_SERVER.Func.UpdateMarketplaceEntry( marketKey, 8, BRS_MARKETPLACE[marketKey][8] )
		currencyTable.addFunction( ply, moneyBack )
		DarkRP.notify( ply, 1, 5, "Collected " .. currencyTable.formatFunction( moneyBack ) .. " from an auction you lost!" )
	end
		
	if( (BRS_MARKETPLACE[marketKey][6] or "") == ply:SteamID64() and not marketItem[9] ) then -- owner gets item/money
		if( marketItem[8] and (table.Count( marketItem[8] ) or 0) > 0 and (marketItem[3] or 0) > 0 ) then
			currencyTable.addFunction( ply, (marketItem[2] or 0) )
			DarkRP.notify( ply, 1, 5, "Collected " .. currencyTable.formatFunction( (marketItem[2] or 0) ) .. " from an auction you sold!" )
		else
			ply:BRS():AddInventoryItem( (marketItem[5] or {}), (marketItem[1] or 1) )

			local infoTable = BRICKS_SERVER.Func.GetEntTypeField( ((marketItem[5] or {})[1] or ""), "GetInfo" )( marketItem[5] or {} )

			DarkRP.notify( ply, 1, 5, "Collected " .. infoTable[1] .. " from an auction you tried to sell!" )
		end
		BRS_MARKETPLACE[marketKey][9] = true
		BRICKS_SERVER.Func.UpdateMarketplaceEntry( marketKey, 9, true )
		changed = true
	end

	if( changed ) then 
		if( BRS_MARKETPLACE[marketKey][9] and (BRS_MARKETPLACE[marketKey][10] or table.Count( BRS_MARKETPLACE[marketKey][8] or {} ) <= 0) ) then
			local bidders = BRS_MARKETPLACE[marketKey][8] or {}
			if( table.Count( bidders ) <= 0 or (table.Count( bidders ) == 1 and bidders[(marketItem[6] or "")]) ) then
				BRICKS_SERVER.Func.DeleteMarketplaceEntry( marketKey )
			end
		end

		BRICKS_SERVER.Func.UpdateMarketplace() 
	end
end )

util.AddNetworkString( "BRS.Net.MarketplaceAdminRemove" )
net.Receive( "BRS.Net.MarketplaceAdminRemove", function( len, ply )
	local marketKey = net.ReadUInt( 16 )
	local ownerSteamID64 = net.ReadString()

	if( not marketKey or not ownerSteamID64 or not BRS_MARKETPLACE or not BRS_MARKETPLACE[marketKey] or BRS_MARKETPLACE[marketKey][6] != ownerSteamID64 ) then return end

	local marketItem = BRS_MARKETPLACE[marketKey]

	if( BRICKS_SERVER.Func.HasAdminAccess( ply ) ) then
		BRICKS_SERVER.Func.DeleteMarketplaceEntry( marketKey )
		BRICKS_SERVER.Func.UpdateMarketplace()	

		DarkRP.notify( ply, 1, 5, "Auction removed by admin!" )
	end
end )

hook.Add( "Initialize", "BRS.Initialize_Marketplace", function()	
	timer.Create( "BRS_TIMER_EXPIREDREMOVE", 300, 0, function()
		if( BRS_MARKETPLACE ) then
			for k, v in pairs( BRS_MARKETPLACE ) do
				local endTime = (v[4] or 0)+(v[3] or 0)+(BRICKS_SERVER.CONFIG.MARKETPLACE["Remove After Auction End Time"] or 86400)
				if( os.time() >= endTime ) then
					BRICKS_SERVER.Func.DeleteMarketplaceEntry( k )
				end
			end
		end
	end )

	BRS_MARKETPLACE = {}
	if( BRICKS_SERVER.ESSENTIALS.LUACFG.UseMySQL != true ) then
		if( not file.Exists( "bricks_server/marketplace", "DATA" ) ) then
			file.CreateDir( "bricks_server/marketplace" )
		end

		local files, directories = file.Find( "bricks_server/marketplace/*", "DATA" )
		for k, v in pairs( files ) do
			local marketItem = util.JSONToTable( file.Read( "bricks_server/marketplace/" .. v, "DATA" ) )
			local marketKey = tonumber( string.Replace( v, ".txt", "" ) )
			if( marketKey and isnumber( marketKey ) and marketItem and istable( marketItem ) ) then
				local endTime = (marketItem[4] or 0)+(marketItem[3] or 0)+(BRICKS_SERVER.CONFIG.MARKETPLACE["Remove After Auction End Time"] or 86400)
				if( os.time() >= endTime ) then
					BRICKS_SERVER.Func.DeleteMarketplaceEntry( marketKey )
				else
					BRS_MARKETPLACE[marketKey] = marketItem
				end
			elseif( marketKey and isnumber( marketKey ) ) then
				BRICKS_SERVER.Func.DeleteMarketplaceEntry( marketKey )
			end
		end
	else
		BRS_FetchMarketDBValues( "bricks_server_marketplace", function( data ) 
			if( not data ) then return end

			for k, v in pairs( data ) do
				local marketItem = { (v.amount or 0), (v.currentbid or 0), (v.time or 0), (v.starttime or 0), util.JSONToTable( v.itemdata or "" ), (v.owner or "") }
				if( v.bidders ) then marketItem[8] = util.JSONToTable( v.bidders or "" ) end
				if( v.ownercollected ) then marketItem[9] = tobool( v.ownercollected ) end
				if( v.winnercollected ) then marketItem[10] = tobool( v.winnercollected ) end
				local marketKey = tonumber( v.marketkey or 0 )
				if( marketKey and isnumber( marketKey ) and marketKey > 0 and marketItem and istable( marketItem ) ) then
					local endTime = (marketItem[4] or 0)+(marketItem[3] or 0)+(BRICKS_SERVER.CONFIG.MARKETPLACE["Remove After Auction End Time"] or 86400)
					if( os.time() >= endTime ) then
						BRICKS_SERVER.Func.DeleteMarketplaceEntry( marketKey )
					else
						BRS_MARKETPLACE[marketKey] = marketItem
					end
				elseif( marketKey and isnumber( marketKey ) ) then
					BRICKS_SERVER.Func.DeleteMarketplaceEntry( marketKey )
				end
			end
		end )
	end
end )