X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local AcidSpray = bot:GetAbilityByName("alchemist_acid_spray")
local UnstableConcoction = bot:GetAbilityByName("alchemist_unstable_concoction")
local CorrosiveWeaponry = bot:GetAbilityByName("alchemist_corrosive_weaponry")
local ChemicalRage = bot:GetAbilityByName("alchemist_chemical_rage")
local UnstableConcoctionThrow = bot:GetAbilityByName("alchemist_unstable_concoction_throw")

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, AcidSpray:GetName())
	if bot:HasModifier("modifier_alchemist_unstable_concoction") then
		table.insert(abilities, UnstableConcoctionThrow:GetName())
	else
		table.insert(abilities, UnstableConcoction:GetName())
	end
	table.insert(abilities, CorrosiveWeaponry:GetName())
	table.insert(abilities, ChemicalRage:GetName())
	
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
	abilities[2], -- Level 3
	abilities[1], -- Level 4
	abilities[1], -- Level 5
	abilities[4], -- Level 6
	abilities[1], -- Level 7
	abilities[2], -- Level 8
	abilities[2], -- Level 9
	talents[1],   -- Level 10
	abilities[3], -- Level 11
	abilities[4], -- Level 12
	abilities[3], -- Level 13
	abilities[3], -- Level 14
	talents[3],   -- Level 15
	abilities[3], -- Level 16
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
	talents[4],   -- Level 28
	talents[6],   -- Level 29
	talents[8]    -- Level 30
	}
	
	return SkillPoints
end

function X.GetHeroItemBuild()
	local ItemBuild
	
	if PRoles.GetPRole(bot, bot:GetUnitName()) == "SafeLane" then
		local SituationalItem1 = PRoles.ShouldBuySilverEdge("item_bloodthorn")
		local SituationalItem2 = PRoles.ShouldBuyMKB("item_abyssal_blade")
		
		ItemBuild = { 
		"item_quelling_blade",
	
		"item_bracer",
		"item_magic_wand",
		"item_power_treads",
		
		"item_radiance",
		"item_sange_and_yasha",
		"item_black_king_bar",
		"item_blink",
		SituationalItem1,
		
		SituationalItem2,
		"item_overwhelming_blink",
		}
	end
	
	return ItemBuild
end

return X