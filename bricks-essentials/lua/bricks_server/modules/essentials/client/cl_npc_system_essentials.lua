net.Receive( "BRS.Net.UseTraderNPC", function()
	local NPCKey = net.ReadUInt( 8 )

	if( not NPCKey or not BRICKS_SERVER.CONFIG.NPCS[NPCKey] ) then return end

	if( not IsValid( BRICKS_SERVER_NPC_TRADER ) ) then
		BRICKS_SERVER_NPC_TRADER = vgui.Create( "bricks_server_ui_npc_trader" )
		BRICKS_SERVER_NPC_TRADER:SetNPCKey( NPCKey )
		BRICKS_SERVER_NPC_TRADER:RefreshInventory()
	end
end )

net.Receive( "BRS.Net.UseBankNPC", function()
	local NPCKey = net.ReadUInt( 8 )

	if( not NPCKey or not BRICKS_SERVER.CONFIG.NPCS[NPCKey] ) then return end

	if( not IsValid( BRICKS_SERVER_NPC_BANK ) ) then
		BRICKS_SERVER_NPC_BANK = vgui.Create( "bricks_server_ui_npc_bank" )
		BRICKS_SERVER_NPC_BANK:SetNPCKey( NPCKey )
		BRICKS_SERVER_NPC_BANK:RefreshInventory()
		BRICKS_SERVER_NPC_BANK:RefreshBank()
	end
end )

net.Receive( "BRS.Net.UseMoneyLaunderer", function()
	local NPCKey = net.ReadUInt( 8 )
	local NPCEnt = net.ReadEntity()

	if( not NPCKey or not BRICKS_SERVER.CONFIG.NPCS[NPCKey] ) then return end

	if( not IsValid( BRICKS_SERVER_NPC_LAUNDERER ) ) then
		BRICKS_SERVER_NPC_LAUNDERER = vgui.Create( "bricks_server_ui_npc_launderer" )
		BRICKS_SERVER_NPC_LAUNDERER:SetNPCKey( NPCKey, NPCEnt )
	end
end )

net.Receive( "BRS.Net.UseDeathscreens", function()
	local NPCKey = net.ReadUInt( 8 )

	if( not NPCKey or not BRICKS_SERVER.CONFIG.NPCS[NPCKey] ) then return end

	if( not IsValid( BRICKS_SERVER_NPC_DEATHSCREENS ) ) then
		BRICKS_SERVER_NPC_DEATHSCREENS = vgui.Create( "bricks_server_dframe" )
		BRICKS_SERVER_NPC_DEATHSCREENS:SetHeader( BRICKS_SERVER.CONFIG.NPCS[NPCKey].Name )
		BRICKS_SERVER_NPC_DEATHSCREENS:SetSize( ScrW()*0.6, ScrH()*0.65 )
		BRICKS_SERVER_NPC_DEATHSCREENS:Center()

		BRICKS_SERVER_NPC_DEATHSCREENS.deathscreensSheet = vgui.Create( "bricks_server_colsheet", BRICKS_SERVER_NPC_DEATHSCREENS )
		BRICKS_SERVER_NPC_DEATHSCREENS.deathscreensSheet:Dock( FILL )
		BRICKS_SERVER_NPC_DEATHSCREENS.deathscreensSheet.Navigation:DockMargin( 0, 10, 0, 0 )

		local pages = {
			{ "Cards", "bricks_server_deathscreens_cards", "icon_32.png" },
			{ "Emblems", "bricks_server_deathscreens_emblems", "emblem.png" },
			{ "Soundtracks", "bricks_server_deathscreens_soundtracks", "soundtrack.png" }
		}

		for k, v in pairs( pages ) do
			local deathscreensPage = vgui.Create( v[2], BRICKS_SERVER_NPC_DEATHSCREENS.deathscreensSheet )
			deathscreensPage:Dock( FILL )
			deathscreensPage:DockMargin( 10, 10, 10, 10 )
			deathscreensPage:FillPanel()
			BRICKS_SERVER_NPC_DEATHSCREENS.deathscreensSheet:AddSheet( v[1], deathscreensPage, function() end, v[3] )
		end
	else
		BRICKS_SERVER_NPC_DEATHSCREENS:SetVisible( true )

		for k, v in pairs( BRICKS_SERVER_NPC_DEATHSCREENS.deathscreensSheet.Items ) do
			v.Panel:FillPanel()
		end
	end
end )

function BRICKS_SERVER.Func.CreateTraderItemEditor( onSave, onCancel )
	BS_TRADERITEM_EDITOR = vgui.Create( "DFrame" )
	BS_TRADERITEM_EDITOR:SetSize( ScrW(), ScrH() )
	BS_TRADERITEM_EDITOR:Center()
	BS_TRADERITEM_EDITOR:SetTitle( "" )
	BS_TRADERITEM_EDITOR:ShowCloseButton( false )
	BS_TRADERITEM_EDITOR:SetDraggable( false )
	BS_TRADERITEM_EDITOR:MakePopup()
	BS_TRADERITEM_EDITOR:SetAlpha( 0 )
	BS_TRADERITEM_EDITOR:AlphaTo( 255, 0.1, 0 )
	BS_TRADERITEM_EDITOR.Paint = function( self2 ) 
		BRICKS_SERVER.Func.DrawBlur( self2, 4, 4 )
	end

	local backPanel = vgui.Create( "DPanel", BS_TRADERITEM_EDITOR )
	backPanel.Paint = function( self2, w, h ) 
		draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 0 ) )
		draw.RoundedBox( 5, 1, 1, w-2, h-2, BRICKS_SERVER.Func.GetTheme( 2 ) )
	end

	local itemTable = {}
	itemTable.Type = "Weapon"
	itemTable.Model = ""
	itemTable.Price = 100
	local tradeType = "Selling"

	local textArea

	local actions = {
		[1] = { "Trade Type", Material( "materials/bricks_server/folder.png" ), function()
			local options = { "Buying", "Selling" }
			BRICKS_SERVER.Func.ComboRequest( "Admin", "What trade type should this item be?", (tradeType or ""), options, function( value, data ) 
				if( options[data] ) then
					if( data == 1 ) then
						tradeType = "Buying"
					else
						tradeType = "Selling"
					end
					backPanel.FillActions()
					backPanel.FillOptions()
				else
					notification.AddLegacy( "Invalid type.", 1, 3 )
				end
			end, function() end, "OK", "Cancel" )
		end },
		[2] = { "Item Type", Material( "materials/bricks_server/amount.png" ), function()
			local typeOptions = {}
			local typeDevTable = BRICKS_SERVER.DEVCONFIG.NPCTypes["Trader"].BuyingTypes
			if( tradeType == "Selling" ) then
				typeDevTable = BRICKS_SERVER.DEVCONFIG.NPCTypes["Trader"].SellingTypes
			end
			for k, v in pairs( typeDevTable ) do
				typeOptions[k] = k
			end
			BRICKS_SERVER.Func.ComboRequest( "Admin", "What type should this item be?", (itemTable.Type or ""), typeOptions, function( value, data ) 
				if( typeDevTable[data] ) then
					itemTable.Type = data
					backPanel.FillActions()
					backPanel.FillOptions()
				else
					notification.AddLegacy( "Invalid item type.", 1, 3 )
				end
			end, function() end, "OK", "Cancel" )
		end, "Type" },
		[3] = { "Model", Material( "materials/bricks_server/icon.png" ), function()
			BRICKS_SERVER.Func.StringRequest( "Admin", "What should the model be?", (itemTable.Model or ""), function( text ) 
				itemTable.Model = text
			end, function() end, "OK", "Cancel", false )
		end, "Model" },
		[4] = { "Price", Material( "materials/bricks_server/currency.png" ), function()
			BRICKS_SERVER.Func.StringRequest( "Admin", "What should the price be?", (itemTable.Price or 0), function( number ) 
				itemTable.Price = number
			end, function() end, "OK", "Cancel", true )
		end, "Price" },
		[5] = { "Color", Material( "materials/bricks_server/color.png" ), function()
			BRICKS_SERVER.Func.ColorRequest( "Admin", "What should the new color be?", (itemTable.ModelColor or Color( 255, 255, 255 )), function( color ) 
				if( color == Color( 255, 255, 255 ) ) then
					itemTable.ModelColor = nil
				else
					itemTable.ModelColor = color
				end
			end, function() end, "OK", "Cancel" )
		end }
	}

	local originalActionsLen = #actions
	function backPanel.FillActions()
		for k, v in pairs( actions ) do
			if( k > originalActionsLen ) then
				actions[k] = nil
			end
		end

		local typeDevTable
		if( tradeType == "Selling" ) then
			typeDevTable = BRICKS_SERVER.DEVCONFIG.NPCTypes["Trader"].SellingTypes
		elseif( tradeType == "Buying" ) then
			typeDevTable = BRICKS_SERVER.DEVCONFIG.NPCTypes["Trader"].BuyingTypes
		end

		if( typeDevTable and itemTable.Type and typeDevTable[itemTable.Type] and typeDevTable[itemTable.Type].ReqInfo ) then
			for k, v in pairs( typeDevTable[itemTable.Type].ReqInfo ) do
				local actionTable = {}
				if( v[2] == "string" ) then
					actionTable = { v[1], Material( "materials/bricks_server/more_24.png" ), function()
						BRICKS_SERVER.Func.StringRequest( "Admin", "What should the " .. v[1] .. " be?", (itemTable.ReqInfo or {})[k] or "", function( text ) 
							itemTable.ReqInfo = itemTable.ReqInfo or {}
							itemTable.ReqInfo[k] = text
						end, function() end, "OK", "Cancel", false )
					end }
				elseif( v[2] == "integer" ) then
					actionTable = { v[1], Material( "materials/bricks_server/more_24.png" ), function()
						BRICKS_SERVER.Func.StringRequest( "Admin", "What should the " .. v[1] .. " be?", (itemTable.ReqInfo or {})[k] or 0, function( number ) 
							itemTable.ReqInfo = itemTable.ReqInfo or {}
							itemTable.ReqInfo[k] = number
						end, function() end, "OK", "Cancel", true )
					end }
				elseif( v[2] == "bool" ) then
					actionTable = { v[1], Material( "materials/bricks_server/more_24.png" ), function()
						itemTable.ReqInfo = itemTable.ReqInfo or {}
						itemTable.ReqInfo[k] = not (itemTable.ReqInfo or {})[k]
					end, false, function() return ((itemTable.ReqInfo or {})[k] and "TRUE") or "FALSE" end }
				elseif( v[2] == "table" ) then
					actionTable = { v[1], Material( "materials/bricks_server/more_24.png" ), function()
						local options = BRICKS_SERVER.Func.GetList( v[3] ) or {}
						BRICKS_SERVER.Func.ComboRequest( "Admin", "What should the " .. v[1] .. " be?", (itemTable.ReqInfo or {})[k] or "", options, function( value, data ) 
							if( options[data] ) then
								itemTable.ReqInfo = itemTable.ReqInfo or {}
								itemTable.ReqInfo[k] = data

								if( v[4] ) then
									local newItemTable = v[4]( itemTable ) 
									if( newItemTable ) then
										itemTable = newItemTable
									end
								end
							else
								notification.AddLegacy( "Invalid option.", 1, 3 )
							end
						end, function() end, "OK", "Cancel", true )
					end }
				end

				table.insert( actions, actionTable )
			end
		end
	end
	backPanel.FillActions()
	
	function backPanel.FillOptions()
		backPanel:Clear()

		textArea = vgui.Create( "DPanel", backPanel )
		textArea:Dock( TOP )
		textArea:DockMargin( 10, 10, 10, 0 )
		textArea:SetTall( 30 )
		textArea.Paint = function( self2, w, h ) 
			draw.SimpleText( "Trader Item Editor", "BRICKS_SERVER_Font20", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end

		for k, v in ipairs( actions ) do
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

				if( v[2] ) then
					surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
					surface.SetMaterial( v[2] )
					local iconSize = 24
					surface.DrawTexturedRect( (h-iconSize)/2, (h/2)-(iconSize/2), iconSize, iconSize )
				end

				if( v[4] and itemTable[v[4]] and not v[5] ) then
					draw.SimpleText( v[1] .. " - " .. string.sub( itemTable[v[4]], 1, 20 ), "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				elseif( v[5] and isfunction( v[5] ) ) then
					draw.SimpleText( v[1] .. " - " .. v[5](), "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				else
					draw.SimpleText( v[1], "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				end
			end
			actionButton.DoClick = function()
				if( v[3] ) then
					v[3]()
				end
			end
		end

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
			onSave( tradeType, itemTable )

			BS_TRADERITEM_EDITOR:AlphaTo( 0, 0.1, 0, function()
				if( IsValid( BS_TRADERITEM_EDITOR ) ) then
					BS_TRADERITEM_EDITOR:Remove()
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

			BS_TRADERITEM_EDITOR:AlphaTo( 0, 0.1, 0, function()
				if( IsValid( BS_TRADERITEM_EDITOR ) ) then
					BS_TRADERITEM_EDITOR:Remove()
				end
			end )
		end

		backPanel:SetSize( (2*10)+(2*150)+80, buttonPanel:GetTall()+(4*10)+textArea:GetTall()+(#actions*50) )
		backPanel:Center()

		leftButton:SetWide( (backPanel:GetWide()-30)/2 )
		rightButton:SetWide( (backPanel:GetWide()-30)/2 )
	end
	backPanel.FillOptions()
end