local function SaveInventories( inventories, bank )
	if( not inventories ) then return end

	local playerInventories = {}
	for k, v in pairs( inventories ) do
		playerInventories[v.sid64] = playerInventories[v.sid64] or {}

		local itemTable = { v.drop_ent }
		local dataTable = util.JSONToTable( v.data or "" ) or {}
		
		if( v.drop_ent == "spawned_weapon" or v.drop_ent == "spawned_shipment" ) then
			itemTable[1] = "spawned_weapon"
			itemTable[2] = BRICKS_SERVER.Func.GetWeaponModel( v.ent ) or ""
			itemTable[3] = v.ent
		else
			itemTable[2] = dataTable["model"] or ""
		end

		local finalTable = { tonumber( v.amount ), itemTable }
		if( v.drop_ent == "spawned_shipment" ) then
			local amount = tonumber( v.amount ) or 1
			if( dataTable and dataTable["amount"] ) then
				amount = tonumber( dataTable["amount"] ) or 1
			end
			
			finalTable = { tonumber( amount ), itemTable }
		end

		table.insert( playerInventories[v.sid64], finalTable )
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
		print( "Bank inventories successfully imported from Xenin Inventory!" )
	else
		print( "Inventories successfully imported from Xenin Inventory!" )
	end
end

concommand.Add( "bricks_server_import_xenin", function( ply, cmd, args )
	if( IsValid( ply ) and not BRICKS_SERVER.Func.HasAdminAccess( ply ) ) then return end

	if( not XeninInventory.Config.Database.EnableMySQL ) then
		local inventories = sql.Query( "SELECT * FROM 'inventory_player'" )
		if( inventories ) then
			SaveInventories( inventories )
		else
			print( "Failed to fetch xenin inventories from SQL Lite")
		end

		local bankInventories = sql.Query( "SELECT * FROM 'inventory_bank'" )
		if( bankInventories ) then
			SaveInventories( bankInventories, true )
		else
			print( "Failed to fetch xenin bank inventories from SQL Lite")
		end
	else
		local conn = XeninInventory.Database:GetConnection()

		conn.query( "SELECT * FROM inventory_player", function( inventories )
			if( inventories ) then
				SaveInventories( inventories )
			else
				print( "Failed to fetch xenin inventories from MySQL")
			end
		end )

		conn.query( "SELECT * FROM inventory_bank", function( bankInventories )
			if( bankInventories ) then
				SaveInventories( bankInventories, true )
			else
				print( "Failed to fetch xenin bank inventories from MySQL")
			end
		end )
	end
end )