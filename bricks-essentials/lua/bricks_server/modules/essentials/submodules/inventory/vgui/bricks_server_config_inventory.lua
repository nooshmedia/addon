local PANEL = {}

function PANEL:Init()

end

function PANEL:FillPanel()
    function self.RefreshPanel()
        self:Clear()

        self.slots = nil
        if( self.grid and IsValid( self.grid ) ) then
            self.grid:Remove()
        end

        BRICKS_SERVER.Func.FillVariableConfigs( self, "INVENTORY", "INVENTORY", { ["Inventory Slots"] = { function()
            BRICKS_SERVER.Func.CreateInventorySlotEditor( (BS_ConfigCopyTable.INVENTORY["Inventory Slots"] or {}), "Inventory", function( slotTable ) 
                BS_ConfigCopyTable.INVENTORY["Inventory Slots"] = slotTable
                BRICKS_SERVER.Func.ConfigChange( "INVENTORY" )
                self.RefreshPanel()
            end, function() end )
        end, #BS_ConfigCopyTable.GENERAL.Groups .. " Available Groups" },
        ["Bank Slots"] = { function()
            BRICKS_SERVER.Func.CreateInventorySlotEditor( (BS_ConfigCopyTable.INVENTORY["Bank Slots"] or {}), "Bank", function( slotTable ) 
                BS_ConfigCopyTable.INVENTORY["Bank Slots"] = slotTable
                BRICKS_SERVER.Func.ConfigChange( "INVENTORY" )
                self.RefreshPanel()
            end, function() end )
        end, #BS_ConfigCopyTable.GENERAL.Groups .. " Available Groups" } } )
    end
    self.RefreshPanel()
end

function PANEL:Paint( w, h )
    
end

vgui.Register( "bricks_server_config_inventory", PANEL, "bricks_server_scrollpanel" )