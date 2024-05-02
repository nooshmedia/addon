timer.Simple( 5, function()
	local player_meta = FindMetaTable("Player")

	if( SERVER ) then
		util.AddNetworkString("BRS.Net.SendEntityMaxChange")
	end

	local maxEntities = {}
	function player_meta:addCustomEntity(entTable)
		if not entTable then return end

		maxEntities[self] = maxEntities[self] or {}
		maxEntities[self][entTable.cmd] = maxEntities[self][entTable.cmd] or 0
		maxEntities[self][entTable.cmd] = maxEntities[self][entTable.cmd] + 1

		if( SERVER ) then
			net.Start( "BRS.Net.SendEntityMaxChange" )
				net.WriteString( entTable.cmd )
				net.WriteBool( true )
			net.Send( self )
		end
	end

	function player_meta:removeCustomEntity(entTable)
		if not entTable.cmd then return end

		maxEntities[self] = maxEntities[self] or {}
		maxEntities[self][entTable.cmd] = maxEntities[self][entTable.cmd] or 0
		maxEntities[self][entTable.cmd] = maxEntities[self][entTable.cmd] - 1

		if( SERVER ) then
			net.Start( "BRS.Net.SendEntityMaxChange" )
				net.WriteString( entTable.cmd )
				net.WriteBool( false )
			net.Send( self )
		end
	end

	function player_meta:customEntityLimitReached(entTable)
		maxEntities[self] = maxEntities[self] or {}
		maxEntities[self][entTable.cmd] = maxEntities[self][entTable.cmd] or 0
		local max = entTable.getMax and entTable.getMax(self) or entTable.max

		return max ~= 0 and maxEntities[self][entTable.cmd] >= max
	end

	hook.Add( "PlayerDisconnected", "BRS.PlayerDisconnected_RemoveMaxLimits", function(ply)
		maxEntities[ply] = nil
		net.Start("DarkRP_DarkRPVarDisconnect")
			net.WriteUInt(ply:UserID(), 16)
		net.Broadcast()
	end )

	function player_meta:customEntityGetCurrent( entityCMD )
		if( maxEntities and maxEntities[self] and maxEntities[self][entityCMD] ) then
			return maxEntities[self][entityCMD]
		else
			return 0
		end
	end

	if( CLIENT ) then
		net.Receive( "BRS.Net.SendEntityMaxChange", function( len, ply )
			local entityCMD = net.ReadString()
			local addedEnt = net.ReadBool()

			maxEntities[LocalPlayer()] = maxEntities[LocalPlayer()] or {}
			maxEntities[LocalPlayer()][entityCMD] = maxEntities[LocalPlayer()][entityCMD] or 0

			if( addedEnt ) then
				maxEntities[LocalPlayer()][entityCMD] = maxEntities[LocalPlayer()][entityCMD]+1
			else
				maxEntities[LocalPlayer()][entityCMD] = maxEntities[LocalPlayer()][entityCMD]-1
			end
		end )
	end
end )