X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local LucentBeam = bot:GetAbilityByName("luna_lucent_beam")
local MoonGlaives = bot:GetAbilityByName("luna_moon_glaive")
local LunarBlessing = bot:GetAbilityByName("luna_lunar_blessing")
local Eclipse = bot:GetAbilityByName("luna_eclipse")

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, LucentBeam:GetName())
	table.insert(abilities, MoonGlaives:GetName())
	table.insert(abilities, LunarBlessing:GetName())
	table.insert(abilities, Eclipse:GetName())
	
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
	talents[1],   -- Level 10
	abilities[2], -- Level 11
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

	if PRoles.GetPRole(bot, bot:GetUnitName()) == "SafeLane" then
		ItemBuild = { 
		"item_quelling_blade",
	
		"item_wraith_band",
		"item_magic_wand",
		"item_power_treads",
		
		"item_mask_of_madness",
		"item_dragon_lance",
		"item_manta",
		"item_black_king_bar",
		"item_angels_demise",
		"item_hurricane_pike",
		}
	end
	
	return ItemBuild
end

return X