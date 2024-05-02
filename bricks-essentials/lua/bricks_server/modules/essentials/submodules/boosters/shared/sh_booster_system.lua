concommand.Add( "givebooster", function( ply, cmd, args )
    if( CLIENT ) then
        if( not BRICKS_SERVER.Func.HasAdminAccess( ply ) ) then 
			print( "BRICKS SERVER ERROR: NO ACCESS" )
			return 
        end
        
        if( args[1] and args[2] and isstring( args[1] ) and isnumber( tonumber( args[2] ) ) ) then
            net.Start( "BRS.Net.Admin_GiveBooster" )
                net.WriteString( args[1] )
                net.WriteUInt( tonumber( args[2] ), 8 )
            net.SendToServer()
        end
    elseif( SERVER ) then
        if( (not IsValid( ply ) or BRICKS_SERVER.Func.HasAdminAccess( ply )) and args[1] and args[2] and isstring( args[1] ) and isnumber( tonumber( args[2] ) ) ) then
            local victimSteamID64 = args[1]
            local boosterKey = tonumber( args[2] )
        
            if( not victimSteamID64 or not boosterKey ) then return end
            if( not BRICKS_SERVER.CONFIG.BOOSTERS[boosterKey] ) then return end
        
            local victimEntity = player.GetBySteamID64( victimSteamID64 )
        
            if( not IsValid( victimEntity ) or not victimEntity:IsPlayer() ) then return end
            victimEntity:AddBooster( boosterKey )
            
            DarkRP.notify( victimEntity, 1, 5, "You have received a " .. (BRICKS_SERVER.CONFIG.BOOSTERS[boosterKey].Title or "ERROR") .. " Booster" )
        end
    end
end )