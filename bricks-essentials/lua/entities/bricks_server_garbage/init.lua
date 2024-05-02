AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self:SetModel( table.Random( BRICKS_SERVER.DEVCONFIG.GarbageModels ) or "" )

	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	
    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end

	self:GetPhysicsObject():EnableMotion( false )

	self:SetCollector( nil )
end

function ENT:Use( activator, caller )
	if( IsValid( self:GetCollector() ) ) then return end
	if( caller:GetPos():DistToSqr( self:GetPos() ) > 10000 ) then return end
	if( not caller:GetEyeTrace() or not caller:GetEyeTrace().Entity or caller:GetEyeTrace().Entity != self ) then return end
	if( caller:GetNW2Int("bricks_server_garbagetime", 0) > CurTime() ) then return end

	self:SetCollector( caller )

	caller:SetNW2Int( "bricks_server_garbagetime", CurTime()+(BRICKS_SERVER.CONFIG.CRAFTING["Garbage Collect Time"] or 5) )
end

function ENT:Think()
	if( IsValid( self:GetCollector() ) ) then
		local ply = self:GetCollector()

		if( not ply:Alive() or ply:GetPos():DistToSqr( self:GetPos() ) > 10000 or not ply:GetEyeTrace() or not ply:GetEyeTrace().Entity or ply:GetEyeTrace().Entity != self ) then
			ply:SetNW2Int( "bricks_server_garbagetime", 0 )
			self:SetCollector( nil )
		else
			if( CurTime() >= ply:GetNW2Int( "bricks_server_garbagetime", 0 ) ) then
				self:RewardPly( ply )
			end
		end
	end
end

function ENT:RewardPly( ply )
	local resourceAmount = math.random( 1, 2 )
	for i = 1, resourceAmount do
		local ChosenResource = ""
		local ResourcePercent = math.Rand(0, 100)
		local CurPercent = 0
		for k, v in pairs( BRICKS_SERVER.CONFIG.CRAFTING.GarbageTypes ) do
			if( ResourcePercent > CurPercent and ResourcePercent < CurPercent+v ) then
				ChosenResource = k
				break
			end
			CurPercent = CurPercent+v
		end

		if( BRICKS_SERVER.CONFIG.CRAFTING.Resources[ChosenResource] ) then
			if( not BRICKS_SERVER.CONFIG.CRAFTING["Add Resources Directly To Inventory"] ) then
				local StartPos = self:GetPos()-(self:GetRight()*60)

				local resourceEnt = ents.Create( "bricks_server_resource_" .. string.Replace( string.lower( ChosenResource ), " ", "" ) )
				if( IsValid( resourceEnt ) ) then
					resourceEnt.farmed = true
					resourceEnt:SetPos( StartPos+(self:GetRight()*((i-1)*40))+(self:GetUp()*20) )
					resourceEnt:Spawn()
				end
			elseif( IsValid( ply ) and ply:IsPlayer() ) then
				local itemData = { "bricks_server_resource", (BRICKS_SERVER.CONFIG.CRAFTING.Resources[ChosenResource][1] or ""), ChosenResource }
                ply:BRS():AddInventoryItem( itemData, 1 )
			end
		end
	end

	ply:SetNW2Int( "bricks_server_garbagetime", 0 )

	if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "levelling" ) ) then
		ply:AddExperience( (BRICKS_SERVER.CONFIG.LEVELING["EXP Gained - Garbage Searched"] or 0), "Scavenging" )
	end

	self:Remove()
end