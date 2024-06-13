X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local GraveChill = bot:GetAbilityByName("visage_grave_chill")
local SoulAssumption = bot:GetAbilityByName("visage_soul_assumption")
local GravekeepersCloak = bot:GetAbilityByName("visage_gravekeepers_cloak")
local SummonFamiliars = bot:GetAbilityByName("visage_summon_familiars")

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, GraveChill:GetName())
	table.insert(abilities, SoulAssumption:GetName())
	table.insert(abilities, GravekeepersCloak:GetName())
	table.insert(abilities, SummonFamiliars:GetName())
	
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
	abilities[1], -- Level 5
	abilities[4], -- Level 6
	abilities[1], -- Level 7
	abilities[3], -- Level 8
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
	talents[6],   -- Level 20
	"NoLevel",    -- Level 21
	"NoLevel",    -- Level 22
	"NoLevel",    -- Level 23
	"NoLevel",    -- Level 24
	talents[8],   -- Level 25
	"NoLevel",    -- Level 26
	talents[2],   -- Level 27
	talents[4],   -- Level 28
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
	
		"item_null_talisman",
		"item_magic_wand",
		"item_tranquil_boots",
		
		CoreItem,
		"item_assault",
		"item_black_king_bar",
		"item_heavens_halberd",
		"item_nullifier",
		"item_ultimate_scepter_2",
		}
	end
	
	if PRoles.GetPRole(bot, bot:GetUnitName()) == "MidLane" then
		ItemBuild = { 
		"item_blight_stone",
	
		"item_null_talisman",
		"item_magic_wand",
		"item_tranquil_boots",
		
		"item_phylactery",
		"item_desolator",
		"item_angels_demise",
		"item_ultimate_scepter",
		"item_shivas_guard",
		"item_sheepstick",
		"item_ultimate_scepter_2",
		"item_bloodthorn",
		}
	end
	
	return ItemBuild
end

return X