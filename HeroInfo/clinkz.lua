X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local Strafe = bot:GetAbilityByName("clinkz_strafe")
local TarBomb = bot:GetAbilityByName("clinkz_tar_bomb")
local DeathPact = bot:GetAbilityByName("clinkz_death_pact")
local SkeletonWalk = bot:GetAbilityByName("clinkz_wind_walk")

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, Strafe:GetName())
	table.insert(abilities, TarBomb:GetName())
	table.insert(abilities, DeathPact:GetName())
	table.insert(abilities, SkeletonWalk:GetName())
	
	local talents = {}
	
	for i = 0, 25 do
		local ability = bot:GetAbilityInSlot(i)
		if ability ~= nil and ability:IsTalent() then
			table.insert(talents, ability:GetName())
		end
	end
	
	local SkillPoints = {
	abilities[2], -- Level 1
	abilities[3], -- Level 2
	abilities[2], -- Level 3
	abilities[3], -- Level 4
	abilities[2], -- Level 5
	abilities[4], -- Level 6
	abilities[2], -- Level 7
	abilities[1], -- Level 8
	abilities[1], -- Level 9
	abilities[1], -- Level 10
	abilities[1], -- Level 11
	abilities[4], -- Level 12
	talents[1],   -- Level 13
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

	if PRoles.GetPRole(bot, bot:GetUnitName()) == "SafeLane" then
		ItemBuild = { 
		"item_blight_stone",
	
		"item_wraith_band",
		"item_power_treads",
		"item_magic_wand",
	
		"item_medallion_of_courage",
		"item_solar_crest",
		"item_desolator",
		"item_nullifier",
		"item_greater_crit",
		"item_sheepstick",
		}
	end
	
	if PRoles.GetPRole(bot, bot:GetUnitName()) == "MidLane" then
		ItemBuild = { 
		"item_faerie_fire",
		"item_blight_stone",
	
		"item_wraith_band",
		"item_power_treads",
		"item_magic_wand",
	
		"item_medallion_of_courage",
		"item_solar_crest",
		"item_desolator",
		"item_nullifier",
		"item_greater_crit",
		"item_sheepstick",
		}
	end
	
	return ItemBuild
end

return X