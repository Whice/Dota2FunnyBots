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
local Chronosphere = bot:GetAbilityInSlot(5)

local TimeWalkDesire = 0
local TimeDilationDesire = 0
local ChronosphereDesire = 0

local AttackRange
local BotTarget
local AttackTarget
local ManaThreshold

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	AttackTarget = bot:GetAttackTarget()
	ManaThreshold = 100
	
	for x = 5, 1, -1 do
		local hAbility = bot:GetAbilityInSlot(x)
		if hAbility ~= nil
		and hAbility:IsTrained()
		and not hAbility:IsHidden() then
			local nManaCost = hAbility:GetManaCost()
			
			if nManaCost > 0 then
				ManaThreshold = (ManaThreshold + nManaCost)
			end
		end
	end
	
	-- The order to use abilities in
	TimeDilationDesire = UseTimeDilation()
	if TimeDilationDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbility(TimeDilation)
		return
	end
	
	TimeWalkDesire, TimeWalkTarget = UseTimeWalk()
	if TimeWalkDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbilityOnLocation(TimeWalk, TimeWalkTarget)
		return
	end
	
	ChronosphereDesire, ChronosphereTarget = UseChronosphere()
	if ChronosphereDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbilityOnLocation(Chronosphere, ChronosphereTarget)
		return
	end
end

function UseTimeWalk()
	if not TimeWalk:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = TimeWalk:GetSpecialValueInt("range")
	local CastRange = PAF.GetProperCastRange(CR)
	local CastPoint = TimeWalk:GetCastPoint()
	
	local EnemiesWithinCastRange = PAF.GetNearbyFilteredHeroes(bot, CastRange, true, BOT_MODE_NONE)
	
	if P.IsRetreating(bot) then
		return BOT_ACTION_DESIRE_ABSOLUTE, PAF.GetFountainLocation(bot)
	end
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			local EstimatedDamage = bot:GetEstimatedDamageToTarget(true, BotTarget, 3, DAMAGE_TYPE_ALL)
			
			if EstimatedDamage > BotTarget:GetHealth() then
				if GetUnitToUnitDistance(bot, BotTarget) < CastRange
				and GetUnitToUnitDistance(bot, BotTarget) > (AttackRange + 150) then
					return 1, BotTarget:GetLocation()
				end
			end
			
			if PAF.IsInTeamFight(bot)
			and Chronosphere:IsFullyCastable() then
				local ChronosphereRadius = Chronosphere:GetSpecialValueInt("radius")
				SearchRange = (CastRange + Chronosphere:GetCastRange())
			
				local AoE = bot:FindAoELocation(true, true, bot:GetLocation(), SearchRange, ChronosphereRadius, CastPoint, 0)
				if (AoE.count >= 2) then
					return 1, AoE.targetloc
				end
			end
			
			if PAF.IsChasing(bot, BotTarget) then
				local AoECount = PAF.GetUnitsNearTarget(BotTarget:GetLocation(), EnemiesWithinCastRange, 800)
				
				if AoECount <= 2 then
					if GetUnitToUnitDistance(bot, BotTarget) > (AttackRange + 150) then
						return 1, BotTarget:GetExtrapolatedLocation(1)
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
	
	local EnemiesWithinCastRange = PAF.GetNearbyFilteredHeroes(bot, CastRange, true, BOT_MODE_NONE)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= (CastRange - 50)
			and not PAF.IsMagicImmune(BotTarget) then
				return 1
			end
		end
	end
	
	if #EnemiesWithinCastRange >= 1 and P.IsRetreating(bot) then
		return 1
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		if PAF.IsRoshan(AttackTarget) then
			return 1, AttackTarget
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
		local AoE = bot:FindAoELocation(true, true, bot:GetLocation(), CastRange, Radius, 0, 0)
		if (AoE.count >= 2) then
			return BOT_ACTION_DESIRE_HIGH, AoE.targetloc
		end
	end
	
	return 0
end