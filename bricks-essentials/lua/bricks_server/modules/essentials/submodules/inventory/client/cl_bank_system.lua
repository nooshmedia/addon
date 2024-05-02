BRS_BANK = BRS_BANK or {}
net.Receive( "BRS.Net.SetBank", function()
	local bankTable = net.ReadTable()

	BRS_BANK = bankTable or {}

	if( IsValid( BRICKS_SERVER_NPC_BANK ) ) then
		BRICKS_SERVER_NPC_BANK:RefreshBank()
	end
end )