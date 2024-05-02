local PANEL = {}

function PANEL:Init()

end

function PANEL:FillPanel()
    local itemActions = {
        [1] = { "Edit", function( k, v )
            BRICKS_SERVER.Func.CreateBoosterEditor( v, function( boosterTable ) 
                BS_ConfigCopyTable.BOOSTERS[k] = boosterTable
                BRICKS_SERVER.Func.ConfigChange( "BOOSTERS" )
                self.RefreshPanel()
            end, function() end )
        end },
        [2] = { "Remove", function( k, v )
            BS_ConfigCopyTable.BOOSTERS[k] = nil
            BRICKS_SERVER.Func.ConfigChange( "BOOSTERS" )
            self.RefreshPanel()
        end, BRICKS_SERVER.DEVCONFIG.BaseThemes.Red, BRICKS_SERVER.DEVCONFIG.BaseThemes.DarkRed },
    }

    function self.RefreshPanel()
        self:Clear()

        self.slots = nil
        if( self.grid and IsValid( self.grid ) ) then
            self.grid:Remove()
        end

        for k, v in pairs( BS_ConfigCopyTable.BOOSTERS or {} ) do
            local itemBack = vgui.Create( "DPanel", self )
            itemBack:Dock( TOP )
            itemBack:DockMargin( 0, 0, 0, 5 )
            itemBack:SetTall( 100 )
            itemBack:DockPadding( 0, 0, 25, 0 )
            local boosterIcon
            BRICKS_SERVER.Func.GetImage( v.Icon or "", function( mat ) boosterIcon = mat end )
            itemBack.Paint = function( self2, w, h )
                draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
                draw.RoundedBox( 5, 5, 5, h-10, h-10, BRICKS_SERVER.Func.GetTheme( 2 ) )

                if( boosterIcon ) then
                    surface.SetDrawColor( 255, 255, 255, 255 )
                    surface.SetMaterial( boosterIcon )
                    local size = 64
                    surface.DrawTexturedRect( (h-size)/2, (h-size)/2, size, size )
                end

                draw.SimpleText( v.Title, "BRICKS_SERVER_Font33", h+15, 5, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
                draw.SimpleText( "Multiplier: " .. (v.Multiplier or 1), "BRICKS_SERVER_Font20", h+18, 32, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
                draw.SimpleText( "Duration: " .. BRICKS_SERVER.Func.FormatTime( v.Time or 0 ), "BRICKS_SERVER_Font20", h+18, 52, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
            end

            for key2, val2 in ipairs( itemActions ) do
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

        local addNewBooster = vgui.Create( "DButton", self )
        addNewBooster:Dock( TOP )
        addNewBooster:SetText( "" )
        addNewBooster:DockMargin( 0, 0, 0, 5 )
        addNewBooster:SetTall( 40 )
        local changeAlpha = 0
        addNewBooster.Paint = function( self2, w, h )
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
    
            draw.SimpleText( "Add Booster", "BRICKS_SERVER_Font25", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end
        addNewBooster.DoClick = function()
            local newBooster = {
                Title = "New Booster",
                Type = 1,
                Multiplier = 2,
                Time = 60
            }

            table.insert( BS_ConfigCopyTable.BOOSTERS, newBooster )
            BRICKS_SERVER.Func.ConfigChange( "BOOSTERS" )
            self.RefreshPanel()
        end
    end
    self.RefreshPanel()
end

function PANEL:Paint( w, h )
    
end

vgui.Register( "bricks_server_config_boosters", PANEL, "bricks_server_scrollpanel" )