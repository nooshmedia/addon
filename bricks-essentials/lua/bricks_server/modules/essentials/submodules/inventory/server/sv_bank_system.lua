local playerMeta = FindMetaTable("Player")

util.AddNetworkString( "BRS.Net.SetBank" )
function playerMeta:SetBank( bankTable, nosave )
	if( not bankTable ) then return end

	net.Start( "BRS.Net.SetBank" )
		net.WriteTable( bankTable )
	net.Send( self )

	self.BRS_BANK = (bankTable or {})

	if( not nosave ) then
		self:BRS_Essentials_SaveStat( "bank" )
	end
end

function playerMeta:GetBank()
	return (self.BRS_BANK or {})
end

function playerMeta:BRS_BankFull( amount, canStack )
	local bankCount = table.Count( self:GetBank() )
	if( not canStack ) then
		if( bankCount+amount > BRICKS_SERVER.Func.GetBankSlots( self ) ) then 
			return true
		end
	else
		local newStacks = amount/BRICKS_SERVER.CONFIG.INVENTORY["Max Item Stack"]
		if( bankCount+newStacks > BRICKS_SERVER.Func.GetBankSlots( self ) ) then 
			return true
		end
	end

	return false
end

function playerMeta:BRS_BankAdd( itemData, itemAmount )
	local bankTable = self:GetBank()

	local bankSlots = BRICKS_SERVER.Func.GetBankSlots( self )
	if( table.Count( bankTable ) < bankSlots ) then
		local itemTable = { math.Clamp( (itemAmount or 1), 1, BRICKS_SERVER.CONFIG.INVENTORY["Max Item Stack"] ), itemData }

		for i = 1, bankSlots do
			if( not bankTable[i] or (bankTable[i][1] or 1) >= BRICKS_SERVER.CONFIG.INVENTORY["Max Item Stack"] ) then continue end

			local canCombine = BRICKS_SERVER.Func.GetEntTypeField( (itemData[1] or ""), "CanCombine" )( itemData, (bankTable[i][2] or {}) )

			if( canCombine ) then
				if( itemTable[1]+(bankTable[i][1] or 1) <= BRICKS_SERVER.CONFIG.INVENTORY["Max Item Stack"] ) then
					bankTable[i][1] = math.Clamp( itemTable[1]+(bankTable[i][1] or 1), 1, BRICKS_SERVER.CONFIG.INVENTORY["Max Item Stack"] )
					self:SetBank( bankTable )

					return
				else
					local oldToAmount = bankTable[i][1]
					bankTable[i][1] = math.Clamp( itemTable[1]+(bankTable[i][1] or 1), 1, BRICKS_SERVER.CONFIG.INVENTORY["Max Item Stack"] )
					self:SetBank( bankTable )

					self:BRS_BankAdd( itemData, (itemAmount-(BRICKS_SERVER.CONFIG.INVENTORY["Max Item Stack"]-(oldToAmount or 1))) )
					return
				end
			end
		end

		for i = 1, bankSlots do
			if( not bankTable[i] ) then
				bankTable[i] = itemTable
				self:SetBank( bankTable )

				if( itemAmount > BRICKS_SERVER.CONFIG.INVENTORY["Max Item Stack"] ) then
					self:BRS_BankAdd( itemData, itemAmount-BRICKS_SERVER.CONFIG.INVENTORY["Max Item Stack"] )
				end
				break
			end
		end
	else
		return false
	end
end

util.AddNetworkString( "BRS.Net.InventoryBankMoveItem" )
net.Receive( "BRS.Net.InventoryBankMoveItem", function( len, ply )
	local slotFrom = net.ReadUInt( 10 )
	local slotTo = net.ReadUInt( 10 )
	local slotFromType = net.ReadString()
	local slotToType = net.ReadString()

	if( not slotFrom or not slotTo or not slotFromType or not slotToType or slotTo <= 0 ) then return end
	if( slotFrom == slotTo and slotFromType == slotToType ) then return end
	if( not IsValid( ply ) ) then return end

	local inventoryTable = ply:BRS():GetInventory() or {}
	local bankTable = ply:GetBank() or {}

	local slotFromItem = false
	local slotFromDataTable = false
	if( slotFromType == "Inventory" ) then
		slotFromItem = inventoryTable[slotFrom]
		slotFromDataTable = inventoryTable
	elseif( slotFromType == "Bank" ) then
		slotFromItem = bankTable[slotFrom]
		slotFromDataTable = bankTable
	end

	if( not slotFromItem or not slotFromDataTable ) then return end

	local slotToItem = false
	local slotToDataTable = false
	if( slotToType == "Inventory" ) then
		slotToItem = inventoryTable[slotTo]
		slotToDataTable = inventoryTable

		if( slotTo > BRICKS_SERVER.Func.GetInventorySlots( ply ) ) then return end
	elseif( slotToType == "Bank" ) then
		slotToItem = bankTable[slotTo]
		slotToDataTable = bankTable

		if( slotTo > BRICKS_SERVER.Func.GetBankSlots( ply ) ) then return end
	end

	if( slotToItem ) then
		local canCombine = BRICKS_SERVER.Func.GetEntTypeField( ((slotFromItem[2] or {})[1] or ""), "CanCombine" )( (slotFromItem[2] or {}), (slotToItem[2] or {}) )

		if( canCombine ) then
			if( (slotToItem[1] or 1)+(slotFromItem[1] or 1) <= BRICKS_SERVER.CONFIG.INVENTORY["Max Item Stack"] ) then
				slotToDataTable[slotTo][1] = math.Clamp( (slotToItem[1] or 1)+(slotFromItem[1] or 1), 1, BRICKS_SERVER.CONFIG.INVENTORY["Max Item Stack"] )
				slotFromDataTable[slotFrom] = nil
			else
				local oldFromAmount = slotFromItem[1]
				local oldToAmount = slotToItem[1]
				slotToDataTable[slotTo][1] = math.Clamp( (slotToItem[1] or 1)+(slotFromItem[1] or 1), 1, BRICKS_SERVER.CONFIG.INVENTORY["Max Item Stack"] )
				slotFromDataTable[slotFrom][1] = oldFromAmount-(BRICKS_SERVER.CONFIG.INVENTORY["Max Item Stack"]-(oldToAmount or 1))

				if( slotFromItem[1] < 1 ) then
					slotFromDataTable[slotFrom] = nil
				end
			end
		else
			slotToDataTable[slotTo] = slotFromItem
			slotFromDataTable[slotFrom] = slotToItem
		end
	else
		slotFromDataTable[slotFrom] = nil
		slotToDataTable[slotTo] = slotFromItem
	end

	if( slotFromType == "Inventory" or slotToType == "Inventory" ) then
		ply:BRS():SetInventory( inventoryTable )
	end
	
	if( slotFromType == "Bank" or slotToType == "Bank" ) then
		ply:SetBank( bankTable )
	end
end )

util.AddNetworkString( "BRS.Net.BankAdminRemove" )
net.Receive( "BRS.Net.BankAdminRemove", function( len, ply )
	if( not BRICKS_SERVER.Func.HasAdminAccess( ply ) ) then return end
	
	local victimID64 = net.ReadString()
	local slotID = net.ReadUInt( 10 )

	if( not victimID64 or not slotID ) then return end
	local requestedPly = player.GetBySteamID64( victimID64 )

	if( IsValid( requestedPly ) ) then
		local bankTable = requestedPly:GetBank() or {}

		if( bankTable[slotID] ) then
			bankTable[slotID] = nil
		end

		requestedPly:SetBank( bankTable )

		ply:BRS():AdminSendInventory( requestedPly )
	else
		DarkRP.notify( ply, 1, 5, "Error removing item!" )
	end
end )