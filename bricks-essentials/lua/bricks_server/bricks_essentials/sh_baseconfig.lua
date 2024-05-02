--[[
    !!WARNING!!
        ALL CONFIG IS DONE INGAME, DONT EDIT ANYTHING HERE
        Type !bricksserver ingame or use the f4menu
    !!WARNING!!
]]--

--[[ MODULES CONFIG ]]--
BRICKS_SERVER.BASECONFIG.MODULES = BRICKS_SERVER.BASECONFIG.MODULES or {}
BRICKS_SERVER.BASECONFIG.MODULES["essentials"] = { true, {
    ["boosters"] = true,
    ["boss"] = true,
    ["crafting"] = true,
    ["deathscreens"] = true,
    ["f4menu"] = true,
    ["hud"] = true,
    ["inventory"] = true,
    ["levelling"] = true,
    ["logging"] = true,
    ["marketplace"] = true,
    ["printers"] = true,
    ["swepupgrader"] = true,
    ["zones"] = true
} }

--[[ GENERAL CONFIG ]]--
BRICKS_SERVER.BASECONFIG.GENERAL = BRICKS_SERVER.BASECONFIG.GENERAL or {}
BRICKS_SERVER.BASECONFIG.GENERAL["F4 Use Spawn Icons"] = false
BRICKS_SERVER.BASECONFIG.GENERAL["Client Logs Limit"] = 100
BRICKS_SERVER.BASECONFIG.GENERAL.JobGroups = {}
BRICKS_SERVER.BASECONFIG.GENERAL.EntityGroups = {}
BRICKS_SERVER.BASECONFIG.GENERAL.ShipmentGroups = {}
BRICKS_SERVER.BASECONFIG.GENERAL.AmmoGroups = {}

--[[ F4 CONFIG ]]--
BRICKS_SERVER.BASECONFIG.F4 = {}
BRICKS_SERVER.BASECONFIG.F4.Tabs = {
    [1] = { "Jobs", "jobs_24.png", 1 },
    [2] = { "Shop", "shop_24.png", 2 },
    [3] = { "Inventory", "inventory_24.png", { 
        { "Main", 3 }, 
        { "Printers", 4 }, 
        { "Boosters", 5 }
    } },
    [4] = { "Crafting", "crafting_24.png", 6 },
    [5] = { "Profile", "profile_24.png", { 
        { "Statistics", 7 }, 
        { "Logs", 8 }
    } },
    [6] = { true },
    [7] = { "Discord", "discord_24.png", "https://discord.gg/crBpKpR" },
    [8] = { "Donate", "donate_24.png", "https://www.blackrockgaming.co.uk/donate" },
}

--[[ LEVELING ]]--
BRICKS_SERVER.BASECONFIG.LEVELING = {}
BRICKS_SERVER.BASECONFIG.LEVELING["Max Level"] = 100
BRICKS_SERVER.BASECONFIG.LEVELING["Original EXP Required"] = 150
BRICKS_SERVER.BASECONFIG.LEVELING["EXP Required Increase"] = 1.1
BRICKS_SERVER.BASECONFIG.LEVELING["EXP Gained - Killing NPC"] = 50
BRICKS_SERVER.BASECONFIG.LEVELING["Playing On Server Reward Time"] = 300
BRICKS_SERVER.BASECONFIG.LEVELING["EXP Gained - Playing On Server"] = 50
BRICKS_SERVER.BASECONFIG.LEVELING["EXP Gained - Lockpick"] = 4
BRICKS_SERVER.BASECONFIG.LEVELING["EXP Gained - Entered Lottery"] = 10
BRICKS_SERVER.BASECONFIG.LEVELING["EXP Gained - Lottery Won"] = 100
BRICKS_SERVER.BASECONFIG.LEVELING["EXP Gained - Hit Completed"] = 25
BRICKS_SERVER.BASECONFIG.LEVELING["EXP Gained - Rock Mined"] = 25
BRICKS_SERVER.BASECONFIG.LEVELING["EXP Gained - Tree Chopped"] = 25
BRICKS_SERVER.BASECONFIG.LEVELING["EXP Gained - Garbage Searched"] = 25
BRICKS_SERVER.BASECONFIG.LEVELING["EXP Gained - Money Printing"] = 10
BRICKS_SERVER.BASECONFIG.LEVELING["EXP Gained - Armory Robbery"] = 20
BRICKS_SERVER.BASECONFIG.LEVELING["EXP Gained - Laundering"] = 20
BRICKS_SERVER.BASECONFIG.LEVELING.JobLevels = {}
BRICKS_SERVER.BASECONFIG.LEVELING.EntityLevels = {}
BRICKS_SERVER.BASECONFIG.LEVELING.ShipmentLevels = {}
BRICKS_SERVER.BASECONFIG.LEVELING.AmmoLevels = {}

--[[ PRINTERS ]]--
BRICKS_SERVER.BASECONFIG.PRINTERS = {}
BRICKS_SERVER.BASECONFIG.PRINTERS["Max Level"] = 100
BRICKS_SERVER.BASECONFIG.PRINTERS["Original EXP Required"] = 150
BRICKS_SERVER.BASECONFIG.PRINTERS["EXP Required Increase"] = 1.1
BRICKS_SERVER.BASECONFIG.PRINTERS["Printer EXP Per Print"] = 5
BRICKS_SERVER.BASECONFIG.PRINTERS["Money Increase Per Level"] = 0.01
BRICKS_SERVER.BASECONFIG.PRINTERS["Ink Lost Per Print"] = 2
BRICKS_SERVER.BASECONFIG.PRINTERS["Replace Cooldown"] = 30
BRICKS_SERVER.BASECONFIG.PRINTERS.Tiers = {
    [1] = {
        Name = "Silver",
        UpgradeCost = 0,
        ModelColor = Color( 192, 192, 192 ),
        ScreenColor = Color( 192, 192, 192 ),
        Health = 150,
        MaxInk = 150,
        PrintAmount = 100,
        MoneyStorage = 1500,
        PrintSpeed = 10
    },
    [2] = {
        Name = "Gold",
        UpgradeCost = 1000,
        ModelColor = Color( 238, 191, 39 ),
        ScreenColor = Color( 234, 213, 39 ),
        Health = 150,
        MaxInk = 150,
        PrintAmount = 90,
        MoneyStorage = 15000,
        PrintSpeed = 8
    },
    [3] = {
        Name = "Diamond",
        UpgradeCost = 5000,
        ModelColor = Color( 16, 231, 255 ),
        ScreenColor = Color( 74, 255, 245 ),
        Health = 150,
        MaxInk = 150,
        PrintAmount = 150,
        MoneyStorage = 50000,
        PrintSpeed = 5
    },
    [4] = {
        Name = "Obsidian",
        UpgradeCost = 25000,
        ModelColor = Color( 65, 34, 119 ),
        ScreenColor = Color( 83, 63, 112 ),
        Health = 150,
        MaxInk = 150,
        PrintAmount = 200,
        MoneyStorage = 100000,
        PrintSpeed = 3
    }
}
BRICKS_SERVER.BASECONFIG.PRINTERS.PrinterSlots = {
    [1] = {},
    [2] = {
        Price = 10000,
    },
    [3] = {
        Price = 20000,
        Level = 5,
    },
    [4] = {
        Group = "VIP",
    },
}

--[[ INVENTORY ]]--
BRICKS_SERVER.BASECONFIG.INVENTORY = BRICKS_SERVER.BASECONFIG.INVENTORY or {}
BRICKS_SERVER.BASECONFIG.INVENTORY["Max Item Stack"] = 10
BRICKS_SERVER.BASECONFIG.INVENTORY["Inventory Slots"] = {
    ["Staff"] = 40,
    ["VIP++"] = 35,
    ["VIP+"] = 30,
    ["VIP"] = 25,
    ["Default"] = 20
}
BRICKS_SERVER.BASECONFIG.INVENTORY["Bank Slots"] = {
    ["Staff"] = 40,
    ["VIP++"] = 35,
    ["VIP+"] = 30,
    ["VIP"] = 25,
    ["Default"] = 20
}

--[[ BOOSTERS ]]--
BRICKS_SERVER.BASECONFIG.BOOSTERS = {
    [1] = {
        Title = "2X EXP",
        Type = 1,
        Multiplier = 2,
        Time = 60,
        Icon = "https://i.imgur.com/MoWl39V.png"
    },
    [2] = {
        Title = "4X EXP",
        Type = 1,
        Multiplier = 4,
        Time = 60,
        Icon = "https://i.imgur.com/DzvUBFv.png"
    },
    [3] = {
        Title = "2X Printer EXP",
        Type = 2,
        Multiplier = 2,
        Time = 60,
        Icon = "https://i.imgur.com/B2PVgUV.png"
    },
    [4] = {
        Title = "4X Printer EXP",
        Type = 2,
        Multiplier = 4,
        Time = 60,
        Icon = "https://i.imgur.com/BfzvXDH.png"
    }
}

--[[ CRAFTING ]]--
BRICKS_SERVER.BASECONFIG.CRAFTING = {}
BRICKS_SERVER.BASECONFIG.CRAFTING["Rock Respawn Time"] = 60
BRICKS_SERVER.BASECONFIG.CRAFTING["Tree Respawn Time"] = 60
BRICKS_SERVER.BASECONFIG.CRAFTING["Garbage Respawn Time"] = 60
BRICKS_SERVER.BASECONFIG.CRAFTING["Garbage Collect Time"] = 3
BRICKS_SERVER.BASECONFIG.CRAFTING["Resource Despawn Time"] = 300
BRICKS_SERVER.BASECONFIG.CRAFTING["Add Resources Directly To Inventory"] = false
BRICKS_SERVER.BASECONFIG.CRAFTING.Resources = {
    ["Wood"] = { "models/2rek/brickwall/bwall_log_1.mdl" },
    ["Plastic"] = { "models/2rek/brickwall/bwall_plastic_1.mdl" },
    ["Scrap"] = { "models/2rek/brickwall/bwall_scrap_1.mdl" },
    ["Iron"] = { "models/2rek/brickwall/bwall_ore_1.mdl", Color( 0, 0, 0 ) },
    ["Diamond"] = { "models/2rek/brickwall/bwall_ore_1.mdl", Color( 0, 246, 255 ) },
    ["Ruby"] = { "models/2rek/brickwall/bwall_ore_1.mdl", Color( 255, 0, 0 ) },
}
BRICKS_SERVER.BASECONFIG.CRAFTING.Craftables = {
    [1] = {
        Name = "Ak-47",
        Type = "Weapon",
        ReqInfo = { "weapon_ak472" },
        Resources = { ["Wood"] = 5, ["Iron"] = 2 },
        Model = "models/weapons/w_rif_ak47.mdl",
        Level = 3,
        CraftTime = 5
    },
    [2] = {
        Name = "M4A1",
        Type = "Weapon",
        ReqInfo = { "weapon_m42" },
        Resources = { ["Wood"] = 15, ["Iron"] = 1 },
        Model = "models/weapons/w_rif_m4a1.mdl",
        CraftTime = 2
    }
}
BRICKS_SERVER.BASECONFIG.CRAFTING.RockTypes = {
    ["Iron"] = 50,
    ["Diamond"] = 20,
    ["Ruby"] = 10
}
BRICKS_SERVER.BASECONFIG.CRAFTING.TreeTypes = {
    ["Wood"] = 50
}
BRICKS_SERVER.BASECONFIG.CRAFTING.GarbageTypes = {
    ["Plastic"] = 50,
    ["Scrap"] = 50
}
BRICKS_SERVER.BASECONFIG.CRAFTING.Skills = {
    ["woodcutting"] = {
        MaxLevel = 50,
        BaseExperience = 100,
        ExpMultiplier = 1.5
    }
}

--[[ NPCS ]]--
BRICKS_SERVER.BASECONFIG.NPCS = BRICKS_SERVER.BASECONFIG.NPCS or {}
table.insert( BRICKS_SERVER.BASECONFIG.NPCS, {
    Name = "Resource store",
    Type = "Trader",
    ReqInfo = { 1 },
    Buying = {
        [1] = {
            Type = "Resource",
            Model = "models/2rek/brickwall/bwall_log_1.mdl",
            ReqInfo = { "Wood" },
            Price = 50
        },
        [2] = {
            Type = "Resource",
            Model = "models/2rek/brickwall/bwall_ore_1.mdl",
            ReqInfo = { "Iron" },
            Price = 100
        }
    }
} )
table.insert( BRICKS_SERVER.BASECONFIG.NPCS, {
    Name = "Marketplace",
    Type = "Marketplace"
} )
table.insert( BRICKS_SERVER.BASECONFIG.NPCS, {
    Name = "Bank",
    Type = "Bank"
} )
table.insert( BRICKS_SERVER.BASECONFIG.NPCS, {
    Name = "Money Launderer",
    Type = "Money Launderer"
} )
table.insert( BRICKS_SERVER.BASECONFIG.NPCS, {
    Name = "Deathscreens",
    Type = "Deathscreens"
} )
table.insert( BRICKS_SERVER.BASECONFIG.NPCS, {
    Name = "SWEP Upgrader",
    Type = "SWEP Upgrader"
} )

--[[ MARKETPLACE ]]--
BRICKS_SERVER.BASECONFIG.MARKETPLACE = {}
BRICKS_SERVER.BASECONFIG.MARKETPLACE["Currency"] = "darkrp_money"
BRICKS_SERVER.BASECONFIG.MARKETPLACE["Minimum Starting Price"] = 1000
BRICKS_SERVER.BASECONFIG.MARKETPLACE["Minimum Auction Time"] = 300
BRICKS_SERVER.BASECONFIG.MARKETPLACE["Maximum Auction Time"] = 86400
BRICKS_SERVER.BASECONFIG.MARKETPLACE["Minimum Bid Increment"] = 1.1
BRICKS_SERVER.BASECONFIG.MARKETPLACE["Can Players Cancel Auction"] = true
BRICKS_SERVER.BASECONFIG.MARKETPLACE["Remove After Auction End Time"] = 259200

--[[ BANK VAULT ]]--
BRICKS_SERVER.BASECONFIG.BANKVAULT = {}
BRICKS_SERVER.BASECONFIG.BANKVAULT["Money Bags"] = 3
BRICKS_SERVER.BASECONFIG.BANKVAULT["Police Requirement"] = 0
BRICKS_SERVER.BASECONFIG.BANKVAULT["Robbery Cooldown"] = 15
BRICKS_SERVER.BASECONFIG.BANKVAULT["Alarm Duration"] = 5
BRICKS_SERVER.BASECONFIG.BANKVAULT["Open Time"] = 45
BRICKS_SERVER.BASECONFIG.BANKVAULT["Money Bag Amount"] = { 100000, 150000 }
BRICKS_SERVER.BASECONFIG.BANKVAULT["Dirty To Clean Money Multiplier"] = { 0.9, 1.1 }
BRICKS_SERVER.BASECONFIG.BANKVAULT["Pins Required"] = 3
BRICKS_SERVER.BASECONFIG.BANKVAULT["Can Pickup Multiple Bags"] = false
BRICKS_SERVER.BASECONFIG.BANKVAULT.RobberTeams = {
    ["citizen"] = true
}
BRICKS_SERVER.BASECONFIG.BANKVAULT.PoliceJobs = {
    ["cp"] = true
}

--[[ ARMORY ]]--
BRICKS_SERVER.BASECONFIG.ARMORY = {}
BRICKS_SERVER.BASECONFIG.ARMORY["Police Requirement"] = 5
BRICKS_SERVER.BASECONFIG.ARMORY["Robbery Cooldown"] = 160
BRICKS_SERVER.BASECONFIG.ARMORY["Open Time"] = 5
BRICKS_SERVER.BASECONFIG.ARMORY["Reward Money"] = { 100000, 150000 }
BRICKS_SERVER.BASECONFIG.ARMORY["Shipment Reward Amount"] = { 1, 3 }
BRICKS_SERVER.BASECONFIG.ARMORY["Fail Cooldown"] = 60
BRICKS_SERVER.BASECONFIG.ARMORY.RewardShipments = { ["AK47"] = true }
BRICKS_SERVER.BASECONFIG.ARMORY.RobberTeams = {
    ["citizen"] = true
}
BRICKS_SERVER.BASECONFIG.ARMORY.PoliceJobs = {
    ["cp"] = true,
    ["chief"] = true
}
BRICKS_SERVER.BASECONFIG.ARMORY.Items = {
	[1] = {
        Name = "AK-47 Rifle",
        Category = "Weapons",
        Type = "Weapon",
        ReqInfo = { "weapon_ak472" },
		Model = "models/weapons/w_rif_ak47.mdl"
	},
	[2] = {
        Name = "M4 Rifle",
        Category = "Weapons",
        Type = "Weapon",
        ReqInfo = { "weapon_m42" },
		Model = "models/weapons/w_rif_m4a1.mdl",
		Level = 4
	},
	[3] = {
        Name = "Pump Shotgun",
        Category = "Weapons",
        Type = "Weapon",
        ReqInfo = { "weapon_pumpshotgun2" },
		Model = "models/weapons/w_shot_m3super90.mdl"
	},
	[4] = {
        Name = "Deagle",
        Category = "Weapons",
        Type = "Weapon",
        ReqInfo = { "weapon_deagle2" },
		Model = "models/weapons/w_pist_deagle.mdl",
        Level = 8,
        Restrictions = { 
            ["chief"] = true
        }
	},
	[5] = {
        Name = "Pistol Ammo",
        Category = "Ammo",
        Type = "Ammo",
        ReqInfo = { "Pistol", 30, 90 },
		Model = "models/items/boxsrounds.mdl"
	},
	[6] = {
        Name = "SMG Ammo",
        Category = "Ammo",
        Type = "Ammo",
        ReqInfo = { "SMG1", 45, 90 },
		Model = "models/items/boxsrounds.mdl",
        Restrictions = { 
            ["cp"] = true
        }
	},
	[7] = {
        Name = "Buckshot",
        Category = "Ammo",
        Type = "Ammo",
        ReqInfo = { "Buckshot", 12, 36 },
		Model = "models/items/boxbuckshot.mdl",
		Level = 5,
        Restrictions = { 
            ["chief"] = true
        }
	},
	[8] = {
        Name = "Light Armor",
        Category = "Gear",
        Type = "Armor",
        ReqInfo = { 50 },
        Model = "models/Items/battery.mdl"
    },
	[9] = {
		Name = "Medium Armor",
        Category = "Gear",
        Type = "Armor",
        ReqInfo = { 100 },
		Model = "models/Items/battery.mdl",
		Level = 3
	},
	[10] = {
		Name = "Heavy Armor",
        Category = "Gear",
        Type = "Armor",
        ReqInfo = { 150 },
		Model = "models/Items/battery.mdl",
		Level = 6,
        Restrictions = { 
            ["chief"] = true
        }
	}
}

--[[ BOSSES ]]--
BRICKS_SERVER.BASECONFIG.BOSS = {}
BRICKS_SERVER.BASECONFIG.BOSS["Damage Update Time"] = 2
BRICKS_SERVER.BASECONFIG.BOSS["Boss Bar Display Distance"] = 2000
BRICKS_SERVER.BASECONFIG.BOSS.NPCs = {}
BRICKS_SERVER.BASECONFIG.BOSS.NPCs[1] = {
    Name = "MINI ZOMBIE BOSS",
    Model = "models/zombie/classic.mdl",
    Class = "npc_zombie",
    Health = 15000,
    Scale = 2,
    DamageScale = 10,
    Loot = {
        [1] = {
            Chance = 100,
            Name = "100 EXP",
            Icon = "https://i.imgur.com/8gXiMxX.png",
            Type = "Experience",
            ReqInfo = { 100 }
        },
        [2] = {
            Chance = 100,
            Name = "$1,000",
            Model = "models/props/cs_assault/money.mdl",
            Type = "Money",
            ReqInfo = { 1000 }
        },
        [3] = {
            Chance = 10,
            Name = "1K EXP",
            Icon = "https://i.imgur.com/8gXiMxX.png",
            Type = "Experience",
            ReqInfo = { 1000 }
        },
        [4] = {
            Chance = 10,
            Name = "$10,000",
            Model = "models/props/cs_assault/money.mdl",
            Type = "Money",
            ReqInfo = { 10000 }
        },
        [5] = {
            Chance = 50,
            Name = "AK47",
            Model = "models/weapons/w_rif_ak47.mdl",
            Type = "Weapon",
            ReqInfo = { "weapon_ak472", 1 }
        }
    }
}

--[[ DEATHSCREENS ]]--
BRICKS_SERVER.BASECONFIG.DEATHSCREENS = {}
BRICKS_SERVER.BASECONFIG.DEATHSCREENS["Default Playercard"] = "https://i.imgur.com/dJ71grf.png"
BRICKS_SERVER.BASECONFIG.DEATHSCREENS.Cards = {
    ["parasyte"] = {
        Name = "Parasyte",
        Category = "Anime",
        Image = "https://i.imgur.com/dhEmnBP.jpg",
        Price = 5000
    },
    ["neoncity"] = {
        Name = "Neon City",
        Category = "Anime",
        GIF = "https://i.imgur.com/zB4VNmi.gif",
        Price = 25000
    },
    ["oneinthechamber"] = {
        Name = "One in the chamber",
        Category = "Call of duty",
        Image = "https://i.imgur.com/jjnFoB5.png",
        Price = 15000
    },
    ["420blazeit"] = {
        Name = "420 Blaze it",
        Category = "Call of duty",
        Image = "https://i.imgur.com/gmYJ39L.png"
    },
    ["oof"] = {
        Name = "Oof",
        Category = "Call of duty",
        Image = "https://i.imgur.com/uWB78JO.png",
        Price = 25000
    },
    ["tankman"] = {
        Name = "Tank Man",
        Category = "Call of duty",
        Image = "https://i.imgur.com/Bx7u4cW.png",
        Price = 5000000
    },
    ["floater"] = {
        Name = "Floater",
        Category = "Call of duty",
        GIF = "https://i.imgur.com/pVUuorQ.gif",
        Level = 5
    },
    ["rocketman"] = {
        Name = "Rocket Man",
        Category = "Call of duty",
        GIF = "https://i.imgur.com/qAr5vRj.gif",
        Group = "VIP++"
    },
    ["mandown"] = {
        Name = "Man Down",
        Category = "Call of duty",
        GIF = "https://i.imgur.com/CSkeIBj.gif",
        Group = "VIP++"
    }
}
BRICKS_SERVER.BASECONFIG.DEATHSCREENS.Emblems = {
    ["abrickinawall"] = {
        Name = "A brick in a wall",
        Image = "https://i.imgur.com/isxAKMU.png",
		Group =	"VIP++",
		Level =	10
    },
    ["ak-47"] = {
        Name = "AK-47",
        Image = "https://i.imgur.com/V3aKj7G.png",
		Price =	50000
    },
    ["deadpool"] = {
        Name = "Deadpool",
        Image = "https://i.imgur.com/O5ID452.png",
		Price =	50000
    },
    ["weeaboo"] = {
        Name = "Weeaboo",
        Category = "Anime",
        Image = "https://i.imgur.com/YrXklOK.png",
        Level = 10,
        Group = "VIP++"
    },
    ["parasyte"] = {
        Name = "Parasyte",
        Category = "Anime",
        Image = "https://i.imgur.com/A2ogFMt.png",
        Level = 15,
        Group = "VIP++"
    },
    ["wyvernknight"] = {
        Name = "Wyvern Knight",
        GIF = "https://i.imgur.com/YIlZdsu.gif",
        Price = 56000
    }
}
BRICKS_SERVER.BASECONFIG.DEATHSCREENS.Soundtracks = {
    ["parasyte"] = {
        Name = "Parasyte",
        Category = "Anime",
        Sound = "https://sndup.net/64vg/parasyte.wav",
        Price = 5000
    },
    ["helix"] = {
        Name = "Helix",
        Sound = "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
        Level = 5,
        Group = "VIP++"
    }
}

BRICKS_SERVER.BASECONFIG.SWEPUPGRADES = {}
BRICKS_SERVER.BASECONFIG.SWEPUPGRADES.BaseUpgradeAmounts = 5
BRICKS_SERVER.BASECONFIG.SWEPUPGRADES.BasePrice = 10000
BRICKS_SERVER.BASECONFIG.SWEPUPGRADES.PriceIncrease = 2.5
BRICKS_SERVER.BASECONFIG.SWEPUPGRADES.UpgradeAmounts = {
    ["ls_sniper"] = 3
}
BRICKS_SERVER.BASECONFIG.SWEPUPGRADES.IncreasePercent = {
    ["Damage"] = 1,
    ["ClipSize"] = 5,
    ["Recoil"] = 1
}
BRICKS_SERVER.BASECONFIG.SWEPUPGRADES.Blacklist = {
    ["weapon_keypadchecker"] = true,
    ["arrest_stick"] = true,
    ["door_ram"] = true,
    ["keys"] = true,
    ["lockpick"] = true,
    ["med_kit"] = true,
    ["pocket"] = true,
    ["stunstick"] = true,
    ["unarrest_stick"] = true,
    ["weaponchecker"] = true,
    ["weapon_physcannon"] = true,
    ["gmod_camera"] = true,
    ["manhack_welder"] = true,
    ["gmod_tool"] = true,
    ["weapon_physgun"] = true,
    ["bricks_server_invpickup"] = true,
    ["bricks_server_axe"] = true,
    ["bricks_server_pickaxe"] = true
}