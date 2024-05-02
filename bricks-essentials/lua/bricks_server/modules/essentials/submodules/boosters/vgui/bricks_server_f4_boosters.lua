local PANEL = {}

function PANEL:Init()

end

function PANEL:FillPanel( f4Panel, sheetButton )
    if( not IsValid( f4Panel ) ) then return end

    local function fillBoosters()
        self:Clear()

        if( table.Count( BRS_BOOSTERS ) > 0 ) then
            for k, v in pairs( BRS_BOOSTERS ) do
                local boosterTable = BRICKS_SERVER.CONFIG.BOOSTERS[v[1]]
                if( not boosterTable ) then continue end

                local boosterBack = vgui.Create( "DPanel", self )
                boosterBack:Dock( TOP )
                boosterBack:SetTall( 100 )
                boosterBack:DockMargin( 0, 0, 0, 5 )
                boosterBack:DockPadding( 0, 0, 25, 5 )
                local boosterIcon
                BRICKS_SERVER.Func.GetImage( boosterTable.Icon or "", function( mat ) boosterIcon = mat end )
                local boosterBackW = 0
                local timeLeftLerp = boosterTable.Time
                if( v[3] ) then
                    timeLeftLerp = v[3]-BRICKS_SERVER.Func.GetServerTime()
                end
                boosterBack.Paint = function( self2, w, h )
                    if( boosterBackW != w ) then
                        boosterBackW = w
                    end

                    draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )

                    if( v[3] ) then
                        timeLeftLerp = Lerp( RealFrameTime()*2, timeLeftLerp, v[3]-BRICKS_SERVER.Func.GetServerTime() )
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
                        draw.SimpleText( "Time left: " .. BRICKS_SERVER.Func.FormatTime( math.max( 0, v[3]-BRICKS_SERVER.Func.GetServerTime() ) ), "BRICKS_SERVER_Font20", h+15, 32, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
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
                        net.Start( "BRS.Net.UseBooster" )
                            net.WriteUInt( k, 10 )
                        net.SendToServer()
                    else
                        BRICKS_SERVER.Func.Query( "Cancelling a booster will remove it, are you sure?", "Booster", "Confirm", "Cancel", function() 
                            net.Start( "BRS.Net.CancelBooster" )
                                net.WriteUInt( k, 10 )
                            net.SendToServer()
                        end )
                    end
                end

                local sameBoosterActive = false
                for key, val in pairs( BRS_BOOSTERS ) do
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
            local noBoosters = vgui.Create( "DButton", self )
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
        
                draw.SimpleText( "No boosters. Click here to buy more!", "BRICKS_SERVER_Font25", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            end
            noBoosters.DoClick = function()
                gui.OpenURL( BRICKS_SERVER.CONFIG.GENERAL["Donate Link"] or "ERROR" ) 
            end
        end
    end
    fillBoosters()

    hook.Add( "BRS.Hooks.FillBoosters", "BRS.BRS.Hooks.FillBoosters_F4", function()
        if( IsValid( self ) ) then
            fillBoosters()
        end
    end )
end

function PANEL:Paint( w, h )

end

vgui.Register( "bricks_server_f4_boosters", PANEL, "bricks_server_scrollpanel" )