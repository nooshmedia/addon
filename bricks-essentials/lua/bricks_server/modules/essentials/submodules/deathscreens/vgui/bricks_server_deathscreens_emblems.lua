local PANEL = {}

function PANEL:Init()

end

local spacing = 5
local gridWide = (ScrW()*0.6)-BRICKS_SERVER.DEVCONFIG.MainNavWidth-30

local slotsWide = (ScrW() >= 1080 and 2) or 1
local slotWide = (gridWide-((slotsWide-1)*spacing))/slotsWide
local slotTall = slotWide/4

local emblemSlotsWide = 3
local emblemSlotSize = (gridWide-((emblemSlotsWide-1)*spacing))/emblemSlotsWide

function PANEL:FillPanel()
    self:Clear()

    local topBar = vgui.Create( "DPanel", self )
    topBar:Dock( TOP )
    topBar:DockMargin( 0, 0, 0, 5 )
    topBar:SetTall( 40 )
    topBar.Paint = function( self2, w, h ) end

    local sortBy = vgui.Create( "bricks_server_combo", topBar )
    sortBy:Dock( RIGHT )
    sortBy:DockMargin( 5, 0, 0, 0 )
    sortBy:SetWide( 150 )
    sortBy:SetValue( "Lowest Level" )
    local sortChoice = "level_low_to_high"
    if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "levelling" ) ) then
        sortBy:AddChoice( "Lowest Level", "level_low_to_high" )
        sortBy:AddChoice( "Highest Level", "level_high_to_low" )
    end
    sortBy:AddChoice( "Lowest Price", "price_low_to_high" )
    sortBy:AddChoice( "Highest Price", "price_high_to_low" )
    sortBy.OnSelect = function( self2, index, value, data )
        sortChoice = data
        self.RefreshItems()
    end

    local searchBarBack = vgui.Create( "DPanel", topBar )
    searchBarBack:Dock( FILL )
    local search = Material( "materials/bricks_server/search.png" )
    local Alpha = 0
    local Alpha2 = 20
    local searchBar
    local color1 = BRICKS_SERVER.Func.GetTheme( 2 )
    searchBarBack.Paint = function( self2, w, h )
        draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )

        if( searchBar:IsEditing() ) then
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
    
    searchBar = vgui.Create( "bricks_server_search", searchBarBack )
    searchBar:Dock( FILL )

    local categoryList = vgui.Create( "bricks_server_dcategorylist", self )
    categoryList:Dock( FILL )
    categoryList.Paint = function( self, w, h ) end 

    function self.RefreshItems()
        categoryList:Clear()

        local itemsOrdered = {}
        for k, v in pairs( BRICKS_SERVER.CONFIG.DEATHSCREENS.Emblems ) do
            if( (searchBar:GetValue() != "" and not string.find( string.lower( v.Name or "New" ), string.lower( searchBar:GetValue() ) )) ) then
                continue
            end

            local sortValue = 0
            if( sortChoice and string.StartWith( sortChoice, "price" ) ) then
                sortValue = v.Price or 0
            elseif( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "levelling" ) and v.Level ) then
                sortValue = v.Level or 0
            end

            table.insert( itemsOrdered, { k, sortValue } )
        end

        if( sortChoice and string.EndsWith( sortChoice, "high_to_low" ) ) then
            table.SortByMember( itemsOrdered, 2, false )
        else
            table.SortByMember( itemsOrdered, 2, true )
        end

        local categories = {}

        for k, v in pairs( itemsOrdered ) do
            local itemKey = v[1]
            local itemTable = BRICKS_SERVER.CONFIG.DEATHSCREENS.Emblems[itemKey]

            local itemCategory = itemTable.Category or "Other"
            if( not categories[itemCategory] ) then
                local categoryColor = BRICKS_SERVER.Func.GetTheme( 4 )

                categories[itemCategory] = categoryList:Add( itemCategory, categoryColor )
                categories[itemCategory]:SetTall( 40 )

                categories[itemCategory].grid = vgui.Create( "DIconLayout", categories[itemCategory] )
                categories[itemCategory].grid:Dock( FILL )
                categories[itemCategory].grid:DockMargin( 5, spacing, 0, 0 )
                categories[itemCategory].grid:SetTall( slotTall )
                categories[itemCategory].grid:SetSpaceY( spacing )
                categories[itemCategory].grid:SetSpaceX( spacing )
            end

            categories[itemCategory].slots = (categories[itemCategory].slots or 0)+1
            local slots = categories[itemCategory].slots
            local slotsTall = math.ceil( slots/emblemSlotsWide )
            categories[itemCategory]:SetTall( 40+10+(slotsTall*slotTall)+((slotsTall-1)*spacing) )
            categories[itemCategory].grid:SetTall( (slotsTall*slotTall)+((slotsTall-1)*spacing) )

            local itemBack = categories[itemCategory].grid:Add( "DPanel" )
            itemBack:SetSize( emblemSlotSize, slotTall )
            local emblemMat
            if( itemTable.Image ) then
                BRICKS_SERVER.Func.GetImage( itemTable.Image or "", function( mat ) emblemMat = mat end )
            end
            local boughtMat = Material( "materials/bricks_server/tick.png" )
            itemBack.Paint = function( self2, w, h )
                draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )

                if( itemTable.Image and emblemMat ) then
                    surface.SetDrawColor( 255, 255, 255, 255 )
                    surface.SetMaterial( emblemMat )
                    local iconSize = h*0.5
                    surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
                end

                if( BRS_DEATHSCREENS_DATA and BRS_DEATHSCREENS_DATA[2] and BRS_DEATHSCREENS_DATA[2][itemKey] ) then
                    if( BRS_DEATHSCREENS_DATA[2][itemKey][1] == true ) then
                        surface.SetDrawColor( BRICKS_SERVER.DEVCONFIG.BaseThemes.Green )
                    else
                        surface.SetDrawColor( 255, 255, 255, 255 )
                    end
                    surface.SetMaterial( boughtMat )
                    local iconSize = 24
                    surface.DrawTexturedRect( w-15-iconSize, 15, iconSize, iconSize )
                end

                surface.SetFont( "BRICKS_SERVER_Font25" )
                local textX, textY = surface.GetTextSize( itemTable.Name or "New Emblem" )
                local boxW, boxH = textX+10, textY

                draw.RoundedBox( 5, 15, 15, boxW, boxH, BRICKS_SERVER.Func.GetTheme( 5 ) )
                draw.SimpleText( itemTable.Name or "New Emblem", "BRICKS_SERVER_Font25", 15+(boxW/2), 15+(boxH/2)-1, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            end

            if( itemTable.GIF ) then
                local html = vgui.Create( "DHTML", itemBack )
                html:SetSize( itemBack:GetTall()*0.5, itemBack:GetTall()*0.5 )
                html:SetPos( (itemBack:GetWide()/2)-(html:GetWide()/2), (itemBack:GetTall()/2)-(html:GetTall()/2) )
                html:SetHTML( [[
                    <body scroll="no" style="overflow: hidden; margin: 0;">
                    <img src="]] .. itemTable.GIF ..  [[" width=]] .. html:GetWide() .. [[ height = ]] .. html:GetTall() .. [[/>
                    </body>
                ]] )
            end

            local itemInfoNoticeBack = vgui.Create( "DPanel", itemBack )
            itemInfoNoticeBack:SetSize( 0, 35 )
            itemInfoNoticeBack:SetPos( emblemSlotSize-15-itemInfoNoticeBack:GetWide(), slotTall-15-itemInfoNoticeBack:GetTall() )
            itemInfoNoticeBack.Paint = function( self2, w, h ) end

            local itemNotices = {}
            if( itemTable.Price and itemTable.Price > 0 ) then
                table.insert( itemNotices, { DarkRP.formatMoney( itemTable.Price or 0 ) } )
            end

            if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "levelling" ) and itemTable.Level ) then
                table.insert( itemNotices, { "Level " .. itemTable.Level } )
            end

            if( itemTable.Group ) then
                local groupTable
                for key, val in pairs( BRICKS_SERVER.CONFIG.GENERAL.Groups ) do
                    if( val[1] == itemTable.Group ) then
                        groupTable = val
                    end
                end

                if( groupTable ) then
                    table.insert( itemNotices, { (groupTable[1] or "None"), groupTable[3] } )
                end
            end

            for k, v in pairs( itemNotices ) do
                surface.SetFont( "BRICKS_SERVER_Font20" )
                local textX, textY = surface.GetTextSize( v[1] )
                local boxW, boxH = textX+10, textY

                local itemInfoNotice = vgui.Create( "DPanel", itemInfoNoticeBack )
                itemInfoNotice:Dock( LEFT )
                itemInfoNotice:DockMargin( 0, 0, 5, 0 )
                itemInfoNotice:SetWide( boxW )
                itemInfoNotice.Paint = function( self2, w, h ) 
                    draw.RoundedBox( 5, 0, 0, w, h, (v[2] or BRICKS_SERVER.Func.GetTheme( 5 )) )
                    draw.SimpleText( v[1], "BRICKS_SERVER_Font20", w/2, (h/2)-1, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                end

                if( itemInfoNoticeBack:GetWide() <= 5 ) then
                    itemInfoNoticeBack:SetSize( itemInfoNoticeBack:GetWide()+boxW, boxH )
                else
                    itemInfoNoticeBack:SetSize( itemInfoNoticeBack:GetWide()+5+boxW, boxH )
                end
                itemInfoNoticeBack:SetPos( emblemSlotSize-15-itemInfoNoticeBack:GetWide(), slotTall-15-itemInfoNoticeBack:GetTall() )
            end

            local purchaseButton = vgui.Create( "DButton", itemBack )
            purchaseButton:Dock( FILL )
            purchaseButton:SetText( "" )
            local changeAlpha, txtChangeAlpha = 0, 0
            purchaseButton.Paint = function( self3, w, h )
                if( self3:IsDown() ) then
                    changeAlpha = math.Clamp( changeAlpha+10, 0, 150 )
                    txtChangeAlpha = math.Clamp( txtChangeAlpha+10, 0, 255 )
                elseif( self3:IsHovered() ) then
                    changeAlpha = math.Clamp( changeAlpha+10, 0, 115 )
                    txtChangeAlpha = math.Clamp( txtChangeAlpha+10, 0, 255 )
                else
                    changeAlpha = math.Clamp( changeAlpha-10, 0, 150 )
                    txtChangeAlpha = math.Clamp( txtChangeAlpha-10, 0, 255 )
                end
        
                surface.SetAlphaMultiplier( changeAlpha/255 )
                draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
                surface.SetAlphaMultiplier( 1 )

                surface.SetAlphaMultiplier( txtChangeAlpha/255 )
                if( BRS_DEATHSCREENS_DATA and BRS_DEATHSCREENS_DATA[2] and BRS_DEATHSCREENS_DATA[2][itemKey] ) then
                    draw.SimpleText( "Equip", "BRICKS_SERVER_Font30", w/2, (h/2)-1, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                else
                    draw.SimpleText( "Purchase", "BRICKS_SERVER_Font30", w/2, (h/2)-1, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                end
                surface.SetAlphaMultiplier( 1 )
            end
            purchaseButton.DoClick = function()
                if( BRS_DEATHSCREENS_DATA and BRS_DEATHSCREENS_DATA[2] and BRS_DEATHSCREENS_DATA[2][itemKey] ) then
                    net.Start( "BRS.Net.DeathscreensMakeactive" )
                        net.WriteUInt( 2, 2 )
                        net.WriteString( itemKey )
                    net.SendToServer()
                else
                    net.Start( "BRS.Net.DeathscreensUnlockItem" )
                        net.WriteUInt( 2, 2 )
                        net.WriteString( itemKey )
                    net.SendToServer()
                end
            end
        end
    end
    self.RefreshItems()

    searchBar.OnChange = function()
        self.RefreshItems()
    end
end

function PANEL:Paint( w, h )

end

vgui.Register( "bricks_server_deathscreens_emblems", PANEL, "DPanel" )