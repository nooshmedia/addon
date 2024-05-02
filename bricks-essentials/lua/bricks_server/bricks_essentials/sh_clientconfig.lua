--[[
    !!WARNING!!
        ALL CONFIG IS DONE INGAME, DONT EDIT ANYTHING HERE
        Type !bricksserver ingame or use the f4menu
    !!WARNING!!
]]--

-- Inventory --
if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "inventory" ) ) then
    BRICKS_SERVER.BASECLIENTCONFIG.PickupBind1 = { "Inventory Pickup Bind 1", "bind", 81, function( value )
        net.Start( "BRS.Net.InventoryChangeBind" )
            net.WriteUInt( 1, 2 )
            net.WriteUInt( tonumber( value ), 8 )
        net.SendToServer()
    end }
    BRICKS_SERVER.BASECLIENTCONFIG.PickupBind2 = { "Inventory Pickup Bind 2", "bind", 15, function( value )
        net.Start( "BRS.Net.InventoryChangeBind" )
            net.WriteUInt( 2, 2 )
            net.WriteUInt( tonumber( value ), 8 )
        net.SendToServer()
    end }
    BRICKS_SERVER.BASECLIENTCONFIG.HolsterBind = { "Inventory Holster Bind", "bind", 0 }
end

-- HUD --
if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "hud" ) ) then
    BRICKS_SERVER.BASECLIENTCONFIG.HUDAgenda = { "Enable Agenda HUD", "bool", 1 }
end