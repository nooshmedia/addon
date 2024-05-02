local PANEL = {}

function PANEL:Init()

end

function PANEL:FillPanel()
    local itemActions = {
        ["Edit group"] = function( k, v, type, itemTable )
            local default = ""
            if( type == "Entity" ) then
                BS_ConfigCopyTable.GENERAL.EntityGroups = BS_ConfigCopyTable.GENERAL.EntityGroups or {}
                default = BS_ConfigCopyTable.GENERAL.EntityGroups[itemTable.cmd] or ""
            elseif( type == "Shipment" ) then
                BS_ConfigCopyTable.GENERAL.ShipmentGroups = BS_ConfigCopyTable.GENERAL.ShipmentGroups or {}
                default = BS_ConfigCopyTable.GENERAL.ShipmentGroups[itemTable.name] or ""
            elseif( type == "Ammo" ) then
                default = (BS_ConfigCopyTable.GENERAL.AmmoGroups or {})[itemTable.id] or ""
            end

            local options = {
                ["None"] = "None"
            }

            for k, v in pairs( (BS_ConfigCopyTable or BRICKS_SERVER.CONFIG).GENERAL.Groups ) do
                options[k] = v[1]
            end

            BRICKS_SERVER.Func.ComboRequest( "Admin", "What group would you like this item to be?", default, options, function( value, data )
                if( data != "None" and not (BS_ConfigCopyTable or BRICKS_SERVER.CONFIG).GENERAL.Groups[data] ) then 
                    notification.AddLegacy( "Invalid group.", 1, 3 )
                    return 
                end

                if( data == "None" ) then
                    value = nil
                end

                if( type == "Entity" ) then
                    BS_ConfigCopyTable.GENERAL.EntityGroups[itemTable.cmd] = value
                elseif( type == "Shipment" ) then
                    BS_ConfigCopyTable.GENERAL.ShipmentGroups[itemTable.name] = value
                elseif( type == "Ammo" ) then
                    BS_ConfigCopyTable.GENERAL.AmmoGroups = BS_ConfigCopyTable.GENERAL.AmmoGroups or {}
                    BS_ConfigCopyTable.GENERAL.AmmoGroups[itemTable.id] = value
                end

                self.RefreshPanel()
                BRICKS_SERVER.Func.ConfigChange( "GENERAL" )
            end, function() end, "OK", "Cancel" )
        end
    }

    if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "levelling" ) ) then
        itemActions["Edit level"] = function( k, v, type, itemTable )
            local default = 0
            if( type == "Entity" ) then
                default = BS_ConfigCopyTable.LEVELING.EntityLevels[itemTable.cmd or "error"]
            elseif( type == "Shipment" ) then
                default = BS_ConfigCopyTable.LEVELING.ShipmentLevels[itemTable.name or "error"]
            elseif( type == "Ammo" ) then
                default = (BS_ConfigCopyTable.LEVELING.AmmoLevels or {})[itemTable.id]
            end

            BRICKS_SERVER.Func.StringRequest( "Admin", "What level would you like this item to be?", default, function( text ) 
                if( isnumber( tonumber( text ) ) ) then
                    if( type == "Entity" ) then
                        BS_ConfigCopyTable.LEVELING.EntityLevels[itemTable.cmd] = tonumber( text )
                    elseif( type == "Shipment" ) then
                        BS_ConfigCopyTable.LEVELING.ShipmentLevels[itemTable.name] = tonumber( text )
                    elseif( type == "Ammo" ) then
                        BS_ConfigCopyTable.LEVELING.AmmoLevels = BS_ConfigCopyTable.LEVELING.AmmoLevels or {}
                        BS_ConfigCopyTable.LEVELING.AmmoLevels[itemTable.id] = tonumber( text )
                    end
                    self.RefreshPanel()
                    BRICKS_SERVER.Func.ConfigChange( "LEVELING" )
                else
                    notification.AddLegacy( "Invalid number.", 1, 3 )
                end
            end, function() end, "OK", "Cancel", true )
        end
    end

    local shopTopBar = vgui.Create( "DPanel", self )
    shopTopBar:Dock( TOP )
    shopTopBar:DockMargin( 0, 0, 0, 5 )
    shopTopBar:SetTall( 40 )
    shopTopBar.Paint = function( self2, w, h ) end

    local shopSortBy = vgui.Create( "bricks_server_combo", shopTopBar )
    shopSortBy:Dock( RIGHT )
    shopSortBy:DockMargin( 5, 0, 0, 0 )
    shopSortBy:SetWide( 150 )
    shopSortBy:SetValue( "Default" )
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
        self.RefreshPanel() 
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

    local shopPanel = vgui.Create( "bricks_server_scrollpanel", self )
    shopPanel:Dock( FILL )

    function self.RefreshPanel()
        shopPanel:Clear()

        local ShopOrdered = {}
        for k, v in pairs( DarkRPEntities ) do
            if( shopSearchBar:GetValue() != "" and not string.find( string.lower( v.name ), string.lower( shopSearchBar:GetValue() ) ) ) then
                continue
            end

            local sortValue = 0

            if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "levelling" ) ) then
                sortValue = BS_ConfigCopyTable.LEVELING.EntityLevels[v.cmd or "error"] or 0
            end

            if( shopSortChoice and string.StartWith( shopSortChoice, "price" ) ) then
                sortValue = v.price or 0
            end

            table.insert( ShopOrdered, { k, "Entity", sortValue } )
        end

        for k, v in pairs( CustomShipments ) do
            if( v.noship ) then continue end

            if( shopSearchBar:GetValue() != "" and not string.find( string.lower( v.name ), string.lower( shopSearchBar:GetValue() ) ) ) then
                continue
            end

            local sortValue = 0

            if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "levelling" ) ) then
                sortValue = BS_ConfigCopyTable.LEVELING.ShipmentLevels[v.name or "error"] or 0
            end

            if( shopSortChoice and string.StartWith( shopSortChoice, "price" ) ) then
                sortValue = v.price or 0
            end

            table.insert( ShopOrdered, { k, "Shipment", sortValue } )
        end

        for k, v in pairs( GAMEMODE.AmmoTypes ) do
            if( shopSearchBar:GetValue() != "" and not string.find( string.lower( v.name ), string.lower( shopSearchBar:GetValue() ) ) ) then
                continue
            end

            local sortValue = 0

            if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "levelling" ) ) then
                sortValue = (BS_ConfigCopyTable.LEVELING.AmmoLevels or {})[v.id] or 0
            end

            if( shopSortChoice and string.StartWith( shopSortChoice, "price" ) ) then
                sortValue = v.price or 0
            end

            table.insert( ShopOrdered, { k, "Ammo", sortValue } )
        end

        if( shopSortChoice != "default" ) then
            if( shopSortChoice ) then
                if( string.EndsWith( shopSortChoice, "high_to_low" ) ) then
                    table.SortByMember( ShopOrdered, 3, false )
                else
                    table.SortByMember( ShopOrdered, 3, true )
                end
            else
                table.SortByMember( ShopOrdered, 3, true )
            end
        end

        for k, v in ipairs( ShopOrdered ) do
            local type = v[2]
            local itemTable = false
            local itemLevel
            if( type == "Entity" and DarkRPEntities[v[1]] ) then
                itemTable = DarkRPEntities[v[1]]
                itemLevel = BS_ConfigCopyTable.LEVELING.EntityLevels[itemTable.cmd or "error"]
            elseif( type == "Shipment" and CustomShipments[v[1]] ) then
                itemTable = CustomShipments[v[1]]
                itemLevel = BS_ConfigCopyTable.LEVELING.ShipmentLevels[itemTable.name or "error"]
            elseif( type == "Ammo" and GAMEMODE.AmmoTypes[v[1]] ) then
                itemTable = GAMEMODE.AmmoTypes[v[1]]
                itemLevel = (BS_ConfigCopyTable.LEVELING.AmmoLevels or {})[itemTable.id]
            end

            if( itemTable ) then
                local itemBack = vgui.Create( "DPanel", shopPanel )
                itemBack:Dock( TOP )
                itemBack:DockMargin( 0, 0, 0, 5 )
                itemBack:SetTall( 100 )
                itemBack:DockPadding( 0, 0, 25, 0 )
                itemBack.Paint = function( self2, w, h )
                    draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
                    draw.RoundedBox( 5, 5, 5, h-10, h-10, BRICKS_SERVER.Func.GetTheme( 2 ) )

                    if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "levelling" ) and itemLevel ) then
                        draw.SimpleText( itemTable.name .. " - Level " .. itemLevel, "BRICKS_SERVER_Font33", h+15, 5, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
                    else
                        draw.SimpleText( itemTable.name, "BRICKS_SERVER_Font33", h+15, 5, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
                    end
                        
                    draw.SimpleText( DarkRP.formatMoney( itemTable.price ), "BRICKS_SERVER_Font20", h+18, 32, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
                end

                local itemIcon = vgui.Create( "SpawnIcon" , itemBack )
                itemIcon:SetPos( 5, 5 )
                itemIcon:SetSize( itemBack:GetTall()-10, itemBack:GetTall()-10 )
                if( istable( itemTable.model ) ) then
                    itemIcon:SetModel( itemTable.model[1] )
                else
                    itemIcon:SetModel( itemTable.model )
                end

                local itemButton = vgui.Create( "DPanel", itemBack )
                itemButton:Dock( LEFT )
                itemButton:SetWide( itemBack:GetTall() )
                itemButton.Paint = function( self2, w, h ) end

                for key2, val2 in pairs( itemActions ) do
                    local itemAction = vgui.Create( "DButton", itemBack )
                    itemAction:Dock( RIGHT )
                    itemAction:SetText( "" )
                    itemAction:DockMargin( 5, 25, 0, 25 )
                    surface.SetFont( "BRICKS_SERVER_Font25" )
                    local textX, textY = surface.GetTextSize( key2 )
                    textX = textX+20
                    itemAction:SetWide( math.max( (ScrW()/2560)*150, textX ) )
                    local changeAlpha = 0
                    itemAction.Paint = function( self2, w, h )
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
                
                        draw.SimpleText( key2, "BRICKS_SERVER_Font25", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                    end
                    itemAction.DoClick = function()
                        val2( k, v, type, itemTable )
                    end
                end
            end
        end
    end
    self.RefreshPanel()

    shopSearchBar.OnChange = function()
        self.RefreshPanel()
    end
end

function PANEL:Paint( w, h )
    
end

vgui.Register( "bricks_server_config_shop", PANEL, "DPanel" )