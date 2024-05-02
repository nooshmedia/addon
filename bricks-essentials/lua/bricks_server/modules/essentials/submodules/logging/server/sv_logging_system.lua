local playerMeta = FindMetaTable("Player")

util.AddNetworkString( "BRS.Net.SetLogs" )
function playerMeta:SetLogs( logsTable, nosave )
	if( not logsTable ) then return end

	self.BRS_LOGS = (logsTable or {})

	if( not nosave ) then
		self:BRS_Essentials_SaveStat( "logs" )
	end
end

function playerMeta:GetLogs()
	return (self.BRS_LOGS or {})
end

function playerMeta:SendLogs()
	local logsTable = self:GetLogs()
	
	if( logsTable ) then
		net.Start( "BRS.Net.SetLogs" )
			net.WriteTable( logsTable )
		net.Send( self )
	end
end

function playerMeta:BRS_AddLog( type, reqinfo )
	local logTypeTable = BRICKS_SERVER.DEVCONFIG.LogTypes[type]
	if( not logTypeTable ) then return end
	
	local plyLogs = self:GetLogs()

	if( #plyLogs >= (BRICKS_SERVER.CONFIG.GENERAL["Client Logs Limit"] or 10) ) then
		for i = 1, (1+(#plyLogs-BRICKS_SERVER.CONFIG.GENERAL["Client Logs Limit"])) do
			table.remove( plyLogs, 1 )
		end
	end

	local newLog = { os.time(), type, reqinfo }

	local recentLog = plyLogs[#plyLogs]
	if( recentLog and recentLog[2] == type and logTypeTable.CanCombine and logTypeTable.Combine and logTypeTable.CanCombine( recentLog[3], reqinfo ) ) then
		plyLogs[#plyLogs][1] = os.time()
		plyLogs[#plyLogs][3] = logTypeTable.Combine( recentLog[3], reqinfo )
	else
		table.insert( plyLogs, newLog )
	end

	self:SetLogs( plyLogs )
end

util.AddNetworkString( "BRS.Net.RequestLogs" )
net.Receive( "BRS.Net.RequestLogs", function( len, ply )
	if( (ply.BRS_LOGREQUEST_COOLDOWN or 0) > CurTime() ) then return end
	if( not IsValid( ply ) ) then return end
	
	ply.BRS_LOGREQUEST_COOLDOWN = CurTime()+60

	ply:SendLogs()
end )

util.AddNetworkString( "BRS.Net.DeleteLogsAdmin" )
net.Receive( "BRS.Net.DeleteLogsAdmin", function( len, ply )
	if( not BRICKS_SERVER.Func.HasAdminAccess( ply ) ) then return end

	local requestedID64 = net.ReadString()

	if( not requestedID64 ) then return end
	local requestedPly = player.GetBySteamID64( requestedID64 )

	if( IsValid( requestedPly ) ) then
		requestedPly:SetLogs( {} )

		local profileTable = {}
		if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "levelling" ) ) then
			profileTable.level = requestedPly:GetLevel()
			profileTable.experience = requestedPly:GetExperience()
		end

		if( BRICKS_SERVER.Func.IsSubModuleEnabled( "default", "currencies" ) ) then
			profileTable.currencies = requestedPly:GetCurrencies()
		end

		if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "logging" ) ) then
			profileTable.logs = requestedPly:GetLogs()
		end
		
		net.Start( "BRS.Net.ProfileAdminSend" )
			net.WriteString( requestedID64 )
			net.WriteTable( profileTable )
		net.Send( ply )
	else
		DarkRP.notify( ply, 1, 5, "Invalid player logs!" )
	end
end )