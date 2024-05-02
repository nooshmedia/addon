local PANEL = {}

function PANEL:Init()

end

function PANEL:FillPanel()
    local craftableActions = {
        [1] = { "Edit", function( k, v )
            BRICKS_SERVER.Func.CreateCraftingEditor( v, function( craftingTable ) 
                BS_ConfigCopyTable.CRAFTING.Craftables[k] = craftingTable
                BRICKS_SERVER.Func.ConfigChange( "CRAFTING" )
                self.RefreshPanel()
            end, function() end )
        end },
        [2] = { "Remove", function( k, v )
            BS_ConfigCopyTable.CRAFTING.Craftables[k] = nil
            BRICKS_SERVER.Func.ConfigChange( "CRAFTING" )
            self.RefreshPanel()
        end, BRICKS_SERVER.DEVCONFIG.BaseThemes.Red, BRICKS_SERVER.DEVCONFIG.BaseThemes.DarkRed },
    }

    local craftingSearchBarBack = vgui.Create( "DPanel", self )
    craftingSearchBarBack:Dock( TOP )
    craftingSearchBarBack:DockMargin( 0, 0, 0, 5 )
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

    function self.RefreshPanel()
        craftingPanel:Clear()

        for k, v in pairs( BS_ConfigCopyTable.CRAFTING.Craftables or {} ) do
            if( craftingSearchBar:GetValue() != "" and not string.find( string.lower( v.Name ), string.lower( craftingSearchBar:GetValue() ) ) ) then
                continue
            end

            local itemBack = vgui.Create( "DPanel", craftingPanel )
            itemBack:Dock( TOP )
            itemBack:DockMargin( 0, 0, 0, 5 )
            itemBack:SetTall( 100 )
            itemBack:DockPadding( 0, 0, 25, 0 )
            local resourceString = ""
            for key, val in pairs( v.Resources or {} ) do
                if( resourceString == "" ) then
                    resourceString = val .. " " .. key
                else
                    resourceString = resourceString .. ", " .. val .. " " .. key
                end
            end
            itemBack.Paint = function( self2, w, h )
                draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
                draw.RoundedBox( 5, 5, 5, h-10, h-10, BRICKS_SERVER.Func.GetTheme( 2 ) )

                if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "levelling" ) and v.Level ) then
                    draw.SimpleText( v.Name .. " - Level " .. v.Level, "BRICKS_SERVER_Font33", h+15, 5, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
                else
                    draw.SimpleText( v.Name, "BRICKS_SERVER_Font33", h+15, 5, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
                end

                if( v.CraftTime ) then
                    draw.SimpleText( "Time: " .. BRICKS_SERVER.Func.FormatTime( v.CraftTime ), "BRICKS_SERVER_Font20", h+15, 32, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
                    draw.SimpleText( resourceString, "BRICKS_SERVER_Font20", h+15, 47, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
                else
                    draw.SimpleText( resourceString, "BRICKS_SERVER_Font20", h+15, 32, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
                end
            end

            local itemIcon = vgui.Create( "DModelPanel" , itemBack )
            itemIcon:SetPos( 5, 5 )
            itemIcon:SetSize( itemBack:GetTall()-10, itemBack:GetTall()-10 )
            itemIcon:SetModel( v.Model or "models/props_junk/rock001a.mdl" )
            if( IsValid( itemIcon.Entity ) ) then
                function itemIcon:LayoutEntity( Entity ) return end
                local mn, mx = itemIcon.Entity:GetRenderBounds()
                local size = 0
                size = math.max( size, math.abs(mn.x) + math.abs(mx.x) )
                size = math.max( size, math.abs(mn.y) + math.abs(mx.y) )
                size = math.max( size, math.abs(mn.z) + math.abs(mx.z) )
        
                itemIcon:SetFOV( 50 )
                itemIcon:SetCamPos( Vector( size, size, size ) )
                itemIcon:SetLookAt( (mn + mx) * 0.5 )
            end
            if( v.Color ) then
                itemIcon:SetColor( v.Color )
            end

            for key2, val2 in ipairs( craftableActions ) do
                local itemAction = vgui.Create( "DButton", itemBack )
                itemAction:Dock( RIGHT )
                itemAction:SetText( "" )
                itemAction:DockMargin( 5, 25, 0, 25 )
                surface.SetFont( "BRICKS_SERVER_Font25" )
                local textX, textY = surface.GetTextSize( val2[1] )
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
                    
                    if( val2[3] ) then
                        draw.RoundedBox( 5, 0, 0, w, h, val2[3] )
                    else
                        draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
                    end
            
                    surface.SetAlphaMultiplier( changeAlpha/255 )
                        if( val2[4] ) then
                            draw.RoundedBox( 5, 0, 0, w, h, val2[4] )
                        else
                            draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
                        end
                    surface.SetAlphaMultiplier( 1 )
            
                    draw.SimpleText( val2[1], "BRICKS_SERVER_Font25", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                end
                itemAction.DoClick = function()
                    val2[2]( k, v )
                end
            end
        end

        local addNewCraftable = vgui.Create( "DButton", craftingPanel )
        addNewCraftable:Dock( TOP )
        addNewCraftable:SetText( "" )
        addNewCraftable:SetTall( 40 )
        local changeAlpha = 0
        addNewCraftable.Paint = function( self2, w, h )
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
    
            draw.SimpleText( "Add Craftable", "BRICKS_SERVER_Font25", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end
        addNewCraftable.DoClick = function()
            local newCraftableTable = {
                Name = "New item",
                Type = "Weapon",
                ReqInfo = {},
                Resources = {},
                Model = "models/weapons/w_rif_ak47.mdl",
                CraftTime = 0
            }

            for k, v in pairs( (BRICKS_SERVER.DEVCONFIG.CraftingTypes[newCraftableTable.Type] or {}).ReqInfo or {} ) do
                if( v[2] == "string" or v[2] == "table" ) then
                    newCraftableTable.ReqInfo[k] = "None"
                else
                    newCraftableTable.ReqInfo[k] = 0
                end
            end

            table.insert( BS_ConfigCopyTable.CRAFTING.Craftables, newCraftableTable )
            self.RefreshPanel()
            BRICKS_SERVER.Func.ConfigChange( "CRAFTING" )
        end
    end
    self.RefreshPanel()

    craftingSearchBar.OnChange = function()
        self.RefreshPanel()
    end
end

function PANEL:Paint( w, h )
    
end

vgui.Register( "bricks_server_config_crafting", PANEL, "DPanel" )