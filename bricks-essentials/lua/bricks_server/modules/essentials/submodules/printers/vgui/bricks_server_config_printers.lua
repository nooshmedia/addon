local PANEL = {}

function PANEL:Init()

end

function PANEL:FillPanel()
    local itemActions = {
        [1] = { "Remove", function( k, v )
            if( #BS_ConfigCopyTable.PRINTERS.Tiers > 1 ) then
                table.remove( BS_ConfigCopyTable.PRINTERS.Tiers, k )
                BRICKS_SERVER.Func.ConfigChange( "PRINTERS" )
                self.RefreshPanel()
            else
                BRICKS_SERVER.Func.Message( "You cannot remove the only tier.", "Admin", "Sorry :(" )
            end
        end, BRICKS_SERVER.DEVCONFIG.BaseThemes.Red, BRICKS_SERVER.DEVCONFIG.BaseThemes.DarkRed },
        [2] = { "Edit", function( k, v )
            BRICKS_SERVER.Func.CreatePrinterEditor( v, function( printerTable ) 
                BS_ConfigCopyTable.PRINTERS.Tiers[k] = printerTable
                BRICKS_SERVER.Func.ConfigChange( "PRINTERS" )
                self.RefreshPanel()
            end, function() end )
        end },
    }

    function self.RefreshPanel()
        self:Clear()

        self.slots = nil
        if( self.grid and IsValid( self.grid ) ) then
            self.grid:Remove()
        end

        BRICKS_SERVER.Func.FillVariableConfigs( self, "PRINTERS", "PRINTERS", { ["Printer Slots"] = { function()
            BRICKS_SERVER.Func.CreatePrinterSlotEditor( function( slotTable ) 
                BS_ConfigCopyTable.PRINTERS.PrinterSlots = slotTable
                BRICKS_SERVER.Func.ConfigChange( "PRINTERS" )
                self.RefreshPanel()
            end, function() end )
        end, #(BS_ConfigCopyTable or BRICKS_SERVER.CONFIG).PRINTERS.PrinterSlots .. " Available Slots" } } )

        for k, v in pairs( (BS_ConfigCopyTable or BRICKS_SERVER.CONFIG).PRINTERS.Tiers ) do
            local itemBack = vgui.Create( "DPanel", self )
            itemBack:Dock( TOP )
            itemBack:DockMargin( 0, 0, 0, 5 )
            itemBack:SetTall( 100 )
            itemBack:DockPadding( 0, 0, 25, 0 )
            itemBack.Paint = function( self2, w, h )
                draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
                draw.RoundedBox( 5, 5, 5, h-10, h-10, BRICKS_SERVER.Func.GetTheme( 2 ) )

                draw.SimpleText( "Tier - " .. v.Name, "BRICKS_SERVER_Font33", h+15, 5, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
                draw.SimpleText( "Storage: " .. DarkRP.formatMoney( v.MoneyStorage ), "BRICKS_SERVER_Font20", h+18, 32, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
                draw.SimpleText( "Amount: " .. DarkRP.formatMoney( v.PrintAmount ), "BRICKS_SERVER_Font20", h+18, 52, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
                draw.SimpleText( "Speed: " .. v.PrintSpeed, "BRICKS_SERVER_Font20", h+18, 72, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
            end

            local itemIcon = vgui.Create( "DModelPanel" , itemBack )
            itemIcon:SetPos( 5, 5 )
            itemIcon:SetSize( itemBack:GetTall()-10, itemBack:GetTall()-10 )
            itemIcon:SetModel( "models/2rek/brickwall/bwall_printer.mdl" )
            itemIcon:SetColor( v.ModelColor or Color( 255, 255, 255 ) )
            if( IsValid( itemIcon.Entity ) ) then
                function itemIcon:LayoutEntity( Entity ) return end

                local mn, mx = itemIcon.Entity:GetRenderBounds()
                local size = 0
                size = math.max( size, math.abs(mn.x) + math.abs(mx.x) )
                size = math.max( size, math.abs(mn.y) + math.abs(mx.y) )
                size = math.max( size, math.abs(mn.z) + math.abs(mx.z) )

                itemIcon:SetFOV( 60 )
                itemIcon:SetCamPos( Vector( size, size, size ) )
                itemIcon:SetLookAt( (mn + mx) * 0.5 )
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

        local addNewPrinter = vgui.Create( "DButton", self )
        addNewPrinter:Dock( TOP )
        addNewPrinter:SetText( "" )
        addNewPrinter:DockMargin( 0, 0, 0, 5 )
        addNewPrinter:SetTall( 40 )
        local changeAlpha = 0
        addNewPrinter.Paint = function( self2, w, h )
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
    
            draw.SimpleText( "Add new tier", "BRICKS_SERVER_Font25", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end
        addNewPrinter.DoClick = function()
            local newPrinter = {
                Name = "New",
                ModelColor = Color( 255, 255, 255 ),
                ScreenColor = Color( 192, 192, 192 ),
                Health = 150,
                MaxInk = 150,
                PrintAmount = 100,
                MoneyStorage = 1500,
                PrintSpeed = 1
            }

            table.insert( BS_ConfigCopyTable.PRINTERS.Tiers, newPrinter )
            BRICKS_SERVER.Func.ConfigChange( "PRINTERS" )
            self.RefreshPanel()
        end
    end
    self.RefreshPanel()
end

function PANEL:Paint( w, h )
    
end

vgui.Register( "bricks_server_config_printers", PANEL, "bricks_server_scrollpanel" )