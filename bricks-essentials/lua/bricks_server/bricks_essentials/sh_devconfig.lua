--[[
    !!WARNING!!
        ALL CONFIG IS DONE INGAME, DONT EDIT ANYTHING HERE
        Type !bricksserver ingame or use the f4menu
    !!WARNING!!
]]--


--[[

    -- DATA FORMATS --
    inventory - main table
        slots
            [1] = item amount (integer)
            [2] = item data (table)

    printers - main table
        slots
            [1] = unlocked (boolean)
            [2] = printer tier (integer)
            [3] = printer level (integer)
            [4] = printer experience (integer)
    
    -- DATA FORMATS - MARKETPLACE --
    BRS_MARKETPLACE
        [1] = amount (integer)
        [2] = current bid (integer)
        [3] = time (integer)
        [4] = start time (integer)
        [5] = inventory item (table)
        [6] = owner steamid64 (string)
        [7] = owner name (string)
        [8] = bidders (table)
        [9] = owner collected (boolean)
        [10] = winner collected (boolean)

]]--

-- Entity Saving --
BRICKS_SERVER.DEVCONFIG.EntityTypes = BRICKS_SERVER.DEVCONFIG.EntityTypes or {}
BRICKS_SERVER.DEVCONFIG.EntityTypes["bricks_server_bank_vault"] = { 
    PrintName = "Bank Vault",
    AngleToSurface = true,
    Placeable = true
}
BRICKS_SERVER.DEVCONFIG.EntityTypes["bricks_server_armory"] = { 
    PrintName = "Armory",
    AngleToPlayer = true,
    Placeable = true
}

-- Boosters --
if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "boosters" ) ) then
    BRICKS_SERVER.DEVCONFIG.BoosterTypes = {}
    if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "levelling" ) ) then
        BRICKS_SERVER.DEVCONFIG.BoosterTypes[1] = { "Experience", "brs_experience_booster" }
    end
    if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "printers" ) ) then
        BRICKS_SERVER.DEVCONFIG.BoosterTypes[2] = { "Printer Experience", "brs_printerexp_booster" }
    end
end

BRICKS_SERVER.DEVCONFIG.INVENTORY = BRICKS_SERVER.DEVCONFIG.INVENTORY or {}

-- Crafting --
if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "crafting" ) ) then
    BRICKS_SERVER.DEVCONFIG.TreeModels = { 
        ["models/props_foliage/tree_deciduous_01a-lod.mdl"] = 12,
        ["models/props_foliage/tree_deciduous_03a.mdl"] = 23,
        ["models/props/cs_militia/tree_large_militia.mdl"] = 22
    }
    BRICKS_SERVER.DEVCONFIG.GarbageModels = { 
        "models/props_junk/garbage128_composite001a.mdl",
        "models/props_junk/garbage128_composite001b.mdl",
        "models/props_junk/garbage128_composite001c.mdl",
        "models/props_junk/garbage128_composite001d.mdl",
    }
    BRICKS_SERVER.DEVCONFIG.CraftingTypes = {
        ["Weapon"] = { 
            ReqInfo = {
                [1] = { "Weapon", "table", "weapons", function( itemTable )
                    if( itemTable.ReqInfo and itemTable.ReqInfo[1] ) then
                        local weaponModel = BRICKS_SERVER.Func.GetWeaponModel( itemTable.ReqInfo[1] )
                        if( weaponModel ) then
                            itemTable.Model = weaponModel
                        end
                    end
                end },
                [2] = { "Amount", "integer" },
                [3] = { "Permanent", "bool" }
            },
            CanCraft = function( ply, reqInfo )
                if( ply:BRS():IsInventoryFull( (reqInfo[2] or 1), true ) ) then
                    return false, "There is not enough space in your inventory!"
                else
                    return true
                end
            end,
            OnCraft = function( ply, reqInfo, itemInfo )
                if( reqInfo[3] ) then
                    ply:BRS():AddInventoryItem( { "spawned_weapon", itemInfo.Model, reqInfo[1], false, true }, (reqInfo[2] or 1) )
                else
                    ply:BRS():AddInventoryItem( { "spawned_weapon", itemInfo.Model, reqInfo[1] }, (reqInfo[2] or 1) )
                end
            end
        },
        ["Entity"] = { 
            ReqInfo = {
                [1] = { "Entity", "table", "entities" }
            },
            CanCraft = function( ply, reqInfo )
                if( ply:BRS():IsInventoryFull( 1 ) ) then
                    return false, "There is not enough space in your inventory!"
                else
                    return true
                end
            end,
            OnCraft = function( ply, reqInfo, itemInfo )
                ply:BRS():AddInventoryItem( { reqInfo[1], itemInfo.Model }, 1 )
            end
        },
        ["Resource"] = { 
            ReqInfo = {
                [1] = { "Resource", "table", "resources", function( itemTable )
                    if( itemTable.ReqInfo and itemTable.ReqInfo[1] and BRICKS_SERVER.CONFIG.CRAFTING.Resources[itemTable.ReqInfo[1]] ) then
                        itemTable.Model = BRICKS_SERVER.CONFIG.CRAFTING.Resources[itemTable.ReqInfo[1]][1]
                        if( BRICKS_SERVER.CONFIG.CRAFTING.Resources[itemTable.ReqInfo[1]][2] ) then
                            itemTable.Color = BRICKS_SERVER.CONFIG.CRAFTING.Resources[itemTable.ReqInfo[1]][2]
                        end
                    end
                end },
                [2] = { "Amount", "integer" }
            },
            CanCraft = function( ply, reqInfo )
                if( ply:BRS():IsInventoryFull( (reqInfo[2] or 1), true ) ) then
                    return false, "There is not enough space in your inventory!"
                else
                    return true
                end
            end,
            OnCraft = function( ply, reqInfo, itemInfo )
                if( not BRICKS_SERVER.CONFIG.CRAFTING.Resources[reqInfo[1] or ""] ) then return false end

                local itemData = { "bricks_server_resource", (BRICKS_SERVER.CONFIG.CRAFTING.Resources[reqInfo[1] or ""][1] or ""), reqInfo[1] }
                ply:BRS():AddInventoryItem( itemData, (reqInfo[2] or 1) )
            end
        },
        ["Booster"] = { 
            ReqInfo = {
                [1] = { "Booster", "table", "boosters" }
            },
            OnCraft = function( ply, reqInfo )
                ply:AddBooster( reqInfo[1] )
            end
        },
        ["Vehicle"] = { 
            ReqInfo = {
                [1] = { "VehicleID", "table", "vehicles" }
            },
            OnCraft = function( ply, reqInfo )
                if( not list.Get( "Vehicles" )[reqInfo[1]] ) then return end

                local CarTable = list.Get( "Vehicles" )[reqInfo[1]]
        
                local carEnt = ents.Create( CarTable.Class )
                carEnt:SetModel( CarTable.Model )
                for k, v in pairs( CarTable.KeyValues or {} ) do
                    carEnt:SetKeyValue( k, v )
                end
                carEnt:SetPos( ply:GetPos()-Vector( 0, 100, 0 ) )
                carEnt:Spawn()
            end
        },
    }

    BRICKS_SERVER.DEVCONFIG.CraftingSkills = {
        ["woodcutting"] = {
            Name = "Wood Cutting",
            Icon = Material( "materials/bricks_server/axe.png", "noclamp smooth" )
        }
    }
end

-- F4 Tabs --
if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "f4menu" ) ) then
    BRICKS_SERVER.DEVCONFIG.F4Tabs = {}
    BRICKS_SERVER.DEVCONFIG.F4Tabs[1] = { "Jobs", "bricks_server_f4_jobs" }
    BRICKS_SERVER.DEVCONFIG.F4Tabs[2] = { "Shop", "bricks_server_f4_shop" }

    if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "inventory" ) ) then
        BRICKS_SERVER.DEVCONFIG.F4Tabs[3] = { "Inventory", "bricks_server_inventory_grid", function( page ) page:DockMargin( 10, 10, 10, 10 ) end }
    end

    if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "printers" ) ) then
        BRICKS_SERVER.DEVCONFIG.F4Tabs[4] = { "Printers", "bricks_server_f4_printers", function( page ) page:DockMargin( 10, 10, 10, 10 ) end }
    end

    if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "boosters" ) ) then
        BRICKS_SERVER.DEVCONFIG.F4Tabs[5] = { "Boosters", "bricks_server_f4_boosters", function( page ) page:DockMargin( 10, 10, 10, 10 ) end }
    end

    if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "crafting" ) ) then
        BRICKS_SERVER.DEVCONFIG.F4Tabs[6] = { "Crafting", "bricks_server_f4_crafting" }
    end

    BRICKS_SERVER.DEVCONFIG.F4Tabs[7] = { "Profile", "bricks_server_profile", function( page ) page:DockMargin( 10, 10, 10, 10 ) end }

    if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "logging" ) ) then
        BRICKS_SERVER.DEVCONFIG.F4Tabs[8] = { "Logs", "bricks_server_f4_logs", function( page ) page:DockMargin( 10, 10, 10, 10 ) end }
    end

    if( BRICKS_SERVER.Func.IsModuleEnabled( "coinflip" ) ) then
        BRICKS_SERVER.DEVCONFIG.F4Tabs[9] = { "Coinflip - " .. BRICKS_SERVER.Func.L( "coinflips" ), "bricks_server_coinflip_flips", function( page ) page.panelWide = ScrW()*0.6-BRICKS_SERVER.DEVCONFIG.MainNavWidth end }
        BRICKS_SERVER.DEVCONFIG.F4Tabs[10] = { "Coinflip - " .. BRICKS_SERVER.Func.L( "coinflipHistory" ), "bricks_server_coinflip_history", function( page ) page.panelWide = ScrW()*0.6-BRICKS_SERVER.DEVCONFIG.MainNavWidth end }
    end

    if( BRICKS_SERVER.Func.IsModuleEnabled( "unboxing" ) ) then
        BRICKS_SERVER.DEVCONFIG.F4Tabs[11] = { "Unboxing - Menu", "bricks_server_unboxingmenu_page_version", function( page ) 
            page.pageWide = ScrW()*0.6-(BRICKS_SERVER.DEVCONFIG.MainNavWidth*2)
            page:Refresh()
        end }
    end

    if( BRICKS_SERVER.Func.IsModuleEnabled( "gangs" ) ) then
        BRICKS_SERVER.DEVCONFIG.F4Tabs[12] = { "Gangs - Menu", "bricks_server_gangmenu_page_version", function( page ) 
            page.pageWide = ScrW()*0.6-(BRICKS_SERVER.DEVCONFIG.MainNavWidth*2)
            page:RefreshGang()
        end }
    end
end

-- NPCS --
BRICKS_SERVER.DEVCONFIG.NPCTypes = BRICKS_SERVER.DEVCONFIG.NPCTypes or {}

if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "marketplace" ) ) then
    BRICKS_SERVER.DEVCONFIG.NPCTypes["Marketplace"] = {
        UseFunction = function( ply, ent, NPCKey )
            net.Start( "BRS.Net.OpenMarketplace" )
                net.WriteTable( BRS_MARKETPLACE or {} )
            net.Send( ply )

            if( not BRS_PLYSIN_MARKETPLACE ) then
                BRS_PLYSIN_MARKETPLACE = {}
            end
            BRS_PLYSIN_MARKETPLACE[ply] = true
        end
    }
end

if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "inventory" ) ) then
    BRICKS_SERVER.DEVCONFIG.NPCTypes["Trader"] = {
        ReqInfo = {
            [1] = { "Currency", "table", "currencies" }
        },
        UseFunction = function( ply, ent, NPCKey )
            net.Start( "BRS.Net.UseTraderNPC" )
                net.WriteUInt( NPCKey, 8 )
            net.Send( ply )
        end,
        TypeDataName = "Items",
        TypeDataFunction = function( NPCKey, NPCTable )
            if( BRICKS_SERVER.DEVCONFIG.NPCTypes[(NPCTable.Type or "")] ) then
                if( not IsValid( BRICKS_SERVER_NPC_TRADER ) ) then
                    BRICKS_SERVER_NPC_TRADER = vgui.Create( "bricks_server_ui_npc_trader" )
                    BRICKS_SERVER_NPC_TRADER:SetNPCKey( NPCKey, true, NPCTable )
                end
            end
        end,
        BuyingTypes = {
            ["Resource"] = {
                ReqInfo = {
                    [1] = { "Resource", "table", "resources", function( itemTable )
                        if( itemTable.ReqInfo and itemTable.ReqInfo[1] and BRICKS_SERVER.CONFIG.CRAFTING.Resources[itemTable.ReqInfo[1]] ) then
                            itemTable.Model = BRICKS_SERVER.CONFIG.CRAFTING.Resources[itemTable.ReqInfo[1]][1]
                            if( BRICKS_SERVER.CONFIG.CRAFTING.Resources[itemTable.ReqInfo[1]][2] ) then
                                itemTable.ModelColor = BRICKS_SERVER.CONFIG.CRAFTING.Resources[itemTable.ReqInfo[1]][2]
                            end
                        end
                    end }
                },
                FormatName = function( reqInfo )
                    return reqInfo[1]
                end,
                SlotSameAsRequired = function( slotInfo, reqInfo )
                    if( slotInfo[3] and slotInfo[3] == reqInfo[1] ) then return true end
                end
            }
        },
        SellingTypes = {
            ["Resource"] = {
                ReqInfo = {
                    [1] = { "Resource", "table", "resources", function( itemTable )
                        if( itemTable.ReqInfo and itemTable.ReqInfo[1] and BRICKS_SERVER.CONFIG.CRAFTING.Resources[itemTable.ReqInfo[1]] ) then
                            itemTable.Model = BRICKS_SERVER.CONFIG.CRAFTING.Resources[itemTable.ReqInfo[1]][1]
                            if( BRICKS_SERVER.CONFIG.CRAFTING.Resources[itemTable.ReqInfo[1]][2] ) then
                                itemTable.ModelColor = BRICKS_SERVER.CONFIG.CRAFTING.Resources[itemTable.ReqInfo[1]][2]
                            end
                        end
                    end }
                },
                FormatName = function( reqInfo )
                    return reqInfo[1]
                end,
                SlotSameAsRequired = function( slotInfo, reqInfo )
                    if( slotInfo[3] and slotInfo[3] == reqInfo[1] ) then return true end
                end,
                GiveItem = function( ply, reqInfo, amount, itemTable )
                    if( not BRICKS_SERVER.CONFIG.CRAFTING.Resources[reqInfo[1] or ""] ) then return false end
                    
                    if( ply:BRS():IsInventoryFull( amount, true ) ) then return false, "There is not enough space in your inventory!" end

                    local itemData = { "bricks_server_resource", (BRICKS_SERVER.CONFIG.CRAFTING.Resources[reqInfo[1] or ""][1] or ""), reqInfo[1] }
                    ply:BRS():AddInventoryItem( itemData, (amount or 1) )
                end
            },
            ["Weapon"] = {
                ReqInfo = {
                    [1] = { "Weapon", "table", "weapons", function( itemTable )
                        if( itemTable.ReqInfo and itemTable.ReqInfo[1] ) then
                            local weaponModel = BRICKS_SERVER.Func.GetWeaponModel( itemTable.ReqInfo[1] )
                            if( weaponModel ) then
                                itemTable.Model = weaponModel
                            end
                        end
                    end },
                    [2] = { "Permanent", "bool" }
                },
                FormatName = function( reqInfo )
                    return (list.Get( "Weapon" )[reqInfo[1]] or {}).PrintName or "Weapon"
                end,
                SlotSameAsRequired = function( slotInfo, reqInfo )
                    if( slotInfo[3] and slotInfo[3] == reqInfo[1] ) then return true end
                end,
                GiveItem = function( ply, reqInfo, amount, itemTable )
                    if( not list.Get( "Weapon" )[reqInfo[1] or ""] ) then return false end
                    
                    if( ply:BRS():IsInventoryFull( amount, true ) ) then return false, "There is not enough space in your inventory!" end

                    local itemData = { "spawned_weapon", (itemTable.Model or ""), reqInfo[1] }
                    if( weapons.GetStored( reqInfo[1] ) and weapons.GetStored( reqInfo[1] ).WorldModel ) then
                        itemData[2] = weapons.GetStored( reqInfo[1] ).WorldModel
                    end
                    
                    if( reqInfo[2] ) then
                        itemData[5] = true
                    end

                    ply:BRS():AddInventoryItem( itemData, (amount or 1) )
                end
            },
            ["Entity"] = { 
                ReqInfo = {
                    [1] = { "Entity", "table", "entities" }
                },
                FormatName = function( reqInfo )
                    return (list.Get( "SpawnableEntities" )[reqInfo[1]] or {}).PrintName or reqInfo[1]
                end,
                SlotSameAsRequired = function( slotInfo, reqInfo )
                    if( slotInfo[1] and slotInfo[1] == reqInfo[1] ) then return true end
                end,
                GiveItem = function( ply, reqInfo, amount, itemTable )
                    if( ply:BRS():IsInventoryFull( amount, true ) ) then return false, "There is not enough space in your inventory!" end

                    ply:BRS():AddInventoryItem( { reqInfo[1], itemTable.Model }, (amount or 1) )
                end
            }
        }
    }

    BRICKS_SERVER.DEVCONFIG.NPCTypes["Bank"] = {
        UseFunction = function( ply, ent, NPCKey )
            net.Start( "BRS.Net.UseBankNPC" )
                net.WriteUInt( NPCKey, 8 )
            net.Send( ply )
        end
    }
end

if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "deathscreens" ) ) then
    BRICKS_SERVER.DEVCONFIG.NPCTypes["Deathscreens"] = {
        UseFunction = function( ply, ent, NPCKey )
            net.Start( "BRS.Net.UseDeathscreens" )
                net.WriteUInt( NPCKey, 8 )
            net.Send( ply )
        end
    }
end

if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "swepupgrader" ) ) then
    BRICKS_SERVER.DEVCONFIG.NPCTypes["SWEP Upgrader"] = {
        UseFunction = function( ply, ent, NPCKey )
            net.Start( "BRS.Net.UseSWEPUpgrader" )
                net.WriteUInt( NPCKey, 8 )
            net.Send( ply )
        end
    }
end

if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "crafting" ) ) then
    BRICKS_SERVER.DEVCONFIG.NPCTypes["Crafting"] = {
        ReqInfo = {},
        UseFunction = function( ply, ent, NPCKey )
            net.Start( "BRS.Net.UseMenuNPC" )
                net.WriteString( "bricks_server_f4_crafting" )
                net.WriteString( "Crafting" )
            net.Send( ply )
        end
    }
end

BRICKS_SERVER.DEVCONFIG.NPCTypes["Money Launderer"] = {
    OnSpawn = function( ent, NPCKey )
        local multiplierLower = (BRICKS_SERVER.CONFIG.BANKVAULT["Dirty To Clean Money Multiplier"] or {})[1] or 0.9
        local multiplierUpper = (BRICKS_SERVER.CONFIG.BANKVAULT["Dirty To Clean Money Multiplier"] or {})[2] or 1.1

        ent:SetNW2Float( "BRS_Launderer_Multiplier", math.Rand( multiplierLower, multiplierUpper ) )
    end,
    UseFunction = function( ply, ent, NPCKey )
        net.Start( "BRS.Net.UseMoneyLaunderer" )
            net.WriteUInt( NPCKey, 8 )
            net.WriteEntity( ent )
        net.Send( ply )
    end
}

-- Logging --
if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "logging" ) ) then
    BRICKS_SERVER.DEVCONFIG.LogTypes = {
        ["Experience"] = {
            ReqInfo = {
                [1] = { "Reason", "string" },
                [2] = { "Amount", "integer" }
            },
            FormatInfo = function( reqInfo )
                if( reqInfo[2] and isnumber( reqInfo[2] ) ) then
                    return string.Comma( math.floor( reqInfo[2] or 0 ) ) .. " EXP Gained - " .. (reqInfo[1] or "NIL")
                else
                    return 0 .. " EXP Gained - " .. (reqInfo[1] or "NIL")
                end
            end,
            CanCombine = function( reqInfo1, reqInfo2 )
                if( (reqInfo1[1] or "") == (reqInfo2[1] or "") ) then return true end
            end,
            Combine = function( reqInfo1, reqInfo2 )
                return { (reqInfo1[1] or "NIL"), (reqInfo1[2] or 0)+(reqInfo2[2] or 0) }
            end,
        },
        ["BossReward"] = {
            ReqInfo = {
                [1] = { "BossName", "string" },
                [2] = { "Damage", "integer" },
                [3] = { "Rewards", "table" }
            },
            FormatInfo = function( reqInfo )
                local rewardString = "None"
                for k, v in pairs( reqInfo[3] or {} ) do
                    if( not isstring( v ) ) then continue end

                    if( rewardString == "None" ) then
                        rewardString = v
                    else
                        rewardString = rewardString .. ", " .. v
                    end
                end
                return BRICKS_SERVER.Func.formatHealth(reqInfo[2] or 0) .. " damage dealt to " .. (reqInfo[1] or "BOSS") .. ", Rewards: " .. rewardString
            end
        }
    }
end

-- Boss -- 
if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "boss" ) ) then
    BRICKS_SERVER.DEVCONFIG.SpawnTimes = {
        ["Once"] = 0,
        ["1 Minute"] = 60,
        ["5 Minutes"] = 300,
        ["10 Minutes"] = 600,
        ["15 Minutes"] = 900,
        ["30 Minutes"] = 1800,
        ["60 Minutes"] = 3600,
    }
    BRICKS_SERVER.DEVCONFIG.LootTypes = {
        ["Weapon"] = { 
            ReqInfo = {
                [1] = { "Weapon", "table", "weapons", function( itemTable )
                    if( itemTable.ReqInfo and itemTable.ReqInfo[1] ) then
                        local weaponModel = BRICKS_SERVER.Func.GetWeaponModel( itemTable.ReqInfo[1] )
                        if( weaponModel ) then
                            itemTable.Model = weaponModel
                        end
                    end
                end },
                [2] = { "Amount", "integer" },
                [3] = { "Permanent", "bool" }
            },
            GiveFunction = function( ply, reqInfo, itemInfo )
                if( reqInfo[3] ) then
                    ply:BRS():AddInventoryItem( { "spawned_weapon", itemInfo.Model, reqInfo[1], false, true }, (reqInfo[2] or 1) )
                else
                    ply:BRS():AddInventoryItem( { "spawned_weapon", itemInfo.Model, reqInfo[1] }, (reqInfo[2] or 1) )
                end
            end
        },
        ["Resource"] = { 
            ReqInfo = {
                [1] = { "Resource", "table", "resources", function( itemTable )
                    if( itemTable.ReqInfo and itemTable.ReqInfo[1] and BRICKS_SERVER.CONFIG.CRAFTING.Resources[itemTable.ReqInfo[1]] ) then
                        itemTable.Model = BRICKS_SERVER.CONFIG.CRAFTING.Resources[itemTable.ReqInfo[1]][1]
                        if( BRICKS_SERVER.CONFIG.CRAFTING.Resources[itemTable.ReqInfo[1]][2] ) then
                            itemTable.ModelColor = BRICKS_SERVER.CONFIG.CRAFTING.Resources[itemTable.ReqInfo[1]][2]
                        end
                    end
                end },
                [2] = { "Amount", "integer" }
            },
            GiveFunction = function( ply, reqInfo, itemInfo )
                if( not BRICKS_SERVER.CONFIG.CRAFTING.Resources[reqInfo[1] or ""] ) then return false end

                local itemData = { "bricks_server_resource", (BRICKS_SERVER.CONFIG.CRAFTING.Resources[reqInfo[1] or ""][1] or ""), reqInfo[1] }
                ply:BRS():AddInventoryItem( itemData, (reqInfo[2] or 1) )
            end
        },
        ["Money"] = { 
            ReqInfo = {
                [1] = { "Amount", "integer" }
            },
            GiveFunction = function( ply, reqInfo, itemInfo )
                ply:addMoney( reqInfo[1] )
            end
        },
        ["Entity"] = { 
            ReqInfo = {
                [1] = { "Entity", "table", "entities" },
                [2] = { "Amount", "integer" }
            },
            GiveFunction = function( ply, reqInfo, itemInfo )
                if( ply:BRS():IsInventoryFull( (reqInfo[2] or 1), true ) ) then return false, "There is not enough space in your inventory!" end

                ply:BRS():AddInventoryItem( { reqInfo[1], (itemInfo.Model or "") }, (reqInfo[2] or 1) )
            end
        }
    }

    if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "levelling" ) ) then
        BRICKS_SERVER.DEVCONFIG.LootTypes["Experience"] = { 
            ReqInfo = {
                [1] = { "Amount", "integer" }
            },
            GiveFunction = function( ply, reqInfo, itemInfo )
                ply:AddExperience( reqInfo[1], "Loot" )
            end
        }
    end
end

-- Armory --
BRICKS_SERVER.DEVCONFIG.ArmoryTypes = {
    ["Weapon"] = {
        ReqInfo = {
            [1] = { "Weapon", "table", "weapons", function( itemTable )
                if( itemTable.ReqInfo and itemTable.ReqInfo[1] ) then
                    local weaponModel = BRICKS_SERVER.Func.GetWeaponModel( itemTable.ReqInfo[1] )
                    if( weaponModel ) then
                        itemTable.Model = weaponModel
                    end
                end
            end }
        },
        GiveItem = function( ply, reqInfo )
            if( ply:HasWeapon( reqInfo[1] or "" ) ) then
                ply:SelectWeapon( reqInfo[1] or "" )
                return false, "You already have this weapon equipped!"
            end

            ply:Give( reqInfo[1] or "" )
            ply:SelectWeapon( reqInfo[1] or "" )
        end
    },
    ["Ammo"] = {
        ReqInfo = {
            [1] = { "Ammo Type", "table", "ammo" },
            [2] = { "Amount", "integer" },
            [3] = { "Max Ammo", "integer" }
        },
        GetDisplayInfo = function( reqInfo )
            return { "Amount: " .. (reqInfo[2] or 0) }
        end,
        GiveItem = function( ply, reqInfo )
            if( ply:GetAmmoCount( reqInfo[1] or "" ) >= (reqInfo[3] or 0) ) then 
                return false, "You already have the max ammo of this type!"
            end

            ply:GiveAmmo( (reqInfo[2] or 0), (reqInfo[1] or "") )
        end
    },
    ["Armor"] = {
        ReqInfo = {
            [1] = { "Amount", "integer" }
        },
        GetDisplayInfo = function( reqInfo )
            return { "Amount: " .. (reqInfo[1] or 0) }
        end,
        GiveItem = function( ply, reqInfo )
            if( ply:Armor() >= (reqInfo[1] or 0) ) then
                return false, "You already have the max armor!"
            end

            ply:SetArmor( reqInfo[1] or 0 )
        end
    }
}

-- Zones --
if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "zones" ) ) then
    BRICKS_SERVER.DEVCONFIG.ZoneTypes = {
        ["Box"] = {
            Points = 2,
            SetupZoneEnt = function( ent, points, size )
                local point1Pos, point2Pos, cubeTall = points[1], points[2], size
                ent:SetPos( Vector( point1Pos[1]+point2Pos[1], point1Pos[2]+point2Pos[2], point1Pos[3]+point2Pos[3] )/2 )

                local point1PosWL = ent:WorldToLocal( point1Pos )
                local point2PosWL = ent:WorldToLocal( point2Pos )
            
                OrderVectors( point1PosWL, point2PosWL )
            
                ent:SetCollisionBounds( point1PosWL, point2PosWL+Vector( 0, 0, cubeTall ) )
            end
        },
        ["Sphere"] = {
            Points = 1,
            SetupZoneEnt = function( ent, points, size )
                ent:SetPos( points[1] )
                local radiusPos = Vector( size, size, size )
                ent:SetCollisionBounds( -radiusPos, radiusPos )
            end
        }
    }
end

-- SWEP Upgrader --
if( BRICKS_SERVER.Func.IsSubModuleEnabled( "essentials", "swepupgrader" ) ) then
    BRICKS_SERVER.DEVCONFIG.SWEPUpgradeTypes = {
        ["Damage"] = {
            SetFunc = function( weaponEnt, multiplier )
                weaponEnt:BRS_SetVariable( "Damage", math.ceil( (weaponEnt:BRS_GetVariableValue( "Damage" ) or 0)*(1+(multiplier or 0)) ) )
            end
        },
        ["ClipSize"] = {
            SetFunc = function( weaponEnt, multiplier )
                weaponEnt:BRS_SetVariable( "ClipSize", math.ceil( (weaponEnt:BRS_GetVariableValue( "ClipSize" ) or 0)*(1+(multiplier or 0)) ) )
            end
        },
        ["Recoil"] = {
            SetFunc = function( weaponEnt, multiplier )
                weaponEnt:BRS_SetVariable( "Recoil", (weaponEnt:BRS_GetVariableValue( "Recoil" ) or 0)*(1-(multiplier or 0)) )
            end
        }
    }
end