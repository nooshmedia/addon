hook.Add("sP:Withdrawn", "sP:LevelingSupport", function(ply, ent, amount, rack)
    if ent.data and ent.data.xpmultiplier and !IsValid(rack) then
        if ply.addExp then
            ply:addExp(amount * ent.data.xpmultiplier)
        end
    end
end)

hook.Add("sP:WithdrawnRack", "sP:LevelingSupport", function(ply, ent, amount, total_xp)
    if ply.addExp and total_xp > 0 then
        ply:addExp(total_xp)
    end
end)