local PANEL = {}

function PANEL:Init()

end

function PANEL:FillPanel()
    BS_ConfigCopyTable.MARKETPLACE = BS_ConfigCopyTable.MARKETPLACE or {}
    function self.RefreshPanel()
        self:Clear()

        self.slots = nil
        if( self.grid and IsValid( self.grid ) ) then
            self.grid:Remove()
        end

        BRICKS_SERVER.Func.FillVariableConfigs( self, "MARKETPLACE", "MARKETPLACE", { ["Currency"] = { function()
            BRICKS_SERVER.Func.ComboRequest( "Admin", "What currency should the marketplace be in?", ((BS_ConfigCopyTable or BRICKS_SERVER.CONFIG).MARKETPLACE["Currency"] or ""), BRICKS_SERVER.Func.GetList( "currencies" ), function( value, data ) 
                if( BRICKS_SERVER.Func.GetList( "currencies" )[data] ) then
                    BS_ConfigCopyTable.MARKETPLACE["Currency"] = data
                    BRICKS_SERVER.Func.ConfigChange( "MARKETPLACE" )
                    self.RefreshPanel()
                else
                    notification.AddLegacy( "Invalid currency!", 1, 5 )
                end
            end, function() end, "OK", "Cancel" )
        end, BRICKS_SERVER.Func.GetList( "currencies" )[((BS_ConfigCopyTable or BRICKS_SERVER.CONFIG).MARKETPLACE["Currency"] or "EMPTY VALUE")] or "NONE", "Marketplace Currency" } } )
    end
    self.RefreshPanel()
end

function PANEL:Paint( w, h )
    
end

vgui.Register( "bricks_server_config_marketplace", PANEL, "bricks_server_scrollpanel" )