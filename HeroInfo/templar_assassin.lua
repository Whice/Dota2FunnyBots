X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local Refraction = bot:GetAbilityByName("templar_assassin_refraction")
local Meld = bot:GetAbilityByName("templar_assassin_meld")
local PsiBlades = bot:GetAbilityByName("templar_assassin_psi_blades")
local PsionicTrap = bot:GetAbilityByName("templar_assassin_psionic_trap")

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, Refraction:GetName())
	table.insert(abilities, Meld:GetName())
	table.insert(abilities, PsiBlades:GetName())
	table.insert(abilities, PsionicTrap:GetName())
	
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
	abilities[3], -- Level 4
	abilities[1], -- Level 5
	abilities[4], -- Level 6
	abilities[1], -- Level 7
	abilities[2], -- Level 8
	abilities[2], -- Level 9
	talents[1],   -- Level 10
	abilities[2], -- Level 11
	abilities[2], -- Level 12
	abilities[4], -- Level 13
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

	if PRoles.GetPRole(bot, bot:GetUnitName()) == "SafeLane" then
		local SituationalItem1 = PRoles.ShouldBuyMKB("item_greater_crit")
		
		ItemBuild = { 
		"item_wraith_band",
		"item_magic_wand",
		"item_power_treads",
		
		"item_dragon_lance",
		"item_desolator",
		"item_blink",
		"item_black_king_bar",
		SituationalItem1,
		"item_swift_blink",
		}
	end
	
	if PRoles.GetPRole(bot, bot:GetUnitName()) == "MidLane" then
		local SituationalItem1 = PRoles.ShouldBuyMKB("item_greater_crit")
		
		ItemBuild = { 
		"item_wraith_band",
		"item_magic_wand",
		"item_power_treads",
		
		"item_dragon_lance",
		"item_desolator",
		"item_blink",
		"item_black_king_bar",
		SituationalItem1,
		"item_swift_blink",
		}
	end
	
	return ItemBuild
end

return X