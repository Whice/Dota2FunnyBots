X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local ArcLightning = bot:GetAbilityByName("zuus_arc_lightning")
local LightningBolt = bot:GetAbilityByName("zuus_lightning_bolt")
local HeavenlyJump = bot:GetAbilityByName("zuus_heavenly_jump")
local ThundergodsWrath = bot:GetAbilityByName("zuus_thundergods_wrath")
local Nimbus = bot:GetAbilityByName("zuus_cloud")

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, ArcLightning:GetName())
	table.insert(abilities, LightningBolt:GetName())
	table.insert(abilities, HeavenlyJump:GetName())
	table.insert(abilities, ThundergodsWrath:GetName())
	
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
	abilities[2], -- Level 4
	abilities[1], -- Level 5
	abilities[4], -- Level 6
	abilities[1], -- Level 7
	abilities[2], -- Level 8
	abilities[2], -- Level 9
	talents[1],   -- Level 10
	abilities[2], -- Level 11
	abilities[4], -- Level 12
	abilities[3], -- Level 13
	abilities[3], -- Level 14
	talents[3],   -- Level 15
	abilities[3], -- Level 16
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
	talents[2],   -- Level 27
	talents[4],   -- Level 28
	talents[6],   -- Level 29
	talents[8]    -- Level 30
	}
	
	return SkillPoints
end

function X.GetHeroItemBuild()
	local ItemBuild

	if PRoles.GetPRole(bot, bot:GetUnitName()) == "MidLane" then
		ItemBuild = { 
		"item_null_talisman",
		"item_magic_wand",
		"item_arcane_boots",
		
		"item_phylactery",
		"item_manta",
		"item_octarine_core",
		"item_kaya_and_sange",
		"item_angels_demise",
		"item_wind_waker",
		"item_ultimate_scepter_2",
		}
	end
	
	if PRoles.GetPRole(bot, bot:GetUnitName()) == "SafeLane" then
		ItemBuild = { 
		"item_null_talisman",
		"item_magic_wand",
		"item_power_treads",
		
		"item_phylactery",
		"item_manta",
		"item_hurricane_pike",
		"item_kaya_and_sange",
		"item_moon_shard",
		"item_wind_waker",
		"item_angels_demise",
		"item_ultimate_scepter_2",
		}
	end
	
	return ItemBuild
end

return X