X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local StickyNapalm = bot:GetAbilityByName("batrider_sticky_napalm")
local Flamebreak = bot:GetAbilityByName("batrider_flamebreak")
local Firefly = bot:GetAbilityByName("batrider_firefly")
local FlamingLasso = bot:GetAbilityByName("batrider_flaming_lasso")

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, StickyNapalm:GetName())
	table.insert(abilities, Flamebreak:GetName())
	table.insert(abilities, Firefly:GetName())
	table.insert(abilities, FlamingLasso:GetName())
	
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
	abilities[3], -- Level 5
	abilities[4], -- Level 6
	abilities[3], -- Level 7
	abilities[1], -- Level 8
	abilities[1], -- Level 9
	talents[2],   -- Level 10
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
		local SituationalItem1 = PRoles.ShouldBuySphere("item_shivas_guard")
		
		ItemBuild = { 
		"item_null_talisman",
		"item_magic_wand",
		"item_travel_boots",
		
		"item_blink",
		SituationalItem1,
		"item_black_king_bar",
		"item_octarine_core",
		"item_sheepstick",
		"item_overwhelming_blink",
		"item_ultimate_scepter_2",
		"item_travel_boots_2",
		}
	end

	if PRoles.GetPRole(bot, bot:GetUnitName()) == "OffLane" then
		local CoreItem = PRoles.GetAOEItem()
		
		ItemBuild = { 
		"item_null_talisman",
		"item_magic_wand",
		"item_travel_boots",
		
		CoreItem,
		"item_blink",
		"item_black_king_bar",
		"item_octarine_core",
		"item_assault",
		"item_overwhelming_blink",
		"item_ultimate_scepter_2",
		"item_travel_boots_2",
		}
	end
	
	return ItemBuild
end

return X