BRICKS_SERVER.Func.AddConfigPage( "Bosses", "bricks_server_config_boss", "essentials" )

function BRICKS_SERVER.Func.formatHealth( number )
	local finalString = math.max( 0, number )
	
	if( finalString > 1000000 ) then
		finalString = math.Round( finalString/1000000, 1 ) .. "M"
	elseif( finalString >= 1000 ) then
		finalString = math.Round( finalString/1000, 1 ) .. "K"
	else
		finalString = math.Round( finalString )
	end

	return finalString
end

net.Receive( "BRS.Net.SendBossDead", function()
	local BossEntity = net.ReadEntity()
	local newDamageTable = net.ReadTable()
	local rewards = net.ReadTable()

	local bossTable, bossKey
	if( IsValid( BossEntity ) ) then
		bossKey = BossEntity:GetNW2Int( "BRICKS_SERVER_BOSS_KEY" )

		if( bossKey > 0 and BRICKS_SERVER.CONFIG.BOSS.NPCs[bossKey] ) then
			bossTable = BRICKS_SERVER.CONFIG.BOSS.NPCs[bossKey]
		end
	end

	if( newDamageTable and newDamageTable[LocalPlayer()] ) then
		if( bossTable ) then
			notification.AddLegacy( (bossTable.Name or "NIL") .. " has been killed! You dealt " .. BRICKS_SERVER.Func.formatHealth( newDamageTable[LocalPlayer()] or 0 ) .. " damage!", 1, 5 )
		else
			notification.AddLegacy( "NPC BOSS has been killed! You dealt " .. BRICKS_SERVER.Func.formatHealth( newDamageTable[LocalPlayer()] or 0 ) .. " damage!", 1, 5 )
		end

		if( BRICKS_SERVER.TEMP.BOSS_DAMAGE ) then
			BRICKS_SERVER.TEMP.BOSS_DAMAGE[BossEntity] = nil
		end
	else
		if( bossTable ) then
			notification.AddLegacy( (bossTable.Name or "NIL") .. " has been killed!", 1, 5 )
		else
			notification.AddLegacy( "NPC BOSS has been killed!", 1, 5 )
		end
	end

	if( IsValid( BRICKS_SERVER_BOSSBOARD ) ) then
		BRICKS_SERVER_BOSSBOARD:Remove()
	end

	if( rewards ) then
		BRICKS_SERVER.Func.AddCenterNotification( "BOSS DEFEATED", BRICKS_SERVER.Func.GetTheme( 5 ), ((bossTable or {}).Name or "NIL"), BRICKS_SERVER.Func.GetTheme( 6 ) )
		
		timer.Simple( 3, function()
			BRICKS_SERVER_BOSSREWARDS = vgui.Create( "bricks_server_boss_rewards" )
			BRICKS_SERVER_BOSSREWARDS:SetRewards( rewards, (bossKey or 0) )
		end )
	end
end )

net.Receive( "BRS.Net.SendBossDamage", function()
	local NPCEntity = net.ReadEntity()

	if( not IsValid( NPCEntity ) or LocalPlayer():GetPos():DistToSqr( NPCEntity:GetPos() ) > 4000000 ) then return end

	local damageTable = net.ReadTable()
	if( not damageTable ) then return end

	if( not BRICKS_SERVER.TEMP.BOSS_DAMAGE ) then
		BRICKS_SERVER.TEMP.BOSS_DAMAGE = {}
	end

	BRICKS_SERVER.TEMP.BOSS_DAMAGE[NPCEntity] = damageTable

	if( IsValid( BRICKS_SERVER_BOSSBOARD ) ) then
		BRICKS_SERVER_BOSSBOARD:Refresh( NPCEntity )
	end
end )

local function CreateBossBoard( BossEntity )
	if( not BRICKS_SERVER.TEMP.BOSS_DAMAGE or not BRICKS_SERVER.TEMP.BOSS_DAMAGE[BossEntity] ) then return end

	local bossTable = BRICKS_SERVER.CONFIG.BOSS.NPCs[BossEntity:GetNW2Int( "BRICKS_SERVER_BOSS_KEY" )]

	if( not bossTable ) then return end

	if( IsValid( BRICKS_SERVER_BOSSBOARD ) ) then
		BRICKS_SERVER_BOSSBOARD:Remove()
	end

	BRICKS_SERVER_BOSSBOARD = vgui.Create( "bricks_server_boss_board" )
	BRICKS_SERVER_BOSSBOARD:SetPos( 20, 20 )

	BRICKS_SERVER_BOSSBOARD:Refresh( BossEntity )
end

local lerpHealth = 0
hook.Add( "HUDPaint", "Rick&BRS.HUDPaint_Boss", function()
	if( IsValid( LocalPlayer() ) and LocalPlayer():Alive() and BRICKS_SERVER.CONFIG.BOSS.NPCs ) then
		local nearBoss = false
		for k, v in pairs( ents.FindInSphere( LocalPlayer():GetPos(), (BRICKS_SERVER.CONFIG.BOSS["Boss Bar Display Distance"] or 2000) ) ) do
			if( IsValid( v ) and v:GetNW2Int( "BRICKS_SERVER_BOSS_KEY" ) and BRICKS_SERVER.CONFIG.BOSS.NPCs[v:GetNW2Int( "BRICKS_SERVER_BOSS_KEY" )] ) then
				nearBoss = v
				break
			end
		end

		if( nearBoss and IsValid( nearBoss ) ) then
			local bossTable = BRICKS_SERVER.CONFIG.BOSS.NPCs[nearBoss:GetNW2Int( "BRICKS_SERVER_BOSS_KEY" )]
			
			BRS_SHOWINGBOSS = true

			if( not IsValid( BRICKS_SERVER_BOSSBOARD ) ) then
				CreateBossBoard( nearBoss )
			end

			local width, height = ScrW()*0.5, 10
			local y = 50
			local maxHealth = bossTable.Health

			local bossName = bossTable.Name
			draw.SimpleText( bossName, "BRICKS_SERVER_HUDFontB", ScrW()/2-1, y-5+1, Color( 0, 0, 0 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
			draw.SimpleText( bossName, "BRICKS_SERVER_HUDFontB", ScrW()/2, y-5, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
		
			lerpHealth = Lerp( RealFrameTime()*2, lerpHealth, nearBoss:Health() )
			draw.RoundedBox( 5, (ScrW()/2)-(width/2), y, width, height, BRICKS_SERVER.Func.GetTheme( 2 ) )
			draw.RoundedBox( 5, (ScrW()/2)-(width/2), y, width*math.Clamp( (lerpHealth/maxHealth), 0, 1 ), height, BRICKS_SERVER.DEVCONFIG.BaseThemes.Red )
			
			local healthStatus = BRICKS_SERVER.Func.formatHealth( nearBoss:Health() ) .. "/" .. BRICKS_SERVER.Func.formatHealth( maxHealth ) .. " [" .. math.Clamp( math.Round((nearBoss:Health()/maxHealth)*100), 0, 100 ) .. "%]"
			draw.SimpleText( healthStatus, "BRICKS_SERVER_HUDFontS", ScrW()/2-1, y+height+2+1, Color( 0, 0, 0 ), TEXT_ALIGN_CENTER, 0 )
			draw.SimpleText( healthStatus, "BRICKS_SERVER_HUDFontS", ScrW()/2, y+height+2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, 0 )
		elseif( BRS_SHOWINGBOSS ) then
			if( IsValid( BRICKS_SERVER_BOSSBOARD ) ) then
				BRICKS_SERVER_BOSSBOARD:Remove()
			end

			BRS_SHOWINGBOSS = false
		end
	elseif( BRS_SHOWINGBOSS ) then
		if( IsValid( BRICKS_SERVER_BOSSBOARD ) ) then
			BRICKS_SERVER_BOSSBOARD:Remove()
		end

		BRS_SHOWINGBOSS = false
	end
end )

function BRICKS_SERVER.Func.CreateBossEditor( oldBossTable, onSave, onCancel )
	BS_BOSS_EDITOR = vgui.Create( "DFrame" )
	BS_BOSS_EDITOR:SetSize( ScrW(), ScrH() )
	BS_BOSS_EDITOR:Center()
	BS_BOSS_EDITOR:SetTitle( "" )
	BS_BOSS_EDITOR:ShowCloseButton( false )
	BS_BOSS_EDITOR:SetDraggable( false )
	BS_BOSS_EDITOR:MakePopup()
	BS_BOSS_EDITOR:SetAlpha( 0 )
	BS_BOSS_EDITOR:AlphaTo( 255, 0.1, 0 )
	BS_BOSS_EDITOR.Paint = function( self2 ) 
		BRICKS_SERVER.Func.DrawBlur( self2, 4, 4 )
	end

	local backgroundPanel = vgui.Create( "DPanel", BS_BOSS_EDITOR )
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

	local bossTable = table.Copy( oldBossTable )

	function backLeftPanel.RefreshInfo()
		backLeftPanel:Clear()

		local topMargin, bottomMargin = backgroundPanel:GetTall()*0.075, 145
		surface.SetFont( "BRICKS_SERVER_Font20" )
		local textX, textY = surface.GetTextSize( "TEST" )

		local itemIcon = vgui.Create( "DModelPanel" , backLeftPanel )
		itemIcon:Dock( FILL )
		itemIcon:DockMargin( 0, topMargin+5+28+textY, 0, 5 )
		itemIcon:SetModel( bossTable.Model or "error.model" )
		if( IsValid( itemIcon.Entity ) ) then
			function itemIcon:LayoutEntity(ent) return end
			local mn, mx = itemIcon.Entity:GetRenderBounds()
			local size = 0
			size = math.max( size, math.abs(mn.x) + math.abs(mx.x) )
			size = math.max( size, math.abs(mn.y) + math.abs(mx.y) )
			size = math.max( size, math.abs(mn.z) + math.abs(mx.z) )

			itemIcon:SetFOV( 40 )
			itemIcon:SetCamPos( Vector( size, size, size ) )
			itemIcon:SetLookAt( (mn + mx) * 0.5 )
		end

		local itemInfoDisplay = vgui.Create( "DPanel", backLeftPanel )
		itemInfoDisplay:SetSize( backLeftPanel:GetWide(), backgroundPanel:GetTall()-topMargin-bottomMargin )
		itemInfoDisplay:SetPos( backLeftPanel:GetWide()-itemInfoDisplay:GetWide(), topMargin )
		itemInfoDisplay.Paint = function( self2, w, h ) 
			draw.SimpleText( bossTable.Name or "NEW BOSS", "BRICKS_SERVER_Font25", w/2, 5, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, 0 )
		end

		local itemInfoNoticeBack = vgui.Create( "DPanel", itemInfoDisplay )
		itemInfoNoticeBack:SetSize( 0, 35 )
		itemInfoNoticeBack:SetPos( (itemInfoDisplay:GetWide()/2)-(itemInfoNoticeBack:GetWide()/2), 5+28 )
		itemInfoNoticeBack.Paint = function( self2, w, h ) end

		local itemNotices = {}
		table.insert( itemNotices, { BRICKS_SERVER.Func.formatHealth( bossTable.Health ) .. " HP", BRICKS_SERVER.DEVCONFIG.BaseThemes.Red } )

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
			BRICKS_SERVER.Func.StringRequest( "Admin", "What should the new name be?", bossTable.Name, function( text ) 
				bossTable.Name = text
				backLeftPanel.RefreshInfo()
			end, function() end, "OK", "Cancel", false )
		end, "Name" },
		[2] = { "Model", Material( "materials/bricks_server/icon.png" ), function()
			BRICKS_SERVER.Func.StringRequest( "Admin", "What should the new model be?", bossTable.Model, function( text ) 
				bossTable.Model = text
				backLeftPanel.RefreshInfo()
			end, function() end, "OK", "Cancel", false )
		end, "Model" },
		[3] = { "Model Scale", Material( "materials/bricks_server/level.png" ), function()
			BRICKS_SERVER.Func.StringRequest( "Admin", "What should the model scale be?", (bossTable.Scale or 0), function( text )
				bossTable.Scale = text
				backLeftPanel.RefreshInfo()
			end, function() end, "OK", "Cancel", true )
		end, "Scale" },
		[4] = { "Class", Material( "materials/bricks_server/amount.png" ), function()
			BRICKS_SERVER.Func.StringRequest( "Admin", "What should the NPC class be?", bossTable.Class, function( text ) 
				bossTable.Class = text
				backLeftPanel.RefreshInfo()
			end, function() end, "OK", "Cancel", false )
		end, "Class" },
		[5] = { "Health", Material( "materials/bricks_server/health.png" ), function()
			BRICKS_SERVER.Func.StringRequest( "Admin", "How much health should the boss have?", (bossTable.Health or 0), function( text )
				bossTable.Health = text
				backLeftPanel.RefreshInfo()
			end, function() end, "OK", "Cancel", true )
		end, "Health", function() return BRICKS_SERVER.Func.formatHealth( bossTable.Health ) end },
		[6] = { "Damage Scale", Material( "materials/bricks_server/damage.png" ), function()
			BRICKS_SERVER.Func.StringRequest( "Admin", "What should the boss' damage multiplier be?", (bossTable.DamageScale or 0), function( text )
				bossTable.DamageScale = text
				backLeftPanel.RefreshInfo()
			end, function() end, "OK", "Cancel", true )
		end, "DamageScale" },
		[7] = { "Weapon", Material( "materials/bricks_server/damage.png" ), function()
			BRICKS_SERVER.Func.ComboRequest( "Admin", "What weapon should the boss have?", (bossTable.Weapon or ""), BRICKS_SERVER.Func.GetList( "weapons" ), function( value, data ) 
				if( BRICKS_SERVER.Func.GetList( "weapons" )[data] ) then
					bossTable.Weapon = data
					backLeftPanel.RefreshInfo()
				else
					notification.AddLegacy( "Invalid choice.", 1, 3 )
				end
			end, function() end, "OK", "Cancel", true )
		end, "Weapon" }
	}
	
	function backPanel.FillOptions()
		backPanel:Clear()

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

				if( v[4] and bossTable[v[4]] and not v[5] ) then
					draw.SimpleText( v[1] .. " - " .. string.sub( bossTable[v[4]], 1, 20 ), "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				elseif( v[5] and isfunction( v[5] ) ) then
					draw.SimpleText( v[1] .. " - " .. v[5](), "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				else
					draw.SimpleText( v[1], "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				end
			end
			if( v[3] ) then
				actionButton.DoClick = v[3]
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
			onSave( bossTable )

			BS_BOSS_EDITOR:AlphaTo( 0, 0.1, 0, function()
				if( IsValid( BS_BOSS_EDITOR ) ) then
					BS_BOSS_EDITOR:Remove()
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

			BS_BOSS_EDITOR:AlphaTo( 0, 0.1, 0, function()
				if( IsValid( BS_BOSS_EDITOR ) ) then
					BS_BOSS_EDITOR:Remove()
				end
			end )
		end

		backgroundPanel:SetTall( math.max( ScrH()*0.45, buttonPanel:GetTall()+(3*10)+(#actions*50) ) )
		backgroundPanel:Center()

		leftButton:SetWide( (backPanel:GetWide()-30)/2 )
		rightButton:SetWide( (backPanel:GetWide()-30)/2 )
	end
	backPanel.FillOptions()
	backLeftPanel.RefreshInfo()
end

function BRICKS_SERVER.Func.CreateBossRewardEditor( oldBossTable, onSave, onCancel )
	BS_BOSS_REWARD_EDITOR = vgui.Create( "DFrame" )
	BS_BOSS_REWARD_EDITOR:SetSize( ScrW(), ScrH() )
	BS_BOSS_REWARD_EDITOR:Center()
	BS_BOSS_REWARD_EDITOR:SetTitle( "" )
	BS_BOSS_REWARD_EDITOR:ShowCloseButton( false )
	BS_BOSS_REWARD_EDITOR:SetDraggable( false )
	BS_BOSS_REWARD_EDITOR:MakePopup()
	BS_BOSS_REWARD_EDITOR:SetAlpha( 0 )
	BS_BOSS_REWARD_EDITOR:AlphaTo( 255, 0.1, 0 )
	BS_BOSS_REWARD_EDITOR.Paint = function( self2 ) 
		BRICKS_SERVER.Func.DrawBlur( self2, 4, 4 )
	end

	local bossTable = table.Copy( oldBossTable )

	local backPanel = vgui.Create( "DPanel", BS_BOSS_REWARD_EDITOR )
	backPanel:SetSize( ScrW()*0.4, 0 )
	backPanel.Paint = function( self2, w, h ) 
		draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 0 ) )
		draw.RoundedBox( 5, 1, 1, w-2, h-2, BRICKS_SERVER.Func.GetTheme( 2 ) )
	end

	local textArea = vgui.Create( "DPanel", backPanel )
	textArea:Dock( TOP )
	textArea:DockMargin( 10, 10, 10, 0 )
	textArea:SetTall( 35 )
	textArea.Paint = function( self2, w, h ) 
		draw.SimpleText( "What should the loot be for killing the boss?", "BRICKS_SERVER_Font20", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end

	local rewardsBack = vgui.Create( "DPanel", backPanel )
	rewardsBack:Dock( TOP )
	rewardsBack:DockMargin( 10, 10, 10, 0 )
	rewardsBack:SetTall( ScrH()*0.4 )
	rewardsBack.Paint = function() end

	local rewardsScroll = vgui.Create( "bricks_server_scrollpanel", rewardsBack )
	rewardsScroll:Dock( FILL )
	
	local spacing = 5
	local gridWide = backPanel:GetWide()-20
    local wantedSlotSize = 125
    local slotsWide = math.floor( gridWide/wantedSlotSize )
	local slotSize = (gridWide-((slotsWide-1)*spacing))/slotsWide

	local lootGrid = vgui.Create( "DIconLayout", rewardsScroll )
    lootGrid:Dock( TOP )
    lootGrid:SetSpaceY( spacing )
	lootGrid:SetSpaceX( spacing )
	
	function backPanel.RefreshRewards()
		lootGrid:Clear()

		for k, v in pairs( bossTable.Loot or {} ) do
			local lootEntry = lootGrid:Add( "DButton" )
			lootEntry:SetSize( slotSize, slotSize )
			lootEntry:SetText( "" )
			local changeAlpha = 0
			local itemIcon
			local x, y, w, h = 0, 0, slotSize, slotSize
			local rewardIcon
			if( v.Icon ) then
				BRICKS_SERVER.Func.GetImage( v.Icon or "", function( mat ) rewardIcon = mat end )
			end
			lootEntry.Paint = function( self2, w, h )
				local toScreenX, toScreenY = self2:LocalToScreen( 0, 0 )
				if( x != toScreenX or y != toScreenY ) then
					x, y = toScreenX, toScreenY
				end

				draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )

				if( (itemIcon or self2):IsDown() ) then
					changeAlpha = math.Clamp( changeAlpha+10, 0, 150 )
				elseif( (itemIcon or self2):IsHovered() ) then
					changeAlpha = math.Clamp( changeAlpha+10, 0, 95 )
				else
					changeAlpha = math.Clamp( changeAlpha-10, 0, 95 )
				end

				surface.SetAlphaMultiplier( changeAlpha/255 )
				draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
				surface.SetAlphaMultiplier( 1 )

				if( v.Icon and rewardIcon ) then
					surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
					surface.SetMaterial( rewardIcon )
					local iconSize = h*0.5
					surface.DrawTexturedRect( (h-iconSize)/2, (h/2)-(iconSize/2), iconSize, iconSize )
				end

				draw.SimpleText( v.Name, "BRICKS_SERVER_Font20", w/2, h-5, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
			end
			lootEntry.DoClick = function()

			end

			if( v.Model ) then
                itemIcon = vgui.Create( "DModelPanel" , lootEntry )
                itemIcon:SetPos( 5, 5 )
                itemIcon:SetSize( lootEntry:GetTall()-10, lootEntry:GetTall()-10 )
                itemIcon:SetModel( v.Model )
				itemIcon:SetCamPos( itemIcon:GetCamPos()+Vector( 40, 0, 0 ) )
				if( IsValid( itemIcon.Entity ) ) then
					function itemIcon:LayoutEntity(ent) return end
					local mn, mx = itemIcon.Entity:GetRenderBounds()
					local size = 0
					size = math.max( size, math.abs(mn.x) + math.abs(mx.x) )
					size = math.max( size, math.abs(mn.y) + math.abs(mx.y) )
					size = math.max( size, math.abs(mn.z) + math.abs(mx.z) )
			
					itemIcon:SetCamPos( Vector( size, size, size ) )
					itemIcon:SetLookAt( (mn + mx) * 0.5 )
					itemIcon:SetFOV( 80 )
				end
			end

			local parent = lootEntry
			if( itemIcon ) then
				parent = itemIcon
			end

			parent.DoClick = function()
				BRICKS_SERVER.Func.CreateBossRewardItemEditor( v, function( rewardItem, remove ) 
					if( not remove ) then
						bossTable.Loot[k] = rewardItem
					else
						table.remove( bossTable.Loot, k )
					end
					backPanel.RefreshRewards()
				end, function() end )
			end
		end

		local lootNew = lootGrid:Add( "DButton" )
		lootNew:SetSize( slotSize, slotSize )
		lootNew:SetText( "" )
		local changeAlpha = 0
		local newMat = Material( "materials/bricks_server/add.png")
		lootNew.Paint = function( self2, w, h )
			if( selected == k ) then
				draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 4 ) )
			else
				draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
			end

			if( self2:IsDown() ) then
				changeAlpha = math.Clamp( changeAlpha+10, 0, 150 )
			elseif( self2:IsHovered() ) then
				changeAlpha = math.Clamp( changeAlpha+10, 0, 95 )
			else
				changeAlpha = math.Clamp( changeAlpha-10, 0, 95 )
			end

			surface.SetAlphaMultiplier( changeAlpha/255 )
			draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
			surface.SetAlphaMultiplier( 1 )

			if( newMat ) then
				surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
				surface.SetMaterial( newMat )
				local iconSize = 32
				surface.DrawTexturedRect( (h-iconSize)/2, (h/2)-(iconSize/2), iconSize, iconSize )
			end

			draw.SimpleText( "Add new", "BRICKS_SERVER_Font20", w/2, h-5, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
		end
		lootNew.DoClick = function()
			local newRewardItem = {
				Chance = 100,
				Name = "New Item",
				Model = "models/weapons/w_rif_ak47.mdl",
				Type = "Weapon",
				ReqInfo = { "weapon_ak472", 1, false }
			}
			
			BRICKS_SERVER.Func.CreateBossRewardItemEditor( newRewardItem, function( rewardItem, remove ) 
				if( remove ) then return end

				if( not bossTable.Loot ) then
					bossTable.Loot = {}
				end

				table.insert( bossTable.Loot, rewardItem )
				backPanel.RefreshRewards()
			end, function() end )
		end

		lootGrid:SetTall( (math.ceil((#(bossTable.Loot or {})+1)/slotsWide)*slotSize)+((math.ceil((#(bossTable.Loot or {})+1)/slotsWide)-1)*spacing) )

		lootGrid:PerformLayout()
		rewardsScroll:Rebuild()
	end
	backPanel.RefreshRewards()

	local buttonPanel = vgui.Create( "DPanel", backPanel )
	buttonPanel:Dock( BOTTOM )
	buttonPanel:DockMargin( 10, 0, 10, 10 )
	buttonPanel:SetTall( 40 )
	buttonPanel.Paint = function( self2, w, h ) end

	local leftButton = vgui.Create( "DButton", buttonPanel )
	leftButton:Dock( LEFT )
	leftButton:SetText( "" )
	leftButton:SetWide( 100 )
	local changeAlpha = 0
	leftButton.Paint = function( self2, w, h )
		if( self2:IsHovered() ) then
			changeAlpha = math.Clamp( changeAlpha+10, 0, 255 )
		else
			changeAlpha = math.Clamp( changeAlpha-10, 0, 255 )
		end
		
		draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )

		surface.SetAlphaMultiplier( changeAlpha/255 )
		draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 4 ) )
		surface.SetAlphaMultiplier( 1 )

		draw.SimpleText( "Save", "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	leftButton.DoClick = function()
		onSave( bossTable )
		BS_BOSS_REWARD_EDITOR:AlphaTo( 0, 0.1, 0, function()
			if( IsValid( BS_BOSS_REWARD_EDITOR ) ) then
				BS_BOSS_REWARD_EDITOR:Remove()
			end
		end )
	end

	local rightButton = vgui.Create( "DButton", buttonPanel )
	rightButton:Dock( RIGHT )
	rightButton:SetText( "" )
	rightButton:SetWide( 100 )
	local changeAlpha = 0
	rightButton.Paint = function( self2, w, h )
		if( self2:IsHovered() ) then
			changeAlpha = math.Clamp( changeAlpha+10, 0, 255 )
		else
			changeAlpha = math.Clamp( changeAlpha-10, 0, 255 )
		end
		
		draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )

		surface.SetAlphaMultiplier( changeAlpha/255 )
		draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 4 ) )
		surface.SetAlphaMultiplier( 1 )

		draw.SimpleText( "Cancel", "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	rightButton.DoClick = function()
		onCancel()
		BS_BOSS_REWARD_EDITOR:AlphaTo( 0, 0.1, 0, function()
			if( IsValid( BS_BOSS_REWARD_EDITOR ) ) then
				BS_BOSS_REWARD_EDITOR:Remove()
			end
		end )
	end

	backPanel:SetSize( backPanel:GetWide(), buttonPanel:GetTall()+(4*10)+textArea:GetTall()+rewardsBack:GetTall()+10 )
	backPanel:Center()
end

function BRICKS_SERVER.Func.CreateBossRewardItemEditor( oldRewardTable, onSave, onCancel )
	BS_BOSS_REWARD_ITEM_EDITOR = vgui.Create( "DFrame" )
	BS_BOSS_REWARD_ITEM_EDITOR:SetSize( ScrW(), ScrH() )
	BS_BOSS_REWARD_ITEM_EDITOR:Center()
	BS_BOSS_REWARD_ITEM_EDITOR:SetTitle( "" )
	BS_BOSS_REWARD_ITEM_EDITOR:ShowCloseButton( false )
	BS_BOSS_REWARD_ITEM_EDITOR:SetDraggable( false )
	BS_BOSS_REWARD_ITEM_EDITOR:MakePopup()
	BS_BOSS_REWARD_ITEM_EDITOR:SetAlpha( 0 )
	BS_BOSS_REWARD_ITEM_EDITOR:AlphaTo( 255, 0.1, 0 )
	BS_BOSS_REWARD_ITEM_EDITOR.Paint = function( self2 ) 
		BRICKS_SERVER.Func.DrawBlur( self2, 4, 4 )
	end

	local rewardTable = table.Copy( oldRewardTable )

	local backgroundPanel = vgui.Create( "DPanel", BS_BOSS_REWARD_ITEM_EDITOR )
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
	local rewardIcon
	backLeftPanel.Paint = function( self2, w, h ) 
		if( rewardIcon ) then
			surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
			surface.SetMaterial( rewardIcon )
			local iconSize = w*0.5
			surface.DrawTexturedRect( (w-iconSize)/2, (h/2)-(iconSize/2), iconSize, iconSize )
		end
	end

	backgroundPanel:SetSize( backPanel:GetWide()+backLeftPanel:GetWide(), 100 )
	backgroundPanel:Center()

	function backLeftPanel.RefreshInfo()
		backLeftPanel:Clear()

		local removeMat = Material( "materials/bricks_server/delete.png" )
		local button = vgui.Create( "DButton", backLeftPanel )
		button:SetSize( 36, 36 )
		button:SetPos( backLeftPanel:GetWide()-5-button:GetWide(), 5 )
		button:SetText( "" )
		local changeAlpha = 0
		button.Paint = function( self3, w, h )
			if( self3:IsDown() ) then
				changeAlpha = math.Clamp( changeAlpha+10, 0, 125 )
			elseif( self3:IsHovered() ) then
				changeAlpha = math.Clamp( changeAlpha+10, 0, 95 )
			else
				changeAlpha = math.Clamp( changeAlpha-10, 0, 95 )
			end
	
			surface.SetAlphaMultiplier( changeAlpha/255 )
			draw.RoundedBox( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 3 ) )
			surface.SetAlphaMultiplier( 1 )
	
			surface.SetMaterial( removeMat )
			local size = 24
			surface.SetDrawColor( 0, 0, 0, 255 )
			surface.DrawTexturedRect( (h-size)/2-1, (h-size)/2+1, size, size )
	
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.DrawTexturedRect( (h-size)/2, (h-size)/2, size, size )
		end
		button.DoClick = function()
			onSave( {}, true )
			BS_BOSS_REWARD_ITEM_EDITOR:AlphaTo( 0, 0.1, 0, function()
				if( IsValid( BS_BOSS_REWARD_ITEM_EDITOR ) ) then
					BS_BOSS_REWARD_ITEM_EDITOR:Remove()
				end
			end )
		end

		local topMargin, bottomMargin = backgroundPanel:GetTall()*0.075, 145
		surface.SetFont( "BRICKS_SERVER_Font20" )
		local textX, textY = surface.GetTextSize( "TEST" )

		if( rewardTable.Model ) then
			local itemIcon = vgui.Create( "DModelPanel" , backLeftPanel )
			itemIcon:Dock( FILL )
			itemIcon:DockMargin( 0, topMargin+5+28+textY, 0, 5 )
			itemIcon:SetModel( rewardTable.Model or "error.model" )
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
		elseif( rewardTable.Icon ) then
			BRICKS_SERVER.Func.GetImage( rewardTable.Icon or "", function( mat ) rewardIcon = mat end )
		end

		local itemInfoDisplay = vgui.Create( "DPanel", backLeftPanel )
		itemInfoDisplay:SetSize( backLeftPanel:GetWide(), backgroundPanel:GetTall()-topMargin-bottomMargin )
		itemInfoDisplay:SetPos( backLeftPanel:GetWide()-itemInfoDisplay:GetWide(), topMargin )
		itemInfoDisplay.Paint = function( self2, w, h ) 
			draw.SimpleText( rewardTable.Name or "New Item", "BRICKS_SERVER_Font25", w/2, 5, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, 0 )
		end

		local itemInfoNoticeBack = vgui.Create( "DPanel", itemInfoDisplay )
		itemInfoNoticeBack:SetSize( 0, 35 )
		itemInfoNoticeBack:SetPos( (itemInfoDisplay:GetWide()/2)-(itemInfoNoticeBack:GetWide()/2), 5+28 )
		itemInfoNoticeBack.Paint = function( self2, w, h ) end

		local itemNotices = {}
		table.insert( itemNotices, { "Chance " .. (rewardTable.Chance or 0) .. "%" } )

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
			BRICKS_SERVER.Func.StringRequest( "Admin", "What should the new name be?", rewardTable.Name, function( text ) 
				rewardTable.Name = text
				backLeftPanel.RefreshInfo()
			end, function() end, "OK", "Cancel", false )
		end, "Name" },
		[2] = { "Model", Material( "materials/bricks_server/icon.png" ), function()
			BRICKS_SERVER.Func.StringRequest( "Admin", "What should the new model be?", rewardTable.Model or "", function( text ) 
				rewardTable.Icon = nil
				rewardTable.Model = text
				backLeftPanel.RefreshInfo()
			end, function() end, "OK", "Cancel", false )
		end, "Model" },
		[3] = { "Model Color", Material( "materials/bricks_server/color.png" ), function()
			BRICKS_SERVER.Func.ColorRequest( "Admin", "What should the new color be?", (rewardTable.ModelColor or Color( 255, 255, 255 )), function( color ) 
				if( color == Color( 255, 255, 255 ) ) then
					rewardTable.ModelColor = nil
				else
					rewardTable.ModelColor = color
				end
				backLeftPanel.RefreshInfo()
			end, function() end, "OK", "Cancel" )
		end },
		[4] = { "Icon", Material( "materials/bricks_server/icon.png" ), function()
			BRICKS_SERVER.Func.MaterialRequest( "Admin", "What should the new icon be?", rewardTable.Icon, function( text ) 
				rewardTable.Model = nil
				rewardTable.Icon = text
				backLeftPanel.RefreshInfo()
			end, function() end, "OK", "Cancel", false )
		end, "Icon" },
		[5] = { "Drop Chance", Material( "materials/bricks_server/chance.png" ), function()
			BRICKS_SERVER.Func.StringRequest( "Admin", "What should the chance of looting this be?", rewardTable.Chance or 0, function( text ) 
				if( isnumber( tonumber( text ) ) ) then
					rewardTable.Chance = text
					backLeftPanel.RefreshInfo()
				else
					notification.AddLegacy( "Invalid number.", 1, 3 )
				end
			end, function() end, "OK", "Cancel", true )
		end, "Chance", function() return (rewardTable.Chance or 0) .. "%" end },
		[6] = { "Type", Material( "materials/bricks_server/amount.png" ), function()
			local options = {}
			for k, v in pairs( BRICKS_SERVER.DEVCONFIG.LootTypes ) do
				options[k] = k
			end
			BRICKS_SERVER.Func.ComboRequest( "Admin", "What reward type should this be?", (rewardTable.Type or ""), options, function( value, data ) 
				if( BRICKS_SERVER.DEVCONFIG.LootTypes[data] ) then
					rewardTable.ReqInfo = {}
					rewardTable.Type = data
					backLeftPanel.RefreshInfo()
					backPanel.FillOptions()
				else
					notification.AddLegacy( "Invalid type.", 1, 3 )
				end
			end, function() end, "OK", "Cancel" )
		end, "Type" }
	}

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
					draw.SimpleText( v[1] .. " - " .. (((rewardTable.ReqInfo or {})[k] and "TRUE") or "FALSE"), "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				elseif( (rewardTable.ReqInfo or {})[k] ) then
					draw.SimpleText( v[1] .. " - " .. (rewardTable.ReqInfo or {})[k], "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				else
					draw.SimpleText( v[1], "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				end
			end
			actionButton.DoClick = function()
				if( v[2] == "string" or v[2] == "integer" ) then 
					BRICKS_SERVER.Func.StringRequest( "Admin", "What should the " .. v[1] .. " be?", ((rewardTable.ReqInfo or {})[k] or 0), function( text ) 
						rewardTable.ReqInfo = rewardTable.ReqInfo or {}
						rewardTable.ReqInfo[k] = text
						backLeftPanel.RefreshInfo()
					end, function() end, "OK", "Cancel", (v[2] == "integer") )
				elseif( v[2] == "bool" ) then 
					rewardTable.ReqInfo = rewardTable.ReqInfo or {}
					rewardTable.ReqInfo[k] = not rewardTable.ReqInfo[k]
					backLeftPanel.RefreshInfo()
				elseif( v[2] == "table" and v[3] and BRICKS_SERVER.Func.GetList( v[3] ) ) then 
					BRICKS_SERVER.Func.ComboRequest( "Admin", "What data should this be?", ((rewardTable.ReqInfo or {})[k] or ""), BRICKS_SERVER.Func.GetList( v[3] ), function( value, data ) 
						if( BRICKS_SERVER.Func.GetList( v[3] )[data] ) then
							rewardTable.ReqInfo[k] = data

							if( v[4] ) then
								local newRewardTable = v[4]( rewardTable ) 
								if( newRewardTable ) then
									rewardTable = newRewardTable
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

		local itemTypeTable = BRICKS_SERVER.DEVCONFIG.LootTypes[(rewardTable.Type or "")]
		local itemReqInfo = BRICKS_SERVER.DEVCONFIG.LootTypes[(rewardTable.Type or "")].ReqInfo or {}

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

				if( v[4] and rewardTable[v[4]] and not v[5] ) then
					draw.SimpleText( v[1] .. " - " .. string.sub( rewardTable[v[4]], 1, 20 ), "BRICKS_SERVER_Font25", w/2, h/2, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
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
			onSave( rewardTable )

			BS_BOSS_REWARD_ITEM_EDITOR:AlphaTo( 0, 0.1, 0, function()
				if( IsValid( BS_BOSS_REWARD_ITEM_EDITOR ) ) then
					BS_BOSS_REWARD_ITEM_EDITOR:Remove()
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

			BS_BOSS_REWARD_ITEM_EDITOR:AlphaTo( 0, 0.1, 0, function()
				if( IsValid( BS_BOSS_REWARD_ITEM_EDITOR ) ) then
					BS_BOSS_REWARD_ITEM_EDITOR:Remove()
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