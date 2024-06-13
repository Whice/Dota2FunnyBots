X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local HoofStomp = bot:GetAbilityByName("centaur_hoof_stomp")
local DoubleEdge = bot:GetAbilityByName("centaur_double_edge")
local Retaliate = bot:GetAbilityByName("centaur_return")
local Stampede = bot:GetAbilityByName("centaur_stampede")

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, HoofStomp:GetName())
	table.insert(abilities, DoubleEdge:GetName())
	table.insert(abilities, Retaliate:GetName())
	table.insert(abilities, Stampede:GetName())
	
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
	abilities[3], -- Level 3
	abilities[2], -- Level 4
	abilities[3], -- Level 5
	abilities[4], -- Level 6
	abilities[3], -- Level 7
	abilities[1], -- Level 8
	abilities[1], -- Level 9
	talents[1],   -- Level 10
	abilities[1], -- Level 11
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
	talents[2],   -- Level 27
	talents[3],   -- Level 28
	talents[5],   -- Level 29
	talents[7]    -- Level 30
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
		"item_power_treads",
		
		CoreItem,
		"item_blink",
		"item_eternal_shroud",
		"item_overwhelming_blink",
		"item_heavens_halberd",
		"item_assault",
		}
	end
	
	return ItemBuild
end

return X