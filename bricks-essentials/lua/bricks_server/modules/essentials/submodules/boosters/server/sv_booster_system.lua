local playerMeta = FindMetaTable("Player")

util.AddNetworkString( "BRS.Net.SetBoosters" )
function playerMeta:SetBoosters( boostersTable, nosave )
	if( not boostersTable ) then return end

	net.Start( "BRS.Net.SetBoosters" )
		net.WriteTable( boostersTable )
	net.Send( self )

	self.BRS_BOOSTERS = (boostersTable or {})

	if( not nosave ) then
		self:BRS_Essentials_SaveStat( "boosters" )
	end
end

function playerMeta:GetBoosters()
	return (self.BRS_BOOSTERS or {})
end

function playerMeta:AddBooster( boosterKey )
	if( not BRICKS_SERVER.CONFIG.BOOSTERS[boosterKey] ) then return end

	local plyBoosters = self:GetBoosters()
	local newBooster = { boosterKey }

	table.insert( plyBoosters, newBooster )

	self:SetBoosters( plyBoosters )
end

local function CreateBoosterTimer( ply, boosterKey )
	if( not IsValid( ply ) ) then return end

	if( timer.Exists( ply:SteamID64() ..  "_BRS_TIMER_BOOSTER_" .. boosterKey ) ) then
		timer.Remove( ply:SteamID64() ..  "_BRS_TIMER_BOOSTER_" .. boosterKey )
	end

	local plyBoosters = ply:GetBoosters()
	if( not plyBoosters[boosterKey] or not plyBoosters[boosterKey][3] or os.time() >= plyBoosters[boosterKey][3] ) then return end

	local boosterTable = BRICKS_SERVER.CONFIG.BOOSTERS[plyBoosters[boosterKey][1] or 1] or {}
	if( boosterTable and boosterTable.Multiplier and BRICKS_SERVER.DEVCONFIG.BoosterTypes[boosterTable.Type or 0] and BRICKS_SERVER.DEVCONFIG.BoosterTypes[boosterTable.Type or 0][2] ) then
		ply:SetNW2Int( BRICKS_SERVER.DEVCONFIG.BoosterTypes[boosterTable.Type or 0][2], boosterTable.Multiplier )
	end

	timer.Create( ply:SteamID64() ..  "_BRS_TIMER_BOOSTER_" .. boosterKey, (plyBoosters[boosterKey][3] - os.time()), 1, function()
		if( not IsValid( ply ) ) then return end

		local plyNewBoosters = ply:GetBoosters()

		DarkRP.notify( ply, 1, 5, "Your " .. ((BRICKS_SERVER.CONFIG.BOOSTERS[plyNewBoosters[boosterKey][1] or 1] or {}).Title or "ERROR") .. " booster has ran out!" )

		ply:SetNW2Int( BRICKS_SERVER.DEVCONFIG.BoosterTypes[boosterTable.Type or 0][2], 1 )

		plyNewBoosters[boosterKey] = nil
		ply:SetBoosters( plyNewBoosters )
	end )
end

local function RemoveBoosterTimer( ply, boosterKey )
	if( not IsValid( ply ) ) then return end

	if( timer.Exists( ply:SteamID64() ..  "_BRS_TIMER_BOOSTER_" .. boosterKey ) ) then
		timer.Remove( ply:SteamID64() ..  "_BRS_TIMER_BOOSTER_" .. boosterKey )
	end
end

util.AddNetworkString( "BRS.Net.UseBooster" )
net.Receive( "BRS.Net.UseBooster", function( len, ply )
	local boosterKey = net.ReadUInt( 10 )
	
	if( not boosterKey ) then return end
	if( not IsValid( ply ) ) then return end
	
	local plyBoosters = ply:GetBoosters()
	
	if( plyBoosters[boosterKey] and not plyBoosters[boosterKey][3] ) then
		local boosterTable = BRICKS_SERVER.CONFIG.BOOSTERS[plyBoosters[boosterKey][1]]

		if( not boosterTable ) then return end

		plyBoosters[boosterKey][2] = os.time()
		plyBoosters[boosterKey][3] = os.time()+boosterTable.Time

		DarkRP.notify( ply, 1, 5, boosterTable.Title .. " booster is now active and will run out in " .. BRICKS_SERVER.Func.FormatTime( boosterTable.Time ) .. "!" )

		ply:SetBoosters( plyBoosters )

		CreateBoosterTimer( ply, boosterKey )
	end
end )

util.AddNetworkString( "BRS.Net.CancelBooster" )
net.Receive( "BRS.Net.CancelBooster", function( len, ply )
	local boosterKey = net.ReadUInt( 10 )
	
	if( not boosterKey ) then return end
	if( not IsValid( ply ) ) then return end
	
	local plyBoosters = ply:GetBoosters()
	
	if( plyBoosters[boosterKey] and plyBoosters[boosterKey][3] ) then
		local boosterTable = BRICKS_SERVER.CONFIG.BOOSTERS[plyBoosters[boosterKey][1]]

		if( not boosterTable ) then return end
		RemoveBoosterTimer( ply, boosterKey )

		DarkRP.notify( ply, 1, 5, "Your " .. boosterTable.Title .. " booster has been cancelled and removed!" )

		if( boosterTable.Multiplier and BRICKS_SERVER.DEVCONFIG.BoosterTypes[boosterTable.Type or 0] and BRICKS_SERVER.DEVCONFIG.BoosterTypes[boosterTable.Type or 0][2] ) then
			ply:SetNW2Int( BRICKS_SERVER.DEVCONFIG.BoosterTypes[boosterTable.Type or 0][2], 1 )
		end

		plyBoosters[boosterKey] = nil

		ply:SetBoosters( plyBoosters )
	end
end )

hook.Add( "PlayerInitialSpawn", "BRS.PlayerInitialSpawn_CheckBoosters", function( ply )
	local plyBoosters = ply:GetBoosters()

	local removed = false
	for k, v in pairs( plyBoosters or {} ) do
		if( v[3] ) then
			if( os.time() >= v[3] ) then
				plyBoosters[k] = nil
				removed = true
			else
				CreateBoosterTimer( ply, k )
			end
		end
	end

	if( removed ) then
		ply:SetBoosters( plyBoosters )
	end
end )

hook.Add( "PlayerDisconnected", "BRS.PlayerDisconnected_CheckBoosters", function( ply )
	local plyBoosters = ply:GetBoosters()

	for k, v in pairs( plyBoosters or {} ) do
		if( v[3] ) then
			RemoveBoosterTimer( ply, k )
		end
	end
end )

-- Admin give booster
util.AddNetworkString("BRS.Net.Admin_GiveBooster")
net.Receive( "BRS.Net.Admin_GiveBooster", function( len, ply )
	if( not BRICKS_SERVER.Func.HasAdminAccess( ply ) ) then return end

	local victimSteamID64 = net.ReadString()
	local boosterKey = net.ReadUInt( 8 )

	if( not victimSteamID64 or not boosterKey ) then return end
	if( not BRICKS_SERVER.CONFIG.BOOSTERS[boosterKey] ) then return end

	local victimEntity = player.GetBySteamID64( victimSteamID64 )

	if( not IsValid( victimEntity ) or not victimEntity:IsPlayer() ) then return end
	victimEntity:AddBooster( boosterKey )
	
	DarkRP.notify( ply, 1, 5, "Gave " .. victimEntity:Nick() .. " a " .. (BRICKS_SERVER.CONFIG.BOOSTERS[boosterKey].Title or "ERROR") .. " Booster" )
	DarkRP.notify( victimEntity, 1, 5, "An admin has gave you a " .. (BRICKS_SERVER.CONFIG.BOOSTERS[boosterKey].Title or "ERROR") .. " Booster" )
end )

util.AddNetworkString( "BRS.Net.AdminUseBooster" )
net.Receive( "BRS.Net.AdminUseBooster", function( len, ply )
	if( not BRICKS_SERVER.Func.HasAdminAccess( ply ) ) then return end

	local victimSteamID64 = net.ReadString()
	local boosterKey = net.ReadUInt( 10 )
	
	if( not victimSteamID64 or not boosterKey ) then return end
	local victimEntity = player.GetBySteamID64( victimSteamID64 )

	if( not IsValid( victimEntity ) or not victimEntity:IsPlayer() ) then return end
	
	local plyBoosters = victimEntity:GetBoosters()
	
	if( plyBoosters[boosterKey] and not plyBoosters[boosterKey][3] ) then
		local boosterTable = BRICKS_SERVER.CONFIG.BOOSTERS[plyBoosters[boosterKey][1]]

		if( not boosterTable ) then return end

		plyBoosters[boosterKey][2] = os.time()
		plyBoosters[boosterKey][3] = os.time()+boosterTable.Time

		DarkRP.notify( ply, 1, 5, "Activated " .. victimEntity:Nick() .. "'s " .. boosterTable.Title .. " booster, it will run out in " .. BRICKS_SERVER.Func.FormatTime( boosterTable.Time ) .. "!" )
		DarkRP.notify( victimEntity, 1, 5, boosterTable.Title .. " booster has been activated by an admin and will run out in " .. BRICKS_SERVER.Func.FormatTime( boosterTable.Time ) .. "!" )

		victimEntity:SetBoosters( plyBoosters )

		ply:BRS():AdminSendInventory( victimEntity )

		CreateBoosterTimer( victimEntity, boosterKey )
	end
end )

util.AddNetworkString( "BRS.Net.AdminCancelBooster" )
net.Receive( "BRS.Net.AdminCancelBooster", function( len, ply )
	if( not BRICKS_SERVER.Func.HasAdminAccess( ply ) ) then return end

	local victimSteamID64 = net.ReadString()
	local boosterKey = net.ReadUInt( 10 )
	
	if( not victimSteamID64 or not boosterKey ) then return end
	local victimEntity = player.GetBySteamID64( victimSteamID64 )

	if( not IsValid( victimEntity ) or not victimEntity:IsPlayer() ) then return end
	
	local plyBoosters = victimEntity:GetBoosters()
	
	if( plyBoosters[boosterKey] and plyBoosters[boosterKey][3] ) then
		local boosterTable = BRICKS_SERVER.CONFIG.BOOSTERS[plyBoosters[boosterKey][1]]

		if( not boosterTable ) then return end
		RemoveBoosterTimer( victimEntity, boosterKey )

		DarkRP.notify( ply, 1, 5, victimEntity:Nick() .. "'s " .. boosterTable.Title .. " booster has been cancelled and removed!" )
		DarkRP.notify( victimEntity, 1, 5, "Your " .. boosterTable.Title .. " booster has been cancelled and removed by an admin!" )

		if( boosterTable.Multiplier and BRICKS_SERVER.DEVCONFIG.BoosterTypes[boosterTable.Type or 0] and BRICKS_SERVER.DEVCONFIG.BoosterTypes[boosterTable.Type or 0][2] ) then
			victimEntity:SetNW2Int( BRICKS_SERVER.DEVCONFIG.BoosterTypes[boosterTable.Type or 0][2], 1 )
		end

		plyBoosters[boosterKey] = nil

		victimEntity:SetBoosters( plyBoosters )

		ply:BRS():AdminSendInventory( victimEntity )
	end
end )