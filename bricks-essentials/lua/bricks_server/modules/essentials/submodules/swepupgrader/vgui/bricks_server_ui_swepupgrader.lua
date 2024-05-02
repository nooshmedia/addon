local PANEL = {}

function PANEL:Init()

end

function PANEL:FillPanel( panelSize )
    self:Clear()

    self.spacing = 5
    local gridWide = panelSize-20

    self.slotsWide = 4
    self.slotWide = (gridWide-((self.slotsWide-1)*self.spacing))/self.slotsWide
    self.slotTall = self.slotWide*1.5

    self.weaponGrid = vgui.Create( "DIconLayout", self )
    self.weaponGrid:Dock( TOP )
    self.weaponGrid:DockMargin( 10, 10, 10, 10 )
    self.weaponGrid:SetTall( self.slotTall )
    self.weaponGrid:SetSpaceY( self.spacing )
    self.weaponGrid:SetSpaceX( self.spacing )

    for k, v in pairs( LocalPlayer():GetWeapons() ) do
        if( BRICKS_SERVER.CONFIG.SWEPUPGRADES.Blacklist[v:GetClass()] ) then continue end

        self:CreateWeaponCard( v )
    end
end

function PANEL:CreateWeaponCard( weaponEnt )
    self.weaponGrid.slots = (self.weaponGrid.slots or 0)+1
    local slots = self.weaponGrid.slots
    local slotsTall = math.ceil( slots/self.slotsWide )
    self.weaponGrid:SetTall( (slotsTall*self.slotTall)+((slotsTall-1)*self.spacing) )

    local class = weaponEnt:GetClass()
    local itemInfo = BRICKS_SERVER.Func.GetInvTypeCFG( "spawned_weapon" ).GetInfo( { "spawned_weapon", "", class } )

    local weaponCard = vgui.Create( "DPanel", self.weaponGrid )
    weaponCard:SetSize( self.slotWide, self.slotTall )
    local circleRadius = weaponCard:GetWide()/3
    local maxUpgrades = BRICKS_SERVER.CONFIG.SWEPUPGRADES.BaseUpgradeAmounts or 5
    if( (BRICKS_SERVER.CONFIG.SWEPUPGRADES.UpgradeAmounts or {})[class] ) then
        maxUpgrades = BRICKS_SERVER.CONFIG.SWEPUPGRADES.UpgradeAmounts[class]
    end
    local currentUpgrades = weaponEnt:BRS_GetVariableValue( "BRS_Upgrades" ) or 0
    local price = BRICKS_SERVER.CONFIG.SWEPUPGRADES.BasePrice
    for i = 1, currentUpgrades do
        price = price*BRICKS_SERVER.CONFIG.SWEPUPGRADES.PriceIncrease
    end
    weaponCard.Paint = function( self2, w, h )
        draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )

        draw.SimpleText( itemInfo[1] or "ERROR", "BRICKS_SERVER_Font33", w/2, 15, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, 0 )

        BRICKS_SERVER.Func.DrawArc( w/2, h/2.2, circleRadius, 2, 0, 360, BRICKS_SERVER.Func.GetTheme( 3 ) )

        local degree = 0
        if( math.Clamp( (currentUpgrades/maxUpgrades), 0, 1 )*360 < 360 ) then
            degree = math.Clamp( (currentUpgrades/maxUpgrades), 0, 1 )*360
        else
            degree = 365
        end

        BRICKS_SERVER.Func.DrawArc( w/2, h/2.2, circleRadius, 2, -90, degree-90, BRICKS_SERVER.Func.GetTheme( 4 ) )

        draw.SimpleText( "Tier " .. currentUpgrades .. "/" .. maxUpgrades, "BRICKS_SERVER_Font17", w/2, (h/2.2)+circleRadius-20, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )

        if( currentUpgrades < maxUpgrades ) then
            draw.SimpleText( DarkRP.formatMoney( math.ceil( price or 0 ) ), "BRICKS_SERVER_Font24", w/2, (h/2.2)+circleRadius-35, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
        else
            draw.SimpleText( "MAX", "BRICKS_SERVER_Font24", w/2, (h/2.2)+circleRadius-35, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
        end
    end

    local itemInfoNoticeBack = vgui.Create( "DPanel", weaponCard )
    itemInfoNoticeBack:SetSize( 0, 35 )
    itemInfoNoticeBack:SetPos( (weaponCard:GetWide()/2)-(itemInfoNoticeBack:GetWide()/2), 24+28 )
    itemInfoNoticeBack.Paint = function( self2, w, h ) end

    local itemNotices = {}
    if( itemInfo[3] ) then
        local rarityInfo = BRICKS_SERVER.Func.GetRarityInfo( itemInfo[3] ) or {}
        table.insert( itemNotices, { (rarityInfo[1] or ""), function() return BRICKS_SERVER.Func.GetRarityColor( rarityInfo ) end } )
    end

    for k, v in pairs( itemNotices ) do
        surface.SetFont( "BRICKS_SERVER_Font20" )
        local textX, textY = surface.GetTextSize( v[1] )
        local boxW, boxH = textX+15, textY+5

        local itemInfoNotice = vgui.Create( "DPanel", itemInfoNoticeBack )
        itemInfoNotice:Dock( LEFT )
        itemInfoNotice:DockMargin( 0, 0, 5, 0 )
        itemInfoNotice:SetWide( boxW )
        itemInfoNotice.Paint = function( self2, w, h ) 
            local rColor = (v[2] and ((isfunction( v[2] ) and v[2]()) or v[2])) or BRICKS_SERVER.Func.GetTheme( 5 )
            local backColor = Color( rColor.r, rColor.g, rColor.b, 50 )
            local textColor = Color( rColor.r, rColor.g, rColor.b, 255 )

            draw.RoundedBox( 5, 0, 0, w, h, backColor )
            draw.SimpleText( v[1], "BRICKS_SERVER_Font20", w/2, (h/2)-1, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end

        if( itemInfoNoticeBack:GetWide() <= 5 ) then
            itemInfoNoticeBack:SetSize( itemInfoNoticeBack:GetWide()+boxW, boxH )
        else
            itemInfoNoticeBack:SetSize( itemInfoNoticeBack:GetWide()+5+boxW, boxH )
        end
        itemInfoNoticeBack:SetPos( (weaponCard:GetWide()/2)-(itemInfoNoticeBack:GetWide()/2), 24+28 )
    end

    local weaponTable = weapons.Get( class )

    local stats = {}
    for k, v in pairs( BRICKS_SERVER.DEVCONFIG.SWEPUpgradeTypes ) do
        if( not weaponTable or not weaponTable.Primary[k] ) then continue end
        table.insert( stats, { k, weaponTable.Primary[k], weaponEnt:BRS_GetVariableValue( k ) } )
    end

    for k, v in ipairs( stats ) do
        local statBack = vgui.Create( "DPanel", weaponCard )
        statBack:Dock( BOTTOM )
        statBack:DockMargin( 10, 0, 10, 10 )
        statBack:SetTall( 40 )
        local percentIncrease = ((v[3] or v[2])/v[2])-0.5
        local percentIncreaseActual = ((v[3] or v[2])/v[2])
        local percentIncreaseTxt = percentIncreaseActual-1
        if( percentIncreaseActual < 1 ) then
            percentIncreaseTxt = 1-percentIncreaseActual
        end
        statBack.Paint = function( self2, w, h )
            local progressW = math.Clamp( percentIncrease*w, 0, w )

            draw.RoundedBox( 5, 0, h-10, w, 10, BRICKS_SERVER.Func.GetTheme( 3 ) )
    
            draw.SimpleText( v[1], "BRICKS_SERVER_Font25", 0, 0, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )

            local progressCol = BRICKS_SERVER.Func.GetTheme( 5 )
            if( percentIncreaseActual != 1 ) then
                progressCol = (percentIncreaseActual >= 1 and BRICKS_SERVER.DEVCONFIG.BaseThemes.Green) or BRICKS_SERVER.DEVCONFIG.BaseThemes.Red
            end

            draw.RoundedBox( 5, 0, h-10, progressW, 10, progressCol )
            draw.SimpleText( (((percentIncreaseActual > 1 and "+") or (percentIncreaseActual < 1 and "-")) or "") .. math.Round( percentIncreaseTxt*100, 2 ) .. "%", "BRICKS_SERVER_Font25", w, 0, progressCol, TEXT_ALIGN_RIGHT, 0 )
        end
    end

    local weaponIcon = vgui.Create( "DModelPanel", weaponCard )
    weaponIcon:Dock( FILL )
    weaponIcon:DockMargin( 0, 100, 0, 0 )
    weaponIcon:SetModel( BRICKS_SERVER.Func.GetWeaponModel( class ) or "error.mdl" )
    if( IsValid( weaponIcon.Entity ) ) then
        function weaponIcon:LayoutEntity( Entity ) return end
        local mn, mx = weaponIcon.Entity:GetRenderBounds()
        local size = 0
        size = math.max( size, math.abs(mn.x) + math.abs(mx.x) )
        size = math.max( size, math.abs(mn.y) + math.abs(mx.y) )
        size = math.max( size, math.abs(mn.z) + math.abs(mx.z) )

        weaponIcon:SetFOV( 70 )
        weaponIcon:SetCamPos( Vector( size, size, size ) )
        weaponIcon:SetLookAt( (mn + mx) * 0.5 )
    end

    local weaponIconCover = vgui.Create( "DPanel", weaponIcon )
    weaponIconCover:Dock( FILL )
    weaponIconCover.Paint = function() end

    local weaponButton = vgui.Create( "DButton", weaponIconCover )
    weaponButton:Dock( FILL )
    local sideMargin = (weaponCard:GetWide()-(2*circleRadius))/2
    weaponButton:DockMargin( sideMargin, 0, sideMargin, 0 )
    weaponButton:SetText( "" )
    local upgradeMat = Material( "materials/bricks_server/upgrade.png" )
    local changeAlpha = 0
    weaponButton.Paint = function( self2, w, h )
        if( currentUpgrades >= maxUpgrades ) then return end

        if( self2:IsDown() ) then
            changeAlpha = math.Clamp( changeAlpha+15, 0, 75 )
        elseif( self2:IsHovered() ) then
            changeAlpha = math.Clamp( changeAlpha+15, 0, 255 )
        else
            changeAlpha = math.Clamp( changeAlpha-15, 0, 255 )
        end

        surface.SetAlphaMultiplier( (changeAlpha*0.5)/255 )
        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 2 ) )
        draw.NoTexture()
        BRICKS_SERVER.Func.DrawCircle( w/2, (weaponCard:GetTall()/2.2)-100, circleRadius-5, 45 )
        surface.SetAlphaMultiplier( 1 )

        surface.SetDrawColor( 255, 255, 255, changeAlpha )
        surface.SetMaterial( upgradeMat )
        local size = 128
        surface.DrawTexturedRect( (w/2)-(size/2), (weaponCard:GetTall()/2.2)-(size/2)-100, size, size )
    end
    weaponButton.DoClick = function()
        local currentUpgrades = weaponEnt:BRS_GetVariableValue( "BRS_Upgrades" ) or 0
        if( currentUpgrades < maxUpgrades ) then
            net.Start( "BRS.Net.UpgradeSWEP" )
                net.WriteString( class )
            net.SendToServer()
        end
    end
end

function PANEL:Paint( w, h )
    if( not self.weaponGrid or not self.weaponGrid.slots or self.weaponGrid.slots <= 0 ) then
        draw.SimpleText( "You have no upgradeable weapons!", "BRICKS_SERVER_Font25", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end
end

vgui.Register( "bricks_server_ui_swepupgrader", PANEL, "bricks_server_scrollpanel" )