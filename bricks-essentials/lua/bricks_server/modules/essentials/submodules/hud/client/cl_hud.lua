local hide = {
	["CHudHealth"] = true,
    ["CHudBattery"] = true,
    ["CHudAmmo"] = true,
    ["DarkRP_HUD"] = true,
    ["DarkRP_EntityDisplay"] = true
}

hook.Add( "HUDShouldDraw", "BRS.HUDShouldDraw_HideHUD", function( name )
	if( hide[name] ) then return false end
end )

if( BRS_HUD and IsValid( BRS_HUD.avatar ) ) then
    BRS_HUD.avatar:Remove()
end

BRS_HUD = {}
BRS_HUD.w, BRS_HUD.h = 380, 110
BRS_HUD.x, BRS_HUD.y = 30, ScrH()-30-BRS_HUD.h

local function createAvatarHUD()
    if( IsValid( BRS_HUD.avatar ) ) then
        BRS_HUD.avatar:Remove()
    end

    BRS_HUD.avatar = vgui.Create( "AvatarImage" )
    BRS_HUD.avatar:SetSize( BRS_HUD.h-14, BRS_HUD.h-14 )
    BRS_HUD.avatar:SetPos( BRS_HUD.x+5+2, BRS_HUD.y+5+2)
    BRS_HUD.avatar:ParentToHUD()
    BRS_HUD.avatar.Think = function( self2 )
        local shouldDraw = hook.Run( "HUDShouldDraw", "CHudGMod" )
        if( not shouldDraw ) then
            self2:Remove()
        end
    end
end

local lerpHealth = 0
local lerpArmor = 0
hook.Add( "HUDPaint", "BRS.HUDPaint_DrawHUD", function()
    if( IsValid( BRS_HUD.avatar ) ) then
        BRS_HUD.avatar:SetPlayer( LocalPlayer(), 64 )
    else
        createAvatarHUD()
    end

    local topText = LocalPlayer():Nick() .. " - " .. (LocalPlayer():getDarkRPVar( "job" ) or "NIL")
    surface.SetFont( "BRICKS_SERVER_Font25" )
    local topTextX, topTextY = surface.GetTextSize( topText )

    BRS_HUD.w = math.max( 380, BRS_HUD.h+topTextX+10 )

    draw.RoundedBox( 5, BRS_HUD.x, BRS_HUD.y, BRS_HUD.w, BRS_HUD.h, BRICKS_SERVER.Func.GetTheme( 3 ) )
    draw.RoundedBox( 5, BRS_HUD.x+5, BRS_HUD.y+5, BRS_HUD.h-10, BRS_HUD.h-10, BRICKS_SERVER.Func.GetTheme( 2 ) )

    draw.SimpleText( topText, "BRICKS_SERVER_Font25", BRS_HUD.x+BRS_HUD.h, BRS_HUD.y+5, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
    draw.SimpleText( "Wallet: " .. DarkRP.formatMoney( LocalPlayer():getDarkRPVar( "money" ) or 0 ), "BRICKS_SERVER_Font20", BRS_HUD.x+BRS_HUD.h+2, BRS_HUD.y+5+20, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )

    local barX = BRS_HUD.x+5+(BRS_HUD.h-10)+5+3
    local barW = BRS_HUD.w-BRS_HUD.h-5-8
    -- health
	draw.RoundedBox( 5, barX, BRS_HUD.y+60, barW, 10, BRICKS_SERVER.Func.GetTheme( 2 ) )

	lerpHealth = Lerp( RealFrameTime()*2, lerpHealth, LocalPlayer():Health() )
	draw.RoundedBox( 5, barX, BRS_HUD.y+60, (barW)*math.Clamp( (lerpHealth/LocalPlayer():GetMaxHealth()), 0, 1 ), 10, BRICKS_SERVER.DEVCONFIG.BaseThemes.Red )
    
    -- armor
	draw.RoundedBox( 5, barX, BRS_HUD.y+60+10+10, barW, 10, BRICKS_SERVER.Func.GetTheme( 2 ) )

	lerpArmor = Lerp( RealFrameTime()*2, lerpArmor, LocalPlayer():Armor() )
    draw.RoundedBox( 5, barX, BRS_HUD.y+60+10+10, (barW)*math.Clamp( (lerpArmor/100), 0, 1 ), 10, BRICKS_SERVER.DEVCONFIG.AccentThemes["Blue"][2] )
end )