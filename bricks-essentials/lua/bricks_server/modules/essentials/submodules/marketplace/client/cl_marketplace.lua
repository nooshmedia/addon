BRICKS_SERVER.Func.AddConfigPage( "Marketplace", "bricks_server_config_marketplace", "essentials" )

BRS_MARKETPLACE = BRS_MARKETPLACE or {}
net.Receive( "BRS.Net.UpdateMarketplace", function()
	local marketplaceTable = net.ReadTable()

	BRS_MARKETPLACE = marketplaceTable or {}

	if( IsValid( BRICKS_SERVER_MARKETPLACE ) and BRICKS_SERVER_MARKETPLACE:IsVisible() ) then
		BRICKS_SERVER_MARKETPLACE:Refresh()
		BRICKS_SERVER_MARKETPLACE:RefreshMyAuctions()
		BRICKS_SERVER_MARKETPLACE:RefreshMyBids()
		if( BRICKS_SERVER.Func.HasAdminAccess( LocalPlayer() ) and BRICKS_SERVER_MARKETPLACE.RefreshAdmin ) then
			BRICKS_SERVER_MARKETPLACE:RefreshAdmin()
		end
	else
		net.Start( "BRS.Net.MarketplaceClose" )
        net.SendToServer()
	end
end )

net.Receive( "BRS.Net.OpenMarketplace", function()
	local marketplaceTable = net.ReadTable()

	BRS_MARKETPLACE = marketplaceTable or {}
	
	if( not IsValid( BRICKS_SERVER_MARKETPLACE ) ) then
		BRICKS_SERVER_MARKETPLACE = vgui.Create( "bricks_server_ui_npc_marketplace" )
		BRICKS_SERVER_MARKETPLACE:Refresh()
		BRICKS_SERVER_MARKETPLACE:RefreshMyAuctions()
		BRICKS_SERVER_MARKETPLACE:RefreshMyBids()
		BRICKS_SERVER_MARKETPLACE:RefreshInventory()
		BRICKS_SERVER_MARKETPLACE:RefreshSelection()
		if( BRICKS_SERVER.Func.HasAdminAccess( LocalPlayer() ) and BRICKS_SERVER_MARKETPLACE.RefreshAdmin ) then
			BRICKS_SERVER_MARKETPLACE:RefreshAdmin()
		end
	end
end )