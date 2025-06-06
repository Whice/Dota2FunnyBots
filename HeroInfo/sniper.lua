X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local Shrapnel = bot:GetAbilityByName("sniper_shrapnel")
local Headshot = bot:GetAbilityByName("sniper_headshot")
local TakeAim = bot:GetAbilityByName("sniper_take_aim")
local Assassinate = bot:GetAbilityByName("sniper_assassinate")
local ConcussiveGrenade = bot:GetAbilityByName("sniper_concussive_grenade")

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, Shrapnel:GetName())
	table.insert(abilities, Headshot:GetName())
	table.insert(abilities, TakeAim:GetName())
	table.insert(abilities, Assassinate:GetName())
	
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
	abilities[1], -- Level 3
	abilities[3], -- Level 4
	abilities[1], -- Level 5
	abilities[4], -- Level 6
	abilities[1], -- Level 7
	abilities[3], -- Level 8
	abilities[3], -- Level 9
	talents[2],   -- Level 10
	abilities[3], -- Level 11
	abilities[4], -- Level 12
	abilities[2], -- Level 13
	abilities[2], -- Level 14
	talents[3],   -- Level 15
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
	talents[4],   -- Level 28
	talents[5],   -- Level 29
	talents[7]    -- Level 30
	}
	
	return SkillPoints
end

function X.GetHeroItemBuild()
	local ItemBuild

	if PRoles.GetPRole(bot, bot:GetUnitName()) == "SafeLane" then
		local SituationalItem1 = PRoles.ShouldBuySilverEdge("item_greater_crit")
		local SituationalItem2 = PRoles.ShouldBuyMKB("item_skadi")
		
		ItemBuild = { 
		"item_wraith_band",
		"item_magic_wand",
		"item_power_treads",
	
		"item_dragon_lance",
		"item_maelstrom",
		"item_black_king_bar",
		"item_hurricane_pike",
		SituationalItem1,
		SituationalItem2,
		}
	end
	
	if PRoles.GetPRole(bot, bot:GetUnitName()) == "MidLane" then
		local SituationalItem1 = PRoles.ShouldBuySilverEdge("item_greater_crit")
		
		ItemBuild = { 
		"item_wraith_band",
		"item_magic_wand",
		"item_power_treads",
	
		"item_dragon_lance",
		"item_maelstrom",
		"item_black_king_bar",
		"item_hurricane_pike",
		SituationalItem1,
		"item_monkey_king_bar",
		}
	end
	
	return ItemBuild
end

return X