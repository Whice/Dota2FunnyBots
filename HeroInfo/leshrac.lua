X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local SplitEarth = bot:GetAbilityByName("leshrac_split_earth")
local DiabolicEdict = bot:GetAbilityByName("leshrac_diabolic_edict")
local LightningStorm = bot:GetAbilityByName("leshrac_lightning_storm")
local PulseNova = bot:GetAbilityByName("leshrac_pulse_nova")

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, SplitEarth:GetName())
	table.insert(abilities, DiabolicEdict:GetName())
	table.insert(abilities, LightningStorm:GetName())
	table.insert(abilities, PulseNova:GetName())
	
	local talents = {}
	
	for i = 0, 25 do
		local ability = bot:GetAbilityInSlot(i)
		if ability ~= nil and ability:IsTalent() then
			table.insert(talents, ability:GetName())
		end
	end
	
	local SkillPoints = {
	abilities[3], -- Level 1
	abilities[2], -- Level 2
	abilities[3], -- Level 3
	abilities[2], -- Level 4
	abilities[2], -- Level 5
	abilities[4], -- Level 6
	abilities[2], -- Level 7
	abilities[1], -- Level 8
	abilities[1], -- Level 9
	abilities[1], -- Level 10
	abilities[1], -- Level 11
	abilities[4], -- Level 12
	abilities[3], -- Level 13
	abilities[3], -- Level 14
	talents[2],   -- Level 15
	talents[4],   -- Level 16
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

	if PRoles.GetPRole(bot, bot:GetUnitName()) == "MidLane" then
		local SituationalItem1 = PRoles.ShouldBuySphere("item_shivas_guard")
		
		ItemBuild = { 
		"item_bottle",
		"item_null_talisman",
		"item_magic_wand",
		"item_arcane_boots",
		
		"item_blink",
		"item_kaya",
		"item_bloodstone",
		"item_kaya_and_sange",
		"item_black_king_bar",
		"item_ultimate_scepter_2",
		SituationalItem1,
		"item_overwhelming_blink",
		}
	end
	
	return ItemBuild
end

return X