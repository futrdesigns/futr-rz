local inRedZone = false
local currentZone = nil
local playerStats = {kills = 0, deaths = 0, streak = 0}

-- Create blips for redzones
Citizen.CreateThread(function()
    for _, zone in ipairs(Config.RedZones) do
        if zone.blip.enabled then
            local blip = AddBlipForRadius(zone.coords.x, zone.coords.y, zone.coords.z, zone.radius)
            SetBlipHighDetail(blip, true)
            SetBlipColour(blip, zone.blip.color)
            SetBlipAlpha(blip, 128)
            
            local blipMarker = AddBlipForCoord(zone.coords.x, zone.coords.y, zone.coords.z)
            SetBlipSprite(blipMarker, zone.blip.sprite)
            SetBlipDisplay(blipMarker, 4)
            SetBlipScale(blipMarker, zone.blip.scale)
            SetBlipColour(blipMarker, zone.blip.color)
            SetBlipAsShortRange(blipMarker, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(zone.name .. " (RedZone)")
            EndTextCommandSetBlipName(blipMarker)
        end
    end
end)

-- Check if player is in redzone
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local wasInZone = inRedZone
        
        inRedZone = false
        for _, zone in ipairs(Config.RedZones) do
            local distance = #(playerCoords - zone.coords)
            if distance <= zone.radius then
                inRedZone = true
                if not wasInZone or currentZone ~= zone.name then
                    currentZone = zone.name
                    TriggerServerEvent('redzone:playerEntered', zone.name)
                    SendNUIMessage({type = "show"})
                end
                break
            end
        end
        
        if wasInZone and not inRedZone then
            TriggerServerEvent('redzone:playerLeft', currentZone)
            currentZone = nil
            SendNUIMessage({type = "hide"})
        end
    end
end)

-- Draw redzone boundaries and domes
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        if Config.Visual.showBoundary or Config.Visual.showDome then
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            
            for _, zone in ipairs(Config.RedZones) do
                local distance = #(playerCoords - zone.coords)
                
                -- Only draw if player is within render distance (500m)
                if distance < 500.0 then
                    local isInZone = distance <= zone.radius
                    
                    -- Pulse effect
                    local alpha = Config.Visual.boundaryColor[4]
                    if Config.Visual.pulseEffect then
                        local pulse = math.abs(math.sin(GetGameTimer() / 1000.0))
                        alpha = Config.Visual.boundaryColor[4] * (0.6 + pulse * 0.4)
                    end
                    
                    -- Draw ground circle boundary
                    if Config.Visual.showBoundary then
                        DrawMarker(
                            1, -- Cylinder marker
                            zone.coords.x, zone.coords.y, zone.coords.z - 1.0,
                            0.0, 0.0, 0.0,
                            0.0, 0.0, 0.0,
                            zone.radius * 2.0, zone.radius * 2.0, 2.0,
                            Config.Visual.boundaryColor[1],
                            Config.Visual.boundaryColor[2],
                            Config.Visual.boundaryColor[3],
                            alpha,
                            false, false, 2, false, nil, nil, false
                        )
                    end
                    
                    -- Draw dome based on type
                    if Config.Visual.showDome and Config.Visual.domeType ~= "none" then
                        local domeAlpha = isInZone and Config.Visual.domeColor[4] * 2 or Config.Visual.domeColor[4]
                        
                        if Config.Visual.domeType == "sphere" then
                            DrawSphereDome(zone, domeAlpha)
                        elseif Config.Visual.domeType == "hexagon" then
                            DrawHexagonDome(zone, domeAlpha)
                        elseif Config.Visual.domeType == "grid" then
                            DrawGridDome(zone, domeAlpha)
                        elseif Config.Visual.domeType == "pulse" then
                            DrawPulseDome(zone, domeAlpha)
                        end
                    end
                end
            end
        end
    end
end)

-- Dome drawing functions
function DrawSphereDome(zone, alpha)
    local segments = 20
    local maxHeight = zone.radius * Config.Visual.domeHeight
    
    for i = 0, segments do
        local height = (i / segments) * maxHeight
        local currentRadius = math.sqrt(zone.radius * zone.radius - height * height)
        
        if currentRadius > 0 then
            DrawMarker(
                1,
                zone.coords.x, zone.coords.y, zone.coords.z + height,
                0.0, 0.0, 0.0,
                0.0, 0.0, 0.0,
                currentRadius * 2.0, currentRadius * 2.0, 1.0,
                Config.Visual.domeColor[1],
                Config.Visual.domeColor[2],
                Config.Visual.domeColor[3],
                alpha,
                false, false, 2, false, nil, nil, false
            )
        end
    end
end

function DrawHexagonDome(zone, alpha)
    local segments = 15
    local sides = 6
    local maxHeight = zone.radius * Config.Visual.domeHeight
    
    for i = 0, segments do
        local height = (i / segments) * maxHeight
        local currentRadius = math.sqrt(zone.radius * zone.radius - height * height)
        
        if currentRadius > 0 then
            for side = 0, sides do
                local angle1 = (side / sides) * math.pi * 2
                local angle2 = ((side + 1) / sides) * math.pi * 2
                
                local x1 = zone.coords.x + math.cos(angle1) * currentRadius
                local y1 = zone.coords.y + math.sin(angle1) * currentRadius
                local x2 = zone.coords.x + math.cos(angle2) * currentRadius
                local y2 = zone.coords.y + math.sin(angle2) * currentRadius
                
                -- Draw line between hexagon points
                DrawLine(
                    x1, y1, zone.coords.z + height,
                    x2, y2, zone.coords.z + height,
                    Config.Visual.domeColor[1],
                    Config.Visual.domeColor[2],
                    Config.Visual.domeColor[3],
                    alpha * 2
                )
            end
        end
    end
end

function DrawGridDome(zone, alpha)
    local gridSegments = 12
    local heightSegments = 15
    local maxHeight = zone.radius * Config.Visual.domeHeight
    
    -- Vertical lines
    for i = 0, gridSegments do
        local angle = (i / gridSegments) * math.pi * 2
        local lastX, lastY, lastZ = nil, nil, nil
        
        for h = 0, heightSegments do
            local height = (h / heightSegments) * maxHeight
            local currentRadius = math.sqrt(math.max(0, zone.radius * zone.radius - height * height))
            
            local x = zone.coords.x + math.cos(angle) * currentRadius
            local y = zone.coords.y + math.sin(angle) * currentRadius
            local z = zone.coords.z + height
            
            if lastX then
                DrawLine(lastX, lastY, lastZ, x, y, z,
                    Config.Visual.domeColor[1],
                    Config.Visual.domeColor[2],
                    Config.Visual.domeColor[3],
                    alpha * 2
                )
            end
            lastX, lastY, lastZ = x, y, z
        end
    end
    
    -- Horizontal circles
    for i = 0, heightSegments, 2 do
        local height = (i / heightSegments) * maxHeight
        local currentRadius = math.sqrt(math.max(0, zone.radius * zone.radius - height * height))
        
        if currentRadius > 0 then
            DrawMarker(
                1,
                zone.coords.x, zone.coords.y, zone.coords.z + height,
                0.0, 0.0, 0.0,
                0.0, 0.0, 0.0,
                currentRadius * 2.0, currentRadius * 2.0, 0.5,
                Config.Visual.domeColor[1],
                Config.Visual.domeColor[2],
                Config.Visual.domeColor[3],
                alpha,
                false, false, 2, false, nil, nil, false
            )
        end
    end
end

function DrawPulseDome(zone, alpha)
    local segments = 20
    local maxHeight = zone.radius * Config.Visual.domeHeight
    local pulse = math.abs(math.sin(GetGameTimer() / 800.0))
    local pulseRadius = zone.radius + (pulse * 5.0)
    
    for i = 0, segments do
        local height = (i / segments) * maxHeight
        local baseRadius = math.sqrt(zone.radius * zone.radius - height * height)
        local currentRadius = math.sqrt(pulseRadius * pulseRadius - height * height)
        
        if currentRadius > 0 then
            local pulseAlpha = alpha * (1.0 - pulse * 0.5)
            
            DrawMarker(
                1,
                zone.coords.x, zone.coords.y, zone.coords.z + height,
                0.0, 0.0, 0.0,
                0.0, 0.0, 0.0,
                currentRadius * 2.0, currentRadius * 2.0, 1.5,
                Config.Visual.domeColor[1],
                Config.Visual.domeColor[2],
                Config.Visual.domeColor[3],
                pulseAlpha,
                false, false, 2, false, nil, nil, false
            )
        end
    end
end

-- Handle player death
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if inRedZone then
            local playerPed = PlayerPedId()
            if IsEntityDead(playerPed) then
                local killer = GetPedSourceOfDeath(playerPed)
                local killerEntity = GetPedInVehicleSeat(killer, -1)
                
                if killerEntity == 0 then
                    killerEntity = killer
                end
                
                if IsEntityAPed(killerEntity) and IsPedAPlayer(killerEntity) then
                    local killerId = NetworkGetPlayerIndexFromPed(killerEntity)
                    local killerServerId = GetPlayerServerId(killerId)
                    
                    if killerServerId ~= GetPlayerServerId(PlayerId()) then
                        TriggerServerEvent('redzone:playerKilled', killerServerId, currentZone)
                    end
                end
                
                Citizen.Wait(5000)
            end
        end
    end
end)

-- Respawn player at redzone spawn point
RegisterNetEvent('redzone:respawnPlayer')
AddEventHandler('redzone:respawnPlayer', function(zoneName)
    local playerPed = PlayerPedId()
    
    -- Get all spawn points for this zone
    local zoneSpawns = {}
    for _, spawn in ipairs(Config.RespawnLocations) do
        if spawn.zone == zoneName then
            table.insert(zoneSpawns, spawn)
        end
    end
    
    if #zoneSpawns > 0 then
        -- Pick random spawn point
        local spawnPoint = zoneSpawns[math.random(1, #zoneSpawns)]
        
        -- Revive and teleport
        local playerPed = PlayerPedId()
        local coords = spawnPoint.coords
        
        NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, spawnPoint.coords.w, true, false)
        SetEntityCoords(playerPed, coords.x, coords.y, coords.z, false, false, false, true)
        SetEntityHeading(playerPed, spawnPoint.coords.w)
        ClearPedTasksImmediately(playerPed)
        
        -- Set health
        SetEntityHealth(playerPed, GetEntityMaxHealth(playerPed))
        
        -- Clear weapons if you want
        -- RemoveAllPedWeapons(playerPed, true)
        
        -- Notification
        TriggerEvent('chat:addMessage', {
            color = {255, 165, 0},
            multiline = true,
            args = {"Respawn", "You respawned at " .. zoneName}
        })
    end
end)

-- Add kill to feed
RegisterNetEvent('redzone:addKillFeed')
AddEventHandler('redzone:addKillFeed', function(killerName, victimName)
    if Config.KillFeed.enabled then
        SendNUIMessage({
            type = "addKill",
            killer = killerName,
            victim = victimName
        })
    end
end)

-- Request stats on resource start
AddEventHandler('onClientResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        Citizen.Wait(1000)
        TriggerServerEvent('redzone:requestStats')
        
        -- Set kill feed position
        SendNUIMessage({
            type = "setKillFeedPosition",
            position = Config.KillFeed.position
        })
        
        -- Send UI colors to HTML
        SendNUIMessage({
            type = "setColors",
            colors = {
                primary = string.format("rgb(%d, %d, %d)", Config.UIColors.primary[1], Config.UIColors.primary[2], Config.UIColors.primary[3]),
                kills = string.format("rgb(%d, %d, %d)", Config.UIColors.kills[1], Config.UIColors.kills[2], Config.UIColors.kills[3]),
                deaths = string.format("rgb(%d, %d, %d)", Config.UIColors.deaths[1], Config.UIColors.deaths[2], Config.UIColors.deaths[3]),
                streak = string.format("rgb(%d, %d, %d)", Config.UIColors.streak[1], Config.UIColors.streak[2], Config.UIColors.streak[3])
            }
        })
    end
end)

-- Update UI with stats
RegisterNetEvent('redzone:updateStats')
AddEventHandler('redzone:updateStats', function(stats)
    playerStats = stats
    SendNUIMessage({
        type = "updateStats",
        kills = stats.kills,
        deaths = stats.deaths,
        streak = stats.streak
    })
end)
