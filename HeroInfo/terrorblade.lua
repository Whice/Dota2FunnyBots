X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local Reflection = bot:GetAbilityByName("terrorblade_reflection")
local ConjureImage = bot:GetAbilityByName("terrorblade_conjure_image")
local Metamorphosis = bot:GetAbilityByName("terrorblade_metamorphosis")
local Sunder = bot:GetAbilityByName("terrorblade_sunder")
local DemonZeal = bot:GetAbilityByName("terrorblade_demon_zeal")

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, Reflection:GetName())
	table.insert(abilities, ConjureImage:GetName())
	table.insert(abilities, Metamorphosis:GetName())
	table.insert(abilities, Sunder:GetName())
	
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
	abilities[2], -- Level 3
	abilities[2], -- Level 4
	abilities[3], -- Level 5
	abilities[2], -- Level 6
	abilities[4], -- Level 7
	abilities[2], -- Level 8
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
	
		"item_dragon_lance",
		"item_manta",
		"item_butterfly",
		"item_skadi",
		"item_black_king_bar",
		}
	end
	
	return ItemBuild
end

return X