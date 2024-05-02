BRICKS_SERVER.Func.AddConfigPage( "Boosters", "bricks_server_config_boosters", "essentials" )
BRICKS_SERVER.Func.AddAdminPlayerFunc( "Booster", "Add", function( ply ) 
	local options = {}
	for k, v in pairs( (BRICKS_SERVER.CONFIG.BOOSTERS or {}) ) do
		options[k] = v.Title
	end
	BRICKS_SERVER.Func.ComboRequest( "Admin", "What booster would you like to give them?", 1, options, function( value, data ) 
		if( BRICKS_SERVER.CONFIG.BOOSTERS[data] ) then
			RunConsoleCommand( "givebooster", ply:SteamID64(), data )
		else
			notification.AddLegacy( "Invalid booster.", 1, 3 )
		end
	end, function() end, "OK", "Cancel" )
end )

BRS_BOOSTERS = BRS_BOOSTERS or {}
net.Receive( "BRS.Net.SetBoosters", function()
	local boostersTable = net.ReadTable()

	BRS_BOOSTERS = boostersTable or {}

	hook.Run( "BRS.Hooks.FillBoosters" )
end )

function BRICKS_SERVER.Func.CreateBoosterEditor( oldBoosterTable, onSave, onCancel )
	BS_BOOSTER_EDITOR = vgui.Create( "DFrame" )
	BS_BOOSTER_EDITOR:SetSize( ScrW(), ScrH() )
	BS_BOOSTER_EDITOR:Center()
	BS_BOOSTER_EDITOR:SetTitle( "" )
	BS_BOOSTER_EDITOR:ShowCloseButton( false )
	BS_BOOSTER_EDITOR:SetDraggable( false )
	BS_BOOSTER_EDITOR:MakePopup()
	BS_BOOSTER_EDITOR:SetAlpha( 0 )
	BS_BOOSTER_EDITOR:AlphaTo( 255, 0.1, 0 )
	BS_BOOSTER_EDITOR.Paint = function( self2 ) 
		BRICKS_SERVER.Func.DrawBlur( self2, 4, 4 )
	end

	local backPanel = vgui.Create( "DPanel", BS_BOOSTER_EDITOR )
	backPanel.Paint = function( self2, w, h ) 
		draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 0 ) )
		draw.RoundedBox( 5, 1, 1, w-2, h-2, BRICKS_SERVER.Func.GetTheme( 2 ) )
	end

	local boosterTable = table.Copy( oldBoosterTable )

	local textArea = vgui.Create( "DPanel", backPanel )
	textArea:Dock( TOP )
	textArea:DockMargin( 10, 10, 10, 0 )
	textArea:SetTall( 30 )
	textArea.Paint = function( self2, w, h ) 
		draw.SimpleText( "Booster Editor - " .. boosterTable.Title, "BRICKS_SERVER_Font20", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end

	local actions = {
		[1] = { "Title", Material( "materials/bricks_server/name.png" ), function()
			BRICKS_SERVER.Func.StringRequest( "Admin", "What should the new title be?", boosterTable.Title, function( text ) 
				boosterTable.Title = text
			end, function() end, "OK", "Cancel", false )
		end, "Title" },
		[2] = { "Icon", Material( "materials/bricks_server/icon.png" ), function()
			BRICKS_SERVER.Func.MaterialRequest( "Admin", "What should the new icon be?", boosterTable.Icon, function( text ) 
				boosterTable.Icon = text
			end, function() end, "OK", "Cancel", false )
		end, "Icon" },
		[3] = { "Type", Material( "materials/bricks_server/amount.png" ), function()
			local options = {}
			for k, v in pairs( BRICKS_SERVER.DEVCONFIG.BoosterTypes ) do
				options[k] = v[1]
			end
			BRICKS_SERVER.Func.ComboRequest( "Admin", "What type should this booster be?", (boosterTable.Type or 1), options, function( value, data ) 
				if( BRICKS_SERVER.DEVCONFIG.BoosterTypes[data] ) then
					boosterTable.Type = data
				else
					notification.AddLegacy( "Invalid type.", 1, 3 )
				end
			end, function() end, "OK", "Cancel" )
		end, "Type" },
		[4] = { "Multiplier", Material( "materials/bricks_server/multiplier.png" ), function()
			BRICKS_SERVER.Func.StringRequest( "Admin", "What should the booster multiplier be?", boosterTable.Multiplier, function( text ) 
				boosterTable.Multiplier = text
			end, function() end, "OK", "Cancel", true )
		end, "Multiplier" },
		[5] = { "Time", Material( "materials/bricks_server/time.png" ), function()
			BRICKS_SERVER.Func.StringRequest( "Admin", "How long should this booster last (in seconds)?", boosterTable.Time, function( text ) 
				boosterTable.Time = text
			end, function() end, "OK", "Cancel", true )
		end, "Time" }
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

			if( v[4] and boosterTable[v[4]] and not v[5] ) then
				draw.SimpleText( v[1] .. " - " .. string.sub( boosterTable[v[4]], 1, 20 ), "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
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
		onSave( boosterTable )

		BS_BOOSTER_EDITOR:AlphaTo( 0, 0.1, 0, function()
			if( IsValid( BS_BOOSTER_EDITOR ) ) then
				BS_BOOSTER_EDITOR:Remove()
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

		BS_BOOSTER_EDITOR:AlphaTo( 0, 0.1, 0, function()
			if( IsValid( BS_BOOSTER_EDITOR ) ) then
				BS_BOOSTER_EDITOR:Remove()
			end
		end )
	end

	backPanel:SetSize( (2*10)+(2*150)+80, buttonPanel:GetTall()+(4*10)+textArea:GetTall()+(#actions*50) )
	backPanel:Center()

	leftButton:SetWide( (backPanel:GetWide()-30)/2 )
	rightButton:SetWide( (backPanel:GetWide()-30)/2 )
end