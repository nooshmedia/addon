local PANEL = {}

local variables = {
    { "Name", "New zone", "string" },
    { "Name Color", BRICKS_SERVER.Func.GetTheme( 5 ), "color" },
    { "Message", "Welcome to the new zone!", "string" },
    { "Message Color", BRICKS_SERVER.Func.GetTheme( 6 ), "color" },
    { "Leaving Message", "Goodbye, please come again!", "string" },
    { "Leaving Message Color", BRICKS_SERVER.Func.GetTheme( 6 ), "color" },
    { "Disable Prop Spawning", false, "bool" },
    { "Enable God Mode", false, "bool" },
    { "Kill On Entry", false, "bool" },
    { "Block Entry", false, "bool" }
}

function PANEL:Init()
    self:SetSize( ScrW(), ScrH() )
    self:SetPos( 0, 0 )
    self:SetDraggable( false )
    self:ShowCloseButton( false )
    self:SetTitle( "" )
    self:MakePopup()
    self:DockPadding( 0, 0, 0, 0 )

    RunConsoleCommand( "developer", 1 )

    if( BRICKS_SERVER.Func.HasAdminAccess( LocalPlayer() ) ) then
        BS_ConfigsChanged = {}
        BS_ConfigCopyTable = table.Copy( BRICKS_SERVER.CONFIG )
    end

    local cameraRotate = vgui.Create( "DPanel", self )
    cameraRotate:Dock( FILL )
    cameraRotate.Paint = function( self2, w, h ) end
    local cameraMoving = false
    local oldMouseX, oldMouseY = gui.MousePos()
    local mouseX, mouseY = gui.MousePos()
    cameraRotate.OnMousePressed = function( self2, keyCode )
        if( keyCode == MOUSE_LEFT ) then 
            if( not self.completedSteps or not self.steps ) then return end

        	local nextStepTable = self.steps[#self.completedSteps+1]
            if( nextStepTable and nextStepTable[2] and nextStepTable[2] == "position" ) then
                table.insert( self.completedSteps, LocalPlayer():GetEyeTrace().HitPos )
                self:RefreshSteps()
            end
        elseif( keyCode == MOUSE_RIGHT ) then 
            cameraMoving = true
            self2:SetCursor( "blank" )
            oldMouseX, oldMouseY = gui.MousePos()
            mouseX, mouseY = gui.MousePos()
        end
	end
	cameraRotate.OnMouseReleased = function( self2, keyCode )
		if( keyCode != MOUSE_RIGHT ) then return end
        
        cameraMoving = false
        self2:SetCursor( "none" )
        input.SetCursorPos( oldMouseX, oldMouseY )
	end
    cameraRotate.OnCursorMoved = function()
        if( not cameraMoving ) then return end
        
        local newMouseX, newMouseY = gui.MousePos()
        LocalPlayer():SetEyeAngles( LocalPlayer():EyeAngles() - Angle( -(newMouseY-mouseY)*0.25, (newMouseX-mouseX)*0.25, 0 ) )
        mouseX, mouseY = newMouseX, newMouseY
	end

    local backPanel = vgui.Create( "DPanel", self )
    backPanel:SetSize( ScrW()*0.3, ScrH()*0.3 )
    backPanel:SetPos( 10, 30 )
    backPanel.headerHeight = 40
    backPanel:DockPadding( 0, backPanel.headerHeight, 0, 0 )
    local rounded = 5
    local themeCol = BRICKS_SERVER.Func.GetTheme( 0 )
    local backColor = Color( themeCol.r, themeCol.g, themeCol.b, 50 )
    backPanel.Paint = function( self2, w, h )
        draw.RoundedBox( rounded, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
        draw.RoundedBox( rounded, 0, 0, w, h, backColor )
        draw.RoundedBoxEx( rounded, 0, 0, w, self2.headerHeight, BRICKS_SERVER.Func.GetTheme( 0 ), true, true, false, false )
    
        draw.SimpleText( "Zone Creator", "BRICKS_SERVER_Font30", 10, (self2.headerHeight or 40)/2-2, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_CENTER )
    end

    local closeButton = vgui.Create( "DButton", backPanel )
	local size = 24
	closeButton:SetSize( size, size )
	closeButton:SetPos( backPanel:GetWide()-size-((backPanel.headerHeight-size)/2), (backPanel.headerHeight/2)-(size/2) )
	closeButton:SetText( "" )
    local CloseMat = Material( "materials/bricks_server/close.png" )
    local textColor = BRICKS_SERVER.Func.GetTheme( 6 )
	closeButton.Paint = function( self2, w, h )
		if( self2:IsHovered() and !self2:IsDown() ) then
			surface.SetDrawColor( textColor.r*0.6, textColor.g*0.6, textColor.b*0.6 )
		elseif( self2:IsDown() || self2.m_bSelected ) then
			surface.SetDrawColor( textColor.r*0.8, textColor.g*0.8, textColor.b*0.8 )
		else
			surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 2 ) )
		end

		surface.SetMaterial( CloseMat )
		surface.DrawTexturedRect( 0, 0, w, h )
	end
    closeButton.DoClick = function()
        RunConsoleCommand( "developer", 0 )

        net.Start( "BRS.Net.CloseZoneEditor" )
        net.SendToServer()

        if( BRICKS_SERVER.Func.HasAdminAccess( LocalPlayer() ) ) then
            if( BS_ConfigsChanged and table.Count( BS_ConfigsChanged ) > 0 ) then
                local configToSend = {}
                for k, v in pairs( BS_ConfigsChanged ) do
                    if( (BS_ConfigCopyTable or BRICKS_SERVER.CONFIG)[k] ) then
                        configToSend[k] = (BS_ConfigCopyTable or BRICKS_SERVER.CONFIG)[k]
                    end
                end

                local configData = util.Compress( util.TableToJSON( configToSend ) )

                net.Start( "BRS.Net.UpdateConfig" )
                    net.WriteData( configData, string.len( configData ) )
                net.SendToServer()
            end
        end
        
        self:Remove()
    end

    local sheet = vgui.Create( "bricks_server_colsheet_icon", backPanel )
    sheet:Dock( FILL )

    self.addPage = vgui.Create( "bricks_server_scrollpanel", sheet )
    self.addPage:Dock( FILL )
    self.addPage:DockMargin( 10, 10, 10, 10 )
    local sheetButton = sheet:AddSheet( self.addPage, false, "add.png" )

    self:ResetSteps()

    local editPageBack = vgui.Create( "DPanel", sheet )
    editPageBack:Dock( FILL )
    editPageBack.Paint = function() end
    local sheetButton = sheet:AddSheet( editPageBack, false, "edit_32.png" )

    local panelSelf = self
    function self:RefreshEditPage()
        editPageBack:Clear()

        local editPage = vgui.Create( "bricks_server_colsheet_left", editPageBack )
        editPage:Dock( FILL )

        for k, v in pairs( BS_ConfigCopyTable.ZONES or {} ) do
            local zoneEditPage = vgui.Create( "bricks_server_scrollpanel", editPage )
            zoneEditPage:Dock( FILL )
            local sheetButton = editPage:AddSheet( (v[1] or "Error"), zoneEditPage )

            local zoneRemoveButton = vgui.Create( "DButton", zoneEditPage )
            zoneRemoveButton:Dock( TOP )
            zoneRemoveButton:SetText( "" )
            zoneRemoveButton:DockMargin( 10, 10, 10, 0 )
            zoneRemoveButton:SetTall( 40 )
            local changeAlpha = 0
            zoneRemoveButton.Paint = function( self2, w, h )
                if( self2:IsHovered() ) then
                    changeAlpha = math.Clamp( changeAlpha+10, 0, 255 )
                else
                    changeAlpha = math.Clamp( changeAlpha-10, 0, 255 )
                end
                
                draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.DEVCONFIG.BaseThemes.Red )
        
                surface.SetAlphaMultiplier( changeAlpha/255 )
                draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.DEVCONFIG.BaseThemes.DarkRed )
                surface.SetAlphaMultiplier( 1 )
        
                draw.SimpleText( "Remove zone", "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            end
            zoneRemoveButton.DoClick = function()
                BS_ConfigCopyTable.ZONES[k] = nil
                panelSelf:RefreshEditPage()
                BRICKS_SERVER.Func.ConfigChange( "ZONES" )
            end

            local addZoneOptionsSpacer = vgui.Create( "DPanel", zoneEditPage )
            addZoneOptionsSpacer:Dock( TOP )
            addZoneOptionsSpacer:DockMargin( 10, 0, 10, 0 )
            addZoneOptionsSpacer:SetTall( 40 )
            addZoneOptionsSpacer.Paint = function( self2, w, h )
                draw.SimpleText( "Options", "BRICKS_SERVER_Font25", 0, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_CENTER )
            end

            local spacing = 10
            local gridWide = (ScrW()*0.3)-65-120-20
        
            local slotsWide = 2
            local slotWide = (gridWide-((slotsWide-1)*spacing))/slotsWide
            local slotTall = 40
        
            local addZoneOptionsGrid = vgui.Create( "DIconLayout", zoneEditPage )
            addZoneOptionsGrid:Dock( TOP )
            addZoneOptionsGrid:DockMargin( 10, spacing, 0, 0 )
            addZoneOptionsGrid:SetTall( slotTall )
            addZoneOptionsGrid:SetSpaceY( spacing )
            addZoneOptionsGrid:SetSpaceX( spacing )
        
            local addZoneOptionsSlots = 0
        
            for key, val in pairs( variables ) do
                addZoneOptionsSlots = (addZoneOptionsSlots or 0)+1
                local slotsTall = math.ceil( addZoneOptionsSlots/slotsWide )
                addZoneOptionsGrid:SetTall( (slotsTall*slotTall)+((slotsTall-1)*spacing) )
                
                if( val[3] == "bool" ) then
                    local addZoneVariable = vgui.Create( "bricks_server_dcheckbox", addZoneOptionsGrid )
                    addZoneVariable:SetSize( slotWide, 20 )
                    addZoneVariable:SetValue( BS_ConfigCopyTable.ZONES[k][key] or val[2] )
                    addZoneVariable:SetTitle( val[1] )
                    addZoneVariable.OnChange = function( value )
                        BS_ConfigCopyTable.ZONES[k][key] = value
                        BRICKS_SERVER.Func.ConfigChange( "ZONES" )
                    end
                elseif( val[3] == "color" ) then
                    local addZoneVariableBack = vgui.Create( "DPanel", addZoneOptionsGrid )
                    addZoneVariableBack:SetSize( slotWide, slotTall )
                    addZoneVariableBack.Paint = function( self2, w, h )
                        draw.RoundedBox( 5, w-h, 0, h, h, BS_ConfigCopyTable.ZONES[k][key] or val[2] )
                    end
        
                    local addZoneVariable = vgui.Create( "bricks_server_clickentry", addZoneVariableBack )
                    addZoneVariable:Dock( FILL )
                    addZoneVariable:DockMargin( 0, 0, 45, 0 )
                    addZoneVariable:SetDataType( val[3] )
                    addZoneVariable:SetValue( BS_ConfigCopyTable.ZONES[k][key] or val[2] )
                    addZoneVariable:SetTitle( val[1] )
                    addZoneVariable.OnChange = function( value )
                        BS_ConfigCopyTable.ZONES[k][key] = value
                        BRICKS_SERVER.Func.ConfigChange( "ZONES" )
                    end
                else
                    local addZoneVariable = vgui.Create( "bricks_server_clickentry", addZoneOptionsGrid )
                    addZoneVariable:SetSize( slotWide, slotTall )
                    addZoneVariable:SetDataType( val[3] )
                    addZoneVariable:SetValue( BS_ConfigCopyTable.ZONES[k][key] or val[2] )
                    addZoneVariable:SetTitle( val[1] )
                    addZoneVariable.OnChange = function( value )
                        BS_ConfigCopyTable.ZONES[k][key] = value
                        BRICKS_SERVER.Func.ConfigChange( "ZONES" )
                    end
                end
            end
        end
    end
    self:RefreshEditPage()
end

function PANEL:ResetSteps()
    self.addPage:Clear()

    self.completedSteps = {}

    self.steps = {
        [1] = { "Select the zone type", "choose" }
    }

    local addZoneTopPanel = vgui.Create( "DPanel", self.addPage )
    addZoneTopPanel:Dock( TOP )
    addZoneTopPanel:SetTall( 75 )
    addZoneTopPanel.Paint = function() end

    local addZoneStepBar = vgui.Create( "DPanel", addZoneTopPanel )
    addZoneStepBar:Dock( TOP )
    addZoneStepBar:SetTall( 25 )
    addZoneStepBar.Paint = function( self2, w, h )
        draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )

        if( not self.completedSteps or not self.steps ) then return end

        if( (#self.completedSteps or 0) < (#self.steps or 0) ) then
            draw.RoundedBoxEx( 5, 0, 0, w*math.Clamp( (#self.completedSteps or 0)/(#self.steps or 0), 0, 1 ), h, BRICKS_SERVER.Func.GetTheme( 4 ), true, false, true, false )
            draw.SimpleText( "Step " .. (#self.completedSteps or 0) .. "/" .. (#self.steps or 0) .. "  -  " .. (self.steps[(#self.completedSteps or 0)+1][1] or "Error"), "BRICKS_SERVER_Font17", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        else
            draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 4 ) )
            draw.SimpleText( "Completed setup", "BRICKS_SERVER_Font17", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end
    end

    if( IsValid( self.addZoneType ) ) then
        self.addZoneType:Remove()
    end

    self.addZoneType = vgui.Create( "bricks_server_combo", addZoneTopPanel )
    self.addZoneType:Dock( TOP )
    self.addZoneType:DockMargin( 0, 10, 0, 0 )
    self.addZoneType:SetTall( 40 )
    self.addZoneType:SetValue( "Select zone type" )
    for k, v in pairs( BRICKS_SERVER.DEVCONFIG.ZoneTypes ) do
        self.addZoneType:AddChoice( k )
    end
    self.addZoneType.OnSelect = function( self2, index, value )
        if( BRICKS_SERVER.DEVCONFIG.ZoneTypes[value] ) then
            self.completedSteps[1] = value

            for i = 1, (BRICKS_SERVER.DEVCONFIG.ZoneTypes[value].Points or 1) do
                table.insert( self.steps, { "Select the position of point " .. i .. " using left click", "position" } )
            end

            table.insert( self.steps, { "Set the size of the zone below", "setsize" } )

            self.addZoneType:Remove()
            addZoneTopPanel:SetTall( 25 )
        end
    end

    function self:RefreshSteps()
        if( (#self.completedSteps or 0) >= (#self.steps or 0) ) then
            addZoneTopPanel:SetTall( 75 )

            local addZoneFinish = vgui.Create( "DButton", addZoneTopPanel )
            addZoneFinish:Dock( TOP )
            addZoneFinish:SetText( "" )
            addZoneFinish:DockMargin( 0, 10, 0, 0 )
            addZoneFinish:SetTall( 40 )
            local changeAlpha = 0
            addZoneFinish.Paint = function( self2, w, h )
                if( self2:IsHovered() ) then
                    changeAlpha = math.Clamp( changeAlpha+10, 0, 255 )
                else
                    changeAlpha = math.Clamp( changeAlpha-10, 0, 255 )
                end
                
                draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.DEVCONFIG.BaseThemes.Green )
        
                surface.SetAlphaMultiplier( changeAlpha/255 )
                draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.DEVCONFIG.BaseThemes.DarkGreen )
                surface.SetAlphaMultiplier( 1 )
        
                draw.SimpleText( "Finish setup", "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            end
            addZoneFinish.DoClick = function()
                local zoneType = self.completedSteps[1]
                local zoneTypeTable = BRICKS_SERVER.DEVCONFIG.ZoneTypes[zoneType]

                if( not zoneTypeTable ) then 
                    notification.AddLegacy( "Zone creation failed!", 1, 3 )
                    self:ResetSteps()
                    return 
                end

                net.Start( "BRS.Net.CreateZone" )
                    net.WriteString( zoneType )
                
                    for i = 1, (zoneTypeTable.Points or 1) do
                        net.WriteVector( self.completedSteps[i+1] or Vector( 0, 0, 0 ) )
                    end
                    net.WriteUInt( self.completedSteps[#self.completedSteps], 16 )
                    net.WriteTable( self.zoneOptions or {} )
                net.SendToServer()
                self:ResetSteps()
            end
        elseif( self.steps[(#self.completedSteps or 0)+1] and (self.steps[(#self.completedSteps or 0)+1][2] or "") == "setsize" ) then
            addZoneTopPanel:SetTall( 75 )

            local addZoneSize = vgui.Create( "bricks_server_clickentry", addZoneTopPanel )
            addZoneSize:Dock( TOP )
            addZoneSize:DockMargin( 0, 10, 0, 0 )
            addZoneSize:SetTall( 40 )
            addZoneSize:SetDataType( "integer" )
            addZoneSize:SetValue( 100 )
            addZoneSize:SetTitle( "Zone size" )
            addZoneSize.OnEnter = function( value )
                table.insert( self.completedSteps, value )
                addZoneSize:Remove()
                self:RefreshSteps()
            end
        end
    end

    local addZoneOptionsSpacer = vgui.Create( "DPanel", self.addPage )
    addZoneOptionsSpacer:Dock( TOP )
    addZoneOptionsSpacer:DockMargin( 0, 0, 0, 0 )
    addZoneOptionsSpacer:SetTall( 40 )
    addZoneOptionsSpacer.Paint = function( self2, w, h )
        draw.SimpleText( "Options", "BRICKS_SERVER_Font25", 0, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_CENTER )
    end

    local spacing = 10
    local gridWide = (ScrW()*0.3)-65-20

    local slotsWide = 2
    local slotWide = (gridWide-((slotsWide-1)*spacing))/slotsWide
    local slotTall = 40

    local addZoneOptionsGrid = vgui.Create( "DIconLayout", self.addPage )
    addZoneOptionsGrid:Dock( TOP )
    addZoneOptionsGrid:DockMargin( 0, spacing, 0, 0 )
    addZoneOptionsGrid:SetTall( slotTall )
    addZoneOptionsGrid:SetSpaceY( spacing )
    addZoneOptionsGrid:SetSpaceX( spacing )

    local addZoneOptionsSlots = 0

    self.zoneOptions = {}
    for k, v in pairs( variables ) do
        addZoneOptionsSlots = (addZoneOptionsSlots or 0)+1
        local slotsTall = math.ceil( addZoneOptionsSlots/slotsWide )
        addZoneOptionsGrid:SetTall( (slotsTall*slotTall)+((slotsTall-1)*spacing) )

        self.zoneOptions[k] = v[2]

        if( v[3] == "color" ) then
            local addZoneVariableBack = vgui.Create( "DPanel", addZoneOptionsGrid )
            addZoneVariableBack:SetSize( slotWide, slotTall )
            addZoneVariableBack.Paint = function( self2, w, h )
                draw.RoundedBox( 5, w-h, 0, h, h, self.zoneOptions[k] or v[2] )
            end

            local addZoneVariable = vgui.Create( "bricks_server_clickentry", addZoneVariableBack )
            addZoneVariable:Dock( FILL )
            addZoneVariable:DockMargin( 0, 0, 45, 0 )
            addZoneVariable:SetDataType( v[3] )
            addZoneVariable:SetValue( v[2] )
            addZoneVariable:SetTitle( v[1] )
            addZoneVariable.OnChange = function( value )
                self.zoneOptions[k] = value
            end
        elseif( v[3] == "bool" ) then
            local addZoneVariable = vgui.Create( "bricks_server_dcheckbox", addZoneOptionsGrid )
            addZoneVariable:SetSize( slotWide, 20 )
            addZoneVariable:SetValue( v[2] )
            addZoneVariable:SetTitle( v[1] )
            addZoneVariable.OnChange = function( value )
                self.zoneOptions[k] = value
            end
        else
            local addZoneVariable = vgui.Create( "bricks_server_clickentry", addZoneOptionsGrid )
            addZoneVariable:SetSize( slotWide, slotTall )
            addZoneVariable:SetDataType( v[3] )
            addZoneVariable:SetValue( v[2] )
            addZoneVariable:SetTitle( v[1] )
            addZoneVariable.OnChange = function( value )
                self.zoneOptions[k] = value
            end
        end
    end
end

function PANEL:Think()
    if( self.completedSteps and self.completedSteps[2] ) then
        local pos1, pos2 = self.completedSteps[2], (self.completedSteps[3] or LocalPlayer():GetEyeTrace().HitPos)

        if( not isvector( pos1 ) or not isvector( pos2 ) ) then return end

        local pos1Copy, pos2Copy = Vector( pos1[1], pos1[2], pos1[3] ), Vector( pos2[1], pos2[2], pos2[3] )
        OrderVectors( pos1Copy, pos2Copy )
        pos2Copy = pos2Copy+Vector( 0, 0, 100 )

        debugoverlay.Box( (Vector( pos1Copy[1]+pos2Copy[1], pos1Copy[2]+pos2Copy[2], pos1Copy[3]+pos2Copy[3] )/2), pos1Copy, pos2Copy, 0.001, Color( 255, 255, 255, 25 ) )
    end
end

function PANEL:Paint( w, h )

end

vgui.Register( "bricks_server_ui_zonecreator", PANEL, "DFrame" )