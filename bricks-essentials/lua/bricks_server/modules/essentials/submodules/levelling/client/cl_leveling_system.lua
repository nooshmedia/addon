BRICKS_SERVER.Func.AddConfigPage( "Levelling", "bricks_server_config_levelling", "essentials" )
BRICKS_SERVER.Func.AddAdminPlayerFunc( "Level", "Set", function( ply ) 
	BRICKS_SERVER.Func.StringRequest( "Admin", "What level would you like to set them to?", 0, function( text ) 
		if( isnumber( tonumber( text ) ) ) then
			RunConsoleCommand( "setlevel", ply:SteamID64(), text )
		else
			notification.AddLegacy( "Invalid number.", 1, 3 )
		end
	end, function() end, "OK", "Cancel", true )
end )
BRICKS_SERVER.Func.AddAdminPlayerFunc( "Experience", "Add", function( ply ) 
	BRICKS_SERVER.Func.StringRequest( "Admin", "How much experience would you like to add?", 0, function( text ) 
		if( isnumber( tonumber( text ) ) ) then
			RunConsoleCommand( "addexperience", ply:SteamID64(), text )
		else
			notification.AddLegacy( "Invalid number.", 1, 3 )
		end
	end, function() end, "OK", "Cancel", true )
end )

BRS_EXPERIENCE = BRS_EXPERIENCE or 0
net.Receive( "BRS.Net.SetExperience", function()
	local amount = net.ReadUInt( 32 )

	BRS_EXPERIENCE = amount or 0
end )

BRS_LEVEL = BRS_LEVEL or 0
net.Receive( "BRS.Net.SetLevel", function()
	local amount = net.ReadUInt( 32 )

	BRS_LEVEL = amount or 0
end )

net.Receive("BRS.Net.SendLevelupEffect", function()
	BRICKS_SERVER.Func.AddCenterNotification( "LEVEL UP", BRICKS_SERVER.Func.GetTheme( 5 ), "Level " .. (BRS_LEVEL or 0), BRICKS_SERVER.Func.GetTheme( 6 ) )
end)

local function formatEXP( number )
	local finalString = number
	
	if( finalString > 1000000 ) then
		finalString = math.Round( finalString/1000000, 1 ) .. "M"
	elseif( finalString > 1000 ) then
		finalString = math.Round( finalString/1000, 1 ) .. "K"
	else
		finalString = math.Round( finalString )
	end

	return finalString
end

local lerpExperience = 0
hook.Add( "HUDPaint", "BRS.HUDPaint_LevellingHUD", function()
	if( not BRS_SHOWINGBOSS ) then
		local width, height = ScrW()*0.5, 10
		local y = 10

		draw.RoundedBox( 5, (ScrW()/2)-(width/2), y, width, height, BRICKS_SERVER.Func.GetTheme( 3 ))

		lerpExperience = Lerp( RealFrameTime()*2, lerpExperience, BRICKS_SERVER.Func.GetCurLevelExp( LocalPlayer() ) )
		if( BRS_LEVEL != BRICKS_SERVER.CONFIG.LEVELING["Max Level"] ) then
			draw.RoundedBox( 5, (ScrW()/2)-(width/2), y, width*math.Clamp( (lerpExperience/BRICKS_SERVER.Func.GetExpToLevel( BRS_LEVEL, BRS_LEVEL+1 )), 0, 1 ), height, BRICKS_SERVER.Func.GetTheme( 5 ) )
		else
			draw.RoundedBox( 5, (ScrW()/2)-(width/2), y, width, height, BRICKS_SERVER.Func.GetTheme( 5 ) )
		end

		draw.SimpleText( BRS_LEVEL, "BRICKS_SERVER_HUDFont", (ScrW()/2)-(width/2)-5-1, y+(height/2)-1, Color( 0, 0, 0 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
		draw.SimpleText( BRS_LEVEL, "BRICKS_SERVER_HUDFont", (ScrW()/2)-(width/2)-5, y+(height/2)-2, Color( 255, 255, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )

		if( BRS_LEVEL != BRICKS_SERVER.CONFIG.LEVELING["Max Level"] ) then
			draw.SimpleText( BRS_LEVEL+1, "BRICKS_SERVER_HUDFont", (ScrW()/2)+(width/2)+5-1, y+(height/2)-1, Color( 0, 0, 0 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
			draw.SimpleText( BRS_LEVEL+1, "BRICKS_SERVER_HUDFont", (ScrW()/2)+(width/2)+5, y+(height/2)-2, Color( 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		else
			draw.SimpleText( "MAX", "BRICKS_SERVER_HUDFont", (ScrW()/2)+(width/2)+5-1, y+(height/2)-1, Color( 0, 0, 0 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
			draw.SimpleText( "MAX", "BRICKS_SERVER_HUDFont", (ScrW()/2)+(width/2)+5, y+(height/2)-2, Color( 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		end

		local expStatus = formatEXP( BRS_EXPERIENCE ) .. "/" .. formatEXP( BRICKS_SERVER.Func.GetExpToLevel( 0, BRS_LEVEL+1 ) ) .. " [" .. math.Round((BRICKS_SERVER.Func.GetCurLevelExp( LocalPlayer() )/BRICKS_SERVER.Func.GetExpToLevel( BRS_LEVEL, BRS_LEVEL+1 ))*100) .. "%]"
		if( BRS_LEVEL == BRICKS_SERVER.CONFIG.LEVELING["Max Level"] ) then
			expStatus = formatEXP( BRS_EXPERIENCE )
		end
		draw.SimpleText( expStatus, "BRICKS_SERVER_HUDFontS", ScrW()/2-1, y+height+2+1, Color( 0, 0, 0 ), TEXT_ALIGN_CENTER, 0 )
		draw.SimpleText( expStatus, "BRICKS_SERVER_HUDFontS", ScrW()/2, y+height+2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, 0 )
	end
end )