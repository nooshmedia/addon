net.Receive( "BRS.Net.SendCraftingSkills", function()
    local skillsTable = LocalPlayer():GetCraftingSkills()

    for i = 1, net.ReadUInt( 2 ) do
        local skillKey, level, experience = net.ReadString(), net.ReadUInt( 8 ), net.ReadUInt( 32 )
        if( skillsTable[skillKey] and skillsTable[skillKey][2] != experience ) then
            BRICKS_SERVER.Func.ShowCraftingSkillProgress( skillKey )
        end

        skillsTable[skillKey] = { level, experience }
    end

    BRICKS_SERVER.TEMP.CraftingSkills = skillsTable

    hook.Run( "BRS.Hooks.CraftingSkillsUpdated" )
end )

function BRICKS_SERVER.Func.ShowCraftingSkillProgress( skillKey )
    BRICKS_SERVER.TEMP.CraftingSkillProgressKey = skillKey

    local oldSkillInfo = LocalPlayer():GetCraftingSkills()[skillKey]
    BRICKS_SERVER.TEMP.CraftingSkillBarProgress = BRICKS_SERVER.Func.GetCraftingSkillProgress( skillKey, oldSkillInfo[1], oldSkillInfo[2] )

    BRICKS_SERVER.TEMP.CraftingSkillProgressLast = CurTime()
end

hook.Add( "HUDPaint", "BRS.HUDPaint_CraftingSkillProgress", function()
    local temp = BRICKS_SERVER.TEMP
	if( CurTime() >= (temp.CraftingSkillProgressLast or 0)+2 ) then
		if( (temp.CraftingSkillProgressAlpha or 1) <= 0 ) then return end
		temp.CraftingSkillProgressAlpha = Lerp( FrameTime()*10, (temp.CraftingSkillProgressAlpha or 0), 0 )
	elseif( (temp.CraftingSkillProgressAlpha or 0) < 1 ) then
		temp.CraftingSkillProgressAlpha = Lerp( FrameTime()*10, (temp.CraftingSkillProgressAlpha or 0), 1 )
	end

    local skillKey = BRICKS_SERVER.TEMP.CraftingSkillProgressKey
    if( not skillKey ) then return end

    local skillInfo = LocalPlayer():GetCraftingSkills()[skillKey]
    if( not skillInfo ) then return end

    local skillDevConfig = BRICKS_SERVER.DEVCONFIG.CraftingSkills[skillKey]

    surface.SetAlphaMultiplier( temp.CraftingSkillProgressAlpha )

    local w, h = ScrW()*0.17, ScrH()*0.05
    local x, y = (ScrW()/2)-(w/2), (ScrH()*0.9)-(h/2)
    local cornerR = BRICKS_SERVER.Func.ScreenScale( 8 )
    local accentH = BRICKS_SERVER.Func.ScreenScale( 5 )

    BRICKS_SERVER.BSHADOWS.BeginShadow()
    draw.RoundedBox( cornerR, x, y, w, h, BRICKS_SERVER.Func.GetTheme( 1 ) )			
    BRICKS_SERVER.BSHADOWS.EndShadow(2, 1, 2, 255, 0, 0, false )

    BRICKS_SERVER.Func.DrawPartialRoundedBoxEx( cornerR, x, y+h-accentH, w, accentH, BRICKS_SERVER.Func.GetTheme( 5 ), w, cornerR*2, false, y+h-(cornerR*2), false, false, true, true )

    local iconSize = BRICKS_SERVER.Func.ScreenScale( 40 )
    local iconSpacing = (h-iconSize)/2

    surface.SetMaterial( skillDevConfig.Icon )
    surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 5 ) )
    surface.DrawTexturedRect( x+iconSpacing, y+iconSpacing, iconSize, iconSize )

    local remainingW = w-(2*h)

    local progressSpacing = BRICKS_SERVER.Func.ScreenScale( 10 )
    local progressW, progressH = remainingW-(2*progressSpacing), BRICKS_SERVER.Func.ScreenScale( 10 )
    local progressX, progressY = x+(w/2)-(progressW/2), y+h-accentH-BRICKS_SERVER.Func.ScreenScale( 25 )

    temp.CraftingSkillBarProgress = Lerp( FrameTime()*5, (temp.CraftingSkillBarProgress or 0), BRICKS_SERVER.Func.GetCraftingSkillProgress( skillKey, skillInfo[1], skillInfo[2] ) )

    draw.RoundedBox( 5, progressX, progressY, progressW, progressH, BRICKS_SERVER.Func.GetTheme( 2 ) )

    BRICKS_SERVER.Func.DrawRoundedMask( 5, progressX, progressY, progressW, progressH, function()
        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 5 ) )
        surface.DrawRect( progressX, progressY, progressW*temp.CraftingSkillBarProgress, progressH )
    end )

	draw.SimpleText( string.upper( skillKey ), "BRICKS_SERVER_Font18", progressX+(progressW/2), progressY-5, BRICKS_SERVER.Func.GetTheme( 6, 200 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
	draw.SimpleText( "Lvl " .. skillInfo[1], "BRICKS_SERVER_Font17", progressX, progressY-5, BRICKS_SERVER.Func.GetTheme( 6, 100 ), 0, TEXT_ALIGN_BOTTOM )
	draw.SimpleText( "Lvl " .. (skillInfo[1]+1), "BRICKS_SERVER_Font17", progressX+progressW, progressY-5, BRICKS_SERVER.Func.GetTheme( 6, 100 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM )
	draw.SimpleText( math.Round( temp.CraftingSkillBarProgress*100 ) .. "%", "BRICKS_SERVER_Font25", x+w-(h/2), y+(h/2), BRICKS_SERVER.Func.GetTheme( 6, 100 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

    surface.SetAlphaMultiplier( 1 )
end )