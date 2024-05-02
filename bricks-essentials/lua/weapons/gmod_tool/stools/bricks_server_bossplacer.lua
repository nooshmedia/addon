TOOL.Category = "Bricks Server"
TOOL.Name = "Boss Placer"
TOOL.Command = nil
TOOL.ConfigName = "" --Setting this means that you do not have to create external configuration files to define the layout of the tool config-hud 
 
local function SaveBossSpawns()
	if( timer.Exists( "bricks_server_timer_savebossspawns" ) ) then
		timer.Remove( "bricks_server_timer_savebossspawns" )
	end

	timer.Create( "bricks_server_timer_savebossspawns", 3, 1, function()
		if not file.IsDir("bricks_server/boss_spawns", "DATA") then
			file.CreateDir("bricks_server/boss_spawns", "DATA")
		end

		file.Write("bricks_server/boss_spawns/".. string.lower(game.GetMap()) ..".txt", util.TableToJSON( (BRS_BOSS_SPAWNS or {}) ), "DATA")
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

	local bossType, freqType = ply:GetNW2Int( "bricks_server_stoolcmd_bosstype" ), ply:GetNW2String( "bricks_server_stoolcmd_freqtype" )

	local NPCTable = BRICKS_SERVER.CONFIG.BOSS.NPCs[bossType]
	if( NPCTable ) then
		if( BRICKS_SERVER.DEVCONFIG.SpawnTimes[freqType] ) then
			local spawnKey = table.insert( BRS_BOSS_SPAWNS, { bossType, ""..(trace.HitPos[1])..";"..(trace.HitPos[2])..";"..(trace.HitPos[3])..";"..(trace.HitNormal[1])..";"..(trace.HitNormal[2])..";"..(trace.HitNormal[3]).."", freqType } )
			BRICKS_SERVER.Func.SpawnBoss( spawnKey )

			local admins = {}
			for k, v in pairs( player.GetAll() ) do
				if( BRICKS_SERVER.Func.HasAdminAccess( v ) ) then
					table.insert( admins, v )
				end
			end
	
			net.Start( "BRS.Net.SendBossSpawns" )
				net.WriteTable( BRS_BOSS_SPAWNS )
			net.Send( admins )
	
			SaveBossSpawns()

			DarkRP.notify( ply, 1, 2, "Boss succesfully placed." )
		else
			DarkRP.notify( ply, 1, 2, "Invalid Frequency type, choose a valid one from the tool menu." )
		end
	else
		DarkRP.notify( ply, 1, 2, "Invalid Boss type, choose a valid one from the tool menu." )
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

	for k, v in pairs( BRS_BOSS_SPAWNS ) do
		local tableString = string.Explode( ";", v[2] )
		local position = Vector( tableString[1], tableString[2], tableString[3] )

		local Distance = trace.HitPos:DistToSqr( position )
		if( Distance < 4000 ) then
			BRS_BOSS_SPAWNS[k] = nil

			if( timer.Exists( "BRS_BOSS_TIMER_" .. k ) ) then
				timer.Remove( "BRS_BOSS_TIMER_" .. k )
			end

			local BossTable = BRICKS_SERVER.CONFIG.BOSS.NPCs[v[1]]
			if( BossTable and BossTable.Class ) then
				for key, val in pairs( ents.FindByClass( BossTable.Class or "" ) ) do
					if( val:GetNW2Int( "BRICKS_SERVER_SPAWN_KEY", 0 ) == k ) then
						val:Remove()
						break
					end
				end
			end

			local admins = {}
			for k, v in pairs( player.GetAll() ) do
				if( BRICKS_SERVER.Func.HasAdminAccess( v ) ) then
					table.insert( admins, v )
				end
			end
	
			net.Start( "BRS.Net.SendBossSpawns" )
				net.WriteTable( BRS_BOSS_SPAWNS )
			net.Send( admins )

			SaveBossSpawns()
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
	
	draw.SimpleText( language.GetPhrase( "tool.bricks_server_bossplacer.name" ), "BRICKS_SERVER_Font33", width/2, 30, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

	local bossSelected = BRICKS_SERVER.CONFIG.BOSS.NPCs[LocalPlayer():GetNW2Int( "bricks_server_stoolcmd_bosstype", 0 )]
	draw.SimpleText( "Boss", "BRICKS_SERVER_Font33", width/2, 60+((height-60)/3), BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
	draw.SimpleText( ((bossSelected and (bossSelected.Name or "ERROR")) or "None"), "BRICKS_SERVER_Font25", width/2, 60+((height-60)/3), BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, 0 )

	draw.SimpleText( "Frequency", "BRICKS_SERVER_Font33", width/2, 60+(((height-60)/3)*2), BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
	draw.SimpleText( (LocalPlayer():GetNW2String( "bricks_server_stoolcmd_freqtype", "" ) or "None"), "BRICKS_SERVER_Font25", width/2, 60+(((height-60)/3)*2), BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, 0 )
end

function TOOL.BuildCPanel( panel )
	panel:AddControl("Header", { Text = "Boss Type", Description = "Places and removes Bosses, LeftClick - place, RightClick - remove." })
 
	local combo = panel:AddControl( "ComboBox", { Label = "Boss Type" } )
	for k, v in pairs( BRICKS_SERVER.CONFIG.BOSS.NPCs ) do
		combo:AddOption( v.Name, { k } )
	end

	local frequency = panel:AddControl( "ComboBox", { Label = "Spawn frequency" } )
	for k, v in pairs( BRICKS_SERVER.DEVCONFIG.SpawnTimes ) do
		frequency:AddOption( k, { k } )
	end

	local function SendOptionData()
		local text1, data1 = combo:GetSelected()
		local text2, data2 = frequency:GetSelected()

		if( not data1 and not data2 ) then return end

		net.Start( "BRS.Net.ToolBossPlacer" )
			net.WriteUInt( ((data1 or {})[1] or 0), 32 )
			net.WriteString( (data2 or {})[1] or "" )
		net.SendToServer()
	end

	combo.OnSelect = SendOptionData
	frequency.OnSelect = SendOptionData
end

if( SERVER ) then
	util.AddNetworkString( "BRS.Net.ToolBossPlacer" )
	net.Receive( "BRS.Net.ToolBossPlacer", function( len, ply )
		if( not BRICKS_SERVER.Func.HasAdminAccess( ply ) ) then return end

		ply:SetNW2Int( "bricks_server_stoolcmd_bosstype", net.ReadUInt( 32 ) )
		ply:SetNW2String( "bricks_server_stoolcmd_freqtype", net.ReadString() )
	end )

	util.AddNetworkString( "BRS.Net.SendBossSpawns" )
	function TOOL:Deploy()
		local ply = self:GetOwner()
		if( IsValid( ply ) and BRICKS_SERVER.Func.HasAdminAccess( ply ) ) then
			net.Start( "BRS.Net.SendBossSpawns" )
				net.WriteTable( BRS_BOSS_SPAWNS or {} )
			net.Send( ply )
		end
	end

	util.AddNetworkString( "BRS.Net.RemoveBossSpawns" )
	net.Receive( "BRS.Net.RemoveBossSpawns", function( len, ply )
		if( not BRICKS_SERVER.Func.HasAdminAccess( ply ) ) then return end

		for k, v in pairs( BRS_BOSS_SPAWNS or {} ) do
			if( timer.Exists( "BRS_BOSS_TIMER_" .. k ) ) then
				timer.Remove( "BRS_BOSS_TIMER_" .. k )
			end

			local BossTable = BRICKS_SERVER.CONFIG.BOSS.NPCs[v[1]]
			if( BossTable and BossTable.Class ) then
				for key, val in pairs( ents.FindByClass( BossTable.Class or "" ) ) do
					if( val:GetNW2Int( "BRICKS_SERVER_SPAWN_KEY", 0 ) == k ) then
						val:Remove()
						break
					end
				end
			end
		end

		BRS_BOSS_SPAWNS = {}

		local admins = {}
		for k, v in pairs( player.GetAll() ) do
			if( BRICKS_SERVER.Func.HasAdminAccess( v ) ) then
				table.insert( admins, v )
			end
		end

		net.Start( "BRS.Net.SendBossSpawns" )
			net.WriteTable( BRS_BOSS_SPAWNS )
		net.Send( admins )

		SaveBossSpawns()
	end )
elseif( CLIENT ) then
	language.Add( "tool.bricks_server_bossplacer.name", "Boss Placer" )
	language.Add( "tool.bricks_server_bossplacer.desc", "Places and removes Bosses" )
	language.Add( "tool.bricks_server_bossplacer.0", "LeftClick - place, RightClick - remove, Reload - remove all." )

	function TOOL:DrawHUD()
		if( not BRICKS_SERVER.Func.HasAdminAccess( LocalPlayer() ) ) then return end

		for k, v in pairs( BRS_BOSS_SPAWNS or {} ) do
			local tableString = string.Explode( ";", v[2] )
			local position = Vector( tableString[1], tableString[2], tableString[3] )
			local angles = Angle( tableString[4], tableString[5], tableString[6] )

			local Distance = LocalPlayer():GetPos():DistToSqr( position )

			local pos = Vector( position.x, position.y, position.z+40 )
			local pos2d = pos:ToScreen()

			local bossTable = BRICKS_SERVER.CONFIG.BOSS.NPCs[v[1] or 0]
			local bossText = k .. " - " .. (bossTable or {}).Name

			draw.SimpleText( bossText, "BRICKS_SERVER_Font33", pos2d.x+1, pos2d.y-1, Color( 0, 0, 0 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			draw.SimpleText( bossText, "BRICKS_SERVER_Font33", pos2d.x-1, pos2d.y+1, Color( 0, 0, 0 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			draw.SimpleText( bossText, "BRICKS_SERVER_Font33", pos2d.x, pos2d.y, BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
	end

	function TOOL:Holster()
		if( not BRICKS_SERVER.Func.HasAdminAccess( LocalPlayer() ) ) then return end

		for k, v in pairs( BRS_CLIENTSIDE_BOSSPROPS or {} ) do
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

		BRICKS_SERVER.Func.Query( "Are you sure you want to remove all boss spawns?", "Admin", "Confirm", "Cancel", function() 
			net.Start( "BRS.Net.RemoveBossSpawns" )
			net.SendToServer()
		end )
	end

	net.Receive( "BRS.Net.SendBossSpawns", function()
		if( not BRICKS_SERVER.Func.HasAdminAccess( LocalPlayer() ) ) then return end

		BRS_BOSS_SPAWNS = net.ReadTable() or {}

		for k, v in pairs( BRS_CLIENTSIDE_BOSSPROPS or {} ) do
			if( IsValid( v ) ) then
				v:Remove()
			end
		end

		BRS_CLIENTSIDE_BOSSPROPS = {}

		for k, v in pairs( BRS_BOSS_SPAWNS ) do
			local bossTable = BRICKS_SERVER.CONFIG.BOSS.NPCs[v[1] or 0]
			local tableString = string.Explode( ";", v[2] or "" )
			local position = Vector( tableString[1], tableString[2], tableString[3] )
			local angles = Angle( tableString[4], tableString[5], tableString[6] )

			if( not BRS_CLIENTSIDE_BOSSPROPS[k] ) then
				BRS_CLIENTSIDE_BOSSPROPS[k] = ents.CreateClientProp()
				BRS_CLIENTSIDE_BOSSPROPS[k]:SetPos( position )
				BRS_CLIENTSIDE_BOSSPROPS[k]:SetAngles( angles )
				BRS_CLIENTSIDE_BOSSPROPS[k]:SetModel( (bossTable or {}).Model or "models/zombie/classic.mdl" )
				BRS_CLIENTSIDE_BOSSPROPS[k]:Spawn()
				BRS_CLIENTSIDE_BOSSPROPS[k]:SetRenderMode( RENDERMODE_TRANSCOLOR )
				BRS_CLIENTSIDE_BOSSPROPS[k]:SetColor( Color( 255, 255, 255, 160 ) )
			end
		end
	end )
end