local Host = "gamesuk28.bisecthosting.com"
local Username = "u89278_B9cxlbTeG6"
local Password = "b7Bbe=YMxDGYi.!Z55PbZH0S"
local DatabaseName = "s89278_basewars"
local DatabasePort = 3306

--[[

	DONT TOUCH ANYTHING BELOW THIS LINE!
	
]]--

if( BRICKS_SERVER.ESSENTIALS.LUACFG.UseMySQL ) then
	require( "mysqloo" )

	local function ConnectToDatabase()
		bricks_server_db = mysqloo.connect( Host, Username, Password, DatabaseName, DatabasePort )
		bricks_server_db.onConnected = function()	print( "[BricksServer SQL] BricksServer database has connected!" )	end
		bricks_server_db.onConnectionFailed = function( db, err )	print( "[BricksServer SQL] Connection to BricksServer Database failed! Error: " .. err )	end
		bricks_server_db:connect()
		
		if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "levelling" ) ) then
			local mainTableQuery = bricks_server_db:query("CREATE TABLE IF NOT EXISTS bricks_server_levelling ( steamid64 varchar(17) NOT NULL UNIQUE, steamid varchar(20) UNIQUE, level int, experience int );")
			function mainTableQuery:onSuccess(data) print( "[BricksServer SQL] bricks_server_levelling table validated!" ) end
			function mainTableQuery:onError(err) print("[BricksServer SQL] An error occured while executing the query: " .. err) end
			mainTableQuery:start()
		end

		if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "inventory" ) ) then
			local inventoryTableQuery = bricks_server_db:query("CREATE TABLE IF NOT EXISTS bricks_server_inventory ( steamid64 varchar(17) NOT NULL UNIQUE, inventory TEXT, bank TEXT );")
			function inventoryTableQuery:onSuccess(data) print( "[BricksServer SQL] bricks_server_inventory table validated!" ) end
			function inventoryTableQuery:onError(err) print("[BricksServer SQL] An error occured while executing the query: " .. err) end
			inventoryTableQuery:start()
		end

		if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "printers" ) ) then
			local printersTableQuery = bricks_server_db:query("CREATE TABLE IF NOT EXISTS bricks_server_printers ( steamid64 varchar(17) NOT NULL UNIQUE, printers TEXT );")
			function printersTableQuery:onSuccess(data) print( "[BricksServer SQL] bricks_server_printers table validated!" ) end
			function printersTableQuery:onError(err) print("[BricksServer SQL] An error occured while executing the query: " .. err) end
			printersTableQuery:start()
		end

		if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "boosters" ) ) then
			local boostersTableQuery = bricks_server_db:query("CREATE TABLE IF NOT EXISTS bricks_server_boosters ( steamid64 varchar(17) NOT NULL UNIQUE, boosters TEXT );")
			function boostersTableQuery:onSuccess(data) print( "[BricksServer SQL] bricks_server_boosters table validated!" ) end
			function boostersTableQuery:onError(err) print("[BricksServer SQL] An error occured while executing the query: " .. err) end
			boostersTableQuery:start()
		end

		if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "logging" ) ) then
			local logsTableQuery = bricks_server_db:query("CREATE TABLE IF NOT EXISTS bricks_server_logs ( steamid64 varchar(17) NOT NULL UNIQUE, logs TEXT );")
			function logsTableQuery:onSuccess(data) print( "[BricksServer SQL] bricks_server_logs table validated!" ) end
			function logsTableQuery:onError(err) print("[BricksServer SQL] An error occured while executing the query: " .. err) end
			logsTableQuery:start()
		end

		if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "marketplace" ) ) then
			local marketplaceTableQuery = bricks_server_db:query("CREATE TABLE IF NOT EXISTS bricks_server_marketplace ( marketkey int NOT NULL UNIQUE, amount int, currentbid int, time int, starttime int, itemdata TEXT, owner varchar(17), bidders TEXT, ownercollected boolean, winnercollected boolean );")
			function marketplaceTableQuery:onSuccess(data) print( "[BricksServer SQL] bricks_server_marketplace table validated!" ) end
			function marketplaceTableQuery:onError(err) print("[BricksServer SQL] An error occured while executing the query: " .. err) end
			marketplaceTableQuery:start()
		end

		if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "deathscreens" ) ) then
			local deathscreensTableQuery = bricks_server_db:query("CREATE TABLE IF NOT EXISTS bricks_server_deathscreens (steamid64 varchar(17) NOT NULL UNIQUE, deathscreens TEXT );")
			function deathscreensTableQuery:onSuccess(data) print( "[BricksServer SQL] bricks_server_deathscreens table validated!" ) end
			function deathscreensTableQuery:onError(err) print("[BricksServer SQL] An error occured while executing the query: " .. err) end
			deathscreensTableQuery:start()
		end
	end
	ConnectToDatabase()

	--[[ PLAYER DATA ]]--
	local tableColumns = {}

	if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "levelling" ) ) then
		tableColumns["bricks_server_levelling"] = {
			["steamid"] = "string",	
			["level"] = "integer",	
			["experience"] = "integer"
		}
	end

	if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "inventory" ) ) then
		tableColumns["bricks_server_inventory"] = {
			["inventory"] = "string",
			["bank"] = "string"
		}
	end

	if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "printers" ) ) then
		tableColumns["bricks_server_printers"] = {
			["printers"] = "string"
		}
	end

	if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "boosters" ) ) then
		tableColumns["bricks_server_boosters"] = {
			["boosters"] = "string"
		}
	end

	if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "logging" ) ) then
		tableColumns["bricks_server_logs"] = {
			["logs"] = "string"
		}
	end

	if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "deathscreens" ) ) then
		tableColumns["bricks_server_deathscreens"] = {
			["deathscreens"] = "string"
		}
	end

	function BRS_UpdateDBValue( table, steamid64, key, value )
		if( not tableColumns[table] or not tableColumns[table][key] ) then return end
		
		if( tableColumns[table][key] == "string" ) then
			value = bricks_server_db:escape( value )
		end
		
		local query = bricks_server_db:query("SELECT * FROM " .. table .. " WHERE steamid64 = '" .. steamid64 .. "'")
		function query:onSuccess(data)
			if( not data[1] ) then
				local queryinner = bricks_server_db:query("INSERT INTO " .. table .. " (`steamid64`, `" .. key .. "`) VALUES( '" .. steamid64 .. "', '" .. value .. "')")
				function queryinner:onError(err)
					local queryinner2 = bricks_server_db:query("UPDATE " .. table .. " SET " .. key .. " = '" .. value .. "' WHERE steamid64 = '" .. steamid64 .. "';")
					queryinner2:start()
				end
				queryinner:start()
			else
				local queryinner2 = bricks_server_db:query("UPDATE " .. table .. " SET " .. key .. " = '" .. value .. "' WHERE steamid64 = '" .. steamid64 .. "';")
				queryinner2:start()
			end
		end
		query:start()
	end

	function BRS_FetchDBValue( table, steamid64, key, func )
		if( not tableColumns[table] or not tableColumns[table][key] ) then return end

		local query = bricks_server_db:query("SELECT " .. key .. " FROM " .. table .. " WHERE steamid64 = '" .. steamid64 .. "'")
		function query:onSuccess(data)
			if( data[1] ) then
				if( data[1][key] ) then
					if( tableColumns[table][key] == "integer" ) then
						func( tonumber(data[1][key]) )
					else
						func( data[1][key] )
					end
				else
					func()
				end
			else
				func()
			end
		end
		query:start()
	end

	function BRS_FetchDBData( table, steamID64, func )
		if( not tableColumns[table] ) then return end

		local query = bricks_server_db:query("SELECT * FROM " .. table .. " WHERE steamid64 = '" .. steamID64 .. "'")
		function query:onSuccess(data)
			if( data[1] ) then
				func( data[1] )
			end
		end
		query:start()
	end

	function BRS_FetchDBSteamIDs( func )
		if( not BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "levelling" ) ) then return end
		
		local query = bricks_server_db:query("SELECT steamid, steamid64 FROM bricks_server_levelling")
		function query:onSuccess(data)
			func( data )
		end
		query:start()
	end

	function BRS_DeleteDBRecord( table, steamid64 )
		if( not tableColumns[table] ) then return end
		
		local query = bricks_server_db:query("DELETE FROM " .. table .. " WHERE steamid64='" .. steamid64 .. "';")
		query:start()
	end

	--[[ MARKETPLACE DATA ]]--
	local tableColumns = {
		["bricks_server_marketplace"] = {
			["marketkey"] = "integer",
			["amount"] = "integer",
			["currentbid"] = "integer",
			["time"] = "integer",
			["starttime"] = "integer",
			["itemdata"] = "table",
			["owner"] = "string",
			["bidders"] = "table",
			["ownercollected"] = "boolean",
			["winnercollected"] = "boolean"
		}
	}

	function BRS_InsertMarketDBValue( table, marketKey, marketItem )
		if( table != "bricks_server_marketplace" ) then return end

		local itemData = bricks_server_db:escape( util.TableToJSON( marketItem[5] or {} ) or "" )
		local bidders = bricks_server_db:escape( util.TableToJSON( marketItem[7] or {} ) or "" )
		local ownerCollected = ((marketItem[8] or false) == true and 1) or 0
		local winnerCollected = ((marketItem[9] or false) == true and 1) or 0
		local query = bricks_server_db:query("INSERT INTO " .. table .. " (`marketkey`, `amount`, `currentbid`, `time`, `starttime`, `itemdata`, `owner`, `bidders`, `ownercollected`, `winnercollected`) VALUES( '" .. marketKey .. "', '" .. (marketItem[1] or 0) .. "', '" .. (marketItem[2] or 0) .. "', '" .. (marketItem[3] or 0) .. "', '" .. (marketItem[4] or 0) .. "', '" .. itemData .. "', '" .. bricks_server_db:escape( marketItem[6] or "" ) .. "', '" .. bidders .. "', '" .. ownerCollected .. "', '" .. winnerCollected .. "')")
		function query:onError(err) print("[BricksServer SQL] Marketplace Insert: An error occured while executing the query: " .. err) end
		query:start()
	end

	function BRS_DeleteMarketDBValue( table, marketKey )
		if( table != "bricks_server_marketplace" ) then return end

		local query = bricks_server_db:query("DELETE FROM " .. table .. " WHERE marketkey = '" .. marketKey .. "'")
		function query:onError(err) print("[BricksServer SQL] Marketplace Delete: An error occured while executing the query: " .. err) end
		query:start()
	end

	function BRS_UpdateMarketDBValue( table, marketKey, key, value )
		if( table != "bricks_server_marketplace" ) then return end
		if( not tableColumns[table][key] ) then return end

		if( tableColumns[table][key] == "string" ) then
			value = bricks_server_db:escape( value )
		elseif( tableColumns[table][key] == "table" ) then
			value = bricks_server_db:escape( util.TableToJSON( value ) )
		elseif( tableColumns[table][key] == "boolean" ) then
			value = ((value or false) == true and 1) or 0
		end

		local query = bricks_server_db:query("SELECT * FROM " .. table .. " WHERE marketkey = '" .. marketKey .. "'")
		function query:onSuccess(data)
			if( not data[1] ) then
				BRS_InsertMarketDBValue( table, marketKey, (BRS_MARKETPLACE[marketKey] or {}) )
			else
				local queryinner2 = bricks_server_db:query("UPDATE " .. table .. " SET " .. key .. " = '" .. value .. "' WHERE marketkey = '" .. marketKey .. "';")
				function queryinner2:onError(err) print("[BricksServer SQL] Marketplace Update: An error occured while executing the query: " .. err) end
				queryinner2:start()
			end
		end
		query:start()
	end

	function BRS_FetchMarketDBValue( table, marketKey, func )
		if( table != "bricks_server_marketplace" ) then return end

		local query = bricks_server_db:query("SELECT * FROM " .. table .. " WHERE marketkey = '" .. marketKey .. "'")
		function query:onSuccess(data)
			if( data[1] ) then
				func( data[1] )
			else
				func()
			end
		end
		query:start()
	end

	function BRS_FetchMarketDBValues( table, func )
		if( table != "bricks_server_marketplace" ) then return end

		local query = bricks_server_db:query("SELECT * FROM " .. table .. ";")
		function query:onSuccess(data)
			if( data ) then
				func( data )
			else
				func()
			end
		end
		query:start()
	end
end