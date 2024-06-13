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

local ChaosBolt = bot:GetAbilityByName("chaos_knight_chaos_bolt")
local RealityRift = bot:GetAbilityByName("chaos_knight_reality_rift")
local ChaosStrike = bot:GetAbilityByName("chaos_knight_chaos_strike")
local Phantasm = bot:GetAbilityByName("chaos_knight_phantasm")

local ChaosBoltDesire = 0
local RealityRiftDesire = 0
local PhantasmDesire = 0

local AttackRange
local BotTarget

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	-- The order to use abilities in
	PhantasmDesire, PhantasmTarget = UsePhantasm()
	if PhantasmDesire > 0 then
		bot:Action_UseAbility(Phantasm)
		return
	end
	
	ChaosBoltDesire, ChaosBoltTarget = UseChaosBolt()
	if ChaosBoltDesire > 0 then
		bot:Action_UseAbilityOnEntity(ChaosBolt, ChaosBoltTarget)
		return
	end
	
	RealityRiftDesire, RealityRiftTarget = UseRealityRift()
	if RealityRiftDesire > 0 then
		bot:Action_UseAbilityOnEntity(RealityRift, RealityRiftTarget)
		return
	end
end

function UseChaosBolt()
	if not ChaosBolt:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = ChaosBolt:GetCastRange()
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

function UseRealityRift()
	if not RealityRift:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = ChaosBolt:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange then
				if bot:GetLevel() >= 20 then
					return BOT_ACTION_DESIRE_HIGH, BotTarget
				else
					if not PAF.IsMagicImmune(BotTarget) then
						return BOT_ACTION_DESIRE_HIGH, BotTarget
					end
				end
			end
		end
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

function UsePhantasm()
	if not Phantasm:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local enemies = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	local tableTrueEnemies = PAF.FilterTrueUnits(enemies)
	
	if PAF.IsEngaging(bot) and #tableTrueEnemies > 0 then
		if bot:FindItemSlot("item_armlet") >= 0 then
			if bot:HasModifier("modifier_item_armlet_unholy_strength") then
				return BOT_ACTION_DESIRE_HIGH
			end
		else
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	--[[if not P.IsInLaningPhase() then
		local attacktarget = bot:GetAttackTarget()
	
		if attacktarget ~= nil then
			if attacktarget:IsBuilding() then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end]]--
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		local AttackTarget = bot:GetAttackTarget()
		
		if PAF.IsRoshan(AttackTarget) then
			return BOT_ACTION_DESIRE_VERYHIGH
		end
	end
	
	return 0
end