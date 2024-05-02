function BRICKS_SERVER.Func.GetInventorySlots( ply )
	if( not IsValid( ply ) ) then return 0 end

	for k, v in ipairs( BRICKS_SERVER.CONFIG.GENERAL.Groups ) do
		if( (BRICKS_SERVER.CONFIG.INVENTORY["Inventory Slots"] or {})[v[1]] and BRICKS_SERVER.Func.IsInGroup( ply, v[1] ) ) then
			return (BRICKS_SERVER.CONFIG.INVENTORY["Inventory Slots"] or {})[v[1]]
		end
	end

	return (BRICKS_SERVER.CONFIG.INVENTORY["Inventory Slots"] or {})["Default"] or 0
end

function BRICKS_SERVER.Func.GetBankSlots( ply )
	if( not IsValid( ply ) ) then return end

	for k, v in ipairs( BRICKS_SERVER.CONFIG.GENERAL.Groups ) do
		if( (BRICKS_SERVER.CONFIG.INVENTORY["Bank Slots"] or {})[v[1]] and BRICKS_SERVER.Func.IsInGroup( ply, v[1] ) ) then
			return (BRICKS_SERVER.CONFIG.INVENTORY["Bank Slots"] or {})[v[1]]
		end
	end

	return (BRICKS_SERVER.CONFIG.INVENTORY["Bank Slots"] or {})["Default"] or 0
end

function BRICKS_SERVER.PLAYERMETA:GetInventory()
	return self.Inventory or {}
end