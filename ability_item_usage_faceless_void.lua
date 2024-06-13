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

local TimeWalk = bot:GetAbilityByName("faceless_void_time_walk")
local TimeDilation = bot:GetAbilityByName("faceless_void_time_dilation")
local TimeLock = bot:GetAbilityByName("faceless_void_time_lock")
local Chronosphere = bot:GetAbilityByName("faceless_void_chronosphere")

local TimeWalkDesire = 0
local TimeDilationDesire = 0
local ChronosphereDesire = 0

local AttackRange
local BotTarget

local RadiantBase = Vector(-7171.12, -7261.72, 1469.28)
local DireBase = Vector(6977.84, 5797.69, 1357.99)
local team = bot:GetTeam()

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	AttackRange = bot:GetAttackRange()
	
	-- The order to use abilities in
	TimeWalkDesire, TimeWalkTarget = UseTimeWalk()
	if TimeWalkDesire > 0 then
		bot:Action_UseAbilityOnLocation(TimeWalk, TimeWalkTarget)
		return
	end
	
	ChronosphereDesire, ChronosphereTarget = UseChronosphere()
	if ChronosphereDesire > 0 then
		bot:Action_UseAbilityOnLocation(Chronosphere, ChronosphereTarget)
		return
	end
	
	TimeDilationDesire = UseTimeDilation()
	if TimeDilationDesire > 0 then
		bot:Action_UseAbility(TimeDilation)
		return
	end
end

function UseTimeWalk()
	if not TimeWalk:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = TimeWalk:GetSpecialValueInt("range")
	local CastRange = PAF.GetProperCastRange(CR)
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	
	if P.IsRetreating(bot) then
		return BOT_ACTION_DESIRE_ABSOLUTE, PAF.GetFountainLocation(bot)
	end
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			local EstimatedDamage = bot:GetEstimatedDamageToTarget(true, BotTarget, 3, DAMAGE_TYPE_ALL)
			
			if EstimatedDamage > BotTarget:GetHealth() then
				if GetUnitToUnitDistance(bot, BotTarget) < CastRange
				and GetUnitToUnitDistance(bot, BotTarget) > (AttackRange + 50) then
					return BOT_ACTION_DESIRE_HIGH, BotTarget:GetLocation()
				end
			end
			
			if PAF.IsInTeamFight(bot)
			and Chronosphere:IsFullyCastable() then
				local ChronosphereRadius = Chronosphere:GetSpecialValueInt("radius")
				SearchRange = (CastRange + Chronosphere:GetCastRange())
			
				local AoE = bot:FindAoELocation(true, true, bot:GetLocation(), SearchRange, ChronosphereRadius/2, 0, 0)
				if (AoE.count >= 2) then
					return BOT_ACTION_DESIRE_HIGH, AoE.targetloc
				end
			end
			
			if PAF.IsChasing(bot, BotTarget) then
				local AoECount = PAF.GetUnitsNearTarget(BotTarget:GetLocation(), FilteredEnemies, 800)
				
				if AoECount <= 2 then
					if GetUnitToUnitDistance(bot, BotTarget) > (AttackRange + 50) then
						return BOT_ACTION_DESIRE_HIGH, BotTarget:GetExtrapolatedLocation(1)
					end
				end
			end
		end
	end
	
	return 0
end

function UseTimeDilation()
	if not TimeDilation:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = TimeDilation:GetSpecialValueInt("radius")
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterUnitsForStun(EnemiesWithinRange)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= (CastRange - 50)
			and not PAF.IsMagicImmune(BotTarget)
			and not PAF.IsDisabled(BotTarget) then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end
	
	if #FilteredEnemies >= 1 and P.IsRetreating(bot) then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	local AttackTarget = bot:GetAttackTarget()
	
	if AttackTarget ~= nil and not P.IsInLaningPhase() then
		if bot:GetActiveMode() == BOT_MODE_ROSHAN and PAF.IsRoshan(AttackTarget) then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	return 0
end

function UseChronosphere()
	if not Chronosphere:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = Chronosphere:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	local Radius = Chronosphere:GetSpecialValueInt("radius")
	
	if PAF.IsEngaging(bot) then
		local AoE = bot:FindAoELocation(true, true, bot:GetLocation(), CastRange, Radius/2, 0, 0)
		if (AoE.count >= 2) then
			return BOT_ACTION_DESIRE_HIGH, AoE.targetloc
		end
	end
	
	return 0
end