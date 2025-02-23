Config = {}

-- General Settings
Config.Debug = false -- Enable debug prints
Config.UseQBInventory = false -- Set false if using qs-inventory
Config.UseDirtyMoney = true -- If true, stolen cash will be dirty money

-- Cooldown Settings (in seconds)
Config.PlayerCooldown = 300 -- 5 minutes cooldown between pickpocket attempts
Config.NPCCooldown = 1800 -- 30 minutes before same NPC can be pickpocketed again

-- Success Rate Settings
Config.BaseSuccessRate = 50 -- Base success rate (percentage)
Config.MinimumSuccessRate = 30 -- Minimum success rate regardless of conditions
Config.PoliceAlertChance = 80 -- Chance of alerting police on failed attempt

-- Money Settings
Config.MinMoney = 50 -- Minimum money NPCs carry
Config.MaxMoney = 500 -- Maximum money NPCs carry

-- Money Type Settings
Config.MoneyType = {
    clean = {
        enabled = true,     -- Enable clean money rewards
        account = 'cash',   -- QB Account type for clean money
        chance = 30        -- Chance (%) to get clean money
    },
    dirty = {
        enabled = true,     -- Enable dirty money rewards
        item = 'dirty_cash', -- Item to use for dirty money
        chance = 70        -- Chance (%) to get dirty money
    }
}

-- Wallet Types and their probabilities (total should equal 100)
Config.WalletTypes = {
    ['regular_wallet'] = {
        name = 'Regular Wallet',
        chance = 70,
        minMoney = 50,
        maxMoney = 250
    },
    ['premium_wallet'] = {
        name = 'Premium Wallet',
        chance = 20,
        minMoney = 150,
        maxMoney = 400
    },
    ['empty_wallet'] = {
        name = 'Empty Wallet',
        chance = 10,
        minMoney = 0,
        maxMoney = 25
    }
}

-- Additional Items that can be found (chance is percentage per pickpocket)
Config.AdditionalLoot = {
    ['plastic'] = {
        name = 'Plastic',
        chance = 25,
        min = 1,
        max = 3
    },
    ['rolex'] = {
        name = 'Rolex Watch',
        chance = 5,
        min = 1,
        max = 1
    },
    ['goldchain'] = {
        name = 'Gold Chain',
        chance = 10,
        min = 1,
        max = 2
    }
}

-- Blacklisted Peds
Config.BlacklistedPeds = {
    -- Add ped models that cannot be pickpocketed
"G_M_M_CartelGoons_01",
"G_M_M_ChemWork_01",
"G_M_M_MaraGrande_01",
"G_M_Y_PoloGoon_01",
"G_M_Y_PoloGoon_02",
"G_M_Y_StrPunk_02",
"a_f_m_bevhills_02",
"a_f_m_fatwhite_01",
"a_f_m_soucent_02",
"a_f_y_bevhills_02",
"a_f_y_gencaspat_01",
"a_f_y_genhot_01",
"a_f_y_hipster_02",
"a_f_y_hipster_04",
"a_f_y_indian_01",
"a_f_y_soucent_01",
"a_f_y_vinewood_02",
"a_m_m_eastsa_01",
"a_m_m_eastsa_02",
"a_m_m_farmer_01",
"a_m_m_genfat_01",
"a_m_m_mexcntry_01",
"a_m_m_og_boss_01",
"a_m_m_rurmeth_01",
"a_m_m_salton_01",
"a_m_m_salton_02",
"a_m_m_salton_03",
"a_m_m_soucent_01",
"a_m_m_soucent_04",
"a_m_m_stlat_02",
"a_m_m_tourist_01",
"a_m_m_trampbeac_01",
"a_m_o_genstreet_01",
"a_m_o_tramp_01",
"a_m_y_beach_01",
"a_m_y_bevhills_01",
"a_m_y_bevhills_02",
"a_m_y_hasjew_01",
"a_m_y_hippy_01",
"a_m_y_methhead_01",
"cs_debra",
"cs_paper",
"cs_siemonyetarian",
"cs_solomon",
"cs_terry",
"csb_agatha",
"csb_vagspeak",
"g_m_y_korlieut_01",
"ig_andreas",
"ig_floyd",
"ig_jimmyboston_02",
"mp_f_helistaff_01",
"s_m_m_dockwork_01",
"s_m_m_doctor_01",
"s_m_m_paramedic_01",
"s_m_m_scientist_01",
"s_m_m_security_01",
"s_m_y_ammucity_01",
"s_m_y_cop_01",
"s_m_y_dealer_01",
"s_m_y_fireman_01",
"s_m_y_ranger_01",
"s_m_y_sheriff_01",
"s_m_y_swat_01",
"s_m_y_xmech_02",
"u_m_y_prisoner_01",
"s_m_m_prisguard_01",
"a_m_y_business_02",
    -- Add any other ped models you want to blacklist
}

-- Blacklist by job
Config.BlacklistedJobs = {
    -- Add jobs that will make a ped non-pickpocketable
    --'police',
    'ambulance',
    --'mechanic',
    -- Add any other jobs you want to blacklist
}

-- Notification Messages
Config.Notifications = {
    success = 'You successfully pickpocketed %s!',
    failed = 'The target noticed your attempt!',
    police_alert = 'Someone reported a pickpocketing attempt!',
    cooldown = 'You need to wait before attempting to pickpocket again!',
    npc_cooldown = 'This person seems too alert right now!',
    inventory_full = 'Your pockets are too full to carry more items!',
    wallet_searched = 'You searched the wallet...',
    wallet_empty = 'This wallet is empty!',
    found_cash = 'Found $%s in cash!',
    found_marked_bills = 'Found $%s in marked bills!',
    found_item = 'Found %sx %s!',
}
