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
		local SituationalItem1 = PRoles.ShouldBuySphere("item_sange_and_yasha")
		local SituationalItem2 = PRoles.ShouldBuyMKB("item_greater_crit")
		
		ItemBuild = { 
		"item_quelling_blade",
	
		"item_wraith_band",
		"item_magic_wand",
		"item_power_treads",
		"item_falcon_blade",
		
		"item_dragon_lance",
		"item_desolator",
		"item_black_king_bar",
		SituationalItem1,
		SituationalItem2,
		"item_satanic",
		"item_hurricane_pike"
		}
	end

	if PRoles.GetPRole(bot, bot:GetUnitName()) == "SoftSupport" then
		ItemBuild = { 
		"item_magic_wand",
		"item_tranquil_boots",
		
		"item_solar_crest",
		"item_force_staff",
		"item_rod_of_atos",
		"item_gungir",
		"item_black_king_bar",
		"item_boots_of_bearing",
		}
	end
	
	if PRoles.GetPRole(bot, bot:GetUnitName()) == "HardSupport" then
		ItemBuild = { 
		"item_magic_wand",
		"item_arcane_boots",
		
		"item_urn_of_shadows",
		"item_glimmer_cape",
		"item_spirit_vessel",
		"item_rod_of_atos",
		"item_gungir",
		"item_black_king_bar",
		"item_guardian_greaves",
		}
	end
	
	return ItemBuild
end

return X