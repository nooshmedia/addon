include("shared.lua")

BRS_VAULTS_CSModels = (BRS_VAULTS_CSModels or {})
 
function ENT:Initialize()
	self.VaultRear = ClientsideModel( "models/2rek/brickwall/bwall_vault.mdl" )
	self.VaultRear:SetPos( self:GetPos() )
	self.VaultRear:SetAngles( self:GetAngles() )
	self.VaultRear:SetNoDraw( true )
	self.VaultRear:SetParent( self )
	
	BRS_VAULTS_CSModels[self:EntIndex()] = self
	self.RenderGroup = 7
	self.VaultRear.RenderGroup = 7
end

function ENT:Think()
	if( IsValid( self.VaultRear ) ) then
		self.VaultRear:SetPos( self:GetPos() ) -- Keeps the rear of the vault position aligned with the front
		self.VaultRear:SetAngles( self:GetAngles() ) -- Keeps the rear of the vault angles aligned with the front
	end
end

function ENT:OnRemove()
	if( IsValid( self.VaultRear ) ) then
		self.VaultRear:Remove()
	end
end

local unlockMat = Material( "materials/bricks_server/unlock.png" )
local alarmMat = Material( "materials/bricks_server/alarm.png" )
local restockMat = Material( "materials/bricks_server/restock.png" )
function ENT:Draw()
	self:DrawModel()

	if( LocalPlayer():GetPos():DistToSqr( self:GetPos() ) >= BRICKS_SERVER.CONFIG.GENERAL["3D2D Display Distance"] ) then return end

	local selfAngles = self:GetAngles()

	selfAngles:RotateAroundAxis(selfAngles:Forward(), 90)
	selfAngles:RotateAroundAxis(selfAngles:Right(), 270)
	selfAngles:RotateAroundAxis( selfAngles:Forward(), 15 )
	
	local policeCount = 0
	for k, v in pairs( player.GetAll() ) do
		if( (BRICKS_SERVER.CONFIG.BANKVAULT.PoliceJobs or {})[(v:getJobTable() or {}).command or ""] ) then
			policeCount = policeCount+1
		end
	end
	
	local w, h = 250, 75
	local x, y =  -(w/2), -h
	cam.Start3D2D( self:GetPos()-(selfAngles:Up()*15)-(selfAngles:Right()*98), selfAngles, 0.1 )
		draw.RoundedBox( 5, x, y, w, h, BRICKS_SERVER.Func.GetTheme( 1 ) )		
		draw.RoundedBox( 5, x, y, 20, h, BRICKS_SERVER.Func.GetTheme( 5 ) )	

		surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 1 ) )
		surface.DrawRect( x+5, y, 15, h )
		
		draw.SimpleText( "BANK VAULT", "BRICKS_SERVER_Font30", x+(w/2), y, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, 0 )

		local textXSpacing, textYPos = (w/3.5), y+(2*(h/3))+2
		draw.SimpleText( policeCount .. "/" .. BRICKS_SERVER.CONFIG.BANKVAULT["Police Requirement"] , "BRICKS_SERVER_Font30", x+textXSpacing, textYPos+2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
		draw.SimpleText( "Police", "BRICKS_SERVER_Font17", x+textXSpacing, textYPos-2, BRICKS_SERVER.Func.GetTheme( 5 ), TEXT_ALIGN_CENTER, 0 )

		draw.SimpleText( self:GetMoneyBags() .. "/" .. BRICKS_SERVER.CONFIG.BANKVAULT["Money Bags"], "BRICKS_SERVER_Font30", x+w-textXSpacing, textYPos+2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
		draw.SimpleText( "Money Bags", "BRICKS_SERVER_Font17", x+w-textXSpacing, textYPos-2, BRICKS_SERVER.Func.GetTheme( 5 ), TEXT_ALIGN_CENTER, 0 )
	cam.End3D2D()

	-- Progress --
	selfAngles:RotateAroundAxis( selfAngles:Forward(), -15 )

	local progressX, progressY =  0, 0
	local radius = 100
	cam.Start3D2D( self:GetPos()+(selfAngles:Up()*15)-(selfAngles:Right()*65), selfAngles, 0.05 )
		local function DrawAlert( percent, iconMat )
			surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 2 ) )
			draw.NoTexture()
			BRICKS_SERVER.Func.DrawCircle( progressX, progressY, radius, 45 )
	
			BRICKS_SERVER.Func.DrawArc( progressX, progressY, radius, 2, 0, 360, BRICKS_SERVER.Func.GetTheme( 3 ) )
	
			local degree = math.Clamp( percent, 0, 1 )*360
			BRICKS_SERVER.Func.DrawArc( progressX, progressY, radius, 2, -90, degree-90, BRICKS_SERVER.Func.GetTheme( 5 ) )
	
			local iconSize = 64
			surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
			surface.SetMaterial( iconMat )
			surface.DrawTexturedRect( progressX-(iconSize/2), progressY-(iconSize/2), iconSize, iconSize )
		end

		if( self:GetRobberyCooldown() > CurTime() ) then
			DrawAlert( (self:GetRobberyCooldown() - CurTime())/BRICKS_SERVER.CONFIG.BANKVAULT["Robbery Cooldown"], restockMat )
		elseif( self:GetAlarm() ) then
			DrawAlert( (self:GetAlarmCooldown() - CurTime())/BRICKS_SERVER.CONFIG.BANKVAULT["Alarm Duration"], alarmMat )
		end
	cam.End3D2D()
end

--[[ RENDERING REAR ATM ]]--
hook.Add( "PostDrawTranslucentRenderables", "BRS.PreDrawTranslucentRenderables_VaultStencils", function( isDrawingDepth, isDrawSkybox )
	if( isDrawSkybox or isDrawingDepth ) then return end

	for k, v in pairs( BRS_VAULTS_CSModels ) do
		if( not IsValid( v ) or not v.VaultRear or not IsValid( v.VaultRear ) ) then 
			if( v.VaultRear ) then
				v.VaultRear:Remove()
			end
			BRS_VAULTS_CSModels[k] = nil
			continue 
		end

		local screenpos = v:GetPos():ToScreen()
		if( screenpos.visible == false and LocalPlayer():GetEyeTrace().Entity != v ) then
			continue
		end

		render.ClearStencil()
		render.SetStencilEnable( true )
		render.SetStencilReferenceValue( 69 )
		render.SetStencilWriteMask( 255 )
		render.SetStencilTestMask( 255 )
		render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_ALWAYS )
		render.SetStencilPassOperation( STENCILOPERATION_REPLACE )

		local VAngles = v:GetAngles()
		VAngles:RotateAroundAxis( VAngles:Right(), -90 )

		cam.Start3D2D( v:GetPos() - ( v:GetAngles():Up() * -10 ), VAngles, 0.5 )
			draw.NoTexture()
			draw.RoundedBox( 0, -170, -80, 175, 150, Color( 255, 255, 255, 1 ) )
		cam.End3D2D()
		
		render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )
		render.DepthRange( 0, 0.8 )
		
		v.VaultRear:DrawModel()
		
		render.SetStencilEnable(false)
		render.DepthRange( 0, 1 )
	end
end )

--[[ UNLOCKING UI ]]--
net.Receive( "BRS.Net.BankUse", function()
	local ReceivedEnt = net.ReadEntity()
	
	if( not IsValid( ReceivedEnt.VaultMenu ) ) then
		ReceivedEnt.VaultMenu = vgui.Create( "bricks_server_bankvault_menu" )
		ReceivedEnt.VaultMenu.VaultEnt = ReceivedEnt
	else
		ReceivedEnt.VaultMenu:SetVisible( true )
	end
end )