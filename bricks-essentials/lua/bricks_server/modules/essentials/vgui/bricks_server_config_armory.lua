local PANEL = {}

function PANEL:Init()

end

function PANEL:FillPanel()
    local armoryActions = {
        [1] = { "Edit", function( k, v )
            BRICKS_SERVER.Func.CreateArmoryItemEditor( v, function( itemTable ) 
                BS_ConfigCopyTable.ARMORY.Items[k] = itemTable
                BRICKS_SERVER.Func.ConfigChange( "ARMORY" )
                self.RefreshPanel()
            end, function() end )
        end },
        [2] = { "Remove", function( k, v )
            BS_ConfigCopyTable.ARMORY.Items[k] = nil
            BRICKS_SERVER.Func.ConfigChange( "ARMORY" )
            self.RefreshPanel()
        end, BRICKS_SERVER.DEVCONFIG.BaseThemes.Red, BRICKS_SERVER.DEVCONFIG.BaseThemes.DarkRed },
    }

    BS_ConfigCopyTable.ARMORY = BS_ConfigCopyTable.ARMORY or {}
    function self.RefreshPanel()
        self:Clear()

        self.slots = nil
        if( self.grid and IsValid( self.grid ) ) then
            self.grid:Remove()
        end

        local teamRobberCount = table.Count( (BS_ConfigCopyTable or BRICKS_SERVER.CONFIG).ARMORY.RobberTeams )
        local teamPoliceCount = table.Count( (BS_ConfigCopyTable or BRICKS_SERVER.CONFIG).ARMORY.PoliceJobs )
        local shipmentCount = table.Count( BS_ConfigCopyTable.ARMORY.RewardShipments or {} )
        local amount1, amount2 = (((BS_ConfigCopyTable or BRICKS_SERVER.CONFIG).ARMORY["Reward Money"] or {})[1] or 0), (((BS_ConfigCopyTable or BRICKS_SERVER.CONFIG).ARMORY["Reward Money"] or {})[2] or 0)
        local shipAmount1, shipAmount2 = (((BS_ConfigCopyTable or BRICKS_SERVER.CONFIG).ARMORY["Shipment Reward Amount"] or {})[1] or 0), (((BS_ConfigCopyTable or BRICKS_SERVER.CONFIG).ARMORY["Shipment Reward Amount"] or {})[2] or 0)
        BRICKS_SERVER.Func.FillVariableConfigs( self, "ARMORY", "ARMORY", {
            ["RobberTeams"] = { function()
                BRICKS_SERVER.Func.CreateTeamSelector( (BS_ConfigCopyTable.ARMORY.RobberTeams or {}), "Select the teams which can rob the armory below.", function( teamTable ) 
                    BS_ConfigCopyTable.ARMORY.RobberTeams = teamTable
                    BRICKS_SERVER.Func.ConfigChange( "ARMORY" )
                    self.RefreshPanel()
                end, function() end )
            end, teamRobberCount .. " Robber " .. ((teamRobberCount != 1 and "Teams") or "Team"), "Edit Robber Teams" },
            ["PoliceJobs"] = { function()
                BRICKS_SERVER.Func.CreateTeamSelector( (BS_ConfigCopyTable.ARMORY.PoliceJobs or {}), "Select the teams which can access the armory below.", function( teamTable ) 
                    BS_ConfigCopyTable.ARMORY.PoliceJobs = teamTable
                    BRICKS_SERVER.Func.ConfigChange( "ARMORY" )
                    self.RefreshPanel()
                end, function() end )
            end, teamPoliceCount .. " Police " .. ((teamPoliceCount != 1 and "Teams") or "Team"), "Edit Police Teams" },
            ["RewardShipments"] = { function()
                BRICKS_SERVER.Func.CreateShipmentSelector( (BS_ConfigCopyTable.ARMORY.RewardShipments or {}), "Select the shipments which can spawn from the armory after a robbery.", function( shipmentsTable ) 
                    BS_ConfigCopyTable.ARMORY.RewardShipments = shipmentsTable
                    BRICKS_SERVER.Func.ConfigChange( "ARMORY" )
                    self.RefreshPanel()
                end, function() end )
            end, shipmentCount .. " " .. ((shipmentCount != 1 and "Shipments") or "Shipment"), "Edit Reward Shipments" },
            ["Reward Money"] = { function()
                BRICKS_SERVER.Func.StringRequest( "Admin", "What should the minimum money reward be?", amount1, function( number1 ) 
                    BRICKS_SERVER.Func.StringRequest( "Admin", "What should the maximum money reward be?", amount2, function( number2 ) 
                        BS_ConfigCopyTable.ARMORY["Reward Money"] = { (number1 or 0), (number2 or 0) }
                        BRICKS_SERVER.Func.ConfigChange( "ARMORY" )
                        self.RefreshPanel()
                    end, function() end, "OK", "Cancel", true )
                end, function() end, "OK", "Cancel", true )
            end, DarkRP.formatMoney( amount1 ) .. " - " .. DarkRP.formatMoney( amount2 ), "Reward Money" },
            ["Shipment Reward Amount"] = { function()
                BRICKS_SERVER.Func.StringRequest( "Admin", "What should the min amount of shipments be?", shipAmount1, function( number1 ) 
                    BRICKS_SERVER.Func.StringRequest( "Admin", "What should the max amount of shipments be?", shipAmount2, function( number2 ) 
                        BS_ConfigCopyTable.ARMORY["Shipment Reward Amount"] = { (number1 or 0), (number2 or 0) }
                        BRICKS_SERVER.Func.ConfigChange( "ARMORY" )
                        self.RefreshPanel()
                    end, function() end, "OK", "Cancel", true )
                end, function() end, "OK", "Cancel", true )
            end, shipAmount1 .. " to " .. shipAmount2 .. " Shipments", "Shipment Reward Amount" }
        } )

        for k, v in pairs( BS_ConfigCopyTable.ARMORY.Items or {} ) do
            local displayInfo = { "Level" }

            local itemBack = vgui.Create( "DPanel", self )
            itemBack:Dock( TOP )
            itemBack:DockMargin( 0, 0, 0, 5 )
            itemBack:SetTall( 100 )
            itemBack:DockPadding( 0, 0, 25, 0 )
            itemBack.Paint = function( self2, w, h )
                draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
                draw.RoundedBox( 5, 5, 5, h-10, h-10, BRICKS_SERVER.Func.GetTheme( 2 ) )
    
                draw.SimpleText( v.Name, "BRICKS_SERVER_Font33", h+15, 5, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
    
                for i = 1, #displayInfo do
                    if( not displayInfo[i] ) then continue end
    
                    draw.SimpleText( displayInfo[i] .. ": " .. (v[displayInfo[i]] or 0), "BRICKS_SERVER_Font20", h+15, 32+((i-1)*15), BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
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
    
            for key2, val2 in ipairs( armoryActions ) do
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
    
        local bottomButton = vgui.Create( "DButton", self )
        bottomButton:Dock( TOP )
        bottomButton:SetText( "" )
        bottomButton:SetTall( 40 )
        local changeAlpha = 0
        bottomButton.Paint = function( self2, w, h )
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
    
            draw.SimpleText( "Add new item", "BRICKS_SERVER_Font25", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end
        bottomButton.DoClick = function()
            local newItemTable = {
                Name = "New Item",
                Category = "Weapons",
                Type = "Weapon",
                ReqInfo = { "weapon_ak472" },
                Model = "models/weapons/w_rif_ak47.mdl"
            }

            table.insert( BS_ConfigCopyTable.ARMORY.Items, newItemTable )
            self.RefreshPanel()
            BRICKS_SERVER.Func.ConfigChange( "ARMORY" )
        end
    end
    self.RefreshPanel()
end

function PANEL:Paint( w, h )
    
end

vgui.Register( "bricks_server_config_armory", PANEL, "bricks_server_scrollpanel" )