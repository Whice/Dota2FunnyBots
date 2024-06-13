X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local Vacuum = bot:GetAbilityByName("dark_seer_vacuum")
local IonShell = bot:GetAbilityByName("dark_seer_ion_shell")
local Surge = bot:GetAbilityByName("dark_seer_surge")
local WallOfReplica = bot:GetAbilityByName("dark_seer_wall_of_replica")

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, Vacuum:GetName())
	table.insert(abilities, IonShell:GetName())
	table.insert(abilities, Surge:GetName())
	table.insert(abilities, WallOfReplica:GetName())
	
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
	abilities[1], -- Level 4
	abilities[2], -- Level 5
	abilities[4], -- Level 6
	abilities[2], -- Level 7
	abilities[3], -- Level 8
	abilities[3], -- Level 9
	abilities[3], -- Level 10
	abilities[1], -- Level 11
	abilities[4], -- Level 12
	abilities[1], -- Level 13
	abilities[1], -- Level 14
	talents[1],   -- Level 15
	talents[3],   -- Level 16
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

	if PRoles.GetPRole(bot, bot:GetUnitName()) == "OffLane" then
		ItemBuild = { 
		"item_null_talisman",
		"item_magic_wand",
		"item_arcane_boots",
		"item_soul_ring",
		
		"items_offlane_blink",
		"item_ultimate_scepter_2",
		}
	end
	
	return ItemBuild
end

return X