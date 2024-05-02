local PANEL = {}

function PANEL:Init()

end

local spacing = 5
local gridWide = (ScrW()*0.6)-BRICKS_SERVER.DEVCONFIG.MainNavWidth-20

local slotsWide = (ScrW() >= 1080 and 2) or 1
local slotWide = (gridWide-((slotsWide-1)*spacing))/slotsWide
local slotTall = slotWide/4

local emblemSlotsWide = 3
local emblemSlotSize = (gridWide-((emblemSlotsWide-1)*spacing))/emblemSlotsWide

function PANEL:FillPanel()
    function self.RefreshPanel()
        self:Clear()

        self.slots = nil
        if( self.grid and IsValid( self.grid ) ) then
            self.grid:Remove()
        end

        BRICKS_SERVER.Func.FillVariableConfigs( self, "DEATHSCREENS", "DEATHSCREENS" )

        local header = vgui.Create( "DPanel", self )
        header:Dock( TOP )
        header:SetTall( 40 )
        header.Paint = function( self2, w, h )
            draw.SimpleText( "Calling cards", "BRICKS_SERVER_Font25", 0, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_CENTER )
        end

        self.cardSlots = nil
        if( self.cardGrid and IsValid( self.cardGrid ) ) then
            self.cardGrid:Remove()
        end

        self.cardGrid = vgui.Create( "DIconLayout", self )
        self.cardGrid:Dock( TOP )
        self.cardGrid:SetTall( slotTall )
        self.cardGrid:SetSpaceY( spacing )
        self.cardGrid:SetSpaceX( spacing )

        for k, v in pairs( (BS_ConfigCopyTable or BRICKS_SERVER.CONFIG).DEATHSCREENS.Cards ) do
            self.cardSlots = (self.cardSlots or 0)+1
            local slots = self.cardSlots
            local slotsTall = math.ceil( slots/slotsWide )
            self.cardGrid:SetTall( (slotsTall*slotTall)+((slotsTall-1)*spacing) )

            local itemBack = self.cardGrid:Add( "DPanel" )
            itemBack:SetSize( slotWide, slotTall )
            local cardMat
            if( v.Image ) then
                BRICKS_SERVER.Func.GetImage( v.Image or "", function( mat ) cardMat = mat end )
            end
            itemBack.Paint = function( self2, w, h )
                draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )

                if( v.Image and cardMat ) then
                    BRICKS_SERVER.Func.DrawRoundedMask( 8, 0, 0, w, h, function()
                        surface.SetDrawColor( 255, 255, 255, 255 )
                        surface.SetMaterial( cardMat )
                        surface.DrawTexturedRect( 0, 0, w, h )
                    end )
                end

                if( IsValid( self2.html ) ) then
                    BRICKS_SERVER.Func.DrawRoundedMask( 8, 0, 0, w, h, function()
                        self2.html:PaintManual()
                    end )
                end
            end

            if( v.GIF ) then
                itemBack.html = vgui.Create( "DHTML", itemBack )
                itemBack.html:Dock( FILL )
                itemBack.html:SetPaintedManually( true )
                itemBack.html:SetHTML( [[
                    <body scroll="no" style="overflow: hidden; margin: 0;">
                    <img src="]] .. v.GIF ..  [[" width=]] .. itemBack:GetWide() .. [[ height = ]] .. itemBack:GetTall() .. [[/>
                    </body>
                ]] )
            end


            local itemInfo = vgui.Create( "DPanel", itemBack )
            itemInfo:SetSize( slotWide, slotTall )
            itemInfo.Paint = function( self2, w, h )
                surface.SetFont( "BRICKS_SERVER_Font25" )
                local textX, textY = surface.GetTextSize( v.Name or "New Card" )
                local boxW, boxH = textX+10, textY

                draw.RoundedBox( 5, 15, 15, boxW, boxH, (v[2] or BRICKS_SERVER.Func.GetTheme( 5 )) )
                draw.SimpleText( v.Name or "New Card", "BRICKS_SERVER_Font25", 15+(boxW/2), 15+(boxH/2)-1, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            end

            local itemInfoNoticeBack = vgui.Create( "DPanel", itemInfo )
            itemInfoNoticeBack:SetSize( 0, 35 )
            itemInfoNoticeBack:SetPos( slotWide-15-itemInfoNoticeBack:GetWide(), slotTall-15-itemInfoNoticeBack:GetTall() )
            itemInfoNoticeBack.Paint = function( self2, w, h ) end
    
            local itemNotices = {}
            if( v.Price and v.Price > 0 ) then
                table.insert( itemNotices, { DarkRP.formatMoney( v.Price or 0 ) } )
            end
    
            if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "levelling" ) and v.Level ) then
                table.insert( itemNotices, { "Level " .. v.Level } )
            end
    
            if( v.Group ) then
                local groupTable
                for key, val in pairs( BRICKS_SERVER.CONFIG.GENERAL.Groups ) do
                    if( val[1] == v.Group ) then
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
                itemInfoNoticeBack:SetPos( slotWide-15-itemInfoNoticeBack:GetWide(), slotTall-15-itemInfoNoticeBack:GetTall() )
            end

            local editMat = Material( "materials/bricks_server/edit.png" )
            local button = vgui.Create( "DButton", itemInfo )
            button:SetSize( 36, 36 )
            button:SetPos( slotWide-5-button:GetWide(), 5 )
            button:SetText( "" )
            local changeAlpha = 0
            button.Paint = function( self3, w, h )
                if( self3:IsDown() ) then
                    changeAlpha = math.Clamp( changeAlpha+10, 0, 125 )
                elseif( self3:IsHovered() ) then
                    changeAlpha = math.Clamp( changeAlpha+10, 0, 95 )
                else
                    changeAlpha = math.Clamp( changeAlpha-10, 0, 95 )
                end
        
                surface.SetAlphaMultiplier( changeAlpha/255 )
                draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
                surface.SetAlphaMultiplier( 1 )
        
                surface.SetMaterial( editMat )
                local size = 24
                surface.SetDrawColor( 0, 0, 0, 255 )
                surface.DrawTexturedRect( (h-size)/2-1, (h-size)/2+1, size, size )
        
                surface.SetDrawColor( 255, 255, 255, 255 )
                surface.DrawTexturedRect( (h-size)/2, (h-size)/2, size, size )
            end
            button.DoClick = function()
                BRICKS_SERVER.Func.CreateDeathscreensEditor( v, "Card", function( itemTable ) 
                    local newItemID = string.Replace( string.lower( itemTable.Name ), " ", "" )
                    if( newItemID != k and BS_ConfigCopyTable.DEATHSCREENS.Cards[newItemID] ) then
                        notification.AddLegacy( "There is already a card with this name!", 1, 5 )
                        return
                    end

                    if( newItemID != k ) then
                        BS_ConfigCopyTable.DEATHSCREENS.Cards[k] = nil
                    end

                    BS_ConfigCopyTable.DEATHSCREENS.Cards[newItemID] = itemTable
        
                    BRICKS_SERVER.Func.ConfigChange( "DEATHSCREENS" )
                    self.RefreshPanel()
                end, function() end ) 
            end

            local removeMat = Material( "materials/bricks_server/delete.png" )
            local removeButton = vgui.Create( "DButton", itemInfo )
            removeButton:SetSize( 36, 36 )
            removeButton:SetPos( slotWide-5-button:GetWide()-5-removeButton:GetWide(), 5 )
            removeButton:SetText( "" )
            local changeAlpha = 0
            removeButton.Paint = function( self3, w, h )
                if( self3:IsDown() ) then
                    changeAlpha = math.Clamp( changeAlpha+10, 0, 125 )
                elseif( self3:IsHovered() ) then
                    changeAlpha = math.Clamp( changeAlpha+10, 0, 95 )
                else
                    changeAlpha = math.Clamp( changeAlpha-10, 0, 95 )
                end
        
                surface.SetAlphaMultiplier( changeAlpha/255 )
                draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
                surface.SetAlphaMultiplier( 1 )
        
                surface.SetMaterial( removeMat )
                local size = 24
                surface.SetDrawColor( 0, 0, 0, 255 )
                surface.DrawTexturedRect( (h-size)/2-1, (h-size)/2+1, size, size )
        
                surface.SetDrawColor( 255, 255, 255, 255 )
                surface.DrawTexturedRect( (h-size)/2, (h-size)/2, size, size )
            end
            removeButton.DoClick = function()
                BS_ConfigCopyTable.DEATHSCREENS.Cards[k] = nil
    
                BRICKS_SERVER.Func.ConfigChange( "DEATHSCREENS" )
                self.RefreshPanel()
            end
        end

        local addNewCard = self.cardGrid:Add( "DButton" )
        addNewCard:SetSize( slotWide, slotTall )
        addNewCard:SetText( "" )
        local changeAlpha = 0
        local newMat = Material( "materials/bricks_server/add_64.png")
        addNewCard.Paint = function( self2, w, h )
            draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )

            if( self2:IsDown() ) then
                changeAlpha = math.Clamp( changeAlpha+10, 0, 150 )
            elseif( self2:IsHovered() ) then
                changeAlpha = math.Clamp( changeAlpha+10, 0, 95 )
            else
                changeAlpha = math.Clamp( changeAlpha-10, 0, 95 )
            end

            surface.SetAlphaMultiplier( changeAlpha/255 )
            draw.RoundedBox( 8, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
            surface.SetAlphaMultiplier( 1 )

            if( newMat ) then
                surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
                surface.SetMaterial( newMat )
                local iconSize = 64
                surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
            end

            
            draw.SimpleText( "Add new card", "BRICKS_SERVER_Font20", w/2, h-15, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
        end
        addNewCard.DoClick = function()
            BRICKS_SERVER.Func.CreateDeathscreensEditor( { Name = "New Card" }, "Card", function( itemTable ) 
                local newItemID = string.Replace( string.lower( itemTable.Name ), " ", "" )
                if( BS_ConfigCopyTable.DEATHSCREENS.Cards[newItemID] ) then
                    notification.AddLegacy( "There is already a card with this name!", 1, 5 )
                    return
                end

                BS_ConfigCopyTable.DEATHSCREENS.Cards[newItemID] = itemTable
    
                BRICKS_SERVER.Func.ConfigChange( "DEATHSCREENS" )
                self.RefreshPanel()
            end, function() end )
        end

        local header = vgui.Create( "DPanel", self )
        header:Dock( TOP )
        header:DockMargin( 0, 10, 0, 0 )
        header:SetTall( 40 )
        header.Paint = function( self2, w, h )
            draw.SimpleText( "Emblems", "BRICKS_SERVER_Font25", 0, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_CENTER )
        end

        self.emblemSlots = nil
        if( self.emblemGrid and IsValid( self.emblemGrid ) ) then
            self.emblemGrid:Remove()
        end

        self.emblemGrid = vgui.Create( "DIconLayout", self )
        self.emblemGrid:Dock( TOP )
        self.emblemGrid:SetTall( slotTall )
        self.emblemGrid:SetSpaceY( spacing )
        self.emblemGrid:SetSpaceX( spacing )

        for k, v in pairs( (BS_ConfigCopyTable or BRICKS_SERVER.CONFIG).DEATHSCREENS.Emblems ) do
            self.emblemSlots = (self.emblemSlots or 0)+1
            local slots = self.emblemSlots
            local slotsTall = math.ceil( slots/slotTall )
            self.emblemGrid:SetTall( (slotsTall*slotTall)+((slotsTall-1)*spacing) )

            local itemBack = self.emblemGrid:Add( "DPanel" )
            itemBack:SetSize( emblemSlotSize, slotTall )
            local emblemMat
            if( v.Image ) then
                BRICKS_SERVER.Func.GetImage( v.Image or "", function( mat ) emblemMat = mat end )
            end
            itemBack.Paint = function( self2, w, h )
                draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )

                if( v.Image and emblemMat ) then
                    surface.SetDrawColor( 255, 255, 255, 255 )
                    surface.SetMaterial( emblemMat )
                    local iconSize = h*0.5
                    surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
                end

                surface.SetFont( "BRICKS_SERVER_Font25" )
                local textX, textY = surface.GetTextSize( v.Name or "New Emblem" )
                local boxW, boxH = textX+10, textY

                draw.RoundedBox( 5, 15, 15, boxW, boxH, (v[2] or BRICKS_SERVER.Func.GetTheme( 5 )) )
                draw.SimpleText( v.Name or "New Emblem", "BRICKS_SERVER_Font25", 15+(boxW/2), 15+(boxH/2)-1, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            end

            if( v.GIF ) then
                local html = vgui.Create( "DHTML", itemBack )
                html:SetSize( itemBack:GetTall()*0.5, itemBack:GetTall()*0.5 )
                html:SetPos( (itemBack:GetWide()/2)-(html:GetWide()/2), (itemBack:GetTall()/2)-(html:GetTall()/2) )
                html:SetHTML( [[
                    <body scroll="no" style="overflow: hidden; margin: 0;">
                    <img src="]] .. v.GIF ..  [[" width=]] .. html:GetWide() .. [[ height = ]] .. html:GetTall() .. [[/>
                    </body>
                ]] )
            end

            local itemInfoNoticeBack = vgui.Create( "DPanel", itemBack )
            itemInfoNoticeBack:SetSize( 0, 35 )
            itemInfoNoticeBack:SetPos( emblemSlotSize-15-itemInfoNoticeBack:GetWide(), slotTall-15-itemInfoNoticeBack:GetTall() )
            itemInfoNoticeBack.Paint = function( self2, w, h ) end
    
            local itemNotices = {}
            if( v.Price and v.Price > 0 ) then
                table.insert( itemNotices, { DarkRP.formatMoney( v.Price or 0 ) } )
            end
    
            if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "levelling" ) and v.Level ) then
                table.insert( itemNotices, { "Level " .. v.Level } )
            end
    
            if( v.Group ) then
                local groupTable
                for key, val in pairs( BRICKS_SERVER.CONFIG.GENERAL.Groups ) do
                    if( val[1] == v.Group ) then
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

            local editMat = Material( "materials/bricks_server/edit.png" )
            local button = vgui.Create( "DButton", itemBack )
            button:SetSize( 36, 36 )
            button:SetPos( emblemSlotSize-5-button:GetWide(), 5 )
            button:SetText( "" )
            local changeAlpha = 0
            button.Paint = function( self3, w, h )
                if( self3:IsDown() ) then
                    changeAlpha = math.Clamp( changeAlpha+10, 0, 125 )
                elseif( self3:IsHovered() ) then
                    changeAlpha = math.Clamp( changeAlpha+10, 0, 95 )
                else
                    changeAlpha = math.Clamp( changeAlpha-10, 0, 95 )
                end
        
                surface.SetAlphaMultiplier( changeAlpha/255 )
                draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
                surface.SetAlphaMultiplier( 1 )
        
                surface.SetMaterial( editMat )
                local size = 24
                surface.SetDrawColor( 0, 0, 0, 255 )
                surface.DrawTexturedRect( (h-size)/2-1, (h-size)/2+1, size, size )
        
                surface.SetDrawColor( 255, 255, 255, 255 )
                surface.DrawTexturedRect( (h-size)/2, (h-size)/2, size, size )
            end
            button.DoClick = function()
                BRICKS_SERVER.Func.CreateDeathscreensEditor( v, "Emblem", function( itemTable ) 
                    local newItemID = string.Replace( string.lower( itemTable.Name ), " ", "" )
                    if( newItemID != k and BS_ConfigCopyTable.DEATHSCREENS.Emblems[newItemID] ) then
                        notification.AddLegacy( "There is already an emblem with this name!", 1, 5 )
                        return
                    end

                    if( newItemID != k ) then
                        BS_ConfigCopyTable.DEATHSCREENS.Emblems[k] = nil
                    end

                    BS_ConfigCopyTable.DEATHSCREENS.Emblems[newItemID] = itemTable
        
                    BRICKS_SERVER.Func.ConfigChange( "DEATHSCREENS" )
                    self.RefreshPanel()
                end, function() end ) 
            end

            local removeMat = Material( "materials/bricks_server/delete.png" )
            local removeButton = vgui.Create( "DButton", itemBack )
            removeButton:SetSize( 36, 36 )
            removeButton:SetPos( emblemSlotSize-5-button:GetWide()-5-removeButton:GetWide(), 5 )
            removeButton:SetText( "" )
            local changeAlpha = 0
            removeButton.Paint = function( self3, w, h )
                if( self3:IsDown() ) then
                    changeAlpha = math.Clamp( changeAlpha+10, 0, 125 )
                elseif( self3:IsHovered() ) then
                    changeAlpha = math.Clamp( changeAlpha+10, 0, 95 )
                else
                    changeAlpha = math.Clamp( changeAlpha-10, 0, 95 )
                end
        
                surface.SetAlphaMultiplier( changeAlpha/255 )
                draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
                surface.SetAlphaMultiplier( 1 )
        
                surface.SetMaterial( removeMat )
                local size = 24
                surface.SetDrawColor( 0, 0, 0, 255 )
                surface.DrawTexturedRect( (h-size)/2-1, (h-size)/2+1, size, size )
        
                surface.SetDrawColor( 255, 255, 255, 255 )
                surface.DrawTexturedRect( (h-size)/2, (h-size)/2, size, size )
            end
            removeButton.DoClick = function()
                BS_ConfigCopyTable.DEATHSCREENS.Emblems[k] = nil
    
                BRICKS_SERVER.Func.ConfigChange( "DEATHSCREENS" )
                self.RefreshPanel()
            end
        end

        local addNewEmblem = self.emblemGrid:Add( "DButton" )
        addNewEmblem:SetSize( emblemSlotSize, slotTall )
        addNewEmblem:SetText( "" )
        local changeAlpha = 0
        local newMat = Material( "materials/bricks_server/add_64.png")
        addNewEmblem.Paint = function( self2, w, h )
            draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )

            if( self2:IsDown() ) then
                changeAlpha = math.Clamp( changeAlpha+10, 0, 150 )
            elseif( self2:IsHovered() ) then
                changeAlpha = math.Clamp( changeAlpha+10, 0, 95 )
            else
                changeAlpha = math.Clamp( changeAlpha-10, 0, 95 )
            end

            surface.SetAlphaMultiplier( changeAlpha/255 )
            draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
            surface.SetAlphaMultiplier( 1 )

            if( newMat ) then
                surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
                surface.SetMaterial( newMat )
                local iconSize = 64
                surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
            end

            
            draw.SimpleText( "Add new emblem", "BRICKS_SERVER_Font20", w/2, h-15, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
        end
        addNewEmblem.DoClick = function()
            BRICKS_SERVER.Func.CreateDeathscreensEditor( { Name = "New Emblem" }, "Emblem", function( itemTable ) 
                local newItemID = string.Replace( string.lower( itemTable.Name ), " ", "" )
                if( BS_ConfigCopyTable.DEATHSCREENS.Emblems[newItemID] ) then
                    notification.AddLegacy( "There is already an emblem with this name!", 1, 5 )
                    return
                end

                BS_ConfigCopyTable.DEATHSCREENS.Emblems[newItemID] = itemTable
    
                BRICKS_SERVER.Func.ConfigChange( "DEATHSCREENS" )
                self.RefreshPanel()
            end, function() end )
        end

        local header = vgui.Create( "DPanel", self )
        header:Dock( TOP )
        header:DockMargin( 0, 10, 0, 0 )
        header:SetTall( 40 )
        header.Paint = function( self2, w, h )
            draw.SimpleText( "Soundstracks", "BRICKS_SERVER_Font25", 0, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_CENTER )
        end

        self.soundtrackSlots = nil
        if( self.soundtrackGrid and IsValid( self.soundtrackGrid ) ) then
            self.soundtrackGrid:Remove()
        end

        self.soundtrackGrid = vgui.Create( "DIconLayout", self )
        self.soundtrackGrid:Dock( TOP )
        self.soundtrackGrid:SetTall( slotTall )
        self.soundtrackGrid:SetSpaceY( spacing )
        self.soundtrackGrid:SetSpaceX( spacing )

        for k, v in pairs( (BS_ConfigCopyTable or BRICKS_SERVER.CONFIG).DEATHSCREENS.Soundtracks ) do
            self.soundtrackSlots = (self.soundtrackSlots or 0)+1
            local slots = self.soundtrackSlots
            local slotsTall = math.ceil( slots/slotTall )
            self.soundtrackGrid:SetTall( (slotsTall*slotTall)+((slotsTall-1)*spacing) )

            local itemBack = self.soundtrackGrid:Add( "DPanel" )
            itemBack:SetSize( emblemSlotSize, slotTall )
            itemBack.Paint = function( self2, w, h )
                draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )

                surface.SetFont( "BRICKS_SERVER_Font25" )
                local textX, textY = surface.GetTextSize( v.Name or "New Soundtrack" )
                local boxW, boxH = textX+10, textY

                draw.RoundedBox( 5, 15, 15, boxW, boxH, (v[2] or BRICKS_SERVER.Func.GetTheme( 5 )) )
                draw.SimpleText( v.Name or "New Soundtrack", "BRICKS_SERVER_Font25", 15+(boxW/2), 15+(boxH/2)-1, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

                draw.SimpleText( v.Sound or "nosound", "BRICKS_SERVER_Font20", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
            end

            local itemInfoNoticeBack = vgui.Create( "DPanel", itemBack )
            itemInfoNoticeBack:SetSize( 0, 35 )
            itemInfoNoticeBack:SetPos( emblemSlotSize-15-itemInfoNoticeBack:GetWide(), slotTall-15-itemInfoNoticeBack:GetTall() )
            itemInfoNoticeBack.Paint = function( self2, w, h ) end
    
            local itemNotices = {}
            if( v.Price and v.Price > 0 ) then
                table.insert( itemNotices, { DarkRP.formatMoney( v.Price or 0 ) } )
            end
    
            if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "levelling" ) and v.Level ) then
                table.insert( itemNotices, { "Level " .. v.Level } )
            end
    
            if( v.Group ) then
                local groupTable
                for key, val in pairs( BRICKS_SERVER.CONFIG.GENERAL.Groups ) do
                    if( val[1] == v.Group ) then
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

            local editMat = Material( "materials/bricks_server/edit.png" )
            local button = vgui.Create( "DButton", itemBack )
            button:SetSize( 36, 36 )
            button:SetPos( emblemSlotSize-5-button:GetWide(), 5 )
            button:SetText( "" )
            local changeAlpha = 0
            button.Paint = function( self3, w, h )
                if( self3:IsDown() ) then
                    changeAlpha = math.Clamp( changeAlpha+10, 0, 125 )
                elseif( self3:IsHovered() ) then
                    changeAlpha = math.Clamp( changeAlpha+10, 0, 95 )
                else
                    changeAlpha = math.Clamp( changeAlpha-10, 0, 95 )
                end
        
                surface.SetAlphaMultiplier( changeAlpha/255 )
                draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
                surface.SetAlphaMultiplier( 1 )
        
                surface.SetMaterial( editMat )
                local size = 24
                surface.SetDrawColor( 0, 0, 0, 255 )
                surface.DrawTexturedRect( (h-size)/2-1, (h-size)/2+1, size, size )
        
                surface.SetDrawColor( 255, 255, 255, 255 )
                surface.DrawTexturedRect( (h-size)/2, (h-size)/2, size, size )
            end
            button.DoClick = function()
                BRICKS_SERVER.Func.CreateDeathscreensEditor( v, "Soundtrack", function( itemTable ) 
                    local newItemID = string.Replace( string.lower( itemTable.Name ), " ", "" )
                    if( newItemID != k and BS_ConfigCopyTable.DEATHSCREENS.Soundtracks[newItemID] ) then
                        notification.AddLegacy( "There is already a soundtrack with this name!", 1, 5 )
                        return
                    end

                    if( newItemID != k ) then
                        BS_ConfigCopyTable.DEATHSCREENS.Soundtracks[k] = nil
                    end

                    BS_ConfigCopyTable.DEATHSCREENS.Soundtracks[newItemID] = itemTable
        
                    BRICKS_SERVER.Func.ConfigChange( "DEATHSCREENS" )
                    self.RefreshPanel()
                end, function() end ) 
            end

            local removeMat = Material( "materials/bricks_server/delete.png" )
            local removeButton = vgui.Create( "DButton", itemBack )
            removeButton:SetSize( 36, 36 )
            removeButton:SetPos( emblemSlotSize-5-button:GetWide()-5-removeButton:GetWide(), 5 )
            removeButton:SetText( "" )
            local changeAlpha = 0
            removeButton.Paint = function( self3, w, h )
                if( self3:IsDown() ) then
                    changeAlpha = math.Clamp( changeAlpha+10, 0, 125 )
                elseif( self3:IsHovered() ) then
                    changeAlpha = math.Clamp( changeAlpha+10, 0, 95 )
                else
                    changeAlpha = math.Clamp( changeAlpha-10, 0, 95 )
                end
        
                surface.SetAlphaMultiplier( changeAlpha/255 )
                draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
                surface.SetAlphaMultiplier( 1 )
        
                surface.SetMaterial( removeMat )
                local size = 24
                surface.SetDrawColor( 0, 0, 0, 255 )
                surface.DrawTexturedRect( (h-size)/2-1, (h-size)/2+1, size, size )
        
                surface.SetDrawColor( 255, 255, 255, 255 )
                surface.DrawTexturedRect( (h-size)/2, (h-size)/2, size, size )
            end
            removeButton.DoClick = function()
                BS_ConfigCopyTable.DEATHSCREENS.Soundtracks[k] = nil
    
                BRICKS_SERVER.Func.ConfigChange( "DEATHSCREENS" )
                self.RefreshPanel()
            end
        end

        local addNewSoundtrack = self.soundtrackGrid:Add( "DButton" )
        addNewSoundtrack:SetSize( emblemSlotSize, slotTall )
        addNewSoundtrack:SetText( "" )
        local changeAlpha = 0
        local newMat = Material( "materials/bricks_server/add_64.png")
        addNewSoundtrack.Paint = function( self2, w, h )
            draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )

            if( self2:IsDown() ) then
                changeAlpha = math.Clamp( changeAlpha+10, 0, 150 )
            elseif( self2:IsHovered() ) then
                changeAlpha = math.Clamp( changeAlpha+10, 0, 95 )
            else
                changeAlpha = math.Clamp( changeAlpha-10, 0, 95 )
            end

            surface.SetAlphaMultiplier( changeAlpha/255 )
            draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
            surface.SetAlphaMultiplier( 1 )

            surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
            surface.SetMaterial( newMat )
            local iconSize = 64
            surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )

            draw.SimpleText( "Add new soundtrack", "BRICKS_SERVER_Font20", w/2, h-15, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
        end
        addNewSoundtrack.DoClick = function()
            BRICKS_SERVER.Func.CreateDeathscreensEditor( { Name = "New Soundtrack" }, "Soundtrack", function( itemTable ) 
                local newItemID = string.Replace( string.lower( itemTable.Name ), " ", "" )
                if( BS_ConfigCopyTable.DEATHSCREENS.Soundtracks[newItemID] ) then
                    notification.AddLegacy( "There is already a soundtrack with this name!", 1, 5 )
                    return
                end

                BS_ConfigCopyTable.DEATHSCREENS.Soundtracks[newItemID] = itemTable
    
                BRICKS_SERVER.Func.ConfigChange( "DEATHSCREENS" )
                self.RefreshPanel()
            end, function() end )
        end
    end
    self.RefreshPanel()
end

function PANEL:Paint( w, h )
    
end

vgui.Register( "bricks_server_config_deathscreens", PANEL, "bricks_server_scrollpanel" )