local PANEL = {}

function PANEL:Init()

end

function PANEL:FillPanel()
    local itemActions = {
        [1] = { "Edit", function( k, v )
            BRICKS_SERVER.Func.CreateResourceEditor( v, function( resourceTable ) 
                BS_ConfigCopyTable.CRAFTING.Resources[k] = resourceTable
                BRICKS_SERVER.Func.ConfigChange( "CRAFTING" )
                self.RefreshPanel()
            end, function() end )
        end },
        [2] = { "Remove", function( k, v )
            BS_ConfigCopyTable.CRAFTING.Resources[k] = nil
            BRICKS_SERVER.Func.ConfigChange( "CRAFTING" )
            self.RefreshPanel()
        end, BRICKS_SERVER.DEVCONFIG.BaseThemes.Red, BRICKS_SERVER.DEVCONFIG.BaseThemes.DarkRed },
    }

    function self.RefreshPanel()
        self:Clear()

        self.slots = nil
        if( self.grid and IsValid( self.grid ) ) then
            self.grid:Remove()
        end

        BRICKS_SERVER.Func.FillVariableConfigs( self, "CRAFTING", "CRAFTING" )

        for k, v in pairs( BS_ConfigCopyTable.CRAFTING.Resources or {} ) do
            local itemBack = vgui.Create( "DPanel", self )
            itemBack:Dock( TOP )
            itemBack:DockMargin( 0, 0, 0, 5 )
            itemBack:SetTall( 100 )
            itemBack:DockPadding( 0, 0, 25, 0 )
            itemBack.Paint = function( self2, w, h )
                draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
                draw.RoundedBox( 5, 5, 5, h-10, h-10, BRICKS_SERVER.Func.GetTheme( 2 ) )

                draw.SimpleText( k, "BRICKS_SERVER_Font33", h+15, 5, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
            end

            local itemIcon = vgui.Create( "DModelPanel" , itemBack )
            itemIcon:SetPos( 5, 5 )
            itemIcon:SetSize( itemBack:GetTall()-10, itemBack:GetTall()-10 )
            itemIcon:SetModel( v[1] or "models/props_junk/rock001a.mdl" )
            itemIcon:SetCamPos( itemIcon:GetCamPos()+Vector( 40, 0, 0 ) )
            itemIcon:SetColor( v[2] or Color( 255, 255, 255 ) )
            itemIcon:SetFOV( 50 )
            function itemIcon:LayoutEntity( Entity ) return end
            itemIcon:SetCamPos( Vector( 0, 50, 5 ) )
            itemIcon:SetLookAng( Angle( 180, 90, 180 ) )

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

        local addNewResource = vgui.Create( "DButton", self )
        addNewResource:Dock( TOP )
        addNewResource:SetText( "" )
        addNewResource:SetTall( 40 )
        local changeAlpha = 0
        addNewResource.Paint = function( self2, w, h )
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
    
            draw.SimpleText( "Add Resource", "BRICKS_SERVER_Font25", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end
        addNewResource.DoClick = function()
            BRICKS_SERVER.Func.StringRequest( "Admin", "What should name of this resource be?", "New Resource " .. ((table.Count( BS_ConfigCopyTable.CRAFTING.Resources ) or 0)+1), function( text ) 
                if( not BS_ConfigCopyTable.CRAFTING.Resources[text] ) then
                    BS_ConfigCopyTable.CRAFTING.Resources[text] = { "models/props_junk/rock001a.mdl" }
                    BRICKS_SERVER.Func.ConfigChange( "CRAFTING" )
                    self.RefreshPanel()

                    local entityClass = "bricks_server_resource_" .. string.Replace( string.lower( text ), " ", "" )
                    if( not (BS_ConfigCopyTable.INVENTORY.Whitelist or {})[entityClass] ) then
                        if( not BS_ConfigCopyTable.INVENTORY.Whitelist ) then
                            BS_ConfigCopyTable.INVENTORY.Whitelist = {}
                        end

                        BS_ConfigCopyTable.INVENTORY.Whitelist[entityClass] = { false, true }
                        BRICKS_SERVER.Func.ConfigChange( "INVENTORY" )
                    end
                else
                    BRICKS_SERVER.Func.Message( "A resource with this name already exists!", "Admin", "OK" )
                end
            end, function() end, "OK", "Cancel" )
        end

        local lineBreak = vgui.Create( "DPanel", self )
        lineBreak:Dock( TOP )
        lineBreak:DockMargin( 5, 20, 5, 20 )
        lineBreak:SetTall( 5 )
        lineBreak.Paint = function( self2, w, h )
            draw.RoundedBox( 3, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
        end

        local rockTypeHeader = vgui.Create( "DButton", self )
        rockTypeHeader:Dock( TOP )
        rockTypeHeader:DockMargin( 0, 0, 0, 5 )
        rockTypeHeader:SetText( "" )
        rockTypeHeader:SetTall( 40 )
        local changeAlpha = 0
        rockTypeHeader.Paint = function( self2, w, h )
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
    
            draw.SimpleText( "Mineable resources", "BRICKS_SERVER_Font25", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end
        rockTypeHeader.DoClick = function()
            BRICKS_SERVER.Func.Message( "Below are the resources available from mining.", "Admin", "OK" )
        end

        for k, v in pairs( BS_ConfigCopyTable.CRAFTING.RockTypes or {} ) do
            local variableBack = vgui.Create( "DPanel", self )
            variableBack:Dock( TOP )
            variableBack:DockMargin( 0, 0, 0, 5 )
            variableBack:SetTall( 65 )
            variableBack:DockPadding( 0, 0, 30, 0 )
            variableBack.Paint = function( self2, w, h )
                draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )

                draw.SimpleText( k, "BRICKS_SERVER_Font33", 15, 5, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
                draw.SimpleText( (BS_ConfigCopyTable.CRAFTING.RockTypes[k] or 0) .. "%", "BRICKS_SERVER_Font20", 18, 32, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
            end

            local variableAction = vgui.Create( "DButton", variableBack )
            variableAction:SetPos( 0, 0 )
            variableAction:SetSize( (ScrW()*0.6)-BRICKS_SERVER.DEVCONFIG.MainNavWidth-20, variableBack:GetTall() )
            variableAction:SetText( "" )
            local changeAlpha = 0
            variableAction.Paint = function( self2, w, h ) 
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
            variableAction.DoClick = function()
                BRICKS_SERVER.Func.StringRequest( "Admin", "What should the chance to get this resource be?", v or 0, function( number ) 
                    BS_ConfigCopyTable.CRAFTING.RockTypes[k] = number
                    BRICKS_SERVER.Func.ConfigChange( "CRAFTING" )
                end, function() end, "OK", "Cancel", true )
            end

            local variableRemove = vgui.Create( "DButton", variableAction )
            local border = 12.5
            variableRemove:Dock( RIGHT ) -- size 40
            variableRemove:DockMargin( 0, border, border, border )
            variableRemove:SetWide( variableAction:GetTall()-(2*border) )
            variableRemove:SetText( "" )
            local changeAlpha = 0
            local deleteMat = Material( "materials/bricks_server/delete.png" )
            variableRemove.Paint = function( self2, w, h ) 
                if( self2:IsDown() ) then
                    changeAlpha = math.Clamp( changeAlpha+10, 0, 255 )
                elseif( self2:IsHovered() ) then
                    changeAlpha = math.Clamp( changeAlpha+10, 0, 255 )
                else
                    changeAlpha = math.Clamp( changeAlpha-10, 0, 255 )
                end
                
                draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.DEVCONFIG.BaseThemes.Red )
        
                surface.SetAlphaMultiplier( changeAlpha/255 )
                    draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.DEVCONFIG.BaseThemes.DarkRed )
                surface.SetAlphaMultiplier( 1 )

                surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
                surface.SetMaterial( deleteMat )
                local iconSize = h*0.65
                surface.DrawTexturedRect( (h-iconSize)/2, (h/2)-(iconSize/2), iconSize, iconSize )
            end
            variableRemove.DoClick = function()
                BS_ConfigCopyTable.CRAFTING.RockTypes[k] = nil
                BRICKS_SERVER.Func.ConfigChange( "CRAFTING" )
                self.RefreshPanel()
            end
        end

        local addNewMineableResource = vgui.Create( "DButton", self )
        addNewMineableResource:Dock( TOP )
        addNewMineableResource:SetText( "" )
        addNewMineableResource:SetTall( 40 )
        local changeAlpha = 0
        addNewMineableResource.Paint = function( self2, w, h )
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
    
            draw.SimpleText( "Add Mineable Resource", "BRICKS_SERVER_Font25", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end
        addNewMineableResource.DoClick = function()
            BS_ConfigCopyTable.CRAFTING.RockTypes = BS_ConfigCopyTable.CRAFTING.RockTypes or {}

            local options = {}
            for k, v in pairs( BS_ConfigCopyTable.CRAFTING.Resources ) do
                if( BS_ConfigCopyTable.CRAFTING.RockTypes[k] ) then continue end
                options[k] = k
            end
            BRICKS_SERVER.Func.ComboRequest( "Admin", "What new mineable resource would you like to add?", "None", options, function( value, data ) 
                if( BS_ConfigCopyTable.CRAFTING.Resources[value] and not BS_ConfigCopyTable.CRAFTING.RockTypes[value] ) then
                    BS_ConfigCopyTable.CRAFTING.RockTypes[value] = 0
                    self.RefreshPanel()
                    BRICKS_SERVER.Func.ConfigChange( "CRAFTING" )
                else
                    notification.AddLegacy( "Invalid resource.", 1, 3 )
                end
            end, function() end, "OK", "Cancel" )
        end

        local lineBreak2 = vgui.Create( "DPanel", self )
        lineBreak2:Dock( TOP )
        lineBreak2:DockMargin( 5, 20, 5, 20 )
        lineBreak2:SetTall( 5 )
        lineBreak2.Paint = function( self2, w, h )
            draw.RoundedBox( 3, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
        end

        local treeTypeHeader = vgui.Create( "DButton", self )
        treeTypeHeader:Dock( TOP )
        treeTypeHeader:DockMargin( 0, 0, 0, 5 )
        treeTypeHeader:SetText( "" )
        treeTypeHeader:SetTall( 40 )
        local changeAlpha = 0
        treeTypeHeader.Paint = function( self2, w, h )
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
    
            draw.SimpleText( "Tree resources", "BRICKS_SERVER_Font25", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end
        treeTypeHeader.DoClick = function()
            BRICKS_SERVER.Func.Message( "Below are the resources available from chopping trees.", "Admin", "OK" )
        end

        for k, v in pairs( BS_ConfigCopyTable.CRAFTING.TreeTypes or {} ) do
            local variableBack = vgui.Create( "DPanel", self )
            variableBack:Dock( TOP )
            variableBack:DockMargin( 0, 0, 0, 5 )
            variableBack:SetTall( 65 )
            variableBack:DockPadding( 0, 0, 30, 0 )
            variableBack.Paint = function( self2, w, h )
                draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )

                draw.SimpleText( k, "BRICKS_SERVER_Font33", 15, 5, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
                draw.SimpleText( (BS_ConfigCopyTable.CRAFTING.TreeTypes[k] or 0) .. "%", "BRICKS_SERVER_Font20", 18, 32, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
            end

            local variableAction = vgui.Create( "DButton", variableBack )
            variableAction:SetPos( 0, 0 )
            variableAction:SetSize( (ScrW()*0.6)-BRICKS_SERVER.DEVCONFIG.MainNavWidth-20, variableBack:GetTall() )
            variableAction:SetText( "" )
            local changeAlpha = 0
            variableAction.Paint = function( self2, w, h ) 
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
            variableAction.DoClick = function()
                BRICKS_SERVER.Func.StringRequest( "Admin", "What should the chance to get this resource be?", v or 0, function( number ) 
                    BS_ConfigCopyTable.CRAFTING.TreeTypes[k] = number
                    BRICKS_SERVER.Func.ConfigChange( "CRAFTING" )
                end, function() end, "OK", "Cancel", true )
            end

            local variableRemove = vgui.Create( "DButton", variableAction )
            local border = 12.5
            variableRemove:Dock( RIGHT ) -- size 40
            variableRemove:DockMargin( 0, border, border, border )
            variableRemove:SetWide( variableAction:GetTall()-(2*border) )
            variableRemove:SetText( "" )
            local changeAlpha = 0
            local deleteMat = Material( "materials/bricks_server/delete.png" )
            variableRemove.Paint = function( self2, w, h ) 
                if( self2:IsDown() ) then
                    changeAlpha = math.Clamp( changeAlpha+10, 0, 255 )
                elseif( self2:IsHovered() ) then
                    changeAlpha = math.Clamp( changeAlpha+10, 0, 255 )
                else
                    changeAlpha = math.Clamp( changeAlpha-10, 0, 255 )
                end
                
                draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.DEVCONFIG.BaseThemes.Red )
        
                surface.SetAlphaMultiplier( changeAlpha/255 )
                    draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.DEVCONFIG.BaseThemes.DarkRed )
                surface.SetAlphaMultiplier( 1 )

                surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
                surface.SetMaterial( deleteMat )
                local iconSize = h*0.65
                surface.DrawTexturedRect( (h-iconSize)/2, (h/2)-(iconSize/2), iconSize, iconSize )
            end
            variableRemove.DoClick = function()
                BS_ConfigCopyTable.CRAFTING.TreeTypes[k] = nil
                BRICKS_SERVER.Func.ConfigChange( "CRAFTING" )
                self.RefreshPanel()
            end
        end

        local addNewTreeResource = vgui.Create( "DButton", self )
        addNewTreeResource:Dock( TOP )
        addNewTreeResource:SetText( "" )
        addNewTreeResource:SetTall( 40 )
        local changeAlpha = 0
        addNewTreeResource.Paint = function( self2, w, h )
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
    
            draw.SimpleText( "Add Tree Resource", "BRICKS_SERVER_Font25", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end
        addNewTreeResource.DoClick = function()
            BS_ConfigCopyTable.CRAFTING.TreeTypes = BS_ConfigCopyTable.CRAFTING.TreeTypes or {}

            local options = {}
            for k, v in pairs( BS_ConfigCopyTable.CRAFTING.Resources ) do
                if( BS_ConfigCopyTable.CRAFTING.TreeTypes[k] ) then continue end
                options[k] = k
            end
            BRICKS_SERVER.Func.ComboRequest( "Admin", "What new tree resource would you like to add?", "None", options, function( value, data ) 
                if( BS_ConfigCopyTable.CRAFTING.Resources[value] and not BS_ConfigCopyTable.CRAFTING.TreeTypes[value] ) then
                    BS_ConfigCopyTable.CRAFTING.TreeTypes[value] = 0
                    self.RefreshPanel()
                    BRICKS_SERVER.Func.ConfigChange( "CRAFTING" )
                else
                    notification.AddLegacy( "Invalid resource.", 1, 3 )
                end
            end, function() end, "OK", "Cancel" )
        end

        local lineBreak2 = vgui.Create( "DPanel", self )
        lineBreak2:Dock( TOP )
        lineBreak2:DockMargin( 5, 20, 5, 20 )
        lineBreak2:SetTall( 5 )
        lineBreak2.Paint = function( self2, w, h )
            draw.RoundedBox( 3, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
        end

        local garbageTypeHeader = vgui.Create( "DButton", self )
        garbageTypeHeader:Dock( TOP )
        garbageTypeHeader:DockMargin( 0, 0, 0, 5 )
        garbageTypeHeader:SetText( "" )
        garbageTypeHeader:SetTall( 40 )
        local changeAlpha = 0
        garbageTypeHeader.Paint = function( self2, w, h )
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
    
            draw.SimpleText( "Garbage resources", "BRICKS_SERVER_Font25", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end
        garbageTypeHeader.DoClick = function()
            BRICKS_SERVER.Func.Message( "Below are the resources available from collecting garbage.", "Admin", "OK" )
        end

        for k, v in pairs( BS_ConfigCopyTable.CRAFTING.GarbageTypes or {} ) do
            local variableBack = vgui.Create( "DPanel", self )
            variableBack:Dock( TOP )
            variableBack:DockMargin( 0, 0, 0, 5 )
            variableBack:SetTall( 65 )
            variableBack:DockPadding( 0, 0, 30, 0 )
            variableBack.Paint = function( self2, w, h )
                draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )

                draw.SimpleText( k, "BRICKS_SERVER_Font33", 15, 5, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
                draw.SimpleText( (BS_ConfigCopyTable.CRAFTING.GarbageTypes[k] or 0) .. "%", "BRICKS_SERVER_Font20", 18, 32, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
            end

            local variableAction = vgui.Create( "DButton", variableBack )
            variableAction:SetPos( 0, 0 )
            variableAction:SetSize( (ScrW()*0.6)-BRICKS_SERVER.DEVCONFIG.MainNavWidth-20, variableBack:GetTall() )
            variableAction:SetText( "" )
            local changeAlpha = 0
            variableAction.Paint = function( self2, w, h ) 
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
            variableAction.DoClick = function()
                BRICKS_SERVER.Func.StringRequest( "Admin", "What should the chance to get this resource be?", v or 0, function( number ) 
                    BS_ConfigCopyTable.CRAFTING.GarbageTypes[k] = number
                    BRICKS_SERVER.Func.ConfigChange( "CRAFTING" )
                end, function() end, "OK", "Cancel", true )
            end

            local variableRemove = vgui.Create( "DButton", variableAction )
            local border = 12.5
            variableRemove:Dock( RIGHT ) -- size 40
            variableRemove:DockMargin( 0, border, border, border )
            variableRemove:SetWide( variableAction:GetTall()-(2*border) )
            variableRemove:SetText( "" )
            local changeAlpha = 0
            local deleteMat = Material( "materials/bricks_server/delete.png" )
            variableRemove.Paint = function( self2, w, h ) 
                if( self2:IsDown() ) then
                    changeAlpha = math.Clamp( changeAlpha+10, 0, 255 )
                elseif( self2:IsHovered() ) then
                    changeAlpha = math.Clamp( changeAlpha+10, 0, 255 )
                else
                    changeAlpha = math.Clamp( changeAlpha-10, 0, 255 )
                end
                
                draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.DEVCONFIG.BaseThemes.Red )
        
                surface.SetAlphaMultiplier( changeAlpha/255 )
                    draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.DEVCONFIG.BaseThemes.DarkRed )
                surface.SetAlphaMultiplier( 1 )

                surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
                surface.SetMaterial( deleteMat )
                local iconSize = h*0.65
                surface.DrawTexturedRect( (h-iconSize)/2, (h/2)-(iconSize/2), iconSize, iconSize )
            end
            variableRemove.DoClick = function()
                BS_ConfigCopyTable.CRAFTING.GarbageTypes[k] = nil
                BRICKS_SERVER.Func.ConfigChange( "CRAFTING" )
                self.RefreshPanel()
            end
        end

        local addNewGarbageResource = vgui.Create( "DButton", self )
        addNewGarbageResource:Dock( TOP )
        addNewGarbageResource:SetText( "" )
        addNewGarbageResource:SetTall( 40 )
        local changeAlpha = 0
        addNewGarbageResource.Paint = function( self2, w, h )
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
    
            draw.SimpleText( "Add Garbage Resource", "BRICKS_SERVER_Font25", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end
        addNewGarbageResource.DoClick = function()
            BS_ConfigCopyTable.CRAFTING.GarbageTypes = BS_ConfigCopyTable.CRAFTING.GarbageTypes or {}

            local options = {}
            for k, v in pairs( BS_ConfigCopyTable.CRAFTING.Resources ) do
                if( BS_ConfigCopyTable.CRAFTING.GarbageTypes[k] ) then continue end
                options[k] = k
            end
            BRICKS_SERVER.Func.ComboRequest( "Admin", "What new garbage resource would you like to add?", "None", options, function( value, data ) 
                if( BS_ConfigCopyTable.CRAFTING.Resources[value] and not BS_ConfigCopyTable.CRAFTING.GarbageTypes[value] ) then
                    BS_ConfigCopyTable.CRAFTING.GarbageTypes[value] = 0
                    self.RefreshPanel()
                    BRICKS_SERVER.Func.ConfigChange( "CRAFTING" )
                else
                    notification.AddLegacy( "Invalid resource.", 1, 3 )
                end
            end, function() end, "OK", "Cancel" )
        end
    end
    self.RefreshPanel()
end

function PANEL:Paint( w, h )
    
end

vgui.Register( "bricks_server_config_resources", PANEL, "bricks_server_scrollpanel" )