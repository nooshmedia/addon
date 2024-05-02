local PANEL = {}

function PANEL:Init()
    self:SetSize( ScrW()*0.3, ScrH()*0.2 )
    self:Center()
    self:MakePopup()
    self:SetTitle( "" )
    self.headerHeight = 40
    self:DockPadding( 0, self.headerHeight, 0, 0 )
    self:SetDraggable( false )
    self:ShowCloseButton( false )

    local closeButton = vgui.Create( "DButton", self )
	local size = 24
	closeButton:SetSize( size, size )
	closeButton:SetPos( self:GetWide()-size-((self.headerHeight-size)/2), (self.headerHeight/2)-(size/2) )
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
        if( self.oldPanel and IsValid( self.oldPanel ) ) then
            self.oldPanel:SetVisible( true )
        end

        self:Remove()
    end
    
    local rewardsMain = vgui.Create( "bricks_server_scrollpanel", self )
    rewardsMain:Dock( FILL )
    rewardsMain:DockMargin( 10, 10, 10, 10 )
    rewardsMain.Paint = function( self, w, h ) end 

    self.rewardsGrid = vgui.Create( "DIconLayout", rewardsMain )
    self.rewardsGrid:Dock( FILL )
    local spacing = 5
    self.rewardsGrid:SetSpaceY( spacing )
    self.rewardsGrid:SetSpaceX( spacing )
end

function PANEL:SetRewards( rewards, BossKey, viewAll )
    self.rewardsGrid:Clear()

    if( viewAll ) then
        self.viewAll = true
    end

    local gridWide = self:GetWide()-20
    local slotsWide = 5
    local spacing = 5
    local slotSize = (gridWide-((slotsWide-1)*spacing))/slotsWide

    if( not viewAll ) then
        self:SetTall( slotSize+20+40+self.headerHeight+spacing )
    else
        self:SetTall( slotSize+20+self.headerHeight )
    end

    for k, v in pairs( rewards ) do
        local slotBack = self.rewardsGrid:Add( "DButton" )
        slotBack:SetSize( slotSize, slotSize )
        slotBack:SetText( "" )
        local x, y, w, h = 0, 0, slotSize, slotSize
        local itemModel
        local changeAlpha = 0
        local rewardIcon
        if( v.Icon ) then
			BRICKS_SERVER.Func.GetImage( v.Icon or "", function( mat ) rewardIcon = mat end )
		end
        slotBack.Paint = function( self2, w, h )
            draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )

            local toScreenX, toScreenY = self2:LocalToScreen( 0, 0 )
            if( x != toScreenX or y != toScreenY ) then
                x, y = toScreenX, toScreenY
            end
            
            if( (itemModel or slotBack):IsDown() ) then
                changeAlpha = math.Clamp( changeAlpha-10, 0, 95 )
            elseif( (itemModel or slotBack):IsHovered() ) then
                changeAlpha = math.Clamp( changeAlpha+10, 0, 95 )
            else
                changeAlpha = math.Clamp( changeAlpha-10, 0, 95 )
            end

            surface.SetAlphaMultiplier( changeAlpha/255 )
            draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
            surface.SetAlphaMultiplier( 1 )

            if( rewardIcon ) then
                surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
                surface.SetMaterial( rewardIcon )
                local iconSize = w*0.5
                surface.DrawTexturedRect( (w-iconSize)/2, (h/2)-(iconSize/2), iconSize, iconSize )
            end

            draw.SimpleText( (v or {}).Name or "", "BRICKS_SERVER_Font20", w/2, h-5, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
            
            if( v.Chance ) then
                draw.SimpleText( v.Chance .. "%", "BRICKS_SERVER_Font17", w/2, 5, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, 0 )
            end
        end

        if( v and v.Model ) then
            itemModel = vgui.Create( "DModelPanel" , slotBack )
            itemModel:Dock( FILL )
            itemModel:SetModel( v.Model )
            if( IsValid( itemModel.Entity ) ) then
                function itemModel:LayoutEntity(ent) return end
                local mn, mx = itemModel.Entity:GetRenderBounds()
                local size = 0
                size = math.max( size, math.abs(mn.x) + math.abs(mx.x) )
                size = math.max( size, math.abs(mn.y) + math.abs(mx.y) )
                size = math.max( size, math.abs(mn.z) + math.abs(mx.z) )

                itemModel:SetFOV( 50 )
                itemModel:SetCamPos( Vector( size, size, size ) )
                itemModel:SetLookAt( (mn + mx) * 0.5 )
            end

            if( v.ModelColor ) then
                itemModel:SetColor( v.ModelColor )
            end
        end
    end

    if( BossKey and BRICKS_SERVER.CONFIG.BOSS.NPCs[BossKey] ) then
        local BossTable = BRICKS_SERVER.CONFIG.BOSS.NPCs[BossKey]

        local buttonBack = self.rewardsGrid:Add( "DButton" )
        buttonBack:SetSize( gridWide, 40 )
        buttonBack:SetText( "" )
        local changeAlpha = 0
        buttonBack.Paint = function( self2, w, h )
            draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )

            if( self2:IsDown() ) then
                changeAlpha = math.Clamp( changeAlpha-10, 0, 95 )
            elseif( self2:IsHovered() ) then
                changeAlpha = math.Clamp( changeAlpha+10, 0, 95 )
            else
                changeAlpha = math.Clamp( changeAlpha-10, 0, 95 )
            end

            surface.SetAlphaMultiplier( changeAlpha/255 )
            draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
            surface.SetAlphaMultiplier( 1 )

            draw.SimpleText( "View all possible rewards", "BRICKS_SERVER_Font20", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end
        buttonBack.DoClick = function()
            self:SetVisible( false )
            
            self.allRewardsPanel = vgui.Create( "bricks_server_boss_rewards" )
            self.allRewardsPanel:SetRewards( (BossTable.Loot or {}), 0, true )
            self.allRewardsPanel.oldPanel = self
        end
    end
end

local rounded = 5
function PANEL:Paint( w, h )
    draw.RoundedBox( rounded, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
    draw.RoundedBoxEx( rounded, 0, 0, w, self.headerHeight, BRICKS_SERVER.Func.GetTheme( 0 ), true, true, false, false )

    if( not self.viewAll ) then
        draw.SimpleText( "REWARDS", "BRICKS_SERVER_Font30", 10, (self.headerHeight or 40)/2-2, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_CENTER )
    else
        draw.SimpleText( "ALL REWARDS", "BRICKS_SERVER_Font30", 10, (self.headerHeight or 40)/2-2, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_CENTER )
    end
end

vgui.Register( "bricks_server_boss_rewards", PANEL, "DFrame" )