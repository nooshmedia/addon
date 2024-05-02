function BRICKS_SERVER.Func.GetExpToLevel( from, to )
    local totalExp = 0

    for i = 0, (to-from)-1 do
        local levelExp = BRICKS_SERVER.CONFIG.LEVELING["Original EXP Required"]*(BRICKS_SERVER.CONFIG.LEVELING["EXP Required Increase"]^(from+i) )
        totalExp = totalExp+levelExp
    end

    return totalExp
end

function BRICKS_SERVER.Func.GetCurLevelExp( ply )
    local level = (ply.BRS_LEVEL or BRS_LEVEL) or 0

    local experience = ply.BRS_EXPERIENCE or BRS_EXPERIENCE

    local totalOldExp = BRICKS_SERVER.Func.GetExpToLevel( 0, level )

    return experience-totalOldExp
end