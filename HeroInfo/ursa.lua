X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local Earthshock = bot:GetAbilityByName("ursa_earthshock")
local Overpower = bot:GetAbilityByName("ursa_overpower")
local FurySwipes = bot:GetAbilityByName("ursa_fury_swipes")
local Enrage = bot:GetAbilityByName("ursa_enrage")

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, Earthshock:GetName())
	table.insert(abilities, Overpower:GetName())
	table.insert(abilities, FurySwipes:GetName())
	table.insert(abilities, Enrage:GetName())
	
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
	abilities[2], -- Level 4
	abilities[3], -- Level 5
	abilities[4], -- Level 6
	abilities[3], -- Level 7
	abilities[2], -- Level 8
	abilities[2], -- Level 9
	talents[1],   -- Level 10
	abilities[2], -- Level 11
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
	talents[7],   -- Level 25
	"NoLevel",    -- Level 26
	talents[2],   -- Level 27
	talents[4],   -- Level 28
	talents[5],   -- Level 29
	talents[8]    -- Level 30
	}
	
	return SkillPoints
end

function X.GetHeroItemBuild()
	local ItemBuild

	if PRoles.GetPRole(bot, bot:GetUnitName()) == "SafeLane" then
		local SituationalItem1 = PRoles.ShouldBuySilverEdge("item_abyssal_blade")
		local SituationalItem2 = PRoles.ShouldBuyMKB("item_nullifier")
		local SituationalItem3 = PRoles.ShouldBuySphere("item_satanic")
		
		ItemBuild = { 
		"item_quelling_blade",
	
		"item_wraith_band",
		"item_magic_wand",
		"item_phase_boots",
		"item_cornucopia",
	
		"item_bfury",
		"item_blink",
		"item_black_king_bar",
		SituationalItem1,
		SituationalItem2,
		SituationalItem3,
		"item_swift_blink",
		}
	end
	
	return ItemBuild
end

return X