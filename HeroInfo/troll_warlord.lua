X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local BerserkersRage = bot:GetAbilityByName("troll_warlord_berserkers_rage")
local WhirlingAxes = bot:GetAbilityByName("troll_warlord_whirling_axes_ranged")
local Fervor = bot:GetAbilityByName("troll_warlord_fervor")
local BattleTrance = bot:GetAbilityByName("troll_warlord_battle_trance")

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, BerserkersRage:GetName())
	table.insert(abilities, WhirlingAxes:GetName())
	table.insert(abilities, Fervor:GetName())
	table.insert(abilities, BattleTrance:GetName())
	
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
	abilities[4], -- Level 6
	abilities[2], -- Level 7
	abilities[3], -- Level 8
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
	
		"item_wraith_band",
		"item_magic_wand",
		"item_power_treads",
	
		"item_bfury",
		"item_sange_and_yasha",
		"item_black_king_bar",
		"item_basher",
		"item_butterfly",
		"item_abyssal_blade",
		"item_ultimate_scepter_2",
		}
	end
	
	return ItemBuild
end

return X