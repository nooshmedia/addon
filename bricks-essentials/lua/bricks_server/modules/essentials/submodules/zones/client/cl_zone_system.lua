concommand.Add( "brs_zone_editor", function()
	if( not BRICKS_SERVER.Func.HasAdminAccess( LocalPlayer() ) ) then return end

	net.Start( "BRS.Net.OpenZoneEditor" )
	net.SendToServer()
end )

net.Receive( "BRS.Net.SendZoneEditor", function()
	if( not IsValid( BRICKS_SERVER_ZONECREATOR ) ) then
		BRICKS_SERVER_ZONECREATOR = vgui.Create( "bricks_server_ui_zonecreator" )
	end
end )

hook.Add( "CreateMove", "BRS.CreateMove_ZoneEditor", function( cmd )
	if( IsValid( BRICKS_SERVER_ZONECREATOR ) ) then
		if( input.IsKeyDown( KEY_W ) ) then
			cmd:SetForwardMove( 1 )
		elseif( input.IsKeyDown( KEY_S ) ) then
			cmd:SetForwardMove( -1 )
		end

		if( input.IsKeyDown( KEY_D ) ) then
			cmd:SetSideMove( 1 )
		elseif( input.IsKeyDown( KEY_A ) ) then
			cmd:SetSideMove( -1 )
		end
	end
end )

net.Receive( "BRS.Net.EnterZone", function()
	local configKey = net.ReadUInt( 16 )

	if( not configKey ) then return end

	local zoneConfig = BRICKS_SERVER.CONFIG.ZONES[configKey]

	if( not zoneConfig ) then return end

	BRICKS_SERVER.Func.AddCenterNotification( zoneConfig[1], zoneConfig[2], zoneConfig[3], zoneConfig[4] )
end )

net.Receive( "BRS.Net.ExitZone", function()
	local configKey = net.ReadUInt( 16 )

	if( not configKey ) then return end

	local zoneConfig = BRICKS_SERVER.CONFIG.ZONES[configKey]

	if( not zoneConfig ) then return end

	BRICKS_SERVER.Func.AddCenterNotification( zoneConfig[1], zoneConfig[2], zoneConfig[5], zoneConfig[6] )
end )