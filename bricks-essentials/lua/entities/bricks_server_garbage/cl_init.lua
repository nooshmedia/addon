include('shared.lua')

function ENT:Draw()

	self:DrawModel()

end

hook.Add( "HUDPaint", "BRS.HUDPaint_DrawGarbageHUD", function()
	if( LocalPlayer():GetEyeTrace() and LocalPlayer():GetEyeTrace().Entity and IsValid( LocalPlayer():GetEyeTrace().Entity ) ) then
		local Distance = LocalPlayer():GetPos():DistToSqr( LocalPlayer():GetEyeTrace().Entity:GetPos() )

		if( LocalPlayer():GetEyeTrace().Entity:GetClass() == "bricks_server_garbage" ) then
			if( Distance < 10000 ) then
				local text = "Press " .. string.upper( (input.LookupBinding( "+use" ) or "UNBOUND") ) .. " to search garbage"
				draw.SimpleText( text, "BRICKS_SERVER_Font40", ScrW()/2+1, (ScrH()-(ScrH()/3))-1, Color( 0, 0, 0 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				draw.SimpleText( text, "BRICKS_SERVER_Font40", ScrW()/2-1, (ScrH()-(ScrH()/3))+1, Color( 0, 0, 0 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				draw.SimpleText( text, "BRICKS_SERVER_Font40", ScrW()/2, (ScrH()-(ScrH()/3)), BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			end
		end
	end

	local CollectTime = LocalPlayer():GetNW2Int( "bricks_server_garbagetime", 0 )

	if( CollectTime >= CurTime() ) then
		local status = math.Clamp(1-((CollectTime-CurTime())/(BRICKS_SERVER.CONFIG.CRAFTING["Garbage Collect Time"] or 5)), 0, 1)
		BRICKS_SERVER.Func.DrawProgress( "Searching", status )
	end
end )
