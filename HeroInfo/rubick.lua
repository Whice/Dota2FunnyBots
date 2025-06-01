X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local Telekinesis = bot:GetAbilityByName("rubick_telekinesis")
local FadeBolt = bot:GetAbilityByName("rubick_fade_bolt")
local ArcaneSupremacy = bot:GetAbilityByName("rubick_arcane_supremacy")
local SpellSteal = bot:GetAbilityByName("rubick_spell_steal")

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, Telekinesis:GetName())
	table.insert(abilities, FadeBolt:GetName())
	table.insert(abilities, ArcaneSupremacy:GetName())
	table.insert(abilities, SpellSteal:GetName())
	
	local talents = {}
	
	for i = 0, 25 do
		local ability = bot:GetAbilityInSlot(i)
		if ability ~= nil and ability:IsTalent() then
			table.insert(talents, ability:GetName())
		end
	end
	
	local SkillPoints = {
	abilities[2], -- Level 1
	abilities[1], -- Level 2
	abilities[2], -- Level 3
	abilities[3], -- Level 4
	abilities[2], -- Level 5
	abilities[4], -- Level 6
	abilities[2], -- Level 7
	abilities[3], -- Level 8
	abilities[3], -- Level 9
	abilities[3], -- Level 10
	abilities[1], -- Level 11
	abilities[4], -- Level 12
	abilities[1], -- Level 13
	abilities[1], -- Level 14
	talents[2],   -- Level 15
	talents[3],   -- Level 16
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
	talents[4],   -- Level 28
	talents[6],   -- Level 29
	talents[7]    -- Level 30
	}
	
	return SkillPoints
end

function X.GetHeroItemBuild()
	local ItemBuild
	
	local SupportBoots = PRoles.GetSupportBoots(bot)
	local SupportUtility = PRoles.GetSupportUtilityItem(bot)
	
	local CoreItems = {
		"item_magic_wand",
		SupportBoots,
		
		SupportUtility,
		"item_aether_lens",
		"item_blink",
	}
	
	local LuxuryItems = {
		"item_ultimate_scepter",
		"item_octarine_core",
		"item_ultimate_scepter_2",
		"item_aeon_disk",
	}
	
	ItemBuild = PRoles.CreateSupportBuild(bot, CoreItems, LuxuryItems, 2)
	
	return ItemBuild
end

return X