X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local SmokeScreen = bot:GetAbilityByName("riki_smoke_screen")
local BlinkStrike = bot:GetAbilityByName("riki_blink_strike")
local TricksOfTheTrade = bot:GetAbilityByName("riki_tricks_of_the_trade")
local Backstab = bot:GetAbilityByName("riki_backstab")

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, SmokeScreen:GetName())
	table.insert(abilities, BlinkStrike:GetName())
	table.insert(abilities, TricksOfTheTrade:GetName())
	table.insert(abilities, Backstab:GetName())
	
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
		local SituationalItem1 = PRoles.ShouldBuySphere("item_manta")
		
		ItemBuild = { 
		"item_quelling_blade",
	
		"item_bottle",
		"item_wraith_band",
		"item_magic_wand",
		"item_power_treads",
		
		"item_diffusal_blade",
		
		"item_nullifier",
		SituationalItem1,
		"item_greater_crit",
		"item_disperser",
		"item_abyssal_blade",
		}
	end
	
	if PRoles.GetPRole(bot, bot:GetUnitName()) == "SafeLane" then
		local SituationalItem1 = PRoles.ShouldBuySphere("item_manta")
		
		ItemBuild = { 
		"item_quelling_blade",
	
		"item_wraith_band",
		"item_magic_wand",
		"item_power_treads",
		
		"item_diffusal_blade",
		
		"item_nullifier",
		SituationalItem1,
		"item_greater_crit",
		"item_disperser",
		"item_abyssal_blade",
		}
	end
	
	return ItemBuild
end

return X