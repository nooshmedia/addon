util.AddNetworkString( "BRS.Net.ScreenAdminRequest" )
util.AddNetworkString( "BRS.Net.ScreenAdminRequestSend" )
net.Receive( "BRS.Net.ScreenAdminRequest", function( len, ply )
    if( not BRICKS_SERVER.Func.HasAdminAccess( ply ) ) then return end

    local requestedID64 = net.ReadString()
    local quality = math.Clamp( net.ReadUInt( 7 ), 1, 100 )

    if( not requestedID64 ) then return end
    local requestedPly = player.GetBySteamID64( requestedID64 )

    if( requestedPly.BRS_SCREENREQUESTED ) then
        DarkRP.notify( ply, 1, 5, "Screen request already requested by another admin!" )
        return
    end

    requestedPly.BRS_SCREENREQUESTED = {}
    requestedPly.BRS_SCREENREQUESTED.StartTime = CurTime()
    requestedPly.BRS_SCREENREQUESTED.Requester = ply

    net.Start( "BRS.Net.ScreenAdminRequestSend" )
        net.WriteUInt( (quality or 70), 7 )
    net.Send( requestedPly )
end )

util.AddNetworkString( "BRS.Net.ScreenAdminReply" )
util.AddNetworkString( "BRS.Net.ScreenAdminReplySend" )
net.Receive( "BRS.Net.ScreenAdminReply", function( len, ply )
    if( not ply.BRS_SCREENREQUESTED ) then return end

    local currentKey = net.ReadUInt( 5 )
    local endKey = net.ReadUInt( 5 )
    local length = net.ReadUInt( 32 )

    if( not length or not currentKey or not endKey ) then return end
    local imageString = net.ReadData( length )

    if( not imageString ) then return end

    if( not IsValid( ply.BRS_SCREENREQUESTED.Requester ) or not BRICKS_SERVER.Func.HasAdminAccess( ply.BRS_SCREENREQUESTED.Requester ) ) then 
        ply.BRS_SCREENREQUESTED = nil
        return
    end

    local dataLen = string.len( imageString )
    net.Start( "BRS.Net.ScreenAdminReplySend" )
        net.WriteUInt( currentKey, 5 )
        net.WriteUInt( endKey, 5 )
        net.WriteUInt( dataLen, 32 )
        net.WriteData( imageString, dataLen )
        net.WriteString( ply:SteamID64() or "" )
    net.Send( ply.BRS_SCREENREQUESTED.Requester )
    
    if( currentKey >= endKey ) then
        ply.BRS_SCREENREQUESTED = nil
    end
end )

util.AddNetworkString( "BRS.Net.ScreenAdminCancel" )
util.AddNetworkString( "BRS.Net.ScreenAdminCancelSend" )
net.Receive( "BRS.Net.ScreenAdminCancel", function( len, ply )
    if( not BRICKS_SERVER.Func.HasAdminAccess( ply ) ) then return end

    local requestedID64 = net.ReadString()

    if( not requestedID64 ) then return end
    local requestedPly = player.GetBySteamID64( requestedID64 )

    if( not requestedPly or not IsValid( requestedPly ) or not requestedPly.BRS_SCREENREQUESTED or (IsValid( requestedPly.BRS_SCREENREQUESTED.Requester ) and requestedPly.BRS_SCREENREQUESTED.Requester != ply) ) then return end

    requestedPly.BRS_SCREENREQUESTED = nil

    net.Start( "BRS.Net.ScreenAdminCancelSend" )
    net.Send( requestedPly )
end )

hook.Add( "BRS.Hooks.ProfileSend", "BRS.Hooks.ProfileSend_Essentials", function( profileTable, requestedPly )
    if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "levelling" ) ) then
        profileTable.level = requestedPly:GetLevel()
        profileTable.experience = requestedPly:GetExperience()
    end

    if( BRICKS_SERVER.Func.IsSubModuleEnabled( "default", "currencies" ) ) then
        profileTable.currencies = requestedPly:GetCurrencies()
    end

    if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "logging" ) ) then
        profileTable.logs = requestedPly:GetLogs()
    end
end )

-- Group can change team
hook.Add( "playerCanChangeTeam", "BRS.playerCanChangeTeam_Groups", function( ply, job, force )
	local jobGroup = (BRICKS_SERVER.CONFIG.GENERAL.JobGroups or {})[RPExtraTeams[job].command or "error"]
	if( jobGroup and not BRICKS_SERVER.Func.IsInGroup( ply, jobGroup ) ) then
		return false, "You are not the right group for this job (" .. (jobGroup or "None") .. ")."
	end
end )

-- Group can buy shipment
hook.Add( "canBuyShipment", "BRS.canBuyShipment_Groups", function( ply, shipments )
	local shipmentGroup = (BRICKS_SERVER.CONFIG.GENERAL.ShipmentGroups or {})[shipments.name or "error"]
	if( shipmentGroup and not BRICKS_SERVER.Func.IsInGroup( ply, shipmentGroup ) ) then
		return false, false, "You are not the right group to buy this shipment (" .. (shipmentGroup or "None") .. ")."
	end
end )

-- Group can buy entity
hook.Add( "canBuyCustomEntity", "BRS.canBuyCustomEntity_Groups", function( ply, entity )
	local entityGroup = (BRICKS_SERVER.CONFIG.GENERAL.EntityGroups or {})[entity.cmd or "error"]
	if( entityGroup and not BRICKS_SERVER.Func.IsInGroup( ply, entityGroup ) ) then
		return false, false, "You are not the right group to buy this entity (" .. (entityGroup or "None") .. ")."
	end
end )

-- Group can buy ammo
hook.Add( "canBuyAmmo", "BRS.canBuyAmmo_Groups", function( ply, ammo )
	local ammoGroup = (BRICKS_SERVER.CONFIG.GENERAL.AmmoGroups or {})[ammo.id or 0]
	if( ammoGroup and not BRICKS_SERVER.Func.IsInGroup( ply, ammoGroup ) ) then
		return false, false, "You are not the right group to buy this ammo (" .. (ammoGroup or "None") .. ")."
	end
end )