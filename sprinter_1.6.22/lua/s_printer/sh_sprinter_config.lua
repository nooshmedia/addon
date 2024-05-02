sPrinter = sPrinter or {}
sPrinter.config = sPrinter.config or {}
sPrinter.config.printers = sPrinter.config.printers or {}

sPrinter.config.EssentialsXPSystemEnabled = true
sPrinter.config.WithdrawXPAmount = 400
--  _______                               _  
-- (_______)                             | | 
--  _   ___ _____ ____  _____  ____ _____| | 
-- | | (_  | ___ |  _ \| ___ |/ ___|____ | | 
-- | |___) | ____| | | | ____| |   / ___ | | 
--  \_____/|_____)_| |_|_____)_|   \_____|\_)

sPrinter.config["language"] = "en"

sPrinter.config["prefix"] = "[sPrinter] "

sPrinter.config["logging_col"] = Color(200,0,0)

sPrinter.config["currency"] = "£"

sPrinter.config["hack_speed"] = 6

sPrinter.config["punish_exploit"] = true

sPrinter.config["hack_words"] = {
    ["HACKING"] = true,
    ["L33T"] = true,
    ["1337"] = true,
    ["LULZ"] = true
}

sPrinter.config["max_printer_bag"] = { --- This is the max printers the printer bag can hold!
    ["default"] = 3,
    ["superadmin"] = 5
}

sPrinter.config["rack_repair_price"] = 12000

sPrinter.config["DarkRPFireSystem_Spawn_Flame_On_Explode"] = true --- This will spawn a flame if you have the darkrp fire system and this is enabled!

sPrinter.config["disable_topscreen_in_rack"] = true --- This will disable drawing the topscreen while the printer is in a rack, good for performance!

sPrinter.config["maxdistance"] = 8000

sPrinter.config["maxdrawdistance"] = 30000

sPrinter.config["logo"] = {
    ["sprinter_base"] = {
        enabled = true,
        id = "zjAxWLD",
        size = {w = 420, h = 420},
        pos = Vector(-13.135, 19.546, 4.8),
        ang = Angle(0,0,0)
    },
    ["sprinter_rack"] = {
        enabled = true,
        id = "zjAxWLD",
        size = {w = 420, h = 420},
        pos = Vector(-3, -10.7, 44.187),
        ang = Angle(0,0,90)
    },
}

sPrinter.config["soundradius"] = 60

sPrinter.config["damageradius"] = {20,50}

sPrinter.config["blastdamage"] = {30,80}


--  ______              _     ______  ______  
-- (______)            | |   (_____ \(_____ \ 
--  _     _ _____  ____| |  _ _____) )_____) )
-- | |   | (____ |/ ___) |_/ )  __  /|  ____/ 
-- | |__/ // ___ | |   |  _ (| |  \ \| |      
-- |_____/ \_____|_|   |_| \_)_|   |_|_|      

hook.Add("loadCustomDarkRPItems", "sP:LoadEnts", function()
    ------------------------------------------------------------------------------------
    --  You can use any DarkRP create entity variables here just like normal in here.
    ------------------------------------------------------------------------------------

    sPrinter.config["reward_teams"] = {
        --[TEAM_CITIZEN] = true -- Add whatever you want in here! 
    }
    
    sPrinter.config["drp_categories"] = { -- This can be used to setup custom categories, for example Premium Printers etc...
        {
            name = "Printers T1",
            color = Color(200,0,0),
            canSee = function(ply)
                return true
            end,
            sortOrder = 10,
        },

        {
            name = "Printers T2",
            color = Color(200,0,0),
            canSee = function(ply)
                return true
            end,
            sortOrder = 12,
        },

        {
            name = "Printers T3",
            color = Color(200,0,0),
            canSee = function(ply)
                return true
            end,
            sortOrder = 14,
        },

        {
            name = "VIP",
            color = Color(200,0,0),
            canSee = function(ply)
                return true
            end,
            sortOrder = 16,
        },
        // {
        //     name = "Example1",
        //     color = Color(230,0,0),
        //     sortOrder = 20,
        // },
    }

    sPrinter.config["rack"] = {
        ["body_color"] = Color(112,112,112),
        ["godmode"] = true, -- Should we godmode the printer rack?
        ["water_affect"] = 2, -- 0 = Ignore, 1 = Blow up & 2 = Eject

        ["price"] = 20000, --- This is the price of the rack in the DarkRP Entities
        ["max"] = 1,
        ["category"] = "Printers",
        // ["allowed"] = {}, --- This is where you add allowed teams.
        // ["disabled"] = true, --- If you wanna disable the printer rack.

        // ["sortOrder"] = -100,
        // ["CustomCheckFailMsg"] = "This is a test",
        // ["customCheck"] = function() end 
    }

    sPrinter.config.printers["Basic Printer"] = {
        bodycolor = Color(174,174,174),
        clockspeed = 0.5, --1Ghz 
        baseincome = 100,
        maxstorage = 1500000,
        sortorder = .3,
        batteryconsumption = .3, --- This is how many percent it will take per 10 seconds
        rechargeprice = 2000,
        repairprice = 2000,
        category = "Printers T1",
        xpmultiplier = 1,
        // cantwithdrawjobs = {["Citizen"] = false},
        // withdrawjobswhitelist = true,
        water_affect = 1, --- 0 = Ignore, 1 = Blow up & 2 = Turn off
        reward = 1, --- This is how much of the cost that the person to destroy the printer will earn, based on the price of the printer!
        // countUpgradesToReward = true, --- This will make the upgrades count into the reward amount!
        dmgresistance = 1, --- This is the damage multiplier the printer receive
        price = 1500, --- This is the cost of buying the printer in the entities list!
        max = 1,
        upgrades = {
            {upgrade = "overclocking", baseprice = 5000, max = 10, upgrade_stage = 3, icon = Material("sprinter/overclock.png", "smooth")}, --- You can enforce pricing for each upgrade level like this ([upgrade_stage] = price) : , enforced_pricing = {[1] = 200, [2] = 400}
            {upgrade = "noisereduction", baseprice = 1500, max = 5, icon = Material("sprinter/noise.png", "smooth")},
            {upgrade = "dmgresistance", baseprice = 700, max = 5, icon = Material("sprinter/shield.png", "smooth")},
            {upgrade = "storage", baseprice = 3000, max = 5, increment = 10000, icon = Material("sprinter/storage.png", "smooth")},
            {upgrade = "notifications", baseprice = 500, max = 1, icon = Material("sprinter/bell.png", "smooth")}
        },
    }

    sPrinter.config.printers["Copper Printer - Lvl 25"] = {
        bodycolor = Color(184,115,51),
        clockspeed = 0.5,
        baseincome = 300,
        maxstorage = 1500000,
        sortorder = 2,
        batteryconsumption = .28,
        rechargeprice = 3000,
        repairprice = 2000,
        water_affect = 1,
        reward = 1,
        dmgresistance = .9,
        price = 4500,
        max = 1,
        upgrades = {
            {upgrade = "overclocking", baseprice = 28500, max = 10, icon = Material("sprinter/overclock.png", "smooth")},
            {upgrade = "noisereduction", baseprice = 1500, max = 5, icon = Material("sprinter/noise.png", "smooth")},
            {upgrade = "dmgresistance", baseprice = 700, max = 5, icon = Material("sprinter/shield.png", "smooth")},
            {upgrade = "storage", baseprice = 3000, max = 5, increment = 10000, icon = Material("sprinter/storage.png", "smooth")},
            {upgrade = "notifications", baseprice = 500, max = 1, icon = Material("sprinter/bell.png", "smooth")}
        }
    }

    sPrinter.config.printers["Iron Printer - Lvl 225"] = {
        bodycolor = Color(161,157,148),
        clockspeed = 0.5,
        baseincome = 2700,
        maxstorage = 1500000,
        sortorder = 2,
        batteryconsumption = .28,
        rechargeprice = 3000,
        repairprice = 2000,
        water_affect = 1,
        reward = 1,
        dmgresistance = .9,
        price = 40500,
        max = 1,
        upgrades = {
            {upgrade = "overclocking", baseprice = 85500, max = 10, icon = Material("sprinter/overclock.png", "smooth")},
            {upgrade = "noisereduction", baseprice = 1500, max = 5, icon = Material("sprinter/noise.png", "smooth")},
            {upgrade = "dmgresistance", baseprice = 700, max = 5, icon = Material("sprinter/shield.png", "smooth")},
            {upgrade = "storage", baseprice = 3000, max = 5, increment = 10000, icon = Material("sprinter/storage.png", "smooth")},
            {upgrade = "notifications", baseprice = 500, max = 1, icon = Material("sprinter/bell.png", "smooth")}
        }
    }

    sPrinter.config.printers["Tin Printer - Lvl 75"] = {
        bodycolor = Color(211,212,213),
        clockspeed = 0.5,
        baseincome = 900,
        maxstorage = 1500000,
        sortorder = 2,
        batteryconsumption = .28,
        rechargeprice = 3000,
        repairprice = 2000,
        water_affect = 1,
        reward = 1,
        dmgresistance = .9,
        price = 13500,
        max = 1,
        upgrades = {
            {upgrade = "overclocking", baseprice = 9500, max = 10, icon = Material("sprinter/overclock.png", "smooth")},
            {upgrade = "noisereduction", baseprice = 1500, max = 5, icon = Material("sprinter/noise.png", "smooth")},
            {upgrade = "dmgresistance", baseprice = 700, max = 5, icon = Material("sprinter/shield.png", "smooth")},
            {upgrade = "storage", baseprice = 3000, max = 5, increment = 10000, icon = Material("sprinter/storage.png", "smooth")},
            {upgrade = "notifications", baseprice = 500, max = 1, icon = Material("sprinter/bell.png", "smooth")}
        }
    }

    sPrinter.config.printers["Silver Printer - Lvl 675"] = {
        bodycolor = Color(192,192,192),
        clockspeed = 0.5,
        baseincome = 8100,
        maxstorage = 1500000,
        sortorder = 2,
        batteryconsumption = .28,
        rechargeprice = 3000,
        repairprice = 2000,
        water_affect = 1,
        reward = 1,
        dmgresistance = .9,
        price = 121500,
        max = 1,
        upgrades = {
            {upgrade = "overclocking", baseprice = 256500, max = 10, icon = Material("sprinter/overclock.png", "smooth")},
            {upgrade = "noisereduction", baseprice = 1500, max = 5, icon = Material("sprinter/noise.png", "smooth")},
            {upgrade = "dmgresistance", baseprice = 700, max = 5, icon = Material("sprinter/shield.png", "smooth")},
            {upgrade = "storage", baseprice = 3000, max = 5, increment = 10000, icon = Material("sprinter/storage.png", "smooth")},
            {upgrade = "notifications", baseprice = 500, max = 1, icon = Material("sprinter/bell.png", "smooth")}
        }
    }

    sPrinter.config.printers["Gold Printer - Lvl 950"] = {
        bodycolor = Color(212,175,55),
        clockspeed = 1.5,  --2Ghz
        baseincome = 8100, --£72,151/min
        maxstorage = 5000000,
        sortorder = 2,
        batteryconsumption = .28,
        rechargeprice = 3000,
        repairprice = 2000,
        water_affect = 1,
        reward = 1,
        dmgresistance = .9,
        price = 364500,
        max = 1,
        category = "Printers T2",
        upgrades = {
            {upgrade = "overclocking", baseprice = 769500, max = 10, icon = Material("sprinter/overclock.png", "smooth")},
            {upgrade = "noisereduction", baseprice = 1500, max = 5, icon = Material("sprinter/noise.png", "smooth")},
            {upgrade = "dmgresistance", baseprice = 700, max = 5, icon = Material("sprinter/shield.png", "smooth")},
            {upgrade = "storage", baseprice = 3000, max = 5, increment = 10000, icon = Material("sprinter/storage.png", "smooth")},
            {upgrade = "notifications", baseprice = 500, max = 1, icon = Material("sprinter/bell.png", "smooth")}
        }
    }

    sPrinter.config.printers["Platinum Printer - Lvl 1250"] = {
        bodycolor = Color(229, 228, 226),
        clockspeed = 1.5,
        baseincome = 24300, --£720/min
        maxstorage = 5000000,
        sortorder = 3,
        batteryconsumption = .28,
        rechargeprice = 3000,
        repairprice = 2000,
        water_affect = 1,
        reward = 1,
        dmgresistance = .9,
        price = 1093500,
        max = 1,
        category = "Printers T2",
        upgrades = {
            {upgrade = "overclocking", baseprice = 2308500, max = 10, icon = Material("sprinter/overclock.png", "smooth")},
            {upgrade = "noisereduction", baseprice = 1500, max = 5, icon = Material("sprinter/noise.png", "smooth")},
            {upgrade = "dmgresistance", baseprice = 700, max = 5, icon = Material("sprinter/shield.png", "smooth")},
            {upgrade = "storage", baseprice = 3000, max = 5, increment = 10000, icon = Material("sprinter/storage.png", "smooth")},
            {upgrade = "notifications", baseprice = 500, max = 1, icon = Material("sprinter/bell.png", "smooth")}
        }
    }

    sPrinter.config.printers["Diamond Printer - Lvl 2000"] = {
        bodycolor = Color(185,242,255),
        clockspeed = 1.5,
        baseincome = 40500,
        maxstorage = 25000000,
        sortorder = 4,
        batteryconsumption = .28,
        rechargeprice = 3000,
        repairprice = 2000,
        water_affect = 1,
        reward = 1,
        dmgresistance = .9,
        price = 3280500,
        max = 1,
        category = "Printers T2",
        upgrades = {
            {upgrade = "overclocking", baseprice = 6925500, max = 10, icon = Material("sprinter/overclock.png", "smooth")},
            {upgrade = "noisereduction", baseprice = 1500, max = 5, icon = Material("sprinter/noise.png", "smooth")},
            {upgrade = "dmgresistance", baseprice = 700, max = 5, icon = Material("sprinter/shield.png", "smooth")},
            {upgrade = "storage", baseprice = 3000, max = 5, increment = 10000, icon = Material("sprinter/storage.png", "smooth")},
            {upgrade = "notifications", baseprice = 500, max = 1, icon = Material("sprinter/bell.png", "smooth")}
        }
    }

    sPrinter.config.printers["Titanium Printer - Lvl 2350"] = {
        bodycolor = Color(128,125,127),
        clockspeed = 1.5,
        baseincome = 113400,
        maxstorage = 25000000,
        sortorder = 5,
        batteryconsumption = .28,
        rechargeprice = 3000,
        repairprice = 2000,
        water_affect = 1,
        reward = 1,
        dmgresistance = .9,
        price = 9841500,
        max = 1,
        level = 25,
        category = "Printers T2",
        upgrades = {
            {upgrade = "overclocking", baseprice = 20776500, max = 10, icon = Material("sprinter/overclock.png", "smooth")},
            {upgrade = "noisereduction", baseprice = 1500, max = 5, icon = Material("sprinter/noise.png", "smooth")},
            {upgrade = "dmgresistance", baseprice = 700, max = 5, icon = Material("sprinter/shield.png", "smooth")},
            {upgrade = "storage", baseprice = 3000, max = 5, increment = 10000, icon = Material("sprinter/storage.png", "smooth")},
            {upgrade = "notifications", baseprice = 500, max = 1, icon = Material("sprinter/bell.png", "smooth")}
        }
    }

    sPrinter.config.printers["Urainum Printer - Lvl 3050"] = {
        bodycolor = Color(115,255,124),
        clockspeed = 1.5,
        baseincome = 656100,
        maxstorage = 25000000,
        sortorder = 6,
        batteryconsumption = .28,
        rechargeprice = 3000,
        repairprice = 2000,
        water_affect = 1,
        reward = 1,
        dmgresistance = .9,
        price = 29524500,
        max = 1,
        category = "Printers T2",
        upgrades = {
            {upgrade = "overclocking", baseprice = 62329500, max = 10, icon = Material("sprinter/overclock.png", "smooth")},
            {upgrade = "noisereduction", baseprice = 1500, max = 5, icon = Material("sprinter/noise.png", "smooth")},
            {upgrade = "dmgresistance", baseprice = 700, max = 5, icon = Material("sprinter/shield.png", "smooth")},
            {upgrade = "storage", baseprice = 3000, max = 5, increment = 10000, icon = Material("sprinter/storage.png", "smooth")},
            {upgrade = "notifications", baseprice = 500, max = 1, icon = Material("sprinter/bell.png", "smooth")}
        }
    }

    sPrinter.config.printers["Thor's - Lvl 3500"] = {
        bodycolor = Color(176,223,241),
        clockspeed = 2.5,
        baseincome = 1246590,
        maxstorage = 100000000,
        sortorder = 1,
        batteryconsumption = .28,
        rechargeprice = 3000,
        repairprice = 2000,
        water_affect = 1,
        reward = 1,
        dmgresistance = .9,
        price = 88573500,
        max = 1,
        category = "Printers T3",
        upgrades = {
            {upgrade = "overclocking", baseprice = 187988500, max = 10, icon = Material("sprinter/overclock.png", "smooth")},
            {upgrade = "noisereduction", baseprice = 1500, max = 5, icon = Material("sprinter/noise.png", "smooth")},
            {upgrade = "dmgresistance", baseprice = 700, max = 5, icon = Material("sprinter/shield.png", "smooth")},
            {upgrade = "storage", baseprice = 3000, max = 5, increment = 10000, icon = Material("sprinter/storage.png", "smooth")},
            {upgrade = "notifications", baseprice = 500, max = 1, icon = Material("sprinter/bell.png", "smooth")}
        }
    }

    sPrinter.config.printers["Odin's - Lvl 4100"] = {
        bodycolor = Color(176,37,37),
        clockspeed = 2.5,
        baseincome = 3542940,
        maxstorage = 100000000,
        sortorder = 1,
        batteryconsumption = .28,
        rechargeprice = 3000,
        repairprice = 2000,
        water_affect = 1,
        reward = 1,
        dmgresistance = .9,
        price = 265720500,
        max = 1,
        category = "Printers T3",
        upgrades = {
            {upgrade = "overclocking", baseprice = 563965500, max = 10, icon = Material("sprinter/overclock.png", "smooth")},
            {upgrade = "noisereduction", baseprice = 1500, max = 5, icon = Material("sprinter/noise.png", "smooth")},
            {upgrade = "dmgresistance", baseprice = 700, max = 5, icon = Material("sprinter/shield.png", "smooth")},
            {upgrade = "storage", baseprice = 3000, max = 5, increment = 10000, icon = Material("sprinter/storage.png", "smooth")},
            {upgrade = "notifications", baseprice = 500, max = 1, icon = Material("sprinter/bell.png", "smooth")}
        }
    }

    sPrinter.config.printers["God's - Lvl 4500"] = {
        bodycolor = Color(43,85,151),
        clockspeed = 2.5,
        baseincome = 10628820,
        maxstorage = 100000000,
        sortorder = 1,
        batteryconsumption = .28,
        rechargeprice = 3000,
        repairprice = 2000,
        water_affect = 1,
        reward = 1,
        dmgresistance = .9,
        price = 797161500,
        max = 1,
        category = "Printers T3",
        upgrades = {
            {upgrade = "overclocking", baseprice = 1691896500, max = 10, icon = Material("sprinter/overclock.png", "smooth")},
            {upgrade = "noisereduction", baseprice = 1500, max = 5, icon = Material("sprinter/noise.png", "smooth")},
            {upgrade = "dmgresistance", baseprice = 700, max = 5, icon = Material("sprinter/shield.png", "smooth")},
            {upgrade = "storage", baseprice = 3000, max = 5, increment = 10000, icon = Material("sprinter/storage.png", "smooth")},
            {upgrade = "notifications", baseprice = 500, max = 1, icon = Material("sprinter/bell.png", "smooth")}
        }
    }

    sPrinter.config.printers["Tier 4"] = {
        bodycolor = Color(188,188,0),
        clockspeed = 4.6,
        baseincome = 70,
        maxstorage = 800000,
        // sortorder = 4,
        batteryconsumption = .26,
        rechargeprice = 5000,
        repairprice = 2000,
        water_affect = 1,
        reward = .4,
        category = "VIP",
        // basevolume = 0.5, -- This is the base volume the printer makes, do not make it above 1 - each upgrade remove .1 from the basevolume. Example: basevolume as 0.5 will make it completely quiet if you have max 5 noise reduction upgrades.
        // cantwithdrawjobs = {["Citizen"] = true},
        // withdrawjobswhitelist = true -- this will determing if the list above is a whitelist or a blacklist
        // cantwithdrawusergroups = {["superadmin"] = true},
        xpmultiplier = .3, -- This is the amount of xp you will receive from withdrawing money - amount * multiplier
        // ignoretemperature = true,
        dmgresistance = .8,
        price = 12000,
        usergroup = {
            ["vip"] = true,
            ["user"] = true
        },
        failmsg = "You need VIP rank to purchase this printer!", --- This will popup if they arent in the usergroups stated above.
        max = 1,
        upgrades = {
            {upgrade = "overclocking", baseprice = 2000, max = 10, usergroup = {["vip"] = true, ["*"] = true}, icon = Material("sprinter/overclock.png", "smooth")},
            {upgrade = "noisereduction", baseprice = 1500, max = 8, icon = Material("sprinter/noise.png", "smooth")},
            {upgrade = "dmgresistance", baseprice = 700, max = 5, icon = Material("sprinter/shield.png", "smooth")},
            {upgrade = "notifications", baseprice = 500, max = 1, icon = Material("sprinter/bell.png", "smooth")}
        }
    }
    
    sPrinter.loadDarkRPContent()
end)