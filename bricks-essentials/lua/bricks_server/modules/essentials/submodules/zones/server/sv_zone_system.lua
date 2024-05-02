util.AddNetworkString( "BRS.Net.OpenZoneEditor" )
util.AddNetworkString( "BRS.Net.SendZoneEditor" )
net.Receive( "BRS.Net.OpenZoneEditor", function( len, ply ) 
	if( not BRICKS_SERVER.Func.HasAdminAccess( ply ) ) then return end

	BRICKS_SERVER.Func.SendConfig( ply )

	net.Start( "BRS.Net.SendZoneEditor" )
	net.Send( ply )

	ply.BRS_PREZONEEDITOR_POS = ply:GetPos()
	ply.BRS_PREZONEEDITOR_MOVE = ply:GetMoveType()
	ply:SetMoveType( MOVETYPE_NOCLIP )
end )

util.AddNetworkString( "BRS.Net.CloseZoneEditor" )
net.Receive( "BRS.Net.CloseZoneEditor", function( len, ply ) 
	if( not BRICKS_SERVER.Func.HasAdminAccess( ply ) ) then return end

	BRICKS_SERVER.Func.SendConfig( ply )

	ply:SetPos( ply.BRS_PREZONEEDITOR_POS )
	ply:SetMoveType( ply.BRS_PREZONEEDITOR_MOVE or MOVETYPE_WALK )

	ply.BRS_PREZONEEDITOR_POS, ply.BRS_PREZONEEDITOR_MOVE = nil, nil
end )

util.AddNetworkString( "BRS.Net.CreateZone" )
net.Receive( "BRS.Net.CreateZone", function( len, ply ) 
	if( not BRICKS_SERVER.Func.HasAdminAccess( ply ) ) then return end

	local zoneType = net.ReadString()
	local zoneTypeTable = BRICKS_SERVER.DEVCONFIG.ZoneTypes[zoneType or ""]

	if( not zoneType or not zoneTypeTable ) then return end

	local pointsTable = {}
	for i = 1, (zoneTypeTable.Points or 1) do
		table.insert( pointsTable, net.ReadVector() )
	end

	local zoneSize = net.ReadUInt( 16 ) or 100
	local zoneOptions = net.ReadTable()

	if( #pointsTable < (zoneTypeTable.Points or 1) ) then
		DarkRP.notify( ply, 1, 3, "Zone creation failed! Not enough points." )
		return
	end

	local newZoneConfig = table.Copy( BRICKS_SERVER.CONFIG.ZONES or {} )
	local newZoneTable = table.Copy( zoneOptions )
	newZoneTable.Points = pointsTable
	newZoneTable.Size = zoneSize
	newZoneTable.Type = zoneType
	local configKey = table.insert( newZoneConfig, newZoneTable )

	local configToSend = {}
	configToSend.ZONES = newZoneConfig

	BRICKS_SERVER.Func.UpdateConfig( configToSend, ply )

	local zoneEntity = ents.Create( "bricks_server_zone" )
	zoneEntity:Spawn()
	zoneEntity.configKey = configKey
	zoneTypeTable.SetupZoneEnt( zoneEntity, pointsTable, zoneSize )

	DarkRP.notify( ply, 1, 3, "ZONE Created" )
end )

hook.Add( "InitPostEntity", "BRS.InitPostEntity_LoadZones", function()	
	for k, v in pairs( BRICKS_SERVER.CONFIG.ZONES or {} ) do
		local zoneTypeTable = BRICKS_SERVER.DEVCONFIG.ZoneTypes[v.Type or ""]

		if( not zoneTypeTable ) then continue end

		local zoneEntity = ents.Create( "bricks_server_zone" )
		zoneEntity:Spawn()
		zoneEntity.configKey = k
		zoneTypeTable.SetupZoneEnt( zoneEntity, v.Points, v.Size )
	end
end )

hook.Add( "PlayerSpawnProp", "BRS.PlayerSpawnProp_Zones", function( ply, model )	
	local configTable = (BRICKS_SERVER.CONFIG.ZONES or {})[ply:GetNW2Int( "BRS_IN_ZONE" )]
	if( configTable and configTable[7] ) then
		return false
	end
end )

hook.Add( "PlayerShouldTakeDamage", "BRS.PlayerShouldTakeDamage_Zones", function( ply, attacker )	
	local configTable = (BRICKS_SERVER.CONFIG.ZONES or {})[ply:GetNW2Int( "BRS_IN_ZONE" )]
	if( configTable and configTable[8] and not BRICKS_SERVER.Func.HasAdminAccess( attacker ) ) then
		return false
	end
end )

hook.Add( "BRS.Hooks.ConfigUpdated", "BRS.Hooks.ConfigUpdated_Zones", function( keysChanged )	
	if( table.HasValue( (keysChanged or {}), "ZONES" ) ) then
		for k, v in pairs( ents.FindByClass( "bricks_server_zone" ) ) do
			if( not BRICKS_SERVER.CONFIG.ZONES[v.configKey or 0] ) then
				v:Remove()
			end
		end
	end
end )