BRICKS_SERVER.Func.AddConfigPage( "Upgrades", "bricks_server_config_upgrades", "essentials" )

net.Receive( "BRS.Net.UseSWEPUpgrader", function()
	local NPCKey = net.ReadUInt( 8 )

	if( not NPCKey or not BRICKS_SERVER.CONFIG.NPCS[NPCKey] ) then return end

	if( not IsValid( BRICKS_SERVER_NPC_SWEPUPGRADER ) ) then
		BRICKS_SERVER_NPC_SWEPUPGRADER = vgui.Create( "bricks_server_dframe" )
		BRICKS_SERVER_NPC_SWEPUPGRADER:SetHeader( BRICKS_SERVER.CONFIG.NPCS[NPCKey].Name )
		BRICKS_SERVER_NPC_SWEPUPGRADER:SetSize( ScrW()*0.6, ScrH()*0.65 )
		BRICKS_SERVER_NPC_SWEPUPGRADER:Center()
		BRICKS_SERVER_NPC_SWEPUPGRADER.removeOnClose = true

		BRICKS_SERVER_NPC_SWEPUPGRADER.mainPage = vgui.Create( "bricks_server_ui_swepupgrader", BRICKS_SERVER_NPC_SWEPUPGRADER )
		BRICKS_SERVER_NPC_SWEPUPGRADER.mainPage:Dock( FILL )
		BRICKS_SERVER_NPC_SWEPUPGRADER.mainPage:FillPanel( BRICKS_SERVER_NPC_SWEPUPGRADER:GetWide() )
	else
		BRICKS_SERVER_NPC_SWEPUPGRADER:SetVisible( true )
	end
end )

net.Receive( "BRS.Net.SendSWEPInfo", function()
	local wepClass = net.ReadString()
	local variable = net.ReadString()
	local value = net.ReadFloat()

	local weaponEnt = LocalPlayer():GetWeapon( wepClass or "" )

	if( not IsValid( weaponEnt ) ) then return end

	if( weaponEnt.Primary and weaponEnt.Primary[variable] ) then
		weaponEnt.Primary[variable] = value
	else
		weaponEnt[variable] = value
	end

	if( BRICKS_SERVER_NPC_SWEPUPGRADER and IsValid( BRICKS_SERVER_NPC_SWEPUPGRADER.mainPage ) ) then
		BRICKS_SERVER_NPC_SWEPUPGRADER.mainPage:FillPanel( BRICKS_SERVER_NPC_SWEPUPGRADER:GetWide() )
	end
end )