X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local ParalyzingCask = bot:GetAbilityByName("witch_doctor_paralyzing_cask")
local VodooRestoration = bot:GetAbilityByName("witch_doctor_voodoo_restoration")
local Maledict = bot:GetAbilityByName("witch_doctor_maledict")
local DeathWard = bot:GetAbilityByName("witch_doctor_death_ward")

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, ParalyzingCask:GetName())
	table.insert(abilities, VodooRestoration:GetName())
	table.insert(abilities, Maledict:GetName())
	table.insert(abilities, DeathWard:GetName())
	
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
	abilities[1], -- Level 4
	abilities[3], -- Level 5
	abilities[4], -- Level 6
	abilities[3], -- Level 7
	abilities[2], -- Level 8
	abilities[2], -- Level 9
	abilities[2], -- Level 10
	abilities[2], -- Level 11
	abilities[4], -- Level 12
	talents[1],   -- Level 13
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

	if PRoles.GetPRole(bot, bot:GetUnitName()) == "SoftSupport" then
		ItemBuild = { 
		--"item_null_talisman",
		"item_magic_wand",
		"item_tranquil_boots",
		"item_holy_locket",
	
		"item_solar_crest",
		"item_blink",
		"item_force_staff",
		"item_black_king_bar",
		"item_ultimate_scepter_2",
		"item_boots_of_bearing",
		}
	end

	if PRoles.GetPRole(bot, bot:GetUnitName()) == "HardSupport" then
		ItemBuild = { 
		--"item_null_talisman",
		"item_magic_wand",
		"item_arcane_boots",
		"item_holy_locket",
		
		"item_urn_of_shadows",
		"item_blink",
		"item_glimmer_cape",
		"item_spirit_vessel",
		"item_black_king_bar",
		"item_ultimate_scepter_2",
		"item_guardian_greaves",
		}
	end
	
	return ItemBuild
end

return X