X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local ShockWave = bot:GetAbilityByName("magnataur_shockwave")
local Empower = bot:GetAbilityByName("magnataur_empower")
local Skewer = bot:GetAbilityByName("magnataur_skewer")
local ReversePolarity = bot:GetAbilityByName("magnataur_reverse_polarity")

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, ShockWave:GetName())
	table.insert(abilities, Empower:GetName())
	table.insert(abilities, Skewer:GetName())
	table.insert(abilities, ReversePolarity:GetName())
	
	local talents = {}
	
	for i = 0, 25 do
		local ability = bot:GetAbilityInSlot(i)
		if ability ~= nil and ability:IsTalent() then
			table.insert(talents, ability:GetName())
		end
	end
	
	local SkillPoints
	
	if PRoles.GetPRole(bot, bot:GetUnitName()) == "MidLane" then
		SkillPoints = {
		abilities[2], -- Level 1
		abilities[3], -- Level 2
		abilities[2], -- Level 3
		abilities[1], -- Level 4
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
		abilities[1], -- Level 16
		abilities[1], -- Level 17
		abilities[4], -- Level 18
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
	end
	
	if PRoles.GetPRole(bot, bot:GetUnitName()) == "OffLane" then
		SkillPoints = {
		abilities[1], -- Level 1
		abilities[3], -- Level 2
		abilities[1], -- Level 3
		abilities[2], -- Level 4
		abilities[1], -- Level 5
		abilities[4], -- Level 6
		abilities[1], -- Level 7
		abilities[2], -- Level 8
		abilities[1], -- Level 9
		talents[1],   -- Level 10
		abilities[2], -- Level 11
		abilities[4], -- Level 12
		abilities[2], -- Level 13
		abilities[3], -- Level 14
		talents[3],   -- Level 15
		abilities[3], -- Level 16
		abilities[3], -- Level 17
		abilities[4], -- Level 18
		"NoLevel",    -- Level 19
		talents[6],   -- Level 20
		"NoLevel",    -- Level 21
		"NoLevel",    -- Level 22
		"NoLevel",    -- Level 23
		"NoLevel",    -- Level 24
		talents[8],   -- Level 25
		"NoLevel",    -- Level 26
		talents[2],   -- Level 27
		talents[4],   -- Level 28
		talents[5],   -- Level 29
		talents[7]    -- Level 30
		}
	end
	
	return SkillPoints
end

function X.GetHeroItemBuild()
	local ItemBuild

	if PRoles.GetPRole(bot, bot:GetUnitName()) == "MidLane" then
		local SituationalItem1 = PRoles.ShouldBuySilverEdge("item_greater_crit")
		local SituationalItem2 = PRoles.ShouldBuySphere("item_shivas_guard")
		
		ItemBuild = { 
		"item_bottle",
		"item_wraith_band",
		"item_magic_wand",
		"item_power_treads",
	
		"item_blink",
		"item_harpoon",
		"item_black_king_bar",
		SituationalItem1,
		SituationalItem2,
		"item_ultimate_scepter_2",
		"item_arcane_blink",
		}
	end
	
	if PRoles.GetPRole(bot, bot:GetUnitName()) == "OffLane" then
		local CoreItem = PRoles.GetAOEItem()
		
		ItemBuild = { 
		"item_bracer",
		"item_magic_wand",
		"item_power_treads",
		
		"item_blink",
		"item_kaya",
		"item_yasha_and_kaya",
		"item_black_king_bar",
		CoreItem,
		"item_ultimate_scepter_2",
		"item_octarine_core",
		"item_arcane_blink",
		}
	end
	
	return ItemBuild
end

return X