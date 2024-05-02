include("shared.lua")

local unlockMat = Material( "materials/bricks_server/unlock.png" )
local alarmMat = Material( "materials/bricks_server/alarm.png" )
local restockMat = Material( "materials/bricks_server/restock.png" )
function ENT:Draw()
	self:DrawModel()

	if( LocalPlayer():GetPos():DistToSqr( self:GetPos() ) >= BRICKS_SERVER.CONFIG.GENERAL["3D2D Display Distance"] ) then return end

	local selfAngles = self:GetAngles()

	selfAngles:RotateAroundAxis( selfAngles:Forward(), 90 )
	selfAngles:RotateAroundAxis( selfAngles:Right(), 270 )
	selfAngles:RotateAroundAxis( selfAngles:Forward(), 15 )
	
	local policeCount = 0
	for k, v in pairs( player.GetAll() ) do
		if( (BRICKS_SERVER.CONFIG.ARMORY.PoliceJobs or {})[(v:getJobTable() or {}).command or ""] ) then
			policeCount = policeCount+1
		end
	end

	local w, h = 250, 75
	local x, y =  -(w/2), -h
	cam.Start3D2D( self:GetPos()+(selfAngles:Up()*7)-(selfAngles:Right()*95), selfAngles, 0.1 )
		draw.RoundedBox( 5, x, y, w, h, BRICKS_SERVER.Func.GetTheme( 1 ) )		
		draw.RoundedBox( 5, x, y, 20, h, BRICKS_SERVER.Func.GetTheme( 5 ) )	

		surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 1 ) )
		surface.DrawRect( x+5, y, 15, h )
		
		draw.SimpleText( "ARMORY", "BRICKS_SERVER_Font30", x+(w/2), y, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, 0 )

		local textXSpacing, textYPos = (w/3.5), y+(2*(h/3))+2
		draw.SimpleText( policeCount .. "/" .. BRICKS_SERVER.CONFIG.ARMORY["Police Requirement"], "BRICKS_SERVER_Font30", x+textXSpacing, textYPos+2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
		draw.SimpleText( "Police", "BRICKS_SERVER_Font17", x+textXSpacing, textYPos-2, BRICKS_SERVER.Func.GetTheme( 5 ), TEXT_ALIGN_CENTER, 0 )

		draw.SimpleText( DarkRP.formatMoney( self:GetMoneyValue() or 0 ), "BRICKS_SERVER_Font30", x+w-textXSpacing, textYPos+2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
		draw.SimpleText( "Holding", "BRICKS_SERVER_Font17", x+w-textXSpacing, textYPos-2, BRICKS_SERVER.Func.GetTheme( 5 ), TEXT_ALIGN_CENTER, 0 )
	cam.End3D2D()

	-- Progress --
	selfAngles:RotateAroundAxis( selfAngles:Forward(), -15 )
	
	local progressX, progressY =  0, 0
	local radius = 100
	cam.Start3D2D( self:GetPos()+(selfAngles:Up()*30)-(selfAngles:Right()*65), selfAngles, 0.05 )
		local function DrawAlert( percent, iconMat )
			BRICKS_SERVER.Func.DrawCircle( progressX, progressY, radius, BRICKS_SERVER.Func.GetTheme( 3 ) )

			BRICKS_SERVER.Func.DrawCircle( progressX, progressY, radius-2, BRICKS_SERVER.Func.GetTheme( 2 ) )
	
			local degree = math.Clamp( percent, 0, 1 )*360
			BRICKS_SERVER.Func.DrawArc( progressX, progressY, radius, 2, -90, degree-90, BRICKS_SERVER.Func.GetTheme( 5 ) )
	
			local iconSize = 64
			surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
			surface.SetMaterial( iconMat )
			surface.DrawTexturedRect( progressX-(iconSize/2), progressY-(iconSize/2), iconSize, iconSize )
		end

		if( self:GetRobberyCooldown() > CurTime() ) then
			DrawAlert( (self:GetRobberyCooldown() - CurTime())/BRICKS_SERVER.CONFIG.ARMORY["Robbery Cooldown"], restockMat )
		elseif( self:GetFailCooldown() > CurTime() ) then
			DrawAlert( (self:GetFailCooldown() - CurTime())/BRICKS_SERVER.CONFIG.ARMORY["Fail Cooldown"], alarmMat )			
		elseif( self:GetUnlockTimer() > CurTime() ) then
			DrawAlert( (self:GetUnlockTimer() - CurTime())/BRICKS_SERVER.CONFIG.ARMORY["Open Time"], unlockMat )
		end
	cam.End3D2D()
end

net.Receive( "BRS.Net.ArmoryUse", function()
	if( not IsValid( BRICKS_SERVER_ARMORY ) ) then
		BRICKS_SERVER_ARMORY = vgui.Create( "bricks_server_armory_menu" )
	else
		BRICKS_SERVER_ARMORY:SetVisible( true )
	end
end )