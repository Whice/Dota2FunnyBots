X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local TimeWalk = bot:GetAbilityByName("faceless_void_time_walk")
local TimeDilation = bot:GetAbilityByName("faceless_void_time_dilation")
local TimeLock = bot:GetAbilityByName("faceless_void_time_lock")
local Chronosphere = bot:GetAbilityByName("faceless_void_chronosphere")

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, TimeWalk:GetName())
	table.insert(abilities, TimeDilation:GetName())
	table.insert(abilities, TimeLock:GetName())
	table.insert(abilities, Chronosphere:GetName())
	
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
	abilities[1], -- Level 7
	abilities[1], -- Level 8
	abilities[3], -- Level 9
	abilities[3], -- Level 10
	abilities[2], -- Level 11
	abilities[4], -- Level 12
	abilities[2], -- Level 13
	abilities[2], -- Level 14
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
	talents[7],   -- Level 25
	"NoLevel",    -- Level 26
	talents[1],   -- Level 27
	talents[4],   -- Level 28
	talents[6],   -- Level 29
	talents[8]    -- Level 30
	}
	
	return SkillPoints
end

function X.GetHeroItemBuild()
	local ItemBuild

	if PRoles.GetPRole(bot, bot:GetUnitName()) == "SafeLane" then
		local SituationalItem1 = PRoles.ShouldBuySilverEdge("item_skadi")
		local SituationalItem2 = PRoles.ShouldBuyMKB("item_butterfly")
		
		ItemBuild = { 
		"item_quelling_blade",
	
		"item_wraith_band",
		"item_magic_wand",
		"item_power_treads",
	
		"item_maelstrom",
		"item_sange_and_yasha",
		"item_mjollnir",
		"item_black_king_bar",
		SituationalItem1,
		SituationalItem2,
		}
	end
	
	return ItemBuild
end

return X