local PANEL = {}

function PANEL:Init()

end

function PANEL:FillPanel( f4Panel, sheetButton )
    local shopTopBar = vgui.Create( "DPanel", self )
    shopTopBar:Dock( TOP )
    shopTopBar:DockMargin( 10, 10, 10, 5 )
    shopTopBar:SetTall( 40 )
    shopTopBar.Paint = function( self2, w, h ) end

    local shopSortBy = vgui.Create( "bricks_server_combo", shopTopBar )
    shopSortBy:Dock( RIGHT )
    shopSortBy:DockMargin( 5, 0, 0, 0 )
    shopSortBy:SetWide( 150 )
    shopSortBy:SetValue( "Default" )
    local shopPanel
    local shopSortChoice = "default"
    shopSortBy:AddChoice( "Default", "default" )
    if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "levelling" ) ) then
        shopSortBy:AddChoice( "Lowest Level", "level_low_to_high" )
        shopSortBy:AddChoice( "Highest Level", "level_high_to_low" )
    end
    shopSortBy:AddChoice( "Lowest Price", "price_low_to_high" )
    shopSortBy:AddChoice( "Highest Price", "price_high_to_low" )
    shopSortBy.OnSelect = function( self2, index, value, data )
        shopSortChoice = data
        shopPanel.FillShop() 
    end

    local shopSearchBarBack = vgui.Create( "DPanel", shopTopBar )
    shopSearchBarBack:Dock( FILL )
    local search = Material( "materials/bricks_server/search.png" )
    local Alpha = 0
    local Alpha2 = 20
    local shopSearchBar
    local color1 = BRICKS_SERVER.Func.GetTheme( 2 )
    shopSearchBarBack.Paint = function( self2, w, h )
        draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )

        if( shopSearchBar:IsEditing() ) then
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
    
    shopSearchBar = vgui.Create( "bricks_server_search", shopSearchBarBack )
    shopSearchBar:Dock( FILL )

    shopPanel = vgui.Create( "bricks_server_dcategorylist", self )
    shopPanel:Dock( FILL )
    shopPanel:DockMargin( 10, 0, 10, 10 )
    shopPanel.Paint = function( self, w, h ) end 

    local panelWide = ScrW()*0.6-BRICKS_SERVER.DEVCONFIG.MainNavWidth

    local spacing = 5
    local gridWide = panelWide-30
    local slotsWide = 2
    local slotWide = (gridWide-((slotsWide-1)*spacing))/slotsWide
    local slotTall = 75

    local function CreateShopPopout( shopKey, type, single )
        local itemTable = false
        local itemID = ""
        local itemGroup = {}
        local itemLevel
        if( type == "Entity" and DarkRPEntities[shopKey] ) then
            itemTable = DarkRPEntities[shopKey]
            itemGroup = BRICKS_SERVER.CONFIG.GENERAL.EntityGroups or {}
            itemID = itemTable.cmd
            if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "levelling" ) ) then
                itemLevel = BRICKS_SERVER.CONFIG.LEVELING.EntityLevels[itemTable.cmd]
            end
        elseif( type == "Shipment" and CustomShipments[shopKey] ) then
            itemTable = CustomShipments[shopKey]
            itemGroup = BRICKS_SERVER.CONFIG.GENERAL.ShipmentGroups or {}
            itemID = itemTable.name
            if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "levelling" ) ) then
                itemLevel = BRICKS_SERVER.CONFIG.LEVELING.ShipmentLevels[itemTable.name]
            end
        elseif( type == "Ammo" and GAMEMODE.AmmoTypes[shopKey] ) then
            itemTable = GAMEMODE.AmmoTypes[shopKey]
            itemGroup = BRICKS_SERVER.CONFIG.GENERAL.AmmoGroups or {}
            itemID = itemTable.id
            if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "levelling" ) ) then
                itemLevel = (BRICKS_SERVER.CONFIG.LEVELING.AmmoLevels or {})[itemTable.id]
            end
        end

        if( not itemTable ) then return end

        if( IsValid( shopPanel.shopPopout ) ) then
            shopPanel.shopPopout:Remove()
        else
            local shopPopoutClose = vgui.Create( "DButton", self )
            shopPopoutClose:SetSize( panelWide, ScrH()*0.65-40 )
            shopPopoutClose:SetText( "" )
            shopPopoutClose:SetAlpha( 0 )
            shopPopoutClose:AlphaTo( 255, 0.2 )
            shopPopoutClose:SetCursor( "arrow" )
            shopPopoutClose.Paint = function( self2, w, h )
                surface.SetDrawColor( 0, 0, 0, 150 )
                surface.DrawRect( 0, 0, w, h )
                BRICKS_SERVER.Func.DrawBlur( self2, 2, 2 )
            end
            shopPopoutClose.DoClick = function()
                if( IsValid( shopPanel.shopPopout ) ) then
                    shopPanel.shopPopout:MoveTo( panelWide, 0, 0.2, 0, -1, function()
                        if( IsValid( shopPanel.shopPopout ) ) then
                            shopPanel.shopPopout:Remove()
                        end
                    end )
                end

                shopPopoutClose:AlphaTo( 0, 0.2, 0, function()
                    if( IsValid( shopPopoutClose ) ) then
                        shopPopoutClose:Remove()
                    end
                end )
            end

            local popoutWide, popoutTall = panelWide*0.475, ScrH()*0.65-40

            shopPanel.shopPopout = vgui.Create( "DPanel", self )
            shopPanel.shopPopout:SetSize( popoutWide, popoutTall )
            shopPanel.shopPopout:SetPos( panelWide, 0 )
            shopPanel.shopPopout:MoveTo( panelWide-popoutWide, 0, 0.2 )
            shopPanel.shopPopout.Paint = function( self2, w, h )
                surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 2 ) )
                surface.DrawRect( 0, 0, w, h )
            end

            local shopAction = vgui.Create( "DButton", shopPanel.shopPopout )
            shopAction:Dock( BOTTOM )
            shopAction:SetTall( 40 )
            shopAction:SetText( "" )
            shopAction:DockMargin( 25, 25, 25, 25 )
            local changeAlpha = 0
            shopAction.Paint = function( self2, w, h )
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
        
                draw.SimpleText( "Purchase for " .. DarkRP.formatMoney( (single and (itemTable.pricesep or 0)) or itemTable.price ), "BRICKS_SERVER_Font20", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            end
            shopAction.DoClick = function()
                if( type == "Entity" ) then
                    RunConsoleCommand( "say", "/" .. itemTable.cmd )
                elseif( type == "Shipment" ) then
                    if( not single ) then
                        RunConsoleCommand( "DarkRP", "buyshipment", itemTable.name )
                    else
                        RunConsoleCommand( "DarkRP", "buy", itemTable.name )
                    end
                elseif( type == "Ammo" ) then
                    RunConsoleCommand( "DarkRP", "buyammo", itemTable.id )
                end

                shopPanel.shopPopout:MoveTo( panelWide, 0, 0.2, 0, -1, function()
                    if( IsValid( shopPanel.shopPopout ) ) then
                        shopPanel.shopPopout:Remove()
                    end
                end )

                shopPopoutClose:AlphaTo( 0, 0.2, 0, function()
                    if( IsValid( shopPopoutClose ) ) then
                        shopPopoutClose:Remove()
                    end
                end )
            end

            local topMargin, bottomMargin = popoutTall*0.075, 145
            surface.SetFont( "BRICKS_SERVER_Font20" )
            local textX, textY = surface.GetTextSize( "TEST" )

            local shopIcon = vgui.Create( "DModelPanel" , shopPanel.shopPopout )
            shopIcon:Dock( FILL )
            shopIcon:DockMargin( 0, topMargin+5+28+textY, 0, 5 )
            shopIcon:SetModel( itemTable.model )

            if( IsValid( shopIcon.Entity ) ) then
                function shopIcon:LayoutEntity(ent) return end

                local mn, mx = shopIcon.Entity:GetRenderBounds()
                local size = 0
                size = math.max( size, math.abs(mn.x) + math.abs(mx.x) )
                size = math.max( size, math.abs(mn.y) + math.abs(mx.y) )
                size = math.max( size, math.abs(mn.z) + math.abs(mx.z) )

                shopIcon:SetFOV( 70 )
                shopIcon:SetCamPos( Vector( size, size, size ) )
                shopIcon:SetLookAt( (mn + mx) * 0.5 )
            end

            local shopInfoDisplay = vgui.Create( "DPanel", shopPanel.shopPopout )
            shopInfoDisplay:SetSize( popoutWide, popoutTall-topMargin-bottomMargin )
            shopInfoDisplay:SetPos( popoutWide-shopInfoDisplay:GetWide(), topMargin )
            shopInfoDisplay.Paint = function( self2, w, h ) 
                draw.SimpleText( itemTable.name, "BRICKS_SERVER_Font25", w/2, 5, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, 0 )
            end

            local shopInfoNoticeBack = vgui.Create( "DPanel", shopInfoDisplay )
            shopInfoNoticeBack:SetSize( 0, 35 )
            shopInfoNoticeBack:SetPos( (shopInfoDisplay:GetWide()/2)-(shopInfoNoticeBack:GetWide()/2), 5+28 )
            shopInfoNoticeBack.Paint = function( self2, w, h ) end

            local shopNotices = {}

            if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "levelling" ) ) then
                if( itemLevel ) then
                    table.insert( shopNotices, { "Level " .. itemLevel } )
                end
            end

            local itemFinalGroup = itemGroup[itemID]
            if( itemFinalGroup ) then
                local groupTable
                for k, v in pairs( BRICKS_SERVER.CONFIG.GENERAL.Groups ) do
                    if( v[1] == itemFinalGroup ) then
                        groupTable = v
                    end
                end

                if( groupTable ) then
                    table.insert( shopNotices, { (groupTable[1] or "None"), groupTable[3] } )
                end
            end

            for k, v in pairs( shopNotices ) do
                surface.SetFont( "BRICKS_SERVER_Font20" )
                local textX, textY = surface.GetTextSize( v[1] )
                local boxW, boxH = textX+10, textY

                local shopInfoNotice = vgui.Create( "DPanel", shopInfoNoticeBack )
                shopInfoNotice:Dock( LEFT )
                shopInfoNotice:DockMargin( 0, 0, 5, 0 )
                shopInfoNotice:SetWide( boxW )
                shopInfoNotice.Paint = function( self2, w, h ) 
                    draw.RoundedBox( 5, 0, 0, w, h, (v[2] or BRICKS_SERVER.Func.GetTheme( 5 )) )
                    draw.SimpleText( v[1], "BRICKS_SERVER_Font20", w/2, (h/2)-1, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                end

                if( shopInfoNoticeBack:GetWide() <= 5 ) then
                    shopInfoNoticeBack:SetSize( shopInfoNoticeBack:GetWide()+boxW, boxH )
                else
                    shopInfoNoticeBack:SetSize( shopInfoNoticeBack:GetWide()+5+boxW, boxH )
                end
                shopInfoNoticeBack:SetPos( (shopInfoDisplay:GetWide()/2)-(shopInfoNoticeBack:GetWide()/2), 5+28 )
            end
        end
    end

    local scroll
    function shopPanel.FillShop()
        scroll = shopPanel.VBar:GetScroll() or 0

        shopPanel:Clear()

        local ShopOrdered = {}
        for k, v in pairs( DarkRPEntities ) do
            if( v.allowed ) then
                if( not table.HasValue( v.allowed, LocalPlayer():Team() ) ) then
                    continue
                end
            end

            if( shopSearchBar:GetValue() != "" and not string.find( string.lower( v.name ), string.lower( shopSearchBar:GetValue() ) ) ) then
                continue
            end

            if( v.customCheck and not v.customCheck( LocalPlayer() ) ) then continue end

            local sortValue = 0

            if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "levelling" ) ) then
                sortValue = BRICKS_SERVER.CONFIG.LEVELING.EntityLevels[v.cmd or "error"] or 0
            end

            if( shopSortChoice and shopSortChoice != "default" and string.StartWith( shopSortChoice, "price" ) ) then
                sortValue = v.price or 0
            elseif( shopSortChoice and shopSortChoice == "default" ) then
                sortValue = v.sortOrder or 0
            end

            table.insert( ShopOrdered, { k, "Entity", sortValue } )
        end

        for k, v in pairs( CustomShipments ) do
            if( v.noship and not v.seperate ) then continue end

            if( v.allowed ) then
                if( not table.HasValue( v.allowed, LocalPlayer():Team() ) ) then
                    continue
                end
            end

            if( shopSearchBar:GetValue() != "" and not string.find( string.lower( v.name ), string.lower( shopSearchBar:GetValue() ) ) ) then
                continue
            end

            if( v.customCheck and not v.customCheck( LocalPlayer() ) ) then continue end

            if( not v.noship ) then
                local sortValue = 0

                if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "levelling" ) ) then
                    sortValue = BRICKS_SERVER.CONFIG.LEVELING.ShipmentLevels[v.name or "error"] or 0
                end

                if( shopSortChoice and shopSortChoice != "default" and string.StartWith( shopSortChoice, "price" ) ) then
                    sortValue = v.price or 0
                elseif( shopSortChoice and shopSortChoice == "default" ) then
                    sortValue = v.sortOrder or 0
                end

                table.insert( ShopOrdered, { k, "Shipment", sortValue } )
            end

            if( v.seperate ) then
                local sortValue = 0

                if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "levelling" ) ) then
                    sortValue = BRICKS_SERVER.CONFIG.LEVELING.ShipmentLevels[v.name or "error"] or 0
                end

                if( shopSortChoice and shopSortChoice != "default" and string.StartWith( shopSortChoice, "price" ) ) then
                    sortValue = v.pricesep or 0
                elseif( shopSortChoice and shopSortChoice == "default" ) then
                    sortValue = v.sortOrder or 0
                end

                table.insert( ShopOrdered, { k, "Shipment", sortValue, true } )
            end
        end

        for k, v in pairs( GAMEMODE.AmmoTypes ) do
            if( shopSearchBar:GetValue() != "" and not string.find( string.lower( v.name ), string.lower( shopSearchBar:GetValue() ) ) ) then
                continue
            end

            if( v.customCheck and not v.customCheck( LocalPlayer() ) ) then continue end

            local sortValue = 0

            if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "levelling" ) ) then
                sortValue = (BRICKS_SERVER.CONFIG.LEVELING.AmmoLevels or {})[v.id] or 0
            end

            if( shopSortChoice and shopSortChoice != "default" and string.StartWith( shopSortChoice, "price" ) ) then
                sortValue = v.pricesep or 0
            elseif( shopSortChoice and shopSortChoice == "default" ) then
                sortValue = v.sortOrder or 0
            end

            table.insert( ShopOrdered, { k, "Ammo", sortValue } )
        end

        if( shopSortChoice and string.EndsWith( shopSortChoice, "high_to_low" ) ) then
            table.SortByMember( ShopOrdered, 3, false )
        else
            table.SortByMember( ShopOrdered, 3, true )
        end

        local categories = {}
        for k, v in ipairs( ShopOrdered ) do
            local type = v[2]
            local itemTable
            local itemGroup = {}
            local itemLevel = 0
            if( type == "Entity" and DarkRPEntities[v[1]] ) then
                itemTable = DarkRPEntities[v[1]]
                itemGroup = BRICKS_SERVER.CONFIG.GENERAL.EntityGroups or {}
                if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "levelling" ) ) then
                    itemLevel = (BRICKS_SERVER.CONFIG.LEVELING.EntityLevels[itemTable.cmd] or 0)
                end
            elseif( type == "Shipment" and CustomShipments[v[1]] ) then
                itemTable = CustomShipments[v[1]]
                itemGroup = BRICKS_SERVER.CONFIG.GENERAL.ShipmentGroups or {}
                if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "levelling" ) ) then
                    itemLevel = (BRICKS_SERVER.CONFIG.LEVELING.ShipmentLevels[itemTable.name] or 0)
                end
            elseif( type == "Ammo" and GAMEMODE.AmmoTypes[v[1]] ) then
                itemTable = GAMEMODE.AmmoTypes[v[1]]
                itemGroup = BRICKS_SERVER.CONFIG.GENERAL.AmmoGroups or {}
                if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "levelling" ) ) then
                    itemLevel = ((BRICKS_SERVER.CONFIG.LEVELING.AmmoLevels or {})[itemTable.id] or 0)
                end
            end

            if( not itemTable ) then continue end

            local itemCategory = itemTable.category or "Other"

            local categoriesTable = DarkRP.getCategories().entities
            if( type == "Shipment" ) then
                categoriesTable = DarkRP.getCategories().shipments
            elseif( type == "Ammo" ) then
                categoriesTable = DarkRP.getCategories().ammo
            end

            local categoryTable = {}
            for key, val in pairs( categoriesTable ) do
                if( itemCategory == val.name ) then
                    categoryTable = val
                    break
                end
            end

            if( categoryTable.canSee and not categoryTable.canSee( LocalPlayer() ) ) then continue end

            if( not categories[itemCategory] ) then
                categories[itemCategory] = shopPanel:Add( itemCategory, categoryTable.color or BRICKS_SERVER.Func.GetTheme( 4 ) )
                categories[itemCategory]:SetTall( 40 )
                categories[itemCategory].type = type

                categories[itemCategory].grid = vgui.Create( "DIconLayout", categories[itemCategory] )
                categories[itemCategory].grid:Dock( FILL )
                categories[itemCategory].grid:DockMargin( 5, spacing, 0, 0 )
                categories[itemCategory].grid:SetTall( slotTall )
                categories[itemCategory].grid:SetSpaceY( spacing )
                categories[itemCategory].grid:SetSpaceX( spacing )
            end

            categories[itemCategory].slots = (categories[itemCategory].slots or 0)+1
            local slots = categories[itemCategory].slots
            local slotsTall = math.ceil( slots/slotsWide )
            categories[itemCategory]:SetTall( 40+10+(slotsTall*slotTall)+((slotsTall-1)*spacing) )
            categories[itemCategory].grid:SetTall( (slotsTall*slotTall)+((slotsTall-1)*spacing) )

            local itemBack = categories[itemCategory].grid:Add( "DPanel" )
            itemBack:SetSize( slotWide, slotTall )
            local circleRadius = (slotTall-20)/2
            local degree = 0
            local itemMax = (itemTable.getMax and itemTable.getMax( LocalPlayer() )) or itemTable.max
            itemBack.Paint = function( self2, w, h )
                draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
                draw.RoundedBox( 5, 5, 5, h-10, h-10, BRICKS_SERVER.Func.GetTheme( 2 ) )

                draw.SimpleText( itemTable.name, "BRICKS_SERVER_Font30", h+10, h/2+2, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_BOTTOM )

                draw.SimpleText( DarkRP.formatMoney( (v[4] and (itemTable.pricesep or 0)) or itemTable.price ), "BRICKS_SERVER_Font20", h+10, h/2-2, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
                
                if( itemMax ) then
                    local currentBoughtEntities = 0
                    if( type == "Entity" and LocalPlayer().customEntityGetCurrent ) then
                        currentBoughtEntities = LocalPlayer():customEntityGetCurrent( itemTable.cmd )
                    end

                    surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 2 ) )
                    draw.NoTexture()
                    BRICKS_SERVER.Func.DrawCircle( w-10-circleRadius, h/2, circleRadius, 45 )
    
                    degree = Lerp( FrameTime()*4, degree, math.Clamp( (currentBoughtEntities/itemMax), 0, 1 )*360 )

                    BRICKS_SERVER.Func.DrawArc( w-10-circleRadius, h/2, circleRadius, 2, -90, degree-90, BRICKS_SERVER.Func.GetTheme( 4 ) )
    
                    if( itemMax > 0 ) then
                        draw.SimpleText( currentBoughtEntities .. "/" .. itemMax, "BRICKS_SERVER_Font20", w-10-circleRadius, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                    else
                        draw.SimpleText( currentBoughtEntities .. "/∞", "BRICKS_SERVER_Font20", w-10-circleRadius, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                    end
                end
            end

            if( (BRICKS_SERVER.CONFIG.GENERAL["F4 Use Spawn Icons"] or false) == true ) then
                local itemIcon = vgui.Create( "SpawnIcon" , itemBack )
                itemIcon:SetPos( 5, 5 )
                itemIcon:SetSize( itemBack:GetTall()-10, itemBack:GetTall()-10 )
                if( istable( itemTable.model ) ) then
                    itemIcon:SetModel( itemTable.model[1] )
                else
                    itemIcon:SetModel( itemTable.model )
                end
            else
                local itemIcon = vgui.Create( "DModelPanel" , itemBack )
                itemIcon:SetPos( 5, 5 )
                itemIcon:SetSize( itemBack:GetTall()-10, itemBack:GetTall()-10 )
                if( istable( itemTable.model ) ) then
                    itemIcon:SetModel( itemTable.model[1] )
                else
                    itemIcon:SetModel( itemTable.model )
                end
                function itemIcon:LayoutEntity(ent) return end

                if( IsValid( itemIcon.Entity ) ) then
                    local mn, mx = itemIcon.Entity:GetRenderBounds()
                    local size = 0
                    size = math.max( size, math.abs(mn.x) + math.abs(mx.x) )
                    size = math.max( size, math.abs(mn.y) + math.abs(mx.y) )
                    size = math.max( size, math.abs(mn.z) + math.abs(mx.z) )
        
                    itemIcon:SetFOV( 60 )
                    itemIcon:SetCamPos( Vector( size, size, size ) )
                    itemIcon:SetLookAt( (mn + mx) * 0.5 )
                end
            end

            local itemButton = vgui.Create( "DButton", itemBack )
            itemButton:SetPos( 0, 0 )
            itemButton:SetSize( slotWide, itemBack:GetTall() )
            itemButton:SetText( "" )
            local changeAlpha = 0
            itemButton.Paint = function( self2, w, h ) 
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
            itemButton.DoClick = function()
                CreateShopPopout( v[1], v[2], v[4] )
            end
        end

        for k, v in pairs( categories ) do
            local categoryTable = DarkRP.getCategories().entities
            if( v.type == "Shipment" ) then
                categoryTable = DarkRP.getCategories().shipments
            elseif( v.type == "Ammo" ) then
                categoryTable = DarkRP.getCategories().ammo
            end

            for key, val in pairs( categoryTable ) do
                if( k == val.name ) then
                    v:SetExpanded( val.startExpanded )
                    v:SetZPos( val.sortOrder or 0 )
                end
            end
        end

        if( scroll ) then
            shopPanel.VBar:AnimateTo( scroll, 0 )
        end
    end
    shopPanel.FillShop()

    shopSearchBar.OnChange = function()
        shopPanel.FillShop()
    end

    hook.Add( "OnPlayerChangedTeam", "BRS.OnPlayerChangedTeam_F4Shop", function()
        timer.Simple( 0.25, function()
            if( IsValid( shopPanel ) ) then
                shopPanel.FillShop()
            end
        end )
    end )
end

function PANEL:Paint( w, h )

end

vgui.Register( "bricks_server_f4_shop", PANEL, "DPanel" )