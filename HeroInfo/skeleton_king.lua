X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local HellfireBlast = bot:GetAbilityByName("skeleton_king_hellfire_blast")
local BoneGuard = bot:GetAbilityByName("skeleton_king_bone_guard")
local MortalStrike = bot:GetAbilityByName("skeleton_king_mortal_strike")
local Reincarnation = bot:GetAbilityByName("skeleton_king_reincarnation")

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, HellfireBlast:GetName())
	table.insert(abilities, BoneGuard:GetName())
	table.insert(abilities, MortalStrike:GetName())
	table.insert(abilities, Reincarnation:GetName())
	
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
	abilities[3], -- Level 3
	abilities[2], -- Level 4
	abilities[2], -- Level 5
	abilities[3], -- Level 6
	abilities[2], -- Level 7
	abilities[4], -- Level 8
	abilities[3], -- Level 9
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

	if PRoles.GetPRole(bot, bot:GetUnitName()) == "SafeLane" then
		local SituationalItem1 = PRoles.ShouldBuyMKB("item_bloodthorn")
		
		ItemBuild = { 
		"item_quelling_blade",
	
		"item_bracer",
		"item_magic_wand",
		"item_phase_boots",
	
		"item_armlet",
		"item_radiance",
		"item_blink",
		"item_ultimate_scepter_2",
		"item_black_king_bar",
		SituationalItem1,
		"item_overwhelming_blink",
		}
	end
	
	if PRoles.GetPRole(bot, bot:GetUnitName()) == "OffLane" then
		local CoreItem = PRoles.GetAOEItem()
		local SituationalItem1 = PRoles.ShouldBuySilverEdge("item_desolator")
		
		ItemBuild = { 
		"item_quelling_blade",
	
		"item_bracer",
		"item_magic_wand",
		"item_phase_boots",
		"item_hand_of_midas",
		
		CoreItem,
		SituationalItem1,
		"item_blink",
		"item_heavens_halberd",
		"item_assault",
		"item_ultimate_scepter_2",
		"item_overwhelming_blink",
		}
	end
	
	return ItemBuild
end

return X