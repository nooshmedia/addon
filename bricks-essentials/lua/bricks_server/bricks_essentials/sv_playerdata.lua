local playerMeta = FindMetaTable( "Player" )

local sqlStatSaveFunctions = {
	["experience"] = { BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "levelling" ), function( ply )
		BRS_UpdateDBValue( "bricks_server_levelling", ply:SteamID64(), "experience", (ply:GetExperience() or 0) )
	end },
	["level"] = { BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "levelling" ), function( ply )
		BRS_UpdateDBValue( "bricks_server_levelling", ply:SteamID64(), "level", (ply:GetLevel() or 0) )
	end },
	["inventory"] = { BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "inventory" ), function( ply )
		BRS_UpdateDBValue( "bricks_server_inventory", ply:SteamID64(), "inventory", util.TableToJSON( ply:BRS():GetInventory() or {} ) )
	end },
	["bank"] = { BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "inventory" ), function( ply )
		BRS_UpdateDBValue( "bricks_server_inventory", ply:SteamID64(), "bank", util.TableToJSON( ply:GetBank() or {} ) )
	end },
	["printers"] = { BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "printers" ), function( ply )
		local newPrintersTable = {}
		for k, v in pairs( (ply:GetPrinters() or {}) ) do
			newPrintersTable[k] = {}
			for key, val in pairs( v ) do
				newPrintersTable[k][tostring(key)] = val
			end
		end

		BRS_UpdateDBValue( "bricks_server_printers", ply:SteamID64(), "printers", util.TableToJSON( newPrintersTable ) )
	end },
	["boosters"] = { BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "boosters" ), function( ply )
		BRS_UpdateDBValue( "bricks_server_boosters", ply:SteamID64(), "boosters", util.TableToJSON( ply:GetBoosters() or {} ) )
	end },
	["logs"] = { BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "logging" ), function( ply )
		BRS_UpdateDBValue( "bricks_server_logs", ply:SteamID64(), "logs", util.TableToJSON( ply:GetLogs() or {} ) )
	end },
	["deathscreens"] = { BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "deathscreens" ), function( ply )
		BRS_UpdateDBValue( "bricks_server_deathscreens", ply:SteamID64(), "deathscreens", util.TableToJSON( ply:GetDeathscreens() or {} ) )
	end }
}

local function SaveStatsToFile( self, stat )
	if( IsValid( self ) ) then
		if( BRICKS_SERVER.ESSENTIALS.LUACFG.UseMySQL != true ) then
			local playerStats = {}
			if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "levelling" ) ) then
				playerStats["experience"] = (self:GetExperience() or 0)
				playerStats["level"] = (self:GetLevel() or 0)
			end

			if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "inventory" ) ) then
				playerStats["inventory"] = (self:BRS():GetInventory() or {})
				playerStats["bank"] = (self:GetBank() or {})
			end

			if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "printers" ) ) then
				playerStats["printers"] = (self:GetPrinters() or {})
			end

			if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "boosters" ) ) then
				playerStats["boosters"] = (self:GetBoosters() or {})
			end

			if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "logging" ) ) then
				playerStats["logs"] = (self:GetLogs() or {})
			end

			if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "deathscreens" ) ) then
				playerStats["deathscreens"] = (self:GetDeathscreens() or {})
			end

			if( not file.Exists( "bricks_server/mainstats", "DATA" ) ) then
				file.CreateDir( "bricks_server/mainstats" )
			end
			file.Write( "bricks_server/mainstats/" .. self:SteamID64() .. ".txt", util.TableToJSON( playerStats ) )
		elseif( stat ) then
			if( sqlStatSaveFunctions[stat] and sqlStatSaveFunctions[stat][1] == true ) then
				sqlStatSaveFunctions[stat][2]( self )
			end
		else
			for k, v in pairs( sqlStatSaveFunctions ) do
				if( v[1] == true ) then
					v[2]( self )
				end
			end
		end
	end
end

function playerMeta:BRS_Essentials_SaveStat( stat )
	if( timer.Exists( self:SteamID64() .. "_bricks_server_timer_savestats_" .. (stat or "all") ) ) then
		timer.Remove( self:SteamID64() .. "_bricks_server_timer_savestats_" .. (stat or "all") )
	end

	if( not IsValid( self ) ) then return end
	
	timer.Create( self:SteamID64() .. "_bricks_server_timer_savestats_" .. (stat or "all"), 5, 1, function()
		SaveStatsToFile( self, stat )
	end )
end

hook.Add( "PlayerDisconnected", "BRS.PlayerDisconnected_EssentialsSaveData", function( ply ) 
	if( IsValid( ply ) ) then
		SaveStatsToFile( ply )
	end
end )

-- Loads player's stats
local sqlStatLoadFunctions = {
	["levelling"] = { BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "levelling" ), function( ply )
		BRS_FetchDBData( "bricks_server_levelling", ply:SteamID64(), function( data )
			if( not IsValid( ply ) ) then return end
			ply:SetExperience( ((data or {}).experience or 0), true)
			ply:SetLevel( ((data or {}).level or 0), true)

			if( not (data or {}).steamid ) then
				BRS_UpdateDBValue( "bricks_server_levelling", ply:SteamID64(), "steamid", (ply:SteamID() or "ERROR") )
			end
		end )
	end },
	["inventory"] = { BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "inventory" ), function( ply )
		BRS_FetchDBValue( "bricks_server_inventory", ply:SteamID64(), "inventory", function( data )
			if( not IsValid( ply ) ) then return end
			ply:BRS():SetInventory( util.JSONToTable( data or "" ) or {}, true )
		end )

		BRS_FetchDBValue( "bricks_server_inventory", ply:SteamID64(), "bank", function( data )
			if( not IsValid( ply ) ) then return end
			ply:SetBank( util.JSONToTable( data or "" ) or {}, true )
		end )
	end },
	["printers"] = { BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "printers" ), function( ply )
		BRS_FetchDBValue( "bricks_server_printers", ply:SteamID64(), "printers", function( data )
			if( not IsValid( ply ) ) then return end

			local newPrintersTable = {}
			for k, v in pairs( util.JSONToTable( data or "" ) or {} ) do
				newPrintersTable[k] = {}
				for key, val in pairs( v ) do
					newPrintersTable[k][tonumber(key)] = val
				end
			end

			ply:SetPrinters( newPrintersTable, true )
		end )
	end },
	["boosters"] = { BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "boosters" ), function( ply )
		BRS_FetchDBValue( "bricks_server_boosters", ply:SteamID64(), "boosters", function( data )
			if( not IsValid( ply ) ) then return end
			ply:SetBoosters( util.JSONToTable( data or "" ) or {}, true )
		end )
	end },
	["logs"] = { BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "logging" ), function( ply )
		BRS_FetchDBValue( "bricks_server_logs", ply:SteamID64(), "logs", function( data )
			if( not IsValid( ply ) ) then return end
			ply:SetLogs( util.JSONToTable( data or "" ) or {}, true )
		end )
	end },
	["deathscreens"] = { BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "deathscreens" ), function( ply )
		BRS_FetchDBValue( "bricks_server_deathscreens", ply:SteamID64(), "deathscreens", function( data )
			if( not IsValid( ply ) ) then return end
			ply:SetDeathscreens( util.JSONToTable( data or "" ) or {}, true )
		end )
	end }
}

hook.Add( "PlayerInitialSpawn", "BRS.PlayerInitialSpawn_EssentialsLoadData", function( ply ) 
	if( BRICKS_SERVER.ESSENTIALS.LUACFG.UseMySQL != true ) then
		if( not file.Exists( "bricks_server/mainstats", "DATA" ) ) then
			file.CreateDir( "bricks_server/mainstats" )
		end

		local brs_stats = {}
		if( file.Exists( "bricks_server/mainstats/" .. ply:SteamID64() .. ".txt", "DATA" ) ) then
			brs_stats = util.JSONToTable( file.Read( "bricks_server/mainstats/" .. ply:SteamID64() .. ".txt", "DATA" ) )
		end
		
		if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "levelling" ) ) then
			ply:SetExperience( (brs_stats["experience"] or 0), true)
			ply:SetLevel( (brs_stats["level"] or 0), true)
		end

		if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "inventory" ) ) then
			ply:BRS():SetInventory( brs_stats["inventory"] or {}, true )
			ply:SetBank( brs_stats["bank"] or {}, true )
		end

		if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "printers" ) ) then
			ply:SetPrinters( brs_stats["printers"] or {}, true )
		end

		if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "boosters" ) ) then
			ply:SetBoosters( brs_stats["boosters"] or {}, true )
		end

		if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "logging" ) ) then
			ply:SetLogs( brs_stats["logs"] or {}, true )
		end

		if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "deathscreens" ) ) then
			ply:SetDeathscreens( brs_stats["deathscreens"] or {}, true )
		end
	else	
		for k, v in pairs( sqlStatLoadFunctions ) do
			if( v[1] == true ) then
				v[2]( ply )
			end
		end
	end
end )