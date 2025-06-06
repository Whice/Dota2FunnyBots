X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local InsatiableHunger = bot:GetAbilityByName("broodmother_insatiable_hunger")
local SpinWeb = bot:GetAbilityByName("broodmother_spin_web")
local IncapacitatingBite = bot:GetAbilityByName("broodmother_incapacitating_bite")
local SpawnSpiderlings = bot:GetAbilityByName("broodmother_spawn_spiderlings")

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, InsatiableHunger:GetName())
	table.insert(abilities, SpinWeb:GetName())
	table.insert(abilities, IncapacitatingBite:GetName())
	table.insert(abilities, SpawnSpiderlings:GetName())
	
	local talents = {}
	
	for i = 0, 25 do
		local ability = bot:GetAbilityInSlot(i)
		if ability ~= nil and ability:IsTalent() then
			table.insert(talents, ability:GetName())
		end
	end
	
	local SkillPoints = {
	abilities[2], -- Level 1
	abilities[1], -- Level 2
	abilities[1], -- Level 3
	abilities[3], -- Level 4
	abilities[2], -- Level 5
	abilities[4], -- Level 6
	abilities[1], -- Level 7
	abilities[1], -- Level 8
	abilities[2], -- Level 9
	talents[2],   -- Level 10
	abilities[2], -- Level 11
	abilities[4], -- Level 12
	abilities[3], -- Level 13
	abilities[3], -- Level 14
	talents[3],   -- Level 15
	abilities[3], -- Level 16
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
	talents[4],   -- Level 28
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
	
		"item_wraith_band",
		"item_magic_wand",
		"item_power_treads",
		"item_soul_ring",
		
		CoreItem,
		"item_bloodthorn",
		"item_black_king_bar",
		"item_heavens_halberd",
		"item_assault",
		}
	end
	
	if PRoles.GetPRole(bot, bot:GetUnitName()) == "MidLane" then
		local SituationalItem1 = PRoles.ShouldBuySphere("item_harpoon")
		
		ItemBuild = { 
		"item_quelling_blade",
	
		"item_wraith_band",
		"item_magic_wand",
		"item_power_treads",
		"item_soul_ring",
		
		"item_bloodthorn",
		"item_black_king_bar",
		"item_nullifier",
		SituationalItem1,
		"item_sheepstick",
		}
	end
	
	return ItemBuild
end

return X