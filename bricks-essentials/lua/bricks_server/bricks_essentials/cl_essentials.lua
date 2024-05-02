hook.Add( "BRS.Hooks.ConfigReceived", "BRS.Hooks.ConfigReceived_Essentials", function( configUnCompressed )
    if( configUnCompressed.CRAFTING and BRICKS_SERVER.LoadEntities ) then
        BRICKS_SERVER.LoadEntities()
    end
    
    if( IsValid( BRICKS_SERVER_F4 ) and BRICKS_SERVER_F4:IsVisible() ) then
        if( configUnCompressed.F4 and BRICKS_SERVER_F4.FillTabs ) then
            BRICKS_SERVER_F4:FillTabs()
        end

        if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "crafting" ) ) then hook.Run( "BRS.Hooks.FillCrafting" ) end
        if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "boosters" ) ) then hook.Run( "BRS.Hooks.FillBoosters" ) end
        if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "inventory" ) ) then hook.Run( "BRS.Hooks.FillInventory" ) end
        if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "printers" ) ) then hook.Run( "BRS.Hooks.FillPrinters" ) end
        if( BRICKS_SERVER_F4.FillProfile ) then BRICKS_SERVER_F4.FillProfile() end
        if( BRICKS_SERVER.Func.HasAdminAccess( LocalPlayer() ) ) then
            hook.Run( "BRS.Hooks.RefreshConfig" )
            if( BRICKS_SERVER_F4.RefreshAdminPerms ) then BRICKS_SERVER_F4.RefreshAdminPerms() end
        end
    elseif( configUnCompressed.F4 ) then
        BRS_F4_NEEDS_TAB_REFRESH = true
    end

    if( IsValid( BRICKS_SERVER_ZONECREATOR ) ) then
        BRICKS_SERVER_ZONECREATOR:RefreshEditPage()
    end
end )

hook.Add( "PostRender", "BRS.PostRender_ScreenGrab", function()
    if( BRS_SCREENSHOTREQUESTED ) then
        local quality = BRS_SCREENSHOTREQUESTED or 70
        BRS_SCREENSHOTREQUESTED = nil

        local imageString = render.Capture( {
            format = "jpeg",
            quality = quality,
            x = 0,
            y = 0,
            w = ScrW(),
            h = ScrH()
        } )

        local split = 60000
        local data = util.Compress( util.Base64Encode( imageString ) )
        local len = string.len( data )
        local parts = math.ceil( len/split )
        local partsTable = {}
        local previousMax = 0
        for i = 1, parts do
            local min
            local max
            if i == 1 then
                min = i
                max = split
            elseif i > 1 and i ~= parts then
                min = ( i - 1 ) * split + 1
                max = min + split - 1
            elseif i > 1 and i == parts then
                min = ( i - 1 ) * split + 1
                max = len
            end

            partsTable[i] = string.sub( data, min, max )
        end

        local currentKey = 1
        timer.Create( "BRS_SCREENSHOT_SEND", 0.1, #partsTable, function()
            if( not partsTable[currentKey] ) then return end
            
            local dataLen = string.len( partsTable[currentKey] )
            net.Start( "BRS.Net.ScreenAdminReply" )
                net.WriteUInt( currentKey, 5 )
                net.WriteUInt( #partsTable, 5 )
                net.WriteUInt( dataLen, 32 )
                net.WriteData( partsTable[currentKey], dataLen )
            net.SendToServer()

            currentKey = currentKey+1
        end )
    end
end )

net.Receive( "BRS.Net.ScreenAdminRequestSend", function( len, ply )
    BRS_SCREENSHOTREQUESTED = net.ReadUInt( 7 ) or 70
end )

net.Receive( "BRS.Net.ScreenAdminReplySend", function( len, ply )
    if( not BRICKS_SERVER.Func.HasAdminAccess( LocalPlayer() ) ) then return end
    
    local currentKey = net.ReadUInt( 5 )
    local endKey = net.ReadUInt( 5 )
    local length = net.ReadUInt( 32 )
    local imageString = net.ReadData( length )
    local requestedSteamID64 = net.ReadString()
    
    BRS_CURRENTSCREENREQUEST = (BRS_CURRENTSCREENREQUEST or "") .. imageString

    if( currentKey >= endKey ) then
        if( not IsValid( BS_ADMIN_SCREENGRAB ) ) then
            return
        end

        file.Write( "brs_temp_screengrab.jpg", util.Base64Decode( util.Decompress( BRS_CURRENTSCREENREQUEST ) ) )

        BS_ADMIN_SCREENGRAB:SetImageInfo( "data/brs_temp_screengrab.jpg", requestedSteamID64 )
        
        BRS_CURRENTSCREENREQUEST = nil
        BRS_SCREENSHOTREQUESTED = nil
    end
end )

net.Receive( "BRS.Net.ScreenAdminCancelSend", function( len, ply )
    if( timer.Exists( "BRS_SCREENSHOT_SEND" ) ) then
        timer.Remove( "BRS_SCREENSHOT_SEND" )
    end

    BRS_CURRENTSCREENREQUEST = nil
end )

local essentialsEnabled = function() return BRICKS_SERVER.Func.IsModuleEnabled( "essentials" ) end
BRICKS_SERVER.Func.AddConfigPage( "Jobs", "bricks_server_config_jobs", "essentials", essentialsEnabled )
BRICKS_SERVER.Func.AddConfigPage( "Shop", "bricks_server_config_shop", "essentials", essentialsEnabled )
BRICKS_SERVER.Func.AddConfigPage( "Armory", "bricks_server_config_armory", "essentials", essentialsEnabled )
BRICKS_SERVER.Func.AddConfigPage( "Bank", "bricks_server_config_bank", "essentials", essentialsEnabled )

BRICKS_SERVER.Func.AddAdminPlayerFunc( "Screen", "View", function( ply ) 
    net.Start( "BRS.Net.ScreenAdminRequest" )
        net.WriteString( ply:SteamID64() or "" )
        net.WriteUInt( (BS_SCREENGRAB_QUALITY or 70), 7 )
    net.SendToServer()

    if( not IsValid( BS_ADMIN_SCREENGRAB ) ) then
        BS_ADMIN_SCREENGRAB = vgui.Create( "bricks_server_admin_screengrab" )
        BS_ADMIN_SCREENGRAB.requestedID64 = ply:SteamID64()
    end
end )

function BRICKS_SERVER.Func.CreateArmoryItemEditor( oldItemTable, onSave, onCancel )
    BS_ARMORY_ITEM_EDITOR = vgui.Create( "DFrame" )
    BS_ARMORY_ITEM_EDITOR:SetSize( ScrW(), ScrH() )
    BS_ARMORY_ITEM_EDITOR:Center()
    BS_ARMORY_ITEM_EDITOR:SetTitle( "" )
    BS_ARMORY_ITEM_EDITOR:ShowCloseButton( false )
    BS_ARMORY_ITEM_EDITOR:SetDraggable( false )
    BS_ARMORY_ITEM_EDITOR:MakePopup()
    BS_ARMORY_ITEM_EDITOR:SetAlpha( 0 )
    BS_ARMORY_ITEM_EDITOR:AlphaTo( 255, 0.1, 0 )
    BS_ARMORY_ITEM_EDITOR.Paint = function( self2 ) 
        BRICKS_SERVER.Func.DrawBlur( self2, 4, 4 )
    end

    local backgroundPanel = vgui.Create( "DPanel", BS_ARMORY_ITEM_EDITOR )
    backgroundPanel:DockPadding( 1, 1, 1, 1 )
    backgroundPanel.Paint = function( self2, w, h ) 
        draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 0 ) )
        draw.RoundedBox( 5, 1, 1, w-2, h-2, BRICKS_SERVER.Func.GetTheme( 2 ) )
    end

    local backPanel = vgui.Create( "DPanel", backgroundPanel )
    backPanel:Dock( RIGHT )
    backPanel:SetWide( (2*10)+(2*150)+80 )
    backPanel.Paint = function( self2, w, h ) 
        draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
    end

    local backLeftPanel = vgui.Create( "DPanel", backgroundPanel )
    backLeftPanel:Dock( LEFT )
    backLeftPanel:SetWide( (2*10)+(2*150)+80 )
    backLeftPanel.Paint = function( self2, w, h ) end

    backgroundPanel:SetSize( backPanel:GetWide()+backLeftPanel:GetWide(), 100 )
    backgroundPanel:Center()

    local itemTable = table.Copy( oldItemTable )

    function backLeftPanel.RefreshInfo()
        backLeftPanel:Clear()

        local topMargin, bottomMargin = backgroundPanel:GetTall()*0.075, 145
        surface.SetFont( "BRICKS_SERVER_Font20" )
        local textX, textY = surface.GetTextSize( "TEST" )

        local itemIcon = vgui.Create( "DModelPanel" , backLeftPanel )
        itemIcon:Dock( FILL )
        itemIcon:DockMargin( 0, topMargin+5+28+textY, 0, 5 )
        itemIcon:SetModel( itemTable.Model or "error.model" )
        function itemIcon:LayoutEntity(ent) return end

        if( IsValid( itemIcon.Entity ) ) then
            local mn, mx = itemIcon.Entity:GetRenderBounds()
            local size = 0
            size = math.max( size, math.abs(mn.x) + math.abs(mx.x) )
            size = math.max( size, math.abs(mn.y) + math.abs(mx.y) )
            size = math.max( size, math.abs(mn.z) + math.abs(mx.z) )

            itemIcon:SetFOV( 50 )
            itemIcon:SetCamPos( Vector( size, size, size ) )
            itemIcon:SetLookAt( (mn + mx) * 0.5 )
        end

        local itemInfoDisplay = vgui.Create( "DPanel", backLeftPanel )
        itemInfoDisplay:SetSize( backLeftPanel:GetWide(), backgroundPanel:GetTall()-topMargin-bottomMargin )
        itemInfoDisplay:SetPos( backLeftPanel:GetWide()-itemInfoDisplay:GetWide(), topMargin )
        itemInfoDisplay.Paint = function( self2, w, h ) 
            draw.SimpleText( itemTable.Name or "New Item", "BRICKS_SERVER_Font25", w/2, 5, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, 0 )
        end

        local itemInfoNoticeBack = vgui.Create( "DPanel", itemInfoDisplay )
        itemInfoNoticeBack:SetSize( 0, 35 )
        itemInfoNoticeBack:SetPos( (itemInfoDisplay:GetWide()/2)-(itemInfoNoticeBack:GetWide()/2), 5+28 )
        itemInfoNoticeBack.Paint = function( self2, w, h ) end

        local itemNotices = {}

        if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "levelling" ) and itemTable.Level ) then
            table.insert( itemNotices, { "Level " .. itemTable.Level } )
        end

        if( itemTable.Group ) then
            local groupTable
            for k, v in pairs( BRICKS_SERVER.CONFIG.GENERAL.Groups ) do
                if( v[1] == itemTable.Group ) then
                    groupTable = v
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
            itemInfoNoticeBack:SetPos( (itemInfoDisplay:GetWide()/2)-(itemInfoNoticeBack:GetWide()/2), 5+28 )
        end
    end

    local actions = {
        [1] = { "Name", Material( "materials/bricks_server/name.png" ), function()
            BRICKS_SERVER.Func.StringRequest( "Admin", "What should the new name be?", itemTable.Name, function( text ) 
                itemTable.Name = text
                backLeftPanel.RefreshInfo()
            end, function() end, "OK", "Cancel", false )
        end, "Name" },
        [2] = { "Category", Material( "materials/bricks_server/folder.png" ), function()
            BRICKS_SERVER.Func.StringRequest( "Admin", "What should the new category be?", itemTable.Category, function( text ) 
                itemTable.Category = text
                backLeftPanel.RefreshInfo()
            end, function() end, "OK", "Cancel", false )
        end, "Category" },
        [3] = { "Model", Material( "materials/bricks_server/icon.png" ), function()
            BRICKS_SERVER.Func.StringRequest( "Admin", "What should the new model be?", itemTable.Model, function( text ) 
                itemTable.Model = text
                backLeftPanel.RefreshInfo()
            end, function() end, "OK", "Cancel", false )
        end, "Model" },
        [4] = { "Group", Material( "materials/bricks_server/group.png" ), function()
            local options = {}
            options["None"] = "None"
            for k, v in pairs( (BS_ConfigCopyTable or BRICKS_SERVER.CONFIG).GENERAL.Groups ) do
                options[k] = v[1]
            end
            BRICKS_SERVER.Func.ComboRequest( "Admin", "What should the group requirement be?", (itemTable.Group or ""), options, function( value, data ) 
                if( (BS_ConfigCopyTable or BRICKS_SERVER.CONFIG).GENERAL.Groups[data] ) then
                    itemTable.Group = value
                    backLeftPanel.RefreshInfo()
                elseif( value == "None" ) then
                    itemTable.Group = nil
                    backLeftPanel.RefreshInfo()
                else
                    notification.AddLegacy( "Invalid group.", 1, 3 )
                end
            end, function() end, "OK", "Cancel" )
        end, "Group" }
    }

    if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "levelling" ) ) then
        table.insert( actions, { "Level", Material( "materials/bricks_server/level.png" ), function()
            BRICKS_SERVER.Func.StringRequest( "Admin", "What should the level requirement be?", (itemTable.Level or 0), function( text )
                if( text > 0 ) then
                    itemTable.Level = text
                else
                    itemTable.Level = nil
                end
                backLeftPanel.RefreshInfo()
            end, function() end, "OK", "Cancel", true )
        end, "Level" } )
    end

    table.insert( actions, { "Job Restrictions", Material( "materials/bricks_server/jobs_24.png" ), function()
        BRICKS_SERVER.Func.CreateTeamSelector( (itemTable.Restrictions or {}), "Select the teams which can equip this item.", function( teamTable ) 
            if( table.Count( teamTable ) > 0 ) then
                itemTable.Restrictions = teamTable
            else
                itemTable.Restrictions = nil
            end
            backLeftPanel.RefreshInfo()
        end, function() end )
    end } )
    
    table.insert( actions, { "Type", Material( "materials/bricks_server/amount.png" ), function()
        local options = {}
        for k, v in pairs( BRICKS_SERVER.DEVCONFIG.ArmoryTypes ) do
            options[k] = k
        end
        BRICKS_SERVER.Func.ComboRequest( "Admin", "What item type should this be?", (itemTable.Type or ""), options, function( value, data ) 
            if( BRICKS_SERVER.DEVCONFIG.ArmoryTypes[data] ) then
                itemTable.ReqInfo = {}
                itemTable.Type = data
                backLeftPanel.RefreshInfo()
                backPanel.FillOptions()
            else
                notification.AddLegacy( "Invalid type.", 1, 3 )
            end
        end, function() end, "OK", "Cancel" )
    end, "Type" } )

    local function FillItemData( itemReqInfo )
        for k, v in pairs( itemReqInfo ) do
            local actionButton = vgui.Create( "DButton", backPanel )
            actionButton:SetText( "" )
            actionButton:Dock( TOP )
            actionButton:DockMargin( 15, 10, 15, 0 )
            actionButton:SetTall( 40 )
            local changeAlpha = 0
            actionButton.Paint = function( self2, w, h )
                if( self2:IsDown() ) then
                    changeAlpha = math.Clamp( changeAlpha+10, 0, 255 )
                elseif( self2:IsHovered() ) then
                    changeAlpha = math.Clamp( changeAlpha+10, 0, 255 )
                else
                    changeAlpha = math.Clamp( changeAlpha-10, 0, 255 )
                end
                
                draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
        
                surface.SetAlphaMultiplier( changeAlpha/255 )
                    draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 5 ) )
                surface.SetAlphaMultiplier( 1 )

                if( (itemTable.ReqInfo or {})[k] ) then
                    draw.SimpleText( v[1] .. " - " .. (itemTable.ReqInfo or {})[k], "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                else
                    draw.SimpleText( v[1], "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                end
            end
            actionButton.DoClick = function()
                if( v[2] == "string" or v[2] == "integer" ) then 
                    BRICKS_SERVER.Func.StringRequest( "Admin", "What should the " .. v[1] .. " be?", ((itemTable.ReqInfo or {})[k] or 0), function( text ) 
                        itemTable.ReqInfo = itemTable.ReqInfo or {}
                        itemTable.ReqInfo[k] = text
                        backLeftPanel.RefreshInfo()
                    end, function() end, "OK", "Cancel", (v[2] == "integer") )
                elseif( v[2] == "table" and v[3] and BRICKS_SERVER.Func.GetList( v[3] ) ) then 
                    BRICKS_SERVER.Func.ComboRequest( "Admin", "What data should this be?", ((itemTable.ReqInfo or {})[k] or ""), BRICKS_SERVER.Func.GetList( v[3] ), function( value, data ) 
                        if( BRICKS_SERVER.Func.GetList( v[3] )[data] ) then
                            itemTable.ReqInfo[k] = data

                            if( v[4] ) then
                                local newItemTable = v[4]( itemTable ) 
                                if( newItemTable ) then
                                    itemTable = newItemTable
                                end
                            end
                            backLeftPanel.RefreshInfo()
                        else
                            notification.AddLegacy( "Invalid choice.", 1, 3 )
                        end
                    end, function() end, "OK", "Cancel", true )
                end
            end
        end
    end
    
    function backPanel.FillOptions()
        backPanel:Clear()

        local itemTypeTable = BRICKS_SERVER.DEVCONFIG.ArmoryTypes[(itemTable.Type or "")]
        local itemReqInfo = BRICKS_SERVER.DEVCONFIG.ArmoryTypes[(itemTable.Type or "")].ReqInfo or {}

        for k, v in ipairs( actions ) do
            local actionButton = vgui.Create( "DButton", backPanel )
            actionButton:SetText( "" )
            actionButton:Dock( TOP )
            actionButton:DockMargin( 10, 10, 10, 0 )
            actionButton:SetTall( 40 )
            local changeAlpha = 0
            actionButton.Paint = function( self2, w, h )
                draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
                
                if( self2:IsDown() ) then
                    changeAlpha = math.Clamp( changeAlpha+10, 0, 255 )
                elseif( self2:IsHovered() ) then
                    changeAlpha = math.Clamp( changeAlpha+10, 0, 255 )
                else
                    changeAlpha = math.Clamp( changeAlpha-10, 0, 255 )
                end

                surface.SetAlphaMultiplier( changeAlpha/255 )
                    draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 5 ) )
                surface.SetAlphaMultiplier( 1 )

                if( v[2] ) then
                    surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
                    surface.SetMaterial( v[2] )
                    local iconSize = 24
                    surface.DrawTexturedRect( (h-iconSize)/2, (h/2)-(iconSize/2), iconSize, iconSize )
                end

                if( v[4] and itemTable[v[4]] and not v[5] ) then
                    draw.SimpleText( v[1] .. " - " .. string.sub( itemTable[v[4]], 1, 20 ), "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                elseif( v[5] and isfunction( v[5] ) ) then
                    draw.SimpleText( v[1] .. " - " .. v[5](), "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                else
                    draw.SimpleText( v[1], "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                end
            end
            if( v[3] ) then
                actionButton.DoClick = v[3]
            end

            if( k == #actions ) then
                FillItemData( itemReqInfo )
            end
        end

        local buttonPanel = vgui.Create( "DPanel", backPanel )
        buttonPanel:Dock( BOTTOM )
        buttonPanel:DockMargin( 10, 10, 10, 10 )
        buttonPanel:SetTall( 40 )
        buttonPanel.Paint = function( self2, w, h ) end

        local leftButton = vgui.Create( "DButton", buttonPanel )
        leftButton:Dock( LEFT )
        leftButton:SetText( "" )
        leftButton:DockMargin( 0, 0, 0, 0 )
        local changeAlpha = 0
        leftButton.Paint = function( self2, w, h )
            if( self2:IsHovered() ) then
                changeAlpha = math.Clamp( changeAlpha+10, 0, 255 )
            else
                changeAlpha = math.Clamp( changeAlpha-10, 0, 255 )
            end
            
            draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.DEVCONFIG.BaseThemes.Green )

            surface.SetAlphaMultiplier( changeAlpha/255 )
            draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.DEVCONFIG.BaseThemes.DarkGreen )
            surface.SetAlphaMultiplier( 1 )

            draw.SimpleText( "Save", "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end
        leftButton.DoClick = function()
            onSave( itemTable )

            BS_ARMORY_ITEM_EDITOR:AlphaTo( 0, 0.1, 0, function()
                if( IsValid( BS_ARMORY_ITEM_EDITOR ) ) then
                    BS_ARMORY_ITEM_EDITOR:Remove()
                end
            end )
        end

        local rightButton = vgui.Create( "DButton", buttonPanel )
        rightButton:Dock( RIGHT )
        rightButton:SetText( "" )
        rightButton:DockMargin( 0, 0, 0, 0 )
        local changeAlpha = 0
        rightButton.Paint = function( self2, w, h )
            if( self2:IsHovered() ) then
                changeAlpha = math.Clamp( changeAlpha+10, 0, 255 )
            else
                changeAlpha = math.Clamp( changeAlpha-10, 0, 255 )
            end
            
            draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.DEVCONFIG.BaseThemes.Red )

            surface.SetAlphaMultiplier( changeAlpha/255 )
            draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.DEVCONFIG.BaseThemes.DarkRed )
            surface.SetAlphaMultiplier( 1 )

            draw.SimpleText( "Cancel", "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end
        rightButton.DoClick = function()
            onCancel()

            BS_ARMORY_ITEM_EDITOR:AlphaTo( 0, 0.1, 0, function()
                if( IsValid( BS_ARMORY_ITEM_EDITOR ) ) then
                    BS_ARMORY_ITEM_EDITOR:Remove()
                end
            end )
        end

        backgroundPanel:SetTall( math.max( ScrH()*0.45, buttonPanel:GetTall()+(3*10)+(#actions*50)+(#itemReqInfo*50) ) )
        backgroundPanel:Center()

        leftButton:SetWide( (backPanel:GetWide()-30)/2 )
        rightButton:SetWide( (backPanel:GetWide()-30)/2 )
    end
    backPanel.FillOptions()
    backLeftPanel.RefreshInfo()
end