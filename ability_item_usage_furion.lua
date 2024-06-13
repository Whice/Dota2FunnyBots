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

local Sprout = bot:GetAbilityByName("furion_sprout")
local Teleportation = bot:GetAbilityByName("furion_teleportation")
local ForceOfNature = bot:GetAbilityByName("furion_force_of_nature")
local WrathOfNature = bot:GetAbilityByName("furion_wrath_of_nature")
local CurseOfTheForest = bot:GetAbilityByName("furion_curse_of_the_forest")

local SproutDesire = 0
local TeleportationDesire = 0
local ForceOfNatureDesire = 0
local WrathOfNatureDesire = 0
local CurseOfTheForestDesire = 0

local AttackRange
local BotTarget

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	-- The order to use abilities in
	CurseOfTheForestDesire = UseCurseOfTheForest()
	if CurseOfTheForestDesire > 0 then
		bot:Action_UseAbility(CurseOfTheForest)
		return
	end
	
	WrathOfNatureDesire, WrathOfNatureTarget = UseWrathOfNature()
	if WrathOfNatureDesire > 0 then
		bot:Action_UseAbilityOnEntity(WrathOfNature, WrathOfNatureTarget)
		return
	end
	
	SproutDesire, SproutTarget = UseSprout()
	if SproutDesire > 0 then
		bot:Action_UseAbilityOnLocation(Sprout, SproutTarget)
		return
	end
	
	ForceOfNatureDesire, ForceOfNatureTarget = UseForceOfNature()
	if ForceOfNatureDesire > 0 then
		bot:Action_UseAbilityOnLocation(ForceOfNature, ForceOfNatureTarget)
		return
	end
	
	TeleportationDesire, TeleportationTarget = UseTeleportation()
	if TeleportationDesire > 0 then
		bot:Action_UseAbilityOnLocation(Teleportation, TeleportationTarget)
		return
	end
end

function UseSprout()
	if not Sprout:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = Sprout:GetCastRange()
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and PAF.IsChasing(bot, BotTarget) then
				return BOT_ACTION_DESIRE_HIGH, BotTarget:GetLocation()
			end
		end
	end
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	
	if P.IsRetreating(bot) and #FilteredEnemies > 0 then
		local ClosestTarget = PAF.GetClosestUnit(bot, FilteredEnemies)
		return BOT_ACTION_DESIRE_HIGH, ClosestTarget:GetLocation()
	end
	
	return 0
end

function UseTeleportation()
	if not Teleportation:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	if P.IsInLaningPhase() then return 0 end
	
	local allies = GetUnitList(UNIT_LIST_ALLIED_HEROES)
	local FilteredAllies = PAF.FilterTrueUnits(allies)
	
	for v, ally in pairs(FilteredAllies) do
		if PAF.IsInTeamFight(ally) then
			local enemies = ally:GetNearbyHeroes(1000, true, BOT_MODE_NONE)
			local FilteredEnemies = PAF.FilterTrueUnits(enemies)
			local target = PAF.GetWeakestUnit(enemies)
			
			if target ~= nil and not P.IsRetreating(bot) and not PAF.IsEngaging(bot) and GetUnitToUnitDistance(bot, target) > 2000 then
				return BOT_ACTION_DESIRE_HIGH, target:GetLocation()
			end
		end
	end
	
	return 0
end

function UseForceOfNature()
	if not ForceOfNature:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = ForceOfNature:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	local Radius = ForceOfNature:GetSpecialValueInt("area_of_effect")
	local MaxTreants = ForceOfNature:GetSpecialValueInt("max_treants")
	
	local Trees = bot:GetNearbyTrees(CastRange + Radius)
	local AttackTarget = bot:GetAttackTarget()
	
	if PAF.IsEngaging(bot)
	or ((AttackTarget ~= nil and not P.IsInLaningPhase()) and (AttackTarget:IsBuilding() or AttackTarget:IsCreep())) then
		if #Trees >= MaxTreants then
			return BOT_ACTION_DESIRE_HIGH, GetTreeLocation(Trees[2])
		end
	end
	
	return 0
end

function UseWrathOfNature()
	if not WrathOfNature:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = WrathOfNature:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	if PAF.IsInTeamFight(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange then
				return BOT_ACTION_DESIRE_HIGH, BotTarget
			end
		end
	end
	
	return 0
end

function UseCurseOfTheForest()
	if not CurseOfTheForest:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = CurseOfTheForest:GetSpecialValueInt("range")
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	
	if PAF.IsInTeamFight(bot) then
		if #FilteredEnemies >= 1 then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	return 0
end