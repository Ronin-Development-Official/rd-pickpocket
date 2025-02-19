# RD-Pickpocket

An advanced NPC pickpocketing system for QBCore FiveM servers, featuring realistic mechanics, dynamic loot, and full integration with QB-Core and QS-Inventory.

## Features

- 🎯 Realistic Pickpocketing System
- 📦 QB/QS-Inventory Support
- 💰 Dynamic Loot System
- ⚖️ Risk & Reward Mechanics
- 🚔 Police Alert System
- 💼 Multiple Wallet Types
- ⚡ Optimized Performance
- ⚙️ Fully Configurable

## Dependencies

- QBCore Framework
- qb-target
- qb-skillbar
- ps-dispatch
- qs-inventory

## Installation

1. Download the resource
2. Place `rd-pickpocket` in your resources folder
3. Add `ensure rd-pickpocket` to your server.cfg
4. Configure the `config.lua` to your liking
5. Restart your server

## Configuration

### General Settings
```lua
Config.Debug = false -- Enable debug mode
Config.UseQBTarget = true -- Use qb-target system
Config.TargetDistance = 2.0 -- Distance to target NPCs
Config.PoliceRequired = 0 -- Minimum police required
```

### Cooldown Settings
```lua
Config.GlobalPlayerCooldown = 300 -- Player cooldown (seconds)
Config.GlobalNPCCooldown = 1800 -- NPC cooldown (seconds)
Config.EnableGlobalCooldowns = true -- Enable cooldown system
```

### Success Rates
```lua
Config.BaseSuccessRate = 70 -- Base success chance
Config.AlertChance = 30 -- Police alert chance
```

## Usage

### As a Player

1. Approach any valid NPC
2. Use the targeting system (default: Left ALT)
3. Select "Pickpocket" option
4. Complete the skillcheck
5. Receive your rewards or face consequences

### For Developers

#### Check Cooldowns
```lua
-- Server-side export
local isOnCooldown = exports['rd-pickpocket']:IsPlayerOnCooldown(playerId)
```

#### Events
```lua
-- Client-side success
TriggerEvent('rd-pickpocket:client:attemptPickpocket', data)

-- Server-side success
TriggerEvent('rd-pickpocket:server:pickpocketSuccess', netId)
```

## Wallet Types

### Common Wallet (60% Chance)
- 50-200 cash
- Common items (phones, papers, etc.)

### Business Wallet (30% Chance)
- 200-500 cash
- Valuable items (Rolex, gold chains)

### Wealthy Wallet (10% Chance)
- 500-1000 cash
- High-value items (diamonds, gold bars)

## Configuration Examples

### Add New Loot Items
```lua
Config.RandomLoot["common"] = {
    {item = "new_item", chance = 20, min = 1, max = 2}
}
```

### Modify Success Rates
```lua
Config.BaseSuccessRate = 65 -- Lower success rate
Config.AlertChance = 40 -- Higher police alert chance
```

## Troubleshooting

### Common Issues

1. Targeting not working
   - Ensure qb-target is properly installed
   - Check Config.UseQBTarget setting

2. No loot received
   - Verify items exist in QS-Inventory
   - Check inventory weight limits

3. Police not being alerted
   - Verify ps-dispatch is working
   - Check Config.AlertChance setting

## Support

For support:
1. Check the issues tab on GitHub
2. Join our Discord (link)
3. Open a new issue with detailed information

## Contributing

1. Fork the repository
2. Create a new branch
3. Make your changes
4. Submit a pull request

## License

This project is licensed under the GPLV3 License - see the LICENSE file for details

## Credits

- Xnation RP
- FiveM Community

## Changelog

### Version 1.0.0
- Initial release
- Base pickpocketing system
- QS-Inventory integration
- Police alert system
