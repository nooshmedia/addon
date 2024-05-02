local PANEL = {}

function PANEL:Init()
    self:SetSize( ScrW()*0.5, ScrH()*0.5 )
    self:Center()
    self:MakePopup()
    self:SetTitle( "" )
    self.headerHeight = 40
    self:DockPadding( 0, self.headerHeight, 0, 0 )
    self:SetDraggable( false )
    self:ShowCloseButton( false )

    local closeButton = vgui.Create( "DButton", self )
	local size = 24
	closeButton:SetSize( size, size )
	closeButton:SetPos( self:GetWide()-size-((self.headerHeight-size)/2), (self.headerHeight/2)-(size/2) )
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
        self:Remove()
    end
    
    local spacing = 5
    self.leftScrollPanel = vgui.Create( "bricks_server_scrollpanel", self )
    self.leftScrollPanel:Dock( LEFT )
    self.leftScrollPanel:DockMargin( 10, 10, 10, 10 )
    self.leftScrollPanel:SetWide( (self:GetWide()-40-5)/2 )
    self.leftScrollPanel.Paint = function( self, w, h ) end 

    self.leftGrid = vgui.Create( "DIconLayout", self.leftScrollPanel )
    self.leftGrid:Dock( FILL )
    self.leftGrid:SetSpaceY( spacing )
    self.leftGrid:SetSpaceX( spacing )

    self.rightScrollPanel = vgui.Create( "bricks_server_scrollpanel", self )
    self.rightScrollPanel:Dock( RIGHT )
    self.rightScrollPanel:DockMargin( 10, 10, 10, 10 )
    self.rightScrollPanel:SetWide( (self:GetWide()-40-5)/2 )
    self.rightScrollPanel.Paint = function( self, w, h ) end 

    self.rightGrid = vgui.Create( "DIconLayout", self.rightScrollPanel )
    self.rightGrid:Dock( FILL )
    self.rightGrid:SetSpaceY( spacing )
    self.rightGrid:SetSpaceX( spacing )

    local centerBar = vgui.Create( "DPanel", self )
    centerBar:Dock( FILL )
    centerBar:DockMargin( 1, 10, 1, 10 )
    centerBar.Paint = function( self2, w, h ) 
        draw.RoundedBox( 3, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
    end 

    hook.Add( "BRS.Hooks.FillInventory", "BRS.Hooks.FillInventory_NPC", function()
        if( IsValid( self ) ) then
            self:RefreshInventory()
        end
    end )
end

function PANEL:SetNPCKey( NPCKey, editMode, editTable )
    self.NPCKey = NPCKey
    self.leftGrid:Clear()

    if( not BRICKS_SERVER.CONFIG.NPCS[NPCKey] ) then return end

    local gridWide = (self:GetWide()-40-5)/2
    local wantedSlotSize = 125
    local slotsWide = math.floor( gridWide/wantedSlotSize )
    local spacing = 5
    local slotSize = (gridWide-((slotsWide-1)*spacing))/slotsWide

    local NPCTable = BRICKS_SERVER.CONFIG.NPCS[NPCKey]
    if( not BRICKS_SERVER.DEVCONFIG.NPCTypes[NPCTable.Type] ) then return end

    local NPCType = BRICKS_SERVER.DEVCONFIG.NPCTypes[NPCTable.Type]

    local currencyTable
    if( NPCTable.ReqInfo and NPCTable.ReqInfo[1] and BRICKS_SERVER.DEVCONFIG.Currencies[NPCTable.ReqInfo[1]] ) then
        currencyTable = BRICKS_SERVER.DEVCONFIG.Currencies[NPCTable.ReqInfo[1]]
    end

    if( not currencyTable ) then 
        notification.AddLegacy( "BRICKS SERVER ERROR: Invalid Currency", 1, 5 )
        return 
    end

    for k, v in pairs( (editTable or BRICKS_SERVER.CONFIG.NPCS[NPCKey]).Buying or {} ) do
        if( not NPCType.BuyingTypes[v.Type] ) then continue end
        
        local itemType = NPCType.BuyingTypes[v.Type]

        local slotBack = self.leftGrid:Add( "DPanel" )
        slotBack:SetSize( slotSize, slotSize )
        local x, y, w, h = 0, 0, slotSize, slotSize
        local itemModel
        local changeAlpha = 0
        local itemName = itemType.FormatName( v.ReqInfo or {} )
        local tooltipInfo = {}
        tooltipInfo[1] = { itemName, false, "BRICKS_SERVER_Font23B" }
        if( currencyTable.formatFunction ) then 
            tooltipInfo[2] = currencyTable.formatFunction( v.Price )
        else
            tooltipInfo[2] = v.Price .. " " .. NPCTable.ReqInfo[1]
        end
        slotBack.Paint = function( self2, w, h )
            draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )

            local toScreenX, toScreenY = self2:LocalToScreen( 0, 0 )
            if( x != toScreenX or y != toScreenY ) then
                x, y = toScreenX, toScreenY
                itemModel:SetBRSToolTip( x, y, w, h, tooltipInfo )
            end
            
            if( IsValid( itemModel ) ) then
                if( itemModel:IsDown() ) then
                    changeAlpha = math.Clamp( changeAlpha-10, 0, 95 )
                elseif( itemModel:IsHovered() ) then
                    changeAlpha = math.Clamp( changeAlpha+10, 0, 95 )
                else
                    changeAlpha = math.Clamp( changeAlpha-10, 0, 95 )
                end
            end

            surface.SetAlphaMultiplier( changeAlpha/255 )
            draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
            surface.SetAlphaMultiplier( 1 )

            draw.SimpleText( itemName or "", "BRICKS_SERVER_Font20", w/2, h-5, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
            
            draw.SimpleText( "BUYING", "BRICKS_SERVER_Font17", w/2, 5, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, 0 )
        end

        if( v and v.Model ) then
            itemModel = vgui.Create( "DModelPanel" , slotBack )
            itemModel:Dock( FILL )
            itemModel:SetModel( v.Model )
            if( IsValid( itemModel.Entity ) ) then
                function itemModel:LayoutEntity( Entity ) return end
                local mn, mx = itemModel.Entity:GetRenderBounds()
                local size = 0
                size = math.max( size, math.abs(mn.x) + math.abs(mx.x) )
                size = math.max( size, math.abs(mn.y) + math.abs(mx.y) )
                size = math.max( size, math.abs(mn.z) + math.abs(mx.z) )
        
                itemModel:SetFOV( 70 )
                itemModel:SetCamPos( Vector( size, size, size ) )
                itemModel:SetLookAt( (mn + mx) * 0.5 )
            end

            if( v.ModelColor ) then
                itemModel:SetColor( v.ModelColor )
            end
        end

        if( editMode and BRICKS_SERVER.Func.HasAdminAccess( LocalPlayer() ) ) then
            local actions = {
                [1] = { "Edit price", function() 
                    BRICKS_SERVER.Func.StringRequest( "Admin", "What should the new price be?", v.Price or 0, function( number ) 
                        editTable.Buying = editTable.Buying or {}
                        editTable.Buying[k].Price = number
                        self:SetNPCKey( NPCKey, editMode, editTable )
                    end, function() end, "OK", "Cancel", true )
                end },
                [2] = { "Edit model", function() 
                    BRICKS_SERVER.Func.StringRequest( "Admin", "What should the new model be?", v.Model or "", function( text ) 
                        editTable.Buying = editTable.Buying or {}
                        editTable.Buying[k].Model = text
                        self:SetNPCKey( NPCKey, editMode, editTable )
                    end, function() end, "OK", "Cancel", false )
                end },
                [3] = { "Remove", function() 
                    editTable.Buying[k] = nil
                    self:SetNPCKey( NPCKey, editMode, editTable )
                end }
            }
    
            if( itemModel ) then
                itemModel.DoClick = function()
                    itemModel.Menu = vgui.Create( "bricks_server_dmenu" )
                    for k, v in pairs( actions ) do
                        itemModel.Menu:AddOption( v[1], v[2] )
                    end
                    itemModel.Menu:Open()
                    itemModel.Menu:SetPos( x+w+5, y+(h/2)-(itemModel.Menu:GetTall()/2) )
                end
            end
        end
    end

    for k, v in pairs( (editTable or BRICKS_SERVER.CONFIG.NPCS[NPCKey]).Selling or {} ) do
        if( not NPCType.SellingTypes[v.Type] ) then continue end
        
        local itemType = NPCType.SellingTypes[v.Type]

        local slotBack = self.leftGrid:Add( "DPanel" )
        slotBack:SetSize( slotSize, slotSize )
        local x, y, w, h = 0, 0, slotSize, slotSize
        local itemModel
        local changeAlpha = 0
        local itemName = itemType.FormatName( v.ReqInfo or {} )
        local tooltipInfo = {}
        tooltipInfo[1] = { itemName, false, "BRICKS_SERVER_Font23B" }
        if( currencyTable.formatFunction ) then 
            tooltipInfo[2] = currencyTable.formatFunction( v.Price )
        else
            tooltipInfo[2] = v.Price .. " " .. NPCTable.ReqInfo[1]
        end
        slotBack.Paint = function( self2, w, h )
            draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )

            local toScreenX, toScreenY = self2:LocalToScreen( 0, 0 )
            if( x != toScreenX or y != toScreenY ) then
                x, y = toScreenX, toScreenY
                itemModel:SetBRSToolTip( x, y, w, h, tooltipInfo )
            end
            
            if( IsValid( itemModel ) ) then
                if( itemModel:IsDown() ) then
                    changeAlpha = math.Clamp( changeAlpha-10, 0, 95 )
                elseif( itemModel:IsHovered() ) then
                    changeAlpha = math.Clamp( changeAlpha+10, 0, 95 )
                else
                    changeAlpha = math.Clamp( changeAlpha-10, 0, 95 )
                end
            end

            surface.SetAlphaMultiplier( changeAlpha/255 )
            draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
            surface.SetAlphaMultiplier( 1 )

            draw.SimpleText( itemName or "", "BRICKS_SERVER_Font20", w/2, h-5, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
            
            draw.SimpleText( "SELLING", "BRICKS_SERVER_Font17", w/2, 5, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, 0 )
        end

        itemModel = vgui.Create( "DModelPanel" , slotBack )
        itemModel:Dock( FILL )
        itemModel:SetModel( v.Model or "" )
        if( IsValid( itemModel.Entity ) ) then
            function itemModel:LayoutEntity( Entity ) return end
            local mn, mx = itemModel.Entity:GetRenderBounds()
            local size = 0
            size = math.max( size, math.abs(mn.x) + math.abs(mx.x) )
            size = math.max( size, math.abs(mn.y) + math.abs(mx.y) )
            size = math.max( size, math.abs(mn.z) + math.abs(mx.z) )

            itemModel:SetFOV( 50 )
            itemModel:SetCamPos( Vector( size, size, size ) )
            itemModel:SetLookAt( (mn + mx) * 0.5 )
        end

        if( v and v.ModelColor ) then
            itemModel:SetColor( v.ModelColor )
        end
        
        local actions
        if( editMode and BRICKS_SERVER.Func.HasAdminAccess( LocalPlayer() ) ) then
            actions = {
                [1] = { "Edit price", function() 
                    BRICKS_SERVER.Func.StringRequest( "Admin", "What should the new price be?", v.Price or 0, function( number ) 
                        editTable.Selling = editTable.Selling or {}
                        editTable.Selling[k].Price = number
                        self:SetNPCKey( NPCKey, editMode, editTable )
                    end, function() end, "OK", "Cancel", true )
                end },
                [2] = { "Edit model", function() 
                    BRICKS_SERVER.Func.StringRequest( "Admin", "What should the new model be?", v.Model or "", function( text ) 
                        editTable.Selling = editTable.Selling or {}
                        editTable.Selling[k].Model = text
                        self:SetNPCKey( NPCKey, editMode, editTable )
                    end, function() end, "OK", "Cancel", false )
                end },
                [3] = { "Remove", function() 
                    editTable.Selling[k] = nil
                    self:SetNPCKey( NPCKey, editMode, editTable )
                end }
            }
        else
            actions = {
                [1] = { "Purchase x1", function() 
                    net.Start( "BRS.Net.NPC_TraderBuyItem" )
                        net.WriteUInt( self.NPCKey, 8 )
                        net.WriteUInt( k, 8 )
                        net.WriteUInt( 1, 10 )
                    net.SendToServer()
                end },
                [2] = { "Purchase x5", function() 
                    net.Start( "BRS.Net.NPC_TraderBuyItem" )
                        net.WriteUInt( self.NPCKey, 8 )
                        net.WriteUInt( k, 8 )
                        net.WriteUInt( 5, 10 )
                    net.SendToServer()
                end },
                [3] = { "Purchase x" .. (BRICKS_SERVER.CONFIG.INVENTORY["Max Item Stack"] or 10), function() 
                    net.Start( "BRS.Net.NPC_TraderBuyItem" )
                        net.WriteUInt( self.NPCKey, 8 )
                        net.WriteUInt( k, 8 )
                        net.WriteUInt( (BRICKS_SERVER.CONFIG.INVENTORY["Max Item Stack"] or 10), 10 )
                    net.SendToServer()
                end },
            }
        end

        if( itemModel ) then
            itemModel.DoClick = function()
                itemModel.Menu = vgui.Create( "bricks_server_dmenu" )
                for k, v in pairs( actions ) do
                    itemModel.Menu:AddOption( v[1], v[2] )
                end
                itemModel.Menu:Open()
                itemModel.Menu:SetPos( x+w+5, y+(h/2)-(itemModel.Menu:GetTall()/2) )
            end
        end
    end

    if( editMode and BRICKS_SERVER.Func.HasAdminAccess( LocalPlayer() ) ) then
        self.editMode = true

        local slotBack = self.leftGrid:Add( "DButton" )
        slotBack:SetSize( slotSize, slotSize )
        slotBack:SetText( "" )
        local changeAlpha = 0
        slotBack.Paint = function( self2, w, h )
            draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )

            local toScreenX, toScreenY = self2:LocalToScreen( 0, 0 )
            if( x != toScreenX or y != toScreenY ) then
                x, y = toScreenX, toScreenY
            end
            
            if( IsValid( self2 ) ) then
                if( self2:IsDown() ) then
                    changeAlpha = math.Clamp( changeAlpha-10, 0, 95 )
                elseif( self2:IsHovered() ) then
                    changeAlpha = math.Clamp( changeAlpha+10, 0, 95 )
                else
                    changeAlpha = math.Clamp( changeAlpha-10, 0, 95 )
                end
            end

            surface.SetAlphaMultiplier( changeAlpha/255 )
            draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
            surface.SetAlphaMultiplier( 1 )

            draw.SimpleText( "NEW", "BRICKS_SERVER_Font20", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end
        slotBack.DoClick = function()
            BRICKS_SERVER.Func.CreateTraderItemEditor( function( buyingOrSelling, newItemTable ) 
                if( buyingOrSelling == "Buying" ) then
                    editTable.Buying = editTable.Buying or {}
                    table.insert( editTable.Buying, newItemTable )
                else
                    editTable.Selling = editTable.Selling or {}
                    table.insert( editTable.Selling, newItemTable )
                end
                self:SetNPCKey( NPCKey, editMode, editTable )
            end, function() end )
        end
    end

    self.leftGrid:PerformLayout()
    self.leftScrollPanel:Rebuild()
end

function PANEL:RefreshInventory()
    local inventoryTable = LocalPlayer():BRS():GetInventory()

    self.rightGrid:Clear()

    local gridWide = (self:GetWide()-40-5)/2
    local wantedSlotSize = 125
    local slotsWide = math.floor( gridWide/wantedSlotSize )
    local spacing = 5
    local slotSize = (gridWide-((slotsWide-1)*spacing))/slotsWide

    if( not self.NPCKey ) then return end
    local NPCTable = BRICKS_SERVER.CONFIG.NPCS[self.NPCKey]

    if( not NPCTable ) then return end
    local typeTable = BRICKS_SERVER.DEVCONFIG.NPCTypes[NPCTable.Type]
    if( not typeTable ) then return end
    
    local function InShop( itemTable )
        if( typeTable.BuyingTypes and NPCTable.Buying ) then
            for k, v in pairs( NPCTable.Buying ) do
                if( typeTable.BuyingTypes[v.Type] and typeTable.BuyingTypes[v.Type].SlotSameAsRequired and typeTable.BuyingTypes[v.Type].SlotSameAsRequired( itemTable, v.ReqInfo ) ) then
                    return "Buying"
                end
            end
        end

        if( typeTable.SellingTypes and NPCTable.Selling ) then
            for k, v in pairs( NPCTable.Selling ) do
                if( typeTable.SellingTypes[v.Type] and typeTable.SellingTypes[v.Type].SlotSameAsRequired and typeTable.SellingTypes[v.Type].SlotSameAsRequired( itemTable, v.ReqInfo ) ) then
                    return "Selling"
                end
            end
        end

        return false
    end

    for k, v in pairs( inventoryTable ) do
        local inShop = InShop( v[2] or {} )

        if( not inShop ) then continue end

        local itemInfo = BRICKS_SERVER.Func.GetEntTypeField( ((v[2] or {})[1] or ""), "GetInfo" )( v[2] )
        
        local tooltipInfo = {}
        tooltipInfo[1] = { itemInfo[1], false, "BRICKS_SERVER_Font23B" }
        tooltipInfo[2] = itemInfo[2]
        if( itemInfo[3] ) then
            local rarityInfo = BRICKS_SERVER.Func.GetRarityInfo( itemInfo[3] )
            tooltipInfo[2] = { itemInfo[3], function() return BRICKS_SERVER.Func.GetRarityColor( rarityInfo ) end, "BRICKS_SERVER_Font17" }
            tooltipInfo[3] = itemInfo[2]
        end

        local slotBack = self.rightGrid:Add( "DPanel" )
        slotBack:SetSize( slotSize, slotSize )
        local x, y, w, h = 0, 0, slotSize, slotSize
        local itemModel
        local changeAlpha = 0
        slotBack.Paint = function( self2, w, h )
            draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )

            local toScreenX, toScreenY = self2:LocalToScreen( 0, 0 )
            if( x != toScreenX or y != toScreenY ) then
                x, y = toScreenX, toScreenY

                itemModel:SetBRSToolTip( x, y, w, h, tooltipInfo )
            end
            
            if( IsValid( itemModel ) ) then
                if( itemModel:IsDown() ) then
                    changeAlpha = math.Clamp( changeAlpha-10, 0, 95 )
                elseif( itemModel:IsHovered() ) then
                    changeAlpha = math.Clamp( changeAlpha+10, 0, 95 )
                else
                    changeAlpha = math.Clamp( changeAlpha-10, 0, 95 )
                end
            end

            surface.SetAlphaMultiplier( changeAlpha/255 )
            draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
            surface.SetAlphaMultiplier( 1 )

            draw.SimpleText( (v[1] or 1), "BRICKS_SERVER_Font20", w-10, h-5, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM )
        end

        if( v and v[2] and v[2][2] ) then
            itemModel = vgui.Create( "DModelPanel" , slotBack )
            itemModel:Dock( FILL )
            itemModel:SetModel( v[2][2] )
            itemModel:SetFOV( 50 )
            function itemModel:LayoutEntity( Entity ) return end

            BRICKS_SERVER.Func.GetEntTypeField( ((v[2] or {})[1] or ""), "ModelDisplay" )( itemModel, v[2] )

            if( v[2] and v[2][1] == "bricks_server_resource" ) then
                if( BRICKS_SERVER.CONFIG.CRAFTING.Resources[v[2][3]] and BRICKS_SERVER.CONFIG.CRAFTING.Resources[v[2][3]][2] ) then
                    itemModel:SetColor( BRICKS_SERVER.CONFIG.CRAFTING.Resources[v[2][3]][2] )
                end
            end
        end

        if( inShop == "Buying" ) then
            local actions = {
                [1] = { "Sell x1", function() 
                    net.Start( "BRS.Net.NPC_TraderSellItem" )
                        net.WriteUInt( self.NPCKey, 8 )
                        net.WriteUInt( k, 8 )
                        net.WriteUInt( 1, 10 )
                    net.SendToServer()
                end }
            }

            if( (v[1] or 1) > 1 ) then
                actions[2] = { "Sell x" .. v[1], function() 
                    net.Start( "BRS.Net.NPC_TraderSellItem" )
                        net.WriteUInt( self.NPCKey, 8 )
                        net.WriteUInt( k, 8 )
                        net.WriteUInt( v[1], 10 )
                    net.SendToServer()
                end }
            end

            if( itemModel ) then
                itemModel.DoClick = function()
                    itemModel.Menu = vgui.Create( "bricks_server_dmenu" )
                    for k, v in pairs( actions ) do
                        itemModel.Menu:AddOption( v[1], v[2] )
                    end
                    itemModel.Menu:Open()
                    itemModel.Menu:SetPos( x+w+5, y+(h/2)-(itemModel.Menu:GetTall()/2) )
                end
            end
        end
    end

    self.rightGrid:PerformLayout()
    self.rightScrollPanel:Rebuild()
end

local rounded = 5
function PANEL:Paint( w, h )
    draw.RoundedBox( rounded, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
    draw.RoundedBoxEx( rounded, 0, 0, w, self.headerHeight, BRICKS_SERVER.Func.GetTheme( 0 ), true, true, false, false )

    local currencyTable
    if( ((BRICKS_SERVER.CONFIG.NPCS or {})[(self.NPCKey or 0)] or {}).ReqInfo and ((BRICKS_SERVER.CONFIG.NPCS or {})[(self.NPCKey or 0)] or {}).ReqInfo[1] and BRICKS_SERVER.DEVCONFIG.Currencies[((BRICKS_SERVER.CONFIG.NPCS or {})[(self.NPCKey or 0)] or {}).ReqInfo[1]] ) then
        currencyTable = BRICKS_SERVER.DEVCONFIG.Currencies[((BRICKS_SERVER.CONFIG.NPCS or {})[(self.NPCKey or 0)] or {}).ReqInfo[1]]
    end

    if( currencyTable ) then 
        draw.SimpleText( ((BRICKS_SERVER.CONFIG.NPCS or {})[(self.NPCKey or 0)] or {}).Name .. " - " .. currencyTable.formatFunction( currencyTable.getFunction( LocalPlayer() ) ), "BRICKS_SERVER_Font30", 10, (self.headerHeight or 40)/2-2, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_CENTER )
    else
        draw.SimpleText( ((BRICKS_SERVER.CONFIG.NPCS or {})[(self.NPCKey or 0)] or {}).Name, "BRICKS_SERVER_Font30", 10, (self.headerHeight or 40)/2-2, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_CENTER )
    end
end

vgui.Register( "bricks_server_ui_npc_trader", PANEL, "DFrame" )