X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local Bloodrage = bot:GetAbilityByName("bloodseeker_bloodrage")
local BloodBath = bot:GetAbilityByName("bloodseeker_blood_bath")
local Thirst = bot:GetAbilityByName("bloodseeker_thirst")
local Rupture = bot:GetAbilityByName("bloodseeker_rupture")

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, Bloodrage:GetName())
	table.insert(abilities, BloodBath:GetName())
	table.insert(abilities, Thirst:GetName())
	table.insert(abilities, Rupture:GetName())
	
	local talents = {}
	
	for i = 0, 25 do
		local ability = bot:GetAbilityInSlot(i)
		if ability ~= nil and ability:IsTalent() then
			table.insert(talents, ability:GetName())
		end
	end
	
	local SkillPoints
	
	if PRoles.GetPRole(bot, bot:GetUnitName()) == "SafeLane" then
		SkillPoints = {
		abilities[2], -- Level 1
		abilities[3], -- Level 2
		abilities[3], -- Level 3
		abilities[1], -- Level 4
		abilities[1], -- Level 5
		abilities[4], -- Level 6
		abilities[1], -- Level 7
		abilities[1], -- Level 8
		abilities[3], -- Level 9
		talents[1],   -- Level 10
		abilities[3], -- Level 11
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
		talents[2],   -- Level 27
		talents[4],   -- Level 28
		talents[6],   -- Level 29
		talents[8]    -- Level 30
		}
	end
	
	if PRoles.GetPRole(bot, bot:GetUnitName()) == "OffLane" then
		SkillPoints = {
		abilities[2], -- Level 1
		abilities[3], -- Level 2
		abilities[2], -- Level 3
		abilities[1], -- Level 4
		abilities[2], -- Level 5
		abilities[4], -- Level 6
		abilities[2], -- Level 7
		abilities[1], -- Level 8
		abilities[1], -- Level 9
		talents[2],   -- Level 10
		abilities[1], -- Level 11
		abilities[4], -- Level 12
		abilities[3], -- Level 13
		abilities[3], -- Level 14
		talents[4],   -- Level 15
		abilities[3], -- Level 16
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
	end
	
	return SkillPoints
end

function X.GetHeroItemBuild()
	local ItemBuild

	if PRoles.GetPRole(bot, bot:GetUnitName()) == "SafeLane" then
		local SituationalItem1 = PRoles.ShouldBuySphere("item_sange_and_yasha")
		local SituationalItem2 = PRoles.ShouldBuyMKB("item_butterfly")
		
		ItemBuild = { 
		"item_quelling_blade",
	
		"item_wraith_band",
		"item_magic_wand",
		"item_phase_boots",
		
		"item_mjollnir",
		"item_black_king_bar",
		SituationalItem1,
		"item_basher",
		"item_ultimate_scepter_2",
		SituationalItem2,
		
		"item_abyssal_blade",
		}
	end
	
	if PRoles.GetPRole(bot, bot:GetUnitName()) == "OffLane" then
		local CoreItem = PRoles.GetAOEItem()
		
		ItemBuild = { 
		"item_quelling_blade",
	
		"item_wraith_band",
		"item_magic_wand",
		"item_phase_boots",
	
		"item_blade_mail",
		"item_black_king_bar",
		CoreItem,
		"item_gungir",
		"item_sange_and_yasha",
		"item_ultimate_scepter_2",
		}
	end
	
	return ItemBuild
end

return X