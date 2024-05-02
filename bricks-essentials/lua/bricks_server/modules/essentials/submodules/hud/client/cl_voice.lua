local AlphaFade = 0

local iconSize = 32
local W, H = iconSize+20, iconSize+20
local X, Y = (ScrW()/2)-(W/2), (ScrH()/10)-(H/2)
local voiceMat = Material( "materials/bricks_server/microphone.png" )
hook.Add( "HUDPaint", "BRS.HUDPaint_DrawVoice", function()
	if( LocalPlayer():IsSpeaking() ) then
		AlphaFade = math.min( AlphaFade + 10, 255 )
	else
		AlphaFade = math.max( AlphaFade - 10, 0 )
	end

	surface.SetAlphaMultiplier( AlphaFade/255 )
		draw.RoundedBox( 5, X, Y, W, H, BRICKS_SERVER.Func.GetTheme( 3 ) )

		surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
		surface.SetMaterial( voiceMat )
		surface.DrawTexturedRect( X+((H-iconSize)/2), Y+(H/2)-(iconSize/2), iconSize, iconSize )
	surface.SetAlphaMultiplier( 1 )
end )