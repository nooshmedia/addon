local PANEL = {}

function PANEL:Init()
	self:SetSize( ScrW()*0.35, ScrH()*0.5 )
	self:Center()
	self:MakePopup()
	self:SetTitle( "" )
	self:ShowCloseButton( false )
	self:SetDraggable( false )
	self:DockPadding( 0, 40, 0, 0 )

	local closeButton = vgui.Create( "DButton", self )
	local size = 24
	closeButton:SetSize( size, size )
	closeButton:SetPos( self:GetWide()-size-((40-size)/2), (40/2)-(size/2) )
	closeButton:SetText( "" )
    local CloseMat = Material( "materials/bricks_server/close.png" )
    local textColor = BRICKS_SERVER.Func.GetTheme( 6 )
	closeButton.Paint = function( self2, w, h )
		if( self2:IsHovered() and !self2:IsDown() ) then
			surface.SetDrawColor( textColor.r*0.6, textColor.g*0.6, textColor.b*0.6 )
		elseif( self2:IsDown() || self2.m_bSelected ) then
			surface.SetDrawColor( textColor.r*0.8, textColor.g*0.8, textColor.b*0.8 )
		else
			surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 2 ) )
		end

		surface.SetMaterial( CloseMat )
		surface.DrawTexturedRect( 0, 0, w, h )
	end
	closeButton.DoClick = function()
		self:Remove()
		
		if( IsValid( self.VaultEnt ) ) then
			net.Start( "BRS.Net.BankFail" ) 
				net.WriteEntity( self.VaultEnt )
			net.SendToServer()
		end
	end
	
	local puzzleBackground = vgui.Create( "DPanel", self )
	puzzleBackground:Dock( FILL )
	puzzleBackground.Paint = function( self2, w, h ) end
	
	local panelSelf = self
	function self:CreatePuzzle()
		puzzleBackground:Clear()

		local circleBack = vgui.Create( "DPanel", puzzleBackground )
		circleBack:SetTall( (panelSelf:GetTall()-40)*0.75 )
		circleBack:SetWide( circleBack:GetTall() )
		circleBack:SetPos( (panelSelf:GetWide()/2)-(circleBack:GetWide()/2), ((panelSelf:GetTall()-40)/2)-(circleBack:GetTall()/2) )
		local circleThick = 30
		local pinsPressed = 0
		local pinStart, pinEnd = 0, 0
		circleBack.Paint = function( self2, w, h ) 
			surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 2 ) )
			draw.NoTexture()
			BRICKS_SERVER.Func.DrawCircle( w/2, h/2, w/2, 65 )

			BRICKS_SERVER.Func.DrawArc( w/2, h/2, w/2, circleThick, 0, 360, BRICKS_SERVER.Func.GetTheme( 3 ) )

			BRICKS_SERVER.Func.DrawArc( w/2, h/2, w/2, circleThick, pinStart, pinEnd, BRICKS_SERVER.Func.GetTheme( 4 ) )

			draw.SimpleText( (BRICKS_SERVER.CONFIG.BANKVAULT["Pins Required"] or 3)-pinsPressed, "BRICKS_SERVER_Font50", w/2, h-(h/6), BRICKS_SERVER.Func.GetTheme( 5 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end

		local pinWide = 20
		local function CreatePin()
			pinStart = math.random( 0, 360 )
			pinEnd = pinStart+pinWide
		end
		CreatePin()

		local unlocker = vgui.Create( "DPanel", circleBack )
		unlocker:SetSize( circleBack:GetWide(), circleBack:GetTall() )
		unlocker:SetPos( 0, 0 )
		local unlockerWide = 3
		local rotatePos = 0
		local direction = true
		unlocker.Paint = function( self2, w, h ) 
			if( direction ) then
				rotatePos = math.Clamp( rotatePos+0.6, -360, 360 )
			else
				rotatePos = math.Clamp( rotatePos-0.6, -360, 360 )
			end

			if( math.abs( rotatePos ) >= 360 ) then
				rotatePos = 0
			end

			BRICKS_SERVER.Func.DrawArc( w/2, h/2, w/2, circleThick, rotatePos, rotatePos+unlockerWide, BRICKS_SERVER.Func.GetTheme( 5 ) )
		end

		local iconSize = 256
		local unlockButton = vgui.Create( "DButton", circleBack )
		unlockButton:SetSize( iconSize, iconSize )
		unlockButton:SetPos( (circleBack:GetWide()/2)-(unlockButton:GetWide()/2), (circleBack:GetTall()/2)-(unlockButton:GetTall()/2) )
		unlockButton:SetText( "" )
		local lockMat = Material( "materials/bricks_server/lock_256.png" )
		local hoverAlpha = 0
		unlockButton.Paint = function( self2, w, h ) 
			surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 3 ) )
			surface.SetMaterial( lockMat )
			surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )

			if( self2:IsDown() ) then
				hoverAlpha = 200
			elseif( self2:IsHovered() ) then
				hoverAlpha = math.Clamp( hoverAlpha+5, 0, 100 )
			else
				hoverAlpha = math.Clamp( hoverAlpha-5, 0, 200 )
			end

			surface.SetAlphaMultiplier( hoverAlpha/255 )
			surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 2 ) )
			surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
			surface.SetAlphaMultiplier( 1 )
		end
		unlockButton.DoClick = function()
			local finalRotatePos = math.abs( rotatePos )
			if( finalRotatePos >= pinStart and finalRotatePos <= pinEnd ) then
				surface.PlaySound( "HL1/fvox/bell.wav" )
				pinsPressed = pinsPressed+1
				if( pinsPressed >= (BRICKS_SERVER.CONFIG.BANKVAULT["Pins Required"] or 3) ) then
					if( IsValid( self.VaultEnt ) ) then
						net.Start( "BRS.Net.BankUnlock" ) 
							net.WriteEntity( self.VaultEnt )
						net.SendToServer()
					end

					self:Remove()
				else
					CreatePin()
				end
			else
				if( IsValid( self.VaultEnt ) ) then
					net.Start( "BRS.Net.BankFail" ) 
						net.WriteEntity( self.VaultEnt )
					net.SendToServer()
				end

				self:Remove()
			end		
		end
	end
	
	self:CreatePuzzle()
end

function PANEL:Think()
	if( not IsValid( self.VaultEnt ) ) then
		self:Remove()
	end
end

local rounded = 5
function PANEL:Paint( w, h )
    draw.RoundedBox( rounded, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 1 ) )
    draw.RoundedBoxEx( rounded, 0, 0, w, 40, BRICKS_SERVER.Func.GetTheme( 0 ), true, true, false, false )

    draw.SimpleText( "Bank vault", "BRICKS_SERVER_Font30", 10, 40/2-2, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_CENTER )
end
 
vgui.Register( "bricks_server_bankvault_menu", PANEL, "DFrame" )