local iconSize = 16
surface.SetFont( "BRICKS_SERVER_Font30" )
local LockDownX, LockDownY = surface.GetTextSize( "LOCKDOWN" )
local H = LockDownY+5
local W = LockDownX+5+H
local X, Y = (ScrW()/2)-(W/2), (ScrH()/10)-(H/2)
local WantedY = 0

local FlashAlpha = 0
local FlashNew = 0
local function FlashChange()
	timer.Simple( 0.5, function() 
		if( FlashNew > 125 ) then
			FlashNew = 0
		else
			FlashNew = 130
		end
		FlashChange()
	end )
end
FlashChange()

local lockdownMat = Material( "materials/bricks_server/lock.png" )
local wantedMat = Material( "materials/bricks_server/wanted.png" )
hook.Add( "HUDPaint", "BRS.HUDPaint_DrawLockdownWanted", function()
    if( GetGlobalBool("DarkRP_LockDown") ) then
		draw.RoundedBox( 5, X, Y, W, H, BRICKS_SERVER.Func.GetTheme( 3 ) )
		
		FlashAlpha = Lerp( FrameTime()*10, FlashAlpha, FlashNew )
		surface.SetAlphaMultiplier( FlashAlpha/255 )
			draw.RoundedBox( 5, X, Y, W, H, BRICKS_SERVER.DEVCONFIG.BaseThemes.Red )
		surface.SetAlphaMultiplier( 1 )

		-- ICON --
		surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
		surface.SetMaterial( lockdownMat )
		surface.DrawTexturedRect( X+((H-iconSize)/2), Y+(H/2)-(iconSize/2), iconSize, iconSize )
		
		-- TEXT --
        draw.SimpleText( "LOCKDOWN", "BRICKS_SERVER_Font30", X+H+((W-H)/2)-5, Y+(H/2)-1, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		
		WantedY = Y+H+5
	else
		WantedY = Y
    end
	
	if( LocalPlayer():isWanted() ) then
		draw.RoundedBox( 5, X, WantedY, W, H, BRICKS_SERVER.Func.GetTheme( 3 ) )
		
		FlashAlpha = Lerp( FrameTime()*10, FlashAlpha, FlashNew )
		surface.SetAlphaMultiplier( FlashAlpha/255 )
			draw.RoundedBox( 5, X, WantedY, W, H, BRICKS_SERVER.DEVCONFIG.BaseThemes.Red )
		surface.SetAlphaMultiplier( 1 )

		-- ICON --
		surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
		surface.SetMaterial( wantedMat )
		surface.DrawTexturedRect( X+((H-iconSize)/2), WantedY+(H/2)-(iconSize/2), iconSize, iconSize )
		
		-- TEXT --
        draw.SimpleText( "WANTED", "BRICKS_SERVER_Font30", X+H+((W-H)/2)-5, WantedY+(H/2)-1, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
end )