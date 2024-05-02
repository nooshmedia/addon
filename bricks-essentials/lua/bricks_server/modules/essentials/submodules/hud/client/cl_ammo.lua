local iconSize = 24

local ammoMat = Material( "materials/bricks_server/ammo.png" )
hook.Add( "HUDPaint", "BRS.HUDPaint_DrawAmmo", function()
    local text = "0 / 0"
    local wep = LocalPlayer():GetActiveWeapon()
    if( IsValid( wep ) and wep:Clip1() >= 0 ) then
        text = wep:Clip1() .. " / " .. LocalPlayer():GetAmmoCount( wep:GetPrimaryAmmoType() )
    else
        return
    end

    surface.SetFont( "BRICKS_SERVER_Font30" )
    local ammoX, ammoY = surface.GetTextSize( text )
    local H = iconSize+20
    local W = ammoX+10+H
    local X, Y = ScrW()-20-W, ScrH()-20-H

    draw.RoundedBox( 5, X, Y, W, H, BRICKS_SERVER.Func.GetTheme( 3 ) )

    -- ICON --
    surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
    surface.SetMaterial( ammoMat )
    surface.DrawTexturedRect( X+((H-iconSize)/2), Y+(H/2)-(iconSize/2), iconSize, iconSize )
    
    -- TEXT --
    draw.SimpleText( text, "BRICKS_SERVER_Font30", X+H+((W-H)/2)-5, Y+(H/2)-1, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
end )