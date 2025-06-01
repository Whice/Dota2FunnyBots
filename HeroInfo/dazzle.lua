X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local PoisonTouch = bot:GetAbilityByName("dazzle_poison_touch")
local ShallowGrave = bot:GetAbilityByName("dazzle_shallow_grave")
local ShadowWave = bot:GetAbilityByName("dazzle_shadow_wave")
local NothlProjection = bot:GetAbilityInSlot(5)

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, PoisonTouch:GetName())
	table.insert(abilities, ShallowGrave:GetName())
	table.insert(abilities, ShadowWave:GetName())
	table.insert(abilities, NothlProjection:GetName())
	
	local talents = {}
	
	for i = 0, 25 do
		local ability = bot:GetAbilityInSlot(i)
		if ability ~= nil and ability:IsTalent() then
			table.insert(talents, ability:GetName())
		end
	end
	
	local SkillPoints = {
	abilities[1], -- Level 1
	abilities[3], -- Level 2
	abilities[1], -- Level 3
	abilities[2], -- Level 4
	abilities[3], -- Level 5
	abilities[4], -- Level 6
	abilities[3], -- Level 7
	abilities[3], -- Level 8
	abilities[2], -- Level 9
	talents[2],   -- Level 10
	abilities[2], -- Level 11
	abilities[4], -- Level 12
	abilities[2], -- Level 13
	abilities[1], -- Level 14
	talents[3],   -- Level 15
	abilities[1], -- Level 16
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
	}
	
	local LuxuryItems = {
		"item_aether_lens",
		"item_ultimate_scepter",
		"item_octarine_core",
		"item_sheepstick",
		"item_ultimate_scepter_2",
	}
	
	ItemBuild = PRoles.CreateSupportBuild(bot, CoreItems, LuxuryItems, 2)
	
	return ItemBuild
end

return X