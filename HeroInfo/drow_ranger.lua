X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local FrostArrows = bot:GetAbilityByName("drow_ranger_frost_arrows")
local Gust = bot:GetAbilityByName("drow_ranger_wave_of_silence")
local Multishot = bot:GetAbilityByName("drow_ranger_multishot")
local Marksmanship = bot:GetAbilityByName("drow_ranger_marksmanship")

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, FrostArrows:GetName())
	table.insert(abilities, Gust:GetName())
	table.insert(abilities, Multishot:GetName())
	table.insert(abilities, Marksmanship:GetName())
	
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
	abilities[1], -- Level 9
	talents[2],   -- Level 10
	abilities[1], -- Level 11
	abilities[4], -- Level 12
	abilities[2], -- Level 13
	abilities[2], -- Level 14
	talents[3],   -- Level 15
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
		local SituationalItem1 = PRoles.ShouldBuySphere("item_manta")
		local SituationalItem2 = PRoles.ShouldBuySilverEdge("item_greater_crit")
		local SituationalItem3 = PRoles.ShouldBuyMKB("item_butterfly")
		
		ItemBuild = { 
		"item_wraith_band",
		"item_magic_wand",
		"item_power_treads",
	
		"item_falcon_blade",
		"item_dragon_lance",
		SituationalItem1,
		"item_hurricane_pike",
		"item_black_king_bar",
		SituationalItem2,
		SituationalItem3,
		}
	end
	
	return ItemBuild
end

return X