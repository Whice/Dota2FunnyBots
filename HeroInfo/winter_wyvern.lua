X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local ArcticBurn = bot:GetAbilityByName("winter_wyvern_arctic_burn")
local SplinterBlast = bot:GetAbilityByName("winter_wyvern_splinter_blast")
local ColdEmbrace = bot:GetAbilityByName("winter_wyvern_cold_embrace")
local WintersCurse = bot:GetAbilityByName("winter_wyvern_winters_curse")

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, ArcticBurn:GetName())
	table.insert(abilities, SplinterBlast:GetName())
	table.insert(abilities, ColdEmbrace:GetName())
	table.insert(abilities, WintersCurse:GetName())
	
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
	abilities[2], -- Level 3
	abilities[2], -- Level 4
	abilities[2], -- Level 5
	abilities[4], -- Level 6
	abilities[2], -- Level 7
	abilities[3], -- Level 8
	abilities[3], -- Level 9
	talents[1],   -- Level 10
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
	talents[2],   -- Level 27
	talents[4],   -- Level 28
	talents[5],   -- Level 29
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
		"item_holy_locket",
		
		"item_solar_crest",
		"item_force_staff",
		"item_aether_lens",
		"item_aeon_disk",
		"item_boots_of_bearing",
		}
	end
	
	if PRoles.GetPRole(bot, bot:GetUnitName()) == "HardSupport" then
		ItemBuild = { 
		--"item_null_talisman",
		"item_magic_wand",
		"item_arcane_boots",
		"item_holy_locket",
		
		"item_urn_of_shadows",
		"item_glimmer_cape",
		"item_spirit_vessel",
		"item_aether_lens",
		"item_aeon_disk",
		"item_guardian_greaves",
		}
	end
	
	return ItemBuild
end

return X