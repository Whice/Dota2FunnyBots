X = {}
local bot = GetBot()
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

local ViscousNasalGoo = bot:GetAbilityByName("bristleback_viscous_nasal_goo")
local QuillSpray = bot:GetAbilityByName("bristleback_quill_spray")
local Bristleback = bot:GetAbilityByName("bristleback_bristleback")
local Warpath = bot:GetAbilityByName("bristleback_warpath")
local Hairball = bot:GetAbilityByName("bristleback_hairball")

local ViscousNasalGooDesire = 0
local QuillSprayDesire = 0
local HairballDesire = 0

local AttackRange
local manathreshold

function X.GetHeroLevelPoints()
	local abilities = {}
	
	table.insert(abilities, ViscousNasalGoo:GetName())
	table.insert(abilities, QuillSpray:GetName())
	table.insert(abilities, Bristleback:GetName())
	table.insert(abilities, Warpath:GetName())
	
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
	abilities[3], -- Level 4
	abilities[2], -- Level 5
	abilities[4], -- Level 6
	abilities[2], -- Level 7
	abilities[1], -- Level 8
	abilities[3], -- Level 9
	talents[2],   -- Level 10
	abilities[3], -- Level 11
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

	if PRoles.GetPRole(bot, bot:GetUnitName()) == "OffLane" then
		local CoreItem = PRoles.GetAOEItem()
	
		ItemBuild = { 
		"item_quelling_blade",

		"item_bracer",
		"item_magic_wand",
		"item_arcane_boots",
		
		CoreItem,
		"item_ultimate_scepter",
		"item_eternal_shroud",
		"item_bloodstone",
		"item_black_king_bar",
		"item_ultimate_scepter_2",
		"item_assault",
		}
	end
	
	return ItemBuild
end

function X.UseAbilities()
	AttackRange = bot:GetAttackRange()

	manathreshold = (bot:GetMaxMana() * 0.4)
	
	-- The order to use abilities in
	HairballDesire, HairballTarget = UseHairball()
	if HairballDesire > 0 then
		bot:Action_UseAbilityOnLocation(Hairball, HairballTarget)
		return
	end
	
	if bot:HasScepter() then
		ViscousNasalGooDesire = UseViscousNasalGoo()
		if ViscousNasalGooDesire > 0 then
			bot:Action_UseAbility(ViscousNasalGoo)
			return
		end
	else
		ViscousNasalGooDesire, ViscousNasalGooTarget = UseViscousNasalGoo()
		if ViscousNasalGooDesire > 0 then
			bot:Action_UseAbilityOnEntity(ViscousNasalGoo, ViscousNasalGooTarget)
			return
		end
	end
	
	QuillSprayDesire = UseQuillSpray()
	if QuillSprayDesire > 0 then
		bot:Action_UseAbility(QuillSpray)
		return
	end
end

function UseViscousNasalGoo()
	if not ViscousNasalGoo:IsFullyCastable() then return 0 end
	if not P.IsInCombativeMode(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = ViscousNasalGoo:GetCastRange()
	
	local enemies = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local target = P.GetWeakestNonImmuneEnemyHero(enemies)
	
	if target ~= nil then
		if bot:HasScepter() then
			return BOT_ACTION_DESIRE_HIGH
		else
			return BOT_ACTION_DESIRE_HIGH, target
		end
	end
	
	return 0
end

function UseQuillSpray()
	if not QuillSpray:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = QuillSpray:GetSpecialValueInt("radius")
	
	local enemies = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	
	if #enemies >= 1 and (P.IsInCombativeMode(bot) or P.IsRetreating(bot)) then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	if (bot:GetActiveMode() == BOT_MODE_FARM and bot:GetActiveModeDesire() >= BOT_MODE_DESIRE_VERYLOW) then
		local neutrals = bot:GetNearbyNeutralCreeps(CastRange)
		
		if #neutrals >= 1 and (bot:GetMana() - QuillSpray:GetManaCost()) > manathreshold then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	return 0
end

function UseHairball()
	if not Hairball:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = Hairball:GetCastRange()
	local Radius = Hairball:GetSpecialValueInt("radius")
	
	local AoE = bot:FindAoELocation(true, true, bot:GetLocation(), CastRange, Radius/2, 0, 0)
	if (AoE.count >= 1) then
		return BOT_ACTION_DESIRE_HIGH, AoE.targetloc;
	end
	
	return 0
end

return X