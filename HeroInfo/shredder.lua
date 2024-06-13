X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local WhirlingDeath = bot:GetAbilityByName("shredder_whirling_death")
local TimberChain = bot:GetAbilityByName("shredder_timber_chain")
local ReactiveArmor = bot:GetAbilityByName("shredder_reactive_armor")
local Chakram = bot:GetAbilityByName("shredder_chakram")

local ReturnChakram = bot:GetAbilityByName("shredder_return_chakram")

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, WhirlingDeath:GetName())
	table.insert(abilities, TimberChain:GetName())
	table.insert(abilities, ReactiveArmor:GetName())
	if bot:HasModifier("modifier_shredder_chakram_disarm") then
		table.insert(abilities, ReturnChakram:GetName())
	else
		table.insert(abilities, Chakram:GetName())
	end
	
	local talents = {}
	
	for i = 0, 25 do
		local ability = bot:GetAbilityInSlot(i)
		if ability ~= nil and ability:IsTalent() then
			table.insert(talents, ability:GetName())
		end
	end
	
	local SkillPoints = {
	abilities[3], -- Level 1
	abilities[2], -- Level 2
	abilities[3], -- Level 3
	abilities[1], -- Level 4
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
		"item_ring_of_basilius",
		"item_arcane_boots",
		"item_soul_ring",
		
		CoreItem,
		"item_eternal_shroud",
		"item_kaya_and_sange",
		"item_heavens_halberd",
		"item_assault",
		
		"item_ultimate_scepter_2",
		}
	end
	
	return ItemBuild
end

return X