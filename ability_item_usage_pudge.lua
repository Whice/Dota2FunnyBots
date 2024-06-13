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

local MeatHook = bot:GetAbilityByName("pudge_meat_hook")
local Rot = bot:GetAbilityByName("pudge_rot")
local FleshHeap = bot:GetAbilityByName("pudge_flesh_heap")
local Dismember = bot:GetAbilityByName("pudge_dismember")

local MeatHookDesire = 0
local RotDesire = 0
local FleshHeapDesire = 0
local DismemberDesire = 0

local AttackRange
local BotTarget

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	-- The order to use abilities in
	MeatHookDesire, MeatHookTarget = UseMeatHook()
	if MeatHookDesire > 0 then
		bot:Action_UseAbilityOnLocation(MeatHook, MeatHookTarget)
		return
	end
	
	RotDesire = UseRot()
	if RotDesire > 0 then
		bot:Action_UseAbility(Rot)
		return
	end
	
	FleshHeapDesire = UseFleshHeap()
	if FleshHeapDesire > 0 then
		bot:Action_UseAbility(FleshHeap)
		return
	end
	
	DismemberDesire, DismemberTarget = UseDismember()
	if DismemberDesire > 0 then
		bot:Action_UseAbilityOnEntity(Dismember, DismemberTarget)
		return
	end
end

function UseMeatHook()
	if not MeatHook:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = MeatHook:GetCastRange()
	local CastPoint = MeatHook:GetCastPoint()
	local Radius = MeatHook:GetSpecialValueInt('hook_width')
	local Speed = MeatHook:GetSpecialValueInt('hook_speed')
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			local MovementStability = BotTarget:GetMovementDirectionStability()
			local ExtrapNum = CastPoint + (GetUnitToUnitDistance(bot, BotTarget) / Speed)
			local PredictedLoc = BotTarget:GetExtrapolatedLocation(ExtrapNum)
			
			--[[if MovementStability < 0.6 then
				PredictedLoc = BotTarget:GetLocation()
			end]]--
			
			if not P.IsHeroBetweenMeAndTarget(bot, BotTarget, PredictedLoc, Radius) and not P.IsCreepBetweenMeAndTarget(bot, BotTarget, PredictedLoc, Radius) then
				if GetUnitToLocationDistance(bot, PredictedLoc) <= CastRange then
					return BOT_ACTION_DESIRE_HIGH, PredictedLoc
				elseif GetUnitToUnitDistance(bot, BotTarget) <= CastRange
				and GetUnitToLocationDistance(bot, PredictedLoc) > CastRange then
					return BOT_ACTION_DESIRE_HIGH, bot:GetXUnitsTowardsLocation(PredictedLoc, CastRange)
				end
			end
		end
	elseif not P.IsRetreating(bot) and #FilteredEnemies > 0 then
		-- If Pudge is not engaging then look for an initiation hook on a killable target
		local AlliesWithinRange = bot:GetNearbyHeroes(1000, false, BOT_MODE_NONE)
		local FilteredAllies = PAF.FilterTrueUnits(AlliesWithinRange)
		local KillDuration = 2
		
		if Dismember:IsFullyCastable() then
			local DismemberDuration = Dismember:GetSpecialValueFloat("AbilityChannelTime")
			KillDuration = (KillDuration + DismemberDuration)
		end
		
		local EstimatedDamage = 0
		for v, Enemy in pairs(FilteredEnemies) do
			EstimatedDamage = PAF.CombineEstimatedDamage(true, FilteredAllies, Enemy, KillDuration, DAMAGE_TYPE_ALL)
			
			if Enemy:GetHealth() <= EstimatedDamage then
				local MovementStability = Enemy:GetMovementDirectionStability()
				local ExtrapNum = CastPoint + (GetUnitToUnitDistance(bot, Enemy) / Speed)
				local PredictedLoc = Enemy:GetExtrapolatedLocation(ExtrapNum)
				
				if not P.IsHeroBetweenMeAndTarget(bot, Enemy, PredictedLoc, Radius) and not P.IsCreepBetweenMeAndTarget(bot, Enemy, PredictedLoc, Radius) then
					if GetUnitToLocationDistance(bot, PredictedLoc) <= CastRange then
						return BOT_ACTION_DESIRE_HIGH, PredictedLoc
					elseif GetUnitToUnitDistance(bot, Enemy) <= CastRange
					and GetUnitToLocationDistance(bot, PredictedLoc) > CastRange then
						return BOT_ACTION_DESIRE_HIGH, bot:GetXUnitsTowardsLocation(PredictedLoc, CastRange)
					end
				end
			end
		end
	end
	
	-- Can we hook a unit into a tower?
	local NearbyTowers = bot:GetNearbyTowers(700, false)
	if #NearbyTowers >= 1
	and not PAF.IsEngaging(bot)
	and not P.IsRetreating(bot) then
		local TowerAttackTarget = NearbyTowers[1]:GetAttackTarget()
		
		if TowerAttackTarget == nil and #FilteredEnemies > 0 then
			for v, Enemy in pairs(FilteredEnemies) do
				local MovementStability = Enemy:GetMovementDirectionStability()
				local ExtrapNum = CastPoint + (GetUnitToUnitDistance(bot, Enemy) / Speed)
				local PredictedLoc = Enemy:GetExtrapolatedLocation(ExtrapNum)
				
				if not P.IsHeroBetweenMeAndTarget(bot, Enemy, PredictedLoc, Radius) and not P.IsCreepBetweenMeAndTarget(bot, Enemy, PredictedLoc, Radius) then
					if GetUnitToLocationDistance(bot, PredictedLoc) <= CastRange then
						return BOT_ACTION_DESIRE_HIGH, PredictedLoc
					elseif GetUnitToUnitDistance(bot, Enemy) <= CastRange
					and GetUnitToLocationDistance(bot, PredictedLoc) > CastRange then
						return BOT_ACTION_DESIRE_HIGH, bot:GetXUnitsTowardsLocation(PredictedLoc, CastRange)
					end
				end
			end
		end
	end
	
	-- Is there a siege creep that can be hooked during laning?
	if P.IsInLaningPhase() and bot:GetActiveMode() == BOT_MODE_LANING then
		local LaneCreeps = bot:GetNearbyLaneCreeps(CastRange, true)
		
		for v, Creep in pairs(LaneCreeps) do
			if string.find(Creep:GetUnitName(), "siege") then
				if Creep:GetAttackTarget() ~= nil then
					if not P.IsHeroBetweenMeAndTarget(bot, Creep, Creep:GetLocation(), Radius) and not P.IsCreepBetweenMeAndTarget(bot, Creep, Creep:GetLocation(), Radius) then
						if GetUnitToLocationDistance(bot, Creep:GetLocation()) <= CastRange then
							return BOT_ACTION_DESIRE_HIGH, Creep:GetLocation()
						end
					end
				end
			end
		end
	end
	
	if not PAF.IsEngaging(bot) then
		local AlliesWithinRange = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
		local FilteredAllies = PAF.FilterTrueUnits(AlliesWithinRange)
		
		for v, Ally in pairs(FilteredAllies) do
			local RetreatLoc = PAF.GetFountainLocation(Ally)
		
			if Ally:GetHealth() <= (Ally:GetMaxHealth() * 0.35)
			and Ally:WasRecentlyDamagedByAnyHero(1)
			and Ally:IsFacingLocation(RetreatLoc, 45)
			and GetUnitToLocationDistance(bot, RetreatLoc) < GetUnitToLocationDistance(Ally, RetreatLoc)
			and GetUnitToUnitDistance(bot, Ally) >= 650 then
				local MovementStability = Ally:GetMovementDirectionStability()
				local ExtrapNum = CastPoint + (GetUnitToUnitDistance(bot, Ally) / Speed)
				local PredictedLoc = Ally:GetExtrapolatedLocation(ExtrapNum)
				
				if not P.IsHeroBetweenMeAndTarget(bot, Ally, PredictedLoc, Radius) and not P.IsCreepBetweenMeAndTarget(bot, Ally, PredictedLoc, Radius) then
					if GetUnitToLocationDistance(bot, PredictedLoc) <= CastRange then
						return BOT_ACTION_DESIRE_HIGH, PredictedLoc
					elseif GetUnitToUnitDistance(bot, Ally) <= CastRange
					and GetUnitToLocationDistance(bot, PredictedLoc) > CastRange then
						return BOT_ACTION_DESIRE_HIGH, bot:GetXUnitsTowardsLocation(PredictedLoc, CastRange)
					end
				end
			end
		end
	end
	
	return 0
end

function UseRot()
	if not Rot:IsFullyCastable() then return 0 end
	if bot:IsSilenced() or bot:IsHexed() or bot:HasModifier("modifier_doom_bringer_doom") then return 0 end
	
	local CastRange = (Rot:GetSpecialValueInt('rot_radius') + 100)
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	
	if P.IsRetreating(bot) then
		if Rot:GetToggleState() == true then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	if not P.IsRetreating(bot) then
		if #FilteredEnemies > 0 then
			if Rot:GetToggleState() == false then
				return BOT_ACTION_DESIRE_HIGH
			else
				return 0
			end
		end
	end
	
	local AttackTarget = bot:GetAttackTarget()
	
	if AttackTarget ~= nil then
		if bot:GetActiveMode() == BOT_MODE_FARM and AttackTarget:IsCreep() then
			if GetUnitToUnitDistance(bot, AttackTarget) <= CastRange then
				if Rot:GetToggleState() == false then
					return BOT_ACTION_DESIRE_HIGH
				else
					return 0
				end
			end
		end
	end
	
	if Rot:GetToggleState() == true then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	return 0
end

function UseFleshHeap()
	if not FleshHeap:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	if Rot:GetToggleState() == true then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	
	if P.IsRetreating(bot) and (#FilteredEnemies >= 1 or bot:WasRecentlyDamagedByAnyHero(2)) then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	return 0
end

function UseDismember()
	if not Dismember:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = (Dismember:GetCastRange() + 100)
	local CastRange = PAF.GetProperCastRange(CR)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange then
				return BOT_ACTION_DESIRE_HIGH, BotTarget
			end
		end
	end
	
	return 0
end