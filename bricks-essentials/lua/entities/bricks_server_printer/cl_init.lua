include('shared.lua')

local ownerMat = Material( "materials/bricks_server/owner.png" )
local moneyMat = Material( "materials/bricks_server/currency.png" )
local blackCol = Color( 0, 0, 0 )
function ENT:CreateVGUI()
	if( IsValid( self.printerVGUI )  ) then
		self.printerVGUI:Remove()
	end

	if( not IsValid( self.printerVGUI )  ) then
		local ProgressBars = {}
		table.insert( ProgressBars, { "HP", function() 
			return self:Health()/BRICKS_SERVER.CONFIG.PRINTERS.Tiers[self:GetTier() or 1].Health
		end, BRICKS_SERVER.DEVCONFIG.BaseThemes.Red } )

		table.insert( ProgressBars, { "Ink", function()
			return self:GetInk()/BRICKS_SERVER.CONFIG.PRINTERS.Tiers[self:GetTier() or 1].MaxInk
		end, Color( 100, 100, 100 ) } )

		local printerSlotTable = (BRS_PRINTERS or {})[self:GetSlotID()]
		if( printerSlotTable ) then
			table.insert( ProgressBars, { function() 
				return "Lvl " .. (self:GetLevel() or 1) 
			end, function() 
				return math.Clamp( (printerSlotTable[4] or 0)/BRICKS_SERVER.Func.GetPrinterExpToLevel( (printerSlotTable[3] or 1), (printerSlotTable[3] or 1)+1 ), 0, 1 ) 
			end } )
		end

		self.printerVGUI = vgui.Create( "DPanel" )
		self.printerVGUI:SetPos( 0, 30 )
		self.printerVGUI:SetSize( 388, 172 )
		self.printerVGUI.Paint = function( self2, w, h )
			-- Background
			surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 3 ) )
			surface.DrawRect( 0, 0, w, h )

			surface.SetDrawColor( BRICKS_SERVER.CONFIG.PRINTERS.Tiers[self:GetTier() or 1].ModelColor )
			surface.DrawRect( 0, 0, 5, h )

			-- Title
			draw.SimpleText( string.upper( BRICKS_SERVER.CONFIG.PRINTERS.Tiers[self:GetTier() or 1].Name ) .. " TIER", "BRICKS_SERVER_Font33", 15-1, 3+1, blackCol, 0, 0 )
			draw.SimpleText( string.upper( BRICKS_SERVER.CONFIG.PRINTERS.Tiers[self:GetTier() or 1].Name ) .. " TIER", "BRICKS_SERVER_Font33", 15, 3, BRICKS_SERVER.CONFIG.PRINTERS.Tiers[self:GetTier() or 1].ModelColor, 0, 0 )
			
			local iconSize = 16
			surface.SetMaterial( ownerMat )
			surface.SetDrawColor( 0, 0, 0 )
			surface.DrawTexturedRect( 15-1, 38+1, iconSize, iconSize )
			surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
			surface.DrawTexturedRect( 15, 38, iconSize, iconSize )

			local ownerName = "Unknown"
			if( IsValid( self:Getowning_ent() ) ) then
				ownerName = self:Getowning_ent():Nick()
			end
			
			draw.SimpleText( ownerName, "BRICKS_SERVER_Font30", 15-1+iconSize+5, 37+(iconSize/2)+1, blackCol, 0, TEXT_ALIGN_CENTER )
			draw.SimpleText( ownerName, "BRICKS_SERVER_Font30", 15+iconSize+5, 37+(iconSize/2), BRICKS_SERVER.Func.GetTheme( 6 ), 0, TEXT_ALIGN_CENTER )

			-- Money
			surface.SetMaterial( moneyMat )
			surface.SetDrawColor( 0, 0, 0 )
			surface.DrawTexturedRect( 15-1, 38+iconSize+8+1, iconSize, iconSize )
			surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
			surface.DrawTexturedRect( 15, 38+iconSize+8, iconSize, iconSize )

			local StorageAmount = BRICKS_SERVER.CONFIG.PRINTERS.Tiers[self:GetTier() or 1].MoneyStorage
			local MoneyCol = HSVToColor( 140-(140*(self:GetHolding()/(StorageAmount))), 1, 1 )

			draw.SimpleText( DarkRP.formatMoney( self:GetHolding() ), "BRICKS_SERVER_Font30", 15-1+iconSize+5, 38+iconSize+8+(iconSize/2)+1, blackCol, 0, TEXT_ALIGN_CENTER )
			draw.SimpleText( DarkRP.formatMoney( self:GetHolding() ), "BRICKS_SERVER_Font30", 15+iconSize+5, 38+iconSize+8+(iconSize/2), MoneyCol, 0, TEXT_ALIGN_CENTER )
		end

		-- Progress Bars
		local width, height = self.printerVGUI:GetSize()
		local Spacing = 10
		local Tall = 20
		local radius = 35
		local yStartPos = height-radius-15
		local xStartPos = (width/2)-(#ProgressBars-1)*(Spacing+radius)
		for k, v in pairs( ProgressBars ) do
			local xPos, yPos = xStartPos+((k-1)*(Spacing+(radius*2))), yStartPos
			if( k == 1 ) then
				xPos, yPos = width-radius-Spacing, Spacing+radius
			elseif( k == 2 ) then
				xPos, yPos = width-radius-Spacing, height-Spacing-radius
			elseif( k == 3 ) then
				xPos, yPos = width-radius-Spacing-(2*radius), height/2
			end

			local progressPanel = vgui.Create( "DPanel", self.printerVGUI )
			progressPanel:SetSize( radius*2, radius*2 )
			progressPanel:SetPos( xPos-radius, yPos-radius )
			progressPanel.Paint = function( self2, w, h )
				--surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 2 ) )
				--draw.NoTexture()
				--BRICKS_SERVER.Func.DrawCircle( w/2, h/2, w/2, 45 )
	
				local decimal = v[2]()

				--BRICKS_SERVER.Func.DrawArc( w/2, h/2, w/2, 2, -90, (360*decimal)-90, v[3] or BRICKS_SERVER.Func.GetTheme( 4 ) )
				
				draw.SimpleText( ((isfunction( v[1] ) and v[1]()) or v[1]), "BRICKS_SERVER_Font24", w/2, h/2+3, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
				draw.SimpleText( math.Round(decimal*100) .. "%", "BRICKS_SERVER_Font20", w/2, h/2-3, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, 0 )
			end
		end

		local nextPageButton = vgui.Create( "DButton", self.printerVGUI )
		nextPageButton:SetSize( 50, 25 )
		nextPageButton:SetPos( (self.printerVGUI:GetWide()/2)-(nextPageButton:GetWide()/2), self.printerVGUI:GetTall()-nextPageButton:GetTall() )
		nextPageButton:SetText( "" )
		local infoPage, upgradeButton
		local upMat = Material( "materials/bricks_server/up.png" )
		nextPageButton.Paint = function( self2, w, h )
			if( not self2.Hovered ) then
				draw.RoundedBoxEx( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ), true, true, false, false )
			else
				draw.RoundedBoxEx( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 5 ), true, true, false, false )
			end

			local iconSize = 24
			surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 3 ) )
			surface.SetMaterial( upMat )
			surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
		end
		nextPageButton.DoClick = function()
			infoPage:SetVisible( true )
			upgradeButton:SetVisible( true )
		end

		local function DrawInfoRow( x, y, text, textCol, icon )
			surface.SetFont( "BRICKS_SERVER_Font24" )
			local textX, textY = surface.GetTextSize( text )

			local iconSize = 16
			surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 6 ) )
			surface.SetMaterial( icon )
			surface.DrawTexturedRect( x-(textX/2)-iconSize-5, y+(textY/2)-(iconSize/2)+1, iconSize, iconSize )

			draw.SimpleText( text, "BRICKS_SERVER_Font24", x, y, textCol, TEXT_ALIGN_CENTER, 0 )
		end

		local amountMat = Material( "materials/bricks_server/money_16.png" )
		local speedMat = Material( "materials/bricks_server/speed_16.png" )
		local storageMat = Material( "materials/bricks_server/storage_16.png" )
		local function DrawTierInfo( x, y, tier, previousTier )
			local previousTierTable = BRICKS_SERVER.CONFIG.PRINTERS.Tiers[previousTier]
			local tierTable = BRICKS_SERVER.CONFIG.PRINTERS.Tiers[tier]

			if( not tierTable ) then return end

			draw.SimpleText( string.upper( tierTable.Name ), "BRICKS_SERVER_Font33", x-1, y+1, blackCol, TEXT_ALIGN_CENTER, 0 )
			draw.SimpleText( string.upper( tierTable.Name ), "BRICKS_SERVER_Font33", x, y, tierTable.ModelColor, TEXT_ALIGN_CENTER, 0 )

			local amountColor = BRICKS_SERVER.Func.GetTheme( 6 )
			if( previousTierTable ) then
				amountColor = (tierTable.PrintAmount > previousTierTable.PrintAmount and BRICKS_SERVER.DEVCONFIG.BaseThemes.Green) or BRICKS_SERVER.DEVCONFIG.BaseThemes.Red
			end

			DrawInfoRow( x, y+30, DarkRP.formatMoney( tierTable.PrintAmount or 0 ), amountColor, amountMat )

			local speedColor = BRICKS_SERVER.Func.GetTheme( 6 )
			if( previousTierTable ) then
				speedColor = (tierTable.PrintSpeed < previousTierTable.PrintSpeed and BRICKS_SERVER.DEVCONFIG.BaseThemes.Green) or BRICKS_SERVER.DEVCONFIG.BaseThemes.Red
			end

			DrawInfoRow( x, y+55, (tierTable.PrintSpeed or 0), speedColor, speedMat )

			local storageColor = BRICKS_SERVER.Func.GetTheme( 6 )
			if( previousTierTable ) then
				storageColor = (tierTable.MoneyStorage > previousTierTable.MoneyStorage and BRICKS_SERVER.DEVCONFIG.BaseThemes.Green) or BRICKS_SERVER.DEVCONFIG.BaseThemes.Red
			end

			DrawInfoRow( x, y+80, DarkRP.formatMoney( tierTable.MoneyStorage or 0 ), storageColor, storageMat )
		end

		infoPage = vgui.Create( "DPanel", self.printerVGUI )
		infoPage:SetSize( self.printerVGUI:GetWide(), self.printerVGUI:GetTall() )
		infoPage:SetPos( 0, 0 )
		infoPage:SetVisible( false )
		local compareMat = Material( "materials/bricks_server/compare.png" )
		infoPage.Paint = function( self2, w, h )
			surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 3 ) )
			surface.DrawRect( 0, 0, w, h )

			local currentTierTable = BRICKS_SERVER.CONFIG.PRINTERS.Tiers[self:GetTier() or 1]
			surface.SetDrawColor( currentTierTable.ModelColor )
			surface.DrawRect( 0, 0, 5, h )

			DrawTierInfo( w/4, 30, self:GetTier() or 1 )
			
			local nextTierTable = BRICKS_SERVER.CONFIG.PRINTERS.Tiers[(self:GetTier() or 1)+1]
			if( nextTierTable ) then
				local iconSize = 24
				surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 5 ) )
				surface.SetMaterial( compareMat )
				surface.DrawTexturedRect( (w/2)-(iconSize/2), 30+((h-30)/2)-(iconSize/2), iconSize, iconSize )

				DrawTierInfo( w-(w/4), 30, (self:GetTier() or 1)+1, self:GetTier() or 1 )
			end
		end

		local lastPageButton = vgui.Create( "DButton", self.printerVGUI )
		lastPageButton:SetSize( 50, 25 )
		lastPageButton:SetPos( (self.printerVGUI:GetWide()/2)-(lastPageButton:GetWide()/2), 0 )
		lastPageButton:SetText( "" )
		local downMat = Material( "materials/bricks_server/down.png" )
		lastPageButton.Paint = function( self2, w, h )
			if( not infoPage:IsVisible() ) then return end

			if( not self2.Hovered ) then
				draw.RoundedBoxEx( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ), false, false, true, true )
			else
				draw.RoundedBoxEx( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 5 ), false, false, true, true )
			end

			local iconSize = 24
			surface.SetDrawColor( BRICKS_SERVER.Func.GetTheme( 3 ) )
			surface.SetMaterial( downMat )
			surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
		end
		lastPageButton.DoClick = function()
			infoPage:SetVisible( false )
			upgradeButton:SetVisible( false )
		end

		upgradeButton = vgui.Create( "DButton", self.printerVGUI )
		upgradeButton:SetSize( 125, 25 )
		upgradeButton:SetPos( (self.printerVGUI:GetWide()/2)-(upgradeButton:GetWide()/2), self.printerVGUI:GetTall()-upgradeButton:GetTall() )
		upgradeButton:SetText( "" )
		upgradeButton:SetVisible( false )
		local downMat = Material( "materials/bricks_server/down.png" )
		upgradeButton.Paint = function( self2, w, h )
			if( not infoPage:IsVisible() ) then return end

			local nextTierTable = BRICKS_SERVER.CONFIG.PRINTERS.Tiers[(self:GetTier() or 1)+1]
			if( not nextTierTable ) then return end

			surface.SetFont( "BRICKS_SERVER_Font17" )
			local textX, textY = surface.GetTextSize( "Upgrade - " .. DarkRP.formatMoney( nextTierTable.UpgradeCost or 0 ) )
			textX = textX+15

			if( w != textX ) then
				upgradeButton:SetSize( textX, 25 )
				upgradeButton:SetPos( (self.printerVGUI:GetWide()/2)-(upgradeButton:GetWide()/2), self.printerVGUI:GetTall()-upgradeButton:GetTall() )
			end

			if( not self2.Hovered ) then
				draw.RoundedBoxEx( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 2 ), true, true, false, false )
			else
				draw.RoundedBoxEx( 5, 0, 0, w, h, BRICKS_SERVER.Func.GetTheme( 1 ), true, true, false, false )
			end

			draw.SimpleText( "Upgrade - " .. DarkRP.formatMoney( nextTierTable.UpgradeCost or 0 ), "BRICKS_SERVER_Font17", w/2, h/2, BRICKS_SERVER.Func.GetTheme( 5 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
		upgradeButton.DoClick = function()
			if( not infoPage:IsVisible() ) then return end

			if( self:GetTier() < #BRICKS_SERVER.CONFIG.PRINTERS.Tiers and self:GetSlotID() ) then
				net.Start( "BRS.Net.PrinterUpgrade" )
					net.WriteUInt( self:GetSlotID(), 8 )
				net.SendToServer()
			end
		end
	end
end

function ENT:OnRemove()
	if( IsValid( self.printerVGUI ) ) then
		self.printerVGUI:Remove()
	end
end

function ENT:Draw()
	self:DrawModel()

	local Distance = LocalPlayer():GetPos():DistToSqr( self:GetPos() )

	if( Distance >= BRICKS_SERVER.CONFIG.GENERAL["3D2D Display Distance"] ) then return end

	if( not IsValid( self.printerVGUI ) ) then
		self:CreateVGUI()
	end

	local Pos = self:GetPos()
	local Ang = self:GetAngles()

	//TOP PANEL
	Ang:RotateAroundAxis(Ang:Up(), 90)
	Ang:RotateAroundAxis(Ang:Up(), 90)
	Ang:RotateAroundAxis(Ang:Forward(), 90)
	Ang:RotateAroundAxis(Ang:Right(), 270)
	Ang:RotateAroundAxis(Ang:Forward(), -73)

	vgui.Start3D2D( Pos+(Ang:Up() * 17.92)-(self:GetRight()*11.05)+(self:GetForward()*5.35), Ang, 0.06 )
		self.printerVGUI:Paint3D2D()
	vgui.End3D2D()
end
