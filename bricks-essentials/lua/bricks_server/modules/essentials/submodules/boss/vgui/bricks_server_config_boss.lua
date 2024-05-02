local PANEL = {}

function PANEL:Init()

end

function PANEL:FillPanel()
    local itemActions = {
        [1] = { "Edit", function( k, v )
            BRICKS_SERVER.Func.CreateBossEditor( v, function( bossTable ) 
                BS_ConfigCopyTable.BOSS.NPCs[k] = bossTable
                BRICKS_SERVER.Func.ConfigChange( "BOSS" )
                self.RefreshPanel()
            end, function() end )
        end },
        [2] = { "Edit Rewards", function( k, v )
            BRICKS_SERVER.Func.CreateBossRewardEditor( v, function( bossTable ) 
                BS_ConfigCopyTable.BOSS.NPCs[k] = bossTable
                BRICKS_SERVER.Func.ConfigChange( "BOSS" )
                self.RefreshPanel()
            end, function() end )
        end },
        [3] = { "Remove", function( k, v )
            BS_ConfigCopyTable.BOSS.NPCs[k] = nil
            BRICKS_SERVER.Func.ConfigChange( "BOSS" )
            self.RefreshPanel()
        end, BRICKS_SERVER.DEVCONFIG.BaseThemes.Red, BRICKS_SERVER.DEVCONFIG.BaseThemes.DarkRed },
    }
    
    BS_ConfigCopyTable.BOSS = BS_ConfigCopyTable.BOSS or {}
    BS_ConfigCopyTable.BOSS.NPCs = BS_ConfigCopyTable.BOSS.NPCs or {}
    function self.RefreshPanel()
        self:Clear()

        self.slots = nil
        if( self.grid and IsValid( self.grid ) ) then
            self.grid:Remove()
        end

        BRICKS_SERVER.Func.FillVariableConfigs( self, "BOSS", "BOSS" )

        for k, v in pairs( BS_ConfigCopyTable.BOSS.NPCs or {} ) do
            local itemBack = vgui.Create( "DPanel", self )
            itemBack:Dock( TOP )
            itemBack:DockMargin( 0, 0, 0, 5 )
            itemBack:SetTall( 100 )
            itemBack:DockPadding( 0, 0, 25, 0 )
            itemBack.Paint = function( self2, w, h )
                draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
                draw.RoundedBox( 5, 5, 5, h-10, h-10, BRICKS_SERVER.Func.GetTheme( 2 ) )

                draw.SimpleText( v.Name, "BRICKS_SERVER_Font33", h+15, 5, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
                draw.SimpleText( BRICKS_SERVER.Func.formatHealth( v.Health ) .. " HP", "BRICKS_SERVER_Font20", h+15, 32, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
            end

            if( v.Model ) then
                local itemIcon = vgui.Create( "DModelPanel" , itemBack )
                itemIcon:SetPos( 5, 5 )
                itemIcon:SetSize( itemBack:GetTall()-10, itemBack:GetTall()-10 )
                itemIcon:SetModel( v.Model or "models/breen.mdl" )
                itemIcon:SetCamPos( itemIcon:GetCamPos()+Vector( 40, 0, 0 ) )
                if( IsValid( itemIcon.Entity ) ) then
                    function itemIcon:LayoutEntity(ent) return end
                    local mn, mx = itemIcon.Entity:GetRenderBounds()
                    local size = 0
                    size = math.max( size, math.abs(mn.x) + math.abs(mx.x) )
                    size = math.max( size, math.abs(mn.y) + math.abs(mx.y) )
                    size = math.max( size, math.abs(mn.z) + math.abs(mx.z) )
            
                    itemIcon:SetFOV( 40 )
                    itemIcon:SetCamPos( Vector( size, size, size ) )
                    itemIcon:SetLookAt( (mn + mx) * 0.5 )
                end
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

        local addNewBoss = vgui.Create( "DButton", self )
        addNewBoss:Dock( TOP )
        addNewBoss:SetText( "" )
        addNewBoss:SetTall( 40 )
        local changeAlpha = 0
        addNewBoss.Paint = function( self2, w, h )
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
    
            draw.SimpleText( "Add Boss", "BRICKS_SERVER_Font25", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end
        addNewBoss.DoClick = function()
            BS_ConfigCopyTable.BOSS.NPCs = BS_ConfigCopyTable.BOSS.NPCs or {}
            local newBoss = {
                Name = "NEW BOSS",
                Class = "npc_zombie",
                Health = 100,
                Scale = 1,
                DamageScale = 1,
                Loot = {}
            }
            table.insert( BS_ConfigCopyTable.BOSS.NPCs, newBoss )
            BRICKS_SERVER.Func.ConfigChange( "BOSS" )
            self.RefreshPanel()
        end
    end
    self.RefreshPanel()
end

function PANEL:Paint( w, h )
    
end

vgui.Register( "bricks_server_config_boss", PANEL, "bricks_server_scrollpanel" )