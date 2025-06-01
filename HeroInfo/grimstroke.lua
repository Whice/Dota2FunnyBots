X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local StrokeOfFate = bot:GetAbilityByName("grimstroke_dark_artistry")
local PhantomsEmbrace = bot:GetAbilityByName("grimstroke_ink_creature")
local InkSwell = bot:GetAbilityByName("grimstroke_spirit_walk")
local Soulbind = bot:GetAbilityByName("grimstroke_soul_chain")

local PhantomReturn = bot:GetAbilityByName("grimstroke_return")

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, StrokeOfFate:GetName())
	table.insert(abilities, PhantomsEmbrace:GetName())
	if InkSwell:IsHidden() then
		table.insert(abilities, PhantomReturn:GetName())
	else
		table.insert(abilities, InkSwell:GetName())
	end
	table.insert(abilities, Soulbind:GetName())
	
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
	talents[6],   -- Level 20
	"NoLevel",    -- Level 21
	"NoLevel",    -- Level 22
	"NoLevel",    -- Level 23
	"NoLevel",    -- Level 24
	talents[7],   -- Level 25
	"NoLevel",    -- Level 26
	talents[1],   -- Level 27
	talents[3],   -- Level 28
	talents[5],   -- Level 29
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
			
		"item_aether_lens",
		SupportUtility,
	}
		
	local LuxuryItems = {
		"item_ultimate_scepter",
		"item_sheepstick",
		"item_aeon_disk",
		"item_ultimate_scepter_2",
	}
		
	ItemBuild = PRoles.CreateSupportBuild(bot, CoreItems, LuxuryItems, 2)
	
	return ItemBuild
end

return X