local PANEL = {}
	
function PANEL:Init()
	BRICKS_SERVER_ARMORY_W, BRICKS_SERVER_ARMORY_H = ScrW()*0.65, ScrW()*0.65
	self:SetSize( ScrW()*0.65, ScrH()*0.65 )
	self:Center()
	self:MakePopup()
	self:SetTitle( "" )
	self:ShowCloseButton( false )
	self:SetDraggable( false )
	self:DockPadding( 0, 40, 0, 0 )

	local closeButton = vgui.Create( "DButton", self )
	local size = 24
	closeButton:SetSize( size, size )
	closeButton:SetPos( self:GetWide()-size-((40-size)/2), (40/2)-(size/2) )
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
	
	local ColSheet = vgui.Create( "bricks_server_colsheet_top", self )
	ColSheet:Dock( FILL )

	local ListSpacing = 5
	local ListWide = 2
	
	local categories = {}
	local itemTable = {}
	for k, v in pairs( BRICKS_SERVER.CONFIG.ARMORY.Items or {} ) do
		local itemCategory = v.Category or "Other"
		if( not categories[itemCategory] ) then
			categories[itemCategory] = vgui.Create( "bricks_server_scrollpanel", ColSheet )
			categories[itemCategory]:Dock( FILL )
			categories[itemCategory]:DockMargin( 10, 10, 10, 10 )
		
			ColSheet:AddSheet( itemCategory, categories[itemCategory] )

			categories[itemCategory].grid = vgui.Create( "DIconLayout", categories[itemCategory] )
			categories[itemCategory].grid:Dock( FILL )
			categories[itemCategory].grid:SetSpaceX( ListSpacing )
			categories[itemCategory].grid:SetSpaceY( ListSpacing )
		end

		itemTable[k] = v
		itemTable[k].key = k
	end
	
	table.sort( itemTable, function(a, b) return ((a or {}).Level or 0) < ((b or {}).Level or 0) end)
	
	local itemWide = (BRICKS_SERVER_ARMORY_W-20-((ListWide-1)*ListSpacing))/ListWide
	for k, v in pairs( itemTable ) do
		local itemCategory = v.Category or "Other"

		local displayInfo
		if( BRICKS_SERVER.DEVCONFIG.ArmoryTypes[v.Type or ""] and BRICKS_SERVER.DEVCONFIG.ArmoryTypes[v.Type or ""].GetDisplayInfo ) then
			displayInfo = BRICKS_SERVER.DEVCONFIG.ArmoryTypes[v.Type or ""].GetDisplayInfo( v.ReqInfo )
		end

		local itemBack = vgui.Create( "DPanel", categories[itemCategory].grid )
		itemBack:SetSize( itemWide, 100 )
		itemBack:DockPadding( 0, 0, 25, 0 )
		itemBack.Paint = function( self2, w, h )
			draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )

			draw.RoundedBox( 5, 5, 5, h-10, h-10, BRICKS_SERVER.Func.GetTheme( 2 ) )

			draw.SimpleText( v.Name, "BRICKS_SERVER_Font33", h+15, 5, BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )

			if( displayInfo ) then
				for i = 1, #displayInfo do
					if( not displayInfo[i] ) then continue end

					draw.SimpleText( displayInfo[i], "BRICKS_SERVER_Font20", h+15, 32+((i-1)*15), BRICKS_SERVER.Func.GetTheme( 6 ), 0, 0 )
				end
			end
		end

		surface.SetFont( "BRICKS_SERVER_Font33" )
		local nameX, nameY = surface.GetTextSize( v.Name )
		local itemInfoNoticeBack = vgui.Create( "DPanel", itemBack )
		itemInfoNoticeBack:SetSize( 0, 35 )
		itemInfoNoticeBack:SetPos( itemBack:GetTall()+15+nameX+5, 14 )
		itemInfoNoticeBack.Paint = function( self2, w, h ) end

		local itemNotices = {}

		if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "levelling" ) and v.Level ) then
			table.insert( itemNotices, { "Level " .. v.Level } )
		end

		if( v.Group ) then
			local groupTable
			for key, val in pairs( BRICKS_SERVER.CONFIG.GENERAL.Groups ) do
				if( val[1] == v.Group ) then
					groupTable = val
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
		end

		local itemModel = vgui.Create( "DModelPanel" , itemBack )
		itemModel:SetPos( 5, 5 )
		itemModel:SetSize( itemBack:GetTall()-10, itemBack:GetTall()-10 )
		itemModel:SetModel( v.Model or "models/error.mdl" )
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

		local itemAction = vgui.Create( "DButton", itemBack )
		itemAction:Dock( RIGHT )
		itemAction:SetText( "" )
		itemAction:DockMargin( 5, 25, 5, 25 )
		surface.SetFont( "BRICKS_SERVER_Font25" )
		local textX, textY = surface.GetTextSize( "Equip" )
		textX = textX+20
		itemAction:SetWide( math.max( (ScrW()/2560)*150, textX ) )
		local changeAlpha = 0
		itemAction.Paint = function( self2, w, h )
			if( self2:IsDown() ) then
				changeAlpha = math.Clamp( changeAlpha+10, 0, 125 )
			elseif( self2:IsHovered() ) then
				changeAlpha = math.Clamp( changeAlpha+10, 0, 75 )
			else
				changeAlpha = math.Clamp( changeAlpha-10, 0, 75 )
			end
			
			draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
	
			surface.SetAlphaMultiplier( changeAlpha/255 )
			draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
			surface.SetAlphaMultiplier( 1 )

			draw.SimpleText( "Equip", "BRICKS_SERVER_Font25", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
		itemAction.DoClick = function()
			if( BRICKS_SERVER.CONFIG.ARMORY.Items[v.key] ) then
				net.Start( "BRS.Net.ArmoryEquipItem" )
					net.WriteUInt( v.key, 8 )
				net.SendToServer()
			end
		end
		
		if( v.Restrictions and not v.Restrictions[RPExtraTeams[LocalPlayer():Team()].command] ) then

		end
	end
end

local rounded = 5
function PANEL:Paint( w, h )
    draw.RoundedBox( rounded, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
    draw.RoundedBoxEx( rounded, 0, 0, w, 40, BRICKS_SERVER.Func.GetTheme( 0 ), true, true, false, false )

    draw.SimpleText( "Armory", "BRICKS_SERVER_Font30", 10, 40/2-2, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_CENTER )
end

vgui.Register( "bricks_server_armory_menu", PANEL, "DFrame" )