--[[ LUA CONFIG ]]--
BRICKS_SERVER.ESSENTIALS.LUACFG = {}
BRICKS_SERVER.ESSENTIALS.LUACFG.UseMySQL = false -- Whether or not MySQL should be used (enter your details in bricks-essentials/lua/bricks_server/bricks_essentials/sv_mysql.lua)

BRICKS_SERVER.ESSENTIALS.LUACFG.F4Commands = { -- The commands that show up in the F4 menu, 1st value is the title, 2nd is the table of commands and 3rd is a custom check
    { "General", {
        { "Drop Money", "/dropmoney", { { "number", "How much money do you want to drop?" } } },
        { "Give Money", "/give", { { "number", "How much do you want to give?" } } },
        { "Change Name", "/rpname", { { "string", "What should your new name be?" } } },
        { "Drop Weapon", "/drop" },
        { "Holster Weapon", "/holster" },
        { "Sell All Doors", "/sellalldoors" },
        { "Change Job Name", "/job", { { "string", "What should your new job name be?" } } },
    } },
    { "Police", {
        { "Make Wanted", "/wanted", { { "players", "What player do you want to make wanted?" }, { "string", "What is the reason for them being wanted?" } } },
        { "Make Unwanted", "/unwanted", { { "players", "What player do you want to make unwanted?" }, { "string", "What is the reason for them being unwanted?" } } },
        { "Request Warrant", "/warrant", { { "players", "What player do you want a warrant for?" }, { "string", "What is the reason for the warrant?" } } }
    }, function( ply ) 
        if( ply:isCP() ) then
            return true
        else
            return false
        end
    end }
}

BRICKS_SERVER.ESSENTIALS.LUACFG.ItemDescriptions = { -- Give an item a custom description, put the class of the weapon or name of the resource
    ["weapon_crowbar"] = "A bar used to pry things open!",
    ["bricks_server_axe"] = "Used to chop wood.",
    ["bricks_server_pickaxe"] = "Used to mine rocks."
}

BRICKS_SERVER.ESSENTIALS.LUACFG.HolsterCommands = {
    ["!holster"] = true,
    ["/holster"] = true,
    ["!invholster"] = true,
    ["/invholster"] = true
}