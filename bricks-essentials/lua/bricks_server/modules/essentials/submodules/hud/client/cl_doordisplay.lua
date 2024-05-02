hook.Add( "HUDPaint", "BRS.HUDPaint_DrawDoorHUD", function()
    local localPly = LocalPlayer()

    local ent = localPly:GetEyeTrace().Entity
    if IsValid(ent) and ent:isKeysOwnable() and ent:GetPos():DistToSqr(localPly:GetPos()) < 40000 then
        ent:drawOwnableInfo()
    end
end )