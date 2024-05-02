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

        BRICKS_SERVER.Func.FillVariableConfigs( self, "LEVELING", "LEVELING" )
    end
    self.RefreshPanel()
end

function PANEL:Paint( w, h )
    
end

vgui.Register( "bricks_server_config_levelling", PANEL, "bricks_server_scrollpanel" )