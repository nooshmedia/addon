BRICKS_SERVER.Func.AddConfigPage( "Inventory", "bricks_server_config_inventory", "essentials" )

BRICKS_SERVER.Func.AddAdminPlayerFunc( "Inventory", "View", function( ply ) 
	if( not IsValid( BS_ADMIN_INVENTORY ) ) then
		BS_ADMIN_INVENTORY = vgui.Create( "bricks_server_admin_inventory" )
	end

	net.Start( "BRS.Net.InventoryAdminRequest" )
		net.WriteString( ply:SteamID64() or "" )
	net.SendToServer()
end )

net.Receive( "BRS.Net.SetInventory", function()
	BRICKS_SERVER.LOCALPLYMETA.Inventory = net.ReadTable()
	hook.Run( "BRS.Hooks.FillInventory" )
end )

function BRICKS_SERVER.Func.OpenInventory( context )
	if( not IsValid( BRICKS_SERVER_INVENTORY ) ) then
		BRICKS_SERVER_INVENTORY = (context and g_ContextMenu:Add( "bricks_server_dframepanel" )) or vgui.Create( "bricks_server_dframe" )
		BRICKS_SERVER_INVENTORY:SetHeader( "Inventory" )
		BRICKS_SERVER_INVENTORY:SetSize( ScrW()*0.4, ScrH()*0.3 )
		BRICKS_SERVER_INVENTORY:SetPos( (ScrW()/2)-(BRICKS_SERVER_INVENTORY:GetWide()/2), ScrH()-20-BRICKS_SERVER_INVENTORY:GetTall() )
		BRICKS_SERVER_INVENTORY:SetMouseInputEnabled( true )

		BRICKS_SERVER_INVENTORY.invGrid = vgui.Create( "bricks_server_inventory_grid", BRICKS_SERVER_INVENTORY )
		BRICKS_SERVER_INVENTORY.invGrid:Dock( FILL )
		BRICKS_SERVER_INVENTORY.invGrid:DockMargin( 10, 10, 10, 10 )
		BRICKS_SERVER_INVENTORY.invGrid:FillPanel( BRICKS_SERVER_INVENTORY, false, BRICKS_SERVER_INVENTORY:GetWide()-20 )
	end
end

function BRICKS_SERVER.Func.CloseInventory()
	if( IsValid( BRICKS_SERVER_INVENTORY ) ) then
		BRICKS_SERVER_INVENTORY:Remove()
	end
end

hook.Add( "OnContextMenuOpen", "BRS.OnContextMenuOpen_OpenInventory", function()
	BRICKS_SERVER.Func.OpenInventory( true )
end )

hook.Add( "OnContextMenuClose", "BRS.OnContextMenuClose_CloseInventory", function()
	BRICKS_SERVER.Func.CloseInventory()
end )

net.Receive( "BRS.Net.InventoryAdminSend", function( len, ply )
	local requestedID64 = net.ReadString()
	local inventoryTable = net.ReadTable()
	local bankTable = net.ReadTable()
	local printersTable = net.ReadTable()
	local boostersTable = net.ReadTable()

	if( not requestedID64 or not inventoryTable ) then return end
	local requestedPly = player.GetBySteamID64( requestedID64 )

	if( IsValid( requestedPly ) ) then
		if( IsValid( BS_ADMIN_INVENTORY ) and BS_ADMIN_INVENTORY:IsVisible() and BS_ADMIN_INVENTORY.RefreshInventory ) then
			BS_ADMIN_INVENTORY:RefreshInventory( requestedID64, inventoryTable, bankTable, printersTable, boostersTable )
		end
	else
		notification.AddLegacy( "Invalid player inventory requested!", 1, 5 )
	end
end )

hook.Add( "InitPostEntity", "BRS.InitPostEntity_SendBindInfo", function()
    local bind1Name, bind1Key = BRICKS_SERVER.Func.GetClientBind( "PickupBind1" )
    if( bind1Key ) then
        net.Start( "BRS.Net.InventoryChangeBind" )
            net.WriteUInt( 1, 2 )
            net.WriteUInt( tonumber( bind1Key ), 8 )
        net.SendToServer()
    end

    local bind2Name, bind2Key = BRICKS_SERVER.Func.GetClientBind( "PickupBind2" )
    if( bind2Key ) then
        net.Start( "BRS.Net.InventoryChangeBind" )
            net.WriteUInt( 2, 2 )
            net.WriteUInt( tonumber( bind2Key ), 8 )
        net.SendToServer()
    end
end )

hook.Add( "OnEntityCreated", "BRS.OnEntityCreated_CreateEntityToolTips", function( ent )
	timer.Simple( 0.1, function()
		if( IsValid( ent ) ) then
			local entClass = ent:GetClass()

			if( (BRICKS_SERVER.CONFIG.INVENTORY.Whitelist or {})[entClass] ) then
				local itemData, amount = BRICKS_SERVER.Func.GetEntTypeField( entClass, "GetItemData" )( ent )
				local itemInfo = BRICKS_SERVER.Func.GetEntTypeField( entClass, "GetInfo" )( itemData )

				local pickupText = ""
				local binds = (BRICKS_SERVER.CONFIG.INVENTORY.Whitelist or {})[entClass]
				if( binds[1] and binds[2] ) then
					pickupText = "Press " .. (BRICKS_SERVER.Func.GetClientBind( "PickupBind1" ) or "UNBOUND") .. "+" .. (BRICKS_SERVER.Func.GetClientBind( "PickupBind2" ) or "UNBOUND") .. " to put in inventory"
				elseif( binds[2] ) then
					pickupText = "Press " .. string.upper( (BRICKS_SERVER.Func.GetClientBind( "PickupBind2" ) or "UNBOUND") ) .. " to put in inventory"
				elseif( binds[1] ) then
					pickupText = "Press " .. string.upper( (BRICKS_SERVER.Func.GetClientBind( "PickupBind1" ) or "UNBOUND") ) .. " to put in inventory"
				end
				
				local tooltipInfo = {}
				tooltipInfo[1] = { "x" .. amount .. " " .. itemInfo[1], false, "BRICKS_SERVER_Font23B" }
				if( itemInfo[3] ) then
					local rarityInfo = BRICKS_SERVER.Func.GetRarityInfo( itemInfo[3] )
					tooltipInfo[2] = { itemInfo[3], function() return BRICKS_SERVER.Func.GetRarityColor( rarityInfo ) end, "BRICKS_SERVER_Font17" }
				end

				if( #itemInfo > 3 ) then
					for i = 4, #itemInfo do
						table.insert( tooltipInfo, itemInfo[i] )
					end
				end

				table.insert( tooltipInfo, pickupText )
				
				ent:SetBRSEntityToolTip( tooltipInfo )
			end
		end
	end )
end )

hook.Add( "PlayerButtonDown", "BRS.PlayerButtonDown_Holster", function( ply, button )
	local bindText, bindButton = BRICKS_SERVER.Func.GetClientBind( "HolsterBind" )
	if( button == bindButton and CurTime() >= (BRS_HOLSTERCOOLDOWN or 0) ) then
		BRS_HOLSTERCOOLDOWN = CurTime()+1
		RunConsoleCommand( "holster" )
	end
end )

function BRICKS_SERVER.Func.CreateInventorySlotEditor( slotTable, title, onSave, onCancel )
	BS_INVENTORY_SLOT_EDITOR = vgui.Create( "DFrame" )
	BS_INVENTORY_SLOT_EDITOR:SetSize( ScrW(), ScrH() )
	BS_INVENTORY_SLOT_EDITOR:Center()
	BS_INVENTORY_SLOT_EDITOR:SetTitle( "" )
	BS_INVENTORY_SLOT_EDITOR:ShowCloseButton( false )
	BS_INVENTORY_SLOT_EDITOR:SetDraggable( false )
	BS_INVENTORY_SLOT_EDITOR:MakePopup()
	BS_INVENTORY_SLOT_EDITOR:SetAlpha( 0 )
	BS_INVENTORY_SLOT_EDITOR:AlphaTo( 255, 0.1, 0 )
	BS_INVENTORY_SLOT_EDITOR.Paint = function( self2 ) 
		BRICKS_SERVER.Func.DrawBlur( self2, 4, 4 )
	end

	local backPanel = vgui.Create( "DPanel", BS_INVENTORY_SLOT_EDITOR )
	backPanel.Paint = function( self2, w, h ) 
		draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 0 ) )
		draw.RoundedBox( 5, 1, 1, w-2, h-2, BRICKS_SERVER.Func.GetTheme( 2 ) )
	end

	local slotsTable = table.Copy( slotTable )
	local textArea

	for k, v in pairs( slotsTable ) do
		if( k == "Default" ) then continue end

		local groupExists = false
		for key, val in pairs( BS_ConfigCopyTable.GENERAL.Groups ) do
			if( k == val[1] ) then 
				groupExists = true
				break
			end
		end

		if( not groupExists ) then
			slotsTable[k] = nil
		end
	end

	local slotCount = 0
	local function AddSlot( key )
		slotCount = slotCount+1

		local actionButton = vgui.Create( "DButton", backPanel )
		actionButton:SetText( "" )
		actionButton:Dock( TOP )
		actionButton:DockMargin( 10, 10, 10, 0 )
		actionButton:SetTall( 40 )
		local changeAlpha = 0
		actionButton.Paint = function( self2, w, h )
			if( self2:IsDown() ) then
				changeAlpha = math.Clamp( changeAlpha+10, 0, 255 )
			elseif( self2:IsHovered() ) then
				changeAlpha = math.Clamp( changeAlpha+10, 0, 255 )
			else
				changeAlpha = math.Clamp( changeAlpha-10, 0, 255 )
			end
			
			draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
	
			surface.SetAlphaMultiplier( changeAlpha/255 )
				draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 5 ) )
			surface.SetAlphaMultiplier( 1 )

			draw.SimpleText( key .. " - " .. (slotsTable[key] or 0) .. " Slots", "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
		actionButton.DoClick = function()
			BRICKS_SERVER.Func.StringRequest( "Admin", "How many slots should this group have?", (slotsTable[key] or 0), function( number ) 
				slotsTable[key] = number
			end, function() end, "OK", "Cancel", true )
		end
	end

	function backPanel.FillInventorySlots()
		slotCount = 0
		backPanel:Clear()

		textArea = vgui.Create( "DPanel", backPanel )
		textArea:Dock( TOP )
		textArea:DockMargin( 10, 10, 10, 0 )
		textArea:SetTall( 30 )
		textArea.Paint = function( self2, w, h ) 
			draw.SimpleText( title .. " Slot Editor", "BRICKS_SERVER_Font20", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end

		for k, v in ipairs( BS_ConfigCopyTable.GENERAL.Groups ) do
			AddSlot( v[1] )
		end

		AddSlot( "Default" )

		local buttonPanel = vgui.Create( "DPanel", backPanel )
		buttonPanel:Dock( BOTTOM )
		buttonPanel:DockMargin( 10, 10, 10, 10 )
		buttonPanel:SetTall( 40 )
		buttonPanel.Paint = function( self2, w, h ) end
	
		local leftButton = vgui.Create( "DButton", buttonPanel )
		leftButton:Dock( LEFT )
		leftButton:SetText( "" )
		leftButton:DockMargin( 0, 0, 0, 0 )
		local changeAlpha = 0
		leftButton.Paint = function( self2, w, h )
			if( self2:IsHovered() ) then
				changeAlpha = math.Clamp( changeAlpha+10, 0, 255 )
			else
				changeAlpha = math.Clamp( changeAlpha-10, 0, 255 )
			end
			
			draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.DEVCONFIG.BaseThemes.Green )
	
			surface.SetAlphaMultiplier( changeAlpha/255 )
			draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.DEVCONFIG.BaseThemes.DarkGreen )
			surface.SetAlphaMultiplier( 1 )
	
			draw.SimpleText( "Save", "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
		leftButton.DoClick = function()
			onSave( slotsTable )
	
			BS_INVENTORY_SLOT_EDITOR:AlphaTo( 0, 0.1, 0, function()
				if( IsValid( BS_INVENTORY_SLOT_EDITOR ) ) then
					BS_INVENTORY_SLOT_EDITOR:Remove()
				end
			end )
		end
	
		local rightButton = vgui.Create( "DButton", buttonPanel )
		rightButton:Dock( RIGHT )
		rightButton:SetText( "" )
		rightButton:DockMargin( 0, 0, 0, 0 )
		local changeAlpha = 0
		rightButton.Paint = function( self2, w, h )
			if( self2:IsHovered() ) then
				changeAlpha = math.Clamp( changeAlpha+10, 0, 255 )
			else
				changeAlpha = math.Clamp( changeAlpha-10, 0, 255 )
			end
			
			draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.DEVCONFIG.BaseThemes.Red )
	
			surface.SetAlphaMultiplier( changeAlpha/255 )
			draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.DEVCONFIG.BaseThemes.DarkRed )
			surface.SetAlphaMultiplier( 1 )
	
			draw.SimpleText( "Cancel", "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
		rightButton.DoClick = function()
			onCancel()
	
			BS_INVENTORY_SLOT_EDITOR:AlphaTo( 0, 0.1, 0, function()
				if( IsValid( BS_INVENTORY_SLOT_EDITOR ) ) then
					BS_INVENTORY_SLOT_EDITOR:Remove()
				end
			end )
		end
	
		backPanel:SetSize( (2*10)+(2*150)+80, buttonPanel:GetTall()+(3*10)+textArea:GetTall()+(slotCount*50) )
		backPanel:Center()
	
		leftButton:SetWide( (backPanel:GetWide()-30)/2 )
		rightButton:SetWide( (backPanel:GetWide()-30)/2 )
	end
	backPanel.FillInventorySlots()
end