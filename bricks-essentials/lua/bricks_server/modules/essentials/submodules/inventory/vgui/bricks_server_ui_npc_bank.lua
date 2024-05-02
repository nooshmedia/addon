local PANEL = {}

function PANEL:Init()
    self:SetSize( ScrW()*0.5, ScrH()*0.5 )
    self:Center()

    if( self.NPCKey ) then
        self:SetHeader( ((BRICKS_SERVER.CONFIG.NPCS or {})[(self.NPCKey or 0)] or {}).Name )
    else
        self:SetHeader( "Bank NPC" )
    end

    self.spacing = 5
    local gridWide = (self:GetWide()-40-5)/2
    local wantedSlotSize = 110
    local slotsWide = math.floor( gridWide/wantedSlotSize )
    self.slotSize = (gridWide-((slotsWide-1)*self.spacing))/slotsWide

    self.inventoryScroll = vgui.Create( "bricks_server_scrollpanel", self )
    self.inventoryScroll:Dock( LEFT )
    self.inventoryScroll:DockMargin( 10, 10, 10, 10 )
    self.inventoryScroll:SetWide( (self:GetWide()-40-5)/2 )
    self.inventoryScroll.Paint = function( self, w, h ) end 

    self.inventoryGrid = vgui.Create( "DIconLayout", self.inventoryScroll )
    self.inventoryGrid:Dock( FILL )
    self.inventoryGrid:SetSpaceY( self.spacing )
    self.inventoryGrid:SetSpaceX( self.spacing )

    self.bankScroll = vgui.Create( "bricks_server_scrollpanel", self )
    self.bankScroll:Dock( RIGHT )
    self.bankScroll:DockMargin( 10, 10, 10, 10 )
    self.bankScroll:SetWide( (self:GetWide()-40-5)/2 )
    self.bankScroll.Paint = function( self, w, h ) end 

    self.bankGrid = vgui.Create( "DIconLayout", self.bankScroll )
    self.bankGrid:Dock( FILL )
    self.bankGrid:SetSpaceY( self.spacing )
    self.bankGrid:SetSpaceX( self.spacing )

    local centerBar = vgui.Create( "DPanel", self )
    centerBar:Dock( FILL )
    centerBar:DockMargin( 1, 10, 1, 10 )
    centerBar.Paint = function( self2, w, h ) 
        draw.RoundedBox( 3, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
    end 
end

local gradient = Material( "vgui/gradient_up" ) 
local function FillItemSlot( self, panel, itemTable, itemKey )
    panel.item = vgui.Create( "DPanel", panel )
    panel.item:Dock( FILL )
    panel.item:Droppable( "inventory_slot" )
    panel.item.itemKey = itemKey
    panel.item.invType = panel.invType
    local x, y, w, h = 0, 0, self.slotSize, self.slotSize
    local itemModel
    local changeAlpha = 0
    local itemInfo = {}
    if( BRICKS_SERVER.Func.GetInvTypeCFG( ((itemTable or {})[2] or {})[1] or "" ).GetInfo ) then
        itemInfo = BRICKS_SERVER.Func.GetInvTypeCFG( ((itemTable or {})[2] or {})[1] or "" ).GetInfo( itemTable[2] )
    else
        itemInfo = BRICKS_SERVER.DEVCONFIG.INVENTORY.DefaultEntFuncs.GetInfo( itemTable[2] )
    end
    
    local tooltipInfo = {}
    tooltipInfo[1] = { itemInfo[1], false, "BRICKS_SERVER_Font23B" }
    local rarityInfo
    if( itemInfo[3] ) then
        rarityInfo = BRICKS_SERVER.Func.GetRarityInfo( itemInfo[3] )
        tooltipInfo[2] = { itemInfo[3], function() return BRICKS_SERVER.Func.GetRarityColor( rarityInfo ) end, "BRICKS_SERVER_Font17" }
    end
    table.insert( tooltipInfo, itemInfo[2] )
    if( #itemInfo > 3 ) then
        for i = 4, #itemInfo do
            table.insert( tooltipInfo, itemInfo[i] )
        end
    end
    local boxH = 20
    panel.item.Paint = function( self2, w, h )
        local toScreenX, toScreenY = self2:LocalToScreen( 0, 0 )
        if( x != toScreenX or y != toScreenY ) then
            x, y = toScreenX, toScreenY
            itemModel:SetBRSToolTip( x, y, w, h, tooltipInfo )
        end
        
        if( itemModel:IsDown() ) then
            changeAlpha = 0
        elseif( itemModel:IsHovered() ) then
            changeAlpha = math.Clamp( changeAlpha+10, 0, 50 )
        else
            changeAlpha = math.Clamp( changeAlpha-10, 0, 50 )
        end

        if( rarityInfo ) then
            surface.SetAlphaMultiplier( 0.25 )
            draw.RoundedBoxEx( 5, 0, 0, w, h-boxH+5, BRICKS_SERVER.Func.GetRarityColor( rarityInfo ), true, true, false, false )
            surface.SetAlphaMultiplier( 1 )


            surface.SetMaterial( gradient )
            surface.SetDrawColor( 0, 0, 0, 125 )
            surface.DrawTexturedRect( 0, 0, w, h-boxH )
        end

        surface.SetAlphaMultiplier( changeAlpha/255 )
        draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 0 ) )
        surface.SetAlphaMultiplier( 1 )

        draw.RoundedBoxEx( 5, 0, h-boxH, w, boxH, BRICKS_SERVER.Func.GetTheme( 2 ), false, false, true, true )

        draw.SimpleText( itemInfo[1], "BRICKS_SERVER_Font17", w/2, h-(boxH/2)-1, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        draw.SimpleText( "x" .. (itemTable[1] or 1), "BRICKS_SERVER_Font17", w-7, 2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_RIGHT, 0 )
    end

    itemModel = vgui.Create( "DModelPanel" , panel.item )
    itemModel:Dock( FILL )
    itemModel:DockMargin( 0, 0, 0, boxH )
    itemModel:SetModel( ((itemTable or {})[2] or {})[2] or "models/error.mdl" )
    itemModel:SetFOV( 50 )
    function itemModel:LayoutEntity( Entity ) return end

    if( BRICKS_SERVER.Func.GetInvTypeCFG( ((itemTable or {})[2] or {})[1] or "" ).ModelDisplay ) then
        BRICKS_SERVER.Func.GetInvTypeCFG( ((itemTable or {})[2] or {})[1] or "" ).ModelDisplay( itemModel, itemTable[2] )
    else
        BRICKS_SERVER.DEVCONFIG.INVENTORY.DefaultEntFuncs.ModelDisplay( itemModel, itemTable[2] )
    end

    if( itemTable[2] and itemTable[2][1] == "bricks_server_resource" ) then
        if( BRICKS_SERVER.CONFIG.CRAFTING.Resources[itemTable[2][3]] and BRICKS_SERVER.CONFIG.CRAFTING.Resources[itemTable[2][3]][2] ) then
            itemModel:SetColor( BRICKS_SERVER.CONFIG.CRAFTING.Resources[itemTable[2][3]][2] )
        end
    end

    local actions = {

    }

    itemModel.DoClick = function()
        itemModel.Menu = vgui.Create( "bricks_server_dmenu" )
        for k, v in pairs( actions ) do
            itemModel.Menu:AddOption( k, v )
        end
        itemModel.Menu:Open()
        itemModel.Menu:SetPos( x+w+5, y+(h/2)-(itemModel.Menu:GetTall()/2) )
    end
    if( not itemModel.NoDrag ) then
        itemModel:SetDragParent( panel.item )
    end

    hook.Add( "BRS.Hooks.FillInventory", "BRS.Hooks.FillInventory_Bank", function()
        if( IsValid( self ) ) then
            self:RefreshInventory()
        end
    end )
end

function PANEL:SetNPCKey( NPCKey )
    self.NPCKey = NPCKey
end

function PANEL:RefreshInventory()
    local inventoryTable = LocalPlayer():BRS():GetInventory()

    self.inventoryGrid:Clear()

    local slotPanels = {}
    for i = 1, BRICKS_SERVER.Func.GetInventorySlots( LocalPlayer() ) do
        slotPanels[i] = self.inventoryGrid:Add( "DPanel" )
        slotPanels[i].SlotNumber = i
        slotPanels[i].invType = "Inventory"
        slotPanels[i]:SetSize( self.slotSize, self.slotSize )
        slotPanels[i]:Receiver( "inventory_slot", function( self2, panels, bDoDrop, Command, x, y )
            if( bDoDrop ) then
                local panel = panels[1]
                if( panel and IsValid( panel ) ) then
                    local slotFromType = panel.invType
                    local slotToType = self2.invType

                    if( not panel.itemKey or (panel.itemKey == self2.SlotNumber and slotFromType == slotToType) ) then return end
                    if( (slotFromType != "Inventory" and slotFromType != "Bank") or (slotToType != "Inventory" and slotToType != "Bank") ) then return end

                    net.Start( "BRS.Net.InventoryBankMoveItem" )
                        net.WriteUInt( panel.itemKey, 10 )
                        net.WriteUInt( self2.SlotNumber, 10 )
                        net.WriteString( slotFromType )
                        net.WriteString( slotToType )
                    net.SendToServer()
                end
            end
        end )
        slotPanels[i].Paint = function( self2, w, h )
            draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
        end

        if( not inventoryTable[i] ) then continue end
        FillItemSlot( self, slotPanels[i], inventoryTable[i], i )
    end
end

function PANEL:RefreshBank()
    self.bankGrid:Clear()

    local slotPanels = {}
    for i = 1, BRICKS_SERVER.Func.GetBankSlots( LocalPlayer() ) do
        slotPanels[i] = self.bankGrid:Add( "DPanel" )
        slotPanels[i].SlotNumber = i
        slotPanels[i].invType = "Bank"
        slotPanels[i]:SetSize( self.slotSize, self.slotSize )
        slotPanels[i]:Receiver( "inventory_slot", function( self2, panels, bDoDrop, Command, x, y )
            if( bDoDrop ) then
                local panel = panels[1]
                if( panel and IsValid( panel ) ) then
                    local slotFromType = panel.invType
                    local slotToType = self2.invType

                    if( not panel.itemKey or (panel.itemKey == self2.SlotNumber and slotFromType == slotToType) ) then return end
                    if( (slotFromType != "Inventory" and slotFromType != "Bank") or (slotToType != "Inventory" and slotToType != "Bank") ) then return end

                    net.Start( "BRS.Net.InventoryBankMoveItem" )
                        net.WriteUInt( panel.itemKey, 10 )
                        net.WriteUInt( self2.SlotNumber, 10 )
                        net.WriteString( slotFromType )
                        net.WriteString( slotToType )
                    net.SendToServer()
                end
            end
        end )
        slotPanels[i].Paint = function( self2, w, h )
            draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
        end

        if( BRS_BANK and BRS_BANK[i] ) then
            FillItemSlot( self, slotPanels[i], BRS_BANK[i], i )
        end
    end
end

vgui.Register( "bricks_server_ui_npc_bank", PANEL, "bricks_server_dframe" )