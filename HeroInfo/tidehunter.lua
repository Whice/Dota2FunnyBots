X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local Gush = bot:GetAbilityByName("tidehunter_gush")
local KrakenShell = bot:GetAbilityByName("tidehunter_kraken_shell")
local AnchorSmash = bot:GetAbilityByName("tidehunter_anchor_smash")
local Ravage = bot:GetAbilityByName("tidehunter_ravage")
local TendrilsOfTheDeep = bot:GetAbilityByName("tidehunter_arm_of_the_deep")

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, Gush:GetName())
	table.insert(abilities, KrakenShell:GetName())
	table.insert(abilities, AnchorSmash:GetName())
	table.insert(abilities, Ravage:GetName())
	
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
	abilities[1], -- Level 3
	abilities[3], -- Level 4
	abilities[1], -- Level 5
	abilities[4], -- Level 6
	abilities[1], -- Level 7
	abilities[2], -- Level 8
	abilities[2], -- Level 9
	talents[1],   -- Level 10
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
	talents[2],   -- Level 27
	talents[4],   -- Level 28
	talents[5],   -- Level 29
	talents[8]    -- Level 30
	}
	
	return SkillPoints
end

function X.GetHeroItemBuild()
	local ItemBuild

	if PRoles.GetPRole(bot, bot:GetUnitName()) == "OffLane" then
		ItemBuild = { 
		"item_quelling_blade",
	
		"item_bracer",
		"item_magic_wand",
		"item_phase_boots",
		"item_soul_ring",
		
		"item_pipe",
		"item_eternal_shroud",
		"item_blink",
		"item_ultimate_scepter",
		"item_heavens_halberd",
		"item_assault",
		"item_overwhelming_blink",
		}
	end
	
	return ItemBuild
end

return X