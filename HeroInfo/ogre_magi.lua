X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local Fireblast = bot:GetAbilityByName("ogre_magi_fireblast")
local Ignite = bot:GetAbilityByName("ogre_magi_ignite")
local Bloodlust = bot:GetAbilityByName("ogre_magi_bloodlust")
local Multicast = bot:GetAbilityByName("ogre_magi_multicast")
local UnrefinedFireblast = bot:GetAbilityByName("ogre_magi_unrefined_fireblast")
local FireShield = bot:GetAbilityByName("ogre_magi_smash")

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, Fireblast:GetName())
	table.insert(abilities, Ignite:GetName())
	table.insert(abilities, Bloodlust:GetName())
	table.insert(abilities, Multicast:GetName())
	
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
	talents[1],   -- Level 10
	abilities[3], -- Level 11
	abilities[4], -- Level 12
	abilities[1], -- Level 13
	abilities[1], -- Level 14
	talents[4],   -- Level 15
	abilities[4], -- Level 16
	"NoLevel",    -- Level 17
	"NoLevel",    -- Level 18
	"NoLevel",    -- Level 19
	talents[6],   -- Level 20
	"NoLevel",    -- Level 21
	"NoLevel",    -- Level 22
	"NoLevel",    -- Level 23
	"NoLevel",    -- Level 24
	talents[8],   -- Level 25
	"NoLevel",    -- Level 26
	talents[2],   -- Level 27
	talents[3],   -- Level 28
	talents[5],   -- Level 29
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
		
		"item_hand_of_midas",
		SupportUtility,
	}
	
	local LuxuryItems = {
		"item_aether_lens",
		"item_sheepstick",
		"item_octarine_core",
		"item_ultimate_scepter_2",
	}
	
	ItemBuild = PRoles.CreateSupportBuild(bot, CoreItems, LuxuryItems, 3)
	
	return ItemBuild
end

return X