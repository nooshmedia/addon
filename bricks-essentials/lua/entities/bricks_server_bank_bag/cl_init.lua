include('shared.lua')

function ENT:Draw()
	self:DrawModel()
	
	local Distance = LocalPlayer():GetPos():DistToSqr( self:GetPos() )

	if( Distance < BRICKS_SERVER.CONFIG.GENERAL["3D2D Display Distance"] ) then
		local ang = LocalPlayer():EyeAngles()
		local pos = self:GetPos() + Vector( 0, 0, self:OBBMaxs().z )

		ang:RotateAroundAxis( ang:Forward(), 90 )
		ang:RotateAroundAxis( ang:Right(), 90 )
		
		surface.SetFont( "BRICKS_SERVER_Font25" )
		local TextX, TextY = surface.GetTextSize( DarkRP.formatMoney( self:GetMoney() ) )
		local W, H = TextX+25, 50
		local X, Y = -(W/2), -H-25
		cam.Start3D2D( pos, Angle( 0, ang.y, 90 ), 0.1 )
			local AlphaMulti = 1-(Distance/BRICKS_SERVER.CONFIG.GENERAL["3D2D Display Distance"])
			surface.SetAlphaMultiplier( AlphaMulti )
			draw.RoundedBox( 5, X, Y, W, H, BRICKS_SERVER.Func.GetTheme( 2 ) )
			surface.SetAlphaMultiplier( 1 )
			
			draw.SimpleText( DarkRP.formatMoney( self:GetMoney() ), "BRICKS_SERVER_Font25", X+(W/2), Y+(H/2), Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		cam.End3D2D()
	end
end
