AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

util.AddNetworkString( "BRS.Net.EnterZone" )
function ENT:StartTouch( ent )
	if( ent and IsValid( ent ) and ent:IsPlayer() ) then
		if( self.configKey ) then
			local configTable = (BRICKS_SERVER.CONFIG.ZONES or {})[self.configKey]
			if( configTable and configTable[9] ) then
				ent:Kill()
			else
				ent:SetNW2Int( "BRS_IN_ZONE", self.configKey )

				net.Start( "BRS.Net.EnterZone" )
					net.WriteUInt( self.configKey, 16 )
				net.Send( ent )
			end
		end
	end
end

util.AddNetworkString( "BRS.Net.ExitZone" )
function ENT:EndTouch( ent )
	if( ent and IsValid( ent ) and ent:IsPlayer() ) then
		if( self.configKey ) then
			ent:SetNW2Int( "BRS_IN_ZONE", 0 )

			net.Start( "BRS.Net.ExitZone" )
				net.WriteUInt( self.configKey, 16 )
			net.Send( ent )
		end
	end
end