X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local MirrorImage = bot:GetAbilityByName("naga_siren_mirror_image")
local Ensnare = bot:GetAbilityByName("naga_siren_ensnare")
local Riptide = bot:GetAbilityByName("naga_siren_rip_tide")
local SongOfTheSiren = bot:GetAbilityByName("naga_siren_song_of_the_siren")

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, MirrorImage:GetName())
	table.insert(abilities, Ensnare:GetName())
	table.insert(abilities, Riptide:GetName())
	table.insert(abilities, SongOfTheSiren:GetName())
	
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
	abilities[3], -- Level 6
	abilities[1], -- Level 7
	abilities[3], -- Level 8
	abilities[4], -- Level 9
	talents[1],   -- Level 10
	abilities[2], -- Level 11
	abilities[4], -- Level 12
	abilities[2], -- Level 13
	abilities[2], -- Level 14
	talents[4],   -- Level 15
	abilities[2], -- Level 16
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
	talents[3],   -- Level 28
	talents[5],   -- Level 29
	talents[8]    -- Level 30
	}
	
	return SkillPoints
end

function X.GetHeroItemBuild()
	local ItemBuild

	if PRoles.GetPRole(bot, bot:GetUnitName()) == "SafeLane" then
		local SituationalItem1 = PRoles.ShouldBuySilverEdge("item_butterfly")
		
		ItemBuild = { 
		"item_quelling_blade",
	
		"item_wraith_band",
		"item_magic_wand",
		"item_power_treads",
	
		"item_manta",
		"item_orchid",
		"item_heart",
		"item_bloodthorn",
		SituationalItem1,
		"item_skadi",
		"item_ultimate_scepter_2",
		}
	end
	
	return ItemBuild
end

return X