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
    
        local extraVariables = {}
    
        for k, v in pairs( BRICKS_SERVER.DEVCONFIG.SWEPUpgradeTypes ) do
            table.insert( extraVariables, { function()
                BRICKS_SERVER.Func.StringRequest( "Admin", "What should the increase be per upgrade?", ((BS_ConfigCopyTable or BRICKS_SERVER.CONFIG).SWEPUPGRADES.IncreasePercent[k] or 0), function( text ) 
                    BS_ConfigCopyTable.SWEPUPGRADES.IncreasePercent[k] = text
                    self.RefreshPanel()
                    BRICKS_SERVER.Func.ConfigChange( "SWEPUPGRADES" )
                end, function() end, "OK", "Cancel", true )
            end, ((BS_ConfigCopyTable or BRICKS_SERVER.CONFIG).SWEPUPGRADES.IncreasePercent[k] or 0) .. "%", "Increase Percent - " .. k } )
        end
    
        BRICKS_SERVER.Func.FillVariableConfigs( self, "SWEPUPGRADES", "SWEPUPGRADES", extraVariables )

        local upgradesSearchBarBack = vgui.Create( "DPanel", self )
        upgradesSearchBarBack:Dock( TOP )
        upgradesSearchBarBack:DockMargin( 0, 0, 0, 5 )
        upgradesSearchBarBack:SetTall( 40 )
        local search = Material( "materials/bricks_server/search.png" )
        local Alpha = 0
        local Alpha2 = 20
        local color1 = BRICKS_SERVER.Func.GetTheme( 2 )
        local upgradesSearchBar
        upgradesSearchBarBack.Paint = function( self2, w, h )
            draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
    
            if( upgradesSearchBar:IsEditing() ) then
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
    
        upgradesSearchBar = vgui.Create( "bricks_server_search", upgradesSearchBarBack )
        upgradesSearchBar:Dock( FILL )
        
        local upgradesSpacing = 5
        local gridWide = (ScrW()*0.6)-BRICKS_SERVER.DEVCONFIG.MainNavWidth-20
        local wantedSlotSize = 125*(ScrW()/2560)
        local slotsWide = math.floor( gridWide/wantedSlotSize )
    
        local slotSize = (gridWide-((slotsWide-1)*upgradesSpacing))/slotsWide
    
        local upgradesGrid = vgui.Create( "DIconLayout", self )
        upgradesGrid:Dock( TOP )
        upgradesGrid:SetSpaceY( upgradesSpacing )
        upgradesGrid:SetSpaceX( upgradesSpacing )
        upgradesGrid:SetTall( slotSize )

        function self.FillWeaponList()
            upgradesGrid:Clear()

            for k, v in pairs( list.Get( "Weapon" ) ) do
                local weaponName, weaponModel = (v.PrintName or "NIL"), BRICKS_SERVER.Func.GetWeaponModel( k )

                if( (upgradesSearchBar:GetValue() or "") != "" and not string.find( string.lower( weaponName ), string.lower( upgradesSearchBar:GetValue() or "" ) ) ) then
                    continue
                end

                upgradesGrid.slots = (upgradesGrid.slots or 0)+1
                local slots = upgradesGrid.slots
                local slotsTall = math.ceil( slots/slotsWide )
                upgradesGrid:SetTall( (slotsTall*slotSize)+((slotsTall-1)*upgradesSpacing) )

                local slotBack = upgradesGrid:Add( "DPanel" )
                slotBack:SetSize( slotSize, slotSize )
                local itemModel
                local changeAlpha = 0
                local x, y, w, h = 0, 0, slotSize, slotSize
                slotBack.Paint = function( self2, w, h )
                    local toScreenX, toScreenY = self2:LocalToScreen( 0, 0 )
                    if( x != toScreenX or y != toScreenY ) then
                        x, y = toScreenX, toScreenY
                    end

                    draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )

                    if( (BS_ConfigCopyTable or BRICKS_SERVER.CONFIG).SWEPUPGRADES.Blacklist[k] ) then
                        draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.DEVCONFIG.BaseThemes.Red )
                    end
                    
                    if( IsValid( itemModel ) ) then
                        if( itemModel:IsDown() ) then
                            changeAlpha = math.Clamp( changeAlpha+10, 0, 125 )
                        elseif( itemModel:IsHovered() ) then
                            changeAlpha = math.Clamp( changeAlpha+10, 0, 95 )
                        else
                            changeAlpha = math.Clamp( changeAlpha-10, 0, 95 )
                        end
                    end

                    surface.SetAlphaMultiplier( changeAlpha/255 )
                    draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
                    surface.SetAlphaMultiplier( 1 )

                    draw.SimpleText( weaponName, "BRICKS_SERVER_Font20", w/2, h-5, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
                end

                local actions = {}
                if( not (BS_ConfigCopyTable or BRICKS_SERVER.CONFIG).SWEPUPGRADES.Blacklist[k] ) then
                    actions["Upgrade Limit"] = function() 
                        BRICKS_SERVER.Func.StringRequest( "Admin", "How many times can this weapon be upgraded?", ((BS_ConfigCopyTable or BRICKS_SERVER.CONFIG).SWEPUPGRADES.UpgradeAmounts[k] or (BS_ConfigCopyTable or BRICKS_SERVER.CONFIG).SWEPUPGRADES.BaseUpgradeAmounts), function( text ) 
                            if( text != (BS_ConfigCopyTable or BRICKS_SERVER.CONFIG).SWEPUPGRADES.BaseUpgradeAmounts ) then
                                BS_ConfigCopyTable.SWEPUPGRADES.UpgradeAmounts[k] = text
                            else
                                BS_ConfigCopyTable.SWEPUPGRADES.UpgradeAmounts[k] = nil
                            end
                            self.FillWeaponList()
                            BRICKS_SERVER.Func.ConfigChange( "SWEPUPGRADES" )
                        end, function() end, "OK", "Cancel", true )
                    end
                    actions["Blacklist"] = function() 
                        BS_ConfigCopyTable.SWEPUPGRADES.Blacklist[k] = true
                        self.FillWeaponList()
                        BRICKS_SERVER.Func.ConfigChange( "SWEPUPGRADES" )
                    end
                else
                    actions["Unblacklist"] = function() 
                        BS_ConfigCopyTable.SWEPUPGRADES.Blacklist[k] = nil
                        self.FillWeaponList()
                        BRICKS_SERVER.Func.ConfigChange( "SWEPUPGRADES" )
                    end
                end

                if( weaponModel ) then
                    itemModel = vgui.Create( "DModelPanel", slotBack )
                    itemModel:Dock( FILL )
                    itemModel:SetModel( weaponModel or "" )
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
                    if( v[3] ) then
                        itemModel:SetColor( v[3] )
                    end
                else
                    itemModel = vgui.Create( "DButton", slotBack )
                    itemModel:Dock( FILL )
                    itemModel:SetText( "" )
                    itemModel.Paint = function() end
                end
                itemModel.DoClick = function()
                    itemModel.Menu = vgui.Create( "bricks_server_dmenu" )
                    for k, v in pairs( actions ) do
                        itemModel.Menu:AddOption( k, v )
                    end
                    itemModel.Menu:Open()
                    itemModel.Menu:SetPos( x+w+5, y+(h/2)-(itemModel.Menu:GetTall()/2) )
                end
            end
        end
        self.FillWeaponList()

        upgradesSearchBar.OnChange = function()
            self.FillWeaponList()
        end
    end
    self.RefreshPanel()
end

function PANEL:Paint( w, h )
    
end

vgui.Register( "bricks_server_config_upgrades", PANEL, "bricks_server_scrollpanel" )