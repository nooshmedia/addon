util.AddNetworkString( "BRS.Net.UseTraderNPC" )
util.AddNetworkString( "BRS.Net.UseBankNPC" )
util.AddNetworkString( "BRS.Net.UseMoneyLaunderer" )
util.AddNetworkString( "BRS.Net.UseDeathscreens" )
util.AddNetworkString( "BRS.Net.UseSWEPUpgrader" )

util.AddNetworkString( "BRS.Net.NPC_TraderSellItem" )
net.Receive( "BRS.Net.NPC_TraderSellItem", function( len, ply )
	local NPCKey = net.ReadUInt( 8 )
	local inventoryKey = net.ReadUInt( 8 )
	local amount = net.ReadUInt( 10 )

	if( not NPCKey or not inventoryKey or not amount ) then return end
	if( not BRICKS_SERVER.CONFIG.NPCS[NPCKey] or not BRICKS_SERVER.CONFIG.NPCS[NPCKey].Buying ) then return end
	local NPCTable = BRICKS_SERVER.CONFIG.NPCS[NPCKey]
	local plyInventory = ply:BRS():GetInventory()

	if( not plyInventory[inventoryKey] or plyInventory[inventoryKey][1] < amount ) then return end

	local slotItem = plyInventory[inventoryKey]

	local typeTable = BRICKS_SERVER.DEVCONFIG.NPCTypes[NPCTable.Type]
	local sameAsRequired = false
	if( typeTable.BuyingTypes ) then
		for k, v in pairs( NPCTable.Buying ) do
			if( typeTable.BuyingTypes[v.Type] and typeTable.BuyingTypes[v.Type].SlotSameAsRequired and typeTable.BuyingTypes[v.Type].SlotSameAsRequired( slotItem[2], v.ReqInfo ) ) then
				sameAsRequired = v
				break
			end
		end
	end

	if( sameAsRequired ) then
		local currencyTable
		if( NPCTable.ReqInfo and NPCTable.ReqInfo[1] and BRICKS_SERVER.DEVCONFIG.Currencies[NPCTable.ReqInfo[1]] ) then
			currencyTable = BRICKS_SERVER.DEVCONFIG.Currencies[NPCTable.ReqInfo[1]]
		end

		if( currencyTable and currencyTable.addFunction ) then
			plyInventory[inventoryKey][1] = plyInventory[inventoryKey][1]-amount
			if( plyInventory[inventoryKey][1] <= 0 ) then
				plyInventory[inventoryKey] = nil
			end

			ply:BRS():SetInventory( plyInventory )

			currencyTable.addFunction( ply, amount*(sameAsRequired.Price or 0) )
			if( currencyTable.formatFunction ) then 
				DarkRP.notify( ply, 1, 5, "You received " .. currencyTable.formatFunction( amount*(sameAsRequired.Price or 0) ) .. " from trading!" )
			else
				DarkRP.notify( ply, 1, 5, "You received " .. string.Comma( amount*(sameAsRequired.Price or 0) ) .. " " .. NPCTable.ReqInfo[1] .. " from trading!" )
			end
		else
			DarkRP.notify( ply, 1, 5, "BRICKS SERVER ERROR: Invalid Currency" )
		end
	end
end )

util.AddNetworkString( "BRS.Net.NPC_TraderBuyItem" )
net.Receive( "BRS.Net.NPC_TraderBuyItem", function( len, ply )
	local NPCKey = net.ReadUInt( 8 )
	local itemKey = net.ReadUInt( 8 )
	local amount = net.ReadUInt( 10 )

	if( not NPCKey or not itemKey or not amount ) then return end
	if( not BRICKS_SERVER.CONFIG.NPCS[NPCKey] or not BRICKS_SERVER.CONFIG.NPCS[NPCKey].Selling or not BRICKS_SERVER.CONFIG.NPCS[NPCKey].Selling[itemKey] ) then return end
	local NPCTable = BRICKS_SERVER.CONFIG.NPCS[NPCKey]
	local itemTable = BRICKS_SERVER.CONFIG.NPCS[NPCKey].Selling[itemKey]

	local currencyTable
	if( NPCTable.ReqInfo and NPCTable.ReqInfo[1] and BRICKS_SERVER.DEVCONFIG.Currencies[NPCTable.ReqInfo[1]] ) then
		currencyTable = BRICKS_SERVER.DEVCONFIG.Currencies[NPCTable.ReqInfo[1]]
	end

	local price = (amount or 1)*(itemTable.Price or 0)
	if( currencyTable and currencyTable.getFunction ) then
		if( (currencyTable.getFunction( ply ) or 0) >= price ) then
			local typeTable = BRICKS_SERVER.DEVCONFIG.NPCTypes[NPCTable.Type]
			if( typeTable.SellingTypes and typeTable.SellingTypes[itemTable.Type] and typeTable.SellingTypes[itemTable.Type].GiveItem ) then
				local giveItem, errorMsg = typeTable.SellingTypes[itemTable.Type].GiveItem( ply, itemTable.ReqInfo, amount, itemTable )
				
				if( giveItem != false ) then
					currencyTable.addFunction( ply, -price )

					if( currencyTable.formatFunction ) then 
						DarkRP.notify( ply, 1, 5, "You bought x" .. amount .. " " .. (typeTable.SellingTypes[itemTable.Type].FormatName( itemTable.ReqInfo or {} ) or "item") .. " for " .. currencyTable.formatFunction( price ) .. " from a trader!" )
					else
						DarkRP.notify( ply, 1, 5, "You bought x" .. amount .. " " .. (typeTable.SellingTypes[itemTable.Type].FormatName( itemTable.ReqInfo or {} ) or "item") .. " for " .. string.Comma( price ) .. " " .. NPCTable.ReqInfo[1] .. " from a trader!" )
					end
				else
					DarkRP.notify( ply, 1, 5, errorMsg or "BRICKS SERVER ERROR: Invalid Item" )
				end
			end
		else
			DarkRP.notify( ply, 1, 5, "You don't have enough " .. (currencyTable.Title or "money") .. " to buy this!" )
		end
	else
		DarkRP.notify( ply, 1, 5, "BRICKS SERVER ERROR: Invalid Currency" )
	end
end )