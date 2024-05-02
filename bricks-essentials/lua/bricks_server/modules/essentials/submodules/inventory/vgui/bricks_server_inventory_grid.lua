local PANEL = {}

function PANEL:Init()

end

function PANEL:FillPanel( panel, sheetButton, gridWide )
    local inventoryGrid = vgui.Create( "DIconLayout", self )
    inventoryGrid:Dock( FILL )
    local spacing = 5
    inventoryGrid:SetSpaceY( spacing )
    inventoryGrid:SetSpaceX( spacing )

    local wantedSlotSize = 125
    local slotsWide = math.floor( gridWide/wantedSlotSize )
    local slotSize = (gridWide-((slotsWide-1)*spacing))/slotsWide

    local gradient = Material( "vgui/gradient_up" ) 
    local function FillItemSlot( panel, itemTable, itemKey )
        panel.item = vgui.Create( "DPanel", panel )
        panel.item:Dock( FILL )
        panel.item:Droppable( "inventory_slot" )
        panel.item.itemKey = itemKey
        local x, y, w, h = 0, 0, slotSize, slotSize
        local itemModel
        local changeAlpha = 0
        local itemInfo = BRICKS_SERVER.Func.GetEntTypeField( (((itemTable or {})[2] or {})[1] or ""), "GetInfo" )( itemTable[2] )
        
        local tooltipInfo = {}
        tooltipInfo[1] = { itemInfo[1], false, "BRICKS_SERVER_Font22B" }
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

        BRICKS_SERVER.Func.GetEntTypeField( (((itemTable or {})[2] or {})[1] or ""), "ModelDisplay" )( itemModel, itemTable[2] )

        local actions = {
            ["Drop"] = function() 
                net.Start( "BRS.Net.InventoryDropItem" )
                    net.WriteUInt( itemKey, 10 )
                net.SendToServer()
            end
        }

        if( BRICKS_SERVER.Func.GetInvTypeCFG( itemTable[2][1] or "" ).OnUse ) then
            local canUse = true
			if( BRICKS_SERVER.Func.GetInvTypeCFG( itemTable[2][1] or "" ).CanUse ) then
				canUse = BRICKS_SERVER.Func.GetInvTypeCFG( itemTable[2][1] or "" ).CanUse( LocalPlayer(), itemTable[2] )
            end
            
            if( canUse ) then
                actions["Use"] = function() 
                    net.Start( "BRS.Net.InventoryUseItem" )
                        net.WriteUInt( itemKey, 10 )
                    net.SendToServer()
                end
            end
        end

        if( not itemTable[3] ) then
            local canEquip = false
            if( BRICKS_SERVER.Func.GetInvTypeCFG( itemTable[2][1] or "" ).CanEquip ) then
                canEquip = BRICKS_SERVER.Func.GetInvTypeCFG( itemTable[2][1] or "" ).CanEquip( LocalPlayer(), itemTable[2] )
            end
            
            if( canEquip ) then
                actions["Equip"] = function() 
                    net.Start( "BRS.Net.InventoryEquipItem" )
                        net.WriteUInt( itemKey, 10 )
                    net.SendToServer()
                end
            end
        else
            local canUnEquip = false
            if( BRICKS_SERVER.Func.GetInvTypeCFG( itemTable[2][1] or "" ).CanUnEquip ) then
                canUnEquip = BRICKS_SERVER.Func.GetInvTypeCFG( itemTable[2][1] or "" ).CanUnEquip( LocalPlayer(), itemTable[2] )
            end
            
            if( canUnEquip ) then
                actions["Un Equip"] = function() 
                    net.Start( "BRS.Net.InventoryUnEquipItem" )
                        net.WriteUInt( itemKey, 10 )
                    net.SendToServer()
                end
            end
        end

        if( BRICKS_SERVER.Func.GetInvTypeCFG( itemTable[2][1] or "" ).CanDropMultiple and (itemTable[1] or 1) > 1 ) then
            actions["Drop all"] = function() 
                net.Start( "BRS.Net.InventoryDropAllItem" )
                    net.WriteUInt( itemKey, 10 )
                net.SendToServer()
            end
        end

        itemModel.DoClick = function()
            itemModel.Menu = vgui.Create( "bricks_server_popupdmenu" )
            for k, v in pairs( actions ) do
                itemModel.Menu:AddOption( k, v )
            end
            itemModel.Menu:Open( itemModel, x+w+5, y+(h/2)-(itemModel.Menu:GetTall()/2) )
        end
        if( not itemModel.NoDrag ) then
            itemModel:SetDragParent( panel.item )
        end
    end

    local function fillInventory()
        local inventoryTable = LocalPlayer():BRS():GetInventory()

        inventoryGrid:Clear()

        local slotPanels = {}
        for i = 1, BRICKS_SERVER.Func.GetInventorySlots( LocalPlayer() ) do
            slotPanels[i] = inventoryGrid:Add( "DPanel" )
            slotPanels[i].SlotNumber = i
            slotPanels[i]:SetSize( slotSize, slotSize )
            slotPanels[i]:Receiver( "inventory_slot", function( self2, panels, bDoDrop, Command, x, y )
                if( bDoDrop ) then
                    local panel = panels[1]
                    if( panel and IsValid( panel ) ) then
                        if( panel.itemKey and panel.itemKey != self2.SlotNumber ) then
                            net.Start( "BRS.Net.InventoryMoveItem" )
                                net.WriteUInt( panel.itemKey, 10 )
                                net.WriteUInt( self2.SlotNumber, 10 )
                            net.SendToServer()
                        end
                    end
                end
            end )
            slotPanels[i].Paint = function( self2, w, h )
                draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
            end

            if( not inventoryTable[i] ) then continue end
            FillItemSlot( slotPanels[i], inventoryTable[i], i )
        end
    end
    fillInventory()

    hook.Add( "BRS.Hooks.FillInventory", self, fillInventory )
end

function PANEL:Paint( w, h )

end

vgui.Register( "bricks_server_inventory_grid", PANEL, "bricks_server_scrollpanel" )