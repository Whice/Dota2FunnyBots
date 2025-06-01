X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local NaturesGrasp = bot:GetAbilityByName("treant_natures_grasp")
local LeechSeed = bot:GetAbilityByName("treant_leech_seed")
local LivingArmor = bot:GetAbilityByName("treant_living_armor")
local NaturesGuise = bot:GetAbilityByName("treant_natures_guise")
local Overgrowth = bot:GetAbilityByName("treant_overgrowth")

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, NaturesGrasp:GetName())
	table.insert(abilities, LeechSeed:GetName())
	table.insert(abilities, LivingArmor:GetName())
	table.insert(abilities, Overgrowth:GetName())
	
	local talents = {}
	
	for i = 0, 25 do
		local ability = bot:GetAbilityInSlot(i)
		if ability ~= nil and ability:IsTalent() then
			table.insert(talents, ability:GetName())
		end
	end
	
	local SkillPoints = {
	abilities[1], -- Level 1
	abilities[2], -- Level 2
	abilities[3], -- Level 3
	abilities[3], -- Level 4
	abilities[3], -- Level 5
	abilities[4], -- Level 6
	abilities[3], -- Level 7
	abilities[1], -- Level 8
	abilities[1], -- Level 9
	talents[1],   -- Level 10
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
	talents[7],   -- Level 25
	"NoLevel",    -- Level 26
	talents[2],   -- Level 27
	talents[3],   -- Level 28
	talents[6],   -- Level 29
	talents[8]    -- Level 30
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
		"item_holy_locket",
			
		SupportUtility,
		"item_blink",
	}
		
	local LuxuryItems = {
		"item_octarine_core",
		"item_aeon_disk",
		"item_sheepstick",
	}
		
	ItemBuild = PRoles.CreateSupportBuild(bot, CoreItems, LuxuryItems, 3)
	
	return ItemBuild
end

return X