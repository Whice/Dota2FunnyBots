X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local Quas = bot:GetAbilityByName("invoker_quas")
local Wex = bot:GetAbilityByName("invoker_wex")
local Exort = bot:GetAbilityByName("invoker_exort")
local Invoke = bot:GetAbilityByName("invoker_invoke")

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, Quas:GetName())
	table.insert(abilities, Wex:GetName())
	table.insert(abilities, Exort:GetName())
	
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
	abilities[3], -- Level 3
	abilities[1], -- Level 4
	abilities[3], -- Level 5
	abilities[1], -- Level 6
	abilities[3], -- Level 7
	abilities[1], -- Level 8
	abilities[3], -- Level 9
	abilities[2], -- Level 10
	abilities[3], -- Level 11
	abilities[2], -- Level 12
	abilities[3], -- Level 13
	abilities[2], -- Level 14
	abilities[2], -- Level 15
	abilities[2], -- Level 16
	abilities[2], -- Level 17
	abilities[2], -- Level 18
	abilities[1], -- Level 19
	talents[2],   -- Level 20
	talents[3],   -- Level 21
	talents[5],   -- Level 22
	abilities[1], -- Level 23
	abilities[1], -- Level 24
	talents[7],   -- Level 25
	"NoLevel",    -- Level 26
	talents[1],   -- Level 27
	talents[4],   -- Level 28
	talents[6],   -- Level 29
	talents[8]    -- Level 30
	}
	
	return SkillPoints
end

function X.GetHeroItemBuild()
	local ItemBuild

	if PRoles.GetPRole(bot, bot:GetUnitName()) == "MidLane" then
		local SituationalItem1 = PRoles.ShouldBuySphere("item_shivas_guard")
		
		ItemBuild = { 
		"item_bottle",
		"item_null_talisman",
		"item_magic_wand",
		"item_boots",
		
		"item_hand_of_midas",
		"item_rod_of_atos",
		"item_travel_boots",
		
		"item_ultimate_scepter",
		"item_black_king_bar",
		"item_gungir",
		"item_sheepstick",
		"item_octarine_core",
		"item_ultimate_scepter_2",
		"item_sphere",
		}
	end
	
	return ItemBuild
end

return X