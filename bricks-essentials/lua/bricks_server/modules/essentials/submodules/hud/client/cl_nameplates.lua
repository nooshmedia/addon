local iconSize = 32
local iconBoxSize = iconSize+20

local playerMat = Material( "materials/bricks_server/player.png" )
local speakerMat = Material( "materials/bricks_server/speaker.png" )
local typingMat = Material( "materials/bricks_server/chat.png" )
local wantedMat = Material( "materials/bricks_server/wanted_32.png" )

hook.Add( "PostPlayerDraw", "BRS.PostPlayerDraw_DrawNameplates", function( ply )
	if( ply == LocalPlayer() or not IsValid( ply ) or not ply:Alive() ) then return end

	local distance = LocalPlayer():GetPos():DistToSqr( ply:GetPos() )
	if( distance > BRICKS_SERVER.CONFIG.GENERAL["3D2D Display Distance"] ) then return end

	local ang = LocalPlayer():EyeAngles()
	local pos = ply:GetPos() + Vector( 0, 0, ply:OBBMaxs().z )

	ang:RotateAroundAxis( ang:Forward(), 90 )
	ang:RotateAroundAxis( ang:Right(), 90 )

	surface.SetFont( "BRICKS_SERVER_Font30" )
	local nameX, nameY = surface.GetTextSize( ply:Nick() )
	local H = iconBoxSize
	local W = iconBoxSize+10+nameX+10
	local X, Y = -(W/2), -H-25

	local donationRank
	for k, v in pairs( BRICKS_SERVER.CONFIG.GENERAL.Groups ) do
		if( BRICKS_SERVER.Func.IsInGroup( ply, v[1] ) ) then
			donationRank = k
			break
		end
	end

	local iconMat = playerMat
	if( ply:IsSpeaking() ) then
		iconMat = speakerMat
	elseif( ply:IsTyping() ) then
		iconMat = typingMat
	elseif( ply:isWanted() ) then
		iconMat = wantedMat
	end
	
	cam.Start3D2D( pos, Angle( 0, ang.y, 90 ), 0.1 )
		local AlphaMulti = 1-(distance/BRICKS_SERVER.CONFIG.GENERAL["3D2D Display Distance"])
		surface.SetAlphaMultiplier( AlphaMulti )
		draw.RoundedBox( 5, X, Y, iconBoxSize, iconBoxSize, BRICKS_SERVER.Func.GetTheme( 2 ) )	
		
		if( BRICKS_SERVER.CONFIG.GENERAL.Groups[donationRank] ) then
			draw.RoundedBoxEx( 5, X, Y, 5, iconBoxSize, (BRICKS_SERVER.CONFIG.GENERAL.Groups[donationRank][3] or BRICKS_SERVER.Func.GetTheme( 5 )), true, false, true, false )
		end

		surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
		surface.SetMaterial( iconMat )

		if( BRICKS_SERVER.CONFIG.GENERAL.Groups[donationRank] ) then
			surface.DrawTexturedRect( X+5+((iconBoxSize-iconSize-5)/2), Y+((iconBoxSize-iconSize)/2), iconSize, iconSize )
		else
			surface.DrawTexturedRect( X+((iconBoxSize-iconSize)/2), Y+((iconBoxSize-iconSize)/2), iconSize, iconSize )
		end
		
		draw.SimpleText( ply:Nick(), "BRICKS_SERVER_Font33", X+H+10, Y+(H/2)+2, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_BOTTOM )
		
		local TeamCol = team.GetColor( ply:Team() )
		draw.SimpleText( ply:getDarkRPVar( "job" ), "BRICKS_SERVER_Font25", X+H+10, Y+(H/2)-2, TeamCol, 0, 0 )
		surface.SetAlphaMultiplier( 1 )
	cam.End3D2D()
end )