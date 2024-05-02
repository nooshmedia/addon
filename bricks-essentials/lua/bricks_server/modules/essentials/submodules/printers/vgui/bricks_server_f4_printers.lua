local PANEL = {}

function PANEL:Init()

end

function PANEL:FillPanel( f4Panel, sheetButton )
    if( not IsValid( f4Panel ) ) then return end

    local panelWide = ScrW()*0.6-BRICKS_SERVER.DEVCONFIG.MainNavWidth

    local spacing = 5
    local gridWide = panelWide-20
    local slotsWide = 2
    local slotWide = (gridWide-((slotsWide-1)*spacing))/slotsWide
    local slotTall = 100

    local printerGrid = vgui.Create( "DIconLayout", self )
    printerGrid:Dock( TOP )
    printerGrid:SetTall( slotTall )
    printerGrid:SetSpaceY( spacing )
    printerGrid:SetSpaceX( spacing )

    local function fillPrinters()
        sheetButton.notifications = 0
        printerGrid:Clear()

        local printerSlots = 0

        for k, v in ipairs( BRICKS_SERVER.CONFIG.PRINTERS.PrinterSlots ) do
            printerSlots = (printerSlots or 0)+1
            local slots = printerSlots
            local slotsTall = math.ceil( slots/slotsWide )
            printerGrid:SetTall( (slotsTall*slotTall)+((slotsTall-1)*spacing) )
            
            local unlocked = false
            local printerTable = {}
            if( BRS_PRINTERS and BRS_PRINTERS[k] and BRS_PRINTERS[k][1] == true ) then
                unlocked = true
                printerTable = BRICKS_SERVER.CONFIG.PRINTERS.Tiers[(BRS_PRINTERS[k][2] or 1)] or {}
            end

            local canUnLock = true
            if( not unlocked ) then
                if( v.Level and BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "levelling" ) ) then
                    if( BRS_LEVEL < v.Level ) then
                        canUnLock = false
                    end
                end

                if( canUnLock and v.Group ) then
                    if( not BRICKS_SERVER.Func.IsInGroup( LocalPlayer(), v.Group ) ) then
                        canUnLock = false
                    end
                end

                if( canUnLock ) then
                    sheetButton.notifications = (sheetButton.notifications or 0)+1
                end
            end

            local printerBack = printerGrid:Add( "DPanel" )
            printerBack:SetSize( slotWide, slotTall )
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
                    draw.SimpleText( "Tier: " .. (printerTable.Name or "None"), "BRICKS_SERVER_Font20", h+15, 32, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
                    draw.SimpleText( "Level: " .. (BRS_PRINTERS[k][3] or 1), "BRICKS_SERVER_Font20", h+15, 47, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
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
            function printerModel:LayoutEntity( Entity ) return end

            if( IsValid( printerModel.Entity ) ) then
                local mn, mx = printerModel.Entity:GetRenderBounds()
                local size = 0
                size = math.max( size, math.abs(mn.x) + math.abs(mx.x) )
                size = math.max( size, math.abs(mn.y) + math.abs(mx.y) )
                size = math.max( size, math.abs(mn.z) + math.abs(mx.z) )

                printerModel:SetFOV( 60 )
                printerModel:SetCamPos( Vector( size, size, size ) )
                printerModel:SetLookAt( (mn + mx) * 0.5 )
            end

            local printerActions = {
                [1] = { "Place", function( ply, slotID )
                    net.Start( "BRS.Net.PlacePrinter" )
                        net.WriteUInt( slotID, 8 )
                    net.SendToServer()
                end },
            }

            if( unlocked and (BRS_PRINTERS[k][2] or 1) < #BRICKS_SERVER.CONFIG.PRINTERS.Tiers ) then
                printerActions[2] = { "Upgrade", function( ply, slotID )
                    net.Start( "BRS.Net.PrinterUpgrade" )
                        net.WriteUInt( slotID, 8 )
                    net.SendToServer()
                end, ((BRICKS_SERVER.CONFIG.PRINTERS.Tiers[(BRS_PRINTERS[k][2] or 1)+1] or {}).UpgradeCost or 0) }
            end

            if( unlocked ) then
                for key, val in ipairs( printerActions ) do
                    local printerAction = vgui.Create( "DButton", printerBack )
                    printerAction:Dock( RIGHT )
                    printerAction:SetText( "" )
                    printerAction:DockMargin( 5, 25, 0, 25 )
                    surface.SetFont( "BRICKS_SERVER_Font25" )
                    local textX, textY = surface.GetTextSize( (val[1] or "ERROR") )
                    surface.SetFont( "BRICKS_SERVER_Font20" )
                    local text2X, text2Y = surface.GetTextSize( DarkRP.formatMoney( val[3] or 0 ) )
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
                    
                        if( not val[3] ) then
                            draw.SimpleText( (val[1] or "ERROR"), "BRICKS_SERVER_Font25", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                        else
                            draw.SimpleText( (val[1] or "ERROR"), "BRICKS_SERVER_Font25", w/2, (h/2)-(textTall/2), BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, 0 )
                            draw.SimpleText( DarkRP.formatMoney( val[3] or 0 ), "BRICKS_SERVER_Font20", w/2, (h/2)-(textTall/2)+textY-5, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, 0 )
                        end
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

                    if( v.Price ) then
                        draw.SimpleText( "Unlock", "BRICKS_SERVER_Font25", w/2, (h/2)-(textTall/2), BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, 0 )
                        draw.SimpleText( DarkRP.formatMoney( v.Price ), "BRICKS_SERVER_Font20", w/2, (h/2)-(textTall/2)+textY-5, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, 0 )
                    else
                        draw.SimpleText( "Unlock", "BRICKS_SERVER_Font25", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                    end
                end
                printerAction.DoClick = function()
                    if( BRS_PRINTERS and BRS_PRINTERS[k] and BRS_PRINTERS[k][1] == true ) then
                        notification.AddLegacy( "You already have this slot unlocked!", 1, 5 )
                        return
                    end
        
                    net.Start( "BRS.Net.UnlockPrinter" )
                        net.WriteUInt( k, 8 )
                    net.SendToServer()
                end
            end

            if( not canUnLock or (BRS_PRINTERS[k] and BRS_PRINTERS[k][5] and BRS_PRINTERS[k][5] > os.time()) ) then
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

                    if( BRS_PRINTERS[k] and BRS_PRINTERS[k][1] == true and BRS_PRINTERS[k][5] and BRS_PRINTERS[k][5] > os.time() ) then
                        draw.SimpleText( "DESTROYED - On cooldown for " .. BRICKS_SERVER.Func.FormatTime( math.max( 0, math.Round( BRS_PRINTERS[k][5]-os.time() ) ) ), "BRICKS_SERVER_HUDFontS", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                        return
                    end

                    if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "levelling" ) and v.Level ) then
                        if( BRS_LEVEL < v.Level ) then
                            draw.SimpleText( "LOCKED - Level " .. v.Level, "BRICKS_SERVER_HUDFontS", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                            return
                        end
                    end

                    if( v.Group ) then
                        if( not BRICKS_SERVER.Func.IsInGroup( LocalPlayer(), v.Group ) ) then
                            draw.SimpleText( "LOCKED - " .. v.Group, "BRICKS_SERVER_HUDFontS", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                            return
                        end
                    end

                    printerCover:Remove()
                end
            end
        end
    end
    fillPrinters()

    hook.Add( "BRS.Hooks.FillPrinters", "BRS.Hooks.FillPrinters_F4", function()
        if( IsValid( self ) ) then
            fillPrinters()
        end
    end )
end

function PANEL:Paint( w, h )

end

vgui.Register( "bricks_server_f4_printers", PANEL, "bricks_server_scrollpanel" )