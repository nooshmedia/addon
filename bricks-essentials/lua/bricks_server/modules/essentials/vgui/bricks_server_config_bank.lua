local PANEL = {}

function PANEL:Init()

end

function PANEL:FillPanel()
    BS_ConfigCopyTable.BANKVAULT = BS_ConfigCopyTable.BANKVAULT or {}
    function self.RefreshPanel()
        self:Clear()

        self.slots = nil
        if( self.grid and IsValid( self.grid ) ) then
            self.grid:Remove()
        end

        local teamRobberCount = table.Count( (BS_ConfigCopyTable or BRICKS_SERVER.CONFIG).BANKVAULT.RobberTeams )
        local teamPoliceCount = table.Count( (BS_ConfigCopyTable or BRICKS_SERVER.CONFIG).BANKVAULT.PoliceJobs )
        local amount1 = (((BS_ConfigCopyTable or BRICKS_SERVER.CONFIG).BANKVAULT["Money Bag Amount"] or {})[1] or 0)
        local amount2 = (((BS_ConfigCopyTable or BRICKS_SERVER.CONFIG).BANKVAULT["Money Bag Amount"] or {})[2] or 0)
        local multiAmount1 = (((BS_ConfigCopyTable or BRICKS_SERVER.CONFIG).BANKVAULT["Dirty To Clean Money Multiplier"] or {})[1] or 0)
        local multiAmount2 = (((BS_ConfigCopyTable or BRICKS_SERVER.CONFIG).BANKVAULT["Dirty To Clean Money Multiplier"] or {})[2] or 0)
        BRICKS_SERVER.Func.FillVariableConfigs( self, "BANKVAULT", "BANKVAULT", { 
            ["RobberTeams"] = { function()
                BRICKS_SERVER.Func.CreateTeamSelector( (BS_ConfigCopyTable.BANKVAULT.RobberTeams or {}), "Select the teams which can rob the bank vault below.", function( teamTable ) 
                    BS_ConfigCopyTable.BANKVAULT.RobberTeams = teamTable
                    BRICKS_SERVER.Func.ConfigChange( "BANKVAULT" )
                    self.RefreshPanel()
                end, function() end )
            end, teamRobberCount .. " Robber " .. ((teamRobberCount != 1 and "Teams") or "Team"), "Edit Robber Teams" },
            ["PoliceJobs"] = { function()
                BRICKS_SERVER.Func.CreateTeamSelector( (BS_ConfigCopyTable.BANKVAULT.PoliceJobs or {}), "Select the teams which count towards the police requirement.", function( teamTable ) 
                    BS_ConfigCopyTable.BANKVAULT.PoliceJobs = teamTable
                    BRICKS_SERVER.Func.ConfigChange( "BANKVAULT" )
                    self.RefreshPanel()
                end, function() end )
            end, teamPoliceCount .. " Police " .. ((teamPoliceCount != 1 and "Teams") or "Team"), "Edit Police Teams" },
            ["Money Bag Amount"] = { function()
                BRICKS_SERVER.Func.StringRequest( "Admin", "What should the minimum money bag reward be?", (((BS_ConfigCopyTable or BRICKS_SERVER.CONFIG).BANKVAULT["Money Bag Amount"] or {})[1] or 0), function( number1 ) 
                    BRICKS_SERVER.Func.StringRequest( "Admin", "What should the maximum money bag reward be?", (((BS_ConfigCopyTable or BRICKS_SERVER.CONFIG).BANKVAULT["Money Bag Amount"] or {})[2] or 0), function( number2 ) 
                        BS_ConfigCopyTable.BANKVAULT["Money Bag Amount"] = { (number1 or 0), (number2 or 0) }
                        BRICKS_SERVER.Func.ConfigChange( "BANKVAULT" )
                        self.RefreshPanel()
                    end, function() end, "OK", "Cancel", true )
                end, function() end, "OK", "Cancel", true )
            end, DarkRP.formatMoney( amount1 ) .. " - " .. DarkRP.formatMoney( amount2 ), "Money Bag Amount" },
            ["Dirty To Clean Money Multiplier"] = { function()
                BRICKS_SERVER.Func.StringRequest( "Admin", "What should the minimum multiplier be?", (((BS_ConfigCopyTable or BRICKS_SERVER.CONFIG).BANKVAULT["Dirty To Clean Money Multiplier"] or {})[1] or 0), function( number1 ) 
                    BRICKS_SERVER.Func.StringRequest( "Admin", "What should the maximum multiplier be?", (((BS_ConfigCopyTable or BRICKS_SERVER.CONFIG).BANKVAULT["Dirty To Clean Money Multiplier"] or {})[2] or 0), function( number2 ) 
                        BS_ConfigCopyTable.BANKVAULT["Dirty To Clean Money Multiplier"] = { (number1 or 0), (number2 or 0) }
                        BRICKS_SERVER.Func.ConfigChange( "BANKVAULT" )
                        self.RefreshPanel()
                    end, function() end, "OK", "Cancel", true )
                end, function() end, "OK", "Cancel", true )
            end, multiAmount1 .. " - " .. multiAmount2, "Dirty To Clean Money Multiplier" }
        } )
    end
    self.RefreshPanel()
end

function PANEL:Paint( w, h )
    
end

vgui.Register( "bricks_server_config_bank", PANEL, "bricks_server_scrollpanel" )