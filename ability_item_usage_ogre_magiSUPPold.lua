------------------------------
-- CREATED BY: MANSLAUGHTER --
------------------------------

local bot = GetBot()
if bot:IsInvulnerable() or not bot:IsHero() or bot:IsIllusion() then return end

local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")
local PAF = require(GetScriptDirectory() ..  "/Library/PhalanxAbilityFunctions")

local ability_item_usage_generic = dofile( GetScriptDirectory().."/ability_item_usage_generic" )

function AbilityLevelUpThink()  
	ability_item_usage_generic.AbilityLevelUpThink(); 
end
function BuybackUsageThink()
	ability_item_usage_generic.BuybackUsageThink();
end
function CourierUsageThink()
	ability_item_usage_generic.CourierUsageThink();
end
function ItemUsageThink()
	ability_item_usage_generic.ItemUsageThink();
end

local Fireblast = bot:GetAbilityByName("ogre_magi_fireblast")
local Ignite = bot:GetAbilityByName("ogre_magi_ignite")
local Bloodlust = bot:GetAbilityByName("ogre_magi_bloodlust")
local Multicast = bot:GetAbilityByName("ogre_magi_multicast")
local UnrefinedFireblast = bot:GetAbilityByName("ogre_magi_unrefined_fireblast")
local FireShield = bot:GetAbilityByName("ogre_magi_smash")

local FireblastDesire = 0
local IgniteDesire = 0
local BloodlustDesire = 0
local UnrefinedFireblastDesire = 0
local FireShieldDesire = 0

local AttackRange
local BotTarget

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	-- The order to use abilities in
	FireShieldDesire, FireShieldTarget = UseFireShield()
	if FireShieldDesire > 0 then
		bot:Action_UseAbilityOnEntity(FireShield, FireShieldTarget)
		return
	end
	
	FireblastDesire, FireblastTarget = UseFireblast()
	if FireblastDesire > 0 then
		bot:Action_UseAbilityOnEntity(Fireblast, FireblastTarget)
		return
	end
	
	UnrefinedFireblastDesire, UnrefinedFireblastTarget = UseUnrefinedFireblast()
	if UnrefinedFireblastDesire > 0 then
		bot:Action_UseAbilityOnEntity(UnrefinedFireblast, UnrefinedFireblastTarget)
		return
	end
	
	IgniteDesire, IgniteTarget = UseIgnite()
	if IgniteDesire > 0 then
		bot:Action_UseAbilityOnEntity(Ignite, IgniteTarget)
		return
	end
	
	BloodlustDesire, BloodlustTarget = UseBloodlust()
	if BloodlustDesire > 0 then
		bot:Action_UseAbilityOnEntity(Bloodlust, BloodlustTarget)
		return
	end
end

function UseFireblast()
	if not Fireblast:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = Fireblast:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterUnitsForStun(EnemiesWithinRange)
	
	for v, enemy in pairs(FilteredEnemies) do
		if enemy:IsChanneling() then
			return BOT_ACTION_DESIRE_HIGH, enemy
		end
	end
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget)
			and not PAF.IsDisabled(BotTarget) then
				return BOT_ACTION_DESIRE_HIGH, BotTarget
			end
		end
	end
	
	if P.IsRetreating(bot) and #EnemiesWithinRange > 0 then
		local ClosestTarget = PAF.GetClosestUnit(bot, EnemiesWithinRange)
		return BOT_ACTION_DESIRE_HIGH, ClosestTarget
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		local AttackTarget = bot:GetAttackTarget()
		
		if PAF.IsRoshan(AttackTarget)
		and GetUnitToUnitDistance(bot, AttackTarget) <= CastRange then
			return BOT_ACTION_DESIRE_VERYHIGH, AttackTarget
		end
	end
	
	return 0
end

function UseIgnite()
	if not Ignite:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = Ignite:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget) then
				return BOT_ACTION_DESIRE_HIGH, BotTarget
			end
		end
	end
	
	return 0
end

function UseBloodlust()
	if not Bloodlust:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = Bloodlust:GetCastRange()
	
	local allies = bot:GetNearbyHeroes(CastRange + 500, false, BOT_MODE_NONE)
	local filteredallies = {}
	
	for v, ally in pairs(allies) do
		if not ally:HasModifier("modifier_ogre_magi_bloodlust") and not PAF.IsPossibleIllusion(ally) then
			table.insert(filteredallies, ally)
		end
	end
	
	local target = PAF.GetStrongestAttackDamageUnit(filteredallies)
	
	if target ~= nil then
		return BOT_ACTION_DESIRE_HIGH, target
	end
	
	local towers = bot:GetNearbyTowers(CastRange + 100, false)
	local enemies = bot:GetNearbyHeroes(1000, true, BOT_MODE_NONE)
	
	for v, tower in pairs(towers) do
		if #enemies >= 1 and not tower:HasModifier("modifier_ogre_magi_bloodlust") then
			return BOT_ACTION_DESIRE_HIGH, tower
		end
	end
	
	return 0
end

function UseFireShield()
	if not FireShield:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = FireShield:GetCastRange()
	
	local allies = bot:GetNearbyHeroes(CastRange + 500, false, BOT_MODE_NONE)
	local enemies = bot:GetNearbyHeroes(1000, true, BOT_MODE_NONE)
	local target = P.GetWeakestAllyHero(allies)
	
	if target ~= nil and #enemies >= 1 and not target:HasModifier("modifier_ogre_magi_smash_buff") then
		return BOT_ACTION_DESIRE_HIGH, target
	end
	
	local ancient = GetAncient(bot:GetTeam())
	
	if #enemies >= 1 and not ancient:IsInvulnerable() and not ancient:HasModifier("modifier_ogre_magi_smash_buff") then
		return BOT_ACTION_DESIRE_HIGH, ancient
	end
	
	local barracks = bot:GetNearbyBarracks(CastRange + 100, false)
	
	for v, barrack in pairs(barracks) do
		if #enemies >= 1 and not barrack:IsInvulnerable() and not barrack:HasModifier("modifier_ogre_magi_smash_buff") then
			return BOT_ACTION_DESIRE_HIGH, barrack
		end
	end
	
	local towers = bot:GetNearbyTowers(CastRange + 100, false)
	
	for v, tower in pairs(towers) do
		if #enemies >= 1 and not tower:IsInvulnerable() and not tower:HasModifier("modifier_ogre_magi_smash_buff") then
			return BOT_ACTION_DESIRE_HIGH, tower
		end
	end
	
	return 0
end

function UseUnrefinedFireblast()
	if not UnrefinedFireblast:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = UnrefinedFireblast:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterUnitsForStun(EnemiesWithinRange)
	
	for v, enemy in pairs(FilteredEnemies) do
		if enemy:IsChanneling() then
			return BOT_ACTION_DESIRE_HIGH, enemy
		end
	end
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget)
			and not PAF.IsDisabled(BotTarget) then
				return BOT_ACTION_DESIRE_HIGH, BotTarget
			end
		end
	end
	
	if P.IsRetreating(bot) and #EnemiesWithinRange > 0 then
		local ClosestTarget = PAF.GetClosestUnit(bot, EnemiesWithinRange)
		return BOT_ACTION_DESIRE_HIGH, ClosestTarget
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		local AttackTarget = bot:GetAttackTarget()
		
		if PAF.IsRoshan(AttackTarget)
		and GetUnitToUnitDistance(bot, AttackTarget) <= CastRange then
			return BOT_ACTION_DESIRE_VERYHIGH, AttackTarget
		end
	end
	
	return 0
end