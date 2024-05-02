local PANEL = {}

function PANEL:Init()

end

function PANEL:FillPanel( f4Panel, sheetButton )
    local craftingSearchBarBack = vgui.Create( "DPanel", self )
    craftingSearchBarBack:Dock( TOP )
    craftingSearchBarBack:DockMargin( 10, 10, 10, 5 )
    craftingSearchBarBack:SetTall( 40 )
    local search = Material( "materials/bricks_server/search.png" )
    local Alpha = 0
    local Alpha2 = 20
    local craftingSearchBar
    local color1 = BRICKS_SERVER.Func.GetTheme( 2 )
    craftingSearchBarBack.Paint = function( self2, w, h )
        draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )

        if( craftingSearchBar:IsEditing() ) then
            Alpha = math.Clamp( Alpha+5, 0, 100 )
            Alpha2 = math.Clamp( Alpha2+20, 20, 255 )
        else
            Alpha = math.Clamp( Alpha-5, 0, 100 )
            Alpha2 = math.Clamp( Alpha2-20, 20, 255 )
        end
        
        draw.RoundedBox( 5, 0, 0, w, h, Color( color1.r, color1.g, color1.b, Alpha ) )
    
        surface.SetDrawColor( 255, 255, 255, Alpha2 )
        surface.SetMaterial(search)
        local size = 24
        surface.DrawTexturedRect( w-size-(h-size)/2, (h-size)/2, size, size )
    end
    
    craftingSearchBar = vgui.Create( "bricks_server_search", craftingSearchBarBack )
    craftingSearchBar:Dock( FILL )

    local craftingPanel = vgui.Create( "bricks_server_scrollpanel", self )
    craftingPanel:Dock( FILL )
    craftingPanel:DockMargin( 10, 0, 10, 10 )
    craftingPanel.Paint = function( self, w, h ) end 

    local panelWide, panelTall = ScrW()*0.6-BRICKS_SERVER.DEVCONFIG.MainNavWidth, ScrH()*0.65-40
    local popoutWide, popoutTall = panelWide*0.5, panelTall

    local spacing = 5
    local gridWide = panelWide-20
    local slotsWide = 2
    local slotWide = (gridWide-((slotsWide-1)*spacing))/slotsWide
    local slotTall = 75
    
    local function CreateItemPopout( itemKey )
        local itemTable = BRICKS_SERVER.CONFIG.CRAFTING.Craftables[itemKey] or {}

        if( IsValid( craftingPanel.itemPopout ) ) then
            craftingPanel.itemPopout:Remove()
        else
            local itemPopoutClose = vgui.Create( "DButton", self )
            itemPopoutClose:SetSize( panelWide, panelTall )
            itemPopoutClose:SetText( "" )
            itemPopoutClose:SetAlpha( 0 )
            itemPopoutClose:AlphaTo( 255, 0.2 )
            itemPopoutClose:SetCursor( "arrow" )
            itemPopoutClose.Paint = function( self2, w, h )
                surface.SetDrawColor( 0, 0, 0, 150 )
                surface.DrawRect( 0, 0, w, h )
                BRICKS_SERVER.Func.DrawBlur( self2, 2, 2 )
            end
            itemPopoutClose.DoClick = function()
                craftingPanel.itemPopout:MoveTo( panelWide, (panelTall/2)-(popoutTall/2), 0.2, 0, -1, function()
                    if( IsValid( craftingPanel.itemPopout ) ) then
                        craftingPanel.itemPopout:Remove()
                    end
                end )

                itemPopoutClose:AlphaTo( 0, 0.2, 0, function()
                    if( IsValid( itemPopoutClose ) ) then
                        itemPopoutClose:Remove()
                    end
                end )
            end

            craftingPanel.itemPopout = vgui.Create( "DPanel", self )
            craftingPanel.itemPopout:SetSize( popoutWide, popoutTall )
            craftingPanel.itemPopout:SetPos( panelWide, (panelTall/2)-(popoutTall/2) )
            craftingPanel.itemPopout:MoveTo( (panelWide)-(popoutWide), (panelTall/2)-(popoutTall/2), 0.2 )
            craftingPanel.itemPopout.Paint = function( self2, w, h )
                surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 2 ) )
                surface.DrawRect( 0, 0, w, h )
            end

            local itemAction = vgui.Create( "DButton", craftingPanel.itemPopout )
            itemAction:Dock( BOTTOM )
            itemAction:SetTall( 40 )
            itemAction:SetText( "" )
            itemAction:DockMargin( 25, 25, 25, 25 )
            local changeAlpha = 0
            itemAction.Paint = function( self2, w, h )
                if( self2:IsDown() ) then
                    changeAlpha = math.Clamp( changeAlpha+10, 0, 125 )
                elseif( self2:IsHovered() ) then
                    changeAlpha = math.Clamp( changeAlpha+10, 0, 75 )
                else
                    changeAlpha = math.Clamp( changeAlpha-10, 0, 75 )
                end
                
                draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 5 ) )
        
                surface.SetAlphaMultiplier( changeAlpha/255 )
                draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 4 ) )
                surface.SetAlphaMultiplier( 1 )
        
                draw.SimpleText( "Craft", "BRICKS_SERVER_Font20", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            end
            itemAction.DoClick = function()
                if( not BRS_CRAFTING_TIMES or not BRS_CRAFTING_TIMES[itemKey] ) then
                    net.Start( "BRS.Net.CraftItem" )
                        net.WriteUInt( itemKey, 8 )
                    net.SendToServer()
                else
                    net.Start( "BRS.Net.CraftCancel" )
                        net.WriteUInt( itemKey, 8 )
                    net.SendToServer()
                end

                craftingPanel.itemPopout:MoveTo( panelWide, (panelTall/2)-(popoutTall/2), 0.2, 0, -1, function()
                    if( IsValid( craftingPanel.itemPopout ) ) then
                        craftingPanel.itemPopout:Remove()
                    end
                end )

                itemPopoutClose:AlphaTo( 0, 0.2, 0, function()
                    if( IsValid( itemPopoutClose ) ) then
                        itemPopoutClose:Remove()
                    end
                end )
            end

            local topMargin, bottomMargin = popoutTall*0.075, 145
            surface.SetFont( "BRICKS_SERVER_Font20" )
            local textX, textY = surface.GetTextSize( "TEST" )

            local itemIcon = vgui.Create( "DModelPanel" , craftingPanel.itemPopout )
            itemIcon:Dock( FILL )
            itemIcon:DockMargin( 0, topMargin+5+28+textY, 0, 5 )
            itemIcon:SetModel( itemTable.Model )
            if( IsValid( itemIcon.Entity ) ) then
                function itemIcon:LayoutEntity(ent) return end
                local mn, mx = itemIcon.Entity:GetRenderBounds()
                local size = 0
                size = math.max( size, math.abs(mn.x) + math.abs(mx.x) )
                size = math.max( size, math.abs(mn.y) + math.abs(mx.y) )
                size = math.max( size, math.abs(mn.z) + math.abs(mx.z) )

                itemIcon:SetFOV( 80 )
                itemIcon:SetCamPos( Vector( size, size, size ) )
                itemIcon:SetLookAt( (mn + mx) * 0.5 )
            end

            if( itemTable.Color ) then
                itemIcon:SetColor( itemTable.Color )
            end

            local itemInfoDisplay = vgui.Create( "DPanel", craftingPanel.itemPopout )
            itemInfoDisplay:SetSize( popoutWide, popoutTall-topMargin-bottomMargin )
            itemInfoDisplay:SetPos( popoutWide-itemInfoDisplay:GetWide(), topMargin )
            itemInfoDisplay.Paint = function( self2, w, h ) 
                draw.SimpleText( itemTable.Name, "BRICKS_SERVER_Font25", w/2, 5, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, 0 )
            end

            local itemInfoNoticeBack = vgui.Create( "DPanel", itemInfoDisplay )
            itemInfoNoticeBack:SetSize( 0, 35 )
            itemInfoNoticeBack:SetPos( (itemInfoDisplay:GetWide()/2)-(itemInfoNoticeBack:GetWide()/2), 5+28 )
            itemInfoNoticeBack.Paint = function( self2, w, h ) end

            local itemNotices = {}

            if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "levelling" ) and itemTable.Level ) then
                table.insert( itemNotices, { "Level " .. itemTable.Level } )
            end

            if( itemTable.Group ) then
                local groupTable
                for k, v in pairs( BRICKS_SERVER.CONFIG.GENERAL.Groups ) do
                    if( v[1] == itemTable.Group ) then
                        groupTable = v
                    end
                end

                if( groupTable ) then
                    table.insert( itemNotices, { (groupTable[1] or "None"), groupTable[3] } )
                end
            end

            for k, v in pairs( itemNotices ) do
                surface.SetFont( "BRICKS_SERVER_Font20" )
                local textX, textY = surface.GetTextSize( v[1] )
                local boxW, boxH = textX+10, textY

                local itemInfoNotice = vgui.Create( "DPanel", itemInfoNoticeBack )
                itemInfoNotice:Dock( LEFT )
                itemInfoNotice:DockMargin( 0, 0, 5, 0 )
                itemInfoNotice:SetWide( boxW )
                itemInfoNotice.Paint = function( self2, w, h ) 
                    draw.RoundedBox( 5, 0, 0, w, h, (v[2] or BRICKS_SERVER.Func.GetTheme( 5 )) )
                    draw.SimpleText( v[1], "BRICKS_SERVER_Font20", w/2, (h/2)-1, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                end

                if( itemInfoNoticeBack:GetWide() <= 5 ) then
                    itemInfoNoticeBack:SetSize( itemInfoNoticeBack:GetWide()+boxW, boxH )
                else
                    itemInfoNoticeBack:SetSize( itemInfoNoticeBack:GetWide()+5+boxW, boxH )
                end
                itemInfoNoticeBack:SetPos( (itemInfoDisplay:GetWide()/2)-(itemInfoNoticeBack:GetWide()/2), 5+28 )
            end

            local resourceListBack = vgui.Create( "bricks_server_scrollpanel", itemInfoDisplay )
            resourceListBack:Dock( RIGHT )
            resourceListBack:SetWide( 50 )
            resourceListBack:DockMargin( 0, 75, 25, 0 )
            resourceListBack.Paint = function( self2, w, h ) end

            for k, v in pairs( itemTable.Resources ) do
                local modelEntryButton = vgui.Create( "DPanel", resourceListBack )
                modelEntryButton:Dock( TOP )
                modelEntryButton:SetTall( resourceListBack:GetWide() )
                modelEntryButton:DockMargin( 0, 0, 0, 5 )
                local changeAlpha = 0
                local modelEntryIcon
                local x, y, w, h = 0, 0, modelEntryButton:GetTall(), modelEntryButton:GetTall()
                modelEntryButton.Paint = function( self2, w, h )
                    local toScreenX, toScreenY = self2:LocalToScreen( 0, 0 )
                    if( x != toScreenX or y != toScreenY ) then
                        x, y = toScreenX, toScreenY
        
                        modelEntryIcon:SetBRSToolTip( x, y, w, h, "x" .. string.Comma( v ) .. " " .. k )
                    end

                    if( modelEntryIcon:IsDown() ) then
                        changeAlpha = math.Clamp( changeAlpha+10, 0, 125 )
                    elseif( modelEntryIcon:IsHovered() ) then
                        changeAlpha = math.Clamp( changeAlpha+10, 0, 75 )
                    else
                        changeAlpha = math.Clamp( changeAlpha-10, 0, 75 )
                    end
                    
                    draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
            
                    surface.SetAlphaMultiplier( changeAlpha/255 )
                    draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 5 ) )
                    surface.SetAlphaMultiplier( 1 )
                end

                local model = "error.model"
                if( BRICKS_SERVER.CONFIG.CRAFTING.Resources and BRICKS_SERVER.CONFIG.CRAFTING.Resources[k] ) then
                    model = BRICKS_SERVER.CONFIG.CRAFTING.Resources[k][1]
                end

                modelEntryIcon = vgui.Create( "DModelPanel" , modelEntryButton )
                modelEntryIcon:Dock( FILL )
                modelEntryIcon:SetModel( model )
                if( modelEntryIcon.Entity and IsValid( modelEntryIcon.Entity ) ) then
                    function modelEntryIcon:LayoutEntity(ent) return end
                    local mn, mx = modelEntryIcon.Entity:GetRenderBounds()
                    local size = 0
                    size = math.max( size, math.abs(mn.x) + math.abs(mx.x) )
                    size = math.max( size, math.abs(mn.y) + math.abs(mx.y) )
                    size = math.max( size, math.abs(mn.z) + math.abs(mx.z) )
            
                    modelEntryIcon:SetFOV( 50 )
                    modelEntryIcon:SetCamPos( Vector( size, size, size ) )
                    modelEntryIcon:SetLookAt( (mn + mx) * 0.5 )

                    if( BRICKS_SERVER.CONFIG.CRAFTING.Resources and BRICKS_SERVER.CONFIG.CRAFTING.Resources[k] and BRICKS_SERVER.CONFIG.CRAFTING.Resources[k][2] ) then
                        modelEntryIcon:SetColor( BRICKS_SERVER.CONFIG.CRAFTING.Resources[k][2] )
                    end
                end
            end
        end
    end

    local function fillCrafting()
        craftingPanel:Clear()

        local sortedCraftingTable = {}
        for k, v in pairs( BRICKS_SERVER.CONFIG.CRAFTING.Craftables ) do
            if( craftingSearchBar:GetValue() != "" and not string.find( string.lower( v.Name ), string.lower( craftingSearchBar:GetValue() ) ) ) then
                continue
            end

            local newItemTable = v
            newItemTable.key = k

            table.insert( sortedCraftingTable, newItemTable )
        end

        table.sort( sortedCraftingTable, function(a, b) return ((a or {}).Level or 0) < ((b or {}).Level or 0) end )

        for k, v in pairs( sortedCraftingTable ) do
            local craftingBack = vgui.Create( "DPanel", craftingPanel )
            craftingBack:Dock( TOP )
            craftingBack:SetTall( 100 )
            craftingBack:DockMargin( 0, 0, 0, 5 )
            craftingBack:DockPadding( 0, 0, 25, 5 )
            local resourceString = ""
            for key, val in pairs( v.Resources or {} ) do
                if( resourceString == "" ) then
                    resourceString = val .. " " .. key
                else
                    resourceString = resourceString .. ", " .. val .. " " .. key
                end
            end
            local craftingType = BRICKS_SERVER.DEVCONFIG.CraftingTypes[v.Type or ""] or {}
            local amount = 1
            if( craftingType.ReqInfo and craftingType.ReqInfo[2] and craftingType.ReqInfo[2][1] and craftingType.ReqInfo[2][1] == "Amount" ) then
                amount = v.ReqInfo[2] or 1
            end
            local loadingIcon = Material( "materials/bricks_server/loading.png" )
            craftingBack.Paint = function( self2, w, h )
                draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )

                if( BRS_CRAFTING_TIMES and BRS_CRAFTING_TIMES[v.key] ) then
                    local finalWidth = w*math.Clamp( (BRS_CRAFTING_TIMES[v.key]-CurTime())/v.CraftTime, 0, 1 )
                    if( finalWidth <= w-5 ) then
                        draw.RoundedBoxEx( 5, 0, 0, finalWidth, h, BRICKS_SERVER.Func.GetTheme( 4 ), true, false, true, false )
                    else
                        draw.RoundedBox( 5, 0, 0, finalWidth, h, BRICKS_SERVER.Func.GetTheme( 4 ) )
                    end
                end

                draw.RoundedBox( 5, 5, 5, h-10, h-10, BRICKS_SERVER.Func.GetTheme( 2 ) )

                if( amount > 1 ) then
                    draw.SimpleText( "x" .. amount .. " " .. v.Name, "BRICKS_SERVER_Font33", h+15, 5, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
                else
                    draw.SimpleText( v.Name, "BRICKS_SERVER_Font33", h+15, 5, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
                end
                
                if( BRS_CRAFTING_TIMES and BRS_CRAFTING_TIMES[v.key] ) then
                    draw.SimpleText( "Time left: " .. BRICKS_SERVER.Func.FormatTime( math.max( 0, BRS_CRAFTING_TIMES[v.key]-CurTime() ) ), "BRICKS_SERVER_Font20", h+15, 32, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )

                    surface.SetDrawColor( 255, 255, 255, 255 )
                    surface.SetMaterial( loadingIcon )
                    local size = 32
                    surface.DrawTexturedRectRotated( w/2, h/2, size, size, -(CurTime() % 360 * 250) )

                    draw.SimpleText( "Crafting", "BRICKS_SERVER_Font20", w/2, h/2+(size/2)+5, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, 0 )
                else
                    if( v.CraftTime ) then
                        draw.SimpleText( "Time: " .. BRICKS_SERVER.Func.FormatWordTime( v.CraftTime ), "BRICKS_SERVER_Font20", h+15, 32, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
                    end
                    draw.SimpleText( resourceString, "BRICKS_SERVER_Font20", h+15, 47, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
                end
            end

            local craftingModel = vgui.Create( "DModelPanel" , craftingBack )
            craftingModel:SetPos( 5, 5 )
            craftingModel:SetSize( craftingBack:GetTall()-10, craftingBack:GetTall()-10 )
            craftingModel:SetModel( v.Model or "models/error.mdl" )
            function craftingModel:LayoutEntity( Entity ) return end
            if( v.Color ) then
                craftingModel:SetColor( v.Color )
            end

            if( IsValid( craftingModel.Entity ) ) then
                local mn, mx = craftingModel.Entity:GetRenderBounds()
                local size = 0
                size = math.max( size, math.abs(mn.x) + math.abs(mx.x) )
                size = math.max( size, math.abs(mn.y) + math.abs(mx.y) )
                size = math.max( size, math.abs(mn.z) + math.abs(mx.z) )
        
                craftingModel:SetFOV( 50 )
                craftingModel:SetCamPos( Vector( size, size, size ) )
                craftingModel:SetLookAt( (mn + mx) * 0.5 )
            end

            local craftingAction = vgui.Create( "DButton", craftingBack )
            craftingAction:SetPos( 0, 0 )
            craftingAction:SetSize( ScrW()*0.6-BRICKS_SERVER.DEVCONFIG.MainNavWidth-20, craftingBack:GetTall() )
            craftingAction:SetText( "" )
            local changeAlpha = 0
            craftingAction.Paint = function( self2, w, h ) 
                if( self2:IsDown() ) then
                    changeAlpha = math.Clamp( changeAlpha+10, 0, 125 )
                elseif( self2:IsHovered() ) then
                    changeAlpha = math.Clamp( changeAlpha+10, 0, 95 )
                else
                    changeAlpha = math.Clamp( changeAlpha-10, 0, 95 )
                end

                surface.SetAlphaMultiplier( changeAlpha/255 )
                draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
                surface.SetAlphaMultiplier( 1 )
            end
            craftingAction.DoClick = function()
                CreateItemPopout( v.key )
            end
        end
    end
    fillCrafting()

    hook.Add( "BRS.Hooks.FillCrafting", "BRS.BRS.Hooks.FillCrafting_F4", function()
        if( IsValid( self ) ) then
            fillCrafting()
        end
    end )

    craftingSearchBar.OnChange = function()
        fillCrafting()
    end
end

function PANEL:Paint( w, h )

end

vgui.Register( "bricks_server_f4_crafting", PANEL, "DPanel" )