local QBCore = exports['qb-core']:GetCoreObject()

-- Performance tracking
local performanceMetrics = {
    pickpocketAttempts = 0,
    successfulPickpockets = 0,
    walletsSearched = 0,
    lastReset = os.time()
}

-- Cooldown tracking tables with garbage collection
local playerCooldowns = {}
local npcCooldowns = {}
local lastCleanup = os.time()

-- Initialize inventory functions with caching
local AddItem, RemoveItem, GetItemCount, CanCarryItem

-- Initialize inventory system based on config
if not Config.UseQBInventory then
    -- QS-Inventory Functions
    AddItem = function(source, item, amount, info)
        return exports['qs-inventory']:AddItem(source, item, amount, false, info)
    end

    RemoveItem = function(source, item, amount)
        return exports['qs-inventory']:RemoveItem(source, item, amount)
    end

    GetItemCount = function(source, item)
        return exports['qs-inventory']:GetItemTotalAmount(source, item)
    end

    CanCarryItem = function(source, item, amount)
        return exports['qs-inventory']:CanCarryItem(source, item, amount)
    end
else
    -- QB-Inventory Functions
    AddItem = function(source, item, amount, info)
        local Player = QBCore.Functions.GetPlayer(source)
        if not Player then return false end
        return Player.Functions.AddItem(item, amount, false, info)
    end

    RemoveItem = function(source, item, amount)
        local Player = QBCore.Functions.GetPlayer(source)
        if not Player then return false end
        return Player.Functions.RemoveItem(item, amount)
    end

    GetItemCount = function(source, item)
        local Player = QBCore.Functions.GetPlayer(source)
        if not Player then return 0 end
        return Player.Functions.GetItemByName(item)
    end

    CanCarryItem = function(source, item, amount)
        return exports['qb-inventory']:CanCarryItem(source, item, amount)
    end
end

-- Function to clean cooldown tables and collect performance metrics
local function CleanupTables()
    local currentTime = os.time()
    
    -- Clean cooldowns every 15 minutes
    if currentTime - lastCleanup >= 900 then
        -- Clean player cooldowns
        for player, time in pairs(playerCooldowns) do
            if (currentTime - time) > Config.PlayerCooldown then
                playerCooldowns[player] = nil
            end
        end
        
        -- Clean NPC cooldowns
        for npc, time in pairs(npcCooldowns) do
            if (currentTime - time) > Config.NPCCooldown then
                npcCooldowns[npc] = nil
            end
        end
        
        lastCleanup = currentTime
        
        -- Log performance metrics if debug is enabled
        if Config.Debug then
            local timeElapsed = currentTime - performanceMetrics.lastReset
            print(string.format(
                'Pickpocket Performance Metrics (Last %d minutes):\nTotal Attempts: %d\nSuccessful Pickpockets: %d\nWallets Searched: %d\nSuccess Rate: %.2f%%',
                timeElapsed / 60,
                performanceMetrics.pickpocketAttempts,
                performanceMetrics.successfulPickpockets,
                performanceMetrics.walletsSearched,
                (performanceMetrics.successfulPickpockets / math.max(1, performanceMetrics.pickpocketAttempts)) * 100
            ))
            
            -- Reset metrics
            performanceMetrics.pickpocketAttempts = 0
            performanceMetrics.successfulPickpockets = 0
            performanceMetrics.walletsSearched = 0
            performanceMetrics.lastReset = currentTime
        end
    end
end

-- Function to check cooldowns
local function CheckCooldowns(playerId, npcNetId)
    local currentTime = os.time()
    
    -- Check player cooldown
    if playerCooldowns[playerId] and (currentTime - playerCooldowns[playerId]) < Config.PlayerCooldown then
        return false, "player"
    end
    
    -- Check NPC cooldown
    if npcCooldowns[npcNetId] and (currentTime - npcCooldowns[npcNetId]) < Config.NPCCooldown then
        return false, "npc"
    end
    
    return true
end

-- Function to determine wallet type and money amount
local function GenerateWalletLoot()
    local random = math.random(1, 100)
    local currentTotal = 0
    
    -- Determine wallet type
    local selectedWallet = nil
    for walletType, data in pairs(Config.WalletTypes) do
        currentTotal = currentTotal + data.chance
        if random <= currentTotal then
            selectedWallet = {type = walletType, data = data}
            break
        end
    end
    
    -- Generate money amount based on wallet type
    local moneyAmount = math.random(selectedWallet.data.minMoney, selectedWallet.data.maxMoney)
    
    return selectedWallet.type, moneyAmount
end

-- Function to generate additional loot
local function GenerateAdditionalLoot()
    local loot = {}
    
    for item, data in pairs(Config.AdditionalLoot) do
        if math.random(1, 100) <= data.chance then
            local amount = math.random(data.min, data.max)
            loot[#loot + 1] = {
                item = item,
                amount = amount
            }
        end
    end
    
    return loot
end

-- Function to handle money rewards
local function GiveMoneyReward(source, amount)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return false end

    -- Determine money type based on configuration chances
    local random = math.random(1, 100)
    local isDirtyMoney = random > Config.MoneyType.clean.chance

    -- Handle dirty money
    if isDirtyMoney and Config.MoneyType.dirty.enabled then
        if AddItem(source, Config.MoneyType.dirty.item, amount) then
            TriggerClientEvent('QBCore:Notify', source, 'Found $' .. amount .. ' in marked bills!', 'success')
            return true
        end
    -- Handle clean money
    elseif Config.MoneyType.clean.enabled then
        if Player.Functions.AddMoney(Config.MoneyType.clean.account, amount) then
            TriggerClientEvent('QBCore:Notify', source, 'Found $' .. amount .. ' in cash!', 'success')
            return true
        end
    end
    
    return false
end

-- Register useable items
local function RegisterItems()
    local walletTypes = {'regular_wallet', 'premium_wallet', 'empty_wallet'}
    for _, walletType in ipairs(walletTypes) do
        QBCore.Functions.CreateUseableItem(walletType, function(source, item)
            TriggerClientEvent('rd-pickpocket:client:useWallet', source, walletType)
        end)
    end
end

-- Handle wallet searching with error handling
RegisterNetEvent('rd-pickpocket:server:searchWallet', function(walletType)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    -- Remove the wallet
    if not RemoveItem(src, walletType, 1) then
        TriggerClientEvent('QBCore:Notify', src, 'Error processing wallet!', 'error')
        return
    end

    -- Generate money based on wallet type
    local walletData = Config.WalletTypes[walletType]
    if not walletData then return end

    local moneyAmount = math.random(walletData.minMoney, walletData.maxMoney)
    
    -- Give money reward
    local moneyGiven = GiveMoneyReward(src, moneyAmount)
    if not moneyGiven then
        TriggerClientEvent('QBCore:Notify', src, Config.Notifications.inventory_full, 'error')
        return
    end

    -- Handle additional loot
    local additionalLoot = GenerateAdditionalLoot()
    for _, lootData in ipairs(additionalLoot) do
        if CanCarryItem(src, lootData.item, lootData.amount) then
            if AddItem(src, lootData.item, lootData.amount) then
                TriggerClientEvent('QBCore:Notify', src, 'Found ' .. lootData.amount .. 'x ' .. QBCore.Shared.Items[lootData.item].label .. '!', 'success')
            end
        end
    end

    -- Update metrics
    performanceMetrics.walletsSearched = performanceMetrics.walletsSearched + 1
end)

-- Handle pickpocket attempt with error handling
RegisterNetEvent('rd-pickpocket:server:attemptPickpocket', function(npcNetId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    
    -- Update metrics
    performanceMetrics.pickpocketAttempts = performanceMetrics.pickpocketAttempts + 1
    
    -- Check cooldowns
    local canPickpocket, cooldownType = CheckCooldowns(src, npcNetId)
    if not canPickpocket then
        if cooldownType == "player" then
            TriggerClientEvent('QBCore:Notify', src, Config.Notifications.cooldown, 'error')
        else
            TriggerClientEvent('QBCore:Notify', src, Config.Notifications.npc_cooldown, 'error')
        end
        return
    end
    
    -- Calculate success
    local success = math.random(1, 100) <= Config.BaseSuccessRate
    
    -- Chance to alert police (checked for all attempts)
    if math.random(1, 100) <= Config.PoliceAlertChance then
        TriggerClientEvent('rd-pickpocket:client:alertPolice', src)
    end
    
    if success then
        -- Generate loot
        local walletType, moneyAmount = GenerateWalletLoot()
        
        -- Add wallet item with error handling
        if CanCarryItem(src, walletType, 1) then
            if AddItem(src, walletType, 1) then
                -- Update metrics and cooldowns
                performanceMetrics.successfulPickpockets = performanceMetrics.successfulPickpockets + 1
                playerCooldowns[src] = os.time()
                npcCooldowns[npcNetId] = os.time()
                
                -- Notify success
                TriggerClientEvent('QBCore:Notify', src, string.format(Config.Notifications.success, Config.WalletTypes[walletType].name), 'success')
                TriggerClientEvent('rd-pickpocket:client:successfulAttempt', src, npcNetId)
            else
                TriggerClientEvent('QBCore:Notify', src, 'Error adding wallet!', 'error')
            end
        else
            TriggerClientEvent('QBCore:Notify', src, Config.Notifications.inventory_full, 'error')
        end
    else
        -- Handle failure
        playerCooldowns[src] = os.time()
        TriggerClientEvent('QBCore:Notify', src, Config.Notifications.failed, 'error')
        TriggerClientEvent('rd-pickpocket:client:failedAttempt', src, npcNetId)
    end
    
    -- Run cleanup
    CleanupTables()
end)

-- Debug command to reset cooldowns
if Config.Debug then
    QBCore.Commands.Add('resetpickpocketcooldown', 'Reset pickpocket cooldowns (Debug)', {}, false, function(source)
        local src = source
        playerCooldowns[src] = nil
        TriggerClientEvent('QBCore:Notify', src, 'Pickpocket cooldown reset', 'success')
        
        -- Print debug info
        print(string.format('Current Active Cooldowns:\nPlayers: %d\nNPCs: %d', 
            table.count(playerCooldowns), 
            table.count(npcCooldowns)
        ))
    end, 'admin')
end

-- Initialize items on resource start
CreateThread(function()
    RegisterItems()
end)