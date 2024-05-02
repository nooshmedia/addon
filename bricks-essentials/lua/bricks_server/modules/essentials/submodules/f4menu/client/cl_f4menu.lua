BRICKS_SERVER.Func.AddConfigPage( "F4", "bricks_server_config_f4", "essentials" )

net.Receive( "BRS.Net.OpenF4", function()
	if( not IsValid( BRICKS_SERVER_F4 ) ) then
		BRICKS_SERVER_F4 = vgui.Create( "bricks_server_f4" )
        BRICKS_SERVER_F4:FillTabs()
    elseif( not BRICKS_SERVER_F4:IsVisible() ) then
        if( BRICKS_SERVER.Func.HasAdminAccess( LocalPlayer() ) ) then
            BS_ConfigsChanged = {}
            BS_ConfigCopyTable = table.Copy( BRICKS_SERVER.CONFIG )
        end
        
        BRICKS_SERVER_F4:SetVisible( true )
        if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "crafting" ) ) then hook.Run( "BRS.Hooks.FillCrafting" ) end
        if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "boosters" ) ) then hook.Run( "BRS.Hooks.FillBoosters" ) end
        if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "inventory" ) ) then hook.Run( "BRS.Hooks.FillInventory" ) end
        if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "printers" ) ) then hook.Run( "BRS.Hooks.FillPrinters" ) end
        if( BRICKS_SERVER_F4.FillProfile ) then BRICKS_SERVER_F4.FillProfile() end
        if( BRICKS_SERVER.Func.HasAdminAccess( LocalPlayer() ) ) then
            hook.Run( "BRS.Hooks.RefreshConfig" )
            if( BRICKS_SERVER_F4.FillPlayers ) then BRICKS_SERVER_F4.FillPlayers() end
            if( BRICKS_SERVER_F4.RefreshAdminPerms ) then BRICKS_SERVER_F4.RefreshAdminPerms() end
        end

        if( BRS_F4_NEEDS_TAB_REFRESH ) then
            if( BRICKS_SERVER_F4.FillTabs ) then
                BRICKS_SERVER_F4:FillTabs()
            end

            BRS_F4_NEEDS_TAB_REFRESH = false
        end
    end
end )

concommand.Add( "bricks_server_debugf4", function()
    if( IsValid( BRICKS_SERVER_F4 ) ) then
        BRICKS_SERVER_F4:Remove()
    end
end )

if( not DarkRP ) then
    hook.Add( "DarkRPFinishedLoading", "BRS.DarkRPFinishedLoading_DisableDarkRPF4", function( ply ) 
        function DarkRP.openF4Menu() 

        end
    end )
else
    function DarkRP.openF4Menu()  

    end
end