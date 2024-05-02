local function SaveInventories( inventories, bank )
	if( not inventories ) then return end

	local playerInventories = {}
	for k, v in pairs( inventories ) do
		for key, val in pairs( v ) do
			playerInventories[k] = playerInventories[k] or {}

			local itemTable = { val.Class }
			local dataTable = val.Data or {}
			
			if( val.Class == "spawned_weapon" or val.Class == "spawned_shipment" ) then
				itemTable[1] = "spawned_weapon"
				itemTable[2] = dataTable.Model or (BRICKS_SERVER.Func.GetWeaponModel( dataTable.Class ) or "")
				itemTable[3] = dataTable.Class or ""
			else
				itemTable[2] = dataTable.Model or ""
			end

			table.insert( playerInventories[k], { (tonumber( dataTable.Amount ) or 1), itemTable } )
		end
	end

	for k, v in pairs( playerInventories ) do
		local ply = player.GetBySteamID64( k )

		if( BRICKS_SERVER.ESSENTIALS.LUACFG.UseMySQL == true ) then
			if( not bank ) then
				BRS_UpdateDBValue( "bricks_server_inventory", k, "inventory", util.TableToJSON( v ) )

				if( IsValid( ply ) ) then
					ply:BRS():SetInventory( v )
				end
			else
				BRS_UpdateDBValue( "bricks_server_inventory", k, "bank", util.TableToJSON( v ) )

				if( IsValid( ply ) ) then
					ply:SetBank( v )
				end
			end
		else
			if( not file.Exists( "bricks_server/mainstats", "DATA" ) ) then
				file.CreateDir( "bricks_server/mainstats" )
			end
	
			local brs_stats = {}
			if( file.Exists( "bricks_server/mainstats/" .. k .. ".txt", "DATA" ) ) then
				brs_stats = util.JSONToTable( file.Read( "bricks_server/mainstats/" .. k .. ".txt", "DATA" ) )
			end

			if( not bank ) then
				brs_stats["inventory"] = v
			else
				brs_stats["bank"] = v
			end
	
			file.Write( "bricks_server/mainstats/" .. k .. ".txt", util.TableToJSON( brs_stats ) )

			if( IsValid( ply ) ) then
				if( not bank ) then
					ply:BRS():SetInventory( v )
				else
					ply:SetBank( v )
				end
			end
		end
	end

	if( bank ) then
		print( "Bank inventories successfully imported from Itemstore!" )
	else
		print( "Inventories successfully imported from Itemstore!" )
	end
end

concommand.Add( "bricks_server_import_itemstore", function( ply, cmd, args )
	if( IsValid( ply ) and not BRICKS_SERVER.Func.HasAdminAccess( ply ) ) then return end

	if( not itemstore or not itemstore.config or not itemstore.config.DataProvider or not (itemstore.config.DataProvider == "mysql" or itemstore.config.DataProvider == "mysql.experimental") ) then
		local files, directories = file.Find("itemstore/*", "DATA")

		local inventories, bankInventories = {}, {}
		for k, v in pairs( files ) do
			local steamID64 = string.Replace( string.Replace( v, "_bank", "" ), ".txt", "" )
			local fileTable = util.JSONToTable( file.Read( "itemstore/" .. v, "DATA" ) )
			if( string.find( v, "_bank" ) ) then
				bankInventories[steamID64] = fileTable
			else
				inventories[steamID64] = fileTable
			end
		end

		if( inventories ) then
			SaveInventories( inventories )
		else
			print( "Failed to fetch Itemstore inventories from data files")
		end

		if( bankInventories ) then
			SaveInventories( bankInventories, true )
		else
			print( "Failed to fetch Itemstore bank inventories from data files")
		end
	else
		itemstore.data.Provider:Query( "SELECT * FROM Inventories", nil, function( data )
			if( data ) then
				local inventories = {}
				for k, v in pairs( data ) do
					if( not v.Class ) then continue end

					inventories[v.SteamID] = inventories[v.SteamID] or {}

					local key = table.insert( inventories[v.SteamID], v )
					inventories[v.SteamID][key].Data = util.JSONToTable( inventories[v.SteamID][key].Data or "" ) or {}
				end

				SaveInventories( inventories )
			else
				print( "Failed to read itemstore inventory data, try running the command a few more times!")
			end
		end )

		itemstore.data.Provider:Query( "SELECT * FROM Banks", nil, function( data )
			if( data ) then
				local bankInventories = {}
				for k, v in pairs( data ) do
					if( not v.Class ) then continue end

					bankInventories[v.SteamID] = bankInventories[v.SteamID] or {}

					local key = table.insert( bankInventories[v.SteamID], v )
					bankInventories[v.SteamID][key].Data = util.JSONToTable( bankInventories[v.SteamID][key].Data or "" ) or {}
				end

				SaveInventories( bankInventories, true )
			else
				print( "Failed to read itemstore bank data, try running the command a few more times!")
			end
		end )
	end
end )