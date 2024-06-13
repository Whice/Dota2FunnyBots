X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local EtherShock = bot:GetAbilityByName("shadow_shaman_ether_shock")
local Voodoo = bot:GetAbilityByName("shadow_shaman_voodoo")
local Shackles = bot:GetAbilityByName("shadow_shaman_shackles")
local MassSerpentWard = bot:GetAbilityByName("shadow_shaman_mass_serpent_ward")

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, EtherShock:GetName())
	table.insert(abilities, Voodoo:GetName())
	table.insert(abilities, Shackles:GetName())
	table.insert(abilities, MassSerpentWard:GetName())
	
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
	abilities[3], -- Level 5
	abilities[4], -- Level 6
	abilities[2], -- Level 7
	abilities[2], -- Level 8
	abilities[2], -- Level 9
	talents[2],   -- Level 10
	abilities[3], -- Level 11
	abilities[4], -- Level 12
	abilities[3], -- Level 13
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
	talents[8],   -- Level 25
	"NoLevel",    -- Level 26
	talents[1],   -- Level 27
	talents[3],   -- Level 28
	talents[6],   -- Level 29
	talents[7]    -- Level 30
	}
	
	return SkillPoints
end

function X.GetHeroItemBuild()
	local ItemBuild

	if PRoles.GetPRole(bot, bot:GetUnitName()) == "SoftSupport" then
		ItemBuild = { 
		--"item_null_talisman",
		"item_magic_wand",
		"item_tranquil_boots",
		
		"item_solar_crest",
		"item_blink",
		"item_force_staff",
		"item_aether_lens",
		"item_black_king_bar",
		"item_ultimate_scepter_2",
		"item_boots_of_bearing",
		}
	end
	
	if PRoles.GetPRole(bot, bot:GetUnitName()) == "HardSupport" then
		ItemBuild = { 
		--"item_null_talisman",
		"item_magic_wand",
		"item_arcane_boots",
		
		"item_urn_of_shadows",
		"item_blink",
		"item_glimmer_cape",
		"item_spirit_vessel",
		"item_aether_lens",
		"item_black_king_bar",
		"item_ultimate_scepter_2",
		"item_guardian_greaves",
		}
	end
	
	return ItemBuild
end

return X