local PANEL = {}

function PANEL:Init()
    self:SetSize( ScrW()*0.5, ScrH()*0.5 )
    self:Center()
    self:MakePopup()
    self:SetTitle( "" )
    self:SetDraggable( false )
    self:ShowCloseButton( false )
    self.headerHeight = 40
    self:DockPadding( 0, self.headerHeight, 0, 0 )

    local closeButton = vgui.Create( "DButton", self )
	local size = 24
	closeButton:SetSize( size, size )
	closeButton:SetPos( self:GetWide()-size-((self.headerHeight-size)/2), (self.headerHeight/2)-(size/2) )
	closeButton:SetText( "" )
    local CloseMat = Material( "materials/bricks_server/close.png" )
    local textColor = BRICKS_SERVER.Func.GetTheme( 6 )
	closeButton.Paint = function( self2, w, h )
		if( self2:IsHovered() and !self2:IsDown() ) then
			surface.SetDrawColor( textColor.r*0.6, textColor.g*0.6, textColor.b*0.6 )
		elseif( self2:IsDown() || self2.m_bSelected ) then
			surface.SetDrawColor( textColor.r*0.8, textColor.g*0.8, textColor.b*0.8 )
		else
			surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 2 ) )
		end

		surface.SetMaterial( CloseMat )
		surface.DrawTexturedRect( 0, 0, w, h )
	end
    closeButton.DoClick = function()
        self:Remove()
    end
end

function PANEL:SetNPCKey( NPCKey, NPCEnt )
    self.NPCKey = NPCKey

    local multiplier = 1
    if( IsValid( NPCEnt ) ) then
        multiplier = NPCEnt:GetNW2Float( "BRS_Launderer_Multiplier", 1 )
    end

    local moneyCarrying = LocalPlayer():GetNW2Int( "BRS_MoneyBagAmount", 0 )
    local convertedMoney = DarkRP.formatMoney( math.ceil( moneyCarrying*multiplier ) )

    surface.SetFont( "BRICKS_SERVER_Font50" )
    local convertedX, convertedY = surface.GetTextSize( convertedMoney )

    local multiplierText = "+" .. math.ceil( (multiplier-1)*100 ) .. "%"
    if( multiplier < 1 ) then
        multiplierText = "-" .. math.ceil( (1-multiplier)*100 ) .. "%"
    end

    surface.SetFont( "BRICKS_SERVER_Font20" )
    local textX, textY = surface.GetTextSize( multiplierText )
    local boxW, boxH = textX+10, textY+5

    local rColor = (multiplier < 1 and BRICKS_SERVER.DEVCONFIG.BaseThemes.Red) or BRICKS_SERVER.DEVCONFIG.BaseThemes.Green
    local backColor = Color( rColor.r, rColor.g, rColor.b, 50 )
    local textColor = Color( rColor.r, rColor.g, rColor.b, 255 )


    local moneyBack = vgui.Create( "DPanel", self )
    moneyBack:SetPos( 0, self.headerHeight )
    moneyBack:SetSize( self:GetWide(), self:GetTall()-self.headerHeight )
    local compareMat = Material( "materials/bricks_server/compare_32.png" )
    moneyBack.Paint = function( self2, w, h )
        draw.SimpleText( DarkRP.formatMoney( moneyCarrying ), "BRICKS_SERVER_Font50", w/3, (h/2), BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
        if( moneyCarrying > 0 ) then
            draw.SimpleText( "Carrying 1 dirty money bag!", "BRICKS_SERVER_Font17", w/3, (h/2), BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, 0 )
        else
            draw.SimpleText( "You aren't carrying any money!", "BRICKS_SERVER_Font17", w/3, (h/2), BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, 0 )
        end

        local iconSize = 32
        surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 5 ) )
        surface.SetMaterial( compareMat )
        surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )

        draw.SimpleText( convertedMoney, "BRICKS_SERVER_Font50", (w/3)*2, (h/2), BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
        draw.SimpleText( "Clean money", "BRICKS_SERVER_Font17", (w/3)*2, (h/2), BRICKS_SERVER.Func.GetTheme( 6 ), TEXT_ALIGN_CENTER, 0 )

        draw.RoundedBox( 5, (w/3)*2+(convertedX/2)+10, (h/2)-(convertedY/2)-(boxH/2)+2, boxW, boxH, backColor )
        draw.SimpleText( multiplierText, "BRICKS_SERVER_Font20", (w/3)*2+(convertedX/2)+10+(boxW/2)-1, (h/2)-(convertedY/2)+2, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end

    local rColor = BRICKS_SERVER.Func.GetTheme( 5 )
    local backColor = Color( rColor.r, rColor.g, rColor.b, 50 )
    local textColor = Color( rColor.r, rColor.g, rColor.b, 255 )

    local convertButton = vgui.Create( "DButton", moneyBack )
    convertButton:SetSize( 100, 40 )
    convertButton:SetPos( (moneyBack:GetWide()/2)-(convertButton:GetWide()/2), ((moneyBack:GetTall()/4)*3)-(convertButton:GetTall()/2) )
    convertButton:SetText( "" )
    local changeAlpha = 0
    convertButton.Paint = function( self2, w, h )
        if( self2:IsDown() ) then
            changeAlpha = 0
        elseif( self2:IsHovered() ) then
            changeAlpha = math.Clamp( changeAlpha+5, 0, 75 )
        else
            changeAlpha = math.Clamp( changeAlpha-5, 0, 75 )
        end

        draw.RoundedBox( 5, 0, 0, w, h, backColor )

        surface.SetAlphaMultiplier( changeAlpha/255 )
        draw.RoundedBox( 5, 0, 0, w, h, backColor )
        surface.SetAlphaMultiplier( 1 )

        draw.SimpleText( "Collect", "BRICKS_SERVER_Font25", w/2, h/2-1, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end
    convertButton.DoClick = function()
        if( moneyCarrying > 0 ) then
            net.Start( "BRS.Net.BankConvertMoney" )
                net.WriteEntity( NPCEnt )
            net.SendToServer()

            self:Remove()
        else
            notification.AddLegacy( "You don't have any money bags on you!", 1, 5 )
        end
    end
end

local rounded = 5
function PANEL:Paint( w, h )
    draw.RoundedBox( rounded, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ) )
    draw.RoundedBoxEx( rounded, 0, 0, w, self.headerHeight, BRICKS_SERVER.Func.GetTheme( 0 ), true, true, false, false )

    if( self.NPCKey ) then
        draw.SimpleText( ((BRICKS_SERVER.CONFIG.NPCS or {})[(self.NPCKey or 0)] or {}).Name, "BRICKS_SERVER_Font30", 10, (self.headerHeight or 40)/2-2, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_CENTER )
    else
        draw.SimpleText( "Money Launderer NPC", "BRICKS_SERVER_Font30", 10, (self.headerHeight or 40)/2-2, BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_CENTER )
    end
end

vgui.Register( "bricks_server_ui_npc_launderer", PANEL, "DFrame" )