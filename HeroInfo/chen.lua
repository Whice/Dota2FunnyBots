X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local Penitence = bot:GetAbilityByName("chen_penitence")
local HolyPersuasion = bot:GetAbilityByName("chen_holy_persuasion")
local DivineFavor = bot:GetAbilityByName("chen_divine_favor")
local HandOfGod = bot:GetAbilityByName("chen_hand_of_god")

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, Penitence:GetName())
	table.insert(abilities, HolyPersuasion:GetName())
	table.insert(abilities, DivineFavor:GetName())
	table.insert(abilities, HandOfGod:GetName())
	
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
	abilities[2], -- Level 3
	abilities[3], -- Level 4
	abilities[2], -- Level 5
	abilities[4], -- Level 6
	abilities[2], -- Level 7
	abilities[3], -- Level 8
	abilities[3], -- Level 9
	abilities[3], -- Level 10
	talents[2],   -- Level 11
	abilities[4], -- Level 12
	abilities[1], -- Level 13
	abilities[1], -- Level 14
	talents[4],   -- Level 15
	abilities[1], -- Level 16
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
	talents[1],   -- Level 27
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
	
	local AuraItem
	if PRoles.GetPRole(bot, bot:GetUnitName()) == "SoftSupport" then
		AuraItem = "item_ancient_janggo"
	elseif PRoles.GetPRole(bot, bot:GetUnitName()) == "HardSupport" then
		AuraItem = "item_mekansm"
	end
	
	local CoreItems = {
		"item_magic_wand",
		SupportBoots,
		"item_holy_locket",
		
		SupportUtility,
		AuraItem,
	}
	
	local LuxuryItems = {
		"item_aeon_disk",
		"item_ultimate_scepter_2",
	}
	
	ItemBuild = PRoles.CreateSupportBuild(bot, CoreItems, LuxuryItems, 4)
	
	return ItemBuild
end

return X