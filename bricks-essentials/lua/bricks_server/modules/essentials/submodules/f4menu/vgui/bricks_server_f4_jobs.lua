local PANEL = {}

function PANEL:Init()

end

function PANEL:FillPanel( f4Panel, sheetButton )
    local jobTopBar = vgui.Create( "DPanel", self )
    jobTopBar:Dock( TOP )
    jobTopBar:DockMargin( 10, 10, 10, 5 )
    jobTopBar:SetTall( 40 )
    jobTopBar.Paint = function( self2, w, h ) end

    local jobSortBy = vgui.Create( "bricks_server_combo", jobTopBar )
    jobSortBy:Dock( RIGHT )
    jobSortBy:DockMargin( 5, 0, 0, 0 )
    jobSortBy:SetWide( 150 )
    jobSortBy:SetValue( "Default" )
    local jobPanel
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
        jobPanel.FillJobs() 
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

    jobPanel = vgui.Create( "bricks_server_dcategorylist", self )
    jobPanel:Dock( FILL )
    jobPanel:DockMargin( 10, 0, 10, 10 )
    jobPanel.Paint = function( self, w, h ) end 

    local panelWide = ScrW()*0.6-BRICKS_SERVER.DEVCONFIG.MainNavWidth

    local spacing = 5
    local gridWide = panelWide-30
    local slotsWide = 2
    local slotWide = (gridWide-((slotsWide-1)*spacing))/slotsWide
    local slotTall = 75
    
    local function CreateJobPopout( jobKey )
        local jobTable = RPExtraTeams[jobKey] or {}

        if( IsValid( jobPanel.jobPopout ) ) then
            jobPanel.jobPopout:Remove()
        else
            local jobPopoutClose = vgui.Create( "DButton", self )
            jobPopoutClose:SetSize( panelWide, ScrH()*0.65-40 )
            jobPopoutClose:SetText( "" )
            jobPopoutClose:SetAlpha( 0 )
            jobPopoutClose:AlphaTo( 255, 0.2 )
            jobPopoutClose:SetCursor( "arrow" )
            jobPopoutClose.Paint = function( self2, w, h )
                surface.SetDrawColor( 0, 0, 0, 150 )
                surface.DrawRect( 0, 0, w, h )
                BRICKS_SERVER.Func.DrawBlur( self2, 2, 2 )
            end
            jobPopoutClose.DoClick = function()
                if( IsValid( jobPanel.jobPopout ) ) then
                    jobPanel.jobPopout:MoveTo( panelWide, 0, 0.2, 0, -1, function()
                        if( IsValid( jobPanel.jobPopout ) ) then
                            jobPanel.jobPopout:Remove()
                        end
                    end )
                end

                jobPopoutClose:AlphaTo( 0, 0.2, 0, function()
                    if( IsValid( jobPopoutClose ) ) then
                        jobPopoutClose:Remove()
                    end
                end )
            end

            local popoutWide, popoutTall = panelWide*0.475, ScrH()*0.65-40

            jobPanel.jobPopout = vgui.Create( "DPanel", self )
            jobPanel.jobPopout:SetSize( popoutWide, popoutTall )
            jobPanel.jobPopout:SetPos( panelWide, 0 )
            jobPanel.jobPopout:MoveTo( panelWide-popoutWide, 0, 0.2 )
            jobPanel.jobPopout.Paint = function( self2, w, h )
                surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 2 ) )
                surface.DrawRect( 0, 0, w, h )
            end

            local jobDescription = vgui.Create( "DButton", jobPanel.jobPopout )
            jobDescription:SetSize( 40, 40 )
            jobDescription:SetPos( popoutWide-jobDescription:GetWide(), 0 )
            jobDescription:SetText( "" )
            local changeAlpha = 0
            local infoMat = Material( "materials/bricks_server/info.png" )
            jobDescription.Paint = function( self2, w, h )
                if( self2:IsDown() ) then
                    changeAlpha = math.Clamp( changeAlpha+10, 0, 125 )
                elseif( self2:IsHovered() ) then
                    changeAlpha = math.Clamp( changeAlpha+10, 0, 75 )
                else
                    changeAlpha = math.Clamp( changeAlpha-10, 0, 75 )
                end

                draw.RoundedBoxEx( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ), false, false, true, false )

                surface.SetAlphaMultiplier( changeAlpha/255 )
                draw.RoundedBoxEx( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 5 ), false, false, true, false )
                surface.SetAlphaMultiplier( 1 )

                local size = 24
                surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
                surface.SetMaterial( infoMat )
                surface.DrawTexturedRect( (w/2)-(size/2), (h/2)-(size/2), size, size )
            end
            jobDescription.DoClick = function()
                if( IsValid( jobPanel.jobPopout.Description ) ) then
                    jobPanel.jobPopout.Description:Remove()
                end

                jobPanel.jobPopout.Description = vgui.Create( "DButton", jobPanel.jobPopout )
                jobPanel.jobPopout.Description:SetSize( popoutWide, popoutTall )
                jobPanel.jobPopout.Description:SetPos( 0, 0 )
                jobPanel.jobPopout.Description:SetText( "" )
                jobPanel.jobPopout.Description:SetCursor( "arrow" )
                jobPanel.jobPopout.Description:SetAlpha( 0 )
                jobPanel.jobPopout.Description:AlphaTo( 255, 0.2 )
                jobPanel.jobPopout.Description.Paint = function( self2, w, h )
                    surface.SetDrawColor( 0, 0, 0, 50 )
                    surface.DrawRect( 0, 0, w, h )
                    BRICKS_SERVER.Func.DrawBlur( self2, 1, 1 )
                end
                local descriptionBack
                jobPanel.jobPopout.Description.DoClick = function()
                    jobPanel.jobPopout.Description:AlphaTo( 0, 0.2, 0, function()
                        if( IsValid( jobPanel.jobPopout.Description ) ) then
                            jobPanel.jobPopout.Description:Remove()
                        end
                    end )

                    descriptionBack:SizeTo( 0, 0, 0.2 )
                end

                local descriptionW, descriptionH = popoutWide*0.75, popoutTall*0.75
                descriptionBack = vgui.Create( "DPanel", jobPanel.jobPopout.Description )
                descriptionBack:SetSize( 0, 0 )
                descriptionBack:SetPos( 0, 0 )
                descriptionBack:SizeTo( descriptionW, descriptionH, 0.2 )
                descriptionBack.Paint = function( self2, w, h )
                    draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 1 ) )

                    local description = DarkRP.textWrap( (jobTable.description or "No description"), "BRICKS_SERVER_Font20", w-20 )

                    draw.DrawNonParsedText( description, "BRICKS_SERVER_Font20", 10, 10, BRICKS_SERVER.Func.GetTheme( 6 ), 0 )
                end
                descriptionBack.OnSizeChanged = function( self2 )
                    self2:SetPos( (jobPanel.jobPopout:GetWide()/2)-(self2:GetWide()/2), (jobPanel.jobPopout:GetTall()/2)-(self2:GetTall()/2) )
                end
            end

            local jobAction = vgui.Create( "DButton", jobPanel.jobPopout )
            jobAction:Dock( BOTTOM )
            jobAction:SetTall( 40 )
            jobAction:SetText( "" )
            jobAction:DockMargin( 25, 25, 25, 25 )
            local changeAlpha = 0
            jobAction.Paint = function( self2, w, h )
                if( self2:IsDown() ) then
                    changeAlpha = math.Clamp( changeAlpha+10, 0, 125 )
                elseif( self2:IsHovered() ) then
                    changeAlpha = math.Clamp( changeAlpha+10, 0, 75 )
                else
                    changeAlpha = math.Clamp( changeAlpha-10, 0, 75 )
                end
                
                draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 5 ) )
        
                surface.SetAlphaMultiplier( changeAlpha/255 )
                draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 4 ) )
                surface.SetAlphaMultiplier( 1 )
                
                if( not jobTable.vote ) then
                    draw.SimpleText( "Become", "BRICKS_SERVER_Font20", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                else
                    draw.SimpleText( "Vote", "BRICKS_SERVER_Font20", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                end
            end
            jobAction.DoClick = function()
                if( not jobTable.vote ) then
                    RunConsoleCommand( "say", "/" .. jobTable.command )
                else
                    RunConsoleCommand( "say", "/vote" .. jobTable.command )
                end

                jobPanel.jobPopout:MoveTo( panelWide, 0, 0.2, 0, -1, function()
                    if( IsValid( jobPanel.jobPopout ) ) then
                        jobPanel.jobPopout:Remove()
                    end
                end )

                jobPopoutClose:AlphaTo( 0, 0.2, 0, function()
                    if( IsValid( jobPopoutClose ) ) then
                        jobPopoutClose:Remove()
                    end
                end )
            end

            local jobIcon
            local currentModel = ""
            if( istable( jobTable.model ) ) then
                currentModel = jobTable.model[1]

                if( #jobTable.model > 1 ) then
                    local modelChoiceBack = vgui.Create( "DIconLayout", jobPanel.jobPopout )
                    modelChoiceBack:Dock( BOTTOM )
                    modelChoiceBack:SetTall( 0 )
                    modelChoiceBack:SetSpaceY( spacing )
                    modelChoiceBack:SetSpaceX( spacing )

                    local spacing = 5
                    local gridWide = jobPanel.jobPopout:GetWide()-50
                    local slotSize = 30
                    local slotsWide = math.floor( gridWide/slotSize )

                    local slotsTall = math.ceil( #jobTable.model/slotsWide )
                    modelChoiceBack:SetTall( (slotsTall*slotSize)+((slotsTall-1)*spacing) )

                    local sideMargin = math.max( (gridWide-((#jobTable.model*slotSize)+((#jobTable.model-1)*spacing)))/2, 0 )
                    modelChoiceBack:DockMargin( 25+sideMargin, 0, 25+sideMargin, 0 )

                    for k, v in pairs( jobTable.model ) do
                        local modelEntryButton = vgui.Create( "DPanel", modelChoiceBack )
                        modelEntryButton:SetSize( slotSize, slotSize )
                        local changeAlpha = 0
                        local modelEntryIcon
                        modelEntryButton.Paint = function( self2, w, h )
                            if( modelEntryIcon:IsDown() ) then
                                changeAlpha = math.Clamp( changeAlpha+10, 0, 125 )
                            elseif( modelEntryIcon:IsHovered() ) then
                                changeAlpha = math.Clamp( changeAlpha+10, 0, 75 )
                            else
                                changeAlpha = math.Clamp( changeAlpha-10, 0, 75 )
                            end
                            
                            draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
                    
                            surface.SetAlphaMultiplier( changeAlpha/255 )
                            draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 5 ) )
                            surface.SetAlphaMultiplier( 1 )
                        end

                        modelEntryIcon = vgui.Create( "DModelPanel" , modelEntryButton )
                        modelEntryIcon:Dock( FILL )
                        modelEntryIcon:SetModel( v )
                        function modelEntryIcon:LayoutEntity(ent) return end
                        local eyepos = modelEntryIcon.Entity:GetBonePosition( (modelEntryIcon.Entity:LookupBone("ValveBiped.Bip01_Head1") or 1) ) or Vector( 0, 0, 0 )
                        eyepos:Add(Vector(0, 0, 2))	-- Move up slightly
                        modelEntryIcon:SetLookAt(eyepos)
                        modelEntryIcon:SetCamPos(eyepos-Vector(-20, 0, 0))	-- Move cam in front of eyes
                        modelEntryIcon.Entity:SetEyeTarget(eyepos-Vector(-12, 0, 0))
                        modelEntryIcon.DoClick = function()
                            DarkRP.setPreferredJobModel( jobKey, v )
                            currentModel = v
                            jobIcon:SetModel( currentModel )
                        end
                    end
                end
            else
                currentModel = jobTable.model
            end

            local topMargin, bottomMargin = popoutTall*0.075, 145
            surface.SetFont( "BRICKS_SERVER_Font20" )
            local textX, textY = surface.GetTextSize( "TEST" )

            jobIcon = vgui.Create( "DModelPanel" , jobPanel.jobPopout )
            jobIcon:Dock( FILL )
            jobIcon:DockMargin( 0, topMargin+5+28+textY, 0, 5 )
            jobIcon:SetModel( currentModel )
            function jobIcon:LayoutEntity(ent) return end
            jobIcon:SetFOV( 70 )

            local jobInfoDisplay = vgui.Create( "DPanel", jobPanel.jobPopout )
            jobInfoDisplay:SetSize( popoutWide, popoutTall-topMargin-bottomMargin )
            jobInfoDisplay:SetPos( popoutWide-jobInfoDisplay:GetWide(), topMargin )
            jobInfoDisplay.Paint = function( self2, w, h ) 
                draw.SimpleText( jobTable.name, "BRICKS_SERVER_Font25", w/2, 5, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, 0 )
            end

            local jobInfoNoticeBack = vgui.Create( "DPanel", jobInfoDisplay )
            jobInfoNoticeBack:SetSize( 0, 35 )
            jobInfoNoticeBack:SetPos( (jobInfoDisplay:GetWide()/2)-(jobInfoNoticeBack:GetWide()/2), 5+28 )
            jobInfoNoticeBack.Paint = function( self2, w, h ) end

            local jobNotices = {}

            if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "levelling" ) ) then
                local jobLevel = BRICKS_SERVER.CONFIG.LEVELING.JobLevels[jobTable.command or "error"]
                if( jobLevel ) then
                    table.insert( jobNotices, { "Level " .. jobLevel } )
                end
            end

            local jobGroup = (BRICKS_SERVER.CONFIG.GENERAL.JobGroups or {})[jobTable.command or "error"]
            if( jobGroup ) then
                local groupTable
                for k, v in pairs( BRICKS_SERVER.CONFIG.GENERAL.Groups ) do
                    if( v[1] == jobGroup ) then
                        groupTable = v
                    end
                end

                if( groupTable ) then
                    table.insert( jobNotices, { (groupTable[1] or "None"), groupTable[3] } )
                end
            end

            for k, v in pairs( jobNotices ) do
                surface.SetFont( "BRICKS_SERVER_Font20" )
                local textX, textY = surface.GetTextSize( v[1] )
                local boxW, boxH = textX+10, textY

                local jobInfoNotice = vgui.Create( "DPanel", jobInfoNoticeBack )
                jobInfoNotice:Dock( LEFT )
                jobInfoNotice:DockMargin( 0, 0, 5, 0 )
                jobInfoNotice:SetWide( boxW )
                jobInfoNotice.Paint = function( self2, w, h ) 
                    draw.RoundedBox( 5, 0, 0, w, h, (v[2] or BRICKS_SERVER.Func.GetTheme( 5 )) )
                    draw.SimpleText( v[1], "BRICKS_SERVER_Font20", w/2, (h/2)-1, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                end

                if( jobInfoNoticeBack:GetWide() <= 5 ) then
                    jobInfoNoticeBack:SetSize( jobInfoNoticeBack:GetWide()+boxW, boxH )
                else
                    jobInfoNoticeBack:SetSize( jobInfoNoticeBack:GetWide()+5+boxW, boxH )
                end
                jobInfoNoticeBack:SetPos( (jobInfoDisplay:GetWide()/2)-(jobInfoNoticeBack:GetWide()/2), 5+28 )
            end

            local weaponListBack = vgui.Create( "bricks_server_scrollpanel", jobInfoDisplay )
            weaponListBack:Dock( RIGHT )
            weaponListBack:SetWide( 50 )
            weaponListBack:DockMargin( 0, 75, 25, 0 )
            weaponListBack.Paint = function( self2, w, h ) end

            for k, v in pairs( jobTable.weapons or {} ) do
                local itemName = "Unknown"
                if( (list.Get( "Weapon" ) or {})[v] and (list.Get( "Weapon" ) or {})[v].PrintName ) then
                    itemName = (list.Get( "Weapon" ) or {})[v].PrintName
                end

                local modelEntryButton = vgui.Create( "DPanel", weaponListBack )
                modelEntryButton:Dock( TOP )
                modelEntryButton:SetTall( weaponListBack:GetWide() )
                modelEntryButton:DockMargin( 0, 0, 0, 5 )
                local changeAlpha = 0
                local modelEntryIcon
                local x, y, w, h = 0, 0, modelEntryButton:GetTall(), modelEntryButton:GetTall()
                modelEntryButton.Paint = function( self2, w, h )
                    local toScreenX, toScreenY = self2:LocalToScreen( 0, 0 )
                    if( x != toScreenX or y != toScreenY ) then
                        x, y = toScreenX, toScreenY
        
                        modelEntryIcon:SetBRSToolTip( x, y, w, h, itemName )
                    end

                    if( modelEntryIcon:IsDown() ) then
                        changeAlpha = math.Clamp( changeAlpha+10, 0, 125 )
                    elseif( modelEntryIcon:IsHovered() ) then
                        changeAlpha = math.Clamp( changeAlpha+10, 0, 75 )
                    else
                        changeAlpha = math.Clamp( changeAlpha-10, 0, 75 )
                    end
                    
                    draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
            
                    surface.SetAlphaMultiplier( changeAlpha/255 )
                    draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 5 ) )
                    surface.SetAlphaMultiplier( 1 )
                end

                local model = "error.model"
                local weaponModel = BRICKS_SERVER.Func.GetWeaponModel( v )
                if( weaponModel ) then
                    model = weaponModel
                end

                modelEntryIcon = vgui.Create( "DModelPanel" , modelEntryButton )
                modelEntryIcon:Dock( FILL )
                modelEntryIcon:SetModel( model )
                if( modelEntryIcon.Entity and IsValid( modelEntryIcon.Entity ) ) then
                    function modelEntryIcon:LayoutEntity(ent) return end
                    local mn, mx = modelEntryIcon.Entity:GetRenderBounds()
                    local size = 0
                    size = math.max( size, math.abs(mn.x) + math.abs(mx.x) )
                    size = math.max( size, math.abs(mn.y) + math.abs(mx.y) )
                    size = math.max( size, math.abs(mn.z) + math.abs(mx.z) )
            
                    modelEntryIcon:SetFOV( 50 )
                    modelEntryIcon:SetCamPos( Vector( size, size, size ) )
                    modelEntryIcon:SetLookAt( (mn + mx) * 0.5 )
                end
            end
        end
    end

    local scroll
    function jobPanel.FillJobs()
        scroll = jobPanel.VBar:GetScroll() or 0

        jobPanel:Clear()

        local JobsOrdered, categoriesUsed = {}, {}
        for k, v in pairs( RPExtraTeams ) do
            if( (jobSearchBar:GetValue() != "" and not string.find( string.lower( v.name ), string.lower( jobSearchBar:GetValue() ) )) ) then
                continue
            end

            if( v.customCheck and not v.customCheck( LocalPlayer() ) ) then continue end

            local sortValue = 0

            if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "levelling" ) ) then
                sortValue = BRICKS_SERVER.CONFIG.LEVELING.JobLevels[v.command or "error"] or 0
            end

            if( jobSortChoice and jobSortChoice != "default" and string.StartWith( jobSortChoice, "salary" ) ) then
                sortValue = v.salary or 0
            elseif( jobSortChoice and jobSortChoice == "default" ) then
                sortValue = v.sortOrder or 0
            end

            table.insert( JobsOrdered, { k, sortValue } )

            if( not categoriesUsed[v.category] ) then
                categoriesUsed[v.category] = true
            end
        end

        if( jobSortChoice and jobSortChoice != "default" ) then
            if( jobSortChoice and string.EndsWith( jobSortChoice, "high_to_low" ) ) then
                table.SortByMember( JobsOrdered, 2, false )
            else
                table.SortByMember( JobsOrdered, 2, true )
            end
        else
            table.SortByMember( JobsOrdered, 2, false )
        end

        local categories = {}
        local function createCategory( name, color )
            categories[name] = jobPanel:Add( name, color )
            categories[name]:SetTall( 40 )

            categories[name].grid = vgui.Create( "DIconLayout", categories[name] )
            categories[name].grid:Dock( FILL )
            categories[name].grid:DockMargin( 5, spacing, 0, 0 )
            categories[name].grid:SetTall( slotTall )
            categories[name].grid:SetSpaceY( spacing )
            categories[name].grid:SetSpaceX( spacing )
        end

        local sortedCategories = {}
        for k, v in pairs( DarkRP.getCategories().jobs ) do
            if( not categoriesUsed[v.name] or (v.canSee and not v.canSee( LocalPlayer() )) ) then continue end

            table.insert( sortedCategories, { v.name, v.color, (v.sortOrder or 100) } )
        end

        table.sort( sortedCategories, function(a, b) return (a[3] or 100) < (b[3] or 100) end )

        for k, v in pairs( sortedCategories ) do
            createCategory( v[1], v[2] )
        end

        for k, v in pairs( JobsOrdered ) do
            local jobTable = RPExtraTeams[(v[1] or 0)]

            local jobCategory = categories[jobTable.category or "Other"] or categories["Other"]
            if( not IsValid( jobCategory ) ) then continue end

            jobCategory.slots = (jobCategory.slots or 0)+1
            local slots = jobCategory.slots
            local slotsTall = math.ceil( slots/slotsWide )
            jobCategory:SetTall( 40+10+(slotsTall*slotTall)+((slotsTall-1)*spacing) )
            jobCategory.grid:SetTall( (slotsTall*slotTall)+((slotsTall-1)*spacing) )

            local jobLevel = BRICKS_SERVER.CONFIG.LEVELING.JobLevels[jobTable.command or "error"] or 0
            local jobBack = jobCategory.grid:Add( "DPanel" )
            jobBack:SetSize( slotWide, slotTall )
            local circleRadius = (slotTall-20)/2
            local jobMax = jobTable.max or 0
            local oldDegree = 0
            local cachedArc
            jobBack.Paint = function( self2, w, h )
                local currentPlayersInTeam = team.NumPlayers( v[1] or 0 ) or 0
                
                draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
                draw.RoundedBox( 5, 5, 5, h-10, h-10, BRICKS_SERVER.Func.GetTheme( 2 ) )

                draw.SimpleText( jobTable.name, "BRICKS_SERVER_Font30", h+10, h/2+2, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_BOTTOM )

                draw.SimpleText( "Salary: " .. DarkRP.formatMoney( jobTable.salary ), "BRICKS_SERVER_Font20", h+10, h/2-2, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )

                BRICKS_SERVER.Func.DrawCircle( w-10-circleRadius, h/2, circleRadius, BRICKS_SERVER.Func.GetTheme( 2 ) )

                local degree = math.Clamp( (currentPlayersInTeam/jobMax), 0, 1 )*360
                if( not cachedArc or oldDegree != degree ) then
                    cachedArc = BRICKS_SERVER.Func.PrecachedArc(  w-10-circleRadius, h/2, circleRadius, 2, -90, degree-90 )
                end

                BRICKS_SERVER.Func.DrawCachedArc( cachedArc, BRICKS_SERVER.Func.GetTheme( 4 ) )

                if( jobMax > 0 ) then
                    draw.SimpleText( currentPlayersInTeam .. "/" .. jobMax, "BRICKS_SERVER_Font20", w-10-circleRadius, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                else
                    draw.SimpleText( currentPlayersInTeam .. "/∞", "BRICKS_SERVER_Font20", w-10-circleRadius, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                end
            end

            if( (BRICKS_SERVER.CONFIG.GENERAL["F4 Use Spawn Icons"] or false) == true ) then
                local jobIcon = vgui.Create( "SpawnIcon" , jobBack )
                jobIcon:SetPos( 5, 5 )
                jobIcon:SetSize( jobBack:GetTall()-10, jobBack:GetTall()-10 )
                if( istable( jobTable.model ) ) then
                    jobIcon:SetModel( jobTable.model[1] )
                else
                    jobIcon:SetModel( jobTable.model )
                end
            else
                local jobIcon = vgui.Create( "DModelPanel" , jobBack )
                jobIcon:SetPos( 5, 5 )
                jobIcon:SetSize( jobBack:GetTall()-10, jobBack:GetTall()-10 )
                if( istable( jobTable.model ) ) then
                    jobIcon:SetModel( jobTable.model[1] )
                else
                    jobIcon:SetModel( jobTable.model )
                end
                function jobIcon:LayoutEntity(ent) return end

                if( IsValid( jobIcon.Entity ) ) then
                    local eyepos = jobIcon.Entity:GetBonePosition( (jobIcon.Entity:LookupBone("ValveBiped.Bip01_Head1") or 1) ) or Vector( 0, 0, 0 )
                    eyepos:Add(Vector(0, 0, 2))	-- Move up slightly
                    jobIcon:SetLookAt(eyepos)
                    jobIcon:SetCamPos(eyepos-Vector(-20, 0, 0))	-- Move cam in front of eyes
                    jobIcon.Entity:SetEyeTarget(eyepos-Vector(-12, 0, 0))
                end
            end

            local jobButton = vgui.Create( "DButton", jobBack )
            jobButton:SetPos( 0, 0 )
            jobButton:SetSize( slotWide, jobBack:GetTall() )
            jobButton:SetText( "" )
            local changeAlpha = 0
            jobButton.Paint = function( self2, w, h ) 
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
            jobButton.DoClick = function()
                CreateJobPopout( v[1] or 0 )
            end
        end

        for k, v in pairs( categories ) do
            for key, val in pairs( DarkRP.getCategories().jobs ) do
                if( k == val.name ) then
                    v:SetExpanded( val.startExpanded )
                end
            end
        end

        if( scroll ) then
            jobPanel.VBar:AnimateTo( scroll, 0 )
        end
    end
    jobPanel.FillJobs()

    jobSearchBar.OnChange = function()
        jobPanel.FillJobs()
    end

    hook.Add( "OnPlayerChangedTeam", "BRS.OnPlayerChangedTeam_F4Jobs", function()
        timer.Simple( 0.25, function()
            if( IsValid( jobPanel ) ) then
                jobPanel.FillJobs()
            end
        end )
    end )
end

function PANEL:Paint( w, h )

end

vgui.Register( "bricks_server_f4_jobs", PANEL, "DPanel" )