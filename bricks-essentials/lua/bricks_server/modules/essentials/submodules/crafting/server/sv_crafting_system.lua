local playerMeta = FindMetaTable("Player")

util.AddNetworkString( "BRS.Net.SendCraftingTimes" )
function playerMeta:SendCraftingTime( key )
	if( not key ) then return end

	if( not self.BRS_CRAFTING_TIMES or not self.BRS_CRAFTING_TIMES[key] ) then 
		net.Start( "BRS.Net.SendCraftingTimes" )
			net.WriteUInt( key, 8 )
		net.Send( self )
	else
		net.Start( "BRS.Net.SendCraftingTimes" )
			net.WriteUInt( key, 8 )
			net.WriteUInt( self.BRS_CRAFTING_TIMES[key], 32 )
		net.Send( self )
	end
end

function playerMeta:TakeResources( resources )
	local plyInventory = self:BRS():GetInventory()

	local resourcesNeeded = table.Copy( resources )
	for k, v in pairs( plyInventory ) do
		if( v[2] and v[2][1] and v[2][1] == "bricks_server_resource" and resourcesNeeded[v[2][3]] ) then
			local invResourceAmount = plyInventory[k][1]
			plyInventory[k][1] = math.max( plyInventory[k][1]-resourcesNeeded[v[2][3]], 0 )

			resourcesNeeded[v[2][3]] = resourcesNeeded[v[2][3]]-invResourceAmount
			
			if( resourcesNeeded[v[2][3]] <= 0 ) then
				resourcesNeeded[v[2][3]] = nil
			end

			if( plyInventory[k][1] <= 0 ) then
				plyInventory[k] = nil
			end
		end
	end

	self:BRS():SetInventory( plyInventory )
end

util.AddNetworkString( "BRS.Net.SendResourceHit" )
function BRICKS_SERVER.Func.SendResourceHit( ply, pos, text )
	net.Start( "BRS.Net.SendResourceHit" )
		net.WriteVector( pos )
		net.WriteString( text )
	net.Send( ply )
end

local function craftItem( ply, itemKey )
	local craftingTable = BRICKS_SERVER.CONFIG.CRAFTING.Craftables[itemKey]
	if( not craftingTable ) then return end
	local plyInventory = ply:BRS():GetInventory()
	if( not BRICKS_SERVER.Func.HasResources( (plyInventory or {}), (craftingTable.Resources or {}) ) ) then
		DarkRP.notify( ply, 1, 5, "Crafting of " .. craftingTable.Name .. " failed, not enough resources!" )
	else
		DarkRP.notify( ply, 1, 5, "Crafting of " .. craftingTable.Name .. " finished!" )

		ply:TakeResources( (craftingTable.Resources or {}) )

		if( BRICKS_SERVER.DEVCONFIG.CraftingTypes[(craftingTable.Type or "")] and BRICKS_SERVER.DEVCONFIG.CraftingTypes[(craftingTable.Type or "")].OnCraft ) then
			BRICKS_SERVER.DEVCONFIG.CraftingTypes[(craftingTable.Type or "")].OnCraft( ply, (craftingTable.ReqInfo or {}), craftingTable )
		end
	end

	ply.BRS_CRAFTING_TIMES[itemKey] = nil
	
	net.Start( "BRS.Net.FinishCrafting" )
		net.WriteUInt( itemKey, 8 )
	net.Send( ply )
end

util.AddNetworkString( "BRS.Net.FinishCrafting" )
util.AddNetworkString( "BRS.Net.CraftItem" )
net.Receive( "BRS.Net.CraftItem", function( len, ply )
	local itemKey = net.ReadUInt( 8 )

	if( not itemKey or not BRICKS_SERVER.CONFIG.CRAFTING.Craftables[itemKey] or (ply.BRS_CRAFTING_TIMES and ply.BRS_CRAFTING_TIMES[itemKey]) ) then return end

	local craftingTable = BRICKS_SERVER.CONFIG.CRAFTING.Craftables[itemKey]

	if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "levelling" ) and craftingTable.Level ) then
		if( ply:GetLevel() < craftingTable.Level ) then
			DarkRP.notify( ply, 1, 5, "You are not the right level to craft this item!" )
			return
		end
	end

	if( craftingTable.Group ) then
		if( not BRICKS_SERVER.Func.IsInGroup( ply, craftingTable.Group ) ) then
			DarkRP.notify( ply, 1, 5, "You are not the right group to craft this item!" )
			return
		end
	end

	local plyInventory = ply:BRS():GetInventory()

	if( not BRICKS_SERVER.Func.HasResources( (plyInventory or {}), (craftingTable.Resources or {}) ) ) then
		DarkRP.notify( ply, 1, 5, "You don't have enough resources to craft this item!" )
		return
	end

	if( BRICKS_SERVER.DEVCONFIG.CraftingTypes[(craftingTable.Type or "")] and BRICKS_SERVER.DEVCONFIG.CraftingTypes[(craftingTable.Type or "")].CanCraft ) then
		local canCraft, message = BRICKS_SERVER.DEVCONFIG.CraftingTypes[(craftingTable.Type or "")].CanCraft( ply, craftingTable.ReqInfo )
		if( not canCraft ) then
			DarkRP.notify( ply, 1, 5, message )
			return
		end
	end

	if( craftingTable.CraftTime and craftingTable.CraftTime > 0 ) then
		if( not ply.BRS_CRAFTING_TIMES ) then
			ply.BRS_CRAFTING_TIMES = {}
		end

		timer.Create( ply:SteamID64() .. "_bricks_server_timer_craftitem_" .. itemKey, craftingTable.CraftTime, 1, function()
			if( IsValid( ply ) and ply.BRS_CRAFTING_TIMES[itemKey] ) then
				craftItem( ply, itemKey )
			end
		end )

		ply.BRS_CRAFTING_TIMES[itemKey] = CurTime()+craftingTable.CraftTime
		ply:SendCraftingTime( itemKey )
	else
		craftItem( ply, itemKey )
	end
end )

util.AddNetworkString( "BRS.Net.CraftCancel" )
net.Receive( "BRS.Net.CraftCancel", function( len, ply )
	local itemKey = net.ReadUInt( 8 )

	if( not itemKey or not BRICKS_SERVER.CONFIG.CRAFTING.Craftables[itemKey] or not ply.BRS_CRAFTING_TIMES or not ply.BRS_CRAFTING_TIMES[itemKey] ) then return end

	local craftingTable = BRICKS_SERVER.CONFIG.CRAFTING.Craftables[itemKey]

	if( craftingTable ) then
		DarkRP.notify( ply, 1, 5, "Crafting of " .. craftingTable.Name .. " cancelled!" )
	end

	if( timer.Exists( ply:SteamID64() .. "_bricks_server_timer_craftitem_" .. itemKey ) ) then
		timer.Remove( ply:SteamID64() .. "_bricks_server_timer_craftitem_" .. itemKey )
	end

	ply.BRS_CRAFTING_TIMES[itemKey] = nil
			
	net.Start( "BRS.Net.FinishCrafting" )
		net.WriteUInt( itemKey, 8 )
	net.Send( ply )
end )

function BRICKS_SERVER.Func.RespawnRocks()
	BRS_ROCKSPAWN_TIME = CurTime()+(BRICKS_SERVER.CONFIG.CRAFTING["Rock Respawn Time"] or 60)

	for k, v in pairs( BRS_ROCK_SPAWNS ) do
		local tableString = string.Explode( ";", v )
		local position = Vector( tableString[1], tableString[2], tableString[3] )
		local angles = Angle( tableString[4], tableString[5], tableString[6] )

		if( position and angles ) then
			local rockType = ""
			if( BRICKS_SERVER.CONFIG.CRAFTING.RockTypes ) then
				local randomFloat = math.Rand( 0, 100 )
				local previousPercent = 0
				for k, v in pairs( BRICKS_SERVER.CONFIG.CRAFTING.RockTypes ) do
					if( randomFloat >= previousPercent and randomFloat < previousPercent+v ) then
						rockType = k
						break
					else
						previousPercent = previousPercent+v
					end
				end

				if( BRICKS_SERVER.CONFIG.CRAFTING.RockTypes[rockType or ""] ) then
					local nearbyEnts = ents.FindInSphere( position, 5 )
	
					local dontSpawn = false
					for k, v in pairs( nearbyEnts ) do
						if( v:GetClass() == "bricks_server_rock" ) then
							if( v:GetStage() == 3 ) then
								v:SetModel("models/2rek/brickwall/bwall_rock_1_phys_3.mdl")
								v:PhysicsInit( SOLID_VPHYSICS )
								v:GetPhysicsObject():EnableMotion( false )
								v:SetStage( 1 )
								v:SetRHealth( 100 )
								v:SetRockType( rockType )
							end
							dontSpawn = true
							break
						end
					end
	
					if( not dontSpawn ) then
						local rockEntity = ents.Create( "bricks_server_rock" )
						rockEntity:SetPos( position )
						rockEntity:SetAngles( angles )
						rockEntity.rockType = rockType
						rockEntity:Spawn()
					end
				end
			end
		end
	end
end

function BRICKS_SERVER.Func.RespawnTrees()
	BRS_TREESPAWN_TIME = CurTime()+(BRICKS_SERVER.CONFIG.CRAFTING["Tree Respawn Time"] or 60)

	for k, v in pairs( BRS_TREE_SPAWNS ) do
		local tableString = string.Explode( ";", v )
		local position = Vector( tableString[1], tableString[2], tableString[3] )
		local angles = Angle( tableString[4], tableString[5], tableString[6] )

		if( position and angles ) then
			local treeType = ""
			if( BRICKS_SERVER.CONFIG.CRAFTING.TreeTypes ) then
				local randomFloat = math.Rand( 0, 100 )
				local previousPercent = 0
				for k, v in pairs( BRICKS_SERVER.CONFIG.CRAFTING.TreeTypes ) do
					if( randomFloat >= previousPercent and randomFloat < previousPercent+v ) then
						treeType = k
						break
					else
						previousPercent = previousPercent+v
					end
				end

				if( BRICKS_SERVER.CONFIG.CRAFTING.TreeTypes[treeType or ""] ) then
					local nearbyEnts = ents.FindInSphere( position, 5 )
	
					local dontSpawn = false
					for k, v in pairs( nearbyEnts ) do
						if( v:GetClass() == "bricks_server_tree" ) then
							dontSpawn = true
							break
						end
					end
	
					if( not dontSpawn ) then
						local treeEntity = ents.Create( "bricks_server_tree" )
						treeEntity:SetPos( position )
						treeEntity:SetAngles( angles )
						treeEntity.treeType = treeType
						treeEntity:Spawn()
					end
				end
			end
		end
	end
end

function BRICKS_SERVER.Func.RespawnGarbage()
	BRS_GARBAGESPAWN_TIME = CurTime()+(BRICKS_SERVER.CONFIG.CRAFTING["Garbage Respawn Time"] or 60)

	for k, v in pairs( BRS_GARBAGE_SPAWNS ) do
		local tableString = string.Explode( ";", v )
		local position = Vector( tableString[1], tableString[2], tableString[3] )
		local angles = Angle( tableString[4], tableString[5], tableString[6] )

		if( position and angles ) then
			local nearbyEnts = ents.FindInSphere( position, 5 )

			local dontSpawn = false
			for k, v in pairs( nearbyEnts ) do
				if( v:GetClass() == "bricks_server_garbage" ) then
					dontSpawn = true
					break
				end
			end

			if( not dontSpawn ) then
				local garbageEntity = ents.Create( "bricks_server_garbage" )
				garbageEntity:SetPos( position+Vector( 0, 0, 5 ) )
				garbageEntity:SetAngles( angles )
				garbageEntity:Spawn()
			end
		end
	end
end

hook.Add( "Think", "BRS.Think_SpawnRocksTrees", function()	
	if( CurTime() >= (BRS_ROCKSPAWN_TIME or 0) ) then
		BRICKS_SERVER.Func.RespawnRocks()
	end

	if( CurTime() >= (BRS_TREESPAWN_TIME or 0) ) then
		BRICKS_SERVER.Func.RespawnTrees()
	end

	if( CurTime() >= (BRS_GARBAGESPAWN_TIME or 0) ) then
		BRICKS_SERVER.Func.RespawnGarbage()
	end
end )

local function loadRockSpawns()
	if not file.IsDir("bricks_server/rock_spawns", "DATA") then
		file.CreateDir("bricks_server/rock_spawns", "DATA")
	end
	
	BRS_ROCK_SPAWNS = BRS_ROCK_SPAWNS or {}
	if( file.Exists( "bricks_server/rock_spawns/".. string.lower(game.GetMap()) ..".txt", "DATA" ) ) then
		BRS_ROCK_SPAWNS = ( util.JSONToTable( file.Read( "bricks_server/rock_spawns/".. string.lower(game.GetMap()) ..".txt", "DATA" ) ) )
	end
end
loadRockSpawns()

local function loadTreeSpawns()
	if not file.IsDir("bricks_server/tree_spawns", "DATA") then
		file.CreateDir("bricks_server/tree_spawns", "DATA")
	end
	
	BRS_TREE_SPAWNS = BRS_TREE_SPAWNS or {}
	if( file.Exists( "bricks_server/tree_spawns/".. string.lower(game.GetMap()) ..".txt", "DATA" ) ) then
		BRS_TREE_SPAWNS = util.JSONToTable( file.Read( "bricks_server/tree_spawns/".. string.lower(game.GetMap()) ..".txt", "DATA" ) ) or {}
	end
end
loadTreeSpawns()

local function loadGarbageSpawns()
	if not file.IsDir("bricks_server/garbage_spawns", "DATA") then
		file.CreateDir("bricks_server/garbage_spawns", "DATA")
	end
	
	BRS_GARBAGE_SPAWNS = BRS_GARBAGE_SPAWNS or {}
	if( file.Exists( "bricks_server/garbage_spawns/".. string.lower(game.GetMap()) ..".txt", "DATA" ) ) then
		BRS_GARBAGE_SPAWNS = util.JSONToTable( file.Read( "bricks_server/garbage_spawns/".. string.lower(game.GetMap()) ..".txt", "DATA" ) ) or {}
	end
end
loadGarbageSpawns()

hook.Add( "BRS.Hooks.ConfigUpdated", "BRS.Hooks.ConfigUpdated_Crafting", function( keysChanged )	
	if( table.HasValue( (keysChanged or {}), "CRAFTING" ) and BRICKS_SERVER.LoadEntities ) then
		BRICKS_SERVER.LoadEntities()
	end
end )