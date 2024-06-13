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

local Strafe = bot:GetAbilityByName("clinkz_strafe")
local TarBomb = bot:GetAbilityByName("clinkz_tar_bomb")
local DeathPact = bot:GetAbilityByName("clinkz_death_pact")
local SkeletonWalk = bot:GetAbilityByName("clinkz_wind_walk")
local BurningBarrage = bot:GetAbilityByName("clinkz_burning_barrage")

local StrafeDesire = 0
local TarBombDesire = 0
local DeathPactDesire = 0
local SkeletonWalkDesire = 0
local BurningBarrageDesire = 0

local AttackRange
local BotTarget

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	-- The order to use abilities in
	SkeletonWalkDesire = UseSkeletonWalk()
	if SkeletonWalkDesire > 0 then
		bot:Action_UseAbility(SkeletonWalk)
		return
	end
	
	DeathPactDesire, DeathPactTarget = UseDeathPact()
	if DeathPactDesire > 0 then
		bot:Action_UseAbilityOnEntity(DeathPact, DeathPactTarget)
		return
	end
	
	TarBombDesire, TarBombTarget = UseTarBomb()
	if TarBombDesire > 0 then
		bot:Action_UseAbilityOnEntity(TarBomb, TarBombTarget)
		return
	end
	
	StrafeDesire = UseStrafe()
	if StrafeDesire > 0 then
		bot:Action_UseAbility(Strafe)
		return
	end
	
	BurningBarrageDesire, BurningBarrageTarget = UseBurningBarrage()
	if BurningBarrageDesire > 0 then
		bot:Action_UseAbilityOnLocation(BurningBarrage, BurningBarrageTarget)
		return
	end
end

function UseStrafe()
	if not Strafe:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= (AttackRange + 50) then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end
	
	local AttackTarget = bot:GetAttackTarget()
	
	if AttackTarget ~= nil then
		if AttackTarget:IsCreep() and bot:GetActiveMode() == BOT_MODE_FARM then
			local NearbyCreeps = bot:GetNearbyCreeps((AttackRange + 50), true)
			
			if #NearbyCreeps >= 2 then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
		
		if PAF.IsRoshan(AttackTarget) then
			return BOT_ACTION_DESIRE_HIGH, AttackTarget
		end
	end
	
	return 0
end

function UseTarBomb()
	if not TarBomb:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = TarBomb:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local Radius = TarBomb:GetSpecialValueInt("radius")
	
	if PAF.IsEngaging(bot) or P.IsRetreating(bot) then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange then
				return BOT_ACTION_DESIRE_HIGH, BotTarget
			end
		end
	end
	
	local AttackTarget = bot:GetAttackTarget()
	
	if AttackTarget ~= nil then
		if AttackTarget:IsCreep() and not P.IsInLaningPhase() then
			local NearbyCreeps = bot:GetNearbyCreeps(CastRange, true)
			local AoECount = PAF.GetUnitsNearTarget(AttackTarget:GetLocation(), NearbyCreeps, Radius)
			
			if AoECount >= 2 then
				return BOT_ACTION_DESIRE_HIGH, AttackTarget
			end
		end
	
		if AttackTarget:IsBuilding() then
			return BOT_ACTION_DESIRE_HIGH, AttackTarget
		end
		
		if PAF.IsRoshan(AttackTarget) then
			return BOT_ACTION_DESIRE_HIGH, AttackTarget
		end
	end
	
	return 0
end

function UseDeathPact()
	if not DeathPact:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = DeathPact:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local CreepLevel = DeathPact:GetSpecialValueInt("creep_level")
	
	local creeps = bot:GetNearbyCreeps(CastRange, true)
		
	if bot:GetActiveMode() == BOT_MODE_LANING
	or bot:GetActiveMode() == BOT_MODE_FARM
	or PAF.IsEngaging(bot) then
		for v, creep in pairs(creeps) do
			if string.find(creep:GetUnitName(), "siege") and creep:GetLevel() <= CreepLevel then
				return BOT_ACTION_DESIRE_HIGH, creep
			end
			
			if string.find(creep:GetUnitName(), "flagbearer") and creep:GetLevel() <= CreepLevel then
				return BOT_ACTION_DESIRE_HIGH, creep
			end
			
			if creep:GetLevel() <= CreepLevel then
				return BOT_ACTION_DESIRE_HIGH, creep
			end
		end
	end
	
	return 0
end

function UseSkeletonWalk()
	if not SkeletonWalk:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	if PAF.IsEngaging(bot) or P.IsRetreating(bot) then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	return 0
end

function UseBurningBarrage()
	if not BurningBarrage:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = BurningBarrage:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= (CastRange - 150) then
				return BOT_ACTION_DESIRE_HIGH, BotTarget:GetLocation()
			end
		end
	end
	
	return 0
end