local PANEL = {}

function PANEL:Init()
    self:SetSize( ScrW(), ScrH() )
    self:Center()
    self:MakePopup()
    self:SetTitle( "" )
    self:SetDraggable( false )
    self:ShowCloseButton( false )

    self.mainPanel = vgui.Create( "DPanel", self )
    self.mainPanel:SetSize( ScrW()*0.5, ScrH()*0.5 )
    self.mainPanel:Center()
    self.mainPanel.headerHeight = 40
    self.mainPanel:DockPadding( 0, self.mainPanel.headerHeight, 0, 0 )
    self.mainPanel.Paint = function( self2, w, h )
        draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
        draw.RoundedBoxEx( 5, 0, 0, w, self.mainPanel.headerHeight, BRICKS_SERVER.Func.GetTheme( 0 ), true, true, false, false )
    
        local requestedPly = player.GetBySteamID64( self.requestedID64 or "" )
        if( requestedPly and IsValid( requestedPly ) ) then 
            draw.SimpleText( "Inventory View - " .. requestedPly:Nick(), "BRICKS_SERVER_Font30", 10, (self.mainPanel.headerHeight or 40)/2-2, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_CENTER )
        else
            draw.SimpleText( "Inventory View", "BRICKS_SERVER_Font30", 10, (self.mainPanel.headerHeight or 40)/2-2, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_CENTER )
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
        self:Remove()
    end

    self.contentsPanel = vgui.Create( "DPanel", self.mainPanel )
    self.contentsPanel:Dock( FILL )
    self.contentsPanel.Paint = function( self, w, h ) end 

    local loadingPanel = vgui.Create( "DPanel", self.contentsPanel )
    loadingPanel:Dock( FILL )
    local loadingIcon = Material( "materials/bricks_server/loading.png" )
    loadingPanel.Paint = function( self, w, h ) 
        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.SetMaterial( loadingIcon )
        local size = 32
        surface.DrawTexturedRectRotated( w/2, h/2, size, size, -(CurTime() % 360 * 250) )

        draw.SimpleText( "Loading", "BRICKS_SERVER_Font20", w/2, h/2+(size/2)+5, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, 0 )
    end 
end

function PANEL:RefreshInventory( requestedID64, inventoryTable, bankTable, printersTable, boostersTable )
    self.requestedID64 = requestedID64

    self.contentsPanel:Clear()

    local requestedPly = player.GetBySteamID64( requestedID64 or "" )
    if( not requestedPly or not IsValid( requestedPly ) ) then return end

    inventoryTable = inventoryTable or {}
    bankTable = bankTable or {}
    printersTable = printersTable or {}
    boostersTable = boostersTable or {}

    local inventorySheet = vgui.Create( "bricks_server_colsheet_top", self.contentsPanel )
    inventorySheet:Dock( FILL )
    inventorySheet.pageClickFunc = function( page )
        self.page = page
    end

    local inventoryScroll = vgui.Create( "bricks_server_scrollpanel", inventorySheet )
    inventoryScroll:Dock( FILL )
    inventoryScroll:DockMargin( 10, 10, 10, 10 )
    inventoryScroll.Paint = function( self, w, h ) end 
    inventorySheet:AddSheet( "Main", inventoryScroll, ((self.page or "") == "Main") )

    local spacing = 5
    local inventoryGrid = vgui.Create( "DIconLayout", inventoryScroll )
    inventoryGrid:Dock( FILL )
    inventoryGrid:SetSpaceY( spacing )
    inventoryGrid:SetSpaceX( spacing )

    local gridWide = self.mainPanel:GetWide()-20
    local slotSize = 125
    local slotsWide = math.floor( gridWide/slotSize )
    local actualSlotSize = (gridWide-((slotsWide-1)*spacing))/slotsWide

    if( not inventoryTable ) then return end

    for k, v in pairs( inventoryTable ) do
        local slotBack = inventoryGrid:Add( "DPanel" )
        slotBack:SetSize( actualSlotSize, actualSlotSize )
        local x, y, w, h = 0, 0, actualSlotSize, actualSlotSize
        local itemModel
        local changeAlpha = 0
        local itemInfo = BRICKS_SERVER.Func.GetEntTypeField( (((v or {})[2] or {})[1] or ""), "GetInfo" )( v[2] )
        
        local tooltipInfo = {}
        tooltipInfo[1] = { itemInfo[1], false, "BRICKS_SERVER_Font23B" }
        tooltipInfo[2] = itemInfo[2]
        if( itemInfo[3] ) then
            local rarityInfo = BRICKS_SERVER.Func.GetRarityInfo( itemInfo[3] )
            tooltipInfo[2] = { itemInfo[3], function() return BRICKS_SERVER.Func.GetRarityColor( rarityInfo ) end, "BRICKS_SERVER_Font17" }
            tooltipInfo[3] = itemInfo[2]
        end
        slotBack.Paint = function( self2, w, h )
            draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )

            local toScreenX, toScreenY = self2:LocalToScreen( 0, 0 )
            if( x != toScreenX or y != toScreenY ) then
                x, y = toScreenX, toScreenY

                itemModel:SetBRSToolTip( x, y, w, h, tooltipInfo )
            end
            
            if( IsValid( itemModel ) ) then
                if( itemModel:IsDown() ) then
                    changeAlpha = math.Clamp( changeAlpha-10, 0, 95 )
                elseif( itemModel:IsHovered() ) then
                    changeAlpha = math.Clamp( changeAlpha+10, 0, 95 )
                else
                    changeAlpha = math.Clamp( changeAlpha-10, 0, 95 )
                end
            end

            surface.SetAlphaMultiplier( changeAlpha/255 )
            draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
            surface.SetAlphaMultiplier( 1 )

            draw.SimpleText( (v[1] or 1), "BRICKS_SERVER_Font20", w-10, h-5, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM )
        end

        if( v and v[2] and v[2][2] ) then
            itemModel = vgui.Create( "DModelPanel" , slotBack )
            itemModel:Dock( FILL )
            itemModel:SetModel( v[2][2] )
            function itemModel:LayoutEntity( Entity ) return end

            BRICKS_SERVER.Func.GetEntTypeField( ((v[2] or {})[1] or ""), "ModelDisplay" )( itemModel, v[2] )

            if( v[2] and v[2][1] == "bricks_server_resource" ) then
                if( BRICKS_SERVER.CONFIG.CRAFTING.Resources[v[2][3]] and BRICKS_SERVER.CONFIG.CRAFTING.Resources[v[2][3]][2] ) then
                    itemModel:SetColor( BRICKS_SERVER.CONFIG.CRAFTING.Resources[v[2][3]][2] )
                end
            end
        end

        local actions = {
            [1] = { "Remove", function() 
                net.Start( "BRS.Net.InventoryAdminRemove" )
                    net.WriteString( requestedID64 )
                    net.WriteUInt( k, 10 )
                net.SendToServer()
            end }
        }

        if( itemModel ) then
            itemModel.DoClick = function()
                itemModel.Menu = vgui.Create( "bricks_server_dmenu" )
                for k, v in pairs( actions ) do
                    itemModel.Menu:AddOption( v[1], v[2] )
                end
                itemModel.Menu:Open()
                itemModel.Menu:SetPos( x+w+5, y+(h/2)-(itemModel.Menu:GetTall()/2) )
            end
        end
    end

    local bankScroll = vgui.Create( "bricks_server_scrollpanel", inventorySheet )
    bankScroll:Dock( FILL )
    bankScroll:DockMargin( 10, 10, 10, 10 )
    bankScroll.Paint = function( self, w, h ) end 
    inventorySheet:AddSheet( "Bank", bankScroll, ((self.page or "") == "Bank") )

    local spacing = 5
    local bankGrid = vgui.Create( "DIconLayout", bankScroll )
    bankGrid:Dock( FILL )
    bankGrid:SetSpaceY( spacing )
    bankGrid:SetSpaceX( spacing )

    for k, v in pairs( bankTable ) do
        local slotBack = bankGrid:Add( "DPanel" )
        slotBack:SetSize( actualSlotSize, actualSlotSize )
        local x, y, w, h = 0, 0, actualSlotSize, actualSlotSize
        local itemModel
        local changeAlpha = 0
        local itemInfo = BRICKS_SERVER.Func.GetEntTypeField( (((v or {})[2] or {})[1] or ""), "GetInfo" )( v[2] )
        
        local tooltipInfo = {}
        tooltipInfo[1] = { itemInfo[1], false, "BRICKS_SERVER_Font23B" }
        tooltipInfo[2] = itemInfo[2]
        if( itemInfo[3] ) then
            local rarityInfo = BRICKS_SERVER.Func.GetRarityInfo( itemInfo[3] )
            tooltipInfo[2] = { itemInfo[3], function() return BRICKS_SERVER.Func.GetRarityColor( rarityInfo ) end, "BRICKS_SERVER_Font17" }
            tooltipInfo[3] = itemInfo[2]
        end
        slotBack.Paint = function( self2, w, h )
            draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )

            local toScreenX, toScreenY = self2:LocalToScreen( 0, 0 )
            if( x != toScreenX or y != toScreenY ) then
                x, y = toScreenX, toScreenY

                itemModel:SetBRSToolTip( x, y, w, h, tooltipInfo )
            end
            
            if( IsValid( itemModel ) ) then
                if( itemModel:IsDown() ) then
                    changeAlpha = math.Clamp( changeAlpha-10, 0, 95 )
                elseif( itemModel:IsHovered() ) then
                    changeAlpha = math.Clamp( changeAlpha+10, 0, 95 )
                else
                    changeAlpha = math.Clamp( changeAlpha-10, 0, 95 )
                end
            end

            surface.SetAlphaMultiplier( changeAlpha/255 )
            draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
            surface.SetAlphaMultiplier( 1 )

            draw.SimpleText( (v[1] or 1), "BRICKS_SERVER_Font20", w-10, h-5, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM )
        end

        if( v and v[2] and v[2][2] ) then
            itemModel = vgui.Create( "DModelPanel" , slotBack )
            itemModel:Dock( FILL )
            itemModel:SetModel( v[2][2] )
            function itemModel:LayoutEntity( Entity ) return end

            BRICKS_SERVER.Func.GetEntTypeField( ((v[2] or {})[1] or ""), "ModelDisplay" )( itemModel, v[2] )

            if( v[2] and v[2][1] == "bricks_server_resource" ) then
                if( BRICKS_SERVER.CONFIG.CRAFTING.Resources[v[2][3]] and BRICKS_SERVER.CONFIG.CRAFTING.Resources[v[2][3]][2] ) then
                    itemModel:SetColor( BRICKS_SERVER.CONFIG.CRAFTING.Resources[v[2][3]][2] )
                end
            end
        end

        local actions = {
            [1] = { "Remove", function() 
                net.Start( "BRS.Net.BankAdminRemove" )
                    net.WriteString( requestedID64 )
                    net.WriteUInt( k, 10 )
                net.SendToServer()
            end }
        }

        if( itemModel ) then
            itemModel.DoClick = function()
                itemModel.Menu = vgui.Create( "bricks_server_dmenu" )
                for k, v in pairs( actions ) do
                    itemModel.Menu:AddOption( v[1], v[2] )
                end
                itemModel.Menu:Open()
                itemModel.Menu:SetPos( x+w+5, y+(h/2)-(itemModel.Menu:GetTall()/2) )
            end
        end
    end

    if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "printers" ) ) then
        local printersScroll = vgui.Create( "bricks_server_scrollpanel", inventorySheet )
        printersScroll:Dock( FILL )
        printersScroll:DockMargin( 10, 10, 10, 10 )
        printersScroll.Paint = function( self, w, h ) end 
        inventorySheet:AddSheet( "Printers", printersScroll, ((self.page or "") == "Printers") )

        for k, v in ipairs( BRICKS_SERVER.CONFIG.PRINTERS.PrinterSlots ) do
            local unlocked = false
            local printerTable = {}
            if( printersTable and printersTable[k] and printersTable[k][1] == true ) then
                unlocked = true
                printerTable = BRICKS_SERVER.CONFIG.PRINTERS.Tiers[(printersTable[k][2] or 1)]
            end

            local printerBack = vgui.Create( "DPanel", printersScroll )
            printerBack:Dock( TOP )
            printerBack:SetTall( 100 )
            printerBack:DockMargin( 0, 0, 0, 5 )
            printerBack:DockPadding( 0, 0, 25, 5 )
            local printerBackW, printerBackH = 0, 0
            printerBack.Paint = function( self2, w, h )
                if( printerBackW != w or printerBackH != h ) then
                    printerBackW, printerBackH = w, h
                end

                draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
                draw.RoundedBox( 5, 5, 5, h-10, h-10, BRICKS_SERVER.Func.GetTheme( 2 ) )

                if( not v.Group ) then
                    draw.SimpleText( "Slot " .. k, "BRICKS_SERVER_Font33", h+15, 5, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
                else
                    draw.SimpleText( "Slot " .. k .. " - " .. v.Group, "BRICKS_SERVER_Font33", h+15, 5, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
                end

                if( unlocked ) then
                    draw.SimpleText( "Tier: " .. printerTable.Name, "BRICKS_SERVER_Font20", h+15, 32, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
                    draw.SimpleText( "Level: " .. (printersTable[k][3] or 1), "BRICKS_SERVER_Font20", h+15, 47, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
                else
                    draw.SimpleText( "Tier: None", "BRICKS_SERVER_Font20", h+15, 32, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
                    draw.SimpleText( "Level: 1", "BRICKS_SERVER_Font20", h+15, 47, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
                end
            end

            local printerModel = vgui.Create( "DModelPanel" , printerBack )
            printerModel:SetPos( 5, 5 )
            printerModel:SetSize( printerBack:GetTall()-10, printerBack:GetTall()-10 )
            printerModel:SetModel( "models/2rek/brickwall/bwall_printer.mdl" )
            if( unlocked ) then
                printerModel:SetColor( printerTable.ModelColor or Color( 255, 255, 255 ) )
            end

            if( IsValid( printerModel.Entity ) ) then
                function printerModel:LayoutEntity( Entity ) return end

                local mn, mx = printerModel.Entity:GetRenderBounds()
                local size = 0
                size = math.max( size, math.abs(mn.x) + math.abs(mx.x) )
                size = math.max( size, math.abs(mn.y) + math.abs(mx.y) )
                size = math.max( size, math.abs(mn.z) + math.abs(mx.z) )

                printerModel:SetFOV( 60 )
                printerModel:SetCamPos( Vector( size, size, size ) )
                printerModel:SetLookAt( (mn + mx) * 0.5 )
            end

            local printerActions = {}

            if( unlocked ) then
                printerActions[1] = { "Remove", function( ply, slotID )
                    net.Start( "BRS.Net.PrinterAdminRemove" )
                        net.WriteString( requestedID64 )
                        net.WriteUInt( slotID, 8 )
                    net.SendToServer()
                end, BRICKS_SERVER.DEVCONFIG.BaseThemes.Red, BRICKS_SERVER.DEVCONFIG.BaseThemes.DarkRed }

                printerActions[2] = { "Set Level", function( ply, slotID )
                    BRICKS_SERVER.Func.StringRequest( "Admin", "What level would you like to set this printer to?", (printersTable[k][3] or 1), function( text ) 
                        if( isnumber( tonumber( text ) ) ) then
                            net.Start( "BRS.Net.PrinterAdminSetLevel" )
                                net.WriteString( requestedID64 )
                                net.WriteUInt( slotID, 8 )
                                net.WriteUInt( tonumber( text ), 32 )
                            net.SendToServer()
                        else
                            notification.AddLegacy( "Invalid number.", 1, 3 )
                        end
                    end, function() end, "OK", "Cancel", true )
                end }

                if( (printersTable[k][2] or 1) < #BRICKS_SERVER.CONFIG.PRINTERS.Tiers ) then
                    printerActions[3] = { "Upgrade", function( ply, slotID )
                        net.Start( "BRS.Net.PrinterAdminUpgrade" )
                            net.WriteString( requestedID64 )
                            net.WriteUInt( slotID, 8 )
                        net.SendToServer()
                    end }
                end

                for key, val in ipairs( printerActions ) do
                    local printerAction = vgui.Create( "DButton", printerBack )
                    printerAction:Dock( RIGHT )
                    printerAction:SetText( "" )
                    printerAction:DockMargin( 5, 25, 0, 25 )
                    surface.SetFont( "BRICKS_SERVER_Font25" )
                    local textX, textY = surface.GetTextSize( (val[1] or "ERROR") )
                    printerAction:SetWide( math.max( (ScrW()/2560)*150, textX+20 ) )
                    local changeAlpha = 0
                    printerAction.Paint = function( self2, w, h )
                        if( self2:IsDown() ) then
                            changeAlpha = math.Clamp( changeAlpha+10, 0, 125 )
                        elseif( self2:IsHovered() ) then
                            changeAlpha = math.Clamp( changeAlpha+10, 0, 75 )
                        else
                            changeAlpha = math.Clamp( changeAlpha-10, 0, 75 )
                        end
                        
                        if( val[3] ) then
                            draw.RoundedBox( 5, 0, 0, w, h, val[3] )
                        else
                            draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
                        end
                
                        surface.SetAlphaMultiplier( changeAlpha/255 )
                            if( val[4] ) then
                                draw.RoundedBox( 5, 0, 0, w, h, val[4] )
                            else
                                draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
                            end
                        surface.SetAlphaMultiplier( 1 )
                    
                        draw.SimpleText( (val[1] or "ERROR"), "BRICKS_SERVER_Font25", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                    end
                    printerAction.DoClick = function()
                        val[2]( v, k )
                    end
                end
            else
                local printerAction = vgui.Create( "DButton", printerBack )
                printerAction:Dock( RIGHT )
                printerAction:SetText( "" )
                printerAction:DockMargin( 5, 25, 0, 25 )
                local tall = 50
                surface.SetFont( "BRICKS_SERVER_Font25" )
                local textX, textY = surface.GetTextSize( "Unlock" )
                surface.SetFont( "BRICKS_SERVER_Font20" )
                local text2X, text2Y = surface.GetTextSize( DarkRP.formatMoney( v.Price or 0 ) )
                local textTall = textY+text2Y-5
                printerAction:SetWide( math.max( (ScrW()/2560)*150, textX+20 ) )
                local changeAlpha = 0
                printerAction.Paint = function( self2, w, h )
                    if( self2:IsDown() ) then
                        changeAlpha = math.Clamp( changeAlpha+10, 0, 125 )
                    elseif( self2:IsHovered() ) then
                        changeAlpha = math.Clamp( changeAlpha+10, 0, 75 )
                    else
                        changeAlpha = math.Clamp( changeAlpha-10, 0, 75 )
                    end
                    
                    draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
            
                    surface.SetAlphaMultiplier( changeAlpha/255 )
                    draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
                    surface.SetAlphaMultiplier( 1 )

                    draw.SimpleText( "Unlock", "BRICKS_SERVER_Font25", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                end
                printerAction.DoClick = function()
                    if( printersTable and printersTable[k] and printersTable[k][1] == true ) then
                        notification.AddLegacy( "This slot is already unlocked!", 1, 5 )
                        return
                    end
        
                    net.Start( "BRS.Net.AdminUnlockPrinter" )
                        net.WriteString( requestedID64 )
                        net.WriteUInt( k, 8 )
                    net.SendToServer()
                end
            end

            if( printersTable[k] and printersTable[k][5] and printersTable[k][5] > os.time() ) then
                local printerCover = vgui.Create( "DPanel", printerBack )
                printerCover:SetPos( 0, 0 )
                printerCover:SetSize( 50, printerBack:GetTall() )
                printerCover.Paint = function( self2, w, h )
                    if( w != printerBackW ) then
                        self2:SetWide( printerBackW )
                    end

                    BRICKS_SERVER.Func.DrawBlur( self2, 2, 2 )

                    surface.SetAlphaMultiplier( 0.8 )
                    draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 0 ) )
                    surface.SetAlphaMultiplier( 1 )

                    if( printersTable[k] and printersTable[k][1] == true and printersTable[k][5] and printersTable[k][5] > os.time() ) then
                        draw.SimpleText( "DESTROYED - On cooldown for " .. BRICKS_SERVER.Func.FormatTime( math.max( 0, math.Round( (printersTable[k][5]-os.time()) ) ) ), "BRICKS_SERVER_HUDFontS", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                        return
                    end

                    printerCover:Remove()
                end
            end
        end
    end

    if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "boosters" ) ) then
        local boostersScroll = vgui.Create( "bricks_server_scrollpanel", inventorySheet )
        boostersScroll:Dock( FILL )
        boostersScroll:DockMargin( 10, 10, 10, 10 )
        boostersScroll.Paint = function( self, w, h ) end 
        inventorySheet:AddSheet( "Boosters", boostersScroll, ((self.page or "") == "Boosters") )

        if( table.Count( boostersTable ) > 0 ) then
            for k, v in pairs( boostersTable ) do
                local boosterTable = BRICKS_SERVER.CONFIG.BOOSTERS[v[1]]
                if( not boosterTable ) then continue end

                local boosterBack = vgui.Create( "DPanel", boostersScroll )
                boosterBack:Dock( TOP )
                boosterBack:SetTall( 100 )
                boosterBack:DockMargin( 0, 0, 0, 5 )
                boosterBack:DockPadding( 0, 0, 25, 5 )
                local boosterIcon
                BRICKS_SERVER.Func.GetImage( boosterTable.Icon or "", function( mat ) boosterIcon = mat end )
                local boosterBackW = 0
                local timeLeftLerp = boosterTable.Time
                if( v[3] ) then
                    timeLeftLerp = v[3]-os.time()
                end
                boosterBack.Paint = function( self2, w, h )
                    if( boosterBackW != w ) then
                        boosterBackW = w
                    end

                    draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )

                    if( v[3] ) then
                        timeLeftLerp = Lerp( RealFrameTime()*2, timeLeftLerp, v[3]-os.time() )
                        local finalWidth = w*math.Clamp( timeLeftLerp/boosterTable.Time, 0, 1 )
                        if( finalWidth <= w-5 ) then
                            draw.RoundedBoxEx( 5, 0, 0, finalWidth, h, BRICKS_SERVER.Func.GetTheme( 4 ), true, false, true, false )
                        else
                            draw.RoundedBox( 5, 0, 0, finalWidth, h, BRICKS_SERVER.Func.GetTheme( 4 ) )
                        end
                    end

                    draw.RoundedBox( 5, 5, 5, h-10, h-10, BRICKS_SERVER.Func.GetTheme( 2 ) )

                    if( boosterIcon ) then
                        surface.SetDrawColor( 255, 255, 255, 255 )
                        surface.SetMaterial( boosterIcon )
                        local size = 64
                        surface.DrawTexturedRect( (h-size)/2, (h-size)/2, size, size )
                    end

                    draw.SimpleText( boosterTable.Title, "BRICKS_SERVER_Font33", h+15, 5, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
                    
                    if( v[3] ) then
                        draw.SimpleText( "Time left: " .. BRICKS_SERVER.Func.FormatTime( math.max( 0, v[3]-os.time() ) ), "BRICKS_SERVER_Font20", h+15, 32, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
                    else
                        draw.SimpleText( "Duration: " .. BRICKS_SERVER.Func.FormatTime( boosterTable.Time ), "BRICKS_SERVER_Font20", h+15, 32, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
                    end
                end

                local boosterAction = vgui.Create( "DButton", boosterBack )
                boosterAction:Dock( RIGHT )
                boosterAction:SetText( "" )
                boosterAction:DockMargin( 5, 25, 0, 25 )
                surface.SetFont( "BRICKS_SERVER_Font25" )
                local textX, textY = surface.GetTextSize( "Cancel" )
                textX = textX+20
                boosterAction:SetWide( math.max( (ScrW()/2560)*150, textX ) )
                local changeAlpha = 0
                boosterAction.Paint = function( self2, w, h )
                    if( self2:IsDown() ) then
                        changeAlpha = math.Clamp( changeAlpha+10, 0, 125 )
                    elseif( self2:IsHovered() ) then
                        changeAlpha = math.Clamp( changeAlpha+10, 0, 75 )
                    else
                        changeAlpha = math.Clamp( changeAlpha-10, 0, 75 )
                    end
                    
                    draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
            
                    surface.SetAlphaMultiplier( changeAlpha/255 )
                    draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
                    surface.SetAlphaMultiplier( 1 )

                    if( not v[3] ) then
                        draw.SimpleText( "Use", "BRICKS_SERVER_Font25", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                    else
                        draw.SimpleText( "Cancel", "BRICKS_SERVER_Font25", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                    end
                end
                boosterAction.DoClick = function()
                    if( not v[3] ) then
                        net.Start( "BRS.Net.AdminUseBooster" )
                            net.WriteString( requestedID64 )
                            net.WriteUInt( k, 10 )
                        net.SendToServer()
                    else
                        net.Start( "BRS.Net.AdminCancelBooster" )
                            net.WriteString( requestedID64 )
                            net.WriteUInt( k, 10 )
                        net.SendToServer()
                    end
                end

                local sameBoosterActive = false
                for key, val in pairs( boostersTable ) do
                    if( not val[3] or key == k ) then continue end

                    local subBoosterTable = BRICKS_SERVER.CONFIG.BOOSTERS[val[1]]
                    if( not subBoosterTable ) then continue end

                    if( subBoosterTable.Type == boosterTable.Type ) then
                        sameBoosterActive = true
                        break
                    end
                end

                if( sameBoosterActive ) then
                    local boosterCover = vgui.Create( "DPanel", boosterBack )
                    boosterCover:SetPos( 0, 0 )
                    boosterCover:SetSize( 50, boosterBack:GetTall() )
                    local boosterType = (BRICKS_SERVER.DEVCONFIG.BoosterTypes[boosterTable.Type] or {})[1] or "ERROR"
                    boosterCover.Paint = function( self2, w, h )
                        if( w != boosterBackW ) then
                            self2:SetWide( boosterBackW )
                        end

                        BRICKS_SERVER.Func.DrawBlur( self2, 2, 2 )

                        surface.SetAlphaMultiplier( 0.8 )
                        draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 0 ) )
                        surface.SetAlphaMultiplier( 1 )

                        draw.SimpleText( boosterType .. " Booster already active", "BRICKS_SERVER_HUDFontS", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                    end
                end
            end
        else
            local noBoosters = vgui.Create( "DButton", boostersScroll )
            noBoosters:Dock( TOP )
            noBoosters:SetText( "" )
            noBoosters:DockMargin( 0, 0, 0, 5 )
            noBoosters:SetTall( 40 )
            local changeAlpha = 0
            noBoosters.Paint = function( self2, w, h )
                if( self2:IsDown() ) then
                    changeAlpha = math.Clamp( changeAlpha+10, 0, 125 )
                elseif( self2:IsHovered() ) then
                    changeAlpha = math.Clamp( changeAlpha+10, 0, 75 )
                else
                    changeAlpha = math.Clamp( changeAlpha-10, 0, 75 )
                end
                
                draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
        
                surface.SetAlphaMultiplier( changeAlpha/255 )
                draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
                surface.SetAlphaMultiplier( 1 )
        
                draw.SimpleText( "No boosters. Click here to add more!", "BRICKS_SERVER_Font25", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            end
            noBoosters.DoClick = function()
                local options = {}
                for k, v in pairs( (BRICKS_SERVER.CONFIG.BOOSTERS or {}) ) do
                    options[k] = v.Title
                end
                BRICKS_SERVER.Func.ComboRequest( "Admin", "What booster would you like to give them?", 1, options, function( value, data ) 
                    if( BRICKS_SERVER.CONFIG.BOOSTERS[data] ) then
                        RunConsoleCommand( "givebooster", requestedID64, data )
                    else
                        notification.AddLegacy( "Invalid booster.", 1, 3 )
                    end
                end, function() end, "OK", "Cancel" )
            end
        end
    end
end

function PANEL:Paint( w, h )
    BRICKS_SERVER.Func.DrawBlur( self, 4, 4 )
end

vgui.Register( "bricks_server_admin_inventory", PANEL, "DFrame" )