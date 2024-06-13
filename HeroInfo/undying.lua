X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local Decay = bot:GetAbilityByName("undying_decay")
local SoulRip = bot:GetAbilityByName("undying_soul_rip")
local Tombstone = bot:GetAbilityByName("undying_tombstone")
local FleshGolem = bot:GetAbilityByName("undying_flesh_golem")

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, Decay:GetName())
	table.insert(abilities, SoulRip:GetName())
	table.insert(abilities, Tombstone:GetName())
	table.insert(abilities, FleshGolem:GetName())
	
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
	abilities[1], -- Level 4
	abilities[1], -- Level 5
	abilities[4], -- Level 6
	abilities[1], -- Level 7
	abilities[3], -- Level 8
	abilities[3], -- Level 9
	talents[1],   -- Level 10
	abilities[2], -- Level 11
	abilities[4], -- Level 12
	abilities[2], -- Level 13
	abilities[2], -- Level 14
	talents[4],   -- Level 15
	abilities[2], -- Level 16
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
	talents[2],   -- Level 27
	talents[3],   -- Level 28
	talents[6],   -- Level 29
	talents[8]    -- Level 30
	}
	
	return SkillPoints
end

function X.GetHeroItemBuild()
	local ItemBuild

	if PRoles.GetPRole(bot, bot:GetUnitName()) == "HardSupport" then
		ItemBuild = { 
		--"item_null_talisman",
		"item_magic_wand",
		"item_arcane_boots",
		"item_holy_locket",
		
		"item_urn_of_shadows",
		"item_glimmer_cape",
		"item_spirit_vessel",
		"item_lotus_orb",
		"item_sheepstick",
		"item_guardian_greaves",
		}
	end
	
	return ItemBuild
end

return X