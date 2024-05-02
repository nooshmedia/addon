local PANEL = {}

function PANEL:Init()
    self:SetSize( ScrW(), ScrH() )
    self:Center()
    self:MakePopup()
    self:SetTitle( "" )
    self:SetDraggable( false )
    self:ShowCloseButton( false )

    self.mainPanel = vgui.Create( "DPanel", self )
    self.mainPanel:SetWide( ScrW()*0.5 )
    self.mainPanel:SetTall( 40+50+10+10+10+(((self.mainPanel:GetWide()-20)/16)*9) )
    self.mainPanel:Center()
    self.mainPanel.headerHeight = 40
    self.mainPanel:DockPadding( 0, self.mainPanel.headerHeight, 0, 0 )
    self.mainPanel.Paint = function( self2, w, h )
        draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
        draw.RoundedBoxEx( 5, 0, 0, w, self.mainPanel.headerHeight, BRICKS_SERVER.Func.GetTheme( 0 ), true, true, false, false )
    
        local requestedPly = player.GetBySteamID64( self.requestedID64 or "" )
        if( requestedPly and IsValid( requestedPly ) ) then 
            draw.SimpleText( "Screen View - " .. requestedPly:Nick(), "BRICKS_SERVER_Font30", 10, (self.mainPanel.headerHeight or 40)/2-2, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_CENTER )
        else
            draw.SimpleText( "Screen View", "BRICKS_SERVER_Font30", 10, (self.mainPanel.headerHeight or 40)/2-2, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_CENTER )
        end
    end

    local closeButton = vgui.Create( "DButton", self.mainPanel )
	local size = 24
	closeButton:SetSize( size, size )
	closeButton:SetPos( self.mainPanel:GetWide()-size-((self.mainPanel.headerHeight-size)/2), (self.mainPanel.headerHeight/2)-(size/2) )
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
        if( self.requestedID64 and not self.loaded ) then
            net.Start( "BRS.Net.ScreenAdminCancel" )
                net.WriteString( self.requestedID64 or "" )
            net.SendToServer()
        end

        self:Remove()
    end

    self.topBar = vgui.Create( "DPanel", self.mainPanel )
    self.topBar:DockMargin( 10, 10, 10, 0 )
    self.topBar:Dock( TOP )
    self.topBar:SetTall( 50 )
    self.topBar.Paint = function() end
    
    local refreshButton = vgui.Create( "DButton", self.topBar )
    refreshButton:Dock( RIGHT )
    refreshButton:DockMargin( 5, 0, 0, 0 )
    refreshButton:SetWide( self.topBar:GetTall() )
    refreshButton:SetText( "" )
    local changeAlpha = 0
    local refreshMat = Material( "materials/bricks_server/refresh.png" )
    refreshButton.Paint = function( self2, w, h ) 
        if( self2:IsDown() ) then
            changeAlpha = math.Clamp( changeAlpha+10, 0, 255 )
        elseif( self2:IsHovered() ) then
            changeAlpha = math.Clamp( changeAlpha+10, 0, 255 )
        else
            changeAlpha = math.Clamp( changeAlpha-10, 0, 255 )
        end

        draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )

        surface.SetAlphaMultiplier( changeAlpha/255 )
            draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 4 ) )
        surface.SetAlphaMultiplier( 1 )

        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
        surface.SetMaterial( refreshMat )
        local iconSize = 24
        surface.DrawTexturedRect( (h-iconSize)/2, (h/2)-(iconSize/2), iconSize, iconSize )
    end
    refreshButton.DoClick = function()
        if( not self.requestedID64 or not self.loaded ) then return end

        self.loaded = false

        net.Start( "BRS.Net.ScreenAdminRequest" )
            net.WriteString( self.requestedID64 )
            net.WriteUInt( (BS_SCREENGRAB_QUALITY or 70), 7 )
        net.SendToServer()

        self.mainPanelCenter:Clear()
        self.openTime = CurTime()
        self.loadTime = nil
    end

    local qualitySliderBack = vgui.Create( "DPanel", self.topBar )
    qualitySliderBack:Dock( RIGHT )
    qualitySliderBack:DockMargin( 5, 0, 0, 0 )
    qualitySliderBack:SetWide( self.topBar:GetTall()*4 )
    qualitySliderBack.Paint = function( self2, w, h ) 
        draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )

        draw.SimpleText( "Quality: " .. (BS_SCREENGRAB_QUALITY or 70) .. "%", "BRICKS_SERVER_Font17", w/2, h-5, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
    end

    local qualitySlider = vgui.Create( "DNumSlider", qualitySliderBack )
    qualitySlider:Dock( FILL )
    qualitySlider:DockMargin( 0, 0, 0, 10 )
    qualitySlider:SetText( "" )
    qualitySlider:SetMin( 1 )
    qualitySlider:SetMax( 100 )
    qualitySlider:SetDecimals( 0 )
    qualitySlider:SetValue( BS_SCREENGRAB_QUALITY or 70 )
    qualitySlider.OnValueChanged = function( self2, value )
        BS_SCREENGRAB_QUALITY = math.floor( value )
    end

    local infoPanel = vgui.Create( "DPanel", self.topBar )
    infoPanel:Dock( FILL )
    self.openTime = CurTime()
    infoPanel.Paint = function( self2, w, h )
        draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )

        local timeTaken = CurTime()-self.openTime
        if( self.loadTime and self.openTime+timeTaken >= (self.loadTime or 0) ) then
            timeTaken = self.loadTime-self.openTime
        end

        draw.SimpleText( "Time Taken: " .. BRICKS_SERVER.Func.FormatTime( timeTaken, true ), "BRICKS_SERVER_Font20", w/3, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        draw.SimpleText( "Resolution: " .. ((self.imageWidth and (self.imageWidth or 0) .. "x" .. (self.imageHeight or 0)) or "Loading"), "BRICKS_SERVER_Font20", w/3*2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end

    self.mainPanelCenter = vgui.Create( "DPanel", self.mainPanel )
    self.mainPanelCenter:Dock( FILL )
    local loadingIcon = Material( "materials/bricks_server/loading.png" )
    self.mainPanelCenter.Paint = function( self, w, h ) 
        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.SetMaterial( loadingIcon )
        local size = 32
        surface.DrawTexturedRectRotated( w/2, h/2, size, size, -(CurTime() % 360 * 250) )

        draw.SimpleText( "Loading", "BRICKS_SERVER_Font20", w/2, h/2+(size/2)+5, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, 0 )
    end 
end

function PANEL:SetImageInfo( imageString, requestedID64 )
    self.loaded = true
    self.requestedID64 = requestedID64 or ""
    self.loadTime = CurTime()
    self.mainPanelCenter:Clear()

    local screenGrabMargin = 10

    local screenGrab = vgui.Create( "DPanel", self.mainPanelCenter )
    screenGrab:DockMargin( screenGrabMargin, screenGrabMargin, screenGrabMargin, screenGrabMargin )
    screenGrab:Dock( TOP )
    local screenGrabWidth = self.mainPanel:GetWide()-(2*screenGrabMargin)
    local screenGrabHeight = (screenGrabWidth/16)*9
    screenGrab:SetTall( screenGrabHeight )
    local screenMaterial = Material( imageString )
    screenGrab.Paint = function( self2, w, h )
        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.SetMaterial( screenMaterial )
        surface.DrawTexturedRect( 0, 0, w, h )
    end
    self.imageWidth = screenMaterial:Width()
    self.imageHeight = screenMaterial:Height()

    file.Delete( "brs_temp_screengrab.jpg" )

    local fullscreenButton = vgui.Create( "DButton", screenGrab )
    fullscreenButton:SetSize( 36, 36 )
    fullscreenButton:SetPos( screenGrabWidth-5-36, screenGrabHeight-5-36 )
    fullscreenButton:SetText( "" )
    local changeAlpha = 95
    local webMat = Material( "materials/bricks_server/fullscreen.png" )
    fullscreenButton.Paint = function( self3, w, h )
        if( self3:IsDown() ) then
            changeAlpha = math.Clamp( changeAlpha+10, 95, 255 )
        elseif( self3:IsHovered() ) then
            changeAlpha = math.Clamp( changeAlpha+10, 95, 165 )
        else
            changeAlpha = math.Clamp( changeAlpha-10, 95, 165 )
        end

        surface.SetAlphaMultiplier( changeAlpha/255 )
        draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
        surface.SetAlphaMultiplier( 1 )

        surface.SetMaterial( webMat )
        local size = 24
        surface.SetDrawColor( 0, 0, 0, 255 )
        surface.DrawTexturedRect( (h-size)/2-1, (h-size)/2+1, size, size )

        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.DrawTexturedRect( (h-size)/2, (h-size)/2, size, size )
    end
    fullscreenButton.DoClick = function()
        if( IsValid( BS_ADMIN_SCREENGRAB_FS ) ) then 
            BS_ADMIN_SCREENGRAB_FS:Remove()
        end

        BS_ADMIN_SCREENGRAB_FS = vgui.Create( "DFrame" )
        BS_ADMIN_SCREENGRAB_FS:SetSize( 0, 0 )
        local transitioning = true
        BS_ADMIN_SCREENGRAB_FS:SizeTo( ScrW(), ScrH(), 0.35, 0, 1, function()
            transitioning = false
            BS_ADMIN_SCREENGRAB_FS:Center() 
        end )
        BS_ADMIN_SCREENGRAB_FS:Center()
        BS_ADMIN_SCREENGRAB_FS:SetTitle( "" )
        BS_ADMIN_SCREENGRAB_FS:DockPadding( 0, 0, 0, 0 )
        BS_ADMIN_SCREENGRAB_FS:MakePopup()
        BS_ADMIN_SCREENGRAB_FS:SetDraggable( false )
        BS_ADMIN_SCREENGRAB_FS:ShowCloseButton( false )
        BS_ADMIN_SCREENGRAB_FS.OnSizeChanged = function( self2 )
            if( transitioning ) then
                self2:Center() 
            end
        end
        BS_ADMIN_SCREENGRAB_FS.Paint = function( self2, w, h )
            if( not screenMaterial ) then return end

            surface.SetDrawColor( 255, 255, 255, 255 )
            surface.SetMaterial( screenMaterial )
            surface.DrawTexturedRect( 0, 0, w, h )
        end

        local unFullscreenButton = vgui.Create( "DButton", BS_ADMIN_SCREENGRAB_FS )
        unFullscreenButton:SetSize( 36, 36 )
        unFullscreenButton:SetPos( ScrW()-5-36, ScrH()-5-36 )
        unFullscreenButton:SetText( "" )
        local changeAlpha = 95
        local minimizeMat = Material( "materials/bricks_server/minimize.png" )
        unFullscreenButton.Paint = function( self3, w, h )
            if( self3:IsDown() ) then
                changeAlpha = math.Clamp( changeAlpha+10, 95, 255 )
            elseif( self3:IsHovered() ) then
                changeAlpha = math.Clamp( changeAlpha+10, 95, 165 )
            else
                changeAlpha = math.Clamp( changeAlpha-10, 95, 165 )
            end
    
            surface.SetAlphaMultiplier( changeAlpha/255 )
            draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
            surface.SetAlphaMultiplier( 1 )
    
            surface.SetMaterial( minimizeMat )
            local size = 24
            surface.SetDrawColor( 0, 0, 0, 255 )
            surface.DrawTexturedRect( (h-size)/2-1, (h-size)/2+1, size, size )
    
            surface.SetDrawColor( 255, 255, 255, 255 )
            surface.DrawTexturedRect( (h-size)/2, (h-size)/2, size, size )
        end
        unFullscreenButton.DoClick = function()
            transitioning = true
            BS_ADMIN_SCREENGRAB_FS:SizeTo( 0, 0, 0.35, 0, 1, function()
                if( IsValid( BS_ADMIN_SCREENGRAB_FS ) ) then
                    BS_ADMIN_SCREENGRAB_FS:Remove()
                end
            end )
        end
    end

    self.mainPanel:SetTall( screenGrabHeight+(3*screenGrabMargin)+self.mainPanel.headerHeight+self.topBar:GetTall() )
    self.mainPanel:Center()
end

function PANEL:Paint( w, h )
    BRICKS_SERVER.Func.DrawBlur( self, 4, 4 )
end

vgui.Register( "bricks_server_admin_screengrab", PANEL, "DFrame" )