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
local AttackTarget
local ManaThreshold

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	AttackTarget = bot:GetAttackTarget()
	ManaThreshold = (100 + ChaosBolt:GetManaCost() + RealityRift:GetManaCost() + Phantasm:GetManaCost())
	
	-- The order to use abilities in
	PhantasmDesire = UsePhantasm()
	if PhantasmDesire > 0 then
		PAF.SwitchTreadsToStr(bot)
		bot:ActionQueue_UseAbility(Phantasm)
		return
	end
	
	ChaosBoltDesire, ChaosBoltTarget = UseChaosBolt()
	if ChaosBoltDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbilityOnEntity(ChaosBolt, ChaosBoltTarget)
		return
	end
	
	RealityRiftDesire, RealityRiftTarget = UseRealityRift()
	if RealityRiftDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbilityOnEntity(RealityRift, RealityRiftTarget)
		return
	end
end

function UseChaosBolt()
	if not ChaosBolt:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = ChaosBolt:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	local Damage = ((ChaosBolt:GetSpecialValueInt("damage_min") + ChaosBolt:GetSpecialValueInt("damage_max")) / 2)
	local DamageType = ChaosBolt:GetDamageType()
	
	local EnemiesWithinCastRange = PAF.GetNearbyFilteredHeroes(bot, CastRange, true, BOT_MODE_NONE)
	
	for x, Enemy in pairs(EnemiesWithinCastRange) do
		if Enemy:IsChanneling() or PAF.CanDamageKillEnemy(Enemy, Damage, DamageType) then
			return 1, Enemy
		end
	end
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget) then
				if not PAF.IsDisabled(BotTarget) then
					return 1, BotTarget
				else
					local EnemiesWithinRange = PAF.GetNearbyFilteredHeroes(bot, 1600, true, BOT_MODE_NONE)
					local FilteredUnits = PAF.FilterExceptedUnit(EnemiesWithinRange, BotTarget)
					
					local StrongestEnemy = PAF.GetStrongestPowerUnit(FilteredUnits)
					
					if StrongestEnemy ~= nil
					and not PAF.IsDisabled(StrongestEnemy)
					and GetUnitToUnitDistance(bot, StrongestEnemy) <= CastRange then
						return 1, StrongestEnemy
					end
				end
			end
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_RETREAT then
		local StrongestEnemy = PAF.GetStrongestPowerUnit(EnemiesWithinCastRange)
		
		if StrongestEnemy ~= nil then
			return 1, StrongestEnemy
		end
	end
	
	local NearbyAlliedTowers = bot:GetNearbyTowers(1600, false)
	
	for x, Tower in pairs(NearbyAlliedTowers) do
		local TowerTarget = Tower:GetAttackTarget()
		
		if PAF.IsValidHeroAndNotIllusion(TowerTarget)
		and not PAF.IsMagicImmune(TowerTarget)
		and not PAF.IsDisabled(TowerTarget) then
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

function UseRealityRift()
	if not RealityRift:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = ChaosBolt:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and GetUnitToUnitDistance(bot, BotTarget) > AttackRange then
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

function UsePhantasm()
	if not Phantasm:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local ManaThresholdTwo = 0
	
	if ChaosBolt:IsFullyCastable() then
		ManaThresholdTwo = (ManaThresholdTwo + ChaosBolt:GetManaCost())
	end
		
	if RealityRift:IsFullyCastable() then
		ManaThresholdTwo = (ManaThresholdTwo + RealityRift:GetManaCost())
	end
	
	ManaThresholdTwo = (ManaThresholdTwo + Phantasm:GetManaCost())
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= 1600
			and bot:GetMana() >= ManaThresholdTwo then
				if bot:FindItemSlot("item_armlet") >= 0 then
					if bot:HasModifier("modifier_item_armlet_unholy_strength") then
						return BOT_ACTION_DESIRE_HIGH
					end
				else
					return BOT_ACTION_DESIRE_HIGH
				end
			end
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		if PAF.IsRoshan(AttackTarget) then
			if bot:FindItemSlot("item_armlet") >= 0 then
				if bot:HasModifier("modifier_item_armlet_unholy_strength") then
					return BOT_ACTION_DESIRE_HIGH
				end
			else
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end
	
	return 0
end