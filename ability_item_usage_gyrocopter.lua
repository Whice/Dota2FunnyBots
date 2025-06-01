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

local RocketBarrage = bot:GetAbilityByName("gyrocopter_rocket_barrage")
local HomingMissile = bot:GetAbilityByName("gyrocopter_homing_missile")
local FlakCannon = bot:GetAbilityByName("gyrocopter_flak_cannon")
local CallDown = bot:GetAbilityByName("gyrocopter_call_down")

local RocketBarrageDesire = 0
local HomingMissileDesire = 0
local FlakCannonDesire = 0
local CallDownDesire = 0

local AttackRange
local BotTarget

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	-- The order to use abilities in
	CallDownDesire, CallDownTarget = UseCallDown()
	if CallDownDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbilityOnLocation(CallDown, CallDownTarget)
		return
	end
	
	HomingMissileDesire, HomingMissileTarget = UseHomingMissile()
	if HomingMissileDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbilityOnEntity(HomingMissile, HomingMissileTarget)
		return
	end
	
	RocketBarrageDesire = UseRocketBarrage()
	if RocketBarrageDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbility(RocketBarrage)
		return
	end
	
	FlakCannonDesire = UseFlakCannon()
	if FlakCannonDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbility(FlakCannon)
		return
	end
end

function UseRocketBarrage()
	if not RocketBarrage:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = RocketBarrage:GetSpecialValueInt("radius")
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget) then
				return BOT_ACTION_DESIRE_HIGH, BotTarget
			end
		end
	end
	
	local AttackTarget = bot:GetAttackTarget()
	
	if AttackTarget ~= nil then
		if bot:GetActiveMode() == BOT_MODE_ROSHAN then
			if PAF.IsRoshan(AttackTarget)
			and GetUnitToUnitDistance(bot, AttackTarget) <= CastRange then
				return BOT_ACTION_DESIRE_VERYHIGH
			end
		end
		
		if PAF.IsTormentor(AttackTarget)
		and GetUnitToUnitDistance(bot, AttackTarget) <= CastRange then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	return 0
end

function UseHomingMissile()
	if not HomingMissile:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = HomingMissile:GetCastRange()
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
			and not PAF.IsMagicImmune(BotTarget) then
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

function UseFlakCannon()
	if not FlakCannon:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local radius = FlakCannon:GetSpecialValueInt("radius")
	local EnemiesWithinRange = bot:GetNearbyHeroes(radius, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	
	if PAF.IsEngaging(bot) and #FilteredEnemies > 1 then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= AttackRange then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end
	
	if P.IsPushing(bot) or bot:GetActiveMode() == BOT_MODE_FARM then
		local AttackTarget = bot:GetAttackTarget()
		if AttackTarget ~= nil then
			if AttackTarget:IsCreep() and AttackTarget:GetTeam() ~= bot:GetTeam() then
				local NearbyCreeps = bot:GetNearbyCreeps(radius, true)
				if #NearbyCreeps >= 3 then
					if bot:GetMana() > (bot:GetMaxMana() * 0.55) then
						return BOT_ACTION_DESIRE_HIGH
					end
				end
			end
		end
	end
	
	return 0
end

function UseCallDown()
	if not CallDown:IsFullyCastable() then return 0 end
	if not PAF.IsInTeamFight(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = CallDown:GetCastRange()
	local Radius = CallDown:GetSpecialValueInt("radius")
	
	local AoE = bot:FindAoELocation(true, true, bot:GetLocation(), CastRange, Radius/2, 0, 0)
	if (AoE.count >= 2) then
		return BOT_ACTION_DESIRE_HIGH, AoE.targetloc
	end
	
	return 0
end