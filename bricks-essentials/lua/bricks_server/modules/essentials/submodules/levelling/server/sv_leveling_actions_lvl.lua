// NPCKill Reward
hook.Add( "OnNPCKilled", "BRS.OnNPCKilled_Levelling", function( npc, attacker, inflictor )
	if( attacker:IsPlayer() and npc:GetNW2Int( "BRICKS_SERVER_BOSS_KEY" ) <= 0 ) then
		attacker:AddExperience( BRICKS_SERVER.CONFIG.LEVELING["EXP Gained - Killing NPC"], "NPC Killed" )
	end
end )

// PlayingOnServer Reward
hook.Add( "PlayerInitialSpawn", "BRS.PlayerInitialSpawn_Levelling", function( ply )
	timer.Create( tostring( ply ) .. "ServerTimerEXPGive", BRICKS_SERVER.CONFIG.LEVELING["Playing On Server Reward Time"], 0, function() 
		if( IsValid( ply ) ) then
			ply:AddExperience( BRICKS_SERVER.CONFIG.LEVELING["EXP Gained - Playing On Server"], "Playing On Server" )
		else
			if( timer.Exists( tostring( ply ) .. "ServerTimerEXPGive" ) ) then
				timer.Remove( tostring( ply ) .. "ServerTimerEXPGive" )
			end
		end
	end )
end )

// LockPick Reward
hook.Add( "onLockpickCompleted", "BRS.onLockpickCompleted_Levelling", function( ply, success, ent)
	if( ent:isDoor() or ent:IsVehicle() or ent.isFadingDoor ) then
		if( ent:isLocked() ) then
			if( success == true ) then
				ply:AddExperience( BRICKS_SERVER.CONFIG.LEVELING["EXP Gained - Lockpick"], "LockPick Success" )
			end
		end
	end
end )

// LotteryEnter Reward
hook.Add( "playerEnteredLottery", "BRS.playerEnteredLottery_Levelling", function( ply )
	if( ply:IsPlayer() ) then
		ply:AddExperience( BRICKS_SERVER.CONFIG.LEVELING["EXP Gained - Entered Lottery"], "Entered Lottery" )
	end
end )

// LotteryWon Reward
hook.Add( "lotteryEnded", "BRS.lotteryEnded_Levelling", function( participants,  chosen, amount )
	if( chosen:IsPlayer() ) then
		chosen:AddExperience( BRICKS_SERVER.CONFIG.LEVELING["EXP Gained - Lottery Won"], "Won Lottery" )
	end
end )

// HitCompleted Reward
hook.Add( "onHitCompleted", "BRS.onHitCompleted_Levelling", function( hitman, target, customer )
	if( hitman:IsPlayer() ) then
		hitman:AddExperience( BRICKS_SERVER.CONFIG.LEVELING["EXP Gained - Hit Completed"], "Hit Success" )
	end
end )

-- Level can change team
hook.Add( "playerCanChangeTeam", "BRS.playerCanChangeTeam_Levelling", function( ply, job, force )
	if( BRICKS_SERVER.CONFIG.LEVELING.JobLevels[RPExtraTeams[job].command or "error"] ) then
		if( (ply.BRS_LEVEL or 0) < BRICKS_SERVER.CONFIG.LEVELING.JobLevels[RPExtraTeams[job].command or "error"] ) then
			return false, "You are not the right level for this job (Level " .. BRICKS_SERVER.CONFIG.LEVELING.JobLevels[RPExtraTeams[job].command or "error"] .. ")."
		end
	end
end )

-- Level can buy shipment
hook.Add( "canBuyShipment", "BRS.canBuyShipment_Levelling", function( ply, shipments )
	if( BRICKS_SERVER.CONFIG.LEVELING.ShipmentLevels[shipments.name or "error"] ) then
		if( (ply.BRS_LEVEL or 0) < BRICKS_SERVER.CONFIG.LEVELING.ShipmentLevels[shipments.name or "error"] ) then
			return false, false, "You are not the right level to buy this shipment (Level " .. BRICKS_SERVER.CONFIG.LEVELING.ShipmentLevels[shipments.name or "error"] .. ")."
		end
	end
end )

-- Level can buy entity
hook.Add( "canBuyCustomEntity", "BRS.canBuyCustomEntity_Levelling", function( ply, entity )
	if( BRICKS_SERVER.CONFIG.LEVELING.EntityLevels[entity.cmd or "error"] ) then
		if( (ply.BRS_LEVEL or 0) < BRICKS_SERVER.CONFIG.LEVELING.EntityLevels[entity.cmd or "error"] ) then
			return false, false, "You are not the right level to buy this entity (Level " .. BRICKS_SERVER.CONFIG.LEVELING.EntityLevels[entity.cmd or "error"] .. ")."
		end
	end
end )

-- Level can buy ammo
hook.Add( "canBuyAmmo", "BRS.canBuyAmmo_Levelling", function( ply, ammo )
	if( (BRICKS_SERVER.CONFIG.LEVELING.AmmoLevels or {})[ammo.id or 0] ) then
		if( (ply.BRS_LEVEL or 0) < BRICKS_SERVER.CONFIG.LEVELING.AmmoLevels[ammo.id] ) then
			return false, false, "You are not the right level to buy this ammo (Level " .. BRICKS_SERVER.CONFIG.LEVELING.AmmoLevels[ammo.id] .. ")."
		end
	end
end )