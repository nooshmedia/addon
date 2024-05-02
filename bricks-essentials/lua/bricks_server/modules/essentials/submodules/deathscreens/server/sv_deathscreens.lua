util.AddNetworkString( "BRS.Net.Deathscreen_Killed" )
hook.Add( "PlayerDeath", "BRS.PlayerDeath_Deathscreen", function( victim, inflictor, attacker )
	if( IsValid( attacker ) and attacker:IsPlayer() ) then
		local card, emblem, sound = "", "", ""
		if( attacker.BRS_ACTIVE_DEATHSCREENS ) then
			card = attacker.BRS_ACTIVE_DEATHSCREENS[1] or ""
			emblem = attacker.BRS_ACTIVE_DEATHSCREENS[2] or ""
			sound = attacker.BRS_ACTIVE_DEATHSCREENS[3] or ""
		end

		local weapon = "nothing"
		if( IsValid( attacker:GetActiveWeapon() ) and attacker:GetActiveWeapon():GetClass() ) then
			weapon = attacker:GetActiveWeapon():GetClass()
			if( (list.Get( "Weapon" ) or {})[weapon] and (list.Get( "Weapon" ) or {})[weapon].PrintName ) then
				weapon = (list.Get( "Weapon" ) or {})[weapon].PrintName
			end
        end

		net.Start( "BRS.Net.Deathscreen_Killed" )
			net.WriteString( card )
			net.WriteString( emblem )
			net.WriteString( sound )
			net.WriteString( weapon )
			net.WriteString( attacker:SteamID64() )
		net.Send( victim )
	end
end )

util.AddNetworkString( "BRS.Net.Deathscreen_Respawn" )
hook.Add( "PlayerSpawn", "BRS.PlayerSpawn_Deathscreen", function( ply )
	net.Start( "BRS.Net.Deathscreen_Respawn" )
	net.Send( ply )
end )

local playerMeta = FindMetaTable("Player")

util.AddNetworkString( "BRS.Net.SetDeathscreens" )
function playerMeta:SetDeathscreens( deathscreensTable, nosave )
	if( not deathscreensTable ) then return end

	net.Start( "BRS.Net.SetDeathscreens" )
		net.WriteTable( deathscreensTable )
	net.Send( self )

	self.BRS_DEATHSCREENS = (deathscreensTable or {})

	if( not nosave ) then
		self:BRS_Essentials_SaveStat( "deathscreens" )
	else
		for k, v in pairs( self.BRS_DEATHSCREENS ) do
			for key, val in pairs( v ) do
				if( val[1] != true ) then continue end

				local itemTable
				if( k == 1 ) then
					itemTable = BRICKS_SERVER.CONFIG.DEATHSCREENS.Cards[key]
				elseif( k == 2 ) then
					itemTable = BRICKS_SERVER.CONFIG.DEATHSCREENS.Emblems[key]
				elseif( k == 3 ) then
					itemTable = BRICKS_SERVER.CONFIG.DEATHSCREENS.Soundtracks[key]
				end

				if( not itemTable ) then continue end

				self.BRS_ACTIVE_DEATHSCREENS = self.BRS_ACTIVE_DEATHSCREENS or {}
				if( k != 3 ) then
					self.BRS_ACTIVE_DEATHSCREENS[k] = itemTable.Image or itemTable.GIF
				else
					self.BRS_ACTIVE_DEATHSCREENS[k] = itemTable.Sound
				end
			end
		end
	end
end

function playerMeta:GetDeathscreens()
	return (self.BRS_DEATHSCREENS or {})
end

util.AddNetworkString( "BRS.Net.DeathscreensUnlockItem" )
net.Receive( "BRS.Net.DeathscreensUnlockItem", function( len, ply )
	local type = net.ReadUInt( 2 )
	local itemKey = net.ReadString()

	if( not type or not itemKey ) then return end

	local itemTable
	if( type == 1 ) then
		itemTable = BRICKS_SERVER.CONFIG.DEATHSCREENS.Cards[itemKey]
	elseif( type == 2 ) then
		itemTable = BRICKS_SERVER.CONFIG.DEATHSCREENS.Emblems[itemKey]
	elseif( type == 3 ) then
		itemTable = BRICKS_SERVER.CONFIG.DEATHSCREENS.Soundtracks[itemKey]
	end

	if( not itemTable ) then return end

	local plyDeathscreenData = ply:GetDeathscreens() or {}

	if( plyDeathscreenData and plyDeathscreenData[type] and plyDeathscreenData[type][itemKey] ) then return end
	
	if( itemTable.Price ) then
		if( ply:getDarkRPVar( "money" ) < itemTable.Price ) then
			DarkRP.notify( ply, 1, 5, "You don't have enough money to unlock this item!" )
			return
		end
	end

	if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "levelling" ) and itemTable.Level ) then
		if( ply:GetLevel() < itemTable.Level ) then
			DarkRP.notify( ply, 1, 5, "You are not the right level to unlock this item!" )
			return
		end
	end

	if( itemTable.Group ) then
		if( not BRICKS_SERVER.Func.IsInGroup( ply, itemTable.Group ) ) then
			DarkRP.notify( ply, 1, 5, "You are not the right group to unlock this item!" )
			return
		end
	end

	if( itemTable.Price ) then
		ply:addMoney( -itemTable.Price )
		DarkRP.notify( ply, 1, 5, "You have unlocked " .. (itemTable.Name or "Error") .. " for " .. DarkRP.formatMoney( itemTable.Price ) .. "!" )
	else
		DarkRP.notify( ply, 1, 5, "You have unlocked " .. (itemTable.Name or "Error") .. "!" )
	end

	if( not plyDeathscreenData[type] ) then
		plyDeathscreenData[type] = {}
	end

	plyDeathscreenData[type][itemKey] = { false }

	ply:SetDeathscreens( plyDeathscreenData )
end )

util.AddNetworkString( "BRS.Net.DeathscreensMakeactive" )
net.Receive( "BRS.Net.DeathscreensMakeactive", function( len, ply )
	local type = net.ReadUInt( 2 )
	local itemKey = net.ReadString()

	if( not type or not itemKey ) then return end

	local itemTable
	if( type == 1 ) then
		itemTable = BRICKS_SERVER.CONFIG.DEATHSCREENS.Cards[itemKey]
	elseif( type == 2 ) then
		itemTable = BRICKS_SERVER.CONFIG.DEATHSCREENS.Emblems[itemKey]
	elseif( type == 3 ) then
		itemTable = BRICKS_SERVER.CONFIG.DEATHSCREENS.Soundtracks[itemKey]
	end

	if( not itemTable ) then return end

	local plyDeathscreenData = ply:GetDeathscreens() or {}

	if( not plyDeathscreenData or not plyDeathscreenData[type] or not plyDeathscreenData[type][itemKey] or plyDeathscreenData[type][itemKey][1] ) then return end
	
	DarkRP.notify( ply, 1, 5, "Your " .. (itemTable.Name or "Error") .. " is now active!" )

	for k, v in pairs( plyDeathscreenData[type] ) do
		if( v[1] == true ) then
			plyDeathscreenData[type][k] = { false }
		end
	end

	plyDeathscreenData[type][itemKey] = { true }

	ply:SetDeathscreens( plyDeathscreenData )

	ply.BRS_ACTIVE_DEATHSCREENS = ply.BRS_ACTIVE_DEATHSCREENS or {}
	if( type != 3 ) then
		ply.BRS_ACTIVE_DEATHSCREENS[type] = itemTable.Image or itemTable.GIF
	else
		ply.BRS_ACTIVE_DEATHSCREENS[type] = itemTable.Sound
	end
end )