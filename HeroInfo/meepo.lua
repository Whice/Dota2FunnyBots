X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local Earthbind = bot:GetAbilityByName("meepo_earthbind")
local Poof = bot:GetAbilityByName("meepo_poof")
local Ransack = bot:GetAbilityByName("meepo_ransack")
local DividedWeStand = bot:GetAbilityByName("meepo_divided_we_stand")
local Dig = bot:GetAbilityByName("meepo_petrify")

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, Earthbind:GetName())
	table.insert(abilities, Poof:GetName())
	table.insert(abilities, Ransack:GetName())
	table.insert(abilities, DividedWeStand:GetName())
	
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
	abilities[4], -- Level 3
	abilities[2], -- Level 4
	abilities[2], -- Level 5
	abilities[1], -- Level 6
	abilities[2], -- Level 7
	abilities[1], -- Level 8
	abilities[3], -- Level 9
	abilities[4], -- Level 10
	talents[1],   -- Level 11
	abilities[3], -- Level 12
	abilities[3], -- Level 13
	abilities[1], -- Level 14
	talents[4],   -- Level 15
	abilities[1], -- Level 16
	abilities[4], -- Level 17
	abilities[4], -- Level 18
	"NoLevel",    -- Level 19
	talents[6],   -- Level 20
	"NoLevel",    -- Level 21
	"NoLevel",    -- Level 22
	"NoLevel",    -- Level 23
	abilities[4], -- Level 24
	talents[8],   -- Level 25
	"NoLevel",    -- Level 26
	talents[2],   -- Level 27
	talents[3],   -- Level 28
	talents[5],   -- Level 29
	talents[7]    -- Level 30
	}
	
	return SkillPoints
end

function X.GetHeroItemBuild()
	local ItemBuild

	if PRoles.GetPRole(bot, bot:GetUnitName()) == "SafeLane" then
		ItemBuild = { 
		"item_quelling_blade",
	
		"item_wraith_band",
		"item_magic_wand",
		"item_power_treads",
	
		"item_diffusal_blade",
		"item_blink",
		"item_disperser",
		"item_skadi",
		"item_swift_blink",
		"item_sheepstick",
		"item_nullifier",
		}
	end
	
	if PRoles.GetPRole(bot, bot:GetUnitName()) == "MidLane" then
		ItemBuild = { 
		"item_quelling_blade",
	
		"item_wraith_band",
		"item_magic_wand",
		"item_power_treads",
	
		"item_diffusal_blade",
		"item_blink",
		"item_disperser",
		"item_skadi",
		"item_swift_blink",
		"item_sheepstick",
		"item_nullifier",
		}
	end
	
	return ItemBuild
end

return X