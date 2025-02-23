local QBCore = exports['qb-core']:GetCoreObject()

-- Localize commonly used functions for performance
local DoesEntityExist = DoesEntityExist
local IsEntityAPed = IsEntityAPed
local IsPedAPlayer = IsPedAPlayer
local IsPedDeadOrDying = IsPedDeadOrDying
local IsPedInAnyVehicle = IsPedInAnyVehicle
local GetEntityCoords = GetEntityCoords
local PlayerPedId = PlayerPedId
local Wait = Wait

-- Initialize variables
local isPickpocketing = false
local validTargets = {}
local lastValidationTime = 0
local validationInterval = 1000 -- Validate targets every second
local maxTargetDistance = 50.0 -- Maximum distance to track potential targets
local performanceMetrics = {
    entityChecks = 0,
    validTargets = 0,
    lastReset = 0
}

-- Function to check if entity is valid for pickpocketing
local function IsValidTarget(entity)
    if Config.Debug then performanceMetrics.entityChecks = performanceMetrics.entityChecks + 1 end
    
    if not entity or not DoesEntityExist(entity) then return false end
    
    -- Quick checks first (most likely to fail)
    if IsPedAPlayer(entity) then return false end
    if IsPedDeadOrDying(entity) then return false end
    if IsPedInAnyVehicle(entity, false) then return false end
    if IsPedFleeing(entity) then return false end
    if IsPedInMeleeCombat(entity) then return false end
    if IsPedCuffed(entity) then return false end
    
    -- Model check for blacklisted peds
    local pedModel = GetEntityModel(entity)
    for _, blacklistedModel in ipairs(Config.BlacklistedPeds) do
        if pedModel == GetHashKey(blacklistedModel) then
            return false
        end
    end
    
    -- Check for any active scenarios that should prevent pickpocketing
    local currentScenario = GetScriptTaskStatus(entity, 0x6F1C03C4)
    if currentScenario == 0 or currentScenario == 1 then
        local scenarioType = GetPedScenarioName(entity)
        local blacklistedScenarios = {
            'WORLD_HUMAN_COP_IDLES',
            'WORLD_HUMAN_GUARD_STAND',
            'WORLD_HUMAN_SECURITY_SHINE_TORCH'
        }
        for _, scenario in ipairs(blacklistedScenarios) do
            if scenarioType == scenario then
                return false
            end
        end
    end
    
    return true
end

-- Function to efficiently maintain valid targets list
local function UpdateValidTargets()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local newValidTargets = {}
    local validCount = 0
    
    -- Get all peds in the area efficiently
    local peds = GetGamePool('CPed')
    for _, ped in ipairs(peds) do
        if DoesEntityExist(ped) and not IsPedAPlayer(ped) then
            local pedCoords = GetEntityCoords(ped)
            local distance = #(playerCoords - pedCoords)
            
            if distance <= maxTargetDistance then
                if IsValidTarget(ped) then
                    newValidTargets[ped] = distance
                    validCount = validCount + 1
                end
            end
        end
    end
    
    validTargets = newValidTargets
    if Config.Debug then performanceMetrics.validTargets = validCount end
end

-- Main optimization thread for distance checking and target validation
CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local sleep = validationInterval
        
        -- Check if we're near any valid targets
        local nearTarget = false
        for ped, distance in pairs(validTargets) do
            if DoesEntityExist(ped) then
                local pedCoords = GetEntityCoords(ped)
                local newDistance = #(playerCoords - pedCoords)
                
                if newDistance <= 2.0 then
                    nearTarget = true
                    sleep = 0
                    break
                end
            end
        end
        
        -- Update validation interval based on proximity
        if nearTarget then
            validationInterval = 500 -- More frequent updates when near targets
        else
            validationInterval = 1000 -- Default interval when no targets nearby
        end
        
        Wait(sleep)
    end
end)

-- Optimization thread for target validation
CreateThread(function()
    while true do
        local currentTime = GetGameTimer()
        
        -- Only update valid targets periodically
        if currentTime - lastValidationTime >= validationInterval then
            UpdateValidTargets()
            lastValidationTime = currentTime
        end
        
        -- Performance metrics reset (if debug enabled)
        if Config.Debug and currentTime - performanceMetrics.lastReset >= 60000 then
            print(string.format('Pickpocket Performance Metrics:\nEntity Checks: %d\nValid Targets: %d\nMemory Usage: %.2f MB',
                performanceMetrics.entityChecks,
                performanceMetrics.validTargets,
                collectgarbage('count') / 1024
            ))
            performanceMetrics.entityChecks = 0
            performanceMetrics.validTargets = 0
            performanceMetrics.lastReset = currentTime
        end
        
        Wait(validationInterval)
    end
end)

-- Function to start pickpocketing process with optimization
local function StartPickpocketing(entity)
    if isPickpocketing or not validTargets[entity] then return end
    
    local playerPed = PlayerPedId()
    local targetCoords = GetEntityCoords(entity)
    local playerCoords = GetEntityCoords(playerPed)
    local distance = #(playerCoords - targetCoords)
    
    -- Distance check before proceeding
    if distance > 2.0 then return end
    
    isPickpocketing = true
    local netId = NetworkGetNetworkIdFromEntity(entity)
    
    -- Animation handling with proper cleanup
    RequestAnimDict("mp_common")
    local timeout = GetGameTimer() + 1000
    
    while not HasAnimDictLoaded("mp_common") and GetGameTimer() < timeout do
        Wait(0)
    end
    
    if not HasAnimDictLoaded("mp_common") then
        isPickpocketing = false
        return
    end
    
    -- Face the target and perform animation
    TaskTurnPedToFaceCoord(playerPed, targetCoords.x, targetCoords.y, targetCoords.z, 1000)
    Wait(1000)
    
    if not DoesEntityExist(entity) then -- Entity validation before animation
        isPickpocketing = false
        RemoveAnimDict("mp_common")
        return
    end
    
    TaskPlayAnim(playerPed, "mp_common", "givetake1_a", 8.0, -8.0, 2000, 0, 0, false, false, false)
    Wait(2000)
    
    -- Trigger server event
    TriggerServerEvent('rd-pickpocket:server:attemptPickpocket', netId)
    
    -- Cleanup
    isPickpocketing = false
    ClearPedTasks(playerPed)
    RemoveAnimDict("mp_common")
end

-- Optimized target setup
local function SetupTargetOptions()
    exports['qb-target']:AddGlobalPed({
        options = {
            {
                icon = "fas fa-hand-paper",
                label = "Pickpocket",
                action = function(entity)
                    StartPickpocketing(entity)
                end,
                canInteract = function(entity)
                    return validTargets[entity] and not isPickpocketing
                end,
            }
        },
        distance = 2.0
    })
end

-- Optimized wallet usage event
RegisterNetEvent('rd-pickpocket:client:useWallet', function(walletType)
    if isPickpocketing then return end
    
    local ped = PlayerPedId()
    
    RequestAnimDict("mp_arresting")
    local timeout = GetGameTimer() + 1000
    
    while not HasAnimDictLoaded("mp_arresting") and GetGameTimer() < timeout do
        Wait(0)
    end
    
    if not HasAnimDictLoaded("mp_arresting") then return end
    
    TaskPlayAnim(ped, "mp_arresting", "a_uncuff", 8.0, -8.0, 2000, 0, 0, false, false, false)
    Wait(2000)
    
    TriggerServerEvent('rd-pickpocket:server:searchWallet', walletType)
    
    -- Cleanup
    RemoveAnimDict("mp_arresting")
end)

-- Optimized NPC reaction events
RegisterNetEvent('rd-pickpocket:client:successfulAttempt', function(netId)
    local entity = NetworkGetEntityFromNetworkId(netId)
    if not DoesEntityExist(entity) then return end
    
    ClearPedTasks(entity)
    TaskWanderStandard(entity, 10.0, 10)
end)

RegisterNetEvent('rd-pickpocket:client:failedAttempt', function(netId)
    local entity = NetworkGetEntityFromNetworkId(netId)
    if not DoesEntityExist(entity) then return end
    
    local playerPed = PlayerPedId()
    
    TaskTurnPedToFaceEntity(entity, playerPed, 1000)
    Wait(1000)
    
    if math.random(1, 100) > 50 then
        TaskSmartFleePed(entity, playerPed, 100.0, -1, false, false)
        SetPedKeepTask(entity, true)
    else
        RequestAnimDict("mp_common")
        if not HasAnimDictLoaded("mp_common") then return end
        
        TaskPlayAnim(entity, "mp_common", "gesture_bring_it_on", 8.0, -8.0, 2000, 0, 0, false, false, false)
        Wait(2000)
        
        TaskWanderStandard(entity, 10.0, 10)
        RemoveAnimDict("mp_common")
    end
end)

-- Police alert with optimization
RegisterNetEvent('rd-pickpocket:client:alertPolice', function()
    local coords = GetEntityCoords(PlayerPedId())
    
    exports['ps-dispatch']:CustomAlert({
        coords = coords,
        message = "Attempted Pickpocketing",
        dispatchCode = "10-66",
        description = "Attempted Pickpocketing at " .. GetStreetNameFromHashKey(GetStreetNameAtCoord(coords.x, coords.y, coords.z)),
        radius = 0,
        sprite = 52,
        color = 2,
        scale = 1.0,
        length = 3,
    })
end)

-- Initialize systems
CreateThread(function()
    SetupTargetOptions()
end)

-- Debug command with performance metrics
if Config.Debug then
    RegisterCommand('testpickpocket', function()
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
        local found = false
        
        print('Current Performance Metrics:')
        print(string.format('Entity Checks: %d', performanceMetrics.entityChecks))
        print(string.format('Valid Targets: %d', performanceMetrics.validTargets))
        print(string.format('Memory Usage: %.2f MB', collectgarbage('count') / 1024))
        
        for ped, distance in pairs(validTargets) do
            local pedCoords = GetEntityCoords(ped)
            local dist = #(coords - pedCoords)
            if dist < 3.0 then
                print('Found valid ped: ' .. ped .. ' at distance: ' .. dist)
                found = true
            end
        end
        
        if not found then
            print('No valid peds found nearby')
        end
    end)
end