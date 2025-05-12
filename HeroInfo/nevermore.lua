X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local Shadowraze1 = bot:GetAbilityByName("nevermore_shadowraze1")
local Shadowraze2 = bot:GetAbilityByName("nevermore_shadowraze2")
local Shadowraze3 = bot:GetAbilityByName("nevermore_shadowraze3")
local FeastOfSouls = bot:GetAbilityByName("nevermore_frenzy")
local DarkLord = bot:GetAbilityByName("nevermore_dark_lord")
local Requiem = bot:GetAbilityByName("nevermore_requiem")

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, Shadowraze1:GetName())
	table.insert(abilities, FeastOfSouls:GetName())
	table.insert(abilities, DarkLord:GetName())
	table.insert(abilities, Requiem:GetName())
	
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
		abilities[1], -- Level 1
		abilities[3], -- Level 2
		abilities[1], -- Level 3
		abilities[3], -- Level 4
		abilities[1], -- Level 5
		abilities[4], -- Level 6
		abilities[1], -- Level 7
		abilities[3], -- Level 8
		abilities[3], -- Level 9
		talents[1],   -- Level 10
		abilities[2], -- Level 11
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
		talents[2],   -- Level 27
		talents[3],   -- Level 28
		talents[5],   -- Level 29
		talents[8]    -- Level 30
		}
	end
	
	if PRoles.GetPRole(bot, bot:GetUnitName()) == "SafeLane" then
		SkillPoints = {
		abilities[1], -- Level 1
		abilities[3], -- Level 2
		abilities[1], -- Level 3
		abilities[3], -- Level 4
		abilities[1], -- Level 5
		abilities[4], -- Level 6
		abilities[1], -- Level 7
		abilities[3], -- Level 8
		abilities[3], -- Level 9
		talents[2],   -- Level 10
		abilities[2], -- Level 11
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
		talents[8],   -- Level 25
		"NoLevel",    -- Level 26
		talents[1],   -- Level 27
		talents[4],   -- Level 28
		talents[6],   -- Level 29
		talents[7]    -- Level 30
		}
	end
	
	return SkillPoints
end

function X.GetHeroItemBuild()
	local ItemBuild

	if PRoles.GetPRole(bot, bot:GetUnitName()) == "MidLane" then
		local SituationalItem1 = PRoles.ShouldBuySphere("item_refresher")
		
		ItemBuild = { 
		"item_bottle",
		"item_null_talisman",
		"item_magic_wand",
		"item_power_treads",
	
		"item_yasha_and_kaya",
		"item_blink",
		"item_ultimate_scepter",
		"item_black_king_bar",
		"item_sheepstick",
		"item_ultimate_scepter_2",
		SituationalItem1,
		"item_arcane_blink",
		}
	end
	
	if PRoles.GetPRole(bot, bot:GetUnitName()) == "SafeLane" then
		local SituationalItem1 = PRoles.ShouldBuySilverEdge("item_greater_crit")
		local SituationalItem2 = PRoles.ShouldBuySphere("item_satanic")
		local SituationalItem3 = PRoles.ShouldBuyMKB("item_butterfly")
		
		ItemBuild = { 
		"item_wraith_band",
		"item_magic_wand",
		"item_power_treads",
		
		"item_dragon_lance",
		"item_black_king_bar",
		"item_hurricane_pike",
		SituationalItem1,
		SituationalItem3,
		SituationalItem2,
		"item_ultimate_scepter_2",
		}
	end
	
	return ItemBuild
end

return X