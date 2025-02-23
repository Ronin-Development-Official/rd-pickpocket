fx_version 'cerulean'
game 'gta5'

description 'RD-Pickpocket - Advanced NPC Pickpocketing System'
version '1.0.0'
author 'RoninDevelopment'

shared_scripts {
    '@qb-core/shared/locale.lua',
    'config.lua'
}

client_scripts {
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    '@PolyZone/EntityZone.lua',
    '@PolyZone/CircleZone.lua',
    '@PolyZone/ComboZone.lua',
    'client.lua'
}

server_scripts {
    'server.lua'
}

dependencies {
    'qb-core',
    'qb-target',
    'ps-dispatch'
}

lua54 'yes'