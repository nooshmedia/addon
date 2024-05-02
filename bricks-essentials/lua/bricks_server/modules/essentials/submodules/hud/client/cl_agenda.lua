local agendaText
local W, H = ScrW()*0.225, ScrH()*0.1
local X, Y = ScrW()-W-10, 30

hook.Add( "HUDPaint", "BRS.HUDPaint_DrawAgenda", function()
    local shouldDraw = hook.Call("HUDShouldDraw", GAMEMODE, "DarkRP_Agenda")
	if shouldDraw == false then return end
	
	if( not BRICKS_SERVER.Func.GetClientConfig( "HUDAgenda" ) ) then return end

    local agenda = LocalPlayer():getAgendaTable()
    if( not agenda ) then return end
	agendaText = agendaText or DarkRP.textWrap((LocalPlayer():getDarkRPVar("agenda") or ""):gsub("//", "\n"):gsub("\\n", "\n"), "BRICKS_SERVER_Font17", W-16)
	
	draw.RoundedBox( 5, X, Y, W, H, BRICKS_SERVER.Func.GetTheme( 3 ) )
    draw.RoundedBox( 5, X, Y, W, 25, BRICKS_SERVER.Func.GetTheme( 2 ) )
	
	draw.SimpleText( agenda.Title, "BRICKS_SERVER_Font20", X+8, Y+(25/2)-1, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_CENTER )

    draw.DrawNonParsedText(agendaText, "BRICKS_SERVER_Font17", X+8, Y+25, BRICKS_SERVER.Func.GetTheme( 6 ), 0)
end )

hook.Add("DarkRPVarChanged", "BRS.DarkRPVarChanged_DrawAgenda", function(ply, var, _, new)
    if ply ~= LocalPlayer() then return end
    if var == "agenda" and new then
        agendaText = DarkRP.textWrap(new:gsub("//", "\n"):gsub("\\n", "\n"), "BRICKS_SERVER_Font17", W)
    else
        agendaText = nil
    end
end)