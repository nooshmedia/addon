local PANEL = {}

function PANEL:Init()

end

function PANEL:FillPanel()
    local F4Wide = (ScrW()*0.6)-BRICKS_SERVER.DEVCONFIG.MainNavWidth-20

    local F4ButtonBack = vgui.Create( "DPanel", self )
    F4ButtonBack:Dock( TOP )
    F4ButtonBack:DockMargin( 0, 0, 0, 5 )
    F4ButtonBack:SetTall( 40 )
    F4ButtonBack.Paint = function() end

    local topButtons = {}
    topButtons[1] = { "Insert tab", function()
        BS_ConfigCopyTable.F4 = BS_ConfigCopyTable.F4 or {}
        BS_ConfigCopyTable.F4.Tabs = BS_ConfigCopyTable.F4.Tabs or {}
        table.insert( BS_ConfigCopyTable.F4.Tabs, { "New tab", "more.png", 1 } )
        self.RefreshPanel()
        BRICKS_SERVER.Func.ConfigChange( "F4" )
    end }
    topButtons[2] = { "Insert linebreak", function()
        BS_ConfigCopyTable.F4 = BS_ConfigCopyTable.F4 or {}
        BS_ConfigCopyTable.F4.Tabs = BS_ConfigCopyTable.F4.Tabs or {}
        table.insert( BS_ConfigCopyTable.F4.Tabs, { true } )
        self.RefreshPanel()
        BRICKS_SERVER.Func.ConfigChange( "F4" )
    end }
    topButtons[3] = { "Insert link", function()
        BS_ConfigCopyTable.F4 = BS_ConfigCopyTable.F4 or {}
        BS_ConfigCopyTable.F4.Tabs = BS_ConfigCopyTable.F4.Tabs or {}
        table.insert( BS_ConfigCopyTable.F4.Tabs, { "New link", "more.png", "https://www.gmodstore.com/market/browse" } )
        self.RefreshPanel()
        BRICKS_SERVER.Func.ConfigChange( "F4" )
    end }


    for k, v in pairs( topButtons ) do
        local F4Button = vgui.Create( "DButton", F4ButtonBack )
        F4Button:SetText( "" )
        F4Button:Dock( LEFT )
        if( k > 1 ) then
            F4Button:DockMargin( 5, 0, 0, 0 )
        end
        F4Button:SetWide( (F4Wide-((#topButtons-1)*5))/#topButtons )
        local changeAlpha = 0
        F4Button.Paint = function( self2, w, h )
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
    
            draw.SimpleText( v[1], "BRICKS_SERVER_Font20", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end
        F4Button.DoClick = v[2]
    end

    local F4List = vgui.Create( "bricks_server_scrollpanel", self )
    F4List:Dock( FILL )

    local actions = {
        [1] = { "Edit Name", function( k, v, parentTabKey, parentTabVal ) 
            BRICKS_SERVER.Func.StringRequest( "Admin", "What should the new name be?", v[1] or "", function( text ) 
                if( not parentTabKey ) then
                    BS_ConfigCopyTable.F4.Tabs[k][1] = text
                else
                    BS_ConfigCopyTable.F4.Tabs[parentTabKey][3][k][1] = text
                end
                self.RefreshPanel()
                BRICKS_SERVER.Func.ConfigChange( "F4" )
            end, function() end, "OK", "Cancel" )
        end },
        [2] = { "Edit Icon", function( k, v, parentTabKey, parentTabVal ) 
            BRICKS_SERVER.Func.MaterialRequest( "Admin", "What should the new icon be?", v[2] or "", function( text ) 
                if( parentTabKey ) then return end

                BS_ConfigCopyTable.F4.Tabs[k][2] = text

                self.RefreshPanel()
                BRICKS_SERVER.Func.ConfigChange( "F4" )
            end, function() end, "OK", "Cancel" )
        end },
        [3] = { "Edit Page", function( k, v, parentTabKey, parentTabVal ) 
            local options = {}
            for k, v in pairs( BRICKS_SERVER.DEVCONFIG.F4Tabs ) do
                options[k] = v[1] or "NIL"
            end

            BRICKS_SERVER.Func.ComboRequest( "Admin", "What page should this button display?", (not parentTabKey and (v[3] or "")) or (v[2] or ""), options, function( value, data ) 
                if( BRICKS_SERVER.DEVCONFIG.F4Tabs[data] ) then
                    if( not parentTabKey ) then
                        BS_ConfigCopyTable.F4.Tabs[k][3] = data
                    else
                        BS_ConfigCopyTable.F4.Tabs[parentTabKey][3][k][2] = data
                    end
                    self.RefreshPanel()
                    BRICKS_SERVER.Func.ConfigChange( "F4" )
                else
                    notification.AddLegacy( "Invalid page.", 1, 3 )
                end
            end, function() end, "OK", "Cancel" )
        end },
        [4] = { "Edit Link", function( k, v, parentTabKey, parentTabVal ) 
            BRICKS_SERVER.Func.StringRequest( "Admin", "What link should this button open?", (not parentTabKey and (v[3] or "")) or (v[2] or ""), function( text ) 
                if( not parentTabKey ) then
                    BS_ConfigCopyTable.F4.Tabs[k][3] = text
                else
                    BS_ConfigCopyTable.F4.Tabs[parentTabKey][3][k][2] = text
                end
                self.RefreshPanel()
                BRICKS_SERVER.Func.ConfigChange( "F4" )
            end, function() end, "OK", "Cancel" )
        end }
    }

    local removeMat = Material( "materials/bricks_server/delete.png" )
    local editMat = Material( "materials/bricks_server/edit.png" )
    local upMat = Material( "materials/bricks_server/up.png" )
    local downMat = Material( "materials/bricks_server/down.png" )

    local function CreateF4Tab( k, v, parent, parentTabKey, parentTabVal, indent )
        local title = (v[1] or "NIL")
        if( title == true ) then
            title = "Linebreak"
        end

        local color = (parentTabKey and BRICKS_SERVER.Func.GetTheme( 4 )) or BRICKS_SERVER.Func.GetTheme( 5 )
        if( v[1] == true ) then
            color = BRICKS_SERVER.DEVCONFIG.BaseThemes.Red
        elseif( v[3] and isstring( v[3] ) ) then
            color = BRICKS_SERVER.DEVCONFIG.BaseThemes.Green
        elseif( parentTabKey and v[2] and isstring( v[2] ) ) then
            color = BRICKS_SERVER.DEVCONFIG.BaseThemes.DarkGreen
        end

        local headerPanel = vgui.Create( "DButton", parent )
        headerPanel:Dock( TOP )
        headerPanel:DockMargin( (indent or 0), ((parentTabKey and 2) or 0), (indent or 0), 0 )
        headerPanel:SetTall( 40 )
        headerPanel:SetText( "" )
        headerPanel.Paint = function( self2, w, h ) 
            draw.RoundedBox( 5, 0, 0, w, h, color )

            draw.SimpleText( title, "BRICKS_SERVER_Font20", 15-1, h/2+1, Color( 0, 0, 0 ), 0, TEXT_ALIGN_CENTER )
            draw.SimpleText( title, "BRICKS_SERVER_Font20", 15, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_CENTER )
        end
        if( not parentTabKey and v[3] and not istable( v[3] ) ) then
            headerPanel:Droppable( "f4tab" )
            headerPanel.f4tabKey = k
        end
        headerPanel.AddButton = function( self2, material, func )
            local button = vgui.Create( "DButton", self2 )
            button:Dock( RIGHT )
            button:DockMargin( 2, 2, 2, 2 )
            button:SetWide( 36 )
            button:SetText( "" )
            local changeAlpha = 0
            local x, y = 0, 0
            button.Paint = function( self3, w, h )
                local toScreenX, toScreenY = self3:LocalToScreen( 0, 0 )
                if( x != toScreenX or y != toScreenY ) then
                    x, y = toScreenX, toScreenY
                end
        
                if( self3:IsDown() ) then
                    changeAlpha = math.Clamp( changeAlpha+10, 0, 125 )
                elseif( self3:IsHovered() ) then
                    changeAlpha = math.Clamp( changeAlpha+10, 0, 95 )
                else
                    changeAlpha = math.Clamp( changeAlpha-10, 0, 95 )
                end
        
                surface.SetAlphaMultiplier( changeAlpha/255 )
                draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
                surface.SetAlphaMultiplier( 1 )
        
                surface.SetMaterial( material )
                local size = 24
                surface.SetDrawColor( 0, 0, 0, 255 )
                surface.DrawTexturedRect( (h-size)/2-1, (h-size)/2+1, size, size )
        
                surface.SetDrawColor( 255, 255, 255, 255 )
                surface.DrawTexturedRect( (h-size)/2, (h-size)/2, size, size )
            end
            button.DoClick = function()
                func( x, y, button:GetWide(), button:GetWide() )
            end
        end

        headerPanel:AddButton( removeMat, function( x, y, w, h )
            if( not parentTabKey ) then
                table.remove( BS_ConfigCopyTable.F4.Tabs, k )
            else
                table.remove( BS_ConfigCopyTable.F4.Tabs[parentTabKey][3], k )

                if( #BS_ConfigCopyTable.F4.Tabs[parentTabKey][3] < 1 ) then
                    BS_ConfigCopyTable.F4.Tabs[parentTabKey][3] = 1
                end
            end

            self.RefreshPanel()
            BRICKS_SERVER.Func.ConfigChange( "F4" )
        end )
        if( v[1] != true ) then
            headerPanel:AddButton( editMat, function( x, y, w, h )
                headerPanel.Menu = vgui.Create( "bricks_server_dmenu" )
                for key, val in ipairs( actions ) do
                    if( v[3] and istable( v[3] ) and (key == 3 or key == 4) ) then continue end
                    if( parentTabKey and key == 2 ) then continue end
                    if( (v[3] and isstring( v[3] ) and key == 3) or (parentTabKey and v[2] and isstring( v[2] ) and key == 3) ) then continue end
                    if( (v[3] and isnumber( v[3] ) and key == 4) or (parentTabKey and v[2] and isnumber( v[2] ) and key == 4) ) then continue end

                    headerPanel.Menu:AddOption( val[1], function()
                        val[2]( k, v, parentTabKey, parentTabVal )
                    end )
                end
                headerPanel.Menu:Open()
                headerPanel.Menu:SetPos( x+w+5, y+(h/2)-(headerPanel.Menu:GetTall()/2) )
            end )
        end
        headerPanel:AddButton( downMat, function( x, y, w, h )
            if( not parentTabKey and k+1 <= #(((BS_ConfigCopyTable or BRICKS_SERVER.CONFIG).F4 or {}).Tabs or {}) ) then
                if( BS_ConfigCopyTable.F4.Tabs[k+1] ) then
                    BS_ConfigCopyTable.F4.Tabs[k] = BS_ConfigCopyTable.F4.Tabs[k+1]
                end

                BS_ConfigCopyTable.F4.Tabs[k+1] = v
                self.RefreshPanel()
                BRICKS_SERVER.Func.ConfigChange( "F4" )
            elseif( k+1 <= #(((BS_ConfigCopyTable or BRICKS_SERVER.CONFIG).F4 or {}).Tabs or {})[parentTabKey][3] ) then
                if( BS_ConfigCopyTable.F4.Tabs[parentTabKey][3][k+1] ) then
                    BS_ConfigCopyTable.F4.Tabs[parentTabKey][3][k] = BS_ConfigCopyTable.F4.Tabs[parentTabKey][3][k+1]
                end
            end
        end )
        headerPanel:AddButton( upMat, function( x, y, w, h )
            if( k-1 >= 1 ) then
                if( not parentTabKey ) then
                    if( BS_ConfigCopyTable.F4.Tabs[k-1] ) then
                        BS_ConfigCopyTable.F4.Tabs[k] = BS_ConfigCopyTable.F4.Tabs[k-1]
                    end

                    BS_ConfigCopyTable.F4.Tabs[k-1] = v
                else
                    if( BS_ConfigCopyTable.F4.Tabs[parentTabKey][3][k-1] ) then
                        BS_ConfigCopyTable.F4.Tabs[parentTabKey][3][k] = BS_ConfigCopyTable.F4.Tabs[parentTabKey][3][k-1]
                    end

                    BS_ConfigCopyTable.F4.Tabs[parentTabKey][3][k-1] = v
                end

                self.RefreshPanel()
                BRICKS_SERVER.Func.ConfigChange( "F4" )
            end
        end )
    end

    local F4ListScroll
    local F4CatHover
    function self.RefreshPanel()
        F4ListScroll = F4List.VBar:GetScroll() or 0

        F4List:Clear()

        for k, v in pairs( ((BS_ConfigCopyTable or BRICKS_SERVER.CONFIG).F4 or {}).Tabs or {} ) do
            local categoryBack = vgui.Create( "DPanel", F4List )
            categoryBack:Dock( TOP )
            categoryBack:DockMargin( 0, 0, 0, 2 )
            categoryBack:SetTall( 40 )
            categoryBack.Paint = function( self2, w, h ) end

            if( v[3] and (istable( v[3] ) or isnumber( v[3] )) ) then
                categoryBack.f4tabKey = k
            end

            CreateF4Tab( k, v, categoryBack )

            if( v[3] and istable( v[3] ) ) then
                for key, val in pairs( v[3] ) do
                    CreateF4Tab( key, val, categoryBack, k, v, 5 )
                end

                categoryBack:SetTall( 40+(#v[3]*42) )
            end

            categoryBack:Receiver( "f4tab", function( receiverPnl, dropPnlTable, dropped )
                local dropPanel = dropPnlTable[1]

                if( not dropPanel or not IsValid( dropPanel ) or receiverPnl == dropPanel or not receiverPnl.f4tabKey or receiverPnl.f4tabKey == (dropPanel.f4tabKey or "") or not BS_ConfigCopyTable.F4.Tabs[receiverPnl.f4tabKey] ) then return end
                
                if( not dropped ) then
                    receiverPnl.droppableHovered = true

                    if( IsValid( F4CatHover ) ) then
                        if( (F4CatHover.f4tabKey or "") == (receiverPnl.f4tabKey or "") ) then return end

                        F4CatHover:Remove()
                    end

                    if( not IsValid( F4CatHover ) ) then
                        F4CatHover = vgui.Create( "DPanel", receiverPnl )
                        F4CatHover:SetPos( 0, 0 )
                        F4CatHover:SetSize( F4Wide, receiverPnl:GetTall() )
                        F4CatHover.Paint = function( self2, w, h ) 
                            if( IsValid( receiverPnl ) and receiverPnl.droppableHovered ) then
                                surface.SetAlphaMultiplier( 0.8 )
                                draw.RoundedBox( 1, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
                                surface.SetAlphaMultiplier( 1 )
                            end
                        end

                        timer.Create( "BRS_REMOVE_SETDROPHOVER", 0.05, 1, function()
                            if( IsValid( receiverPnl ) ) then
                                receiverPnl.droppableHovered = false
                            end
                        end )

                        timer.Create( "BRS_REMOVE_DROPHOVER", 0.1, 0, function()
                            if( IsValid( F4CatHover ) and (not receiverPnl or not IsValid( receiverPnl ) or not receiverPnl.droppableHovered) ) then
                                F4CatHover:Remove()
                                timer.Remove( "BRS_REMOVE_DROPHOVER" )
                            else
                                timer.Remove( "BRS_REMOVE_DROPHOVER" )
                            end
                        end )
                    end
                elseif( dropPanel.f4tabKey and BS_ConfigCopyTable.F4.Tabs[dropPanel.f4tabKey] and dropPanel.f4tabKey != receiverPnl.f4tabKey ) then
                    if( not istable( BS_ConfigCopyTable.F4.Tabs[receiverPnl.f4tabKey][3] ) ) then
                        BS_ConfigCopyTable.F4.Tabs[receiverPnl.f4tabKey][3] = {}
                    end

                    local newTab = { BS_ConfigCopyTable.F4.Tabs[dropPanel.f4tabKey][1], BS_ConfigCopyTable.F4.Tabs[dropPanel.f4tabKey][3] }
                    table.insert( BS_ConfigCopyTable.F4.Tabs[receiverPnl.f4tabKey][3], newTab )

                    table.remove( BS_ConfigCopyTable.F4.Tabs, dropPanel.f4tabKey )

                    self.RefreshPanel()
                    BRICKS_SERVER.Func.ConfigChange( "F4" )
                end
            end )
        end

        F4List.VBar:AddScroll( 50 )

        if( F4ListScroll ) then
            F4List.VBar:AnimateTo( F4ListScroll, 0 )
        end
    end
    self.RefreshPanel()
end

function PANEL:Paint( w, h )
    
end

vgui.Register( "bricks_server_config_f4", PANEL, "DPanel" )