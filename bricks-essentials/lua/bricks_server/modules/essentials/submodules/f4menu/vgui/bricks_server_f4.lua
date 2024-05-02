local PANEL = {}

function PANEL:Init()
    self:SetSize( ScrW()*0.6, ScrH()*0.65 )
    self:Center()
    self:SetHeader( BRICKS_SERVER.CONFIG.GENERAL["Server Name"] )
    self.removeOnClose = false
    self.centerOnSizeChanged = true

    self.onCloseFunc = function()
        if( BRICKS_SERVER.Func.HasAdminAccess( LocalPlayer() ) ) then
            BRICKS_SERVER.Func.SendAdminConfig()
        end

        if( BRICKS_SERVER.Func.IsSubModuleEnabled( "unboxing", "marketplace" ) ) then
            net.Start( "BRS.Net.SendUnboxingMarketplaceClose" )
            net.SendToServer()
        end

        if( BRICKS_SERVER.Func.IsModuleEnabled( "coinflip" ) ) then
            net.Start( "BRS.Net.CloseCoinflipsMenu" )
            net.SendToServer()
        end
    end

    hook.Add( "Move", self, function( self, ply, mv )
        if( IsValid( self ) ) then
            if( self:IsVisible() and input.WasKeyPressed( KEY_F4 ) ) then
                self:CloseFrame()
            end
        else
            hook.Remove( "Move", self )
        end
    end)
end

function PANEL:FillTabs()
    if( IsValid( self.sheet ) ) then
        if( IsValid( self.sheet.ActiveButton ) ) then
            self.previousSheet = self.sheet.ActiveButton.label
        end
        self.sheet:Remove()
    end

    local originalW, originalH = ScrW()*0.6, ScrH()*0.65 
    local newW = originalW+200

    self.sheet = vgui.Create( "bricks_server_colsheet", self )
    self.sheet:Dock( FILL )
    self.sheet.OnSheetChange = function( active )
        if( active.label == "Config" and (self:GetWide() != newW or self:GetTall() != originalH) ) then
            self:SizeTo( newW, originalH, 0.2 )
        elseif( active.label != "Config" and (self:GetWide() != originalW or self:GetTall() != originalH) ) then
            self:SizeTo( originalW, originalH, 0.2 )
        end
    end

    local height = 55
    local avatarBackSize = height
    local textStartPos = 65
    
    local avatarBack = vgui.Create( "DPanel", self.sheet.Navigation )
    avatarBack:Dock( TOP )
    avatarBack:DockMargin( 10, 10, 0, 10 )
    avatarBack:SetTall( height )
    avatarBack.Paint = function( self2, w, h )
        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 2 ) )
        draw.NoTexture()
        BRICKS_SERVER.Func.DrawCircle( (h-avatarBackSize)/2+(avatarBackSize/2), h/2, avatarBackSize/2, 45 )

        draw.SimpleText( LocalPlayer():Nick(), "BRICKS_SERVER_Font23", textStartPos, h/2+2, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_BOTTOM )
        draw.SimpleText( DarkRP.formatMoney( LocalPlayer():getDarkRPVar( "money" ) ), "BRICKS_SERVER_Font20", textStartPos, h/2-2, BRICKS_SERVER.Func.GetTheme( 5 ), 0, 0 )
    end

    local distance = 2

    local avatarIcon = vgui.Create( "bricks_server_circle_avatar" , avatarBack )
    avatarIcon:SetPos( (height-avatarBackSize)/2+distance, (height-avatarBackSize)/2+distance )
    avatarIcon:SetSize( avatarBackSize-(2*distance), avatarBackSize-(2*distance) )
    avatarIcon:SetPlayer( LocalPlayer(), 64 )

    local commandsButton = vgui.Create( "DButton", self.sheet.Navigation )
    commandsButton:SetSize( 16, 16 )
    commandsButton:SetPos( BRICKS_SERVER.DEVCONFIG.MainNavWidth-commandsButton:GetWide()-5, 12 )
    commandsButton:SetText( "" )
    local changeAlpha = 100
    local settingsMat = Material( "materials/bricks_server/settings_16.png" )
    commandsButton.Paint = function( self2, w, h )
        if( self2:IsDown() ) then
            changeAlpha = math.Clamp( changeAlpha+10, 100, 225 )
        elseif( self2:IsHovered() ) then
            changeAlpha = math.Clamp( changeAlpha+10, 100, 200 )
        else
            changeAlpha = math.Clamp( changeAlpha-10, 100, 200 )
        end

        surface.SetAlphaMultiplier( changeAlpha/255 )
            surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
            surface.SetMaterial( settingsMat )
            surface.DrawTexturedRect( 0, 0, w, h )
        surface.SetAlphaMultiplier( 1 )
    end
    commandsButton.DoClick = function()
        if( IsValid( self.navCover ) ) then
            self.navCover:Remove()
        else
            local lastPage = self.sheet.ActiveButton
            self.sheet:SetActiveButton( self.settingsPageButton )
            
            self.navCover = vgui.Create( "DPanel", self.sheet.Navigation )
            self.navCover:SetPos( 0, 0 )
            self.navCover:SetSize( BRICKS_SERVER.DEVCONFIG.MainNavWidth, 0 )
            self.navCover:SizeTo( BRICKS_SERVER.DEVCONFIG.MainNavWidth, 1000, 0.2 )
            self.navCover.Paint = function( self2, w, h )
                draw.RoundedBoxEx( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ), false, false, true, true )
            end

            local avatarBack = vgui.Create( "DPanel", self.navCover )
            avatarBack:Dock( TOP )
            avatarBack:DockMargin( 10, 10, 0, 10 )
            avatarBack:SetTall( height )
            avatarBack.Paint = function( self2, w, h )
                surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 2 ) )
                draw.NoTexture()
                BRICKS_SERVER.Func.DrawCircle( (h-avatarBackSize)/2+(avatarBackSize/2), h/2, avatarBackSize/2, 45 )
        
                draw.SimpleText( LocalPlayer():Nick(), "BRICKS_SERVER_Font23", textStartPos, h/2+2, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_BOTTOM )
                draw.SimpleText( DarkRP.formatMoney( LocalPlayer():getDarkRPVar( "money" ) ), "BRICKS_SERVER_Font20", textStartPos, h/2-2, BRICKS_SERVER.Func.GetTheme( 5 ), 0, 0 )
            end
        
            local distance = 2
        
            local avatarIcon = vgui.Create( "bricks_server_circle_avatar" , avatarBack )
            avatarIcon:SetPos( (height-avatarBackSize)/2+distance, (height-avatarBackSize)/2+distance )
            avatarIcon:SetSize( avatarBackSize-(2*distance), avatarBackSize-(2*distance) )
            avatarIcon:SetPlayer( LocalPlayer(), 64 )

            local commandsButtonTop = vgui.Create( "DButton", self.navCover )
            commandsButtonTop:SetSize( 16, 16 )
            commandsButtonTop:SetPos( BRICKS_SERVER.DEVCONFIG.MainNavWidth-commandsButtonTop:GetWide()-5, 12 )
            commandsButtonTop:SetText( "" )
            local changeAlpha = 100
            local settingsMat = Material( "materials/bricks_server/settings_16.png" )
            commandsButtonTop.Paint = function( self2, w, h )
                if( self2:IsDown() ) then
                    changeAlpha = math.Clamp( changeAlpha+10, 100, 225 )
                elseif( self2:IsHovered() ) then
                    changeAlpha = math.Clamp( changeAlpha+10, 100, 200 )
                else
                    changeAlpha = math.Clamp( changeAlpha-10, 100, 200 )
                end
        
                surface.SetAlphaMultiplier( changeAlpha/255 )
                    surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
                    surface.SetMaterial( settingsMat )
                    surface.DrawTexturedRect( 0, 0, w, h )
                surface.SetAlphaMultiplier( 1 )
            end
            commandsButtonTop.DoClick = function()
                if( IsValid( self.navCover ) ) then
                    if( lastPage and IsValid( lastPage ) ) then
                        self.sheet:SetActiveButton( lastPage )
                    end

                    self.navCover:SizeTo( BRICKS_SERVER.DEVCONFIG.MainNavWidth, 0, 0.2, 0, 1, function()
                        if( IsValid( self.navCover ) ) then
                            self.navCover:Remove()
                        end
                    end )
                end
            end

            for k, v in pairs( BRICKS_SERVER.ESSENTIALS.LUACFG.F4Commands ) do
                if( v[3] and not v[3]( LocalPlayer() ) ) then
                    continue
                end

                local commandHeader = vgui.Create( "DPanel", self.navCover )
                commandHeader:Dock( TOP )
                commandHeader:DockMargin( 0, 5, 0, 0 )
                commandHeader:SetTall( 25 )
                commandHeader.Paint = function( self2, w, h )
                    draw.SimpleText( v[1], "BRICKS_SERVER_Font20", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                end

                for key, val in pairs( v[2] ) do
                    local commandButton = vgui.Create( "DButton", self.navCover )
                    commandButton:Dock( TOP )
                    commandButton:DockMargin( 10, 5, 10, 0 )
                    commandButton:SetTall( 35 )
                    commandButton:SetText( "" )
                    local changeAlpha = 100
                    commandButton.Paint = function( self2, w, h )
                        if( self2:IsDown() ) then
                            changeAlpha = math.Clamp( changeAlpha+10, 100, 255 )
                        elseif( self2:IsHovered() ) then
                            changeAlpha = math.Clamp( changeAlpha+10, 100, 225 )
                        else
                            changeAlpha = math.Clamp( changeAlpha-10, 100, 225 )
                        end
                
                        surface.SetAlphaMultiplier( changeAlpha/255 )
                        draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
                        draw.SimpleText( val[1], "BRICKS_SERVER_Font20", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                        surface.SetAlphaMultiplier( 1 )
                    end
                    local argumentsString = ""
                    local currentArgument = 0
                    local function loadNextRequest()
                        currentArgument = currentArgument+1

                        if( val[3][currentArgument] ) then
                            local val2 = val[3][currentArgument]
                            if( val2[1] == "number" ) then
                                BRICKS_SERVER.Func.StringRequest( "Command", (val2[2] or "What should the number be?"), 100, function( number ) 
                                    if( argumentsString == "" ) then
                                        argumentsString = number
                                    else
                                        argumentsString = argumentsString .. " " .. number
                                    end
                                    loadNextRequest()
                                end, function() end, "OK", "Cancel", true )
                            elseif( val2[1] == "players" ) then
                                local options = {}
                                for k, v in pairs( player.GetAll() ) do
                                    options[k] = v:Nick()
                                end

                                BRICKS_SERVER.Func.ComboRequest( "Command", (val2[2] or "What should the number be?"), 1, options, function( value, data ) 
                                    if( player.GetAll()[data] ) then
                                        if( argumentsString == "" ) then
                                            argumentsString = value
                                        else
                                            argumentsString = argumentsString .. " " .. value
                                        end
                                        loadNextRequest()
                                    else
                                        notification.AddLegacy( "Invalid player.", 1, 3 )
                                    end
                                end, function() end, "OK", "Cancel", true )
                            else
                                BRICKS_SERVER.Func.StringRequest( "Command", (val2[2] or "What should the number be?"), "", function( text ) 
                                    if( argumentsString == "" ) then
                                        argumentsString = text
                                    else
                                        argumentsString = argumentsString .. " " .. text
                                    end
                                    loadNextRequest()
                                end, function() end, "OK", "Cancel", false )
                            end
                        else
                            RunConsoleCommand( "say", val[2] .. " " .. argumentsString )
                        end
                    end
                    commandButton.DoClick = function()
                        if( val[3] and istable( val[3] ) ) then
                            argumentsString = ""
                            currentArgument = 0
                            loadNextRequest()
                        else
                            RunConsoleCommand( "say", val[2] )
                        end
                    end
                end
            end
        end
    end

    for k, v in pairs( (BRICKS_SERVER.CONFIG.F4 or {}).Tabs or {} ) do
        local f4TabTable = (BRICKS_SERVER.DEVCONFIG.F4Tabs[v[3] or 0] or {})
        if( not istable( v[3] ) and f4TabTable[2] ) then
            local sheetPage = vgui.Create( f4TabTable[2], self.sheet )
            if( IsValid( sheetPage ) ) then
                sheetPage:Dock( FILL )
                sheetPage.Paint = function( self, w, h ) end 
                if( f4TabTable[3] ) then f4TabTable[3]( sheetPage ) end
                if( not IsValid( sheetPage ) ) then continue end

                local sheetButton = self.sheet:AddSheet( v[1], sheetPage, false, ( v[2] or "more.png" ) )

                if( sheetPage.FillPanel ) then
                    sheetPage:FillPanel( self, sheetButton, ((ScrW()*0.6)-BRICKS_SERVER.DEVCONFIG.MainNavWidth-20) )
                end
            end
        elseif( istable( v[3] ) ) then
            local sheetPage = vgui.Create( "bricks_server_colsheet_top", self.sheet )
            sheetPage:Dock( FILL )
            sheetPage:DockMargin( 10, 10, 10, 10 )
            sheetPage.rounded = true
            local sheetButton = self.sheet:AddSheet( v[1], sheetPage, false, ( v[2] or "more.png" ) )

            for key, val in pairs( v[3] ) do
                local sheetClass = (BRICKS_SERVER.DEVCONFIG.F4Tabs[val[2] or 0] or {})[2]
                if( sheetClass ) then
                    local subSheetPage = vgui.Create( sheetClass, sheetPage )
                    if( IsValid( subSheetPage ) ) then
                        subSheetPage:Dock( FILL )
                        subSheetPage.Paint = function( self, w, h ) end 
                        sheetPage:AddSheet( val[1], subSheetPage )

                        if( subSheetPage.FillPanel ) then
                            subSheetPage:FillPanel( self, sheetButton, ((ScrW()*0.6)-BRICKS_SERVER.DEVCONFIG.MainNavWidth-20) )
                        end
                    end
                else
                    local subSheetPage = vgui.Create( "bricks_server_url", sheetPage )
                    subSheetPage:Dock( FILL )
                    sheetPage:AddSheet( val[1], subSheetPage, false, function()
                        subSheetPage:LoadURL( val[2], (ScrW()*0.6)-BRICKS_SERVER.DEVCONFIG.MainNavWidth-20 )
                    end )
                end
            end
        elseif( v[3] and isstring( v[3] ) ) then
            local sheetPage = vgui.Create( "bricks_server_url", self.sheet )
            sheetPage:Dock( FILL )
            local sheetButton = self.sheet:AddSheet( v[1], sheetPage, function() 
                sheetPage:LoadURL( v[3], (ScrW()*0.6)-BRICKS_SERVER.DEVCONFIG.MainNavWidth )
            end, ( v[2] or "more.png" ) )
        elseif( v[1] and v[1] == true ) then
            self.sheet:AddLinebreak()
        end
    end

    local settingsPage = vgui.Create( "bricks_server_settings", self.sheet )
    settingsPage:Dock( FILL )
    settingsPage:DockMargin( 10, 10, 10, 10 )
    settingsPage.Paint = function( self, w, h ) end 
    self.settingsPageButton = self.sheet:AddSheet( "Settings", settingsPage, false, "settings.png", true ).Button
    self.settingsPageButton:SetTall( 0 )
    self.settingsPageButton:DockMargin( 0, 0, 0, 0 )

    self.adminCreated = nil
    
    function self.RefreshAdminPerms()
        if( BRICKS_SERVER.Func.HasAdminAccess( LocalPlayer() ) and not self.adminCreated ) then
            self.sheet:AddLinebreak()
            
            -- PLAYERS PAGE --
            local adminPlayersPanelBack = vgui.Create( "bricks_server_admin", self.sheet )
            adminPlayersPanelBack:Dock( FILL )
            adminPlayersPanelBack.Paint = function( self, w, h ) end 
            self.sheet:AddSheet( "Players", adminPlayersPanelBack, false, "players_24.png" )

            -- MODULES PAGE --
            local adminModulesPanel = vgui.Create( "bricks_server_config_modules", self.sheet )
            adminModulesPanel:Dock( FILL )
            adminModulesPanel.Paint = function( self, w, h ) end 
            self.sheet:AddSheet( "Modules", adminModulesPanel, function()
                adminModulesPanel:FillPanel() 
            end, "modules_24.png" )

            -- CONFIG PAGE --
            local adminConfigPanel = vgui.Create( "bricks_server_config", self.sheet )
            adminConfigPanel:Dock( FILL )
            adminConfigPanel.Paint = function( self, w, h ) end 
            self.sheet:AddSheet( "Config", adminConfigPanel, function()
                adminConfigPanel:FillPanel() 
            end, "admin_24.png" )

            self.adminCreated = true
        end
    end
    self.RefreshAdminPerms()

    if( self.previousSheet ) then
        self.sheet:SetActiveSheet( self.previousSheet )
    end
end

vgui.Register( "bricks_server_f4", PANEL, "bricks_server_dframe" )