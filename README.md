# RD Pickpocket

A realistic NPC pickpocketing system for QBCore with support for both QB-Inventory and QS-Inventory.

## Features
- Realistic Pickpocketing System
- Dynamic Loot System with different wallet types
- Risk & Reward Mechanic with police alerts
- Support for both QB-Inventory and QS-Inventory
- Optimized performance with monitoring
- Fully configurable settings
- Player and NPC cooldown system
- Blacklisted ped system
- Performance monitoring system

## Dependencies
- QBCore Framework
- QB-Target
- PS-Dispatch
- QB-Inventory or QS-Inventory

## Installation

1. Add the following items to your `qb-core/shared/items.lua`:
```lua
['regular_wallet']         = {['name'] = 'regular_wallet',         ['label'] = 'Regular Wallet',         ['weight'] = 250,   ['type'] = 'item',   ['image'] = 'wallet.png',         ['unique'] = true,    ['useable'] = true,    ['shouldClose'] = true,    ['combinable'] = nil,   ['description'] = 'A standard leather wallet'},
['premium_wallet']         = {['name'] = 'premium_wallet',         ['label'] = 'Premium Wallet',         ['weight'] = 300,   ['type'] = 'item',   ['image'] = 'wallet_premium.png', ['unique'] = true,    ['useable'] = true,    ['shouldClose'] = true,    ['combinable'] = nil,   ['description'] = 'A high-end designer wallet'},
['empty_wallet']          = {['name'] = 'empty_wallet',          ['label'] = 'Empty Wallet',          ['weight'] = 200,   ['type'] = 'item',   ['image'] = 'wallet_empty.png',   ['unique'] = true,    ['useable'] = true,    ['shouldClose'] = true,    ['combinable'] = nil,   ['description'] = 'An empty wallet'}
```

2. Add the wallet images to your inventory:
   - For QB-Inventory: `qb-inventory/html/images/`
   - For QS-Inventory: `qs-inventory/html/images/`

3. Copy the `qb-pickpocket` folder to your resources folder

4. Add to your server.cfg:
```
ensure qb-pickpocket
```

## Configuration

### config.lua Key Settings:

```lua
Config.UseQBInventory = true -- Set to false if using qs-inventory
Config.Debug = false -- Enable debug and performance monitoring

-- Cooldown Settings (in seconds)
Config.PlayerCooldown = 300 -- 5 minutes cooldown between pickpocket attempts
Config.NPCCooldown = 1800 -- 30 minutes before same NPC can be pickpocketed again

-- Success Rate Settings
Config.BaseSuccessRate = 75 -- Base success rate (percentage)
Config.PoliceAlertChance = 35 -- Chance of alerting police on any attempt

-- Money Type Settings
Config.MoneyType = {
    clean = {
        enabled = true,     -- Enable clean money rewards
        account = 'cash',   -- QB Account type for clean money
        chance = 30        -- Chance (%) to get clean money
    },
    dirty = {
        enabled = true,     -- Enable dirty money rewards
        item = 'markedbills', -- Item to use for dirty money
        chance = 70        -- Chance (%) to get dirty money
    }
}
```

## Usage Guide

### Basic Usage:
1. Approach any NPC
2. Use QB-Target to select the "Pickpocket" option
3. If successful:
   - Receive a wallet
   - Can use the wallet from inventory to search it
   - Find money (clean or dirty) and possible additional items
4. If failed:
   - NPC will react (run away or become aggressive)
   - Possible police alert

### Performance Monitoring:
If Config.Debug = true:
1. Automatic metrics every 15 minutes in server console:
   - Total Attempts
   - Success Rate
   - Wallets Searched

2. Use `/testpickpocket` command to see:
   - Current Entity Checks
   - Valid Targets
   - Memory Usage
   - Nearby valid peds

### Admin Commands:
- `/resetpickpocketcooldown` - Resets pickpocket cooldown (Admin Only)

## Blacklisting NPCs
Add ped models to Config.BlacklistedPeds to prevent them from being pickpocketed:
```lua
Config.BlacklistedPeds = {
    's_m_y_cop_01',      -- Police Officer
    's_m_y_sheriff_01',  -- Sheriff
    's_m_m_security_01', -- Security Guard
    -- Add more as needed
}
```

## Performance Tips
1. Adjust validation intervals based on server needs
2. Monitor performance metrics regularly
3. Adjust cooldown times for balance
4. Configure police alert chance based on server activity

## Known Issues
- None currently reported

## Support
For support, please create an issue on the GitHub repository or contact through Discord.|
(https://discord.gg/t9UNB5UcRh)

## Credits
Xnation (https://discord.gg/xnation-rp)
Created for QBCore Framework
