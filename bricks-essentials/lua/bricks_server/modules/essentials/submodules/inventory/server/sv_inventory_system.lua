local playerMeta = FindMetaTable( "Player" )

util.AddNetworkString( "BRS.Net.SetInventory" )
function BRICKS_SERVER.PLAYERMETA:SetInventory( inventoryTable, nosave )
	if( not inventoryTable ) then return end

	net.Start( "BRS.Net.SetInventory" )
		net.WriteTable( inventoryTable )
	net.Send( self.Player )

	self.Inventory = inventoryTable

	if( not nosave ) then
		self.Player:BRS_Essentials_SaveStat( "inventory" )
	end
end

--[[ ADDING/REMOVING ]]--
function BRICKS_SERVER.PLAYERMETA:IsInventoryFull( amount, canStack )
	local inventoryCount = table.Count( self:GetInventory() )
	if( not canStack ) then
		if( inventoryCount+amount > BRICKS_SERVER.Func.GetInventorySlots( self.Player ) ) then 
			return true
		end
	else
		local newStacks = amount/BRICKS_SERVER.CONFIG.INVENTORY["Max Item Stack"]
		if( inventoryCount+newStacks > BRICKS_SERVER.Func.GetInventorySlots( self.Player ) ) then 
			return true
		end
	end

	return false
end

function BRICKS_SERVER.PLAYERMETA:AddInventoryEnt( itemEntity )
	if( not IsValid( itemEntity ) or not BRICKS_SERVER.CONFIG.INVENTORY.Whitelist[itemEntity:GetClass()] ) then return end

	local inventoryTable = self:GetInventory()

	local itemData, amount = BRICKS_SERVER.Func.GetEntTypeField( itemEntity:GetClass(), "GetItemData" )( itemEntity )

	if( self:IsInventoryFull( amount, false ) ) then 
		DarkRP.notify( self.Player, 1, 5, "Your inventory is full!" )
		return
	end

	self:AddInventoryItem( itemData, amount )

	DarkRP.notify( self.Player, 1, 5, "Added 1 item to your inventory." )
	itemEntity:Remove()
end	

BRS_INVENTORYADD_QUEUE = {}
function BRICKS_SERVER.PLAYERMETA:AddInventoryItem( itemData, amount )
	if( not BRS_INVENTORYADD_QUEUE ) then
		BRS_INVENTORYADD_QUEUE = {}
	end

	if( not BRS_INVENTORYADD_QUEUE[self.Player] ) then
		BRS_INVENTORYADD_QUEUE[self.Player] = {}
	end

	table.insert( BRS_INVENTORYADD_QUEUE[self.Player], { amount, itemData } )
end

hook.Add( "Think", "BRS.Think_InventoryAdd", function()
	if( not BRS_INVENTORYADD_QUEUE ) then return end

	for ply, items in pairs( BRS_INVENTORYADD_QUEUE ) do 
		if( not IsValid( ply ) or not ply:IsPlayer() or not items or not istable( items ) ) then
			BRS_INVENTORYADD_QUEUE[ply] = nil
			continue
		end

		for key, val in pairs( items ) do 
			local inventoryTable = ply:BRS():GetInventory()
			local maxSlots = BRICKS_SERVER.Func.GetInventorySlots( ply )

			if( table.Count( inventoryTable ) >= maxSlots ) then
				BRS_INVENTORYADD_QUEUE[ply] = nil
				break
			end

			local itemAmount, itemData = val[1], val[2]
	
			for i = 1, maxSlots do
				if( inventoryTable[i] and (inventoryTable[i][1] or 1) >= BRICKS_SERVER.CONFIG.INVENTORY["Max Item Stack"] ) then continue end
	
				if( inventoryTable[i] ) then
					local canCombine = BRICKS_SERVER.Func.GetEntTypeField( (itemData[1] or ""), "CanCombine" )( itemData, (inventoryTable[i][2] or {}) )
		
					if( canCombine ) then
						local currentItemAmount = inventoryTable[i][1] or 1

						inventoryTable[i][1] = math.Clamp( currentItemAmount+itemAmount, 1, BRICKS_SERVER.CONFIG.INVENTORY["Max Item Stack"] )
						ply:BRS():SetInventory( inventoryTable )
	
						table.remove( BRS_INVENTORYADD_QUEUE[ply], key )

						if( currentItemAmount+itemAmount > BRICKS_SERVER.CONFIG.INVENTORY["Max Item Stack"] ) then
							ply:BRS():AddInventoryItem( itemData, currentItemAmount+itemAmount-BRICKS_SERVER.CONFIG.INVENTORY["Max Item Stack"] )
						end
						break
					end
				else
					inventoryTable[i] = { math.Clamp( (itemAmount or 1), 1, BRICKS_SERVER.CONFIG.INVENTORY["Max Item Stack"] ), itemData }
					ply:BRS():SetInventory( inventoryTable )
	
					table.remove( BRS_INVENTORYADD_QUEUE[ply], key )
	
					if( itemAmount > BRICKS_SERVER.CONFIG.INVENTORY["Max Item Stack"] ) then
						ply:BRS():AddInventoryItem( itemData, itemAmount-BRICKS_SERVER.CONFIG.INVENTORY["Max Item Stack"] )
					end
					break
				end
			end
		end
	end
end )

hook.Add( "PlayerButtonUp", "BRS.PlayerButtonUp_InventoryPickup", function( ply, key )
	if( key == (ply.PickupBind1 or KEY_LALT) ) then
		ply.PickupBind1Down = false
	elseif( key == (ply.PickupBind2 or KEY_E) ) then
		ply.PickupBind2Down = false
	end
end )

hook.Add( "PlayerButtonDown", "BRS.PlayerButtonDown_InventoryPickup", function( ply, key )
	if( key == (ply.PickupBind1 or KEY_LALT) ) then
		ply.PickupBind1Down = true
	elseif( key == (ply.PickupBind2 or KEY_E) ) then
		ply.PickupBind2Down = true
	end
	
	if( ply:GetEyeTrace() and ply:GetEyeTrace().Entity and IsValid( ply:GetEyeTrace().Entity ) ) then
		local entClass = ply:GetEyeTrace().Entity:GetClass()
		local Distance = ply:GetPos():DistToSqr( ply:GetEyeTrace().Entity:GetPos() )

		if( Distance < 10000 ) then
			local binds = (BRICKS_SERVER.CONFIG.INVENTORY.Whitelist or {})[entClass]
			if( binds ) then
				if( binds[1] and binds[2] ) then
					if( ply.PickupBind1Down and ply.PickupBind2Down ) then
						ply:BRS():AddInventoryEnt( ply:GetEyeTrace().Entity )
					end
				elseif( binds[2] and ply.PickupBind2Down ) then
					ply:BRS():AddInventoryEnt( ply:GetEyeTrace().Entity )
				elseif( binds[1] and ply.PickupBind1Down ) then
					ply:BRS():AddInventoryEnt( ply:GetEyeTrace().Entity )
				end
			end
		end
	end
end )

util.AddNetworkString( "BRS.Net.InventoryChangeBind" )
net.Receive( "BRS.Net.InventoryChangeBind", function( len, ply )
	local bindNumber = net.ReadUInt( 2 )
	local bindKey = net.ReadUInt( 8 )

	if( not BRICKS_SERVER.DEVCONFIG.KEY_BINDS[bindKey] ) then return end

	if( bindNumber == 1 ) then
		ply.PickupBind1 = bindKey
	elseif( bindNumber == 2 ) then
		ply.PickupBind2 = bindKey
	end
end )

util.AddNetworkString( "BRS.Net.InventoryDropItem" )
net.Receive( "BRS.Net.InventoryDropItem", function( len, ply )
	local itemKey = net.ReadUInt( 10 )
	
	if( not itemKey ) then return end
	
	local inventoryTable = ply:BRS():GetInventory()
	
	if( inventoryTable[itemKey] ) then
		local preventDrop, errorMessage = hook.Run( "BRS.Hooks.InventoryCanDrop", ply, itemKey )

		if( not preventDrop ) then
			local itemTable = inventoryTable[itemKey]
			local itemData = itemTable[2] or {}
			local placePos = ply:GetPos()+( ply:GetForward()*30 )+Vector( 0, 0, 20 )

			local unequipFunc = BRICKS_SERVER.Func.GetEntTypeField( (itemData[1] or ""), "UnEquip" )
			if( itemTable[3] and unequipFunc ) then
				unequipFunc( ply, itemData )
			end

			BRICKS_SERVER.Func.GetEntTypeField( (itemData[1] or ""), "OnSpawn" )( ply, placePos, itemData, 1 )

			if( (itemTable[1] or 1) > 1 ) then
				itemTable[1] = math.Clamp( itemTable[1]-1, 1, BRICKS_SERVER.CONFIG.INVENTORY["Max Item Stack"] )
			else
				inventoryTable[itemKey] = nil
			end

			ply:BRS():SetInventory( inventoryTable )

			DarkRP.notify( ply, 1, 5, "Dropped 1 item from your inventory." )
		else
			DarkRP.notify( ply, 1, 5, errorMessage or "You can't drop that!" )
		end
	end
end )

util.AddNetworkString( "BRS.Net.InventoryDropAllItem" )
net.Receive( "BRS.Net.InventoryDropAllItem", function( len, ply )
	local itemKey = net.ReadUInt( 10 )
	
	if( not itemKey ) then return end
	
	local inventoryTable = ply:BRS():GetInventory()
	
	if( inventoryTable[itemKey] ) then
		local preventDrop, errorMessage = hook.Run( "BRS.Hooks.InventoryCanDrop", ply, itemKey )

		if( not preventDrop ) then
			local itemTable = inventoryTable[itemKey]
			local itemData = itemTable[2] or {}
			local placePos = ply:GetPos()+( ply:GetForward()*30 )+Vector( 0, 0, 20 )

			if( not BRICKS_SERVER.Func.GetEntTypeField( (itemData[1] or ""), "CanDropMultiple" ) ) then return end

			BRICKS_SERVER.Func.GetEntTypeField( (itemData[1] or ""), "OnSpawn" )( ply, placePos, itemData, (itemTable[1] or 1) )

			inventoryTable[itemKey] = nil
			ply:BRS():SetInventory( inventoryTable )

			DarkRP.notify( ply, 1, 5, "Dropped 1 item from your inventory." )
		else
			DarkRP.notify( ply, 1, 5, errorMessage or "You can't drop that!" )
		end
	end
end )

util.AddNetworkString( "BRS.Net.InventoryUseItem" )
net.Receive( "BRS.Net.InventoryUseItem", function( len, ply )
	local itemKey = net.ReadUInt( 10 )
	
	if( not itemKey ) then return end
	
	local inventoryTable = ply:BRS():GetInventory()
	
	if( inventoryTable[itemKey] ) then
		local preventUse, errorMessage = hook.Run( "BRS.Hooks.InventoryCanUse", ply, itemKey )

		if( not preventUse ) then
			local itemTable = inventoryTable[itemKey]
			local itemData = itemTable[2] or {}

			if( BRICKS_SERVER.Func.GetEntTypeField( (itemData[1] or ""), "CanUse" )( ply, itemData ) ) then
				if( BRICKS_SERVER.Func.GetInvTypeCFG( itemData[1] or "" ).OnUse ) then
					BRICKS_SERVER.Func.GetInvTypeCFG( itemData[1] or "" ).OnUse( ply, itemData )
				end

				if( (itemTable[1] or 1) > 1 ) then
					itemTable[1] = math.Clamp( itemTable[1]-1, 1, BRICKS_SERVER.CONFIG.INVENTORY["Max Item Stack"] )
				else
					inventoryTable[itemKey] = nil
				end
				ply:BRS():SetInventory( inventoryTable )

				DarkRP.notify( ply, 1, 5, "Used 1 item from your inventory." )
			else
				DarkRP.notify( ply, 1, 5, "You can't use that!" )
			end
		else
			DarkRP.notify( ply, 1, 5, "You can't use that!" )
		end
	end
end )

util.AddNetworkString( "BRS.Net.InventoryEquipItem" )
net.Receive( "BRS.Net.InventoryEquipItem", function( len, ply )
	local itemKey = net.ReadUInt( 10 )
	
	if( not itemKey ) then return end
	
	local inventoryTable = ply:BRS():GetInventory()
	
	if( inventoryTable[itemKey] and not inventoryTable[itemKey][3] ) then
		local preventUse, errorMessage = hook.Run( "BRS.Hooks.InventoryCanUse", ply, itemKey )

		if( not preventUse ) then
			local itemTable = inventoryTable[itemKey]
			local itemData = itemTable[2] or {}

			local canEquip = true
			if( BRICKS_SERVER.Func.GetInvTypeCFG( itemData[1] or "" ).CanEquip ) then
				canEquip = BRICKS_SERVER.Func.GetInvTypeCFG( itemData[1] or "" ).CanEquip( ply, itemData )
			end

			if( canEquip ) then
				if( BRICKS_SERVER.Func.GetInvTypeCFG( itemData[1] or "" ).Equip ) then
					BRICKS_SERVER.Func.GetInvTypeCFG( itemData[1] or "" ).Equip( ply, itemData )
				end

				inventoryTable[itemKey][3] = true

				ply:BRS():SetInventory( inventoryTable )

				DarkRP.notify( ply, 1, 5, "Equipped 1 item from your inventory." )
			else
				DarkRP.notify( ply, 1, 5, "You can't equip that!" )
			end
		else
			DarkRP.notify( ply, 1, 5, errorMessage or "You can't equip that!" )
		end
	end
end )

util.AddNetworkString( "BRS.Net.InventoryUnEquipItem" )
net.Receive( "BRS.Net.InventoryUnEquipItem", function( len, ply )
	local itemKey = net.ReadUInt( 10 )
	
	if( not itemKey ) then return end
	
	local inventoryTable = ply:BRS():GetInventory()
	
	if( inventoryTable[itemKey] and inventoryTable[itemKey][3] ) then
		local itemTable = inventoryTable[itemKey]
		local itemData = itemTable[2] or {}

		local canUnEquip = true
		if( BRICKS_SERVER.Func.GetInvTypeCFG( itemData[1] or "" ).CanUnEquip ) then
			canUnEquip = BRICKS_SERVER.Func.GetInvTypeCFG( itemData[1] or "" ).CanUnEquip( ply, itemData )
		end

		if( canUnEquip ) then
			if( BRICKS_SERVER.Func.GetInvTypeCFG( itemData[1] or "" ).UnEquip ) then
				BRICKS_SERVER.Func.GetInvTypeCFG( itemData[1] or "" ).UnEquip( ply, itemData )
			end

			inventoryTable[itemKey][3] = nil

			ply:BRS():SetInventory( inventoryTable )

			DarkRP.notify( ply, 1, 5, "Un equipped 1 item from your inventory." )
		else
			DarkRP.notify( ply, 1, 5, "You can't un equip that!" )
		end
	end
end )

util.AddNetworkString( "BRS.Net.InventoryMoveItem" )
net.Receive( "BRS.Net.InventoryMoveItem", function( len, ply )
	local slotFrom = net.ReadUInt( 10 )
	local slotTo = net.ReadUInt( 10 )

	if( not slotFrom or not slotTo or slotTo > BRICKS_SERVER.Func.GetInventorySlots( ply ) ) then return end
	if( slotFrom == slotTo ) then return end
	if( not IsValid( ply ) ) then return end

	local inventoryTable = ply:BRS():GetInventory()

	if( not inventoryTable[slotFrom] ) then return end
	
	local slotFromItem = inventoryTable[slotFrom]

	if( inventoryTable[slotTo] ) then
		local slotToItem = inventoryTable[slotTo]

		if( slotToItem ) then
			local canCombine = false
			if( BRICKS_SERVER.Func.GetInvTypeCFG( (slotFromItem[2] or {})[1] or "" ).CanCombine ) then
				canCombine = BRICKS_SERVER.Func.GetInvTypeCFG( (slotFromItem[2] or {})[1] or "" ).CanCombine( (slotFromItem[2] or {}), (slotToItem[2] or {}) )
			else
				canCombine = BRICKS_SERVER.DEVCONFIG.INVENTORY.DefaultEntFuncs.CanCombine( (slotFromItem[2] or {}), (slotToItem[2] or {}) )
			end

			if( canCombine ) then
				if( (inventoryTable[slotTo][1] or 1)+(inventoryTable[slotFrom][1] or 1) <= BRICKS_SERVER.CONFIG.INVENTORY["Max Item Stack"] ) then
					inventoryTable[slotTo][1] = math.Clamp( (inventoryTable[slotTo][1] or 1)+(inventoryTable[slotFrom][1] or 1), 1, BRICKS_SERVER.CONFIG.INVENTORY["Max Item Stack"] )
					inventoryTable[slotFrom] = nil
				else
					local oldFromAmount = inventoryTable[slotFrom][1]
					local oldToAmount = inventoryTable[slotTo][1]
					inventoryTable[slotTo][1] = math.Clamp( (inventoryTable[slotTo][1] or 1)+(inventoryTable[slotFrom][1] or 1), 1, BRICKS_SERVER.CONFIG.INVENTORY["Max Item Stack"] )
					inventoryTable[slotFrom][1] = oldFromAmount-(BRICKS_SERVER.CONFIG.INVENTORY["Max Item Stack"]-(oldToAmount or 1))

					if( inventoryTable[slotFrom][1] < 1 ) then
						inventoryTable[slotFrom] = nil
					end
				end
			else
				inventoryTable[slotTo] = slotFromItem
				inventoryTable[slotFrom] = slotToItem
			end
		else
			inventoryTable[slotTo] = slotFromItem
			inventoryTable[slotFrom] = nil
		end
	else
		inventoryTable[slotTo] = slotFromItem
		inventoryTable[slotFrom] = nil
	end

	ply:BRS():SetInventory( inventoryTable )
end )

util.AddNetworkString( "BRS.Net.InventoryAdminSend" )
function BRICKS_SERVER.PLAYERMETA:AdminSendInventory( victim )
	local printers = {}
	if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "printers" ) ) then
		printers = victim:GetPrinters() or {}
	end

	local boosters = {}
	if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "boosters" ) ) then
		boosters = victim:GetBoosters() or {}
	end

	net.Start( "BRS.Net.InventoryAdminSend" )
		net.WriteString( victim:SteamID64() )
		net.WriteTable( victim:BRS():GetInventory() or {} )
		net.WriteTable( victim:GetBank() or {} )
		net.WriteTable( printers )
		net.WriteTable( boosters )
	net.Send( self.Player )
end	

util.AddNetworkString( "BRS.Net.InventoryAdminRequest" )
net.Receive( "BRS.Net.InventoryAdminRequest", function( len, ply )
	if( not BRICKS_SERVER.Func.HasAdminAccess( ply ) ) then return end
	
	local requestedID64 = net.ReadString()

	if( not requestedID64 ) then return end
	local requestedPly = player.GetBySteamID64( requestedID64 )

	if( IsValid( requestedPly ) ) then
		ply:BRS():AdminSendInventory( requestedPly )
	else
		DarkRP.notify( ply, 1, 5, "Invalid player inventory requested!" )
	end
end )

util.AddNetworkString( "BRS.Net.InventoryAdminRemove" )
net.Receive( "BRS.Net.InventoryAdminRemove", function( len, ply )
	if( not BRICKS_SERVER.Func.HasAdminAccess( ply ) ) then return end
	
	local victimID64 = net.ReadString()
	local slotID = net.ReadUInt( 10 )

	if( not victimID64 or not slotID ) then return end
	local requestedPly = player.GetBySteamID64( victimID64 )

	if( IsValid( requestedPly ) ) then
		local inventoryTable = requestedPly:BRS():GetInventory() or {}

		if( inventoryTable[slotID] ) then
			inventoryTable[slotID] = nil
		end

		requestedPly:BRS():SetInventory( inventoryTable )

		ply:BRS():AdminSendInventory( requestedPly )
	else
		DarkRP.notify( ply, 1, 5, "Error removing item!" )
	end
end )

hook.Add( "PlayerPickupDarkRPWeapon", "BRS.PlayerPickupDarkRPWeapon_WeaponPickup", function( ply, spawned_weapon, weaponEnt )
	if( spawned_weapon:GetNW2Bool( "BRS_IsPermanent" ) ) then
		return true
	end

	if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "swepupgrader" ) ) then
		local upgradeTier = spawned_weapon:GetNW2Int( "BRS_Upgrades", 0 )
		local weaponClass = spawned_weapon:GetWeaponClass()

		if( upgradeTier > 0 ) then
			timer.Simple( 0, function()
				local newWeaponEnt = ply:GetWeapon( weaponClass )

				if( IsValid( newWeaponEnt ) ) then
					newWeaponEnt:BRS_SetWeaponTier( upgradeTier )
				end
			end )
		end
	end
end )

if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "swepupgrader" ) ) then
	hook.Add( "onDarkRPWeaponDropped", "BRS.onDarkRPWeaponDropped_WeaponDrop", function( ply, spawned_weapon, weaponEnt )
		spawned_weapon:SetNW2Int( "BRS_Upgrades", weaponEnt:BRS_GetVariableValue( "BRS_Upgrades" ) or 0 )

		function spawned_weapon:StartTouch( touchEnt ) 
			BRICKS_SERVER.Func.MergeWeapons( self, touchEnt )
		end
	end )

	function BRICKS_SERVER.Func.MergeWeapons( self, ent )
		-- the .USED var is also used in other mods for the same purpose
		if ent.IsSpawnedWeapon ~= true or
		self:GetWeaponClass() ~= ent:GetWeaponClass() or
		self:GetNW2Int( "BRS_Upgrades", 0 ) != ent:GetNW2Int( "BRS_Upgrades", 0 ) or
		self.hasMerged or ent.hasMerged then return end
	
		ent.hasMerged = true
		ent.USED = true
	
		local selfAmount, entAmount = self:Getamount(), ent:Getamount()
		local totalAmount = selfAmount + entAmount
		self.ammoadd, ent.ammoadd = self.ammoadd or 0, ent.ammoadd or 0
	
		-- ammoAdd will be the floored average of both weapons' ammoadd
		-- Some ammo might get lost there.
		self.ammoadd = math.floor((self.ammoadd * selfAmount + ent.ammoadd * entAmount) / totalAmount)
	
		-- If neither have a clip, use default clip, otherwise merge the two
		if self.clip1 or ent.clip1 then
			self.clip1 = math.floor(((self.clip1 or 0) * selfAmount + (ent.clip1 or 0) * entAmount) / totalAmount)
		end
	
		if self.clip2 or ent.clip2 then
			self.clip2 = math.floor(((self.clip2 or 0) * selfAmount + (ent.clip2 or 0) * entAmount) / totalAmount)
		end
	
		self:Setamount(totalAmount)
		ent:Remove()
	end
end

function BRICKS_SERVER.Func.HolsterWeapon( ply )
	if( not IsValid( ply ) or not ply:Alive() ) then return end

	local activeWeapon = ply:GetActiveWeapon()

	if( not IsValid( activeWeapon ) ) then return end

	local canDrop = hook.Run( "canDropWeapon", ply, activeWeapon )

	if( not canDrop or activeWeapon:GetClass() == "bricks_server_invpickup" ) then
		DarkRP.notify( ply, 1, 5, "You cannot holster this weapon!" )
		return
	end

	if( ply:BRS():IsInventoryFull( 1, false ) ) then
		DarkRP.notify( ply, 1, 5, "Your inventory is full!" )
		return
	end

	local weaponClass = activeWeapon:GetClass()
	local itemData = { "spawned_weapon", (activeWeapon.WorldModel or BRICKS_SERVER.Func.GetWeaponModel( weaponClass )), weaponClass }

	if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "swepupgrader" ) ) then
		local tier = activeWeapon:BRS_GetVariableValue( "BRS_Upgrades" ) or 0
		if( tier > 0 ) then
			itemData[4] = tier
		end
	end

	ply:StripWeapon( weaponClass )

	ply:BRS():AddInventoryItem( itemData, 1 )

	DarkRP.notify( ply, 1, 5, "Weapon holstered!" )
end

hook.Add( "PlayerSay", "BRS.PlayerSay_HolsterWeapon", function( ply, text )
	if( BRICKS_SERVER.ESSENTIALS.LUACFG.HolsterCommands[string.lower( text )] ) then
		BRICKS_SERVER.Func.HolsterWeapon( ply )
		return ""
	end
end)

concommand.Add( "holster", function( ply, cmd, args )
	if( IsValid( ply ) and ply:IsPlayer() ) then
		BRICKS_SERVER.Func.HolsterWeapon( ply )
	end
end )

hook.Add( "PlayerLoadout", "BRS.PlayerLoadout_InventorySWEP", function( ply )
	ply:Give( "bricks_server_invpickup" )

	for k, v in pairs( ply:BRS():GetInventory() or {} ) do
		if( not v[3] or not v[2] or v[2][1] != "spawned_weapon" or not v[2][3] ) then continue end

		ply:Give( v[2][3] )
	end
end)

hook.Add( "canDropWeapon", "BRS.canDropWeapon_Inventory", function( ply, wep )
	for k, v in pairs( ply:BRS():GetInventory() or {} ) do
		if( not v[3] or not v[2] or v[2][1] != "spawned_weapon" or (v[2][3] or "") != wep:GetClass() ) then continue end

		return false
	end
end )