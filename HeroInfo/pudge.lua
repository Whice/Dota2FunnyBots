X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local MeatHook = bot:GetAbilityByName("pudge_meat_hook")
local Rot = bot:GetAbilityByName("pudge_rot")
local FleshHeap = bot:GetAbilityByName("pudge_flesh_heap")
local Dismember = bot:GetAbilityByName("pudge_dismember")

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, MeatHook:GetName())
	table.insert(abilities, Rot:GetName())
	table.insert(abilities, FleshHeap:GetName())
	table.insert(abilities, Dismember:GetName())
	
	local talents = {}
	
	for i = 0, 25 do
		local ability = bot:GetAbilityInSlot(i)
		if ability ~= nil and ability:IsTalent() then
			table.insert(talents, ability:GetName())
		end
	end
	
	local SkillPoints = {
	abilities[1], -- Level 1
	abilities[2], -- Level 2
	abilities[2], -- Level 3
	abilities[3], -- Level 4
	abilities[2], -- Level 5
	abilities[4], -- Level 6
	abilities[3], -- Level 7
	abilities[2], -- Level 8
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

	if PRoles.GetPRole(bot, bot:GetUnitName()) == "OffLane" then
		local CoreItem = PRoles.GetAOEItem()
		
		ItemBuild = { 
		"item_bracer",
		"item_magic_wand",
		"item_phase_boots",
		"item_soul_ring",
		
		CoreItem,
		"item_eternal_shroud",
		"item_ultimate_scepter",
		"item_blink",
		"item_black_king_bar",
		"item_ultimate_scepter_2",
		"item_assault",
		"item_overwhelming_blink",
		}
	end
	
	if PRoles.GetPRole(bot, bot:GetUnitName()) == "MidLane" then
		ItemBuild = { 
		"item_bracer",
		"item_magic_wand",
		"item_phase_boots",
		
		"item_eternal_shroud",
		"item_ultimate_scepter",
		"item_shivas_guard",
		"item_blink",
		"item_kaya_and_sange",
		"item_ultimate_scepter_2",
		"item_black_king_bar",
		"item_overwhelming_blink",
		}
	end
	
	return ItemBuild
end

return X