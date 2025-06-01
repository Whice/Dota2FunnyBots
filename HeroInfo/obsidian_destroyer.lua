X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local ArcaneOrb = bot:GetAbilityByName("obsidian_destroyer_arcane_orb")
local AstralImprisonment = bot:GetAbilityByName("obsidian_destroyer_astral_imprisonment")
local EssenceAura = bot:GetAbilityByName("obsidian_destroyer_equilibrium")
local SanityEclipse = bot:GetAbilityByName("obsidian_destroyer_sanity_eclipse")

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, ArcaneOrb:GetName())
	table.insert(abilities, AstralImprisonment:GetName())
	table.insert(abilities, EssenceAura:GetName())
	table.insert(abilities, SanityEclipse:GetName())
	
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
	abilities[1], -- Level 8
	abilities[1], -- Level 9
	talents[2],   -- Level 10
	abilities[1], -- Level 11
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
	talents[1],   -- Level 27
	talents[3],   -- Level 28
	talents[5],   -- Level 29
	talents[7]    -- Level 30
	}
	
	return SkillPoints
end

function X.GetHeroItemBuild()
	local ItemBuild

	if PRoles.GetPRole(bot, bot:GetUnitName()) == "MidLane" then
		local SituationalItem1 = PRoles.ShouldBuySphere("item_sheepstick")
		
		ItemBuild = { 
		"item_bottle",
		"item_null_talisman",
		"item_magic_wand",
		"item_power_treads",
		
		"item_witch_blade",
		"item_hurricane_pike",
		"item_blink",
		"item_black_king_bar",
		"item_ultimate_scepter_2",
		SituationalItem1,
		"item_devastator",
		"item_arcane_blink",
		}
	end
	
	return ItemBuild
end

return X