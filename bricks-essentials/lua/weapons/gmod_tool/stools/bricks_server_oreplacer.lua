TOOL.Category = "Bricks Server"
TOOL.Name = "Rock Spawns"
TOOL.Command = nil
TOOL.ConfigName = "" --Setting this means that you do not have to create external configuration files to define the layout of the tool config-hud 
 
local function SaveRockSpawns()
	if( timer.Exists( "bricks_server_timer_saverockspawns" ) ) then
		timer.Remove( "bricks_server_timer_saverockspawns" )
	end

	timer.Create( "bricks_server_timer_saverockspawns", 3, 1, function()
		if not file.IsDir("bricks_server/rock_spawns", "DATA") then
			file.CreateDir("bricks_server/rock_spawns", "DATA")
		end

		file.Write("bricks_server/rock_spawns/".. string.lower(game.GetMap()) ..".txt", util.TableToJSON( (BRS_ROCK_SPAWNS or {}) ), "DATA")
	end )
end

function TOOL:LeftClick( trace )
	if( !trace.HitPos || IsValid( trace.Entity ) && trace.Entity:IsPlayer() ) then return false end
	if( CLIENT ) then return true end

	local ply = self:GetOwner()
	
	if( not BRICKS_SERVER.Func.HasAdminAccess( ply ) ) then
		DarkRP.notify( ply, 1, 2, "You don't have permission to use this tool." )
		return
	end

	if( trace.HitPos and trace.HitNormal ) then
		table.insert( BRS_ROCK_SPAWNS, ""..(trace.HitPos[1])..";"..(trace.HitPos[2])..";"..(trace.HitPos[3])..";"..(trace.HitNormal[1])..";"..(trace.HitNormal[2])..";"..(trace.HitNormal[3]).."" )

		local admins = {}
		for k, v in pairs( player.GetAll() ) do
			if( BRICKS_SERVER.Func.HasAdminAccess( v ) ) then
				table.insert( admins, v )
			end
		end

		net.Start( "BRS.Net.SendRockSpawns" )
			net.WriteTable( BRS_ROCK_SPAWNS )
		net.Send( admins )

		SaveRockSpawns()
	end
end
 
function TOOL:RightClick( trace )
	if( !trace.HitPos ) then return false end
	if( CLIENT ) then return true end

	local ply = self:GetOwner()
	
	if( not BRICKS_SERVER.Func.HasAdminAccess( ply ) ) then
		DarkRP.notify( ply, 1, 2, "You don't have permission to use this tool." )
		return
	end
	
	for k, v in pairs( BRS_ROCK_SPAWNS ) do
		local tableString = string.Explode( ";", v )
		local position = Vector( tableString[1], tableString[2], tableString[3] )

		local Distance = trace.HitPos:DistToSqr( position )
		if( Distance < 4000 ) then
			BRS_ROCK_SPAWNS[k] = nil

			local admins = {}
			for k, v in pairs( player.GetAll() ) do
				if( BRICKS_SERVER.Func.HasAdminAccess( v ) ) then
					table.insert( admins, v )
				end
			end
	
			net.Start( "BRS.Net.SendRockSpawns" )
				net.WriteTable( BRS_ROCK_SPAWNS )
			net.Send( admins )

			SaveRockSpawns()
			break
		end
	end	
end

function TOOL:DrawToolScreen( width, height )
	if( not BRICKS_SERVER.Func.HasAdminAccess( LocalPlayer() ) ) then return end

	surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 2 ) )
	surface.DrawRect( 0, 0, width, height )

	surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 0 ) )
	surface.DrawRect( 0, 0, width, 60 )
	
	draw.SimpleText( language.GetPhrase( "tool.bricks_server_oreplacer.name" ), "BRICKS_SERVER_Font33", width/2, 30, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	draw.SimpleText( table.Count( BRS_ROCK_SPAWNS or {} ) .. " ore placed", "BRICKS_SERVER_Font30", width/2, 60+((height-60)/2)-15, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
end

function TOOL.BuildCPanel( panel )
	panel:AddControl("Header", { Text = "Rock Spawns", Description = "Places rock spawns from Brick's Server and saves their positions. LeftClick - Place. RightClick - Remove. Reload - Remove all." })
end

if( SERVER ) then
	util.AddNetworkString( "BRS.Net.SendRockSpawns" )
	function TOOL:Deploy()
		local ply = self:GetOwner()
		if( IsValid( ply ) and BRICKS_SERVER.Func.HasAdminAccess( ply ) ) then
			net.Start( "BRS.Net.SendRockSpawns" )
				net.WriteTable( BRS_ROCK_SPAWNS )
			net.Send( ply )
		end
	end

	util.AddNetworkString( "BRS.Net.RemoveRockSpawns" )
	net.Receive( "BRS.Net.RemoveRockSpawns", function( len, ply )
		if( not BRICKS_SERVER.Func.HasAdminAccess( ply ) ) then return end

		BRS_ROCK_SPAWNS = {}

		local admins = {}
		for k, v in pairs( player.GetAll() ) do
			if( BRICKS_SERVER.Func.HasAdminAccess( v ) ) then
				table.insert( admins, v )
			end
		end

		net.Start( "BRS.Net.SendRockSpawns" )
			net.WriteTable( BRS_ROCK_SPAWNS )
		net.Send( admins )

		SaveRockSpawns()
	end )
elseif( CLIENT ) then
	language.Add( "tool.bricks_server_oreplacer.name", "Ore Spawns" )
	language.Add( "tool.bricks_server_oreplacer.desc", "Places and removes rock spawns from Brick's Server." )
	language.Add( "tool.bricks_server_oreplacer.0", "LeftClick - place, RightClick - remove, Reload - remove all." )

	function TOOL:DrawHUD()
		if( not BRICKS_SERVER.Func.HasAdminAccess( LocalPlayer() ) ) then return end

		for k, v in pairs( BRS_ROCK_SPAWNS or {} ) do
			local tableString = string.Explode( ";", v )
			local position = Vector( tableString[1], tableString[2], tableString[3] )
			local angles = Angle( tableString[4], tableString[5], tableString[6] )

			local Distance = LocalPlayer():GetPos():DistToSqr( position )

			local pos = Vector( position.x, position.y, position.z+40 )
			local pos2d = pos:ToScreen()

			draw.SimpleText( "Rock " .. k, "BRICKS_SERVER_Font33", pos2d.x+1, pos2d.y-1, Color( 0, 0, 0 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			draw.SimpleText( "Rock " .. k, "BRICKS_SERVER_Font33", pos2d.x-1, pos2d.y+1, Color( 0, 0, 0 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			draw.SimpleText( "Rock " .. k, "BRICKS_SERVER_Font33", pos2d.x, pos2d.y, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
	end

	function TOOL:Holster()
		if( not BRICKS_SERVER.Func.HasAdminAccess( LocalPlayer() ) ) then return end

		for k, v in pairs( BRS_CLIENTSIDE_ROCKPROPS or {} ) do
			if( IsValid( v ) ) then
				v:Remove()
			end
		end
	end

	local cooldown = 0
	function TOOL:Reload()
		if( not BRICKS_SERVER.Func.HasAdminAccess( LocalPlayer() ) ) then return end
		if( (cooldown or 0) > CurTime() ) then return end

		cooldown = CurTime()+1

		BRICKS_SERVER.Func.Query( "Are you sure you want to remove all rock spawns?", "Admin", "Confirm", "Cancel", function() 
			net.Start( "BRS.Net.RemoveRockSpawns" )
			net.SendToServer()
		end )
	end

	net.Receive( "BRS.Net.SendRockSpawns", function()
		if( not BRICKS_SERVER.Func.HasAdminAccess( LocalPlayer() ) ) then return end

		BRS_ROCK_SPAWNS = net.ReadTable() or {}

		for k, v in pairs( BRS_CLIENTSIDE_ROCKPROPS or {} ) do
			if( IsValid( v ) ) then
				v:Remove()
			end
		end

		BRS_CLIENTSIDE_ROCKPROPS = {}

		for k, v in pairs( BRS_ROCK_SPAWNS ) do
			local tableString = string.Explode( ";", v )
			local position = Vector( tableString[1], tableString[2], tableString[3] )
			local angles = Angle( tableString[4], tableString[5], tableString[6] )

			if( not BRS_CLIENTSIDE_ROCKPROPS[k] ) then
				BRS_CLIENTSIDE_ROCKPROPS[k] = ents.CreateClientProp()
				BRS_CLIENTSIDE_ROCKPROPS[k]:SetPos( position )
				BRS_CLIENTSIDE_ROCKPROPS[k]:SetAngles( angles )
				BRS_CLIENTSIDE_ROCKPROPS[k]:SetModel( "models/2rek/brickwall/bwall_rock_1.mdl" )
				BRS_CLIENTSIDE_ROCKPROPS[k]:Spawn()
				BRS_CLIENTSIDE_ROCKPROPS[k]:SetRenderMode( RENDERMODE_TRANSCOLOR )
				BRS_CLIENTSIDE_ROCKPROPS[k]:SetColor( Color( 255, 255, 255, 160 ) )
			end
		end
	end )
end