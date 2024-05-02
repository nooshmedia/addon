TEAM_BSMINER = DarkRP.createJob("Miner", {
    color = Color(196, 196, 196, 255),
    model = {"models/player/eli.mdl"},
    description = [[The Miner must go into the mines and collect precious stones and ores in order to craft items!]],
    weapons = {"bricks_server_pickaxe"},
    command = "miner",
    max = 0,
    salary = 25,
    admin = 0,
    vote = false,
    hasLicense = false,
    candemote = false,
    category = "Citizens"
})

TEAM_BSLUMBERJACK = DarkRP.createJob("Lumberjack", {
    color = Color(196, 196, 196, 255),
    model = {"models/player/odessa.mdl"},
    description = [[The lumberjack must go into the forest and cut down trees for wood and other materials!]],
    weapons = {"bricks_server_axe"},
    command = "lumberjack",
    max = 0,
    salary = 25,
    admin = 0,
    vote = false,
    hasLicense = false,
    candemote = false,
    category = "Citizens",
    sortOrder = 100,
})