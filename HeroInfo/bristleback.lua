X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local ViscousNasalGoo = bot:GetAbilityByName("bristleback_viscous_nasal_goo")
local QuillSpray = bot:GetAbilityByName("bristleback_quill_spray")
local Bristleback = bot:GetAbilityByName("bristleback_bristleback")
local Warpath = bot:GetAbilityByName("bristleback_warpath")
local Hairball = bot:GetAbilityByName("bristleback_hairball")

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, ViscousNasalGoo:GetName())
	table.insert(abilities, QuillSpray:GetName())
	table.insert(abilities, Bristleback:GetName())
	table.insert(abilities, Warpath:GetName())
	
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

	if PRoles.GetPRole(bot, bot:GetUnitName()) == "OffLane" then
		local CoreItem = PRoles.GetAOEItem()
	
		ItemBuild = { 
		"item_quelling_blade",

		"item_bracer",
		"item_magic_wand",
		"item_arcane_boots",
		
		CoreItem,
		"item_ultimate_scepter",
		"item_bloodstone",
		"item_black_king_bar",
		"item_kaya_and_sange",
		"item_ultimate_scepter_2",
		"item_assault",
		}
	end
	
	return ItemBuild
end

return X