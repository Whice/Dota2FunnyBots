X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local OverwhelmingOdds = bot:GetAbilityByName("legion_commander_overwhelming_odds")
local PressTheAttack = bot:GetAbilityByName("legion_commander_press_the_attack")
local MomentOfCourage = bot:GetAbilityByName("legion_commander_moment_of_courage")
local Duel = bot:GetAbilityByName("legion_commander_duel")

local AttackRange
local manathreshold

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, OverwhelmingOdds:GetName())
	table.insert(abilities, PressTheAttack:GetName())
	table.insert(abilities, MomentOfCourage:GetName())
	table.insert(abilities, Duel:GetName())
	
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
	abilities[2], -- Level 3
	abilities[3], -- Level 4
	abilities[3], -- Level 5
	abilities[4], -- Level 6
	abilities[2], -- Level 7
	abilities[2], -- Level 8
	abilities[2], -- Level 9
	talents[2],   -- Level 10
	abilities[3], -- Level 11
	abilities[4], -- Level 12
	abilities[1], -- Level 13
	abilities[1], -- Level 14
	talents[3],   -- Level 15
	abilities[1], -- Level 16
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

	if PRoles.GetPRole(bot, bot:GetUnitName()) == "OffLane" then
		local CoreItem = PRoles.GetAOEItem()
		
		ItemBuild = { 
		"item_quelling_blade",
	
		"item_bracer",
		"item_magic_wand",
		"item_phase_boots",
	
		CoreItem,
		"item_blade_mail",
		"item_blink",
		"item_black_king_bar",
		"item_assault",
		"item_overwhelming_blink",
		}
	end
	
	return ItemBuild
end

return X