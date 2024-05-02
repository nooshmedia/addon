function BRICKS_SERVER.Func.SpawnBoss( spawnKey )
	local spawnTable = BRS_BOSS_SPAWNS[spawnKey]

	if( not spawnTable ) then return end

	local BossTable = BRICKS_SERVER.CONFIG.BOSS.NPCs[spawnTable[1] or 0]

	if( not BossTable ) then return end

	local tableString = string.Explode( ";", spawnTable[2] )
	local position = Vector( tableString[1], tableString[2], tableString[3] )

	local BossEntity = ents.Create( BossTable.Class )
	if ( !IsValid( BossEntity ) ) then return end
	BossEntity:SetPos( position )
	BossEntity:Spawn()
	BossEntity:SetHealth( BossTable.Health )
	BossEntity:SetNW2Int( "BRICKS_SERVER_BOSS_KEY", spawnTable[1] )
	BossEntity:SetNW2Int( "BRICKS_SERVER_SPAWN_KEY", spawnKey )
	if( BossTable.Weapon ) then
		BossEntity:Give( BossTable.Weapon )
	end
	if( BossTable.Scale ) then
		BossEntity:SetModelScale( BossTable.Scale, 0 )
		BossEntity:Activate()
	end
end

util.AddNetworkString( "BRS.Net.SendBossDamage" )
hook.Add( "EntityTakeDamage", "BRS.EntityTakeDamage_Boss", function( target, dmginfo )
	if( not target:IsPlayer() and IsValid( dmginfo:GetAttacker() ) and dmginfo:GetAttacker():IsPlayer() and target:GetNW2Int( "BRICKS_SERVER_BOSS_KEY" ) > 0 and BRICKS_SERVER.CONFIG.BOSS.NPCs[target:GetNW2Int( "BRICKS_SERVER_BOSS_KEY" )] ) then
		local NPCTable = BRICKS_SERVER.CONFIG.BOSS.NPCs[target:GetNW2Int( "BRICKS_SERVER_BOSS_KEY" )]

		if( not BRICKS_SERVER.TEMP.BOSS_DAMAGE ) then
			BRICKS_SERVER.TEMP.BOSS_DAMAGE = {}
		end

		if( not BRICKS_SERVER.TEMP.BOSS_DAMAGE[target] ) then
			BRICKS_SERVER.TEMP.BOSS_DAMAGE[target] = {}
		end

		BRICKS_SERVER.TEMP.BOSS_DAMAGE[target][dmginfo:GetAttacker()] = (BRICKS_SERVER.TEMP.BOSS_DAMAGE[target][dmginfo:GetAttacker()] or 0)+(dmginfo:GetDamage() or 0)

		if( CurTime() >= (dmginfo:GetAttacker().BRS_LASTNPCDAMAGE or 0) ) then
			dmginfo:GetAttacker().BRS_LASTNPCDAMAGE = CurTime()+BRICKS_SERVER.CONFIG.BOSS["Damage Update Time"]

			local newDamageTable = {}
			for k, v in pairs( BRICKS_SERVER.TEMP.BOSS_DAMAGE[target] ) do
				table.insert( newDamageTable, { v, k } )
			end

			table.sort( newDamageTable, function(a, b) return a[1] > b[1] end )

			for k, v in pairs( newDamageTable ) do
				if( v[2] != dmginfo:GetAttacker() and k > 5 ) then
					newDamageTable[k] = nil
				end
			end

			net.Start( "BRS.Net.SendBossDamage" )
				net.WriteEntity( target )
				net.WriteTable( newDamageTable or {} )
			net.Send( dmginfo:GetAttacker() )
		end
	elseif( target:IsPlayer() and IsValid( dmginfo:GetAttacker() ) and dmginfo:GetAttacker():GetNW2Int( "BRICKS_SERVER_BOSS_KEY" ) > 0 and BRICKS_SERVER.CONFIG.BOSS.NPCs[dmginfo:GetAttacker():GetNW2Int( "BRICKS_SERVER_BOSS_KEY" )] ) then
		if( BRICKS_SERVER.CONFIG.BOSS.NPCs[dmginfo:GetAttacker():GetNW2Int( "BRICKS_SERVER_BOSS_KEY" )].DamageScale ) then
			dmginfo:ScaleDamage( BRICKS_SERVER.CONFIG.BOSS.NPCs[dmginfo:GetAttacker():GetNW2Int( "BRICKS_SERVER_BOSS_KEY" )].DamageScale )
		end
	end
end )

util.AddNetworkString( "BRS.Net.SendBossDead" )
hook.Add( "OnNPCKilled", "BRS.OnNPCKilled_Boss", function( npc, attacker, inflictor )
	if( npc:GetNW2Int( "BRICKS_SERVER_BOSS_KEY" ) > 0 and BRICKS_SERVER.CONFIG.BOSS.NPCs[npc:GetNW2Int( "BRICKS_SERVER_BOSS_KEY" )] ) then
		local spawnKey = npc:GetNW2Int( "BRICKS_SERVER_SPAWN_KEY", 0 )
		local spawnTable = BRS_BOSS_SPAWNS[spawnKey] or {}
		local freqKey = spawnTable[3] or 0
		if( BRICKS_SERVER.DEVCONFIG.SpawnTimes[freqKey] and BRICKS_SERVER.DEVCONFIG.SpawnTimes[freqKey] > 0 ) then
			timer.Create( "BRS_BOSS_TIMER_" .. spawnKey, BRICKS_SERVER.DEVCONFIG.SpawnTimes[freqKey], 1, function()
				BRICKS_SERVER.Func.SpawnBoss( spawnKey )
			end )
		end

		local damageTable = {}
		if( BRICKS_SERVER.TEMP.BOSS_DAMAGE and BRICKS_SERVER.TEMP.BOSS_DAMAGE[npc] ) then
			damageTable = BRICKS_SERVER.TEMP.BOSS_DAMAGE[npc]
		end

		local NPCTable = BRICKS_SERVER.CONFIG.BOSS.NPCs[npc:GetNW2Int( "BRICKS_SERVER_BOSS_KEY" )]

		local players = {}
		if( damageTable ) then
			for k, v in pairs( damageTable ) do
				if( IsValid( k ) and v > 0 ) then
					local rewards = {}
					for k, v in pairs( NPCTable.Loot or {} ) do
						local dropPercent = math.Rand( 0, 100 )

						if( dropPercent <= (v.Chance or 0) ) then
							table.insert( rewards, v )
						end
					end

					table.insert( players, { k, rewards } )

					for key, val in pairs( rewards ) do
						if( not BRICKS_SERVER.DEVCONFIG.LootTypes[val.Type] ) then 
							print( "ERROR REWARDING PLAYER FOR KILLING " .. NPCTable.Name )
							continue
						end

						if( BRICKS_SERVER.DEVCONFIG.LootTypes[val.Type].GiveFunction ) then
							BRICKS_SERVER.DEVCONFIG.LootTypes[val.Type].GiveFunction( k, (val.ReqInfo or {}), val )
						end
					end
				end
			end
		end

		for k, v in pairs( players ) do
			if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "logging" ) ) then
				local rewards = {}
				if( v[2] and istable( v[2] ) and #v[2] > 0 ) then
					for key, val in pairs( v[2] ) do
						table.insert( rewards, (val.Name or "") )
					end
				end

				v[1]:BRS_AddLog( "BossReward", { NPCTable.Name, (damageTable[v[1]] or 0), rewards } )
			end

			net.Start( "BRS.Net.SendBossDead" )
				net.WriteEntity( npc )
				net.WriteTable( damageTable )
				net.WriteTable( v[2] or {} )
			net.Send( v[1] )
		end
	end
end )

BRS_BOSS_SPAWNS = {}
hook.Add( "InitPostEntity", "BRS.InitPostEntity_LoadBossSpawns", function()	
	if not file.IsDir("bricks_server/boss_spawns", "DATA") then
		file.CreateDir("bricks_server/boss_spawns", "DATA")
	end
	
	BRS_BOSS_SPAWNS = BRS_BOSS_SPAWNS or {}
	if( file.Exists( "bricks_server/boss_spawns/".. string.lower(game.GetMap()) ..".txt", "DATA" ) ) then
		BRS_BOSS_SPAWNS = util.JSONToTable( file.Read( "bricks_server/boss_spawns/".. string.lower(game.GetMap()) ..".txt", "DATA" ) )
	end

	for k, v in pairs( BRS_BOSS_SPAWNS ) do
		BRICKS_SERVER.Func.SpawnBoss( k )
	end
end )