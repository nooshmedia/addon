local PANEL = {}

function PANEL:Init()
    self:SetPos( 20, 20 )
    self:SetSize( 200, 250 )
end

function PANEL:Refresh( BossEntity )
    if( not BossEntity or not IsValid( BossEntity ) ) then return end

    local bossTable = BRICKS_SERVER.CONFIG.BOSS.NPCs[BossEntity:GetNW2Int( "BRICKS_SERVER_BOSS_KEY" )]

    if( not bossTable ) then return end

    local damageTable = BRICKS_SERVER.TEMP.BOSS_DAMAGE[BossEntity]

    if( not damageTable ) then return end

    self:Clear()

    local lineBreak = vgui.Create( "DPanel", self )
    lineBreak:Dock( TOP )
    lineBreak:DockMargin( 5, 35, 5, 5 )
    lineBreak:SetTall( 5 )
    lineBreak.Paint = function( self2, w, h )
        draw.RoundedBox( 3, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
    end

    local doneLocalPly = false
    for i = 1, 5 do
        if( damageTable[i] ) then
            local playerEntry = vgui.Create( "DPanel", self )
            playerEntry:Dock( TOP )
            playerEntry:DockMargin( 5, 5, 5, 0 )
            playerEntry:SetTall( 20 )
            local name = "NIL"
            if( IsValid( damageTable[i][2] ) and damageTable[i][2]:IsPlayer() ) then
                name = damageTable[i][2]:Nick()

                if( damageTable[i][2] == LocalPlayer() ) then
                    doneLocalPly = true
                end
            end
            local text = string.sub( name or "NIL", 1, 20 ) .. " - " .. BRICKS_SERVER.Func.formatHealth( damageTable[i][1] )
            playerEntry.Paint = function( self2, w, h )
                draw.SimpleText( i .. ". " .. text, "BRICKS_SERVER_Font20", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            end
        else
            break
        end
    end

    if( not doneLocalPly and #damageTable > 5 ) then
        local playerKey
        local playerTable
        for k, v in pairs( damageTable ) do
            if( k <= 5 ) then continue end

            if( IsValid( v[2] ) and v[2]:IsPlayer() and v[2] == LocalPlayer() ) then
                playerKey = k
                playerTable = v
                break
            end
        end

        if( playerKey and playerTable ) then
            local playerEntry = vgui.Create( "DPanel", self )
            playerEntry:Dock( TOP )
            playerEntry:DockMargin( 5, 5, 5, 0 )
            playerEntry:SetTall( 20 )
            local text = string.sub( LocalPlayer():Nick() or "NIL", 1, 20 ) .. " - " .. BRICKS_SERVER.Func.formatHealth( playerTable[1] )
            playerEntry.Paint = function( self2, w, h )
                draw.SimpleText( playerKey .. ". " .. text, "BRICKS_SERVER_Font20", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            end
        end
    end
end

function PANEL:Paint( w, h )
    draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )

    draw.SimpleText( "BOSS DAMAGE", "BRICKS_SERVER_HUDFontS", w/2, 5, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, 0 )
end

vgui.Register( "bricks_server_boss_board", PANEL, "DPanel" )