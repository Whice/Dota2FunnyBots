X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local Sprout = bot:GetAbilityByName("furion_sprout")
local Teleportation = bot:GetAbilityByName("furion_teleportation")
local ForceOfNature = bot:GetAbilityByName("furion_force_of_nature")
local WrathOfNature = bot:GetAbilityByName("furion_wrath_of_nature")

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, Sprout:GetName())
	table.insert(abilities, Teleportation:GetName())
	table.insert(abilities, ForceOfNature:GetName())
	table.insert(abilities, WrathOfNature:GetName())
	
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
	abilities[2], -- Level 4
	abilities[3], -- Level 5
	abilities[4], -- Level 6
	abilities[3], -- Level 7
	abilities[2], -- Level 8
	abilities[2], -- Level 9
	talents[2],   -- Level 10
	abilities[2], -- Level 11
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
	talents[7],   -- Level 25
	"NoLevel",    -- Level 26
	talents[1],   -- Level 27
	talents[3],   -- Level 28
	talents[5],   -- Level 29
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
	
		"item_null_talisman",
		"item_magic_wand",
		"item_power_treads",
		
		CoreItem,
		"item_heavens_halberd",
		"item_black_king_bar",
		"item_assault",
		"item_greater_crit",
		"item_ultimate_scepter_2",
		}
	end
	
	return ItemBuild
end

return X