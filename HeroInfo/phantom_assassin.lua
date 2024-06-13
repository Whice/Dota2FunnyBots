X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local StiflingDagger = bot:GetAbilityByName("phantom_assassin_stifling_dagger")
local PhantomStrike = bot:GetAbilityByName("phantom_assassin_phantom_strike")
local Blur = bot:GetAbilityByName("phantom_assassin_blur")
local CoupDeGrace = bot:GetAbilityByName("phantom_assassin_coup_de_grace")
local FanOfKnives = bot:GetAbilityByName("phantom_assassin_fan_of_knives")

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, StiflingDagger:GetName())
	table.insert(abilities, PhantomStrike:GetName())
	table.insert(abilities, Blur:GetName())
	table.insert(abilities, CoupDeGrace:GetName())
	
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
	talents[4],   -- Level 15
	abilities[3], -- Level 16
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

	if PRoles.GetPRole(bot, bot:GetUnitName()) == "SafeLane" then
		ItemBuild = { 
		"item_quelling_blade",
	
		"item_wraith_band",
		"item_magic_wand",
		"item_cornucopia",
		"item_power_treads",
	
		"item_bfury",
		"item_desolator",
		"item_black_king_bar",
		"item_satanic",
		"item_abyssal_blade",
		"item_ultimate_scepter_2"
		}
	end
	
	return ItemBuild
end

return X