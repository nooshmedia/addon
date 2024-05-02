BRICKS_SERVER.Func.AddConfigPage( "Printers", "bricks_server_config_printers", "essentials" )

BRS_PRINTERS = {}
net.Receive( "BRS.Net.SetPrinters", function()
	local printersTable = net.ReadTable()

	BRS_PRINTERS = printersTable or {}

	hook.Run( "BRS.Hooks.FillPrinters" )
end )

function BRICKS_SERVER.Func.CreatePrinterEditor( oldPrinterTable, onSave, onCancel )
	BS_PRINTER_EDITOR = vgui.Create( "DFrame" )
	BS_PRINTER_EDITOR:SetSize( ScrW(), ScrH() )
	BS_PRINTER_EDITOR:Center()
	BS_PRINTER_EDITOR:SetTitle( "" )
	BS_PRINTER_EDITOR:ShowCloseButton( false )
	BS_PRINTER_EDITOR:SetDraggable( false )
	BS_PRINTER_EDITOR:MakePopup()
	BS_PRINTER_EDITOR:SetAlpha( 0 )
	BS_PRINTER_EDITOR:AlphaTo( 255, 0.1, 0 )
	BS_PRINTER_EDITOR.Paint = function( self2 ) 
		BRICKS_SERVER.Func.DrawBlur( self2, 4, 4 )
	end

	local backPanel = vgui.Create( "DPanel", BS_PRINTER_EDITOR )
	backPanel.Paint = function( self2, w, h ) 
		draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 0 ) )
		draw.RoundedBox( 5, 1, 1, w-2, h-2, BRICKS_SERVER.Func.GetTheme( 2 ) )
	end

	local printerTable = table.Copy( oldPrinterTable )

	local textArea = vgui.Create( "DPanel", backPanel )
	textArea:Dock( TOP )
	textArea:DockMargin( 10, 10, 10, 0 )
	textArea:SetTall( 30 )
	textArea.Paint = function( self2, w, h ) 
		draw.SimpleText( "Printer Editor - " .. printerTable.Name .. " Tier", "BRICKS_SERVER_Font20", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end

	local actions = {
		[1] = { "Name", Material( "materials/bricks_server/name.png" ), function()
			BRICKS_SERVER.Func.StringRequest( "Admin", "What should the new name be?", printerTable.Name, function( text ) 
				printerTable.Name = text
			end, function() end, "OK", "Cancel", false )
		end, "Name" },
		[2] = { "Upgrade Cost", Material( "materials/bricks_server/upgrade_24.png" ), function()
			BRICKS_SERVER.Func.StringRequest( "Admin", "What should the new upgrade cost be?", printerTable.UpgradeCost, function( text ) 
				if( isnumber( tonumber( text ) ) ) then
					printerTable.UpgradeCost = text
				else
					notification.AddLegacy( "Invalid number.", 1, 3 )
				end
			end, function() end, "OK", "Cancel", true )
		end, "UpgradeCost", true },
		[3] = { "Model Color", Material( "materials/bricks_server/color.png" ), function()
			BRICKS_SERVER.Func.ColorRequest( "Admin", "What should the new color be?", printerTable.ModelColor, function( color ) 
				printerTable.ModelColor = color
			end, function() end, "OK", "Cancel" )
		end },
		[4] = { "Screen Color", Material( "materials/bricks_server/screen.png" ), function()
			BRICKS_SERVER.Func.ColorRequest( "Admin", "What should the new screen color be?", printerTable.ScreenColor, function( color ) 
				printerTable.ScreenColor = color
			end, function() end, "OK", "Cancel" )
		end },
		[5] = { "Amount", Material( "materials/bricks_server/amount.png" ), function()
			BRICKS_SERVER.Func.StringRequest( "Admin", "How much money should be made per print?", printerTable.PrintAmount or 0, function( text ) 
				if( isnumber( tonumber( text ) ) ) then
					printerTable.PrintAmount = text
				else
					notification.AddLegacy( "Invalid number.", 1, 3 )
				end
			end, function() end, "OK", "Cancel", true )
		end, "PrintAmount", true },
		[6] = { "Storage", Material( "materials/bricks_server/storage.png" ), function()
			BRICKS_SERVER.Func.StringRequest( "Admin", "How much money can be stored in this printer?", printerTable.MoneyStorage or 0, function( text ) 
				if( isnumber( tonumber( text ) ) ) then
					printerTable.MoneyStorage = text
				else
					notification.AddLegacy( "Invalid number.", 1, 3 )
				end
			end, function() end, "OK", "Cancel", true )
		end, "MoneyStorage", true },
		[7] = { "Speed", Material( "materials/bricks_server/speed.png" ), function()
			BRICKS_SERVER.Func.StringRequest( "Admin", "How often should it print in seconds?", printerTable.PrintSpeed or 0, function( text ) 
				if( isnumber( tonumber( text ) ) ) then
					printerTable.PrintSpeed = text
				else
					notification.AddLegacy( "Invalid number.", 1, 3 )
				end
			end, function() end, "OK", "Cancel", true )
		end, "PrintSpeed" },
		[8] = { "Max Ink", Material( "materials/bricks_server/ink.png" ), function()
			BRICKS_SERVER.Func.StringRequest( "Admin", "How much ink can be stored?", printerTable.MaxInk or 0, function( text ) 
				if( isnumber( tonumber( text ) ) ) then
					printerTable.MaxInk = text
				else
					notification.AddLegacy( "Invalid number.", 1, 3 )
				end
			end, function() end, "OK", "Cancel", true )
		end, "MaxInk" },
		[9] = { "Health", Material( "materials/bricks_server/health.png" ), function()
			BRICKS_SERVER.Func.StringRequest( "Admin", "How much health should it have?", printerTable.Health or 0, function( text ) 
				if( isnumber( tonumber( text ) ) ) then
					printerTable.Health = text
				else
					notification.AddLegacy( "Invalid number.", 1, 3 )
				end
			end, function() end, "OK", "Cancel", true )
		end, "Health" },
	}

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

			if( v[4] and printerTable[v[4]] ) then
				if( v[5] ) then
					draw.SimpleText( v[1] .. " - " .. DarkRP.formatMoney( printerTable[v[4]] ), "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				else
					draw.SimpleText( v[1] .. " - " .. printerTable[v[4]], "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				end
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
		onSave( printerTable )

		BS_PRINTER_EDITOR:AlphaTo( 0, 0.1, 0, function()
			if( IsValid( BS_PRINTER_EDITOR ) ) then
				BS_PRINTER_EDITOR:Remove()
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

		BS_PRINTER_EDITOR:AlphaTo( 0, 0.1, 0, function()
			if( IsValid( BS_PRINTER_EDITOR ) ) then
				BS_PRINTER_EDITOR:Remove()
			end
		end )
	end

	backPanel:SetSize( (2*10)+(2*150)+80, buttonPanel:GetTall()+(4*10)+textArea:GetTall()+(#actions*50) )
	backPanel:Center()

	leftButton:SetWide( (backPanel:GetWide()-30)/2 )
	rightButton:SetWide( (backPanel:GetWide()-30)/2 )
end

function BRICKS_SERVER.Func.CreatePrinterSlotEditor( onSave, onCancel )
	BS_PRINTER_SLOT_EDITOR = vgui.Create( "DFrame" )
	BS_PRINTER_SLOT_EDITOR:SetSize( ScrW(), ScrH() )
	BS_PRINTER_SLOT_EDITOR:Center()
	BS_PRINTER_SLOT_EDITOR:SetTitle( "" )
	BS_PRINTER_SLOT_EDITOR:ShowCloseButton( false )
	BS_PRINTER_SLOT_EDITOR:SetDraggable( false )
	BS_PRINTER_SLOT_EDITOR:MakePopup()
	BS_PRINTER_SLOT_EDITOR:SetAlpha( 0 )
	BS_PRINTER_SLOT_EDITOR:AlphaTo( 255, 0.1, 0 )
	BS_PRINTER_SLOT_EDITOR.Paint = function( self2 ) 
		BRICKS_SERVER.Func.DrawBlur( self2, 4, 4 )
	end

	local backPanel = vgui.Create( "DPanel", BS_PRINTER_SLOT_EDITOR )
	backPanel.Paint = function( self2, w, h ) 
		draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 0 ) )
		draw.RoundedBox( 5, 1, 1, w-2, h-2, BRICKS_SERVER.Func.GetTheme( 2 ) )
	end

	local slotsTable = table.Copy( (BS_ConfigCopyTable or BRICKS_SERVER.CONFIG).PRINTERS.PrinterSlots )
	local textArea

	function backPanel.FillPrinterSlot( slotKey )
		local rewardSlotTable = slotsTable[slotKey] or {}
		backPanel:Clear()

		local slotActions = {
			[1] = { "Price", Material( "materials/bricks_server/currency.png" ), function()
				BRICKS_SERVER.Func.StringRequest( "Admin", "What should the new price be?", (slotsTable[slotKey].Price or 0), function( text )
					if( text > 0 ) then 
						slotsTable[slotKey].Price = text
					else
						slotsTable[slotKey].Price = nil
					end
				end, function() end, "OK", "Cancel", true )
			end, "Price", function() return DarkRP.formatMoney( slotsTable[slotKey].Price or 0 ) end },
			[2] = { "Group", Material( "materials/bricks_server/group.png" ), function()
				local options = {}
				options["None"] = "None"
                for k, v in pairs( (BS_ConfigCopyTable or BRICKS_SERVER.CONFIG).GENERAL.Groups ) do
                    options[k] = v[1]
                end
                BRICKS_SERVER.Func.ComboRequest( "Admin", "What group would you like this slot to be?", (slotsTable[slotKey].Group or ""), options, function( value, data ) 
                    if( (BS_ConfigCopyTable or BRICKS_SERVER.CONFIG).GENERAL.Groups[data] ) then
                        slotsTable[slotKey].Group = value
					elseif( value == "None" ) then
						slotsTable[slotKey].Group = nil
					else
                        notification.AddLegacy( "Invalid group.", 1, 3 )
                    end
                end, function() end, "OK", "Cancel" )
			end, "Group" },
		}

		if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "levelling" ) ) then
			slotActions[3] = { "Level", Material( "materials/bricks_server/level.png" ), function()
				BRICKS_SERVER.Func.StringRequest( "Admin", "What should the new level requirement be?", (slotsTable[slotKey].Level or 0), function( text ) 
					if( text > 0 ) then 
						slotsTable[slotKey].Level = text
					else
						slotsTable[slotKey].Level = nil
					end
				end, function() end, "OK", "Cancel", true )
			end, "Level" }
		end

		textArea = vgui.Create( "DPanel", backPanel )
		textArea:Dock( TOP )
		textArea:DockMargin( 10, 10, 10, 0 )
		textArea:SetTall( 30 )
		textArea.Paint = function( self2, w, h ) 
			if( slotKey == 1 ) then
				draw.SimpleText( "Printer Slot Editor - " .. slotKey .. "st Slot", "BRICKS_SERVER_Font20", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			elseif( slotKey == 2 ) then
				draw.SimpleText( "Printer Slot Editor - " .. slotKey .. "nd Slot", "BRICKS_SERVER_Font20", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			elseif( slotKey == 3 ) then
				draw.SimpleText( "Printer Slot Editor - " .. slotKey .. "rd Slot", "BRICKS_SERVER_Font20", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			else
				draw.SimpleText( "Printer Slot Editor - " .. slotKey .. "th Slot", "BRICKS_SERVER_Font20", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			end
		end

		for k, v in pairs( slotActions ) do
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

				if( v[4] and slotsTable[slotKey][v[4]] and not v[5] ) then
					draw.SimpleText( v[1] .. " - " .. slotsTable[slotKey][v[4]], "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				elseif( v[5] and isfunction( v[5] ) ) then
					draw.SimpleText( v[1] .. " - " .. v[5](), "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				else
					draw.SimpleText( v[1], "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				end
			end
			actionButton.DoClick = function()
				v[3]()
			end
		end

		local mainButton = vgui.Create( "DButton", backPanel )
		mainButton:Dock( BOTTOM )
		mainButton:DockMargin( 10, 10, 10, 10 )
		mainButton:SetTall( 40 )
		mainButton:SetText( "" )
		local changeAlpha = 0
		mainButton.Paint = function( self2, w, h )
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
		mainButton.DoClick = function()
			backPanel.FillPrinterSlots()
		end
	
		backPanel:SetSize( (2*10)+(2*150)+80, mainButton:GetTall()+(4*10)+textArea:GetTall()+(#slotActions*50) )
		backPanel:Center()
	end

	function backPanel.FillPrinterSlots()
		backPanel:Clear()

		textArea = vgui.Create( "DPanel", backPanel )
		textArea:Dock( TOP )
		textArea:DockMargin( 10, 10, 10, 0 )
		textArea:SetTall( 30 )
		textArea.Paint = function( self2, w, h ) 
			draw.SimpleText( "Printer Slot Editor", "BRICKS_SERVER_Font20", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end

		for k, v in ipairs( slotsTable ) do
			local actionButtonBack = vgui.Create( "DPanel", backPanel )
			actionButtonBack:Dock( TOP )
			actionButtonBack:DockMargin( 10, 10, 10, 0 )
			actionButtonBack:SetTall( 40 )
			actionButtonBack.Paint = function() end

			local actionButtonDelete = vgui.Create( "DButton", actionButtonBack )
			actionButtonDelete:SetText( "" )
			actionButtonDelete:Dock( RIGHT )
			actionButtonDelete:DockMargin( 5, 0, 0, 0 )
			actionButtonDelete:SetWide( actionButtonBack:GetTall() )
			local changeAlpha = 0
			local deleteMat = Material( "materials/bricks_server/delete.png" )
			actionButtonDelete.Paint = function( self2, w, h )
				if( self2:IsDown() ) then
					changeAlpha = math.Clamp( changeAlpha+10, 0, 255 )
				elseif( self2:IsHovered() ) then
					changeAlpha = math.Clamp( changeAlpha+10, 0, 255 )
				else
					changeAlpha = math.Clamp( changeAlpha-10, 0, 255 )
				end
				
				draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.DEVCONFIG.BaseThemes.Red )
		
				surface.SetAlphaMultiplier( changeAlpha/255 )
					draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.DEVCONFIG.BaseThemes.DarkRed )
				surface.SetAlphaMultiplier( 1 )

				surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
				surface.SetMaterial( deleteMat )
				local iconSize = h*0.65
				surface.DrawTexturedRect( (h-iconSize)/2, (h/2)-(iconSize/2), iconSize, iconSize )
			end
			actionButtonDelete.DoClick = function()
				table.remove( slotsTable, k )
				backPanel.FillPrinterSlots()
			end

			local actionButton = vgui.Create( "DButton", actionButtonBack )
			actionButton:SetText( "" )
			actionButton:Dock( FILL )
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

				if( k == 1 ) then
					draw.SimpleText( k .. "st Slot", "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				elseif( k == 2 ) then
					draw.SimpleText( k .. "nd Slot", "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				elseif( k == 3 ) then
					draw.SimpleText( k .. "rd Slot", "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				else
					draw.SimpleText( k .. "th Slot", "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				end
			end
			actionButton.DoClick = function()
				backPanel.FillPrinterSlot( k )
			end
		end

		local newSlotButton = vgui.Create( "DButton", backPanel )
		newSlotButton:SetText( "" )
		newSlotButton:Dock( TOP )
		newSlotButton:DockMargin( 10, 10, 10, 0 )
		newSlotButton:SetTall( 40 )
		local changeAlpha = 0
		newSlotButton.Paint = function( self2, w, h )
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

			draw.SimpleText( "Add new slot", "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
		newSlotButton.DoClick = function()
			slotsTable[#slotsTable+1] = {}
			backPanel.FillPrinterSlots()
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
			onSave( slotsTable )
	
			BS_PRINTER_SLOT_EDITOR:AlphaTo( 0, 0.1, 0, function()
				if( IsValid( BS_PRINTER_SLOT_EDITOR ) ) then
					BS_PRINTER_SLOT_EDITOR:Remove()
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
	
			BS_PRINTER_SLOT_EDITOR:AlphaTo( 0, 0.1, 0, function()
				if( IsValid( BS_PRINTER_SLOT_EDITOR ) ) then
					BS_PRINTER_SLOT_EDITOR:Remove()
				end
			end )
		end
	
		backPanel:SetSize( (2*10)+(2*150)+80, buttonPanel:GetTall()+(5*10)+textArea:GetTall()+((#slotsTable or 10)*50)+newSlotButton:GetTall() )
		backPanel:Center()
	
		leftButton:SetWide( (backPanel:GetWide()-30)/2 )
		rightButton:SetWide( (backPanel:GetWide()-30)/2 )
	end
	backPanel.FillPrinterSlots()
end