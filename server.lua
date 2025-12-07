local playerStats = {}

RegisterNetEvent('redzone:playerEntered')
AddEventHandler('redzone:playerEntered', function(zoneName)
    local src = source
    if not playerStats[src] then
        playerStats[src] = {kills = 0, deaths = 0, streak = 0}
    end
    TriggerClientEvent('chat:addMessage', src, {
        color = {255, 0, 0},
        multiline = true,
        args = {"RedZone", "You entered " .. zoneName .. "! PvP is enabled!"}
    })
end)

RegisterNetEvent('redzone:playerLeft')
AddEventHandler('redzone:playerLeft', function(zoneName)
    local src = source
    TriggerClientEvent('chat:addMessage', src, {
        color = {0, 255, 0},
        multiline = true,
        args = {"RedZone", "You left " .. zoneName .. ". You are now safe."}
    })
end)

RegisterNetEvent('redzone:playerKilled')
AddEventHandler('redzone:playerKilled', function(killerId, victimZone)
    local victim = source
    
    if not playerStats[killerId] then
        playerStats[killerId] = {kills = 0, deaths = 0, streak = 0}
    end
    if not playerStats[victim] then
        playerStats[victim] = {kills = 0, deaths = 0, streak = 0}
    end
    
    -- Update stats
    playerStats[killerId].kills = playerStats[killerId].kills + 1
    playerStats[killerId].streak = playerStats[killerId].streak + 1
    playerStats[victim].deaths = playerStats[victim].deaths + 1
    playerStats[victim].streak = 0
    
    -- Give rewards
    GiveKillReward(killerId, playerStats[killerId].kills)
    
    -- Check streak rewards
    CheckStreakReward(killerId, playerStats[killerId].streak)
    
    -- Update UI for both players
    TriggerClientEvent('redzone:updateStats', killerId, playerStats[killerId])
    TriggerClientEvent('redzone:updateStats', victim, playerStats[victim])
    
    -- Get player names
    local killerName = GetPlayerName(killerId)
    local victimName = GetPlayerName(victim)
    
    -- Send kill feed to all players in redzone
    local players = GetPlayers()
    for _, playerId in ipairs(players) do
        TriggerClientEvent('redzone:addKillFeed', playerId, killerName, victimName)
    end
    
    -- Notify killer
    TriggerClientEvent('chat:addMessage', killerId, {
        color = {255, 0, 0},
        multiline = true,
        args = {"Kill", "You killed " .. victimName}
    })
    
    TriggerClientEvent('chat:addMessage', victim, {
        color = {255, 0, 0},
        multiline = true,
        args = {"Death", "You were killed by " .. killerName}
    })
    
    -- Handle respawn
    if Config.RespawnInRedZone then
        Citizen.Wait(5000) -- Wait for death animation
        TriggerClientEvent('redzone:respawnPlayer', victim, victimZone)
    end
end)

function GiveKillReward(playerId, totalKills)
    if not Config.EnableRewards then return end
    
    for _, reward in ipairs(Config.Rewards) do
        if totalKills == reward.kills then
            -- Give money
            TriggerEvent('esx:getSharedObject', function(ESX)
                local xPlayer = ESX.GetPlayerFromId(playerId)
                if xPlayer then
                    xPlayer.addMoney(reward.money)
                end
            end)
            
            -- Alternative for non-ESX servers
            -- Just add your own money system here
            
            -- Give items
            for _, item in ipairs(reward.items) do
                -- TriggerEvent for your inventory system
                -- Example: xPlayer.addInventoryItem(item.name, item.count)
            end
            
            TriggerClientEvent('chat:addMessage', playerId, {
                color = {0, 255, 0},
                multiline = true,
                args = {"Reward", "Kill reward: $" .. reward.money}
            })
        end
    end
end

function CheckStreakReward(playerId, streak)
    if not Config.EnableStreakRewards then return end
    
    for _, streakReward in ipairs(Config.StreakRewards) do
        if streak == streakReward.streak then
            -- Give streak bonus
            TriggerEvent('esx:getSharedObject', function(ESX)
                local xPlayer = ESX.GetPlayerFromId(playerId)
                if xPlayer then
                    xPlayer.addMoney(streakReward.money)
                end
            end)
            
            TriggerClientEvent('chat:addMessage', playerId, {
                color = {255, 215, 0},
                multiline = true,
                args = {"Streak Bonus", streakReward.message}
            })
        end
    end
end

RegisterNetEvent('redzone:requestStats')
AddEventHandler('redzone:requestStats', function()
    local src = source
    if not playerStats[src] then
        playerStats[src] = {kills = 0, deaths = 0, streak = 0}
    end
    TriggerClientEvent('redzone:updateStats', src, playerStats[src])
end)

AddEventHandler('playerDropped', function()
    local src = source
    playerStats[src] = nil
end)
