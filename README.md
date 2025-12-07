# Futr's FiveM RedZone Script

A comprehensive RedZone script for FiveM servers featuring customizable PvP zones, kill tracking, rewards system, and visual dome effects.

## Features

- Multiple configurable RedZone locations
- Real-time kill/death/streak tracking UI
- Live kill feed with configurable position
- Automatic respawn system at zone edges
- Kill rewards and streak bonuses (toggleable)
- Visual dome effects with multiple styles
- Fully customizable colors and settings
- Map blips and markers

## Installation

1. Download and extract the `futr-rz` folder to your server's `resources` directory
2. Add `ensure futr-rz` to your `server.cfg`
3. Configure settings in `config.lua`
4. Restart your server

## File Structure

```
resources/[scripts]/futr-rz
├── fxmanifest.lua
├── config.lua
├── server.lua
├── client.lua
└── html/
    └── index.html
```

## Configuration

### RedZone Locations

Define your RedZones in `Config.RedZones`:

```lua
{
    name = "Legion Square",
    coords = vector3(195.0, -933.0, 30.0),
    radius = 100.0,
    blip = {
        enabled = true,
        sprite = 84,
        color = 1,
        scale = 1.0
    }
}
```

### Respawn Points

Configure spawn locations in `Config.RespawnLocations`. Each spawn needs:
- `zone` - Name of the RedZone (must match exactly)
- `coords` - vector4(x, y, z, heading)

### Rewards System

Toggle rewards on/off:
```lua
Config.EnableRewards = true
Config.EnableStreakRewards = true
```

Configure rewards for kill milestones and streaks in `Config.Rewards` and `Config.StreakRewards`.

### Visual Effects

#### Dome Types

Choose from 5 dome styles in `Config.Visual.domeType`:
- `"sphere"` - Smooth spherical dome (default)
- `"hexagon"` - Hexagonal honeycomb pattern
- `"grid"` - Wire-frame grid structure
- `"pulse"` - Animated pulsing effect
- `"none"` - No dome, boundary only

#### Visual Settings

```lua
Config.Visual = {
    showBoundary = true,
    showDome = true,
    domeType = "sphere",
    boundaryColor = {255, 0, 0, 200},
    domeColor = {255, 0, 0, 30},
    pulseEffect = true,
    domeHeight = 1.0
}
```

### UI Customization

#### Colors

Customize all UI colors in `Config.UIColors`:
```lua
Config.UIColors = {
    primary = {255, 0, 0},    -- Borders, headers
    kills = {0, 255, 0},       -- Kill stat
    deaths = {255, 0, 0},      -- Death stat
    streak = {255, 215, 0}     -- Streak stat
}
```

#### Kill Feed

Configure kill feed position:
```lua
Config.KillFeed = {
    enabled = true,
    position = "top-right", -- "top-left", "top-center", "top-right"
    maxEntries = 5,
    displayTime = 5000
}
```

## Framework Support

The script includes ESX integration by default. For other frameworks (QBCore, vRP, etc.), modify the `GiveKillReward` function in `server.lua` to match your framework's money/item functions.

### ESX Example (Included)
```lua
TriggerEvent('esx:getSharedObject', function(ESX)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if xPlayer then
        xPlayer.addMoney(reward.money)
    end
end)
```

### QBCore Example
```lua
local Player = QBCore.Functions.GetPlayer(playerId)
if Player then
    Player.Functions.AddMoney('cash', reward.money)
end
```

## How It Works

1. Players entering a RedZone see the stats UI appear on the right
2. A dome/boundary appears around the zone (visible from inside and outside)
3. Kills are tracked and displayed in real-time
4. Kill feed shows recent eliminations at the top of screen
5. Players receive rewards for reaching kill milestones and streaks
6. On death, players respawn at configured spawn points around the zone
7. Stats persist for the duration of the session

## Performance

- Visual effects only render within 500m of zones
- Optimized dome rendering based on type
- Sphere dome offers best performance
- Grid dome is slightly more intensive

## Support

For support, bug reports, or feature requests:
- Discord: https://discord.gg/XQ8seNVz6M

## License

This script is provided as-is for FiveM servers.
