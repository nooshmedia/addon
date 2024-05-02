BRICKS_SERVER.Func.AddConfigPage( "Crafting", "bricks_server_config_crafting", "essentials" )
BRICKS_SERVER.Func.AddConfigPage( "Resources", "bricks_server_config_resources", "essentials" )

BRS_CRAFTING_TIMES = BRS_CRAFTING_TIMES or {}
net.Receive( "BRS.Net.SendCraftingTimes", function()
	local itemKey = net.ReadUInt( 8 )
	local itemTime = net.ReadUInt( 32 )

	BRS_CRAFTING_TIMES = BRS_CRAFTING_TIMES or {}
	BRS_CRAFTING_TIMES[itemKey] = itemTime

	hook.Run( "BRS.Hooks.FillCrafting" )
end )

net.Receive( "BRS.Net.FinishCrafting", function()
	local itemKey = net.ReadUInt( 8 )

	BRS_CRAFTING_TIMES = BRS_CRAFTING_TIMES or {}
	BRS_CRAFTING_TIMES[itemKey] = nil

	hook.Run( "BRS.Hooks.FillCrafting" )
end )

net.Receive( "BRS.Net.SendResourceHit", function()
	BRICKS_SERVER.Func.AddResourceHit( net.ReadVector(), net.ReadString() )
end )

BRICKS_SERVER.TEMP.ResourceHits = BRICKS_SERVER.TEMP.ResourceHits or {}
function BRICKS_SERVER.Func.AddResourceHit( pos, text )
	table.insert( BRICKS_SERVER.TEMP.ResourceHits, { pos, text, CurTime() } )
end

local function vector2( x, y )
	return {
		x = x,
		y = y
	}
end

local black = Color( 0, 0, 0 )
hook.Add( "HUDPaint", "BRS.HUDPaint_DrawResourceHits", function()
	if( not BRICKS_SERVER.TEMP.ResourceHits or table.Count( BRICKS_SERVER.TEMP.ResourceHits ) <= 0 ) then return end

	local duration = 0.5
	for k, v in pairs( BRICKS_SERVER.TEMP.ResourceHits ) do
		if( CurTime() >= v[3]+duration ) then
			BRICKS_SERVER.TEMP.ResourceHits[k] = nil
			continue
		end

		
		local progress = math.Clamp( (CurTime()-v[3])/duration, 0, 1 )
		local startPos = v[1]:ToScreen()
		local endPos = vector2( startPos.x+200, startPos.y-200 )

		local currentPos = vector2( Lerp( progress, startPos.x, endPos.x ), Lerp( progress, startPos.y, endPos.y ) )

		surface.SetAlphaMultiplier( 1-progress )
		draw.SimpleTextOutlined( v[2], "BRICKS_SERVER_Font40", currentPos.x, currentPos.y, BRICKS_SERVER.DEVCONFIG.BaseThemes.Red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, black )
		surface.SetAlphaMultiplier( 1 )
	end
end )


function BRICKS_SERVER.Func.CreateResourceEditor( oldResourceTable, onSave, onCancel )
	BS_RESOURCE_EDITOR = vgui.Create( "DFrame" )
	BS_RESOURCE_EDITOR:SetSize( ScrW(), ScrH() )
	BS_RESOURCE_EDITOR:Center()
	BS_RESOURCE_EDITOR:SetTitle( "" )
	BS_RESOURCE_EDITOR:ShowCloseButton( false )
	BS_RESOURCE_EDITOR:SetDraggable( false )
	BS_RESOURCE_EDITOR:MakePopup()
	BS_RESOURCE_EDITOR:SetAlpha( 0 )
	BS_RESOURCE_EDITOR:AlphaTo( 255, 0.1, 0 )
	BS_RESOURCE_EDITOR.Paint = function( self2 ) 
		BRICKS_SERVER.Func.DrawBlur( self2, 4, 4 )
	end

	local backPanel = vgui.Create( "DPanel", BS_RESOURCE_EDITOR )
	backPanel.Paint = function( self2, w, h ) 
		draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 0 ) )
		draw.RoundedBox( 5, 1, 1, w-2, h-2, BRICKS_SERVER.Func.GetTheme( 2 ) )
	end

	local resourceTable = table.Copy( oldResourceTable )

	local textArea = vgui.Create( "DPanel", backPanel )
	textArea:Dock( TOP )
	textArea:DockMargin( 10, 10, 10, 0 )
	textArea:SetTall( 30 )
	textArea.Paint = function( self2, w, h ) 
		draw.SimpleText( "Resource Editor", "BRICKS_SERVER_Font20", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end

	local actions = {
		[1] = { "Model", Material( "materials/bricks_server/icon.png" ), function()
			BRICKS_SERVER.Func.StringRequest( "Admin", "What should the new model be?", resourceTable[1], function( text ) 
				resourceTable[1] = text
			end, function() end, "OK", "Cancel", false )
		end, 1 },
		[2] = { "Color", Material( "materials/bricks_server/color.png" ), function()
			BRICKS_SERVER.Func.ColorRequest( "Admin", "What should the new screen color be?", (resourceTable[2] or Color( 255, 255, 255 )), function( color ) 
				if( color == Color( 255, 255, 255 ) ) then
					resourceTable[2] = nil
				else
					resourceTable[2] = color
				end
			end, function() end, "OK", "Cancel" )
		end },
	}
	
	for k, v in ipairs( actions ) do
		local actionButton = vgui.Create( "DButton", backPanel )
		actionButton:SetText( "" )
		actionButton:Dock( TOP )
		actionButton:DockMargin( 10, 10, 10, 0 )
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
			
			draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
	
			surface.SetAlphaMultiplier( changeAlpha/255 )
				draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 5 ) )
			surface.SetAlphaMultiplier( 1 )

			if( v[2] ) then
				surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
				surface.SetMaterial( v[2] )
				local iconSize = 24
				surface.DrawTexturedRect( (h-iconSize)/2, (h/2)-(iconSize/2), iconSize, iconSize )
			end

			if( v[4] and resourceTable[v[4]] and not v[5] ) then
				draw.SimpleText( v[1] .. " - " .. string.sub( resourceTable[v[4]], 1, 20 ), "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			elseif( v[5] and isfunction( v[5] ) ) then
				draw.SimpleText( v[1] .. " - " .. v[5](), "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			else
				draw.SimpleText( v[1], "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			end
		end
		actionButton.DoClick = function()
			if( v[3] ) then
				v[3]()
			end
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
		onSave( resourceTable )

		BS_RESOURCE_EDITOR:AlphaTo( 0, 0.1, 0, function()
			if( IsValid( BS_RESOURCE_EDITOR ) ) then
				BS_RESOURCE_EDITOR:Remove()
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

		BS_RESOURCE_EDITOR:AlphaTo( 0, 0.1, 0, function()
			if( IsValid( BS_RESOURCE_EDITOR ) ) then
				BS_RESOURCE_EDITOR:Remove()
			end
		end )
	end

	backPanel:SetSize( (2*10)+(2*150)+80, buttonPanel:GetTall()+(4*10)+textArea:GetTall()+(#actions*50) )
	backPanel:Center()

	leftButton:SetWide( (backPanel:GetWide()-30)/2 )
	rightButton:SetWide( (backPanel:GetWide()-30)/2 )
end

function BRICKS_SERVER.Func.CreateCraftingEditor( oldCraftingTable, onSave, onCancel )
	BS_CRAFTING_EDITOR = vgui.Create( "DFrame" )
	BS_CRAFTING_EDITOR:SetSize( ScrW(), ScrH() )
	BS_CRAFTING_EDITOR:Center()
	BS_CRAFTING_EDITOR:SetTitle( "" )
	BS_CRAFTING_EDITOR:ShowCloseButton( false )
	BS_CRAFTING_EDITOR:SetDraggable( false )
	BS_CRAFTING_EDITOR:MakePopup()
	BS_CRAFTING_EDITOR:SetAlpha( 0 )
	BS_CRAFTING_EDITOR:AlphaTo( 255, 0.1, 0 )
	BS_CRAFTING_EDITOR.Paint = function( self2 ) 
		BRICKS_SERVER.Func.DrawBlur( self2, 4, 4 )
	end

	local backgroundPanel = vgui.Create( "DPanel", BS_CRAFTING_EDITOR )
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

	local craftingTable = table.Copy( oldCraftingTable )

	function backLeftPanel.RefreshInfo()
		backLeftPanel:Clear()

		local topMargin, bottomMargin = backgroundPanel:GetTall()*0.075, 145
		surface.SetFont( "BRICKS_SERVER_Font20" )
		local textX, textY = surface.GetTextSize( "TEST" )

		local itemIcon = vgui.Create( "DModelPanel" , backLeftPanel )
		itemIcon:Dock( FILL )
		itemIcon:DockMargin( 0, topMargin+5+28+textY, 0, 5 )
		itemIcon:SetModel( craftingTable.Model or "error.model" )
		if( IsValid( itemIcon.Entity ) ) then
			function itemIcon:LayoutEntity(ent) return end
			local mn, mx = itemIcon.Entity:GetRenderBounds()
			local size = 0
			size = math.max( size, math.abs(mn.x) + math.abs(mx.x) )
			size = math.max( size, math.abs(mn.y) + math.abs(mx.y) )
			size = math.max( size, math.abs(mn.z) + math.abs(mx.z) )

			itemIcon:SetFOV( 50 )
			itemIcon:SetCamPos( Vector( size, size, size ) )
			itemIcon:SetLookAt( (mn + mx) * 0.5 )
		end

		if( craftingTable.Color ) then
			itemIcon:SetColor( craftingTable.Color )
		end

		local itemInfoDisplay = vgui.Create( "DPanel", backLeftPanel )
		itemInfoDisplay:SetSize( backLeftPanel:GetWide(), backgroundPanel:GetTall()-topMargin-bottomMargin )
		itemInfoDisplay:SetPos( backLeftPanel:GetWide()-itemInfoDisplay:GetWide(), topMargin )
		itemInfoDisplay.Paint = function( self2, w, h ) 
			draw.SimpleText( craftingTable.Name or "New Item", "BRICKS_SERVER_Font25", w/2, 5, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, 0 )
		end

		local itemInfoNoticeBack = vgui.Create( "DPanel", itemInfoDisplay )
		itemInfoNoticeBack:SetSize( 0, 35 )
		itemInfoNoticeBack:SetPos( (itemInfoDisplay:GetWide()/2)-(itemInfoNoticeBack:GetWide()/2), 5+28 )
		itemInfoNoticeBack.Paint = function( self2, w, h ) end

		local itemNotices = {}

		if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "levelling" ) and craftingTable.Level ) then
			table.insert( itemNotices, { "Level " .. craftingTable.Level } )
		end

		if( craftingTable.Group ) then
			local groupTable
			for k, v in pairs( BRICKS_SERVER.CONFIG.GENERAL.Groups ) do
				if( v[1] == craftingTable.Group ) then
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

		local resourceListBack = vgui.Create( "bricks_server_scrollpanel", itemInfoDisplay )
		resourceListBack:Dock( RIGHT )
		resourceListBack:SetWide( 50 )
		resourceListBack:DockMargin( 0, 75, 25, 0 )
		resourceListBack.Paint = function( self2, w, h ) end

		for k, v in pairs( craftingTable.Resources ) do
			local modelEntryButton = vgui.Create( "DPanel", resourceListBack )
			modelEntryButton:Dock( TOP )
			modelEntryButton:SetTall( resourceListBack:GetWide() )
			modelEntryButton:DockMargin( 0, 0, 0, 5 )
			local changeAlpha = 0
			local modelEntryIcon
			local x, y, w, h = 0, 0, modelEntryButton:GetTall(), modelEntryButton:GetTall()
			modelEntryButton.Paint = function( self2, w, h )
				local toScreenX, toScreenY = self2:LocalToScreen( 0, 0 )
				if( x != toScreenX or y != toScreenY ) then
					x, y = toScreenX, toScreenY
	
					modelEntryIcon:SetBRSToolTip( x, y, w, h, "x" .. string.Comma( v ) .. " " .. k )
				end

				if( modelEntryIcon:IsDown() ) then
					changeAlpha = math.Clamp( changeAlpha+10, 0, 125 )
				elseif( modelEntryIcon:IsHovered() ) then
					changeAlpha = math.Clamp( changeAlpha+10, 0, 75 )
				else
					changeAlpha = math.Clamp( changeAlpha-10, 0, 75 )
				end
				
				draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
		
				surface.SetAlphaMultiplier( changeAlpha/255 )
				draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 5 ) )
				surface.SetAlphaMultiplier( 1 )
			end

			local model = "error.model"
			if( BRICKS_SERVER.CONFIG.CRAFTING.Resources and BRICKS_SERVER.CONFIG.CRAFTING.Resources[k] ) then
				model = BRICKS_SERVER.CONFIG.CRAFTING.Resources[k][1]
			end

			modelEntryIcon = vgui.Create( "DModelPanel" , modelEntryButton )
			modelEntryIcon:Dock( FILL )
			modelEntryIcon:SetModel( model )
			if( modelEntryIcon.Entity and IsValid( modelEntryIcon.Entity ) ) then
				function modelEntryIcon:LayoutEntity(ent) return end
				local mn, mx = modelEntryIcon.Entity:GetRenderBounds()
				local size = 0
				size = math.max( size, math.abs(mn.x) + math.abs(mx.x) )
				size = math.max( size, math.abs(mn.y) + math.abs(mx.y) )
				size = math.max( size, math.abs(mn.z) + math.abs(mx.z) )
		
				modelEntryIcon:SetFOV( 50 )
				modelEntryIcon:SetCamPos( Vector( size, size, size ) )
				modelEntryIcon:SetLookAt( (mn + mx) * 0.5 )

				if( BRICKS_SERVER.CONFIG.CRAFTING.Resources and BRICKS_SERVER.CONFIG.CRAFTING.Resources[k] and BRICKS_SERVER.CONFIG.CRAFTING.Resources[k][2] ) then
					modelEntryIcon:SetColor( BRICKS_SERVER.CONFIG.CRAFTING.Resources[k][2] )
				end
			end
		end
	end

	local actions = {
		[1] = { "Name", Material( "materials/bricks_server/name.png" ), function()
			BRICKS_SERVER.Func.StringRequest( "Admin", "What should the new name be?", craftingTable.Name, function( text ) 
				craftingTable.Name = text
				backLeftPanel.RefreshInfo()
			end, function() end, "OK", "Cancel", false )
		end, "Name" },
		[2] = { "Type", Material( "materials/bricks_server/amount.png" ), function()
			local options = {}
			for k, v in pairs( BRICKS_SERVER.DEVCONFIG.CraftingTypes ) do
				options[k] = k
			end
			BRICKS_SERVER.Func.ComboRequest( "Admin", "What crafting type should this be?", (craftingTable.Type or ""), options, function( value, data ) 
				if( BRICKS_SERVER.DEVCONFIG.CraftingTypes[data] ) then
					craftingTable.ReqInfo = {}
					craftingTable.Type = data
					backLeftPanel.RefreshInfo()
					backPanel.FillOptions()
				else
					notification.AddLegacy( "Invalid type.", 1, 3 )
				end
			end, function() end, "OK", "Cancel" )
		end, "Type" },
		[3] = { "Resource cost", Material( "materials/bricks_server/log.png" ), false },
		[4] = { "Model", Material( "materials/bricks_server/icon.png" ), function()
			BRICKS_SERVER.Func.StringRequest( "Admin", "What should the new model be?", craftingTable.Model, function( text ) 
				craftingTable.Model = text
				backLeftPanel.RefreshInfo()
			end, function() end, "OK", "Cancel", false )
		end, "Model" },
		[5] = { "Model Color", Material( "materials/bricks_server/color.png" ), function()
			BRICKS_SERVER.Func.ColorRequest( "Admin", "What should the new model color be?", (craftingTable.Color or Color( 255, 255, 255 )), function( color ) 
				if( color == Color( 255, 255, 255 ) ) then
					craftingTable.Color = nil
					backLeftPanel.RefreshInfo()
				else
					craftingTable.Color = color
					backLeftPanel.RefreshInfo()
				end
			end, function() end, "OK", "Cancel" )
		end },
		[6] = { "Craft time", Material( "materials/bricks_server/time.png" ), function()
			BRICKS_SERVER.Func.StringRequest( "Admin", "How long should it take to craft this item?", craftingTable.CraftTime, function( text ) 
				craftingTable.CraftTime = text
				backLeftPanel.RefreshInfo()
			end, function() end, "OK", "Cancel", true )
		end, "CraftTime" },
		[7] = { "Group", Material( "materials/bricks_server/group.png" ), function()
			local options = {}
			options["None"] = "None"
			for k, v in pairs( (BS_ConfigCopyTable or BRICKS_SERVER.CONFIG).GENERAL.Groups ) do
				options[k] = v[1]
			end
			BRICKS_SERVER.Func.ComboRequest( "Admin", "What should the group requirement be?", (craftingTable.Group or ""), options, function( value, data ) 
				if( (BS_ConfigCopyTable or BRICKS_SERVER.CONFIG).GENERAL.Groups[data] ) then
					craftingTable.Group = value
					backLeftPanel.RefreshInfo()
				elseif( value == "None" ) then
					craftingTable.Group = nil
					backLeftPanel.RefreshInfo()
				else
					notification.AddLegacy( "Invalid group.", 1, 3 )
				end
			end, function() end, "OK", "Cancel" )
		end, "Group" }
	}

	if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "levelling" ) ) then
		actions[8] = { "Level", Material( "materials/bricks_server/level.png" ), function()
			BRICKS_SERVER.Func.StringRequest( "Admin", "What should the level requirement be?", craftingTable.Level, function( text ) 
				craftingTable.Level = text
				backLeftPanel.RefreshInfo()
			end, function() end, "OK", "Cancel", true )
		end, "Level" }
	end

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

				if( v[2] == "bool" ) then
					draw.SimpleText( v[1] .. " - " .. (((craftingTable.ReqInfo or {})[k] and "TRUE") or "FALSE"), "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				elseif( (craftingTable.ReqInfo or {})[k] ) then
					draw.SimpleText( v[1] .. " - " .. (craftingTable.ReqInfo or {})[k], "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				else
					draw.SimpleText( v[1], "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				end
			end
			actionButton.DoClick = function()
				if( v[2] == "string" or v[2] == "integer" ) then 
					BRICKS_SERVER.Func.StringRequest( "Admin", "What should the " .. v[1] .. " be?", ((craftingTable.ReqInfo or {})[k] or 0), function( text ) 
						craftingTable.ReqInfo = craftingTable.ReqInfo or {}
						craftingTable.ReqInfo[k] = text
						backLeftPanel.RefreshInfo()
					end, function() end, "OK", "Cancel", (v[2] == "integer") )
				elseif( v[2] == "bool" ) then 
					craftingTable.ReqInfo = craftingTable.ReqInfo or {}
					craftingTable.ReqInfo[k] = not craftingTable.ReqInfo[k]
					backLeftPanel.RefreshInfo()
				elseif( v[2] == "table" and v[3] and BRICKS_SERVER.Func.GetList( v[3] ) ) then 
					BRICKS_SERVER.Func.ComboRequest( "Admin", "What data should this be?", ((craftingTable.ReqInfo or {})[k] or ""), BRICKS_SERVER.Func.GetList( v[3] ), function( value, data ) 
						if( BRICKS_SERVER.Func.GetList( v[3] )[data] ) then
							craftingTable.ReqInfo[k] = data

							if( v[4] ) then
								local newCraftingTable = v[4]( craftingTable ) 
								if( newCraftingTable ) then
									craftingTable = newCraftingTable
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

		local itemTypeTable = BRICKS_SERVER.DEVCONFIG.CraftingTypes[(craftingTable.Type or "")]
		local itemReqInfo = BRICKS_SERVER.DEVCONFIG.CraftingTypes[(craftingTable.Type or "")].ReqInfo or {}

		for k, v in ipairs( actions ) do
			local actionButton
			if( v[3] ) then
				actionButton = vgui.Create( "DButton", backPanel )
				actionButton:SetText( "" )
			else
				actionButton = vgui.Create( "DPanel", backPanel )
			end
			actionButton:Dock( TOP )
			actionButton:DockMargin( 10, 10, 10, 0 )
			actionButton:SetTall( 40 )
			local changeAlpha = 0
			actionButton.Paint = function( self2, w, h )
				draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
				
				if( v[3] ) then
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
				end

				if( v[2] ) then
					surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
					surface.SetMaterial( v[2] )
					local iconSize = 24
					surface.DrawTexturedRect( (h-iconSize)/2, (h/2)-(iconSize/2), iconSize, iconSize )
				end

				if( v[4] and craftingTable[v[4]] and not v[5] ) then
					draw.SimpleText( v[1] .. " - " .. string.sub( craftingTable[v[4]], 1, 20 ), "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				elseif( v[5] and isfunction( v[5] ) ) then
					draw.SimpleText( v[1] .. " - " .. v[5](), "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				else
					draw.SimpleText( v[1], "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				end
			end
			if( v[3] ) then
				actionButton.DoClick = v[3]
			end

			if( k == 2 ) then
				FillItemData( itemReqInfo )
			elseif( k == 3 ) then
				local spacing = 5
				local gridWide = backPanel:GetWide()-30
				local slotsWide = 8
				local slotSize = (gridWide-((slotsWide-1)*spacing))/slotsWide

				backPanel.grid = vgui.Create( "DIconLayout", backPanel )
                backPanel.grid:Dock( TOP )
                backPanel.grid:DockMargin( 15, 10, 15, 0 )
                backPanel.grid:SetTall( slotSize )
                backPanel.grid:SetSpaceY( spacing )
				backPanel.grid:SetSpaceX( spacing )
				
				for k, v in pairs( BS_ConfigCopyTable.CRAFTING.Resources or {} ) do
					if( ((craftingTable.Resources or {})[k] or 0) <= 0 ) then continue end

					backPanel.grid.slots = (backPanel.grid.slots or 0)+1
					local slots = backPanel.grid.slots
					local slotsTall = math.ceil( slots/slotsWide )
					backPanel.grid:SetTall( (slotsTall*slotSize)+((slotsTall-1)*spacing) )

					local modelEntryButton = vgui.Create( "DPanel", backPanel.grid )
					modelEntryButton:SetSize( slotSize, slotSize )
					local changeAlpha = 0
					local modelEntryIcon
					local x, y, w, h = 0, 0, modelEntryButton:GetTall(), modelEntryButton:GetTall()
					modelEntryButton.Paint = function( self2, w, h )
						local toScreenX, toScreenY = self2:LocalToScreen( 0, 0 )
						if( x != toScreenX or y != toScreenY ) then
							x, y = toScreenX, toScreenY
			
							modelEntryIcon:SetBRSToolTip( x, y, w, h, "x" .. string.Comma( (craftingTable.Resources or {})[k] or 0 ) .. " " .. k )
						end
		
						if( modelEntryIcon:IsDown() ) then
							changeAlpha = math.Clamp( changeAlpha+10, 0, 125 )
						elseif( modelEntryIcon:IsHovered() ) then
							changeAlpha = math.Clamp( changeAlpha+10, 0, 75 )
						else
							changeAlpha = math.Clamp( changeAlpha-10, 0, 75 )
						end
						
						draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
				
						surface.SetAlphaMultiplier( changeAlpha/255 )
						draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 5 ) )
						surface.SetAlphaMultiplier( 1 )
					end
		
					modelEntryIcon = vgui.Create( "DModelPanel" , modelEntryButton )
					modelEntryIcon:Dock( FILL )
					modelEntryIcon:SetModel( v[1] or "error.model" )
					if( modelEntryIcon.Entity and IsValid( modelEntryIcon.Entity ) ) then
						function modelEntryIcon:LayoutEntity(ent) return end
						local mn, mx = modelEntryIcon.Entity:GetRenderBounds()
						local size = 0
						size = math.max( size, math.abs(mn.x) + math.abs(mx.x) )
						size = math.max( size, math.abs(mn.y) + math.abs(mx.y) )
						size = math.max( size, math.abs(mn.z) + math.abs(mx.z) )
				
						modelEntryIcon:SetFOV( 50 )
						modelEntryIcon:SetCamPos( Vector( size, size, size ) )
						modelEntryIcon:SetLookAt( (mn + mx) * 0.5 )
		
						if( v[2] ) then
							modelEntryIcon:SetColor( v[2] )
						end
					end
					modelEntryIcon.DoClick = function()
						BRICKS_SERVER.Func.StringRequest( "Admin", "How much of this resource is needed to craft it?", ((craftingTable.Resources or {})[k] or 0), function( text ) 
							craftingTable.Resources = craftingTable.Resources or {}
							if( text > 0 ) then
								craftingTable.Resources[k] = text
							else
								craftingTable.Resources[k] = nil
							end

							backPanel.FillOptions()
							backLeftPanel.RefreshInfo()
						end, function() end, "OK", "Cancel", true )
					end
				end

				backPanel.grid.slots = (backPanel.grid.slots or 0)+1
				local slots = backPanel.grid.slots
				local slotsTall = math.ceil( slots/slotsWide )
				backPanel.grid:SetTall( (slotsTall*slotSize)+((slotsTall-1)*spacing) )

				local modelEntryButton = vgui.Create( "DButton", backPanel.grid )
				modelEntryButton:SetSize( slotSize, slotSize )
				modelEntryButton:SetText( "" )
				local changeAlpha = 0
				local newMat = Material( "materials/bricks_server/add_64.png")
				modelEntryButton.Paint = function( self2, w, h )
					if( self2:IsDown() ) then
						changeAlpha = math.Clamp( changeAlpha+10, 0, 125 )
					elseif( self2:IsHovered() ) then
						changeAlpha = math.Clamp( changeAlpha+10, 0, 75 )
					else
						changeAlpha = math.Clamp( changeAlpha-10, 0, 75 )
					end
					
					draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
			
					surface.SetAlphaMultiplier( changeAlpha/255 )
					draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 5 ) )
					surface.SetAlphaMultiplier( 1 )

					surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
					surface.SetMaterial( newMat )
					local iconSize = w*0.6
					surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
				end
				modelEntryButton.DoClick = function()
					local newResources = {}
					for k, v in pairs( BS_ConfigCopyTable.CRAFTING.Resources or {} ) do
						if( ((craftingTable.Resources or {})[k] or 0) > 0 ) then continue end

						newResources[k] = k
					end

					BRICKS_SERVER.Func.ComboRequest( "Admin", "What resource would you like to add?", "", newResources, function( value, data ) 
						if( newResources[value] ) then
							craftingTable.Resources = craftingTable.Resources or {}
							craftingTable.Resources[value] = 1

							backPanel.FillOptions()
							backLeftPanel.RefreshInfo()
						else
							notification.AddLegacy( "Invalid resource.", 1, 3 )
						end
					end, function() end, "OK", "Cancel", true )
				end
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
			onSave( craftingTable )

			BS_CRAFTING_EDITOR:AlphaTo( 0, 0.1, 0, function()
				if( IsValid( BS_CRAFTING_EDITOR ) ) then
					BS_CRAFTING_EDITOR:Remove()
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

			BS_CRAFTING_EDITOR:AlphaTo( 0, 0.1, 0, function()
				if( IsValid( BS_CRAFTING_EDITOR ) ) then
					BS_CRAFTING_EDITOR:Remove()
				end
			end )
		end

		if( backPanel.grid and IsValid( backPanel.grid ) ) then
			backgroundPanel:SetTall( buttonPanel:GetTall()+(3*10)+(#actions*50)+(#itemReqInfo*50)+backPanel.grid:GetTall() )
		else
			backgroundPanel:SetTall( buttonPanel:GetTall()+(3*10)+(#actions*50)+(#itemReqInfo*50) )
		end
		backgroundPanel:Center()

		leftButton:SetWide( (backPanel:GetWide()-30)/2 )
		rightButton:SetWide( (backPanel:GetWide()-30)/2 )
	end
	backPanel.FillOptions()
	backLeftPanel.RefreshInfo()
end