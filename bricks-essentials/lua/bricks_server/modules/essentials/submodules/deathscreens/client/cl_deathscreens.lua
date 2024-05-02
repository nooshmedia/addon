BRICKS_SERVER.Func.AddConfigPage( "Deathscreens", "bricks_server_config_deathscreens", "essentials" )

BRS_DEATHSCREENS_DATA = BRS_DEATHSCREENS_DATA or {}
net.Receive( "BRS.Net.SetDeathscreens", function()
	local deathscreensData = net.ReadTable()

	BRS_DEATHSCREENS_DATA = deathscreensData or {}
end )

net.Receive( "BRS.Net.Deathscreen_Killed", function( len, ply )
	local deathscreenCard = net.ReadString()
	local deathscreenEmblem = net.ReadString()
	local deathscreenSound = net.ReadString()
	local deathscreenWeapon = net.ReadString()
	local deathscreenKiller = net.ReadString()

	if( BRS_DEATHSCREEN and IsValid( BRS_DEATHSCREEN.Panel ) ) then
        BRS_DEATHSCREEN.Panel:Remove()
	end
	
	BRS_DEATHSCREEN = {}
	if( deathscreenEmblem != "" ) then
		if( not string.EndsWith( deathscreenEmblem, ".gif" ) ) then
			BRICKS_SERVER.Func.GetImage( deathscreenEmblem or "", function( mat ) 
				if( not BRS_DEATHSCREEN ) then return end
				
				BRS_DEATHSCREEN.Emblem = mat 
			end )
		else
			BRS_DEATHSCREEN.Emblem = deathscreenEmblem
		end
	end

	if( deathscreenKiller != "" ) then
		BRS_DEATHSCREEN.Killer = player.GetBySteamID64( deathscreenKiller )
	end

	if( deathscreenWeapon != "" ) then
		BRS_DEATHSCREEN.Weapon = deathscreenWeapon
	end

	if( deathscreenCard == "" ) then
		deathscreenCard = BRICKS_SERVER.CONFIG.DEATHSCREENS["Default Playercard"]
	end

	if( deathscreenCard and deathscreenCard != "" ) then
		if( not string.EndsWith( deathscreenCard, ".gif" ) ) then
			BRICKS_SERVER.Func.GetImage( deathscreenCard or "", function( mat ) 
				if( not BRS_DEATHSCREEN ) then return end

				BRS_DEATHSCREEN.Card = mat 
			end )
		else
			BRS_DEATHSCREEN.Card = deathscreenCard
		end
	end

	if( deathscreenSound != "" ) then
		sound.PlayURL( deathscreenSound, "mono", function( station )
			if( not BRS_DEATHSCREEN ) then return end
			
			if( IsValid( station ) ) then
				BRS_DEATHSCREEN.Sound = station
				BRS_DEATHSCREEN.Sound:Play()
			elseif( BRICKS_SERVER.Func.HasAdminAccess( LocalPlayer() ) ) then
				notification.AddLegacy( "Invalid sound URL!", 1, 5 )
			end
		end )
	end

    BRS_DEATHSCREEN.Panel = vgui.Create( "DPanel" )
	BRS_DEATHSCREEN.Panel:SetPos( 0, 0 )
	BRS_DEATHSCREEN.Panel:SetSize( ScrW(), ScrH() )
	BRS_DEATHSCREEN.Panel:ParentToHUD()
	local cardW, cardH, emblemSize, xInnerSpacing, yInnerSpacing = 512, 128, 116, 10, 10
	local topH = 35
	local largestH = (((emblemSize > cardH) and emblemSize) or cardH)
	local totalW, totalH = largestH+cardW+(3*xInnerSpacing), largestH+(2*yInnerSpacing)+topH+5
	local ySpacing, topMargin = 50, topH
	BRS_DEATHSCREEN.Panel.Paint = function( self2, w, h )
		surface.SetDrawColor( 0, 0, 0, 150 )
		surface.DrawRect( 0, 0, w, h )
		BRICKS_SERVER.Func.DrawBlur( self2, 4, 4 )

		BRICKS_SERVER.BSHADOWS.BeginShadow()
		local x, y = self2:LocalToScreen( (w/2)-(totalW/2), h-ySpacing-totalH )
		draw.RoundedBox( 5, x, y, totalW, totalH, BRICKS_SERVER.Func.GetTheme( 0 ) )			
		BRICKS_SERVER.BSHADOWS.EndShadow(1, 5, 1, 255, 50, 5, false )

		if( BRS_DEATHSCREEN.Emblem and not isstring( BRS_DEATHSCREEN.Emblem ) ) then
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetMaterial( BRS_DEATHSCREEN.Emblem )
			surface.DrawTexturedRect( (w/2)-(totalW/2)+xInnerSpacing+(largestH/2)-(emblemSize/2), h-ySpacing-totalH+yInnerSpacing+topMargin+(cardH/2)-(emblemSize/2), emblemSize, emblemSize )

			if( IsValid( BRS_DEATHSCREEN.Panel.Avatar ) ) then
				BRS_DEATHSCREEN.Panel.Avatar:Remove()
			end
		end

		if( BRS_DEATHSCREEN.Card and not isstring( BRS_DEATHSCREEN.Card ) ) then
			BRICKS_SERVER.Func.DrawRoundedMask( 8, (w/2)-(totalW/2)+largestH+(2*xInnerSpacing), h-ySpacing-totalH+yInnerSpacing+topMargin, cardW, cardH, function()
				surface.SetDrawColor( 255, 255, 255, 255 )
				surface.SetMaterial( BRS_DEATHSCREEN.Card )
				surface.DrawTexturedRect( (w/2)-(totalW/2)+largestH+(2*xInnerSpacing), h-ySpacing-totalH+yInnerSpacing+topMargin, cardW, cardH )
			end )
		end

		if( IsValid( BRS_DEATHSCREEN.Killer ) ) then
			draw.RoundedBoxEx( 5, (w/2)-(totalW/2), h-ySpacing-totalH, totalW, topH, BRICKS_SERVER.Func.GetTheme( 2 ), true, true, false, false )

			draw.SimpleText( BRS_DEATHSCREEN.Killer:Nick(), "BRICKS_SERVER_Font25", (w/2)-(totalW/2)+10, h-ySpacing-totalH+(topH/2)-2, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_CENTER )
			draw.SimpleText( "Killed by", "BRICKS_SERVER_Font33", w/2-1, h-ySpacing-totalH-15+1, BRICKS_SERVER.Func.GetTheme( 0 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
			draw.SimpleText( "Killed by", "BRICKS_SERVER_Font33", w/2, h-ySpacing-totalH-15, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
			if( BRS_DEATHSCREEN.Killer != LocalPlayer() ) then
				draw.SimpleText( "Killed with: " .. (BRS_DEATHSCREEN.Weapon or "AK-47"), "BRICKS_SERVER_Font25", (w/2)+(totalW/2)-10, h-ySpacing-totalH+(topH/2)-2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
			else
				draw.SimpleText( "Committed suicide", "BRICKS_SERVER_Font25", (w/2)+(totalW/2)-10, h-ySpacing-totalH+(topH/2)-2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
			end
		end
	end

	if( not BRS_DEATHSCREEN.Emblem ) then
		BRS_DEATHSCREEN.Panel.Avatar = vgui.Create( "bricks_server_circle_avatar", BRS_DEATHSCREEN.Panel )
		BRS_DEATHSCREEN.Panel.Avatar:SetSize( emblemSize, emblemSize )
		BRS_DEATHSCREEN.Panel.Avatar:SetPos( (ScrW()/2)-(totalW/2)+xInnerSpacing+(largestH/2)-(emblemSize/2), ScrH()-ySpacing-totalH+yInnerSpacing+topMargin+(cardH/2)-(emblemSize/2) )
		if( IsValid( BRS_DEATHSCREEN.Killer ) ) then
			BRS_DEATHSCREEN.Panel.Avatar:SetPlayer( BRS_DEATHSCREEN.Killer, 128 )
		end
	elseif( isstring( BRS_DEATHSCREEN.Emblem ) and string.EndsWith( BRS_DEATHSCREEN.Emblem, ".gif" ) ) then
		local html = vgui.Create( "DHTML", BRS_DEATHSCREEN.Panel )
		html:SetSize( emblemSize, emblemSize )
		html:SetPos( (ScrW()/2)-(totalW/2)+xInnerSpacing+(largestH/2)-(emblemSize/2), ScrH()-ySpacing-totalH+yInnerSpacing+topMargin+(cardH/2)-(emblemSize/2) )
		html:SetHTML( [[
			<body scroll="no" style="overflow: hidden; margin: 0;">
			<img src="]] .. BRS_DEATHSCREEN.Emblem ..  [[" width=]] .. html:GetWide() .. [[ height = ]] .. html:GetTall() .. [[/>
			</body>
		]] )
	end

	if( BRS_DEATHSCREEN.Card and isstring( BRS_DEATHSCREEN.Card ) and string.EndsWith( BRS_DEATHSCREEN.Card, ".gif" ) ) then
		local html = vgui.Create( "DHTML", BRS_DEATHSCREEN.Panel )
		html:SetSize( cardW, cardH )
		html:SetPos( (ScrW()/2)-(totalW/2)+largestH+(2*xInnerSpacing), ScrH()-ySpacing-totalH+yInnerSpacing+topMargin )
		html:SetHTML( [[
			<body scroll="no" style="overflow: hidden; margin: 0;">
			<img src="]] .. BRS_DEATHSCREEN.Card ..  [[" width=]] .. html:GetWide() .. [[ height = ]] .. html:GetTall() .. [[/>
			</body>
		]] )
	end
end )

net.Receive( "BRS.Net.Deathscreen_Respawn", function( len, ply )
	if( BRS_DEATHSCREEN ) then
		if( BRS_DEATHSCREEN.Sound ) then
			BRS_DEATHSCREEN.Sound:Stop()
		end

		if( IsValid( BRS_DEATHSCREEN.Panel ) ) then
			BRS_DEATHSCREEN.Panel:Remove()
		end

		BRS_DEATHSCREEN = nil
	end
end )

hook.Add( "HUDShouldDraw", "BRS.HUDShouldDraw_Deathscreens", function( name )
	if( BRS_DEATHSCREEN and name == "CHudGMod" and not LocalPlayer():Alive() ) then return false end
end )

function BRICKS_SERVER.Func.CreateDeathscreensEditor( oldItemTable, type, onSave, onCancel )
	BS_DEATHSCREENS_EDITOR = vgui.Create( "DFrame" )
	BS_DEATHSCREENS_EDITOR:SetSize( ScrW(), ScrH() )
	BS_DEATHSCREENS_EDITOR:Center()
	BS_DEATHSCREENS_EDITOR:SetTitle( "" )
	BS_DEATHSCREENS_EDITOR:ShowCloseButton( false )
	BS_DEATHSCREENS_EDITOR:SetDraggable( false )
	BS_DEATHSCREENS_EDITOR:MakePopup()
	BS_DEATHSCREENS_EDITOR:SetAlpha( 0 )
	BS_DEATHSCREENS_EDITOR:AlphaTo( 255, 0.1, 0 )
	BS_DEATHSCREENS_EDITOR.Paint = function( self2 ) 
		BRICKS_SERVER.Func.DrawBlur( self2, 4, 4 )
	end

	local itemTable = table.Copy( oldItemTable )

	local backgroundPanel = vgui.Create( "DPanel", BS_DEATHSCREENS_EDITOR )
	backgroundPanel:DockPadding( 1, 1, 1, 1 )
	backgroundPanel.Paint = function( self2, w, h ) 
		draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 0 ) )
		draw.RoundedBox( 5, 1, 1, w-2, h-2, BRICKS_SERVER.Func.GetTheme( 2 ) )
	end

	local backPanel = vgui.Create( "DPanel", backgroundPanel )
	backPanel:Dock( RIGHT )
	backPanel:SetWide( (2*10)+(2*150)+80 )
	backPanel.Paint = function( self2, w, h ) 
		draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
	end

	local backLeftPanel = vgui.Create( "DPanel", backgroundPanel )
	backLeftPanel:Dock( LEFT )
	if( type == "Card" ) then
		backLeftPanel:SetWide( ScrW()*0.3 )
	else
		backLeftPanel:SetWide( backPanel:GetWide()*1.1 )
	end
	local cardImage
	backLeftPanel.Paint = function( self2, w, h ) 
		if( type != "Soundtrack" and cardImage ) then
			surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
			surface.SetMaterial( cardImage )
			if( type == "Card" ) then
				local iconSize = w*0.9
				surface.DrawTexturedRect( (w-iconSize)/2, (h/2)-(iconSize/8), iconSize, iconSize/4 )
			else
				local iconSize = 128
				surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
			end
		end
	end

	backgroundPanel:SetSize( backPanel:GetWide()+backLeftPanel:GetWide(), 100 )
	backgroundPanel:Center()

	function backLeftPanel.RefreshInfo()
		backLeftPanel:Clear()

		local topMargin, bottomMargin = backgroundPanel:GetTall()*0.075, 145
		surface.SetFont( "BRICKS_SERVER_Font20" )
		local textX, textY = surface.GetTextSize( "TEST" )

		if( type != "Soundtrack" and itemTable.Image ) then
			BRICKS_SERVER.Func.GetImage( itemTable.Image or "", function( mat ) cardImage = mat end )
		else
			cardImage = nil
		end

		if( itemTable.GIF ) then
			local html = vgui.Create( "DHTML", backLeftPanel )
			if( type == "Card" ) then
				html:SetSize( backLeftPanel:GetWide()*0.9, (backLeftPanel:GetWide()*0.9)/4 )
			else
				html:SetSize( backLeftPanel:GetWide()*0.9, backLeftPanel:GetWide()*0.9 )
			end
			html:SetPos( (backLeftPanel:GetWide()/2)-(html:GetWide()/2), (backgroundPanel:GetTall()/2)-(html:GetTall()/2) )
			html:SetHTML( [[
				<body scroll="no" style="overflow: hidden; margin: 0;">
				<img src="]] .. itemTable.GIF ..  [[" width=]] .. html:GetWide() .. [[ height = ]] .. html:GetTall() .. [[/>
				</body>
			]] )
		end

		local itemInfoDisplay = vgui.Create( "DPanel", backLeftPanel )
		itemInfoDisplay:SetSize( backLeftPanel:GetWide(), backgroundPanel:GetTall()-topMargin-bottomMargin )
		itemInfoDisplay:SetPos( backLeftPanel:GetWide()-itemInfoDisplay:GetWide(), topMargin )
		itemInfoDisplay.Paint = function( self2, w, h ) 
			draw.SimpleText( itemTable.Name or "New Item", "BRICKS_SERVER_Font25", w/2, 5, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, 0 )
		end

		local itemInfoNoticeBack = vgui.Create( "DPanel", itemInfoDisplay )
		itemInfoNoticeBack:SetSize( 0, 35 )
		itemInfoNoticeBack:SetPos( (itemInfoDisplay:GetWide()/2)-(itemInfoNoticeBack:GetWide()/2), 5+28 )
		itemInfoNoticeBack.Paint = function( self2, w, h ) end

		local itemNotices = {}
		if( itemTable.Price and itemTable.Price > 0 ) then
			table.insert( itemNotices, { DarkRP.formatMoney( itemTable.Price or 0 ) } )
		end

		if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "levelling" ) and itemTable.Level ) then
			table.insert( itemNotices, { "Level " .. itemTable.Level } )
		end

		if( itemTable.Group ) then
			local groupTable
			for k, v in pairs( BRICKS_SERVER.CONFIG.GENERAL.Groups ) do
				if( v[1] == itemTable.Group ) then
					groupTable = v
				end
			end

			if( groupTable ) then
				table.insert( itemNotices, { (groupTable[1] or "None"), groupTable[3] } )
			end
		end

		for k, v in pairs( itemNotices ) do
			surface.SetFont( "BRICKS_SERVER_Font20" )
			local textX, textY = surface.GetTextSize( v[1] )
			local boxW, boxH = textX+10, textY

			local itemInfoNotice = vgui.Create( "DPanel", itemInfoNoticeBack )
			itemInfoNotice:Dock( LEFT )
			itemInfoNotice:DockMargin( 0, 0, 5, 0 )
			itemInfoNotice:SetWide( boxW )
			itemInfoNotice.Paint = function( self2, w, h ) 
				draw.RoundedBox( 5, 0, 0, w, h, (v[2] or BRICKS_SERVER.Func.GetTheme( 5 )) )
				draw.SimpleText( v[1], "BRICKS_SERVER_Font20", w/2, (h/2)-1, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			end

			if( itemInfoNoticeBack:GetWide() <= 5 ) then
				itemInfoNoticeBack:SetSize( itemInfoNoticeBack:GetWide()+boxW, boxH )
			else
				itemInfoNoticeBack:SetSize( itemInfoNoticeBack:GetWide()+5+boxW, boxH )
			end
			itemInfoNoticeBack:SetPos( (itemInfoDisplay:GetWide()/2)-(itemInfoNoticeBack:GetWide()/2), 5+28 )
		end

		if( type == "Soundtrack" ) then
			local playMat = Material( "materials/bricks_server/play_128.png" )
			local pauseMat = Material( "materials/bricks_server/pause_128.png" )
			local button = vgui.Create( "DButton", backLeftPanel )
			button:SetSize( 140, 140 )
			button:SetPos( (backLeftPanel:GetWide()/2)-70, (backgroundPanel:GetTall()/2)-70 )
			button:SetText( "" )
			local changeAlpha = 0
			button.Paint = function( self3, w, h )
				if( self3:IsDown() ) then
					changeAlpha = math.Clamp( changeAlpha+10, 0, 125 )
				elseif( self3:IsHovered() ) then
					changeAlpha = math.Clamp( changeAlpha+10, 0, 95 )
				else
					changeAlpha = math.Clamp( changeAlpha-10, 0, 95 )
				end
		
				surface.SetAlphaMultiplier( changeAlpha/255 )
				draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
				surface.SetAlphaMultiplier( 1 )
				
				if( not backLeftPanel.testSound ) then
					surface.SetMaterial( playMat )
				else
					surface.SetMaterial( pauseMat )
				end
				local size = 128
				surface.SetDrawColor( 0, 0, 0, 255 )
				surface.DrawTexturedRect( (h-size)/2-1, (h-size)/2+1, size, size )
		
				surface.SetDrawColor( 255, 255, 255, 255 )
				surface.DrawTexturedRect( (h-size)/2, (h-size)/2, size, size )
			end
			button.DoClick = function()
				if( not backLeftPanel.testSound ) then
					sound.PlayURL( (itemTable.Sound or ""), "mono", function( station )
						if( IsValid( station ) ) then
							backLeftPanel.testSound = station
							backLeftPanel.testSound:Play()
						elseif( BRICKS_SERVER.Func.HasAdminAccess( LocalPlayer() ) ) then
							notification.AddLegacy( "Invalid sound URL!", 1, 5 )
						end
					end )
				else
					backLeftPanel.testSound:Stop()
					backLeftPanel.testSound = nil
				end
			end
		end
	end

	local actions = {
		[1] = { "Name", Material( "materials/bricks_server/name.png" ), function()
			BRICKS_SERVER.Func.StringRequest( "Admin", "What should the new name be?", itemTable.Name, function( text ) 
				itemTable.Name = text
				backLeftPanel.RefreshInfo()
			end, function() end, "OK", "Cancel", false )
		end, "Name" }
	}

	if( type != "Soundtrack" ) then
		actions[2] = { "Image", Material( "materials/bricks_server/icon.png" ), function()
			BRICKS_SERVER.Func.MaterialRequest( "Admin", "What should the new image be? (recommended: " .. ((type == "Card" and "512x128") or "128x128") .. "px)", itemTable.Image, function( text ) 
				itemTable.GIF = nil
				itemTable.Image = text
				backLeftPanel.RefreshInfo()
			end, function() end, "OK", "Cancel", false )
		end, "Image" }

		actions[3] = { "GIF", Material( "materials/bricks_server/icon.png" ), function()
			BRICKS_SERVER.Func.StringRequest( "Admin", "What should the new GIF be?", itemTable.GIF, function( text ) 
				itemTable.Image = nil
				itemTable.GIF = text
				backLeftPanel.RefreshInfo()
			end, function() end, "OK", "Cancel", false )
		end, "GIF" }
	else
		actions[2] = { "Sound", Material( "materials/bricks_server/icon.png" ), function()
			BRICKS_SERVER.Func.StringRequest( "Admin", "Enter a URL/link to a sound file:", itemTable.Sound, function( text ) 
				itemTable.Sound = text
				backLeftPanel.RefreshInfo()
			end, function() end, "OK", "Cancel", false )
		end, "Sound" }
	end

	table.insert( actions, { "Category", Material( "materials/bricks_server/folder.png" ), function()
		BRICKS_SERVER.Func.StringRequest( "Admin", "What should the category be?", itemTable.Category, function( text ) 
			itemTable.Category = text
			backLeftPanel.RefreshInfo()
		end, function() end, "OK", "Cancel", false )
	end, "Category" } )

	table.insert( actions, { "Price", Material( "materials/bricks_server/currency.png" ), function()
		BRICKS_SERVER.Func.StringRequest( "Admin", "What should the price of looting this be?", itemTable.Price or 0, function( text ) 
			if( isnumber( tonumber( text ) ) ) then
				if( text > 0 ) then
					itemTable.Price = text
				else
					itemTable.Price = nil
				end
				backLeftPanel.RefreshInfo()
			else
				notification.AddLegacy( "Invalid number.", 1, 3 )
			end
		end, function() end, "OK", "Cancel", true )
	end, "Price", function() return DarkRP.formatMoney( itemTable.Price or 0 ) end } )

	table.insert( actions, { "Group", Material( "materials/bricks_server/group.png" ), function()
		local options = {}
		options["None"] = "None"
		for k, v in pairs( (BS_ConfigCopyTable or BRICKS_SERVER.CONFIG).GENERAL.Groups ) do
			options[k] = v[1]
		end
		BRICKS_SERVER.Func.ComboRequest( "Admin", "What should the group requirement be?", (itemTable.Group or ""), options, function( value, data ) 
			if( (BS_ConfigCopyTable or BRICKS_SERVER.CONFIG).GENERAL.Groups[data] ) then
				itemTable.Group = value
				backLeftPanel.RefreshInfo()
			elseif( value == "None" ) then
				itemTable.Group = nil
				backLeftPanel.RefreshInfo()
			else
				notification.AddLegacy( "Invalid group.", 1, 3 )
			end
		end, function() end, "OK", "Cancel" )
	end, "Group" } )

	if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "levelling" ) ) then
		table.insert( actions, { "Level", Material( "materials/bricks_server/level.png" ), function()
			BRICKS_SERVER.Func.StringRequest( "Admin", "What should the level requirement be?", itemTable.Level, function( text ) 
				itemTable.Level = text
				backLeftPanel.RefreshInfo()
			end, function() end, "OK", "Cancel", true )
		end, "Level" } )
	end
	
	function backPanel.FillOptions()
		backPanel:Clear()

		for k, v in ipairs( actions ) do
			local actionButton = vgui.Create( "DButton", backPanel )
			actionButton:SetText( "" )
			actionButton:Dock( TOP )
			actionButton:DockMargin( 10, 10, 10, 0 )
			actionButton:SetTall( 40 )
			local changeAlpha = 0
			actionButton.Paint = function( self2, w, h )
				draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
				
				if( self2:IsDown() ) then
					changeAlpha = math.Clamp( changeAlpha+10, 0, 255 )
				elseif( self2:IsHovered() ) then
					changeAlpha = math.Clamp( changeAlpha+10, 0, 255 )
				else
					changeAlpha = math.Clamp( changeAlpha-10, 0, 255 )
				end

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
			actionButton.DoClick = v[3]
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
			onSave( itemTable )

			if( backLeftPanel.testSound ) then
				backLeftPanel.testSound:Stop()
				backLeftPanel.testSound = nil
			end

			BS_DEATHSCREENS_EDITOR:AlphaTo( 0, 0.1, 0, function()
				if( IsValid( BS_DEATHSCREENS_EDITOR ) ) then
					BS_DEATHSCREENS_EDITOR:Remove()
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

			if( backLeftPanel.testSound ) then
				backLeftPanel.testSound:Stop()
				backLeftPanel.testSound = nil
			end

			BS_DEATHSCREENS_EDITOR:AlphaTo( 0, 0.1, 0, function()
				if( IsValid( BS_DEATHSCREENS_EDITOR ) ) then
					BS_DEATHSCREENS_EDITOR:Remove()
				end
			end )
		end

		backgroundPanel:SetTall( math.max( ScrH()*0.45, buttonPanel:GetTall()+(3*10)+(#actions*50) ) )
		backgroundPanel:Center()

		leftButton:SetWide( (backPanel:GetWide()-30)/2 )
		rightButton:SetWide( (backPanel:GetWide()-30)/2 )
	end
	backPanel.FillOptions()
	backLeftPanel.RefreshInfo()
end