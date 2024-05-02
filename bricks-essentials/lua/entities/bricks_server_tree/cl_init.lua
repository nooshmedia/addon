include('shared.lua')

local iconMat = Material( "materials/bricks_server/heart.png" )
local fadeDistance = 50000
function ENT:Draw()
	self:DrawModel()

	local distance = LocalPlayer():GetPos():DistToSqr( self:GetPos() )
	if( distance >= fadeDistance ) then
		if( (self.lerpDisplayFade or 1) <= 0 ) then return end
		self.lerpDisplayFade = Lerp( FrameTime()*10, (self.lerpDisplayFade or 0), 0 )
	elseif( (self.lerpDisplayFade or 0) < 1 ) then
		self.lerpDisplayFade = Lerp( FrameTime()*10, (self.lerpDisplayFade or 0), 1 )
	end

	local entAngles = self:GetAngles()

	local entPos = self:GetPos()
	local plyPos = LocalPlayer():GetPos()

	local ang = math.atan2( plyPos.y-entPos.y, plyPos.x-entPos.x )
	ang = ang * (180/math.pi)
	ang = -ang-90

	entAngles:RotateAroundAxis( entAngles:Forward(), 90 )
	entAngles:RotateAroundAxis( entAngles:Right(), entAngles[2]+ang )

	surface.SetAlphaMultiplier( self.lerpDisplayFade )

	local w, h = 2500, 500
	local x, y =  -(w/2), -h
	cam.Start3D2D( self:GetPos()-(entAngles:Right()*50)+(entAngles:Up()*BRICKS_SERVER.DEVCONFIG.TreeModels[self:GetModel()]), entAngles, 0.01 )
		draw.RoundedBox( 64, x-10, y-10, w+20, h+20, BRICKS_SERVER.Func.GetTheme( 3 ) )
		draw.RoundedBox( 64, x, y, w, h, BRICKS_SERVER.Func.GetTheme( 1 ) )

		local iconSize = 256
		local iconSpacing = (h-iconSize)/2

		local progressH = h*0.3
		local progressSpacing = (h-progressH)/2
		local progressW = w-h-(2*progressSpacing)+iconSpacing
		local progressX, progressY = x+h-iconSpacing+progressSpacing, y+(h/2)-(progressH/2)

		draw.RoundedBox( progressH/2, progressX, progressY, progressW, progressH, BRICKS_SERVER.Func.GetTheme( 2 ) )

		self.lerpProgress = Lerp( FrameTime(), (self.lerpProgress or 1), math.Clamp( self:GetFarmableHealth()/100, 0, 1 ) )
		draw.RoundedBox( progressH/2, progressX, progressY, progressW*self.lerpProgress, progressH, BRICKS_SERVER.DEVCONFIG.BaseThemes.DarkRed )

		surface.SetMaterial( iconMat )
		surface.SetDrawColor( BRICKS_SERVER.DEVCONFIG.BaseThemes.Red )
		surface.DrawTexturedRect( x+iconSpacing, y+iconSpacing, iconSize, iconSize )
	cam.End3D2D()

	surface.SetAlphaMultiplier( 1 )
end