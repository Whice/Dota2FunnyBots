local PRoles = {}

PRoles["Positions"] = {}

PRoles["SafeLane"] = {
	"npc_dota_hero_nevermore",
	"npc_dota_hero_sven",
	"npc_dota_hero_chaos_knight",
	"npc_dota_hero_bloodseeker",
	"npc_dota_hero_skeleton_king",
	"npc_dota_hero_antimage",
	"npc_dota_hero_juggernaut",
	"npc_dota_hero_terrorblade",
	"npc_dota_hero_phantom_assassin",
	"npc_dota_hero_luna",
	"npc_dota_hero_phantom_lancer",
	"npc_dota_hero_life_stealer",
	"npc_dota_hero_naga_siren",
	"npc_dota_hero_meepo",
	"npc_dota_hero_medusa",
	"npc_dota_hero_ursa",
	"npc_dota_hero_faceless_void",
	"npc_dota_hero_slark",
	"npc_dota_hero_spectre",
	"npc_dota_hero_razor",
	"npc_dota_hero_alchemist",
	"npc_dota_hero_sniper",
	"npc_dota_hero_templar_assassin",
	"npc_dota_hero_troll_warlord",
	"npc_dota_hero_zuus",
	"npc_dota_hero_riki",
	"npc_dota_hero_lina",
	"npc_dota_hero_weaver",
	"npc_dota_hero_gyrocopter",
	"npc_dota_hero_drow_ranger",
	"npc_dota_hero_dragon_knight",
	"npc_dota_hero_lycan",
	"npc_dota_hero_arc_warden",
	"npc_dota_hero_furion",
	"npc_dota_hero_tiny",
	"npc_dota_hero_pudge",
}

PRoles["MidLane"] = {
	"npc_dota_hero_nevermore",
	"npc_dota_hero_sniper",
	"npc_dota_hero_viper",
	"npc_dota_hero_templar_assassin",
	"npc_dota_hero_huskar",
	"npc_dota_hero_storm_spirit",
	"npc_dota_hero_obsidian_destroyer",
	"npc_dota_hero_riki",
	"npc_dota_hero_lina",
	"npc_dota_hero_queenofpain",
	"npc_dota_hero_death_prophet",
	"npc_dota_hero_pugna",
	"npc_dota_hero_meepo",
	"npc_dota_hero_arc_warden",
	"npc_dota_hero_batrider",
	"npc_dota_hero_tiny",
	"npc_dota_hero_necrolyte",
	"npc_dota_hero_broodmother",
	--"npc_dota_hero_visage",
	"npc_dota_hero_razor",
	"npc_dota_hero_invoker",
	"npc_dota_hero_kunkka",
	"npc_dota_hero_pudge",
	"npc_dota_hero_zuus",
	"npc_dota_hero_leshrac",
	"npc_dota_hero_magnataur",
	"npc_dota_hero_earthshaker",
	"npc_dota_hero_bounty_hunter",
}

PRoles["OffLane"] = {
	"npc_dota_hero_chaos_knight",
	"npc_dota_hero_bloodseeker",
	"npc_dota_hero_viper",
	"npc_dota_hero_bristleback",
	"npc_dota_hero_night_stalker",
	"npc_dota_hero_razor",
	"npc_dota_hero_axe",
	"npc_dota_hero_legion_commander",
	"npc_dota_hero_slardar",
	"npc_dota_hero_tidehunter",
	"npc_dota_hero_dragon_knight",
	"npc_dota_hero_death_prophet",
	"npc_dota_hero_enigma",
	"npc_dota_hero_pudge",
	"npc_dota_hero_brewmaster",
	"npc_dota_hero_mars",
	"npc_dota_hero_batrider",
	"npc_dota_hero_sand_king",
	"npc_dota_hero_centaur",
	"npc_dota_hero_necrolyte",
	"npc_dota_hero_broodmother",
	"npc_dota_hero_lycan",
	--"npc_dota_hero_visage",
	"npc_dota_hero_bounty_hunter",
	"npc_dota_hero_beastmaster",
	"npc_dota_hero_skeleton_king",
	"npc_dota_hero_kunkka",
	"npc_dota_hero_shredder",
	"npc_dota_hero_magnataur",
	"npc_dota_hero_dark_seer",
	"npc_dota_hero_earthshaker",
	"npc_dota_hero_doom_bringer",
	"npc_dota_hero_dawnbreaker",
}

PRoles["SoftSupport"] = {
	"npc_dota_hero_skywrath_mage",
	"npc_dota_hero_silencer",
	"npc_dota_hero_shadow_shaman",
	"npc_dota_hero_grimstroke",
	"npc_dota_hero_venomancer",
	"npc_dota_hero_treant",
	"npc_dota_hero_witch_doctor",
	"npc_dota_hero_nyx_assassin",
	"npc_dota_hero_shadow_demon",
	"npc_dota_hero_oracle",
	"npc_dota_hero_tusk",
	"npc_dota_hero_winter_wyvern",
	"npc_dota_hero_disruptor",
	"npc_dota_hero_ringmaster",
	--"npc_dota_hero_dazzle",
	"npc_dota_hero_rattletrap",
	"npc_dota_hero_vengefulspirit",
	"npc_dota_hero_tinker",
	"npc_dota_hero_jakiro",
	"npc_dota_hero_lion",
	"npc_dota_hero_ogre_magi",
	"npc_dota_hero_mirana",
	"npc_dota_hero_enchantress",
	"npc_dota_hero_chen",
	"npc_dota_hero_rubick",
	"npc_dota_hero_windrunner",
	"npc_dota_hero_pudge",
	"npc_dota_hero_bristleback",
}

PRoles["HardSupport"] = {
	"npc_dota_hero_skywrath_mage",
	"npc_dota_hero_warlock",
	"npc_dota_hero_silencer",
	"npc_dota_hero_shadow_shaman",
	"npc_dota_hero_grimstroke",
	"npc_dota_hero_jakiro",
	"npc_dota_hero_treant",
	"npc_dota_hero_abaddon",
	"npc_dota_hero_lich",
	"npc_dota_hero_omniknight",
	"npc_dota_hero_bane",
	"npc_dota_hero_crystal_maiden",
	"npc_dota_hero_ancient_apparition",
	"npc_dota_hero_lion",
	"npc_dota_hero_undying",
	"npc_dota_hero_witch_doctor",
	"npc_dota_hero_shadow_demon",
	"npc_dota_hero_oracle",
	"npc_dota_hero_winter_wyvern",
	"npc_dota_hero_disruptor",
	"npc_dota_hero_ringmaster",
	--"npc_dota_hero_dazzle",
	"npc_dota_hero_rattletrap",
	"npc_dota_hero_vengefulspirit",
	"npc_dota_hero_tinker",
	"npc_dota_hero_ogre_magi",
	"npc_dota_hero_mirana",
	"npc_dota_hero_enchantress",
	"npc_dota_hero_chen",
	"npc_dota_hero_rubick",
	"npc_dota_hero_windrunner",
	"npc_dota_hero_pudge",
	"npc_dota_hero_bristleback",
}

-------------------------------------------------------------------------------------------

PRoles["invisHeroes"] = {
	["npc_dota_hero_templar_assassin"] = 1,
	["npc_dota_hero_clinkz"] = 1,
	["npc_dota_hero_mirana"] = 1,
	["npc_dota_hero_riki"] = 1,
	["npc_dota_hero_nyx_assassin"] = 1,
	["npc_dota_hero_bounty_hunter"] = 1,
	["npc_dota_hero_invoker"] = 1,
	["npc_dota_hero_sand_king"] = 1,
	["npc_dota_hero_treant"] = 1,
	["npc_dota_hero_broodmother"] = 1,
	["npc_dota_hero_weaver"] = 1
} 

PRoles["SummonHeroes"] = {
	"npc_dota_hero_chaos_knight",
	"npc_dota_hero_naga_siren",
	"npc_dota_hero_phantom_lancer",
	"npc_dota_hero_terrorblade",
	"npc_dota_hero_broodmother",
	"npc_dota_hero_meepo",
	"npc_dota_hero_enigma",
	"npc_dota_hero_lycan",
	"npc_dota_hero_visage",
}

PRoles["SphereHeroes"] = {
	"npc_dota_hero_bloodseeker",
	"npc_dota_hero_legion_commander",
	"npc_dota_hero_necrolyte",
	"npc_dota_hero_doom_bringer",
}

PRoles["StrongPassiveHeroes"] = {
	"npc_dota_hero_phantom_assassin",
	"npc_dota_hero_ursa",
	"npc_dota_hero_bristleback",
	"npc_dota_hero_spectre",
	"npc_dota_hero_enchantress",
	"npc_dota_hero_huskar",
	"npc_dota_hero_lina",
	"npc_dota_hero_troll_warlord",
	"npc_dota_hero_shredder",
	"npc_dota_hero_tidehunter",
}

PRoles["EvasionArmorHeroes"] = {
	"npc_dota_hero_phantom_assassin",
	"npc_dota_hero_windrunner",
	"npc_dota_hero_riki",
	"npc_dota_hero_alchemist",
	"npc_dota_hero_brewmaster",
	"npc_dota_hero_terrorblade",
	"npc_dota_hero_dragon_knight",
	"npc_dota_hero_primal_beast",
}

PRoles["SolarCrestHeroes"] = {
	"npc_dota_hero_alchemist",
    "npc_dota_hero_bloodseeker",
    "npc_dota_hero_broodmother",
    "npc_dota_hero_chaos_knight",
    "npc_dota_hero_clinkz",
    "npc_dota_hero_drow_ranger",
    "npc_dota_hero_faceless_void",
    "npc_dota_hero_gyrocopter",
    "npc_dota_hero_huskar",
    "npc_dota_hero_juggernaut",
    "npc_dota_hero_legion_commander",
    "npc_dota_hero_lone_druid",
    "npc_dota_hero_lycan",
    "npc_dota_hero_monkey_king",
    "npc_dota_hero_naga_siren",
    "npc_dota_hero_phantom_assassin",
    "npc_dota_hero_phantom_lancer",
    "npc_dota_hero_riki",
    "npc_dota_hero_slardar",
    "npc_dota_hero_slark",
    "npc_dota_hero_sniper",
    "npc_dota_hero_sven",
    "npc_dota_hero_templar_assassin",
    "npc_dota_hero_terrorblade",
    "npc_dota_hero_troll_warlord",
    "npc_dota_hero_ursa",
    "npc_dota_hero_weaver",
    "npc_dota_hero_windrunner",
    "npc_dota_hero_skeleton_king",
}

PRoles["SpiritVesselHeroes"] = {
	"npc_dota_hero_abaddon",
    "npc_dota_hero_alchemist",
    "npc_dota_hero_wisp",
    "npc_dota_hero_dazzle",
    "npc_dota_hero_huskar",
    "npc_dota_hero_omniknight",
    "npc_dota_hero_oracle",
    "npc_dota_hero_phoenix",
    "npc_dota_hero_pugna",
    "npc_dota_hero_juggernaut",
    "npc_dota_hero_legion_commander",
    "npc_dota_hero_morphling",
    "npc_dota_hero_necrolyte",
    "npc_dota_hero_undying",
    "npc_dota_hero_warlock",
    "npc_dota_hero_bristleback",
    "npc_dota_hero_timbersaw",
    "npc_dota_hero_slark",
    "npc_dota_hero_pudge",
}

PRoles["GhostHeroes"] = {
	"npc_dota_hero_phantom_assassin",
    "npc_dota_hero_ursa",
    "npc_dota_hero_troll_warlord",
    "npc_dota_hero_juggernaut",
    "npc_dota_hero_sven",
    "npc_dota_hero_templar_assassin",
    "npc_dota_hero_clinkz",
    "npc_dota_hero_drow_ranger",
    "npc_dota_hero_sniper",
    "npc_dota_hero_monkey_king",
    "npc_dota_hero_legion_commander",
    "npc_dota_hero_skeleton_king",
    "npc_dota_hero_chaos_knight",
    "npc_dota_hero_life_stealer",
    "npc_dota_hero_bloodseeker",
    "npc_dota_hero_slark",
    "npc_dota_hero_weaver",
    "npc_dota_hero_phantom_lancer",
    "npc_dota_hero_terrorblade",
    "npc_dota_hero_naga_siren",
    "npc_dota_hero_riki",
    "npc_dota_hero_broodmother",
    "npc_dota_hero_lycan",
    "npc_dota_hero_lone_druid",
}

PRoles["LotusOrbHeroes"] = {
	"npc_dota_hero_bane",
    "npc_dota_hero_beastmaster",
    "npc_dota_hero_batrider",
    "npc_dota_hero_bloodseeker",
    "npc_dota_hero_doom_bringer",
    "npc_dota_hero_legion_commander",
    "npc_dota_hero_lion",
    "npc_dota_hero_lina",
    "npc_dota_hero_necrolyte",
    "npc_dota_hero_pudge",
    "npc_dota_hero_riki",
    "npc_dota_hero_rubick",
    "npc_dota_hero_shadow_shaman",
    "npc_dota_hero_vengefulspirit",
    "npc_dota_hero_winter_wyvern",
}

PRoles["VladmirHeroes"] = {
    "npc_dota_hero_alchemist",
    "npc_dota_hero_anti_mage",
    "npc_dota_hero_arc_warden",
    "npc_dota_hero_beastmaster",
    "npc_dota_hero_bloodseeker",
    "npc_dota_hero_broodmother",
    "npc_dota_hero_chaos_knight",
    "npc_dota_hero_clinkz",
    "npc_dota_hero_dragon_knight",
    "npc_dota_hero_drow_ranger",
    "npc_dota_hero_ember_spirit",
    "npc_dota_hero_faceless_void",
    "npc_dota_hero_furion",
    "npc_dota_hero_gyrocopter",
    "npc_dota_hero_huskar",
    "npc_dota_hero_juggernaut",
    "npc_dota_hero_legion_commander",
    "npc_dota_hero_life_stealer",
    "npc_dota_hero_lone_druid",
    "npc_dota_hero_luna",
    "npc_dota_hero_lycan",
    "npc_dota_hero_meepo",
    "npc_dota_hero_monkey_king",
    "npc_dota_hero_morphling",
    "npc_dota_hero_naga_siren",
    "npc_dota_hero_pangolier",
    "npc_dota_hero_phantom_assassin",
    "npc_dota_hero_phantom_lancer",
    "npc_dota_hero_riki",
    "npc_dota_hero_nevermore",
    "npc_dota_hero_slardar",
    "npc_dota_hero_slark",
    "npc_dota_hero_sniper",
    "npc_dota_hero_spectre",
    "npc_dota_hero_sven",
    "npc_dota_hero_templar_assassin",
    "npc_dota_hero_terrorblade",
    "npc_dota_hero_tiny",
    "npc_dota_hero_troll_warlord",
    "npc_dota_hero_ursa",
    "npc_dota_hero_visage",
    "npc_dota_hero_weaver",
    "npc_dota_hero_windrunner",
    "npc_dota_hero_skeleton_king",
}

------------------------------------------------
-- GETPRIMARYATTRIBUTE() NOT WORKING PROPERLY --
------------------------------------------------

PRoles["StrengthHeroes"] = {
    "npc_dota_hero_alchemist",
    "npc_dota_hero_axe",
    "npc_dota_hero_bristleback",
    "npc_dota_hero_centaur",
    "npc_dota_hero_chaos_knight",
    "npc_dota_hero_rattletrap",
    "npc_dota_hero_dawnbreaker",
    "npc_dota_hero_doom_bringer",
    "npc_dota_hero_dragon_knight",
    "npc_dota_hero_earth_spirit",
    "npc_dota_hero_earthshaker",
    "npc_dota_hero_elder_titan",
    "npc_dota_hero_huskar",
    "npc_dota_hero_kunkka",
    "npc_dota_hero_legion_commander",
    "npc_dota_hero_life_stealer",
    "npc_dota_hero_lycan",
    "npc_dota_hero_mars",
    "npc_dota_hero_night_stalker",
    "npc_dota_hero_ogre_magi",
    "npc_dota_hero_omniknight",
    "npc_dota_hero_phoenix",
    "npc_dota_hero_primal_beast",
    "npc_dota_hero_pudge",
    "npc_dota_hero_slardar",
    "npc_dota_hero_spirit_breaker",
    "npc_dota_hero_sven",
    "npc_dota_hero_tidehunter",
    "npc_dota_hero_shredder",
    "npc_dota_hero_tiny",
    "npc_dota_hero_treant",
    "npc_dota_hero_tusk",
    "npc_dota_hero_underlord",
    "npc_dota_hero_undying",
    "npc_dota_hero_skeleton_king",
}

PRoles["AgilityHeroes"] = {
    "npc_dota_hero_antimage",
	"npc_dota_hero_bloodseeker",
	"npc_dota_hero_bounty_hunter",
	"npc_dota_hero_broodmother",
	"npc_dota_hero_clinkz",
	"npc_dota_hero_drow_ranger",
	"npc_dota_hero_ember_spirit",
	"npc_dota_hero_faceless_void",
	"npc_dota_hero_gyrocopter",
	"npc_dota_hero_hoodwink",
	"npc_dota_hero_juggernaut",
	"npc_dota_hero_kez",
	"npc_dota_hero_lone_druid",
	"npc_dota_hero_luna",
	"npc_dota_hero_medusa",
	"npc_dota_hero_meepo",
	"npc_dota_hero_mirana",
	"npc_dota_hero_monkey_king",
	"npc_dota_hero_morphling",
	"npc_dota_hero_naga_siren",
	"npc_dota_hero_phantom_assassin",
	"npc_dota_hero_phantom_lancer",
	"npc_dota_hero_razor",
	"npc_dota_hero_riki",
	"npc_dota_hero_nevermore",
	"npc_dota_hero_slark",
	"npc_dota_hero_sniper",
	"npc_dota_hero_templar_assassin",
	"npc_dota_hero_terrorblade",
	"npc_dota_hero_troll_warlord",
	"npc_dota_hero_ursa",
	"npc_dota_hero_vengefulspirit",
	"npc_dota_hero_viper",
	"npc_dota_hero_weaver",
}

PRoles["IntelligenceHeroes"] = {
    "npc_dota_hero_ancient_apparition",
	"npc_dota_hero_chen",
	"npc_dota_hero_crystal_maiden",
	"npc_dota_hero_dark_seer",
	"npc_dota_hero_dark_willow",
	"npc_dota_hero_disruptor",
	"npc_dota_hero_enchantress",
	"npc_dota_hero_grimstroke",
	"npc_dota_hero_invoker",
	"npc_dota_hero_jakiro",
	"npc_dota_hero_keeper_of_the_light",
	"npc_dota_hero_leshrac",
	"npc_dota_hero_lich",
	"npc_dota_hero_lina",
	"npc_dota_hero_lion",
	"npc_dota_hero_muerta",
	"npc_dota_hero_necrolyte",
	"npc_dota_hero_oracle",
	"npc_dota_hero_obsidian_destroyer",
	"npc_dota_hero_puck",
	"npc_dota_hero_pugna",
	"npc_dota_hero_queenofpain",
	"npc_dota_hero_ringmaster",
	"npc_dota_hero_rubick",
	"npc_dota_hero_shadow_demon",
	"npc_dota_hero_shadow_shaman",
	"npc_dota_hero_silencer",
	"npc_dota_hero_skywrath_mage",
	"npc_dota_hero_storm_spirit",
	"npc_dota_hero_tinker",
	"npc_dota_hero_warlock",
	"npc_dota_hero_winter_wyvern",
	"npc_dota_hero_witch_doctor",
	"npc_dota_hero_zuus",
}

PRoles["UniversalHeroes"] = {
    "npc_dota_hero_abaddon",
	"npc_dota_hero_arc_warden",
	"npc_dota_hero_bane",
	"npc_dota_hero_batrider",
	"npc_dota_hero_beastmaster",
	"npc_dota_hero_brewmaster",
	"npc_dota_hero_dazzle",
	"npc_dota_hero_death_prophet",
	"npc_dota_hero_enigma",
	"npc_dota_hero_wisp",
	"npc_dota_hero_magnataur",
	"npc_dota_hero_marci",
	"npc_dota_hero_furion",
	"npc_dota_hero_nyx_assassin",
	"npc_dota_hero_pangolier",
	"npc_dota_hero_sand_king",
	"npc_dota_hero_snapfire",
	"npc_dota_hero_spectre",
	"npc_dota_hero_techies",
	"npc_dota_hero_venomancer",
	"npc_dota_hero_visage",
	"npc_dota_hero_void_spirit",
	"npc_dota_hero_windrunner",
	
}

function PRoles.GetActualPrimaryAttribute(hUnit)
	local sUnitName = hUnit:GetUnitName()
	
	for i = 1, #PRoles["StrengthHeroes"] do
		if PRoles['StrengthHeroes'][i] == sUnitName then
			return 0
		end	
	end
	
	for i = 1, #PRoles["AgilityHeroes"] do
		if PRoles['AgilityHeroes'][i] == sUnitName then
			return 2
		end	
	end
	
	for i = 1, #PRoles["IntelligenceHeroes"] do
		if PRoles['IntelligenceHeroes'][i] == sUnitName then
			return 1
		end	
	end
	
	for i = 1, #PRoles["UniversalHeroes"] do
		if PRoles['UniversalHeroes'][i] == sUnitName then
			return 3
		end	
	end
	
	print("Couldn't find "..sUnitName.." under any attribute table!")
	return 2
end

function PRoles.GetPRole(bot, hero)
	return PRoles["Positions"][hero]
end

--[[function PRoles.GetPRole(bot, hero)
	for i = 1, #PRoles["SafeLane"] do
		if PRoles['SafeLane'][i] == hero then
			if bot:GetTeam() == TEAM_RADIANT and bot:GetAssignedLane() == LANE_BOT then
				return "SafeLane"
			elseif bot:GetTeam() == TEAM_DIRE and bot:GetAssignedLane() == LANE_TOP then
				return "SafeLane"
			end
		end	
	end
	
	for i = 1, #PRoles["MidLane"] do
		if PRoles['MidLane'][i] == hero and bot:GetAssignedLane() == LANE_MID then
			return "MidLane"
		end	
	end
	
	for i = 1, #PRoles["OffLane"] do
		if PRoles['OffLane'][i] == hero then
			if bot:GetTeam() == TEAM_RADIANT and bot:GetAssignedLane() == LANE_TOP then
				return "OffLane"
			elseif bot:GetTeam() == TEAM_DIRE and bot:GetAssignedLane() == LANE_BOT then
				return "OffLane"
			end
		end
	end
	
	for i = 1, #PRoles["SoftSupport"] do
		if PRoles['SoftSupport'][i] == hero then
			if bot:GetTeam() == TEAM_RADIANT and bot:GetAssignedLane() == LANE_TOP then
				return "SoftSupport"
			elseif bot:GetTeam() == TEAM_DIRE and bot:GetAssignedLane() == LANE_BOT then
				return "SoftSupport"
			end
		end
	end
	
	for i = 1, #PRoles['HardSupport'] do
		if PRoles['HardSupport'][i] == hero then
			if bot:GetTeam() == TEAM_RADIANT and bot:GetAssignedLane() == LANE_BOT then
				return "HardSupport"
			elseif bot:GetTeam() == TEAM_DIRE and bot:GetAssignedLane() == LANE_TOP then
				return "HardSupport"
			end
		end
	end
end]]--

function PRoles.IsCoreHero(bot)
	if PRoles.GetPRole(bot, bot:GetUnitName()) == "MidLane"
	or PRoles.GetPRole(bot, bot:GetUnitName()) == "OffLane"
	or PRoles.GetPRole(bot, bot:GetUnitName()) == "SafeLane" then
		return true
	end
	
	return false
end

function PRoles.IsSupportHero(bot)
	if PRoles.GetPRole(bot, bot:GetUnitName()) == "SoftSupport"
	or PRoles.GetPRole(bot, bot:GetUnitName()) == "HardSupport" then
		return true
	end
	
	return false
end

function PRoles.GetAOEItem()
	local EnemyPlayers = GetTeamPlayers(GetOpposingTeam())
	
	for v, Hero in pairs(EnemyPlayers) do
		local EnemyName = GetSelectedHeroName(Hero)
		
		for x, SummonHero in pairs(PRoles["SummonHeroes"]) do
			if EnemyName == SummonHero then
				return "item_crimson_guard"
			end
		end
	end
	
	return "item_pipe"
end

function PRoles.GetSupportBoots(bot)
	if PRoles.GetPRole(bot, bot:GetUnitName()) == "SoftSupport" then
		return "item_tranquil_boots"
	end
	
	if PRoles.GetPRole(bot, bot:GetUnitName()) == "HardSupport" then
		return "item_arcane_boots"
	end
end

function PRoles.GetSupportUtilityItem(bot)
	if PRoles.GetPRole(bot, bot:GetUnitName()) == "SoftSupport" then
		return "item_force_staff"
	end
	
	if PRoles.GetPRole(bot, bot:GetUnitName()) == "HardSupport" then
		return "item_glimmer_cape"
	end
end

function PRoles.ShouldBuySphere(FirstChoice)
	local EnemyPlayers = GetTeamPlayers(GetOpposingTeam())
	
	for v, Hero in pairs(EnemyPlayers) do
		local EnemyName = GetSelectedHeroName(Hero)
		
		for x, SummonHero in pairs(PRoles["SphereHeroes"]) do
			if EnemyName == SummonHero then
				return "item_sphere"
			end
		end
	end
	
	return FirstChoice
end

function PRoles.ShouldBuySilverEdge(FirstChoice)
	local EnemyPlayers = GetTeamPlayers(GetOpposingTeam())
	
	for v, Hero in pairs(EnemyPlayers) do
		local EnemyName = GetSelectedHeroName(Hero)
		
		for x, SummonHero in pairs(PRoles["StrongPassiveHeroes"]) do
			if EnemyName == SummonHero then
				return "item_silver_edge"
			end
		end
	end
	
	return FirstChoice
end

function PRoles.ShouldBuyMKB(FirstChoice)
	local EnemyPlayers = GetTeamPlayers(GetOpposingTeam())
	
	for v, Hero in pairs(EnemyPlayers) do
		local EnemyName = GetSelectedHeroName(Hero)
		
		for x, SummonHero in pairs(PRoles["EvasionArmorHeroes"]) do
			if EnemyName == SummonHero then
				return "item_monkey_king_bar"
			end
		end
	end
	
	return FirstChoice
end

function PRoles.CreateSupportBuild(bot, CoreItems, LuxuryItems, NumItemsToIgnore)
	local FullBuild = CoreItems
	
	local AvailableSlots = (4 - (#FullBuild - NumItemsToIgnore))
	local SlotsTaken = 0
	
	-- Tinker buys boots immediately
	if bot:GetUnitName() == "npc_dota_hero_tinker" then
		if PRoles.GetPRole(bot, bot:GetUnitName()) == "SoftSupport" then
			table.insert(FullBuild, "item_boots_of_bearing")
		end
		
		-- Hard Support buys Arcane Boots into Guardian Greaves
		if PRoles.GetPRole(bot, bot:GetUnitName()) == "HardSupport" then
			table.insert(FullBuild, "item_guardian_greaves")
		end
	end
	
	-- Should support buy Ghost Scepter?
	if SlotsTaken < AvailableSlots then
		local EnemyPlayers = GetTeamPlayers(GetOpposingTeam())
	
		for v, Hero in pairs(EnemyPlayers) do
			local EnemyName = GetSelectedHeroName(Hero)
			
			for x, GhostHero in pairs(PRoles["GhostHeroes"]) do
				if EnemyName == GhostHero then
					table.insert(FullBuild, "item_ghost")
					SlotsTaken = (SlotsTaken + 1)
				end
			end
		end
	end
	
	-- Should Soft Support buy Solar Crest?
	if PRoles.GetPRole(bot, bot:GetUnitName()) == "SoftSupport" then
		if SlotsTaken < AvailableSlots then
			local EnemyPlayers = GetTeamPlayers(GetOpposingTeam())
			local NumBeneficiaryHeroes = 0
		
			for v, Hero in pairs(EnemyPlayers) do
				if NumBeneficiaryHeroes >= 2 then
					break
				end
				
				local EnemyName = GetSelectedHeroName(Hero)
				
				for x, SolarCrestHero in pairs(PRoles["SolarCrestHeroes"]) do
					if EnemyName == SolarCrestHero then
						NumBeneficiaryHeroes = (NumBeneficiaryHeroes + 1)
						break
					end
				end
			end
			
			if NumBeneficiaryHeroes >= 2 then
				table.insert(FullBuild, "item_solar_crest")
				SlotsTaken = (SlotsTaken + 1)
			end
		end
	end
	
	-- Should Soft Support buy Lotus Orb?
	if PRoles.GetPRole(bot, bot:GetUnitName()) == "SoftSupport" then
		if SlotsTaken < AvailableSlots then
			local EnemyPlayers = GetTeamPlayers(GetOpposingTeam())
		
			for v, Hero in pairs(EnemyPlayers) do
				local EnemyName = GetSelectedHeroName(Hero)
				
				for x, LotusOrbHero in pairs(PRoles["LotusOrbHeroes"]) do
					if EnemyName == LotusOrbHero then
						table.insert(FullBuild, "item_lotus_orb")
						SlotsTaken = (SlotsTaken + 1)
					end
				end
			end
		end
	end
	
	-- Should Hard Support buy Spirit Vessel?
	if PRoles.GetPRole(bot, bot:GetUnitName()) == "HardSupport" then
		if SlotsTaken < AvailableSlots then
			local EnemyPlayers = GetTeamPlayers(GetOpposingTeam())
		
			for v, Hero in pairs(EnemyPlayers) do
				local EnemyName = GetSelectedHeroName(Hero)
				
				for x, SpiritVesselHero in pairs(PRoles["SpiritVesselHeroes"]) do
					if EnemyName == SpiritVesselHero then
						table.insert(FullBuild, "item_spirit_vessel")
						SlotsTaken = (SlotsTaken + 1)
					end
				end
			end
		end
	end
	
	-- Should Hard Support buy Vladmir's Offering?
	if PRoles.GetPRole(bot, bot:GetUnitName()) == "HardSupport" then
		if SlotsTaken < AvailableSlots then
			local AllyPlayers = GetTeamPlayers(bot:GetTeam())
			local NumBeneficiaryHeroes = 0
		
			for v, Hero in pairs(AllyPlayers) do
				local AllyName = GetSelectedHeroName(Hero)
				
				for x, VladmirHero in pairs(PRoles["VladmirHeroes"]) do
					if AllyName == VladmirHero then
						NumBeneficiaryHeroes = (NumBeneficiaryHeroes + 1)
					end
				end
			end
			
			if NumBeneficiaryHeroes >= 2 then
				table.insert(FullBuild, "item_vladmir")
				SlotsTaken = (SlotsTaken + 1)
			end
		end
	end
	
	for v, LuxuryItem in pairs(LuxuryItems) do
		if LuxuryItem == "item_ultimate_scepter"
		or LuxuryItem == "item_ultimate_scepter_2"
		or LuxuryItem == "item_overwhelming_blink"
		or LuxuryItem == "item_swift_blink"
		or LuxuryItem == "item_arcane_blink" then
			table.insert(FullBuild, LuxuryItem)
		else
			if SlotsTaken < AvailableSlots then
				table.insert(FullBuild, LuxuryItem)
				SlotsTaken = (SlotsTaken + 1)
			else
				break
			end
		end
	end
	
	-- Tinker already bought boots
	if bot:GetUnitName() ~= "npc_dota_hero_tinker" then
		-- Soft Support buys Tranquil Boots into Boots of Bearing
		if PRoles.GetPRole(bot, bot:GetUnitName()) == "SoftSupport" then
			table.insert(FullBuild, "item_boots_of_bearing")
		end
		
		-- Hard Support buys Arcane Boots into Guardian Greaves
		if PRoles.GetPRole(bot, bot:GetUnitName()) == "HardSupport" then
			table.insert(FullBuild, "item_guardian_greaves")
		end
	end
	
	return FullBuild
end

PRoles['invisEnemyExist'] = false;
local globalEnemyCheck = false;
local lastCheck = -90;

function PRoles.UpdateInvisEnemyStatus(bot)
	if globalEnemyCheck == false then
		local players = GetTeamPlayers(GetOpposingTeam());
		for i=1,#players do
			if PRoles["invisHeroes"][GetSelectedHeroName(players[i])] == 1 
			then
				PRoles['invisEnemyExist'] = true;
				break;
			end
		end
		globalEnemyCheck = true;	
	elseif globalEnemyCheck == true and DotaTime() > 10*60 and DotaTime() > lastCheck + 3.0 then
		local enemies = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
		if #enemies > 0 then
			for i=1,#enemies
			do
				if enemies[i] ~= nil and enemies[i]:IsNull() == false and enemies[i]:CanBeSeen() == true then
					local SASlot = enemies[i]:FindItemSlot("item_shadow_amulet");
					local GCSlot = enemies[i]:FindItemSlot("item_glimmer_cape");
					local ISSlot = enemies[i]:FindItemSlot("item_invis_sword");
					local SESlot = enemies[i]:FindItemSlot("item_silver_edge");
					if  SASlot >= 0 or GCSlot >= 0 or ISSlot >= 0 or SESlot >= 0 
					then
						PRoles['invisEnemyExist'] = true;
						break;
					end	
				end
			end
		end
		lastCheck = DotaTime();
	end	
end

function PRoles.IsTheLowestLevel(bot)
	local lowestLevel = 31;
	local lowestID = -1;
	local players = GetTeamPlayers(GetTeam());
	for i=1,#players do
		if GetHeroLevel(players[i]) < lowestLevel then
			lowestLevel = GetHeroLevel(players[i]);
			lowestID = players[i];
		end
	end
	return bot:GetPlayerID() == lowestID;
end

PRoles["lastbbtime"] = -90

return PRoles