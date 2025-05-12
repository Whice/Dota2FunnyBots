X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

--local TameTheBeasts = bot:GetAbilityByName("ringmaster_tame_the_beasts")
local EscapeAct = bot:GetAbilityByName("ringmaster_the_box")
local ImpalementArts = bot:GetAbilityByName("ringmaster_impalement")
local WheelOfWonder = bot:GetAbilityByName("ringmaster_wheel")

function X.GetHeroLevelPoints()
	local abilities = {}
	
	local TameTheBeasts = bot:GetAbilityInSlot(0)
	
	table.insert(abilities, TameTheBeasts:GetName())
	table.insert(abilities, EscapeAct:GetName())
	table.insert(abilities, ImpalementArts:GetName())
	table.insert(abilities, WheelOfWonder:GetName())
	
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
	abilities[4], -- Level 6
	abilities[3], -- Level 7
	abilities[2], -- Level 8
	abilities[1], -- Level 9
	talents[2],   -- Level 10
	abilities[1], -- Level 11
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
	talents[7],   -- Level 25
	"NoLevel",    -- Level 26
	talents[1],   -- Level 27
	talents[3],   -- Level 28
	talents[5],   -- Level 29
	talents[8]    -- Level 30
	}
	
	return SkillPoints
end

function X.GetHeroItemBuild()
	local ItemBuild
	
	local SupportBoots = PRoles.GetSupportBoots(bot)
	local SupportUtility = PRoles.GetSupportUtilityItem(bot)
	
	local CoreItems = {
		"item_magic_wand",
		SupportBoots,
		
		SupportUtility,
		"item_aether_lens",
	}
	
	local LuxuryItems = {
		"item_cyclone",
		"item_ultimate_scepter",
		"item_sheepstick",
		"item_ultimate_scepter_2",
	}
	
	ItemBuild = PRoles.CreateSupportBuild(bot, CoreItems, LuxuryItems, 2)
	
	return ItemBuild
end

return X