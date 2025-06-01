X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local Flux = bot:GetAbilityByName("arc_warden_flux")
local MagneticField = bot:GetAbilityByName("arc_warden_magnetic_field")
local SparkWraith = bot:GetAbilityByName("arc_warden_spark_wraith")
local TempestDouble = bot:GetAbilityByName("arc_warden_tempest_double")

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, Flux:GetName())
	table.insert(abilities, MagneticField:GetName())
	table.insert(abilities, SparkWraith:GetName())
	table.insert(abilities, TempestDouble:GetName())
	
	local talents = {}
	
	for i = 0, 25 do
		local ability = bot:GetAbilityInSlot(i)
		if ability ~= nil and ability:IsTalent() then
			table.insert(talents, ability:GetName())
		end
	end
	
	local SkillPoints = {
	abilities[3], -- Level 1
	abilities[1], -- Level 2
	abilities[3], -- Level 3
	abilities[1], -- Level 4
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
	talents[6],   -- Level 20
	"NoLevel",    -- Level 21
	"NoLevel",    -- Level 22
	"NoLevel",    -- Level 23
	"NoLevel",    -- Level 24
	talents[8],   -- Level 25
	"NoLevel",    -- Level 26
	talents[1],   -- Level 27
	talents[3],   -- Level 28
	talents[5],   -- Level 29
	talents[7]    -- Level 30
	}
	
	return SkillPoints
end

function X.GetHeroItemBuild()
	local ItemBuild

	if PRoles.GetPRole(bot, bot:GetUnitName()) == "MidLane" then
		local SituationalItem1 = PRoles.ShouldBuySilverEdge("item_greater_crit")
		
		ItemBuild = { 
		"item_wraith_band",
		"item_magic_wand",
		"item_power_treads",
		"item_hand_of_midas",
	
		"item_mjollnir",
		"item_bloodthorn",
		"item_hurricane_pike",
		
		"item_manta",
		SituationalItem1,
		"item_butterfly",
		}
	end
	
	if PRoles.GetPRole(bot, bot:GetUnitName()) == "SafeLane" then
		local SituationalItem1 = PRoles.ShouldBuySilverEdge("item_greater_crit")
		
		ItemBuild = { 
		"item_wraith_band",
		"item_magic_wand",
		"item_hand_of_midas",
		"item_power_treads",
	
		"item_mjollnir",
		"item_bloodthorn",
		"item_hurricane_pike",
		
		SituationalItem1,
		"item_butterfly",
		"item_skadi",
		}
	end
	
	return ItemBuild
end

return X