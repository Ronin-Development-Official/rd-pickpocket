# Advanced Pickpocket System for QBCore

An advanced and feature-rich pickpocketing system for FiveM QBCore framework, offering realistic NPC interactions, progression system, and extensive configuration options.

## License

This project is licensed under GNU Public License v3. See the LICENSE file for details.

## Features

- 🎯 Advanced targeting system with realistic restrictions
- 📈 Player progression system with experience and levels
- 🌡️ Dynamic suspicion system
- 🚔 Integrated police alerts and evidence system
- 💰 Configurable loot tables and wallet types
- 🎮 Skill-based minigame integration
- 🌍 Zone-based restrictions and bonuses
- 🕒 Time and weather-based modifiers
- 📊 Comprehensive statistics tracking
- 🎥 Security camera detection system
- 👮 Advanced NPC reactions
- 🔧 Admin tools and debugging features

## Dependencies

- QBCore Framework
- qb-target
- ox_lib
- PolyZone
- oxmysql

## Installation

1. Ensure you have all dependencies installed
2. Place the `rd-pickpocket` folder in your server's resources directory
3. Import the provided SQL file into your database
4. Add `ensure rd-pickpocket` to your server.cfg

```sql
-- SQL Import Command
mysql -u username -p database_name < pickpocket.sql
```

## Configuration

The config.lua file allows extensive customization of the system:

```lua
Config = {
    Debug = false,
    UseTarget = true,
    MinimumPolice = 0,
    AlertChance = 65,
    CooldownTime = 300,
    MaxPickpocketDistance = 2.0
}
```

### Key Configuration Options

- Police requirements
- Cooldown timers
- Success chances
- Loot tables
- Zone restrictions
- Skill check difficulty
- Progression rates
- NPC behavior

## Usage

### Player Commands
- `/pickpocketstats` - View your pickpocketing statistics

### Admin Commands
- `/pickpocketadmin` - Open admin menu
- `/clearpickpocketcooldown [id]` - Clear cooldown for a player
- `/resetpickpocket [id]` - Reset player's pickpocket data

### Integration Example

```lua
-- Check if player can be pickpocketed
exports['rd-pickpocket']:CanPickpocket(target)

-- Get player's pickpocket level
exports['rd-pickpocket']:GetPlayerLevel()
```

## NPC Configuration

Configure different NPC types and their loot:

```lua
Config.NPCPickpocket = {
    blacklistedPeds = {
        'mp_m_shopkeep_01',
        's_m_y_cop_01'
    },
    walletTypes = {
        ['poor_wallet'] = 60,
        ['standard_wallet'] = 35,
        ['expensive_wallet'] = 5
    }
}
```

## Zones Configuration

Set up restricted and bonus zones:

```lua
Config.RestrictedZones = {
    {
        coords = vector3(441.8, -982.4, 30.69),
        radius = 50.0,
        message = 'Cannot pickpocket near police station'
    }
}
```

## Progression System

Players can level up their pickpocketing skills:
- Experience gained from successful attempts
- Higher levels provide better success chances
- Unlock better loot possibilities
- Reduce detection rates

## Security Features

- Anti-exploitation measures
- Validation checks
- Rate limiting
- Secure loot generation
- Event verification

## Performance Optimization

The resource includes:
- Efficient ped caching
- Optimized zone checking
- Smart event handling
- Resource cleanup
- State management

## Troubleshooting

Common issues and solutions:

1. Target system not working
   - Ensure qb-target is properly installed
   - Check target configuration

2. Database errors
   - Verify SQL installation
   - Check database credentials

3. Performance issues
   - Enable debug mode for detailed logging
   - Check server console for errors

## Support

For support:
1. Check the debug logs
2. Review configuration
3. Verify all dependencies are updated
4. Check GitHub issues

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## Credits

Developed by Ronin Development
- Version: 1.0.0
- Contact: https://discord.gg/t9UNB5UcRh
- Framework: QBCore

## Changelog

### Version 1.0.0
- Initial release
- Core pickpocket functionality
- Progression system
- Police integration
- Evidence system
