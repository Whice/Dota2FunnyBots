--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
-- Lua Library inline imports
local function __TS__ArrayIncludes(self, searchElement, fromIndex)
    if fromIndex == nil then
        fromIndex = 0
    end
    local len = #self
    local k = fromIndex
    if fromIndex < 0 then
        k = len + fromIndex
    end
    if k < 0 then
        k = 0
    end
    for i = k + 1, len do
        if self[i] == searchElement then
            return true
        end
    end
    return false
end
-- End of Lua Library inline imports
local ____exports = {}
local heroes = {
    npc_dota_hero_abaddon = {synergy = {
        "npc_dota_hero_axe",
        "npc_dota_hero_legion_commander",
        "npc_dota_hero_earth_spirit",
        "npc_dota_hero_sand_king",
        "npc_dota_hero_monkey_king",
        "npc_dota_hero_ursa",
        "npc_dota_hero_rubick",
        "npc_dota_hero_rattletrap"
    }, counter = {
        "npc_dota_hero_axe",
        "npc_dota_hero_bounty_hunter",
        "npc_dota_hero_silencer",
        "npc_dota_hero_arc_warden",
        "npc_dota_hero_skeleton_king",
        "npc_dota_hero_spectre",
        "npc_dota_hero_earth_spirit",
        "npc_dota_hero_bane"
    }},
    npc_dota_hero_abyssal_underlord = {synergy = {
        "npc_dota_hero_doom_bringer",
        "npc_dota_hero_shredder",
        "npc_dota_hero_mars",
        "npc_dota_hero_chaos_knight",
        "npc_dota_hero_rattletrap",
        "npc_dota_hero_batrider",
        "npc_dota_hero_night_stalker",
        "npc_dota_hero_templar_assassin",
        "npc_dota_hero_slardar"
    }, counter = {
        "npc_dota_hero_naga_siren",
        "npc_dota_hero_lone_druid",
        "npc_dota_hero_riki",
        "npc_dota_hero_phantom_lancer",
        "npc_dota_hero_meepo",
        "npc_dota_hero_spirit_breaker",
        "npc_dota_hero_tiny",
        "npc_dota_hero_chaos_knight"
    }},
    npc_dota_hero_alchemist = {synergy = {
        "npc_dota_hero_arc_warden",
        "npc_dota_hero_outworld_destroyer",
        "npc_dota_hero_chaos_knight",
        "npc_dota_hero_earth_spirit",
        "npc_dota_hero_dark_seer",
        "npc_dota_hero_oracle",
        "npc_dota_hero_monkey_king",
        "npc_dota_hero_sven"
    }, counter = {
        "npc_dota_hero_visage",
        "npc_dota_hero_enigma",
        "npc_dota_hero_arc_warden",
        "npc_dota_hero_medusa",
        "npc_dota_hero_templar_assassin",
        "npc_dota_hero_centaur",
        "npc_dota_hero_tiny",
        "npc_dota_hero_treant",
        "npc_dota_hero_chaos_knight",
        "npc_dota_hero_phantom_lancer"
    }},
    npc_dota_hero_ancient_apparition = {synergy = {
        "npc_dota_hero_visage",
        "npc_dota_hero_skeleton_king",
        "npc_dota_hero_shadow_shaman",
        "npc_dota_hero_ember_spirit",
        "npc_dota_hero_meepo",
        "npc_dota_hero_centaur",
        "npc_dota_hero_pudge",
        "npc_dota_hero_storm_spirit"
    }, counter = {
        "npc_dota_hero_huskar",
        "npc_dota_hero_leshrac",
        "npc_dota_hero_necrophos",
        "npc_dota_hero_death_prophet",
        "npc_dota_hero_slark",
        "npc_dota_hero_dazzle",
        "npc_dota_hero_treant",
        "npc_dota_hero_abyssal_underlord"
    }},
    npc_dota_hero_antimage = {synergy = {
        "npc_dota_hero_snapfire",
        "npc_dota_hero_winter_wyvern",
        "npc_dota_hero_axe",
        "npc_dota_hero_death_prophet",
        "npc_dota_hero_broodmother",
        "npc_dota_hero_razor",
        "npc_dota_hero_jakiro",
        "npc_dota_hero_bane",
        "npc_dota_hero_nyx_assassin"
    }, counter = {
        "npc_dota_hero_medusa",
        "npc_dota_hero_phantom_lancer",
        "npc_dota_hero_ancient_apparition",
        "npc_dota_hero_abaddon",
        "npc_dota_hero_storm_spirit",
        "npc_dota_hero_doom_bringer",
        "npc_dota_hero_chaos_knight",
        "npc_dota_hero_muerta"
    }},
    npc_dota_hero_arc_warden = {synergy = {
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_alchemist",
        "npc_dota_hero_naga_siren",
        "npc_dota_hero_troll_warlord",
        "npc_dota_hero_terrorblade",
        "npc_dota_hero_phantom_lancer",
        "npc_dota_hero_templar_assassin",
        "npc_dota_hero_medusa",
        "npc_dota_hero_mirana"
    }, counter = {
        "npc_dota_hero_huskar",
        "npc_dota_hero_silencer",
        "npc_dota_hero_night_stalker",
        "npc_dota_hero_necrolyte",
        "npc_dota_hero_weaver",
        "npc_dota_hero_disruptor",
        "npc_dota_hero_dark_willow",
        "npc_dota_hero_tiny",
        "npc_dota_hero_ogre_magi"
    }},
    npc_dota_hero_axe = {synergy = {
        "npc_dota_hero_omniknight",
        "npc_dota_hero_dawnbreaker",
        "npc_dota_hero_lone_druid",
        "npc_dota_hero_bristleback",
        "npc_dota_hero_abaddon",
        "npc_dota_hero_bounty_hunter",
        "npc_dota_hero_huskar",
        "npc_dota_hero_life_stealer",
        "npc_dota_hero_bloodseeker",
        "npc_dota_hero_primal_beast"
    }, counter = {
        "npc_dota_hero_troll_warlord",
        "npc_dota_hero_naga_siren",
        "npc_dota_hero_phantom_lancer",
        "npc_dota_hero_broodmother",
        "npc_dota_hero_terrorblade",
        "npc_dota_hero_windrunner",
        "npc_dota_hero_phantom_assassin",
        "npc_dota_hero_huskar",
        "npc_dota_hero_chaos_knight",
        "npc_dota_hero_bristleback"
    }},
    npc_dota_hero_bane = {synergy = {
        "npc_dota_hero_meepo",
        "npc_dota_hero_leshrac",
        "npc_dota_hero_naga_siren",
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_muerta",
        "npc_dota_hero_visage"
    }, counter = {
        "npc_dota_hero_ember_spirit",
        "npc_dota_hero_storm_spirit",
        "npc_dota_hero_alchemist",
        "npc_dota_hero_batrider",
        "npc_dota_hero_shredder",
        "npc_dota_hero_muerta",
        "npc_dota_hero_faceless_void",
        "npc_dota_hero_troll_warlord"
    }},
    npc_dota_hero_batrider = {synergy = {
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_winter_wyvern",
        "npc_dota_hero_broodmother",
        "npc_dota_hero_templar_assassin",
        "npc_dota_hero_leshrac",
        "npc_dota_hero_oracle",
        "npc_dota_hero_terrorblade"
    }, counter = {
        "npc_dota_hero_lycan",
        "npc_dota_hero_shredder",
        "npc_dota_hero_marci",
        "npc_dota_hero_troll_warlord",
        "npc_dota_hero_death_prophet",
        "npc_dota_hero_furion",
        "npc_dota_hero_razor",
        "npc_dota_hero_meepo"
    }},
    npc_dota_hero_beastmaster = {synergy = {
        "npc_dota_hero_arc_warden",
        "npc_dota_hero_primal_beast",
        "npc_dota_hero_shredder",
        "npc_dota_hero_batrider",
        "npc_dota_hero_night_stalker",
        "npc_dota_hero_dazzle",
        "npc_dota_hero_magnataur",
        "npc_dota_hero_lone_druid",
        "npc_dota_hero_dragon_knight",
        "npc_dota_hero_earthshaker"
    }, counter = {
        "npc_dota_hero_visage",
        "npc_dota_hero_naga_siren",
        "npc_dota_hero_arc_warden",
        "npc_dota_hero_phantom_lancer",
        "npc_dota_hero_night_stalker",
        "npc_dota_hero_slardar",
        "npc_dota_hero_broodmother",
        "npc_dota_hero_oracle"
    }},
    npc_dota_hero_bloodseeker = {synergy = {
        "npc_dota_hero_slark",
        "npc_dota_hero_death_prophet",
        "npc_dota_hero_riki",
        "npc_dota_hero_chaos_knight",
        "npc_dota_hero_juggernaut",
        "npc_dota_hero_omniknight",
        "npc_dota_hero_abyssal_underlord",
        "npc_dota_hero_axe",
        "npc_dota_hero_bristleback"
    }, counter = {
        "npc_dota_hero_antimage",
        "npc_dota_hero_slark",
        "npc_dota_hero_night_stalker",
        "npc_dota_hero_primal_beast",
        "npc_dota_hero_phoenix",
        "npc_dota_hero_phantom_lancer",
        "npc_dota_hero_bane",
        "npc_dota_hero_riki",
        "npc_dota_hero_lycan"
    }},
    npc_dota_hero_bounty_hunter = {synergy = {
        "npc_dota_hero_axe",
        "npc_dota_hero_spectre",
        "npc_dota_hero_phantom_lancer",
        "npc_dota_hero_muerta",
        "npc_dota_hero_legion_commander",
        "npc_dota_hero_void_spirit",
        "npc_dota_hero_obsidian_destroyer"
    }, counter = {
        "npc_dota_hero_clinkz",
        "npc_dota_hero_leshrac",
        "npc_dota_hero_visage",
        "npc_dota_hero_lycan",
        "npc_dota_hero_weaver",
        "npc_dota_hero_skeleton_king",
        "npc_dota_hero_bristleback",
        "npc_dota_hero_warlock",
        "npc_dota_hero_alchemist"
    }},
    npc_dota_hero_brewmaster = {synergy = {
        "npc_dota_hero_visage",
        "npc_dota_hero_chaos_knight",
        "npc_dota_hero_broodmother",
        "npc_dota_hero_naga_siren",
        "npc_dota_hero_dark_willow",
        "npc_dota_hero_dawnbreaker",
        "npc_dota_hero_monkey_king",
        "npc_dota_hero_ancient_apparition",
        "npc_dota_hero_gyrocopter"
    }, counter = {
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_naga_siren",
        "npc_dota_hero_sven",
        "npc_dota_hero_terrorblade",
        "npc_dota_hero_dark_seer",
        "npc_dota_hero_ancient_apparition",
        "npc_dota_hero_shredder",
        "npc_dota_hero_troll_warlord",
        "npc_dota_hero_lone_druid"
    }},
    npc_dota_hero_bristleback = {synergy = {
        "npc_dota_hero_chaos_knight",
        "npc_dota_hero_naga_siren",
        "npc_dota_hero_legion_commander",
        "npc_dota_hero_slardar",
        "npc_dota_hero_sand_king",
        "npc_dota_hero_axe",
        "npc_dota_hero_nyx_assassin",
        "npc_dota_hero_mars",
        "npc_dota_hero_meepo"
    }, counter = {
        "npc_dota_hero_visage",
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_huskar",
        "npc_dota_hero_enigma",
        "npc_dota_hero_witch_doctor",
        "npc_dota_hero_arc_warden",
        "npc_dota_hero_leshrac",
        "npc_dota_hero_sven",
        "npc_dota_hero_death_prophet"
    }},
    npc_dota_hero_broodmother = {synergy = {
        "npc_dota_hero_dawnbreaker",
        "npc_dota_hero_earthshaker",
        "npc_dota_hero_batrider",
        "npc_dota_hero_skywrath_mage",
        "npc_dota_hero_mars",
        "npc_dota_hero_marci",
        "npc_dota_hero_nyx_assassin",
        "npc_dota_hero_snapfire",
        "npc_dota_hero_lich"
    }, counter = {
        "npc_dota_hero_arc_warden",
        "npc_dota_hero_furion",
        "npc_dota_hero_silencer",
        "npc_dota_hero_invoker",
        "npc_dota_hero_void_spirit",
        "npc_dota_hero_earth_spirit",
        "npc_dota_hero_obsidian_destroyer",
        "npc_dota_hero_skywrath_mage"
    }},
    npc_dota_hero_centaur = {synergy = {
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_bristleback",
        "npc_dota_hero_huskar",
        "npc_dota_hero_omniknight",
        "npc_dota_hero_dark_seer",
        "npc_dota_hero_alchemist",
        "npc_dota_hero_lone_druid",
        "npc_dota_hero_sven",
        "npc_dota_hero_broodmother"
    }, counter = {
        "npc_dota_hero_medusa",
        "npc_dota_hero_spectre",
        "npc_dota_hero_sniper",
        "npc_dota_hero_phantom_lancer",
        "npc_dota_hero_phantom_assassin",
        "npc_dota_hero_riki",
        "npc_dota_hero_muerta",
        "npc_dota_hero_drow_ranger",
        "npc_dota_hero_gyrocopter"
    }},
    npc_dota_hero_chaos_knight = {synergy = {
        "npc_dota_hero_abyssal_underlord",
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_dawnbreaker",
        "npc_dota_hero_earthshaker",
        "npc_dota_hero_death_prophet",
        "npc_dota_hero_treant",
        "npc_dota_hero_drow_ranger",
        "npc_dota_hero_ancient_apparition",
        "npc_dota_hero_batrider",
        "npc_dota_hero_viper"
    }, counter = {
        "npc_dota_hero_huskar",
        "npc_dota_hero_viper",
        "npc_dota_hero_lycan",
        "npc_dota_hero_ogre_magi",
        "npc_dota_hero_razor",
        "npc_dota_hero_broodmother",
        "npc_dota_hero_vengefulspirit",
        "npc_dota_hero_pugna"
    }},
    npc_dota_hero_chen = {synergy = {
        "npc_dota_hero_omniknight",
        "npc_dota_hero_visage",
        "npc_dota_hero_marci",
        "npc_dota_hero_techies",
        "npc_dota_hero_batrider",
        "npc_dota_hero_arc_warden",
        "npc_dota_hero_primal_beast",
        "npc_dota_hero_mars"
    }, counter = {
        "npc_dota_hero_huskar",
        "npc_dota_hero_medusa",
        "npc_dota_hero_sven",
        "npc_dota_hero_muerta",
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_batrider",
        "npc_dota_hero_anti-mage",
        "npc_dota_hero_phoenix"
    }},
    npc_dota_hero_clinkz = {synergy = {
        "npc_dota_hero_keeper_of_the_light",
        "npc_dota_hero_arc_warden",
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_spectre",
        "npc_dota_hero_luna",
        "npc_dota_hero_undying",
        "npc_dota_hero_abyssal_underlord",
        "npc_dota_hero_phantom_lancer",
        "npc_dota_hero_techies"
    }, counter = {
        "npc_dota_hero_broodmother",
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_leshrac",
        "npc_dota_hero_death_prophet",
        "npc_dota_hero_huskar",
        "npc_dota_hero_rubick",
        "npc_dota_hero_doom_bringer",
        "npc_dota_hero_sand_king"
    }},
    npc_dota_hero_crystal_maiden = {synergy = {
        "npc_dota_hero_silencer",
        "npc_dota_hero_lycan",
        "npc_dota_hero_pudge",
        "npc_dota_hero_drow_ranger",
        "npc_dota_hero_alchemist",
        "npc_dota_hero_bristleback",
        "npc_dota_hero_meepo"
    }, counter = {
        "npc_dota_hero_phantom_lancer",
        "npc_dota_hero_meepo",
        "npc_dota_hero_enchantress",
        "npc_dota_hero_lycan",
        "npc_dota_hero_bounty_hunter",
        "npc_dota_hero_furion",
        "npc_dota_hero_mirana",
        "npc_dota_hero_keeper_of_the_light"
    }},
    npc_dota_hero_dark_seer = {synergy = {
        "npc_dota_hero_doom_bringer",
        "npc_dota_hero_primal_beast",
        "npc_dota_hero_naga_siren",
        "npc_dota_hero_centaur",
        "npc_dota_hero_bristleback",
        "npc_dota_hero_dawnbreaker",
        "npc_dota_hero_earth_spirit",
        "npc_dota_hero_spirit_breaker"
    }, counter = {
        "npc_dota_hero_medusa",
        "npc_dota_hero_meepo",
        "npc_dota_hero_terrorblade",
        "npc_dota_hero_tidehunter",
        "npc_dota_hero_enigma",
        "npc_dota_hero_chaos_knight",
        "npc_dota_hero_viper",
        "npc_dota_hero_doom_bringer",
        "npc_dota_hero_lone_druid"
    }},
    npc_dota_hero_dawnbreaker = {synergy = {
        "npc_dota_hero_death_prophet",
        "npc_dota_hero_shredder",
        "npc_dota_hero_tidehunter",
        "npc_dota_hero_naga_siren",
        "npc_dota_hero_dark_seer",
        "npc_dota_hero_chaos_knight",
        "npc_dota_hero_mars",
        "npc_dota_hero_venomancer",
        "npc_dota_hero_void_spirit",
        "npc_dota_hero_crystal_maiden"
    }, counter = {
        "npc_dota_hero_naga_siren",
        "npc_dota_hero_shadow_demon",
        "npc_dota_hero_treant",
        "npc_dota_hero_troll_warlord",
        "npc_dota_hero_abaddon"
    }},
    npc_dota_hero_dazzle = {synergy = {
        "npc_dota_hero_broodmother",
        "npc_dota_hero_marci",
        "npc_dota_hero_tidehunter",
        "npc_dota_hero_visage",
        "npc_dota_hero_primal_beast",
        "npc_dota_hero_crystal_maiden",
        "npc_dota_hero_dawnbreaker",
        "npc_dota_hero_razor",
        "npc_dota_hero_shadow_demon"
    }, counter = {
        "npc_dota_hero_naga_siren",
        "npc_dota_hero_visage",
        "npc_dota_hero_spectre",
        "npc_dota_hero_arc_warden",
        "npc_dota_hero_lycan",
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_shadow_demon",
        "npc_dota_hero_bloodseeker",
        "npc_dota_hero_bane"
    }},
    npc_dota_hero_disruptor = {synergy = {
        "npc_dota_hero_arc_warden",
        "npc_dota_hero_oracle",
        "npc_dota_hero_bristleback",
        "npc_dota_hero_omniknight",
        "npc_dota_hero_furion",
        "npc_dota_hero_monkey_king",
        "npc_dota_hero_lycan",
        "npc_dota_hero_bounty_hunter",
        "npc_dota_hero_razor",
        "npc_dota_hero_mirana"
    }, counter = {
        "npc_dota_hero_riki",
        "npc_dota_hero_slark",
        "npc_dota_hero_magnataur",
        "npc_dota_hero_batrider",
        "npc_dota_hero_spectre",
        "npc_dota_hero_primal_beast",
        "npc_dota_hero_earthshaker",
        "npc_dota_hero_mirana"
    }},
    npc_dota_hero_death_prophet = {synergy = {
        "npc_dota_hero_meepo",
        "npc_dota_hero_lycan",
        "npc_dota_hero_treant",
        "npc_dota_hero_enchantress",
        "npc_dota_hero_chaos_knight",
        "npc_dota_hero_slark",
        "npc_dota_hero_storm_spirit",
        "npc_dota_hero_phantom_assassin"
    }, counter = {
        "npc_dota_hero_necrolyte",
        "npc_dota_hero_oracle",
        "npc_dota_hero_alchemist",
        "npc_dota_hero_naga_siren",
        "npc_dota_hero_meepo",
        "npc_dota_hero_huskar",
        "npc_dota_hero_omniknight",
        "npc_dota_hero_life_stealer"
    }},
    npc_dota_hero_doom_bringer = {synergy = {
        "npc_dota_hero_meepo",
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_sand_king",
        "npc_dota_hero_dark_seer",
        "npc_dota_hero_furion",
        "npc_dota_hero_sven",
        "npc_dota_hero_night_stalker",
        "npc_dota_hero_bristleback"
    }, counter = {
        "npc_dota_hero_omniknight",
        "npc_dota_hero_necrolyte",
        "npc_dota_hero_enchantress",
        "npc_dota_hero_axe",
        "npc_dota_hero_oracle",
        "npc_dota_hero_marci",
        "npc_dota_hero_ember_spirit",
        "npc_dota_hero_faceless_void",
        "npc_dota_hero_shredder"
    }},
    npc_dota_hero_dragon_knight = {synergy = {
        "npc_dota_hero_primal_beast",
        "npc_dota_hero_mars",
        "npc_dota_hero_abyssal_underlord",
        "npc_dota_hero_earthshaker",
        "npc_dota_hero_centaur",
        "npc_dota_hero_omniknight",
        "npc_dota_hero_night_stalker",
        "npc_dota_hero_riki",
        "npc_dota_hero_sand_king"
    }, counter = {
        "npc_dota_hero_lycan",
        "npc_dota_hero_bristleback",
        "npc_dota_hero_skywrath_mage",
        "npc_dota_hero_oracle",
        "npc_dota_hero_skeleton_king",
        "npc_dota_hero_templar_assassin",
        "npc_dota_hero_void_spirit"
    }},
    npc_dota_hero_drow_ranger = {synergy = {
        "npc_dota_hero_vengefulspirit",
        "npc_dota_hero_storm_spirit",
        "npc_dota_hero_nevermore",
        "npc_dota_hero_arc_warden",
        "npc_dota_hero_crystal_maiden",
        "npc_dota_hero_venomancer",
        "npc_dota_hero_riki",
        "npc_dota_hero_pudge",
        "npc_dota_hero_razor",
        "npc_dota_hero_beastmaster"
    }, counter = {
        "npc_dota_hero_necrolyte",
        "npc_dota_hero_weaver",
        "npc_dota_hero_bristleback",
        "npc_dota_hero_death_prophet",
        "npc_dota_hero_leshrac",
        "npc_dota_hero_riki",
        "npc_dota_hero_slardar",
        "npc_dota_hero_troll_warlord",
        "npc_dota_hero_sand_king"
    }},
    npc_dota_hero_earth_spirit = {synergy = {
        "npc_dota_hero_enigma",
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_treant",
        "npc_dota_hero_silencer",
        "npc_dota_hero_skeleton_king",
        "npc_dota_hero_undying",
        "npc_dota_hero_venomancer",
        "npc_dota_hero_dazzle"
    }, counter = {
        "npc_dota_hero_abyssal_underlord",
        "npc_dota_hero_keeper_of_the_light",
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_sniper",
        "npc_dota_hero_broodmother",
        "npc_dota_hero_axe",
        "npc_dota_hero_drow_ranger",
        "npc_dota_hero_phantom_lancer"
    }},
    npc_dota_hero_earthshaker = {synergy = {
        "npc_dota_hero_night_stalker",
        "npc_dota_hero_visage",
        "npc_dota_hero_naga_siren",
        "npc_dota_hero_broodmother",
        "npc_dota_hero_dark_seer",
        "npc_dota_hero_omniknight",
        "npc_dota_hero_dragon_knight",
        "npc_dota_hero_shredder"
    }, counter = {
        "npc_dota_hero_meepo",
        "npc_dota_hero_broodmother",
        "npc_dota_hero_naga_siren",
        "npc_dota_hero_phantom_lancer",
        "npc_dota_hero_chaos_knight",
        "npc_dota_hero_arc_warden",
        "npc_dota_hero_visage",
        "npc_dota_hero_lone_druid"
    }},
    npc_dota_hero_ember_spirit = {synergy = {
        "npc_dota_hero_dark_seer",
        "npc_dota_hero_pugna",
        "npc_dota_hero_treant",
        "npc_dota_hero_alchemist",
        "npc_dota_hero_bane",
        "npc_dota_hero_bounty_hunter",
        "npc_dota_hero_bloodseeker"
    }, counter = {
        "npc_dota_hero_phantom_lancer",
        "npc_dota_hero_batrider",
        "npc_dota_hero_centaur",
        "npc_dota_hero_enigma",
        "npc_dota_hero_rattletrap",
        "npc_dota_hero_bristleback",
        "npc_dota_hero_kunkka",
        "npc_dota_hero_storm_spirit",
        "npc_dota_hero_zuus",
        "npc_dota_hero_vengefulspirit"
    }},
    npc_dota_hero_enchantress = {synergy = {
        "npc_dota_hero_keeper_of_the_light",
        "npc_dota_hero_abyssal_underlord",
        "npc_dota_hero_winter_wyvern",
        "npc_dota_hero_nyx_assassin",
        "npc_dota_hero_furion",
        "npc_dota_hero_warlock",
        "npc_dota_hero_dawnbreaker",
        "npc_dota_hero_kunkka",
        "npc_dota_hero_tidehunter",
        "npc_dota_hero_muerta"
    }, counter = {
        "npc_dota_hero_visage",
        "npc_dota_hero_venomancer",
        "npc_dota_hero_death_prophet",
        "npc_dota_hero_sven",
        "npc_dota_hero_faceless_void",
        "npc_dota_hero_batrider",
        "npc_dota_hero_huskar",
        "npc_dota_hero_spectre"
    }},
    npc_dota_hero_enigma = {synergy = {
        "npc_dota_hero_batrider",
        "npc_dota_hero_earth_spirit",
        "npc_dota_hero_leshrac",
        "npc_dota_hero_marci",
        "npc_dota_hero_huskar",
        "npc_dota_hero_phoenix",
        "npc_dota_hero_skeleton_king",
        "npc_dota_hero_medusa"
    }, counter = {
        "npc_dota_hero_batrider",
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_meepo",
        "npc_dota_hero_razor",
        "npc_dota_hero_obsidian_destroyer",
        "npc_dota_hero_ogre_magi",
        "npc_dota_hero_slardar",
        "npc_dota_hero_venomancer"
    }},
    npc_dota_hero_faceless_void = {synergy = {
        "npc_dota_hero_razor",
        "npc_dota_hero_viper",
        "npc_dota_hero_obsidian_destroyer",
        "npc_dota_hero_doom_bringer",
        "npc_dota_hero_necrolyte",
        "npc_dota_hero_bounty_hunter",
        "npc_dota_hero_nyx_assassin",
        "npc_dota_hero_abyssal_underlord",
        "npc_dota_hero_enchantress"
    }, counter = {
        "npc_dota_hero_weaver",
        "npc_dota_hero_windrunner",
        "npc_dota_hero_primal_beast",
        "npc_dota_hero_shredder",
        "npc_dota_hero_undying",
        "npc_dota_hero_magnataur",
        "npc_dota_hero_batrider",
        "npc_dota_hero_queenofpain",
        "npc_dota_hero_shadow_demon",
        "npc_dota_hero_zuus"
    }},
    npc_dota_hero_furion = {synergy = {
        "npc_dota_hero_doom_bringer",
        "npc_dota_hero_enchantress",
        "npc_dota_hero_necrolyte",
        "npc_dota_hero_sand_king",
        "npc_dota_hero_death_prophet",
        "npc_dota_hero_obsidian_destroyer",
        "npc_dota_hero_night_stalker",
        "npc_dota_hero_earthshaker"
    }, counter = {
        "npc_dota_hero_life_stealer",
        "npc_dota_hero_keeper_of_the_light",
        "npc_dota_hero_windrunner",
        "npc_dota_hero_lone_druid",
        "npc_dota_hero_bloodseeker",
        "npc_dota_hero_leshrac",
        "npc_dota_hero_venomancer",
        "npc_dota_hero_visage",
        "npc_dota_hero_doom_bringer"
    }},
    npc_dota_hero_grimstroke = {synergy = {
        "npc_dota_hero_visage",
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_alchemist",
        "npc_dota_hero_batrider",
        "npc_dota_hero_meepo",
        "npc_dota_hero_lich",
        "npc_dota_hero_phantom_lancer",
        "npc_dota_hero_broodmother"
    }, counter = {
        "npc_dota_hero_shredder",
        "npc_dota_hero_primal_beast",
        "npc_dota_hero_omniknight",
        "npc_dota_hero_slark",
        "npc_dota_hero_necrolyte",
        "npc_dota_hero_broodmother",
        "npc_dota_hero_storm_spirit",
        "npc_dota_hero_faceless_void"
    }},
    npc_dota_hero_gyrocopter = {synergy = {
        "npc_dota_hero_broodmother",
        "npc_dota_hero_riki",
        "npc_dota_hero_storm_spirit",
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_primal_beast",
        "npc_dota_hero_lone_druid",
        "npc_dota_hero_oracle",
        "npc_dota_hero_treant"
    }, counter = {
        "npc_dota_hero_batrider",
        "npc_dota_hero_dazzle",
        "npc_dota_hero_undying",
        "npc_dota_hero_dawnbreaker",
        "npc_dota_hero_grimstroke",
        "npc_dota_hero_sven",
        "npc_dota_hero_enigma"
    }},
    npc_dota_hero_huskar = {synergy = {
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_troll_warlord",
        "npc_dota_hero_lycan",
        "npc_dota_hero_naga_siren",
        "npc_dota_hero_oracle",
        "npc_dota_hero_enigma",
        "npc_dota_hero_magnataur",
        "npc_dota_hero_phoenix",
        "npc_dota_hero_bristleback"
    }, counter = {
        "npc_dota_hero_anti-mage",
        "npc_dota_hero_void_spirit",
        "npc_dota_hero_ember_spirit",
        "npc_dota_hero_lone_druid",
        "npc_dota_hero_meepo",
        "npc_dota_hero_night_stalker",
        "npc_dota_hero_bounty_hunter",
        "npc_dota_hero_obsidian_destroyer",
        "npc_dota_hero_queenofpain"
    }},
    npc_dota_hero_invoker = {synergy = {
        "npc_dota_hero_phantom_lancer",
        "npc_dota_hero_batrider",
        "npc_dota_hero_undying",
        "npc_dota_hero_faceless_void",
        "npc_dota_hero_life_stealer",
        "npc_dota_hero_skeleton_king",
        "npc_dota_hero_shredder",
        "npc_dota_hero_dark_seer",
        "npc_dota_hero_furion",
        "npc_dota_hero_anti-mage"
    }, counter = {
        "npc_dota_hero_medusa",
        "npc_dota_hero_viper",
        "npc_dota_hero_death_prophet",
        "npc_dota_hero_abyssal_underlord",
        "npc_dota_hero_visage",
        "npc_dota_hero_batrider",
        "npc_dota_hero_doom_bringer",
        "npc_dota_hero_muerta",
        "npc_dota_hero_naga_siren"
    }},
    npc_dota_hero_jakiro = {synergy = {
        "npc_dota_hero_terrorblade",
        "npc_dota_hero_broodmother",
        "npc_dota_hero_meepo",
        "npc_dota_hero_marci",
        "npc_dota_hero_naga_siren",
        "npc_dota_hero_void_spirit",
        "npc_dota_hero_pudge",
        "npc_dota_hero_chaos_knight",
        "npc_dota_hero_earth_spirit",
        "npc_dota_hero_slark"
    }, counter = {
        "npc_dota_hero_naga_siren",
        "npc_dota_hero_meepo",
        "npc_dota_hero_broodmother",
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_chaos_knight",
        "npc_dota_hero_dawnbreaker",
        "npc_dota_hero_visage",
        "npc_dota_hero_enigma",
        "npc_dota_hero_riki"
    }},
    npc_dota_hero_juggernaut = {synergy = {
        "npc_dota_hero_bloodseeker",
        "npc_dota_hero_magnataur",
        "npc_dota_hero_ogre_magi",
        "npc_dota_hero_kunkka",
        "npc_dota_hero_gyrocopter",
        "npc_dota_hero_zuus",
        "npc_dota_hero_mirana",
        "npc_dota_hero_centaur",
        "npc_dota_hero_dark_seer",
        "npc_dota_hero_bounty_hunter"
    }, counter = {
        "npc_dota_hero_abyssal_underlord",
        "npc_dota_hero_bristleback",
        "npc_dota_hero_tidehunter",
        "npc_dota_hero_bloodseeker",
        "npc_dota_hero_kunkka",
        "npc_dota_hero_viper",
        "npc_dota_hero_dark_willow",
        "npc_dota_hero_phoenix",
        "npc_dota_hero_spectre"
    }},
    npc_dota_hero_keeper_of_the_light = {synergy = {
        "npc_dota_hero_terrorblade",
        "npc_dota_hero_obsidian_destroyer",
        "npc_dota_hero_enchantress",
        "npc_dota_hero_visage",
        "npc_dota_hero_medusa",
        "npc_dota_hero_clinkz",
        "npc_dota_hero_void_spirit",
        "npc_dota_hero_razor",
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_chaos_knight"
    }, counter = {
        "npc_dota_hero_dark_seer",
        "npc_dota_hero_warlock",
        "npc_dota_hero_abaddon",
        "npc_dota_hero_lone_druid",
        "npc_dota_hero_bloodseeker",
        "npc_dota_hero_arc_warden",
        "npc_dota_hero_troll_warlord",
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_naga_siren"
    }},
    npc_dota_hero_kunkka = {synergy = {
        "npc_dota_hero_dawnbreaker",
        "npc_dota_hero_necrolyte",
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_shadow_demon",
        "npc_dota_hero_lycan",
        "npc_dota_hero_slark",
        "npc_dota_hero_huskar",
        "npc_dota_hero_sven",
        "npc_dota_hero_bristleback"
    }, counter = {
        "npc_dota_hero_naga_siren",
        "npc_dota_hero_medusa",
        "npc_dota_hero_meepo",
        "npc_dota_hero_arc_warden",
        "npc_dota_hero_marci",
        "npc_dota_hero_lone_druid",
        "npc_dota_hero_grimstroke",
        "npc_dota_hero_chaos_knight",
        "npc_dota_hero_dark_seer"
    }},
    npc_dota_hero_legion_commander = {synergy = {
        "npc_dota_hero_omniknight",
        "npc_dota_hero_bristleback",
        "npc_dota_hero_shredder",
        "npc_dota_hero_troll_warlord",
        "npc_dota_hero_dawnbreaker",
        "npc_dota_hero_undying",
        "npc_dota_hero_leshrac",
        "npc_dota_hero_necrolyte",
        "npc_dota_hero_broodmother",
        "npc_dota_hero_snapfire"
    }, counter = {
        "npc_dota_hero_bristleback",
        "npc_dota_hero_meepo",
        "npc_dota_hero_arc_warden",
        "npc_dota_hero_phantom_lancer",
        "npc_dota_hero_anti-mage",
        "npc_dota_hero_faceless_void",
        "npc_dota_hero_bounty_hunter",
        "npc_dota_hero_weaver",
        "npc_dota_hero_venomancer",
        "npc_dota_hero_huskar"
    }},
    npc_dota_hero_leshrac = {synergy = {
        "npc_dota_hero_enigma",
        "npc_dota_hero_magnataur",
        "npc_dota_hero_bane",
        "npc_dota_hero_treant",
        "npc_dota_hero_ancient_apparition",
        "npc_dota_hero_mirana",
        "npc_dota_hero_sven",
        "npc_dota_hero_beastmaster"
    }, counter = {
        "npc_dota_hero_meepo",
        "npc_dota_hero_necrolyte",
        "npc_dota_hero_phantom_lancer",
        "npc_dota_hero_naga_siren",
        "npc_dota_hero_omniknight",
        "npc_dota_hero_riki",
        "npc_dota_hero_axe",
        "npc_dota_hero_arc_warden",
        "npc_dota_hero_tidehunter"
    }},
    npc_dota_hero_lich = {synergy = {
        "npc_dota_hero_lone_druid",
        "npc_dota_hero_huskar",
        "npc_dota_hero_naga_siren",
        "npc_dota_hero_grimstroke",
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_lycan",
        "npc_dota_hero_pudge",
        "npc_dota_hero_visage",
        "npc_dota_hero_spirit_breaker",
        "npc_dota_hero_slark"
    }, counter = {
        "npc_dota_hero_muerta",
        "npc_dota_hero_medusa",
        "npc_dota_hero_terrorblade",
        "npc_dota_hero_naga_siren",
        "npc_dota_hero_chaos_knight",
        "npc_dota_hero_monkey_king",
        "npc_dota_hero_marci",
        "npc_dota_hero_arc_warden",
        "npc_dota_hero_tidehunter"
    }},
    npc_dota_hero_life_stealer = {synergy = {
        "npc_dota_hero_batrider",
        "npc_dota_hero_phoenix",
        "npc_dota_hero_axe",
        "npc_dota_hero_primal_beast",
        "npc_dota_hero_dark_willow",
        "npc_dota_hero_invoker",
        "npc_dota_hero_earth_spirit",
        "npc_dota_hero_gyrocopter"
    }, counter = {
        "npc_dota_hero_centaur",
        "npc_dota_hero_tiny",
        "npc_dota_hero_skeleton_king",
        "npc_dota_hero_abyssal_underlord",
        "npc_dota_hero_spectre",
        "npc_dota_hero_phoenix",
        "npc_dota_hero_mars",
        "npc_dota_hero_kunkka",
        "npc_dota_hero_snapfire",
        "npc_dota_hero_sand_king"
    }},
    npc_dota_hero_lina = {synergy = {
        "npc_dota_hero_naga_siren",
        "npc_dota_hero_meepo",
        "npc_dota_hero_storm_spirit",
        "npc_dota_hero_riki",
        "npc_dota_hero_void_spirit",
        "npc_dota_hero_warlock",
        "npc_dota_hero_faceless_void",
        "npc_dota_hero_undying"
    }, counter = {
        "npc_dota_hero_naga_siren",
        "npc_dota_hero_lone_druid",
        "npc_dota_hero_phoenix",
        "npc_dota_hero_huskar",
        "npc_dota_hero_bloodseeker",
        "npc_dota_hero_meepo",
        "npc_dota_hero_troll_warlord",
        "npc_dota_hero_dawnbreaker",
        "npc_dota_hero_visage"
    }},
    npc_dota_hero_lion = {synergy = {
        "npc_dota_hero_lycan",
        "npc_dota_hero_meepo",
        "npc_dota_hero_naga_siren",
        "npc_dota_hero_grimstroke",
        "npc_dota_hero_visage",
        "npc_dota_hero_dark_seer",
        "npc_dota_hero_lone_druid",
        "npc_dota_hero_shredder",
        "npc_dota_hero_silencer"
    }, counter = {
        "npc_dota_hero_naga_siren",
        "npc_dota_hero_batrider",
        "npc_dota_hero_troll_warlord",
        "npc_dota_hero_legion_commander",
        "npc_dota_hero_slark",
        "npc_dota_hero_terrorblade",
        "npc_dota_hero_meepo",
        "npc_dota_hero_faceless_void",
        "npc_dota_hero_phoenix"
    }},
    npc_dota_hero_luna = {synergy = {
        "npc_dota_hero_visage",
        "npc_dota_hero_riki",
        "npc_dota_hero_broodmother",
        "npc_dota_hero_night_stalker",
        "npc_dota_hero_omniknight",
        "npc_dota_hero_mars",
        "npc_dota_hero_void_spirit",
        "npc_dota_hero_primal_beast",
        "npc_dota_hero_oracle"
    }, counter = {
        "npc_dota_hero_night_stalker",
        "npc_dota_hero_slardar",
        "npc_dota_hero_undying",
        "npc_dota_hero_lycan",
        "npc_dota_hero_sven",
        "npc_dota_hero_weaver"
    }},
    npc_dota_hero_lycan = {synergy = {
        "npc_dota_hero_batrider",
        "npc_dota_hero_death_prophet",
        "npc_dota_hero_magnataur",
        "npc_dota_hero_nevermore",
        "npc_dota_hero_huskar",
        "npc_dota_hero_bristleback",
        "npc_dota_hero_lion",
        "npc_dota_hero_troll_warlord"
    }, counter = {
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_night_stalker",
        "npc_dota_hero_death_prophet",
        "npc_dota_hero_skywrath_mage",
        "npc_dota_hero_silencer",
        "npc_dota_hero_arc_warden",
        "npc_dota_hero_ancient_apparition",
        "npc_dota_hero_viper",
        "npc_dota_hero_warlock"
    }},
    npc_dota_hero_magnataur = {synergy = {
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_leshrac",
        "npc_dota_hero_lycan",
        "npc_dota_hero_slardar",
        "npc_dota_hero_huskar",
        "npc_dota_hero_sand_king",
        "npc_dota_hero_broodmother",
        "npc_dota_hero_viper"
    }, counter = {
        "npc_dota_hero_shadow_demon",
        "npc_dota_hero_marci",
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_naga_siren",
        "npc_dota_hero_drow_ranger",
        "npc_dota_hero_lycan",
        "npc_dota_hero_pudge",
        "npc_dota_hero_bounty_hunter"
    }},
    npc_dota_hero_mars = {synergy = {
        "npc_dota_hero_lone_druid",
        "npc_dota_hero_dawnbreaker",
        "npc_dota_hero_slardar",
        "npc_dota_hero_night_stalker",
        "npc_dota_hero_tidehunter",
        "npc_dota_hero_dragon_knight",
        "npc_dota_hero_broodmother",
        "npc_dota_hero_arc_warden"
    }, counter = {
        "npc_dota_hero_drow_ranger",
        "npc_dota_hero_slark",
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_sniper",
        "npc_dota_hero_naga_siren",
        "npc_dota_hero_enchantress",
        "npc_dota_hero_death_prophet",
        "npc_dota_hero_mirana",
        "npc_dota_hero_windrunner",
        "npc_dota_hero_magnataur"
    }},
    npc_dota_hero_medusa = {synergy = {
        "npc_dota_hero_naga_siren",
        "npc_dota_hero_meepo",
        "npc_dota_hero_bloodseeker",
        "npc_dota_hero_riki",
        "npc_dota_hero_batrider",
        "npc_dota_hero_spectre",
        "npc_dota_hero_chaos_knight",
        "npc_dota_hero_void_spirit",
        "npc_dota_hero_keeper_of_the_light"
    }, counter = {
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_meepo",
        "npc_dota_hero_visage",
        "npc_dota_hero_naga_siren",
        "npc_dota_hero_undying",
        "npc_dota_hero_death_prophet",
        "npc_dota_hero_chaos_knight",
        "npc_dota_hero_queenofpain",
        "npc_dota_hero_dawnbreaker",
        "npc_dota_hero_obsidian_destroyer"
    }},
    npc_dota_hero_meepo = {synergy = {
        "npc_dota_hero_visage",
        "npc_dota_hero_monkey_king",
        "npc_dota_hero_doom_bringer",
        "npc_dota_hero_winter_wyvern",
        "npc_dota_hero_medusa",
        "npc_dota_hero_terrorblade",
        "npc_dota_hero_dark_willow",
        "npc_dota_hero_batrider"
    }, counter = {
        "npc_dota_hero_arc_warden",
        "npc_dota_hero_void_spirit",
        "npc_dota_hero_anti-mage",
        "npc_dota_hero_phantom_lancer",
        "npc_dota_hero_storm_spirit",
        "npc_dota_hero_faceless_void",
        "npc_dota_hero_clinkz",
        "npc_dota_hero_mirana",
        "npc_dota_hero_doom_bringer"
    }},
    npc_dota_hero_mirana = {synergy = {
        "npc_dota_hero_meepo",
        "npc_dota_hero_leshrac",
        "npc_dota_hero_viper",
        "npc_dota_hero_axe",
        "npc_dota_hero_obsidian_destroyer",
        "npc_dota_hero_ember_spirit",
        "npc_dota_hero_medusa",
        "npc_dota_hero_alchemist",
        "npc_dota_hero_dragon_knight"
    }, counter = {
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_medusa",
        "npc_dota_hero_death_prophet",
        "npc_dota_hero_visage",
        "npc_dota_hero_keeper_of_the_light",
        "npc_dota_hero_phoenix",
        "npc_dota_hero_razor",
        "npc_dota_hero_weaver",
        "npc_dota_hero_broodmother"
    }},
    npc_dota_hero_morphling = {synergy = {
        "npc_dota_hero_spectre",
        "npc_dota_hero_bloodseeker",
        "npc_dota_hero_clinkz",
        "npc_dota_hero_gyrocopter",
        "npc_dota_hero_death_prophet",
        "npc_dota_hero_naga_siren",
        "npc_dota_hero_visage",
        "npc_dota_hero_leshrac",
        "npc_dota_hero_doom_bringer"
    }, counter = {
        "npc_dota_hero_terrorblade",
        "npc_dota_hero_visage",
        "npc_dota_hero_sniper",
        "npc_dota_hero_viper",
        "npc_dota_hero_enigma",
        "npc_dota_hero_juggernaut",
        "npc_dota_hero_bloodseeker",
        "npc_dota_hero_furion"
    }},
    npc_dota_hero_monkey_king = {synergy = {
        "npc_dota_hero_meepo",
        "npc_dota_hero_alchemist",
        "npc_dota_hero_batrider",
        "npc_dota_hero_treant",
        "npc_dota_hero_oracle",
        "npc_dota_hero_abaddon",
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_shadow_demon"
    }, counter = {
        "npc_dota_hero_lone_druid",
        "npc_dota_hero_meepo",
        "npc_dota_hero_naga_siren",
        "npc_dota_hero_broodmother",
        "npc_dota_hero_ember_spirit",
        "npc_dota_hero_visage",
        "npc_dota_hero_abaddon",
        "npc_dota_hero_medusa"
    }},
    npc_dota_hero_muerta = {synergy = {
        "npc_dota_hero_tidehunter",
        "npc_dota_hero_necrolyte",
        "npc_dota_hero_marci",
        "npc_dota_hero_grimstroke",
        "npc_dota_hero_death_prophet",
        "npc_dota_hero_phoenix",
        "npc_dota_hero_visage",
        "npc_dota_hero_slark"
    }, counter = {
        "npc_dota_hero_kunkka",
        "npc_dota_hero_enchantress",
        "npc_dota_hero_keeper_of_the_light",
        "npc_dota_hero_medusa",
        "npc_dota_hero_lina",
        "npc_dota_hero_void_spirit",
        "npc_dota_hero_spectre",
        "npc_dota_hero_naga_siren",
        "npc_dota_hero_skywrath_mage"
    }},
    npc_dota_hero_naga_siren = {synergy = {
        "npc_dota_hero_nyx_assassin",
        "npc_dota_hero_bristleback",
        "npc_dota_hero_earth_spirit",
        "npc_dota_hero_lina",
        "npc_dota_hero_techies",
        "npc_dota_hero_medusa",
        "npc_dota_hero_earthshaker",
        "npc_dota_hero_winter_wyvern",
        "npc_dota_hero_jakiro"
    }, counter = {
        "npc_dota_hero_lycan",
        "npc_dota_hero_night_stalker",
        "npc_dota_hero_chaos_knight",
        "npc_dota_hero_broodmother",
        "npc_dota_hero_viper",
        "npc_dota_hero_clinkz",
        "npc_dota_hero_ancient_apparition",
        "npc_dota_hero_faceless_void"
    }},
    npc_dota_hero_necrolyte = {synergy = {
        "npc_dota_hero_riki",
        "npc_dota_hero_kunkka",
        "npc_dota_hero_mars",
        "npc_dota_hero_omniknight",
        "npc_dota_hero_furion",
        "npc_dota_hero_enigma",
        "npc_dota_hero_night_stalker",
        "npc_dota_hero_spirit_breaker",
        "npc_dota_hero_dawnbreaker"
    }, counter = {
        "npc_dota_hero_phantom_lancer",
        "npc_dota_hero_huskar",
        "npc_dota_hero_spectre",
        "npc_dota_hero_tiny",
        "npc_dota_hero_tidehunter",
        "npc_dota_hero_axe",
        "npc_dota_hero_spirit_breaker",
        "npc_dota_hero_naga_siren",
        "npc_dota_hero_omniknight",
        "npc_dota_hero_zuus"
    }},
    npc_dota_hero_nevermore = {synergy = {
        "npc_dota_hero_marci",
        "npc_dota_hero_lycan",
        "npc_dota_hero_bane",
        "npc_dota_hero_skeleton_king",
        "npc_dota_hero_shadow_shaman",
        "npc_dota_hero_night_stalker",
        "npc_dota_hero_dazzle",
        "npc_dota_hero_phantom_assassin"
    }, counter = {
        "npc_dota_hero_meepo",
        "npc_dota_hero_necrolyte",
        "npc_dota_hero_oracle",
        "npc_dota_hero_ember_spirit",
        "npc_dota_hero_anti-mage",
        "npc_dota_hero_huskar",
        "npc_dota_hero_slark",
        "npc_dota_hero_lone_druid",
        "npc_dota_hero_beastmaster"
    }},
    npc_dota_hero_night_stalker = {synergy = {
        "npc_dota_hero_dawnbreaker",
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_primal_beast",
        "npc_dota_hero_earthshaker",
        "npc_dota_hero_luna",
        "npc_dota_hero_mars",
        "npc_dota_hero_sand_king",
        "npc_dota_hero_winter_wyvern",
        "npc_dota_hero_dragon_knight"
    }, counter = {
        "npc_dota_hero_juggernaut",
        "npc_dota_hero_shredder",
        "npc_dota_hero_storm_spirit",
        "npc_dota_hero_queenofpain",
        "npc_dota_hero_earth_spirit",
        "npc_dota_hero_void_spirit",
        "npc_dota_hero_drow_ranger"
    }},
    npc_dota_hero_nyx_assassin = {synergy = {
        "npc_dota_hero_naga_siren",
        "npc_dota_hero_enchantress",
        "npc_dota_hero_tidehunter",
        "npc_dota_hero_medusa",
        "npc_dota_hero_faceless_void",
        "npc_dota_hero_sniper",
        "npc_dota_hero_dark_seer",
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_sven",
        "npc_dota_hero_warlock"
    }, counter = {
        "npc_dota_hero_medusa",
        "npc_dota_hero_muerta",
        "npc_dota_hero_weaver",
        "npc_dota_hero_enigma",
        "npc_dota_hero_sniper",
        "npc_dota_hero_storm_spirit",
        "npc_dota_hero_dawnbreaker",
        "npc_dota_hero_shredder"
    }},
    npc_dota_hero_obsidian_destroyer = {synergy = {
        "npc_dota_hero_abyssal_underlord",
        "npc_dota_hero_keeper_of_the_light",
        "npc_dota_hero_faceless_void",
        "npc_dota_hero_primal_beast",
        "npc_dota_hero_treant",
        "npc_dota_hero_razor",
        "npc_dota_hero_mirana",
        "npc_dota_hero_rattletrap",
        "npc_dota_hero_alchemist"
    }, counter = {
        "npc_dota_hero_shredder",
        "npc_dota_hero_axe",
        "npc_dota_hero_abaddon",
        "npc_dota_hero_leshrac",
        "npc_dota_hero_troll_warlord",
        "npc_dota_hero_omniknight",
        "npc_dota_hero_oracle",
        "npc_dota_hero_faceless_void",
        "npc_dota_hero_winter_wyvern",
        "npc_dota_hero_slark"
    }},
    npc_dota_hero_ogre_magi = {synergy = {
        "npc_dota_hero_keeper_of_the_light",
        "npc_dota_hero_sniper",
        "npc_dota_hero_warlock",
        "npc_dota_hero_medusa",
        "npc_dota_hero_juggernaut",
        "npc_dota_hero_troll_warlord",
        "npc_dota_hero_sven",
        "npc_dota_hero_tiny"
    }, counter = {
        "npc_dota_hero_ursa",
        "npc_dota_hero_troll_warlord",
        "npc_dota_hero_medusa",
        "npc_dota_hero_batrider",
        "npc_dota_hero_windrunner",
        "npc_dota_hero_phantom_assassin",
        "npc_dota_hero_night_stalker",
        "npc_dota_hero_keeper_of_the_light",
        "npc_dota_hero_bane"
    }},
    npc_dota_hero_omniknight = {synergy = {
        "npc_dota_hero_bristleback",
        "npc_dota_hero_abyssal_underlord",
        "npc_dota_hero_visage",
        "npc_dota_hero_shredder",
        "npc_dota_hero_muerta",
        "npc_dota_hero_legion_commander",
        "npc_dota_hero_bloodseeker",
        "npc_dota_hero_primal_beast"
    }, counter = {
        "npc_dota_hero_legion_commander",
        "npc_dota_hero_meepo",
        "npc_dota_hero_slark",
        "npc_dota_hero_keeper_of_the_light",
        "npc_dota_hero_abyssal_underlord",
        "npc_dota_hero_naga_siren",
        "npc_dota_hero_dazzle",
        "npc_dota_hero_abaddon",
        "npc_dota_hero_ursa"
    }},
    npc_dota_hero_oracle = {synergy = {
        "npc_dota_hero_visage",
        "npc_dota_hero_huskar",
        "npc_dota_hero_windrunner",
        "npc_dota_hero_sand_king",
        "npc_dota_hero_rubick",
        "npc_dota_hero_gyrocopter",
        "npc_dota_hero_luna"
    }, counter = {
        "npc_dota_hero_legion_commander",
        "npc_dota_hero_skywrath_mage",
        "npc_dota_hero_centaur",
        "npc_dota_hero_necrolyte",
        "npc_dota_hero_bloodseeker",
        "npc_dota_hero_dark_seer",
        "npc_dota_hero_troll_warlord",
        "npc_dota_hero_storm_spirit"
    }},
    npc_dota_hero_pangolier = {synergy = {
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_meepo",
        "npc_dota_hero_razor",
        "npc_dota_hero_oracle",
        "npc_dota_hero_lycan",
        "npc_dota_hero_luna",
        "npc_dota_hero_phantom_lancer"
    }, counter = {
        "npc_dota_hero_life_stealer",
        "npc_dota_hero_dawnbreaker",
        "npc_dota_hero_enigma",
        "npc_dota_hero_oracle",
        "npc_dota_hero_leshrac",
        "npc_dota_hero_chaos_knight",
        "npc_dota_hero_arc_warden",
        "npc_dota_hero_pugna",
        "npc_dota_hero_earth_spirit"
    }},
    npc_dota_hero_phantom_lancer = {synergy = {
        "npc_dota_hero_grimstroke",
        "npc_dota_hero_kunkka",
        "npc_dota_hero_invoker",
        "npc_dota_hero_lone_druid",
        "npc_dota_hero_skywrath_mage",
        "npc_dota_hero_bane",
        "npc_dota_hero_arc_warden",
        "npc_dota_hero_keeper_of_the_light",
        "npc_dota_hero_witch_doctor"
    }, counter = {
        "npc_dota_hero_viper",
        "npc_dota_hero_templar_assassin",
        "npc_dota_hero_arc_warden",
        "npc_dota_hero_obsidian_destroyer",
        "npc_dota_hero_dragon_knight",
        "npc_dota_hero_ogre_magi",
        "npc_dota_hero_chaos_knight",
        "npc_dota_hero_skeleton_king",
        "npc_dota_hero_shadow_shaman",
        "npc_dota_hero_slardar"
    }},
    npc_dota_hero_phantom_assassin = {synergy = {
        "npc_dota_hero_arc_warden",
        "npc_dota_hero_bristleback",
        "npc_dota_hero_enchantress",
        "npc_dota_hero_death_prophet",
        "npc_dota_hero_nevermore",
        "npc_dota_hero_slark",
        "npc_dota_hero_broodmother",
        "npc_dota_hero_magnataur",
        "npc_dota_hero_techies",
        "npc_dota_hero_tidehunter"
    }, counter = {
        "npc_dota_hero_lone_druid",
        "npc_dota_hero_anti-mage",
        "npc_dota_hero_broodmother",
        "npc_dota_hero_keeper_of_the_light",
        "npc_dota_hero_visage",
        "npc_dota_hero_huskar",
        "npc_dota_hero_life_stealer",
        "npc_dota_hero_enchantress",
        "npc_dota_hero_furion",
        "npc_dota_hero_lina"
    }},
    npc_dota_hero_phoenix = {synergy = {
        "npc_dota_hero_broodmother",
        "npc_dota_hero_lone_druid",
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_terrorblade",
        "npc_dota_hero_enigma",
        "npc_dota_hero_marci",
        "npc_dota_hero_huskar"
    }, counter = {
        "npc_dota_hero_chaos_knight",
        "npc_dota_hero_lone_druid",
        "npc_dota_hero_skeleton_king",
        "npc_dota_hero_lycan",
        "npc_dota_hero_treant",
        "npc_dota_hero_sven",
        "npc_dota_hero_templar_assassin",
        "npc_dota_hero_broodmother",
        "npc_dota_hero_tiny"
    }},
    npc_dota_hero_puck = {synergy = {
        "npc_dota_hero_terrorblade",
        "npc_dota_hero_snapfire",
        "npc_dota_hero_life_stealer",
        "npc_dota_hero_gyrocopter",
        "npc_dota_hero_bounty_hunter",
        "npc_dota_hero_ursa"
    }, counter = {
        "npc_dota_hero_phantom_lancer",
        "npc_dota_hero_enchantress",
        "npc_dota_hero_terrorblade",
        "npc_dota_hero_mars",
        "npc_dota_hero_storm_spirit",
        "npc_dota_hero_dark_seer",
        "npc_dota_hero_dawnbreaker"
    }},
    npc_dota_hero_pudge = {synergy = {
        "npc_dota_hero_pugna",
        "npc_dota_hero_enigma",
        "npc_dota_hero_abyssal_underlord",
        "npc_dota_hero_silencer",
        "npc_dota_hero_ancient_apparition",
        "npc_dota_hero_winter_wyvern",
        "npc_dota_hero_muerta",
        "npc_dota_hero_treant",
        "npc_dota_hero_jakiro",
        "npc_dota_hero_dark_willow"
    }, counter = {
        "npc_dota_hero_spectre",
        "npc_dota_hero_necrolyte",
        "npc_dota_hero_phantom_assassin",
        "npc_dota_hero_muerta",
        "npc_dota_hero_axe",
        "npc_dota_hero_sniper",
        "npc_dota_hero_naga_siren",
        "npc_dota_hero_pugna",
        "npc_dota_hero_phantom_lancer",
        "npc_dota_hero_crystal_maiden"
    }},
    npc_dota_hero_pugna = {synergy = {
        "npc_dota_hero_visage",
        "npc_dota_hero_bloodseeker",
        "npc_dota_hero_ember_spirit",
        "npc_dota_hero_winter_wyvern",
        "npc_dota_hero_pudge",
        "npc_dota_hero_axe",
        "npc_dota_hero_abyssal_underlord",
        "npc_dota_hero_alchemist",
        "npc_dota_hero_spirit_breaker",
        "npc_dota_hero_furion"
    }, counter = {
        "npc_dota_hero_shredder",
        "npc_dota_hero_storm_spirit",
        "npc_dota_hero_omniknight",
        "npc_dota_hero_necrolyte",
        "npc_dota_hero_grimstroke",
        "npc_dota_hero_winter_wyvern",
        "npc_dota_hero_queenofpain",
        "npc_dota_hero_bane"
    }},
    npc_dota_hero_queenofpain = {synergy = {
        "npc_dota_hero_alchemist",
        "npc_dota_hero_muerta",
        "npc_dota_hero_mars",
        "npc_dota_hero_ember_spirit",
        "npc_dota_hero_enigma",
        "npc_dota_hero_nyx_assassin",
        "npc_dota_hero_abyssal_underlord",
        "npc_dota_hero_doom_bringer",
        "npc_dota_hero_death_prophet",
        "npc_dota_hero_life_stealer"
    }, counter = {
        "npc_dota_hero_razor",
        "npc_dota_hero_keeper_of_the_light",
        "npc_dota_hero_monkey_king",
        "npc_dota_hero_rattletrap",
        "npc_dota_hero_dark_seer",
        "npc_dota_hero_shadow_demon",
        "npc_dota_hero_alchemist",
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_leshrac"
    }},
    npc_dota_hero_rattletrap = {synergy = {
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_bloodseeker",
        "npc_dota_hero_naga_siren",
        "npc_dota_hero_winter_wyvern",
        "npc_dota_hero_dark_seer",
        "npc_dota_hero_broodmother",
        "npc_dota_hero_obsidian_destroyer",
        "npc_dota_hero_huskar",
        "npc_dota_hero_keeper_of_the_light"
    }, counter = {
        "npc_dota_hero_slark",
        "npc_dota_hero_sniper",
        "npc_dota_hero_razor",
        "npc_dota_hero_spirit_breaker",
        "npc_dota_hero_drow_ranger",
        "npc_dota_hero_windrunner",
        "npc_dota_hero_treant",
        "npc_dota_hero_crystal_maiden",
        "npc_dota_hero_medusa"
    }},
    npc_dota_hero_razor = {synergy = {
        "npc_dota_hero_faceless_void",
        "npc_dota_hero_dawnbreaker",
        "npc_dota_hero_bloodseeker",
        "npc_dota_hero_keeper_of_the_light",
        "npc_dota_hero_obsidian_destroyer",
        "npc_dota_hero_spirit_breaker",
        "npc_dota_hero_abyssal_underlord"
    }, counter = {
        "npc_dota_hero_troll_warlord",
        "npc_dota_hero_tidehunter",
        "npc_dota_hero_dazzle",
        "npc_dota_hero_life_stealer",
        "npc_dota_hero_death_prophet",
        "npc_dota_hero_lion",
        "npc_dota_hero_shadow_demon",
        "npc_dota_hero_grimstroke",
        "npc_dota_hero_abaddon"
    }},
    npc_dota_hero_riki = {synergy = {
        "npc_dota_hero_silencer",
        "npc_dota_hero_luna",
        "npc_dota_hero_necrolyte",
        "npc_dota_hero_medusa",
        "npc_dota_hero_meepo",
        "npc_dota_hero_warlock",
        "npc_dota_hero_terrorblade",
        "npc_dota_hero_muerta",
        "npc_dota_hero_bristleback"
    }, counter = {
        "npc_dota_hero_storm_spirit",
        "npc_dota_hero_clinkz",
        "npc_dota_hero_witch_doctor",
        "npc_dota_hero_ursa",
        "npc_dota_hero_queenofpain",
        "npc_dota_hero_oracle",
        "npc_dota_hero_juggernaut"
    }},
    npc_dota_hero_rubick = {synergy = {
        "npc_dota_hero_oracle",
        "npc_dota_hero_naga_siren",
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_life_stealer",
        "npc_dota_hero_broodmother",
        "npc_dota_hero_keeper_of_the_light",
        "npc_dota_hero_visage"
    }, counter = {
        "npc_dota_hero_abyssal_underlord",
        "npc_dota_hero_enigma",
        "npc_dota_hero_jakiro",
        "npc_dota_hero_obsidian_destroyer",
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_crystal_maiden",
        "npc_dota_hero_weaver",
        "npc_dota_hero_medusa",
        "npc_dota_hero_phantom_lancer",
        "npc_dota_hero_skeleton_king"
    }},
    npc_dota_hero_sand_king = {synergy = {
        "npc_dota_hero_omniknight",
        "npc_dota_hero_abaddon",
        "npc_dota_hero_doom_bringer",
        "npc_dota_hero_slardar",
        "npc_dota_hero_dark_seer",
        "npc_dota_hero_chaos_knight",
        "npc_dota_hero_night_stalker",
        "npc_dota_hero_oracle",
        "npc_dota_hero_magnataur"
    }, counter = {
        "npc_dota_hero_naga_siren",
        "npc_dota_hero_phantom_lancer",
        "npc_dota_hero_chaos_knight",
        "npc_dota_hero_dark_seer",
        "npc_dota_hero_meepo",
        "npc_dota_hero_shadow_demon",
        "npc_dota_hero_medusa",
        "npc_dota_hero_primal_beast",
        "npc_dota_hero_lone_druid",
        "npc_dota_hero_skeleton_king"
    }},
    npc_dota_hero_shadow_demon = {synergy = {
        "npc_dota_hero_terrorblade",
        "npc_dota_hero_visage",
        "npc_dota_hero_lone_druid",
        "npc_dota_hero_dark_seer",
        "npc_dota_hero_bloodseeker",
        "npc_dota_hero_dark_willow"
    }, counter = {
        "npc_dota_hero_oracle",
        "npc_dota_hero_abaddon",
        "npc_dota_hero_arc_warden",
        "npc_dota_hero_huskar",
        "npc_dota_hero_muerta",
        "npc_dota_hero_obsidian_destroyer",
        "npc_dota_hero_omniknight"
    }},
    npc_dota_hero_shadow_shaman = {synergy = {
        "npc_dota_hero_keeper_of_the_light",
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_enigma",
        "npc_dota_hero_tidehunter",
        "npc_dota_hero_medusa",
        "npc_dota_hero_earth_spirit",
        "npc_dota_hero_skywrath_mage",
        "npc_dota_hero_treant"
    }, counter = {
        "npc_dota_hero_death_prophet",
        "npc_dota_hero_storm_spirit",
        "npc_dota_hero_lycan",
        "npc_dota_hero_ursa",
        "npc_dota_hero_bloodseeker",
        "npc_dota_hero_clinkz",
        "npc_dota_hero_faceless_void",
        "npc_dota_hero_earth_spirit",
        "npc_dota_hero_oracle"
    }},
    npc_dota_hero_shredder = {synergy = {
        "npc_dota_hero_tidehunter",
        "npc_dota_hero_lone_druid",
        "npc_dota_hero_omniknight",
        "npc_dota_hero_legion_commander",
        "npc_dota_hero_visage",
        "npc_dota_hero_dawnbreaker",
        "npc_dota_hero_spirit_breaker",
        "npc_dota_hero_dark_seer",
        "npc_dota_hero_abaddon"
    }, counter = {
        "npc_dota_hero_phantom_lancer",
        "npc_dota_hero_meepo",
        "npc_dota_hero_naga_siren",
        "npc_dota_hero_huskar",
        "npc_dota_hero_chaos_knight",
        "npc_dota_hero_axe",
        "npc_dota_hero_terrorblade",
        "npc_dota_hero_shadow_demon",
        "npc_dota_hero_treant",
        "npc_dota_hero_techies"
    }},
    npc_dota_hero_silencer = {synergy = {
        "npc_dota_hero_riki",
        "npc_dota_hero_earth_spirit",
        "npc_dota_hero_pudge",
        "npc_dota_hero_shadow_shaman",
        "npc_dota_hero_crystal_maiden",
        "npc_dota_hero_rattletrap",
        "npc_dota_hero_death_prophet",
        "npc_dota_hero_magnataur",
        "npc_dota_hero_enigma",
        "npc_dota_hero_lion"
    }, counter = {
        "npc_dota_hero_leshrac",
        "npc_dota_hero_shredder",
        "npc_dota_hero_shadow_shaman",
        "npc_dota_hero_storm_spirit",
        "npc_dota_hero_death_prophet",
        "npc_dota_hero_bane",
        "npc_dota_hero_bristleback",
        "npc_dota_hero_obsidian_destroyer",
        "npc_dota_hero_dawnbreaker"
    }},
    npc_dota_hero_skeleton_king = {synergy = {
        "npc_dota_hero_arc_warden",
        "npc_dota_hero_enigma",
        "npc_dota_hero_bloodseeker",
        "npc_dota_hero_huskar",
        "npc_dota_hero_earth_spirit",
        "npc_dota_hero_bristleback",
        "npc_dota_hero_kunkka",
        "npc_dota_hero_nevermore",
        "npc_dota_hero_beastmaster"
    }, counter = {
        "npc_dota_hero_silencer",
        "npc_dota_hero_riki",
        "npc_dota_hero_enigma",
        "npc_dota_hero_huskar",
        "npc_dota_hero_skywrath_mage",
        "npc_dota_hero_muerta",
        "npc_dota_hero_legion_commander",
        "npc_dota_hero_axe",
        "npc_dota_hero_doom_bringer"
    }},
    npc_dota_hero_skywrath_mage = {synergy = {
        "npc_dota_hero_terrorblade",
        "npc_dota_hero_broodmother",
        "npc_dota_hero_troll_warlord",
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_phantom_lancer",
        "npc_dota_hero_visage",
        "npc_dota_hero_arc_warden",
        "npc_dota_hero_medusa"
    }, counter = {
        "npc_dota_hero_phoenix",
        "npc_dota_hero_necrolyte",
        "npc_dota_hero_muerta",
        "npc_dota_hero_sand_king",
        "npc_dota_hero_storm_spirit",
        "npc_dota_hero_terrorblade",
        "npc_dota_hero_leshrac",
        "npc_dota_hero_juggernaut",
        "npc_dota_hero_shredder"
    }},
    npc_dota_hero_slardar = {synergy = {
        "npc_dota_hero_dawnbreaker",
        "npc_dota_hero_mars",
        "npc_dota_hero_bristleback",
        "npc_dota_hero_alchemist",
        "npc_dota_hero_sand_king",
        "npc_dota_hero_muerta",
        "npc_dota_hero_chaos_knight",
        "npc_dota_hero_lone_druid",
        "npc_dota_hero_primal_beast"
    }, counter = {
        "npc_dota_hero_life_stealer",
        "npc_dota_hero_anti-mage",
        "npc_dota_hero_leshrac",
        "npc_dota_hero_pudge",
        "npc_dota_hero_clinkz",
        "npc_dota_hero_centaur",
        "npc_dota_hero_ember_spirit",
        "npc_dota_hero_ursa"
    }},
    npc_dota_hero_slark = {synergy = {
        "npc_dota_hero_bloodseeker",
        "npc_dota_hero_anti-mage",
        "npc_dota_hero_abyssal_underlord",
        "npc_dota_hero_kunkka",
        "npc_dota_hero_death_prophet",
        "npc_dota_hero_bristleback",
        "npc_dota_hero_lich",
        "npc_dota_hero_grimstroke",
        "npc_dota_hero_jakiro"
    }, counter = {
        "npc_dota_hero_bristleback",
        "npc_dota_hero_troll_warlord",
        "npc_dota_hero_ember_spirit",
        "npc_dota_hero_broodmother",
        "npc_dota_hero_lycan",
        "npc_dota_hero_tidehunter",
        "npc_dota_hero_bane",
        "npc_dota_hero_medusa",
        "npc_dota_hero_batrider"
    }},
    npc_dota_hero_snapfire = {synergy = {
        "npc_dota_hero_meepo",
        "npc_dota_hero_visage",
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_void_spirit",
        "npc_dota_hero_marci",
        "npc_dota_hero_huskar",
        "npc_dota_hero_lone_druid"
    }, counter = {
        "npc_dota_hero_earth_spirit",
        "npc_dota_hero_pugna",
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_visage",
        "npc_dota_hero_dawnbreaker",
        "npc_dota_hero_abyssal_underlord",
        "npc_dota_hero_meepo",
        "npc_dota_hero_doom_bringer"
    }},
    npc_dota_hero_sniper = {synergy = {
        "npc_dota_hero_ogre_magi",
        "npc_dota_hero_nyx_assassin",
        "npc_dota_hero_omniknight",
        "npc_dota_hero_vengefulspirit",
        "npc_dota_hero_pudge",
        "npc_dota_hero_slark",
        "npc_dota_hero_skeleton_king",
        "npc_dota_hero_slardar",
        "npc_dota_hero_chaos_knight"
    }, counter = {
        "npc_dota_hero_sand_king",
        "npc_dota_hero_medusa",
        "npc_dota_hero_leshrac",
        "npc_dota_hero_enigma",
        "npc_dota_hero_keeper_of_the_light",
        "npc_dota_hero_templar_assassin",
        "npc_dota_hero_huskar",
        "npc_dota_hero_silencer",
        "npc_dota_hero_pugna"
    }},
    npc_dota_hero_spectre = {synergy = {
        "npc_dota_hero_medusa",
        "npc_dota_hero_bristleback",
        "npc_dota_hero_clinkz",
        "npc_dota_hero_enchantress",
        "npc_dota_hero_witch_doctor",
        "npc_dota_hero_keeper_of_the_light",
        "npc_dota_hero_omniknight",
        "npc_dota_hero_muerta"
    }, counter = {
        "npc_dota_hero_sniper",
        "npc_dota_hero_luna",
        "npc_dota_hero_arc_warden",
        "npc_dota_hero_muerta",
        "npc_dota_hero_riki",
        "npc_dota_hero_broodmother",
        "npc_dota_hero_silencer",
        "npc_dota_hero_windrunner",
        "npc_dota_hero_furion",
        "npc_dota_hero_clinkz"
    }},
    npc_dota_hero_spirit_breaker = {synergy = {
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_dark_seer",
        "npc_dota_hero_abyssal_underlord",
        "npc_dota_hero_shredder",
        "npc_dota_hero_warlock",
        "npc_dota_hero_alchemist",
        "npc_dota_hero_earthshaker",
        "npc_dota_hero_kunkka",
        "npc_dota_hero_keeper_of_the_light"
    }, counter = {
        "npc_dota_hero_broodmother",
        "npc_dota_hero_legion_commander",
        "npc_dota_hero_bloodseeker",
        "npc_dota_hero_juggernaut",
        "npc_dota_hero_life_stealer",
        "npc_dota_hero_sniper",
        "npc_dota_hero_nevermore",
        "npc_dota_hero_night_stalker",
        "npc_dota_hero_windrunner"
    }},
    npc_dota_hero_storm_spirit = {synergy = {
        "npc_dota_hero_ancient_apparition",
        "npc_dota_hero_abyssal_underlord",
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_gyrocopter",
        "npc_dota_hero_shadow_demon",
        "npc_dota_hero_dawnbreaker",
        "npc_dota_hero_drow_ranger",
        "npc_dota_hero_jakiro",
        "npc_dota_hero_phoenix",
        "npc_dota_hero_techies"
    }, counter = {
        "npc_dota_hero_sniper",
        "npc_dota_hero_zuus",
        "npc_dota_hero_mars",
        "npc_dota_hero_venomancer",
        "npc_dota_hero_bristleback",
        "npc_dota_hero_razor",
        "npc_dota_hero_ancient_apparition",
        "npc_dota_hero_keeper_of_the_light",
        "npc_dota_hero_bloodseeker",
        "npc_dota_hero_spectre"
    }},
    npc_dota_hero_sven = {synergy = {
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_omniknight",
        "npc_dota_hero_bloodseeker",
        "npc_dota_hero_doom_bringer",
        "npc_dota_hero_leshrac",
        "npc_dota_hero_muerta",
        "npc_dota_hero_slardar",
        "npc_dota_hero_necrolyte"
    }, counter = {
        "npc_dota_hero_meepo",
        "npc_dota_hero_lycan",
        "npc_dota_hero_primal_beast",
        "npc_dota_hero_pugna",
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_broodmother",
        "npc_dota_hero_ember_spirit",
        "npc_dota_hero_phantom_lancer",
        "npc_dota_hero_lone_druid"
    }},
    npc_dota_hero_techies = {synergy = {
        "npc_dota_hero_naga_siren",
        "npc_dota_hero_arc_warden",
        "npc_dota_hero_lone_druid",
        "npc_dota_hero_bane",
        "npc_dota_hero_visage",
        "npc_dota_hero_broodmother",
        "npc_dota_hero_huskar"
    }, counter = {
        "npc_dota_hero_lone_druid",
        "npc_dota_hero_slark",
        "npc_dota_hero_naga_siren",
        "npc_dota_hero_meepo",
        "npc_dota_hero_marci",
        "npc_dota_hero_legion_commander",
        "npc_dota_hero_riki",
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_windrunner",
        "npc_dota_hero_sven"
    }},
    npc_dota_hero_terrorblade = {synergy = {
        "npc_dota_hero_primal_beast",
        "npc_dota_hero_visage",
        "npc_dota_hero_arc_warden",
        "npc_dota_hero_shadow_demon",
        "npc_dota_hero_lone_druid",
        "npc_dota_hero_batrider",
        "npc_dota_hero_dawnbreaker",
        "npc_dota_hero_broodmother",
        "npc_dota_hero_skywrath_mage"
    }, counter = {
        "npc_dota_hero_broodmother",
        "npc_dota_hero_visage",
        "npc_dota_hero_lone_druid",
        "npc_dota_hero_slardar",
        "npc_dota_hero_templar_assassin",
        "npc_dota_hero_anti-mage",
        "npc_dota_hero_chaos_knight",
        "npc_dota_hero_viper",
        "npc_dota_hero_beastmaster"
    }},
    npc_dota_hero_templar_assassin = {synergy = {
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_oracle",
        "npc_dota_hero_vengefulspirit",
        "npc_dota_hero_snapfire",
        "npc_dota_hero_abyssal_underlord",
        "npc_dota_hero_mars",
        "npc_dota_hero_muerta",
        "npc_dota_hero_disruptor"
    }, counter = {
        "npc_dota_hero_leshrac",
        "npc_dota_hero_obsidian_destroyer",
        "npc_dota_hero_sven",
        "npc_dota_hero_skywrath_mage",
        "npc_dota_hero_bloodseeker",
        "npc_dota_hero_nyx_assassin",
        "npc_dota_hero_shredder",
        "npc_dota_hero_night_stalker",
        "npc_dota_hero_oracle"
    }},
    npc_dota_hero_tidehunter = {synergy = {
        "npc_dota_hero_shredder",
        "npc_dota_hero_bloodseeker",
        "npc_dota_hero_arc_warden",
        "npc_dota_hero_alchemist",
        "npc_dota_hero_marci",
        "npc_dota_hero_nyx_assassin",
        "npc_dota_hero_spirit_breaker",
        "npc_dota_hero_slardar",
        "npc_dota_hero_omniknight"
    }, counter = {
        "npc_dota_hero_naga_siren",
        "npc_dota_hero_chaos_knight",
        "npc_dota_hero_arc_warden",
        "npc_dota_hero_earth_spirit",
        "npc_dota_hero_broodmother",
        "npc_dota_hero_lone_druid",
        "npc_dota_hero_meepo",
        "npc_dota_hero_visage",
        "npc_dota_hero_phantom_lancer"
    }},
    npc_dota_hero_tinker = {synergy = {
        "npc_dota_hero_grimstroke",
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_snapfire",
        "npc_dota_hero_night_stalker",
        "npc_dota_hero_anti-mage",
        "npc_dota_hero_furion",
        "npc_dota_hero_gyrocopter",
        "npc_dota_hero_kunkka",
        "npc_dota_hero_rattletrap"
    }, counter = {
        "npc_dota_hero_terrorblade",
        "npc_dota_hero_ember_spirit",
        "npc_dota_hero_skeleton_king",
        "npc_dota_hero_phantom_lancer",
        "npc_dota_hero_meepo",
        "npc_dota_hero_keeper_of_the_light",
        "npc_dota_hero_chaos_knight",
        "npc_dota_hero_arc_warden",
        "npc_dota_hero_venomancer",
        "npc_dota_hero_viper"
    }},
    npc_dota_hero_tiny = {synergy = {
        "npc_dota_hero_dark_seer",
        "npc_dota_hero_ancient_apparition",
        "npc_dota_hero_dawnbreaker",
        "npc_dota_hero_magnataur",
        "npc_dota_hero_primal_beast",
        "npc_dota_hero_winter_wyvern",
        "npc_dota_hero_keeper_of_the_light"
    }, counter = {
        "npc_dota_hero_antimage",
        "npc_dota_hero_naga_siren",
        "npc_dota_hero_riki",
        "npc_dota_hero_axe",
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_spirit_breaker",
        "npc_dota_hero_enigma",
        "npc_dota_hero_chaos_knight",
        "npc_dota_hero_dark_seer"
    }},
    npc_dota_hero_treant = {synergy = {
        "npc_dota_hero_visage",
        "npc_dota_hero_earth_spirit",
        "npc_dota_hero_ember_spirit",
        "npc_dota_hero_monkey_king",
        "npc_dota_hero_death_prophet",
        "npc_dota_hero_leshrac",
        "npc_dota_hero_dawnbreaker",
        "npc_dota_hero_obsidian_destroyer",
        "npc_dota_hero_pudge",
        "npc_dota_hero_lycan"
    }, counter = {
        "npc_dota_hero_mirana",
        "npc_dota_hero_enigma",
        "npc_dota_hero_skeleton_king",
        "npc_dota_hero_dragon_knight",
        "npc_dota_hero_legion_commander",
        "npc_dota_hero_abyssal_underlord",
        "npc_dota_hero_shadow_shaman",
        "npc_dota_hero_templar_assassin",
        "npc_dota_hero_chaos_knight"
    }},
    npc_dota_hero_troll_warlord = {synergy = {
        "npc_dota_hero_batrider",
        "npc_dota_hero_huskar",
        "npc_dota_hero_skywrath_mage",
        "npc_dota_hero_legion_commander",
        "npc_dota_hero_lycan",
        "npc_dota_hero_night_stalker",
        "npc_dota_hero_meepo",
        "npc_dota_hero_nevermore",
        "npc_dota_hero_marci"
    }, counter = {
        "npc_dota_hero_meepo",
        "npc_dota_hero_lycan",
        "npc_dota_hero_slardar",
        "npc_dota_hero_earth_spirit",
        "npc_dota_hero_marci",
        "npc_dota_hero_templar_assassin",
        "npc_dota_hero_void_spirit",
        "npc_dota_hero_ember_spirit"
    }},
    npc_dota_hero_tusk = {synergy = {
        "npc_dota_hero_visage",
        "npc_dota_hero_monkey_king",
        "npc_dota_hero_muerta",
        "npc_dota_hero_abyssal_underlord",
        "npc_dota_hero_shadow_demon",
        "npc_dota_hero_mars",
        "npc_dota_hero_bristleback",
        "npc_dota_hero_sven"
    }, counter = {
        "npc_dota_hero_sven",
        "npc_dota_hero_legion_commander",
        "npc_dota_hero_clinkz",
        "npc_dota_hero_shadow_demon",
        "npc_dota_hero_visage",
        "npc_dota_hero_obsidian_destroyer",
        "npc_dota_hero_alchemist",
        "npc_dota_hero_arc_warden",
        "npc_dota_hero_bane"
    }},
    npc_dota_hero_undying = {synergy = {
        "npc_dota_hero_winter_wyvern",
        "npc_dota_hero_batrider",
        "npc_dota_hero_axe",
        "npc_dota_hero_earth_spirit",
        "npc_dota_hero_windrunner",
        "npc_dota_hero_mars",
        "npc_dota_hero_legion_commander",
        "npc_dota_hero_sand_king",
        "npc_dota_hero_disruptor"
    }, counter = {
        "npc_dota_hero_spectre",
        "npc_dota_hero_lone_druid",
        "npc_dota_hero_abaddon",
        "npc_dota_hero_leshrac",
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_shadow_demon",
        "npc_dota_hero_centaur",
        "npc_dota_hero_skeleton_king",
        "npc_dota_hero_primal_beast",
        "npc_dota_hero_death_prophet"
    }},
    npc_dota_hero_ursa = {synergy = {
        "npc_dota_hero_alchemist",
        "npc_dota_hero_mars",
        "npc_dota_hero_primal_beast",
        "npc_dota_hero_earth_spirit",
        "npc_dota_hero_kunkka",
        "npc_dota_hero_oracle",
        "npc_dota_hero_snapfire",
        "npc_dota_hero_phoenix",
        "npc_dota_hero_shredder",
        "npc_dota_hero_leshrac"
    }, counter = {
        "npc_dota_hero_bloodseeker",
        "npc_dota_hero_shredder",
        "npc_dota_hero_pudge",
        "npc_dota_hero_leshrac",
        "npc_dota_hero_tidehunter",
        "npc_dota_hero_juggernaut",
        "npc_dota_hero_lycan",
        "npc_dota_hero_anti-mage",
        "npc_dota_hero_abyssal_underlord",
        "npc_dota_hero_rubick"
    }},
    npc_dota_hero_vengefulspirit = {synergy = {
        "npc_dota_hero_lone_druid",
        "npc_dota_hero_drow_ranger",
        "npc_dota_hero_templar_assassin",
        "npc_dota_hero_muerta",
        "npc_dota_hero_tiny",
        "npc_dota_hero_warlock",
        "npc_dota_hero_meepo",
        "npc_dota_hero_sniper",
        "npc_dota_hero_luna"
    }, counter = {
        "npc_dota_hero_legion_commander",
        "npc_dota_hero_clinkz",
        "npc_dota_hero_bloodseeker",
        "npc_dota_hero_weaver",
        "npc_dota_hero_shredder",
        "npc_dota_hero_furion",
        "npc_dota_hero_skywrath_mage",
        "npc_dota_hero_enchantress",
        "npc_dota_hero_death_prophet"
    }},
    npc_dota_hero_venomancer = {synergy = {
        "npc_dota_hero_pudge",
        "npc_dota_hero_earth_spirit",
        "npc_dota_hero_drow_ranger",
        "npc_dota_hero_ember_spirit",
        "npc_dota_hero_void_spirit",
        "npc_dota_hero_arc_warden",
        "npc_dota_hero_obsidian_destroyer",
        "npc_dota_hero_centaur"
    }, counter = {
        "npc_dota_hero_axe",
        "npc_dota_hero_visage",
        "npc_dota_hero_tiny",
        "npc_dota_hero_kunkka",
        "npc_dota_hero_lone_druid",
        "npc_dota_hero_mars",
        "npc_dota_hero_spirit_breaker",
        "npc_dota_hero_dragon_knight",
        "npc_dota_hero_night_stalker",
        "npc_dota_hero_chaos_knight"
    }},
    npc_dota_hero_viper = {synergy = {
        "npc_dota_hero_faceless_void",
        "npc_dota_hero_naga_siren",
        "npc_dota_hero_omniknight",
        "npc_dota_hero_primal_beast",
        "npc_dota_hero_magnataur",
        "npc_dota_hero_mirana",
        "npc_dota_hero_meepo",
        "npc_dota_hero_dark_seer"
    }, counter = {
        "npc_dota_hero_huskar",
        "npc_dota_hero_bristleback",
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_tiny",
        "npc_dota_hero_dragon_knight",
        "npc_dota_hero_spectre",
        "npc_dota_hero_necrolyte",
        "npc_dota_hero_visage",
        "npc_dota_hero_night_stalker"
    }},
    npc_dota_hero_visage = {synergy = {
        "npc_dota_hero_terrorblade",
        "npc_dota_hero_batrider",
        "npc_dota_hero_luna",
        "npc_dota_hero_shadow_demon",
        "npc_dota_hero_meepo",
        "npc_dota_hero_grimstroke",
        "npc_dota_hero_broodmother",
        "npc_dota_hero_omniknight"
    }, counter = {
        "npc_dota_hero_leshrac",
        "npc_dota_hero_shadow_demon",
        "npc_dota_hero_life_stealer",
        "npc_dota_hero_obsidian_destroyer",
        "npc_dota_hero_night_stalker",
        "npc_dota_hero_oracle",
        "npc_dota_hero_batrider",
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_juggernaut"
    }},
    npc_dota_hero_void_spirit = {synergy = {
        "npc_dota_hero_medusa",
        "npc_dota_hero_keeper_of_the_light",
        "npc_dota_hero_ancient_apparition",
        "npc_dota_hero_snapfire",
        "npc_dota_hero_luna",
        "npc_dota_hero_alchemist",
        "npc_dota_hero_phoenix",
        "npc_dota_hero_jakiro",
        "npc_dota_hero_winter_wyvern"
    }, counter = {
        "npc_dota_hero_ancient_apparition",
        "npc_dota_hero_clinkz",
        "npc_dota_hero_queenofpain",
        "npc_dota_hero_mars",
        "npc_dota_hero_juggernaut",
        "npc_dota_hero_sniper",
        "npc_dota_hero_pudge",
        "npc_dota_hero_invoker",
        "npc_dota_hero_bristleback",
        "npc_dota_hero_phantom_assassin"
    }},
    npc_dota_hero_warlock = {synergy = {
        "npc_dota_hero_bane",
        "npc_dota_hero_riki",
        "npc_dota_hero_spirit_breaker",
        "npc_dota_hero_ogre_magi",
        "npc_dota_hero_enchantress",
        "npc_dota_hero_earth_spirit",
        "npc_dota_hero_shadow_shaman",
        "npc_dota_hero_vengefulspirit",
        "npc_dota_hero_sven",
        "npc_dota_hero_slardar"
    }, counter = {
        "npc_dota_hero_phantom_lancer",
        "npc_dota_hero_meepo",
        "npc_dota_hero_naga_siren",
        "npc_dota_hero_chaos_knight",
        "npc_dota_hero_omniknight",
        "npc_dota_hero_enigma",
        "npc_dota_hero_arc_warden",
        "npc_dota_hero_lone_druid",
        "npc_dota_hero_medusa",
        "npc_dota_hero_beastmaster"
    }},
    npc_dota_hero_weaver = {synergy = {
        "npc_dota_hero_muerta",
        "npc_dota_hero_bloodseeker",
        "npc_dota_hero_luna",
        "npc_dota_hero_visage",
        "npc_dota_hero_spectre",
        "npc_dota_hero_sand_king",
        "npc_dota_hero_shadow_shaman",
        "npc_dota_hero_treant",
        "npc_dota_hero_axe"
    }, counter = {
        "npc_dota_hero_shredder",
        "npc_dota_hero_warlock",
        "npc_dota_hero_ursa",
        "npc_dota_hero_primal_beast",
        "npc_dota_hero_razor",
        "npc_dota_hero_venomancer",
        "npc_dota_hero_lone_druid",
        "npc_dota_hero_dazzle",
        "npc_dota_hero_lycan"
    }},
    npc_dota_hero_windrunner = {synergy = {
        "npc_dota_hero_oracle",
        "npc_dota_hero_lone_druid",
        "npc_dota_hero_abaddon",
        "npc_dota_hero_undying",
        "npc_dota_hero_batrider",
        "npc_dota_hero_warlock",
        "npc_dota_hero_sven",
        "npc_dota_hero_venomancer"
    }, counter = {
        "npc_dota_hero_troll_warlord",
        "npc_dota_hero_lone_druid",
        "npc_dota_hero_huskar",
        "npc_dota_hero_batrider",
        "npc_dota_hero_terrorblade",
        "npc_dota_hero_ursa",
        "npc_dota_hero_night_stalker",
        "npc_dota_hero_leshrac",
        "npc_dota_hero_medusa",
        "npc_dota_hero_venomancer"
    }},
    npc_dota_hero_winter_wyvern = {synergy = {
        "npc_dota_hero_broodmother",
        "npc_dota_hero_meepo",
        "npc_dota_hero_naga_siren",
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_enchantress",
        "npc_dota_hero_undying",
        "npc_dota_hero_arc_warden",
        "npc_dota_hero_night_stalker",
        "npc_dota_hero_batrider",
        "npc_dota_hero_rattletrap"
    }, counter = {
        "npc_dota_hero_meepo",
        "npc_dota_hero_visage",
        "npc_dota_hero_lone_druid",
        "npc_dota_hero_legion_commander",
        "npc_dota_hero_troll_warlord",
        "npc_dota_hero_medusa",
        "npc_dota_hero_dawnbreaker",
        "npc_dota_hero_magnataur",
        "npc_dota_hero_templar_assassin"
    }},
    npc_dota_hero_witch_doctor = {synergy = {
        "npc_dota_hero_meepo",
        "npc_dota_hero_terrorblade",
        "npc_dota_hero_shadow_shaman",
        "npc_dota_hero_naga_siren",
        "npc_dota_hero_spectre",
        "npc_dota_hero_lone_druid",
        "npc_dota_hero_chaos_knight",
        "npc_dota_hero_void_spirit",
        "npc_dota_hero_phantom_lancer",
        "npc_dota_hero_grimstroke"
    }, counter = {
        "npc_dota_hero_dark_seer",
        "npc_dota_hero_axe",
        "npc_dota_hero_undying",
        "npc_dota_hero_lone_druid",
        "npc_dota_hero_bloodseeker",
        "npc_dota_hero_beastmaster",
        "npc_dota_hero_razor",
        "npc_dota_hero_abyssal_underlord",
        "npc_dota_hero_queenofpain",
        "npc_dota_hero_shredder"
    }},
    npc_dota_hero_zuus = {synergy = {
        "npc_dota_hero_legion_commander",
        "npc_dota_hero_spirit_breaker",
        "npc_dota_hero_storm_spirit",
        "npc_dota_hero_void_spirit",
        "npc_dota_hero_juggernaut",
        "npc_dota_hero_riki",
        "npc_dota_hero_witch_doctor"
    }, counter = {
        "npc_dota_hero_nevermore",
        "npc_dota_hero_monkey_king",
        "npc_dota_hero_riki",
        "npc_dota_hero_terrorblade",
        "npc_dota_hero_windrunner",
        "npc_dota_hero_doom_bringer",
        "npc_dota_hero_drow_ranger",
        "npc_dota_hero_naga_siren"
    }},
    npc_dota_hero_ringmaster = {synergy = {
        "npc_dota_hero_skeleton_king",
        "npc_dota_hero_storm_spirit",
        "npc_dota_hero_omniknight",
        "npc_dota_hero_juggernaut",
        "npc_dota_hero_meepo",
        "npc_dota_hero_puck",
        "npc_dota_hero_mars",
        "npc_dota_hero_medusa",
        "npc_dota_hero_legion_commander",
        "npc_dota_hero_sand_king"
    }, counter = {
        "npc_dota_hero_ember_spirit",
        "npc_dota_hero_slark",
        "npc_dota_hero_primal_beast",
        "npc_dota_hero_sven",
        "npc_dota_hero_troll_warlord",
        "npc_dota_hero_dark_seer",
        "npc_dota_hero_phantom_lancer",
        "npc_dota_hero_tiny",
        "npc_dota_hero_axe",
        "npc_dota_hero_leshrac",
        "npc_dota_hero_dragon_knight"
    }}
}
function ____exports.GetHeroMatchups(heroName, ____type)
    local matchups = heroes[heroName]
    if not matchups then
        return {}
    end
    return matchups[____type]
end
function ____exports.IsSynergy(name1, name2)
    return __TS__ArrayIncludes(
        ____exports.GetHeroMatchups(name1, "synergy"),
        name2
    )
end
function ____exports.IsCounter(name1, name2)
    return __TS__ArrayIncludes(
        ____exports.GetHeroMatchups(name1, "counter"),
        name2
    )
end
return ____exports
