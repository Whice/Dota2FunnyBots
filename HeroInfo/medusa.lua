X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local SplitShot = bot:GetAbilityByName("medusa_split_shot")
local MysticSnake = bot:GetAbilityByName("medusa_mystic_snake")
local GorgonGrasp = bot:GetAbilityByName("medusa_gorgon_grasp")
local StoneGaze = bot:GetAbilityByName("medusa_stone_gaze")

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, SplitShot:GetName())
	table.insert(abilities, MysticSnake:GetName())
	table.insert(abilities, GorgonGrasp:GetName())
	table.insert(abilities, StoneGaze:GetName())
	
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
	abilities[3], -- Level 4
	abilities[2], -- Level 5
	abilities[4], -- Level 6
	abilities[2], -- Level 7
	abilities[1], -- Level 8
	abilities[1], -- Level 9
	talents[1],   -- Level 10
	abilities[1], -- Level 11
	abilities[3], -- Level 12
	abilities[1], -- Level 13
	abilities[3], -- Level 14
	talents[4],   -- Level 15
	abilities[4], -- Level 16
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
	talents[2],   -- Level 27
	talents[3],   -- Level 28
	talents[6],   -- Level 29
	talents[7]    -- Level 30
	}
	
	return SkillPoints
end

function X.GetHeroItemBuild()
	local ItemBuild

	if PRoles.GetPRole(bot, bot:GetUnitName()) == "SafeLane" then
		local SituationalItem1 = PRoles.ShouldBuySphere("item_manta")
		local SituationalItem2 = PRoles.ShouldBuyMKB("item_butterfly")
		local SituationalItem3 = PRoles.ShouldBuySilverEdge("item_greater_crit")
		
		ItemBuild = { 
		"item_ring_of_basilius",
		"item_arcane_boots",
		"item_wraith_band",
	
		SituationalItem1,
		SituationalItem2,
		"item_skadi",
		"item_black_king_bar",
		SituationalItem3,
		}
	end
	
	return ItemBuild
end

return X