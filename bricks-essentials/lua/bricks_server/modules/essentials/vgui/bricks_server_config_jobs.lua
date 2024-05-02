local PANEL = {}

function PANEL:Init()

end

function PANEL:FillPanel()
    local jobActions = {
        ["Edit group"] = function( k, v, jobTable )
            local options = {
                ["None"] = "None"
            }
            
            for k, v in pairs( (BS_ConfigCopyTable or BRICKS_SERVER.CONFIG).GENERAL.Groups ) do
                options[k] = v[1]
            end
            BRICKS_SERVER.Func.ComboRequest( "Admin", "What group would you like this job to be?", (((BS_ConfigCopyTable or BRICKS_SERVER.CONFIG).GENERAL.JobGroups or {})[jobTable.command] or ""), options, function( value, data ) 
                BS_ConfigCopyTable.GENERAL.JobGroups = BS_ConfigCopyTable.GENERAL.JobGroups or {}
                if( value != "None" and (BS_ConfigCopyTable or BRICKS_SERVER.CONFIG).GENERAL.Groups[data] ) then
                    BS_ConfigCopyTable.GENERAL.JobGroups[jobTable.command] = value
                    self.RefreshPanel()
                    BRICKS_SERVER.Func.ConfigChange( "GENERAL" )
                elseif( value == "None" or value == "" ) then
                    BS_ConfigCopyTable.GENERAL.JobGroups[jobTable.command] = nil
                    self.RefreshPanel()
                    BRICKS_SERVER.Func.ConfigChange( "GENERAL" )
                else
                    notification.AddLegacy( "Invalid group.", 1, 3 )
                end
            end, function() end, "OK", "Cancel" )
        end
    }

    if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "levelling" ) ) then
        jobActions["Edit level"] = function( k, v, jobTable )
            BRICKS_SERVER.Func.StringRequest( "Admin", "What level would you like this job to be?", (BS_ConfigCopyTable.LEVELING.JobLevels[jobTable.command] or 0), function( text ) 
                if( isnumber( tonumber( text ) ) ) then
                    BS_ConfigCopyTable.LEVELING.JobLevels[jobTable.command] = tonumber( text )
                    self.RefreshPanel()
                    BRICKS_SERVER.Func.ConfigChange( "LEVELING" )
                else
                    notification.AddLegacy( "Invalid number.", 1, 3 )
                end
            end, function() end, "OK", "Cancel", true )
        end
    end

    local jobTopBar = vgui.Create( "DPanel", self )
    jobTopBar:Dock( TOP )
    jobTopBar:DockMargin( 0, 0, 0, 5 )
    jobTopBar:SetTall( 40 )
    jobTopBar.Paint = function( self2, w, h ) end

    local jobSortBy = vgui.Create( "bricks_server_combo", jobTopBar )
    jobSortBy:Dock( RIGHT )
    jobSortBy:DockMargin( 5, 0, 0, 0 )
    jobSortBy:SetWide( 150 )
    jobSortBy:SetValue( "Default" )
    local jobSortChoice = "default"
    jobSortBy:AddChoice( "Default", "default" )
    if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "levelling" ) ) then
        jobSortBy:AddChoice( "Lowest Level", "level_low_to_high" )
        jobSortBy:AddChoice( "Highest Level", "level_high_to_low" )
    end
    jobSortBy:AddChoice( "Lowest Salary", "salary_low_to_high" )
    jobSortBy:AddChoice( "Highest Salary", "salary_high_to_low" )
    jobSortBy.OnSelect = function( self2, index, value, data )
        jobSortChoice = data
        self.RefreshPanel() 
    end

    local jobSearchBarBack = vgui.Create( "DPanel", jobTopBar )
    jobSearchBarBack:Dock( FILL )
    local search = Material( "materials/bricks_server/search.png" )
    local Alpha = 0
    local Alpha2 = 20
    local jobSearchBar
    local color1 = BRICKS_SERVER.Func.GetTheme( 2 )
    jobSearchBarBack.Paint = function( self2, w, h )
        draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )

        if( jobSearchBar:IsEditing() ) then
            Alpha = math.Clamp( Alpha+5, 0, 100 )
            Alpha2 = math.Clamp( Alpha2+20, 20, 255 )
        else
            Alpha = math.Clamp( Alpha-5, 0, 100 )
            Alpha2 = math.Clamp( Alpha2-20, 20, 255 )
        end
        
        draw.RoundedBox( 5, 0, 0, w, h, Color( color1.r, color1.g, color1.b, Alpha ) )
    
        surface.SetDrawColor( 255, 255, 255, Alpha2 )
        surface.SetMaterial(search)
        local size = 24
        surface.DrawTexturedRect( w-size-(h-size)/2, (h-size)/2, size, size )
    end
    
    jobSearchBar = vgui.Create( "bricks_server_search", jobSearchBarBack )
    jobSearchBar:Dock( FILL )

    local jobPanel = vgui.Create( "bricks_server_scrollpanel", self )
    jobPanel:Dock( FILL )

    function self.RefreshPanel()
        jobPanel:Clear()

        local JobsOrdered = {}
        for k, v in pairs( RPExtraTeams ) do
            if( (jobSearchBar:GetValue() != "" and not string.find( string.lower( v.name ), string.lower( jobSearchBar:GetValue() ) )) ) then
                continue
            end

            local sortValue = 0

            if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "levelling" ) ) then
                sortValue = BS_ConfigCopyTable.LEVELING.JobLevels[v.command or "error"] or 0
            end

            if( jobSortChoice and string.StartWith( jobSortChoice, "salary" ) ) then
                sortValue = v.salary or 0
            end

            table.insert( JobsOrdered, { k, sortValue } )
        end

        if( jobSortChoice != "default" ) then
            if( jobSortChoice and string.EndsWith( jobSortChoice, "high_to_low" ) ) then
                table.SortByMember( JobsOrdered, 2, false )
            else
                table.SortByMember( JobsOrdered, 2, true )
            end
        end

        for k, v in ipairs( JobsOrdered ) do
            if( RPExtraTeams[v[1]] ) then
                local jobTable = RPExtraTeams[v[1]]
                local jobLevel = BS_ConfigCopyTable.LEVELING.JobLevels[jobTable.command or "error"]
                local jobBack = vgui.Create( "DPanel", jobPanel )
                jobBack:Dock( TOP )
                jobBack:DockMargin( 0, 0, 0, 5 )
                jobBack:DockPadding( 0, 0, 25, 0 )
                jobBack:SetTall( 100 )
                jobBack.Paint = function( self2, w, h )
                    draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
                    draw.RoundedBox( 5, 5, 5, h-10, h-10, BRICKS_SERVER.Func.GetTheme( 2 ) )

                    if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "levelling" ) and jobLevel ) then
                        draw.SimpleText( jobTable.name .. " - Level " .. jobLevel, "BRICKS_SERVER_Font33", h+15, 5, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
                    else
                        draw.SimpleText( jobTable.name, "BRICKS_SERVER_Font33", h+15, 5, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
                    end

                    draw.SimpleText( "Salary: " .. DarkRP.formatMoney( jobTable.salary ), "BRICKS_SERVER_Font20", h+18, 32, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
                end

                local jobIcon = vgui.Create( "SpawnIcon" , jobBack )
                jobIcon:SetPos( 5, 5 )
                jobIcon:SetSize( jobBack:GetTall()-10, jobBack:GetTall()-10 )
                if( istable( jobTable.model ) ) then
                    jobIcon:SetModel( jobTable.model[1] )
                else
                    jobIcon:SetModel( jobTable.model )
                end

                local jobButton = vgui.Create( "DPanel", jobBack )
                jobButton:Dock( LEFT )
                jobButton:SetWide( jobBack:GetTall() )
                jobButton.Paint = function( self2, w, h ) end

                for key2, val2 in pairs( jobActions ) do
                    local jobAction = vgui.Create( "DButton", jobBack )
                    jobAction:Dock( RIGHT )
                    jobAction:SetText( "" )
                    jobAction:DockMargin( 5, 25, 0, 25 )
                    surface.SetFont( "BRICKS_SERVER_Font25" )
                    local textX, textY = surface.GetTextSize( key2 )
                    textX = textX+20
                    jobAction:SetWide( math.max( (ScrW()/2560)*150, textX ) )
                    local changeAlpha = 0
                    jobAction.Paint = function( self2, w, h )
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
                
                        draw.SimpleText( key2, "BRICKS_SERVER_Font25", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                    end
                    jobAction.DoClick = function()
                        val2( k, v, jobTable )
                    end
                end
            end
        end
    end
    self.RefreshPanel()

    jobSearchBar.OnChange = function()
        self.RefreshPanel()
    end
end

function PANEL:Paint( w, h )
    
end

vgui.Register( "bricks_server_config_jobs", PANEL, "DPanel" )