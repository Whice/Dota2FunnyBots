X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local StaticRemnant = bot:GetAbilityByName("storm_spirit_static_remnant")
local ElectricVortex = bot:GetAbilityByName("storm_spirit_electric_vortex")
local Overload = bot:GetAbilityByName("storm_spirit_overload")
local BallLightning = bot:GetAbilityByName("storm_spirit_ball_lightning")

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, StaticRemnant:GetName())
	table.insert(abilities, ElectricVortex:GetName())
	table.insert(abilities, Overload:GetName())
	table.insert(abilities, BallLightning:GetName())
	
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
	abilities[1], -- Level 4
	abilities[3], -- Level 5
	abilities[4], -- Level 6
	abilities[1], -- Level 7
	abilities[1], -- Level 8
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
	talents[5],   -- Level 20
	"NoLevel",    -- Level 21
	"NoLevel",    -- Level 22
	"NoLevel",    -- Level 23
	"NoLevel",    -- Level 24
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
		local SituationalItem1 = PRoles.ShouldBuySphere("item_eternal_shroud")
		
		ItemBuild = { 
		"item_null_talisman",
		"item_magic_wand",
		"item_soul_ring",
		"item_power_treads",
		
		"item_witch_blade",
		SituationalItem1,
		"item_kaya_and_sange",
		"item_black_king_bar",
		"item_shivas_guard",
		"item_devastator",
		"item_ultimate_scepter_2",
		}
	end
	
	return ItemBuild
end

return X