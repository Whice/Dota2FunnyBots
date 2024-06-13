X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local DualBreath = bot:GetAbilityByName("jakiro_dual_breath")
local IcePath = bot:GetAbilityByName("jakiro_ice_path")
local LiquidFire = bot:GetAbilityByName("jakiro_liquid_fire")
local Macropyre = bot:GetAbilityByName("jakiro_macropyre")
local LiquidIce = bot:GetAbilityByName("jakiro_liquid_ice")

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, DualBreath:GetName())
	table.insert(abilities, IcePath:GetName())
	table.insert(abilities, LiquidFire:GetName())
	table.insert(abilities, Macropyre:GetName())
	
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
	abilities[1], -- Level 3
	abilities[2], -- Level 4
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
	talents[4],   -- Level 15
	abilities[3], -- Level 16
	"NoLevel",    -- Level 17
	abilities[4], -- Level 18
	"NoLevel",    -- Level 19
	talents[5],   -- Level 20
	"NoLevel",    -- Level 21
	"NoLevel",    -- Level 22
	"NoLevel",    -- Level 23
	"NoLevel",    -- Level 24
	talents[8],   -- Level 25
	"NoLevel",    -- Level 26
	talents[2],   -- Level 27
	talents[3],   -- Level 28
	talents[6],   -- Level 29
	talents[7]    -- Level 30
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
		
		"item_urn_of_shadows",
		"item_glimmer_cape",
		"item_spirit_vessel",
		"item_cyclone",
		"item_sheepstick",
		"item_ultimate_scepter_2",
		"item_octarine_core",
		"item_guardian_greaves",
		}
	end
	
	return ItemBuild
end

return X