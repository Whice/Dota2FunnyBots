X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local Disruption = bot:GetAbilityByName("shadow_demon_disruption")
local Disseminate = bot:GetAbilityByName("shadow_demon_disseminate")
local ShadowPoison = bot:GetAbilityByName("shadow_demon_shadow_poison")
local DemonicPurge = bot:GetAbilityByName("shadow_demon_demonic_purge")
local DemonicCleanse = bot:GetAbilityByName("shadow_demon_demonic_cleanse")

local DisruptionDesire = 0
local DisseminateDesire = 0
local ShadowPoisonDesire = 0
local DemonicPurgeDesire = 0
local DemonicCleanseDesire = 0

local AttackRange
local manathreshold

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, Disruption:GetName())
	table.insert(abilities, Disseminate:GetName())
	table.insert(abilities, ShadowPoison:GetName())
	table.insert(abilities, DemonicPurge:GetName())
	
	local talents = {}
	
	for i = 0, 25 do
		local ability = bot:GetAbilityInSlot(i)
		if ability ~= nil and ability:IsTalent() then
			table.insert(talents, ability:GetName())
		end
	end
	
	local SkillPoints = {
	abilities[3], -- Level 1
	abilities[1], -- Level 2
	abilities[3], -- Level 3
	abilities[2], -- Level 4
	abilities[3], -- Level 5
	abilities[4], -- Level 6
	abilities[3], -- Level 7
	abilities[1], -- Level 8
	abilities[1], -- Level 9
	talents[2],   -- Level 10
	abilities[1], -- Level 11
	abilities[4], -- Level 12
	abilities[2], -- Level 13
	abilities[2], -- Level 14
	talents[4],   -- Level 15
	abilities[2], -- Level 16
	"NoLevel",    -- Level 17
	abilities[4], -- Level 18
	"NoLevel",    -- Level 19
	talents[5],   -- Level 20
	"NoLevel",    -- Level 21
	"NoLevel",    -- Level 22
	"NoLevel",    -- Level 23
	"NoLevel",    -- Level 24
	talents[8],   -- Level 25
	"NoLevel",    -- Level 26
	talents[1],   -- Level 27
	talents[3],   -- Level 28
	talents[6],   -- Level 29
	talents[7]    -- Level 30
	}
	
	return SkillPoints
end

function X.GetHeroItemBuild()
	local ItemBuild

	if PRoles.GetPRole(bot, bot:GetUnitName()) == "SoftSupport" then
		ItemBuild = { 
		--"item_null_talisman",
		"item_magic_wand",
		"item_tranquil_boots",
		
		"item_solar_crest",
		"item_aether_lens",
		"item_force_staff",
		"item_ultimate_scepter",
		"item_blink",
		"item_ultimate_scepter_2",
		"item_octarine_core",
		"item_boots_of_bearing",
		}
	end
	
	if PRoles.GetPRole(bot, bot:GetUnitName()) == "HardSupport" then
		ItemBuild = { 
		--"item_null_talisman",
		"item_magic_wand",
		"item_arcane_boots",
		
		"item_urn_of_shadows",
		"item_aether_lens",
		"item_glimmer_cape",
		"item_spirit_vessel",
		"item_ultimate_scepter",
		"item_blink",
		"item_ultimate_scepter_2",
		"item_octarine_core",
		"item_guardian_greaves",
		}
	end
	
	return ItemBuild
end

return X