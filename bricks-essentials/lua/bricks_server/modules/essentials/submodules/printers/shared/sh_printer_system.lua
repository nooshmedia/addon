function BRICKS_SERVER.Func.GetPrinterExpToLevel( from, to )
	local totalExp = 0

    for i = from, to-1 do
		local levelExp = BRICKS_SERVER.CONFIG.PRINTERS["Original EXP Required"]*(BRICKS_SERVER.CONFIG.PRINTERS["EXP Required Increase"]^(i-1) )
		totalExp = totalExp+levelExp
    end

	return totalExp
end