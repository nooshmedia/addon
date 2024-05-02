BRS_LOGS = BRS_LOGS or {}
net.Receive( "BRS.Net.SetLogs", function()
	local logsTable = net.ReadTable()

	BRS_LOGS = logsTable or {}

	if( IsValid( BRICKS_SERVER_F4 ) and BRICKS_SERVER_F4:IsVisible() and BRICKS_SERVER_F4.FillLogs ) then
		BRICKS_SERVER_F4.FillLogs()
	end
end )