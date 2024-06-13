X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local SpiritLance = bot:GetAbilityByName("phantom_lancer_spirit_lance")
local DoppelGanger = bot:GetAbilityByName("phantom_lancer_doppelwalk")
local PhantomRush = bot:GetAbilityByName("phantom_lancer_phantom_edge")
local Juxtapose = bot:GetAbilityByName("phantom_lancer_juxtapose")

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, SpiritLance:GetName())
	table.insert(abilities, DoppelGanger:GetName())
	table.insert(abilities, PhantomRush:GetName())
	table.insert(abilities, Juxtapose:GetName())
	
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
	abilities[3], -- Level 4
	abilities[3], -- Level 5
	abilities[4], -- Level 6
	abilities[3], -- Level 7
	abilities[2], -- Level 8
	abilities[2], -- Level 9
	talents[2],   -- Level 10
	abilities[2], -- Level 11
	abilities[4], -- Level 12
	abilities[1], -- Level 13
	abilities[1], -- Level 14
	talents[3],   -- Level 15
	abilities[1], -- Level 16
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

	if PRoles.GetPRole(bot, bot:GetUnitName()) == "SafeLane" then
		ItemBuild = { 
		"item_quelling_blade",
	
		"item_wraith_band",
		"item_magic_wand",
		"item_power_treads",
	
		"item_ultimate_scepter",
		"item_diffusal_blade",
		"item_manta",
		"item_heart",
		"item_skadi",
		"item_ultimate_scepter_2",
		"item_bloodthorn",
		"item_disperser",
		}
	end
	
	return ItemBuild
end

return X