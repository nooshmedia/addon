local ITEM = BRICKS_SERVER.Func.CreateItemType( "bricks_server_resource*" )

ITEM.GetItemData = function( ent )
    if( not IsValid( ent ) ) then return end
    
    local itemData = { "bricks_server_resource", ent:GetModel(), (ent.GetResourceType and ent:GetResourceType()) or "" }

    return itemData, ((ent.GetAmount and ent:GetAmount()) or 1)
end

ITEM.CanDropMultiple = true

ITEM.OnSpawn = function( ply, pos, itemData, itemAmount )
    local ent = ents.Create( "bricks_server_resource_" .. string.Replace( string.lower( itemData[3] or "" ), " ", "" ) )
    if( not IsValid( ent ) ) then return end
    ent:SetPos( pos )
    ent:Spawn()
    ent:SetAmount( itemAmount or 1 )
    ent.ResourceType = itemData[3]
end

ITEM.GetInfo = function( itemData )
    local itemDescription = "Crafting resource."
    if( BRICKS_SERVER.ESSENTIALS.LUACFG.ItemDescriptions and BRICKS_SERVER.ESSENTIALS.LUACFG.ItemDescriptions[(itemData[3] or "")] ) then
        itemDescription = BRICKS_SERVER.ESSENTIALS.LUACFG.ItemDescriptions[(itemData[3] or "")]
    end

    return { (itemData[3] or "Unknown"), itemDescription, (BRICKS_SERVER.CONFIG.INVENTORY.ItemRarities or {})[itemData[3] or ""] }
end

ITEM.GetItemKey = function( itemData )
    return itemData[3] or ""
end

ITEM.GetPotentialItems = function()
    local potentialItems = {}
    for k, v in pairs( BRICKS_SERVER.CONFIG.CRAFTING.Resources ) do
        potentialItems[k] = {
            Name = k,
            Model = v[1],
            ItemKey = k
        }
    end

    return potentialItems
end

ITEM.ModelDisplay = function( Panel, itemtable )
    if( not Panel.Entity or not IsValid( Panel.Entity ) ) then return end
    
    local mn, mx = Panel.Entity:GetRenderBounds()
    local size = 0
    size = math.max( size, math.abs(mn.x) + math.abs(mx.x) )
    size = math.max( size, math.abs(mn.y) + math.abs(mx.y) )
    size = math.max( size, math.abs(mn.z) + math.abs(mx.z) )

    Panel:SetFOV( 70 )
    Panel:SetCamPos( Vector( size, size, size ) )
    Panel:SetLookAt( (mn + mx) * 0.5 )

    if( BRICKS_SERVER.CONFIG.CRAFTING.Resources[itemtable[3]] and BRICKS_SERVER.CONFIG.CRAFTING.Resources[itemtable[3]][2] ) then
        Panel:SetColor( BRICKS_SERVER.CONFIG.CRAFTING.Resources[itemtable[3]][2] )
    end
end

ITEM.CanCombine = function( itemData1, itemData2 )
    if( itemData1[1] == itemData2[1] and itemData1[3] and itemData2[3] and itemData1[3] == itemData2[3] ) then
        return true
    end

    return false
end

ITEM:Register()