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

local ThunderStrike = bot:GetAbilityByName("disruptor_thunder_strike")
local Glimpse = bot:GetAbilityByName("disruptor_glimpse")
local KineticField = bot:GetAbilityInSlot(2)
local StaticStorm = bot:GetAbilityByName("disruptor_static_storm")

local ThunderStrikeDesire = 0
local GlimpseDesire = 0
local KineticFieldDesire = 0
local StaticStormDesire = 0

-- Combo Desires
local StormFieldComboDesire = 0

local AttackRange
local BotTarget

local LastKineticFieldPos = Vector(-99999, -99999, -99999)
local LastKineticFieldTime = 0

local RetreatTime = 0

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	-- The order to use abilities in
	StormFieldComboDesire, StormFieldComboTarget = UseStormFieldCombo()
	if StormFieldComboDesire > 0 then
		bot:Action_ClearActions(false)
		
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbilityOnLocation(KineticField, StormFieldComboTarget)
		LastKineticFieldPos = StormFieldComboTarget
		LastKineticFieldTime = DotaTime()
		bot:ActionQueue_UseAbilityOnLocation(StaticStorm, StormFieldComboTarget)
		return
	end
	
	StaticStormDesire, StaticStormTarget = UseStaticStorm()
	if StaticStormDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbilityOnLocation(StaticStorm, StaticStormTarget)
		return
	end
	
	KineticFieldDesire, KineticFieldTarget = UseKineticField()
	if KineticFieldDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbilityOnLocation(KineticField, KineticFieldTarget)
		LastKineticFieldPos = KineticFieldTarget
		LastKineticFieldTime = DotaTime()
		return
	end
	
	GlimpseDesire, GlimpseTarget = UseGlimpse()
	if GlimpseDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbilityOnEntity(Glimpse, GlimpseTarget)
		return
	end
	
	ThunderStrikeDesire, ThunderStrikeTarget = UseThunderStrike()
	if ThunderStrikeDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbilityOnEntity(ThunderStrike, ThunderStrikeTarget)
		return
	end
end

function UseStormFieldCombo()
	if not CanCastStormFieldCombo() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local ComboCastRange = StaticStorm:GetCastRange()
	local Radius = KineticField:GetSpecialValueInt("radius")
	
	if PAF.IsInTeamFight(bot) then
		local AoE = bot:FindAoELocation(true, true, bot:GetLocation(), ComboCastRange, Radius/2, 0, 0)
		if (AoE.count >= 2) then
			return BOT_ACTION_DESIRE_HIGH, AoE.targetloc
		end
	end
	
	return 0
end

function UseThunderStrike()
	if not ThunderStrike:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = ThunderStrike:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget) then
				return BOT_ACTION_DESIRE_HIGH, BotTarget
			end
		end
	end
	
	if P.IsInLaningPhase() and bot:GetActiveMode() == BOT_MODE_LANING then
		local WeakestEnemy = PAF.GetWeakestUnit(FilteredEnemies)
		
		if WeakestEnemy ~= nil then
			if GetUnitToUnitDistance(bot, WeakestEnemy) <= CastRange
			and not PAF.IsMagicImmune(WeakestEnemy) then
				return BOT_ACTION_DESIRE_HIGH, WeakestEnemy
			end
		end
	end
	
	local AttackTarget = bot:GetAttackTarget()
	
	if AttackTarget ~= nil then
		if bot:GetActiveMode() == BOT_MODE_ROSHAN then
			if PAF.IsRoshan(AttackTarget)
			and GetUnitToUnitDistance(bot, AttackTarget) <= CastRange then
				return BOT_ACTION_DESIRE_VERYHIGH, AttackTarget
			end
		end
		
		if PAF.IsTormentor(AttackTarget) then
			return BOT_ACTION_DESIRE_HIGH, AttackTarget
		end
	end
	
	return 0
end

function UseGlimpse()
	if not Glimpse:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = Glimpse:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local KineticFieldRadius = KineticField:GetSpecialValueInt("radius")
	local KineticFieldDuration = KineticField:GetSpecialValueFloat("duration")
	
	local SearchRange = CastRange
	if SearchRange > 1600 then
		SearchRange = 1600
	end
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(SearchRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterUnitsForStun(EnemiesWithinRange)
	
	for v, enemy in pairs(FilteredEnemies) do
		if enemy:IsChanneling()
		or enemy:HasModifier("modifier_fountain_passive") then
			return BOT_ACTION_DESIRE_HIGH, enemy
		end
	end
	
	if P.IsRetreating(bot) and #EnemiesWithinRange > 0 then
		local ClosestTarget = PAF.GetClosestUnit(bot, EnemiesWithinRange)
		
		if (DotaTime() - KineticFieldDuration) > LastKineticFieldTime
		and GetUnitToLocationDistance(ClosestTarget, LastKineticFieldPos) > (KineticFieldRadius + 25) then
			return BOT_ACTION_DESIRE_HIGH, ClosestTarget
		end
	end
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget)
			and not BotTarget:HasModifier("modifier_disruptor_kinetic_field") then
				if not BotTarget:IsFacingLocation(bot:GetLocation(), 45)
				and GetUnitToUnitDistance(bot, BotTarget) > 500 then
					local AlliesWithinRange = bot:GetNearbyHeroes(1200, false, BOT_MODE_NONE)
					local FilteredAllies = PAF.FilterTrueUnits(AlliesWithinRange)
					local OffensivePower = PAF.CombineOffensivePower(FilteredAllies, false)
					
					if BotTarget:GetHealth() <= OffensivePower then
						if (DotaTime() - KineticFieldDuration) > LastKineticFieldTime
						and GetUnitToLocationDistance(BotTarget, LastKineticFieldPos) > (KineticFieldRadius + 25)
						and (DotaTime() - RetreatTime) >= 2 then
							return BOT_ACTION_DESIRE_HIGH, BotTarget
						end
					end
				else
					RetreatTime = DotaTime()
				end
			end
		end
	else
		RetreatTime = DotaTime()
	end
	
	return 0
end

function UseKineticField()
	if not KineticField:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = KineticField:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	local Radius = KineticField:GetSpecialValueInt("radius")
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	
	if PAF.IsEngaging(bot)
	and not (CanCastStormFieldCombo() and PAF.IsInTeamFight(bot)) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget) then
				return BOT_ACTION_DESIRE_HIGH, BotTarget:GetLocation()
			end
		end
	end
	
	if P.IsRetreating(bot) and #EnemiesWithinRange > 0 then
		local ClosestTarget = PAF.GetClosestUnit(bot, EnemiesWithinRange)
		return BOT_ACTION_DESIRE_HIGH, ClosestTarget:GetLocation()
	end
	
	return 0
end

function UseStaticStorm()
	if not StaticStorm:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = StaticStorm:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	local Radius = StaticStorm:GetSpecialValueInt("radius")
	
	if PAF.IsInTeamFight(bot) and not CanCastStormFieldCombo() then
		local AoE = bot:FindAoELocation(true, true, bot:GetLocation(), CastRange, Radius/2, 0, 0)
		if (AoE.count >= 2) then
			return BOT_ACTION_DESIRE_HIGH, AoE.targetloc
		end
	end
	
	return 0
end

function CanCastStormFieldCombo()
	if KineticField:IsFullyCastable()
	and StaticStorm:IsFullyCastable() then
		local TotalManaCost = 0
		
		TotalManaCost = (TotalManaCost + KineticField:GetManaCost())
		TotalManaCost = (TotalManaCost + StaticStorm:GetManaCost())
		
		if bot:GetMana() > TotalManaCost then
			return true
		end
	end
	
	return false
end