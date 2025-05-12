X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local Swarm = bot:GetAbilityByName("weaver_the_swarm")
local Shukuchi = bot:GetAbilityByName("weaver_shukuchi")
local GeminateAttack = bot:GetAbilityByName("weaver_geminate_attack")
local TimeLapse = bot:GetAbilityByName("weaver_time_lapse")

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, Swarm:GetName())
	table.insert(abilities, Shukuchi:GetName())
	table.insert(abilities, GeminateAttack:GetName())
	table.insert(abilities, TimeLapse:GetName())
	
	local talents = {}
	
	for i = 0, 25 do
		local ability = bot:GetAbilityInSlot(i)
		if ability ~= nil and ability:IsTalent() then
			table.insert(talents, ability:GetName())
		end
	end
	
	local SkillPoints = {
	abilities[2], -- Level 1
	abilities[3], -- Level 2
	abilities[2], -- Level 3
	abilities[1], -- Level 4
	abilities[2], -- Level 5
	abilities[4], -- Level 6
	abilities[2], -- Level 7
	abilities[3], -- Level 8
	abilities[3], -- Level 9
	talents[2],   -- Level 10
	abilities[3], -- Level 11
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

	if PRoles.GetPRole(bot, bot:GetUnitName()) == "SafeLane" then
		local SituationalItem1 = PRoles.ShouldBuyMKB("item_butterfly")
		
		ItemBuild = { 
		"item_quelling_blade",
	
		"item_null_talisman",
		"item_magic_wand",
		"item_power_treads",
		
		"item_mjollnir",
		"item_aghanims_shard",
		"item_desolator",
		"item_satanic",
		"item_butterfly",
		"item_greater_crit",
		
		"item_skadi",
		SituationalItem1,
		}
	end
	
	return ItemBuild
end

return X