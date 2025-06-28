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
	
	if bot:GetActiveMode() == BOT_MODE_RETREAT then
		local EnemiesWithinRange = PAF.GetNearbyFilteredHeroes(bot, 1200, true, BOT_MODE_NONE)
		
		if #EnemiesWithinRange > 0 then
			return 1
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		if PAF.IsRoshan(AttackTarget) then
			return 1
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_SIDE_SHOP then
		if PAF.IsTormentor(AttackTarget) then
			return 1
		end
	end
	
	return 0
end

function UseHomingMissile()
	if not HomingMissile:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = HomingMissile:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	local Damage = HomingMissile:GetSpecialValueInt("hit_damage")
	local DamageType = HomingMissile:GetDamageType()
	
	local EnemiesWithinCastRange = PAF.GetNearbyFilteredHeroes(bot, CastRange, true, BOT_MODE_NONE)
	
	for x, Enemy in pairs(EnemiesWithinCastRange) do
		if (Enemy:IsChanneling() or PAF.CanDamageKillEnemy(Enemy, Damage, DamageType))
		and not PAF.IsReflectingSpells(Enemy) then
			return 1, Enemy
		end
	end
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget)
			and not PAF.IsReflectingSpells(BotTarget) then
				if not PAF.IsDisabled(BotTarget) then
					return 1, BotTarget
				else
					local EnemiesWithinRange = PAF.GetNearbyFilteredHeroesForStun(bot, 1600, true, BOT_MODE_NONE)
					local FilteredUnits = PAF.FilterExceptedUnit(EnemiesWithinRange, BotTarget)
					
					local StrongestEnemy = PAF.GetStrongestPowerUnit(FilteredUnits)
					
					if StrongestEnemy ~= nil
					and GetUnitToUnitDistance(bot, StrongestEnemy) <= CastRange then
						return 1, StrongestEnemy
					end
				end
			end
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_RETREAT then
		local StrongestEnemy = PAF.GetStrongestPowerUnit(EnemiesWithinCastRange)
		
		if StrongestEnemy ~= nil
		and not PAF.IsMagicImmune(StrongestEnemy)
		and not PAF.IsReflectingSpells(StrongestEnemy) then
			return 1, StrongestEnemy
		end
	end
	
	local NearbyAlliedTowers = bot:GetNearbyTowers(1600, false)
	
	for x, Tower in pairs(NearbyAlliedTowers) do
		local TowerTarget = Tower:GetAttackTarget()
		
		if PAF.IsValidHeroAndNotIllusion(TowerTarget)
		and not PAF.IsMagicImmune(TowerTarget)
		and not PAF.IsDisabled(TowerTarget)
		and not PAF.IsReflectingSpells(TowerTarget) then
			return 1, TowerTarget
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		if PAF.IsRoshan(AttackTarget) then
			return 1, AttackTarget
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_SIDE_SHOP then
		if PAF.IsTormentor(AttackTarget) then
			return 1, AttackTarget
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