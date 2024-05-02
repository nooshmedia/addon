BRICKS_SERVER.ESSENTIALS = {}

local module = BRICKS_SERVER.Func.AddModule( "essentials", "Brick's Essentials", "materials/bricks_server/essentials.png", "1.9.7" )
module:AddSubModule( "boosters", "Boosters" )
module:AddSubModule( "boss", "Boss" )
module:AddSubModule( "crafting", "Crafting" )
module:AddSubModule( "deathscreens", "Deathscreens" )
module:AddSubModule( "f4menu", "F4 Menu" )
module:AddSubModule( "hud", "HUD" )
module:AddSubModule( "inventory", "Inventory" )
module:AddSubModule( "levelling", "Levelling" )
module:AddSubModule( "logging", "Logging" )
module:AddSubModule( "marketplace", "Marketplace" )
module:AddSubModule( "printers", "Printers" )
module:AddSubModule( "swepupgrader", "SWEP Upgrader" )
module:AddSubModule( "zones", "Zones" )

hook.Add( "BRS.Hooks.BaseConfigLoad", "BRS.Hooks.BaseConfigLoad_Essentials", function()
    AddCSLuaFile( "bricks_server/bricks_essentials/sh_baseconfig.lua" )
    include( "bricks_server/bricks_essentials/sh_baseconfig.lua" )
end )

hook.Add( "BRS.Hooks.ClientConfigLoad", "BRS.Hooks.ClientConfigLoad_Essentials", function()
    AddCSLuaFile( "bricks_server/bricks_essentials/sh_clientconfig.lua" )
    include( "bricks_server/bricks_essentials/sh_clientconfig.lua" )
end )

hook.Add( "BRS.Hooks.DevConfigLoad", "BRS.Hooks.DevConfigLoad_Essentials", function()
    AddCSLuaFile( "bricks_server/bricks_essentials/sh_devconfig.lua" )
    include( "bricks_server/bricks_essentials/sh_devconfig.lua" )
end )

if( SERVER ) then
    resource.AddWorkshop( "2126843730" ) -- Brick's Essentials
    resource.AddWorkshop( "2136421687" ) -- Brick's Server

    hook.Add( "BRS.Hooks.SQLLoad", "BRS.Hooks.SQLLoad_Essentials", function()
        if( BRICKS_SERVER.ESSENTIALS.LUACFG.UseMySQL ) then
            include( "bricks_server/bricks_essentials/sv_mysql.lua" )
        end
    end )
end

hook.Add( "BRS.Hooks.CoreLoaded", "BRS.Hooks.CoreLoaded_Essentials", function()
    if( SERVER ) then
        AddCSLuaFile( "bricks_server/bricks_essentials/cl_essentials.lua" )
        include( "bricks_server/bricks_essentials/sv_essentials.lua" )
        include( "bricks_server/bricks_essentials/sv_playerdata.lua" )
    elseif( CLIENT ) then
        include( "bricks_server/bricks_essentials/cl_essentials.lua" )
    end
end )