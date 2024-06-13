X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local Rage = bot:GetAbilityByName("life_stealer_rage")
local OpenWounds = bot:GetAbilityByName("life_stealer_open_wounds")
local GhoulFrenzy = bot:GetAbilityByName("life_stealer_ghoul_frenzy")
local Infest = bot:GetAbilityByName("life_stealer_infest")

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, Rage:GetName())
	table.insert(abilities, OpenWounds:GetName())
	table.insert(abilities, GhoulFrenzy:GetName())
	table.insert(abilities, Infest:GetName())
	
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
	abilities[1], -- Level 9
	talents[2],   -- Level 10
	abilities[1], -- Level 11
	abilities[4], -- Level 12
	abilities[1], -- Level 13
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
	talents[1],   -- Level 27
	talents[4],   -- Level 28
	talents[5],   -- Level 29
	talents[7]    -- Level 30
	}
	
	return SkillPoints
end

function X.GetHeroItemBuild()
	local ItemBuild

	if PRoles.GetPRole(bot, bot:GetUnitName()) == "SafeLane" then
		ItemBuild = { 
		"item_quelling_blade",
	
		"item_bracer",
		"item_magic_wand",
		"item_phase_boots",
	
		"item_orb_of_corrosion",
		"item_radiance",
		"item_sange_and_yasha",
		"item_basher",
		"item_skadi",
		"item_abyssal_blade",
		}
	end
	
	return ItemBuild
end

return X