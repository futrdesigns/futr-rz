Config = {}

-- RedZone Locations
Config.RedZones = {
    {
        name = "Grove Street",
        coords = vector3(-48.0, -1760.0, 29.0),
        radius = 80.0,
        blip = {
            enabled = true,
            sprite = 84,
            color = 1,
            scale = 1.0
        }
    },
    {
        name = "Sandy Shores",
        coords = vector3(1960.0, 3740.0, 32.0),
        radius = 120.0,
        blip = {
            enabled = true,
            sprite = 84,
            color = 1,
            scale = 1.0
        }
    }
}

-- Kill Rewards Configuration
Config.EnableRewards = true -- Enable/disable all reward systems

Config.Rewards = {
    {
        kills = 1,
        money = 500,
        items = {
            -- {name = "bandage", count = 1}
        }
    },
    {
        kills = 3,
        money = 1000,
        items = {
            -- {name = "medkit", count = 1}
        }
    },
    {
        kills = 5,
        money = 2500,
        items = {
            -- {name = "armor", count = 1}
        }
    },
    {
        kills = 10,
        money = 5000,
        items = {
            -- {name = "weapon_pistol", count = 1}
        }
    }
}

-- Streak Rewards (bonus for consecutive kills)
Config.EnableStreakRewards = true -- Enable/disable streak bonuses

Config.StreakRewards = {
    {
        streak = 3,
        money = 1000,
        message = "~r~3 Kill Streak! ~w~Bonus: $1000"
    },
    {
        streak = 5,
        money = 2500,
        message = "~r~5 Kill Streak! ~w~Bonus: $2500"
    },
    {
        streak = 10,
        money = 5000,
        message = "~r~10 Kill Streak! ~w~UNSTOPPABLE! Bonus: $5000"
    }
}

-- General Settings
Config.EnableDamageReduction = false -- Reduce damage in redzone
Config.DamageMultiplier = 1.0 -- 1.0 = normal damage
Config.RespawnInRedZone = true -- Respawn in same redzone after death
Config.ShowNotifications = true -- Show kill notifications

-- Visual Settings
Config.Visual = {
    showBoundary = true, -- Show red circle boundary
    showDome = true, -- Show dome effect
    domeType = "sphere", -- Options: "sphere", "hexagon", "grid", "pulse", "none"
    boundaryColor = {255, 0, 0, 200}, -- RGBA for boundary circle
    domeColor = {255, 0, 0, 30}, -- RGBA for dome (semi-transparent)
    pulseEffect = true, -- Pulse effect on boundary
    domeHeight = 1.0, -- Multiplier for dome height (1.0 = full sphere, 0.5 = half dome)
}

-- Respawn Locations (if RespawnInRedZone is true, random location from this list)
Config.RespawnLocations = {
    -- Grove Street Spawns
    {zone = "Grove Street", coords = vector4(-98.0, -1760.0, 29.0, 90.0)},
    {zone = "Grove Street", coords = vector4(2.0, -1760.0, 29.0, 270.0)},
    {zone = "Grove Street", coords = vector4(-48.0, -1710.0, 29.0, 180.0)},
    {zone = "Grove Street", coords = vector4(-48.0, -1810.0, 29.0, 0.0)},
    
    -- Sandy Shores Spawns
    {zone = "Sandy Shores", coords = vector4(1910.0, 3740.0, 32.0, 90.0)},
    {zone = "Sandy Shores", coords = vector4(2010.0, 3740.0, 32.0, 270.0)},
    {zone = "Sandy Shores", coords = vector4(1960.0, 3690.0, 32.0, 180.0)},
    {zone = "Sandy Shores", coords = vector4(1960.0, 3790.0, 32.0, 0.0)},
}

-- Kill Feed Settings
Config.KillFeed = {
    enabled = true,
    position = "top-right", -- Options: "top-left", "top-center", "top-right"
    maxEntries = 5, -- Maximum number of kills to show
    displayTime = 5000, -- Time in ms each kill stays visible
}

-- UI Color Settings (RGB format)
Config.UIColors = {
    primary = {255, 0, 0}, -- Main accent color (red by default) - affects borders, headers, icons
    kills = {0, 255, 0}, -- Kills stat color (green by default)
    deaths = {255, 0, 0}, -- Deaths stat color (red by default)
    streak = {255, 215, 0}, -- Streak stat color (gold by default)
}
