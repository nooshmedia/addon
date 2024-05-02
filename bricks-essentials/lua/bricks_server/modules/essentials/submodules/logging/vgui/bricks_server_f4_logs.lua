local PANEL = {}

function PANEL:Init()

end

function PANEL:FillPanel( f4Panel, sheetButton )
    if( not IsValid( f4Panel ) ) then return end

    function f4Panel.FillLogs()
        self:Clear()

        local logsRequest = vgui.Create( "DButton", self )
        logsRequest:Dock( TOP )
        logsRequest:DockMargin( 0, 0, 0, 5 )
        logsRequest:SetTall( 65 )
        logsRequest:DockPadding( 0, 0, 30, 0 )
        logsRequest:SetText( "" )
        local changeAlpha = 0
        logsRequest.Paint = function( self2, w, h ) 
            draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )

            draw.SimpleText( "Refresh logs", "BRICKS_SERVER_Font33", 15, 5, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
            draw.SimpleText( (#(BRS_LOGS or {}) or 0) .. " logs", "BRICKS_SERVER_Font20", 18, 32, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )

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
        logsRequest.DoClick = function()
            net.Start( "BRS.Net.RequestLogs" )
            net.SendToServer()
        end

        local sortedLogs = table.Copy( BRS_LOGS or {} )
        table.sort( sortedLogs, function(a, b) return a[1] > b[1] end )

        for k, v in pairs( sortedLogs or {} ) do
            if( not BRICKS_SERVER.DEVCONFIG.LogTypes[v[2] or ""] ) then continue end

            local entryBack = vgui.Create( "DPanel", self )
            entryBack:Dock( TOP )
            entryBack:DockMargin( 0, 0, 0, 5 )
            entryBack:SetTall( 65 )
            entryBack:DockPadding( 0, 0, 30, 0 )
            local dateTime = os.date( "%H:%M:%S - %d/%m/%Y" , v[1] )
            local text = ""
            if( BRICKS_SERVER.DEVCONFIG.LogTypes[v[2] or ""].FormatInfo ) then
                text = BRICKS_SERVER.DEVCONFIG.LogTypes[v[2] or ""].FormatInfo( v[3] )
            end
            entryBack.Paint = function( self2, w, h )
                draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )

                draw.SimpleText( dateTime, "BRICKS_SERVER_Font33", 15, 5, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
                draw.SimpleText( text, "BRICKS_SERVER_Font20", 18, 32, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
            end
        end
    end
    f4Panel.FillLogs()
end

function PANEL:Paint( w, h )

end

vgui.Register( "bricks_server_f4_logs", PANEL, "bricks_server_scrollpanel" )