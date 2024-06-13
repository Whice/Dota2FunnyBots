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

local StickyNapalm = bot:GetAbilityByName("batrider_sticky_napalm")
local Flamebreak = bot:GetAbilityByName("batrider_flamebreak")
local Firefly = bot:GetAbilityByName("batrider_firefly")
local FlamingLasso = bot:GetAbilityByName("batrider_flaming_lasso")

local StickyNapalmDesire = 0
local FlamebreakDesire = 0
local FireflyDesire = 0
local FlamingLassoDesire = 0

local AttackRange
local BotTarget
local manathreshold = 0

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	manathreshold = (bot:GetMaxMana() * 0.4)
	
	-- The order to use abilities in
	FlamingLassoDesire, FlamingLassoTarget = UseFlamingLasso()
	if FlamingLassoDesire > 0 then
		bot:Action_UseAbilityOnEntity(FlamingLasso, FlamingLassoTarget)
		return
	end
	
	FireflyDesire = UseFirefly()
	if FireflyDesire > 0 then
		bot:Action_UseAbility(Firefly)
		return
	end
	
	FlamebreakDesire, FlamebreakTarget = UseFlamebreak()
	if FlamebreakDesire > 0 then
		bot:Action_UseAbilityOnLocation(Flamebreak, FlamebreakTarget)
		return
	end
	
	StickyNapalmDesire, StickyNapalmTarget = UseStickyNapalm()
	if StickyNapalmDesire > 0 then
		bot:Action_UseAbilityOnLocation(StickyNapalm, StickyNapalmTarget)
		return
	end
end

function UseStickyNapalm()
	if not StickyNapalm:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = StickyNapalm:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	local Radius = StickyNapalm:GetSpecialValueInt("radius")
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterUnitsForStun(EnemiesWithinRange)
	
	local WeakestEnemy = PAF.GetWeakestUnit(FilteredEnemies)
		
	if WeakestEnemy ~= nil and not P.IsRetreating(bot) then
		return BOT_ACTION_DESIRE_HIGH, WeakestEnemy:GetLocation()
	end
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget) then
				return BOT_ACTION_DESIRE_HIGH, BotTarget:GetLocation()
			end
		end
	end
	
	local AttackTarget = bot:GetAttackTarget()
	
	if not P.IsInLaningPhase() and (bot:GetMana() - StickyNapalm:GetManaCost()) > manathreshold then
		if AttackTarget ~= nil and AttackTarget:IsCreep() then
			local NearbyCreeps = bot:GetNearbyCreeps(CastRange, true)
			local AoECount = PAF.GetUnitsNearTarget(AttackTarget:GetLocation(), NearbyCreeps, Radius)
			
			if AoECount >= 3 then
				return BOT_ACTION_DESIRE_HIGH, AttackTarget:GetLocation()
			end
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		if PAF.IsRoshan(AttackTarget)
		and GetUnitToUnitDistance(bot, AttackTarget) <= CastRange then
			return BOT_ACTION_DESIRE_VERYHIGH, AttackTarget:GetLocation()
		end
	end
	
	return 0
end

function UseFlamebreak()
	if not Flamebreak:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = Flamebreak:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget) then
				return BOT_ACTION_DESIRE_HIGH, BotTarget:GetLocation()
			end
		end
	end
	
	local AttackTarget = bot:GetAttackTarget()
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		if PAF.IsRoshan(AttackTarget)
		and GetUnitToUnitDistance(bot, AttackTarget) <= CastRange then
			return BOT_ACTION_DESIRE_VERYHIGH, AttackTarget:GetLocation()
		end
	end
	
	return 0
end

function UseFirefly()
	if not Firefly:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(800, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if bot:HasModifier("modifier_batrider_flaming_lasso_self") then
				return true
			end
			
			if BotTarget:HasModifier("modifier_batrider_flaming_lasso") then
				return true
			end
		
			if GetUnitToUnitDistance(bot, BotTarget) <= 250
			and not PAF.IsMagicImmune(BotTarget) then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end
	
	if P.IsRetreating(bot) and #FilteredEnemies >= 1 then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	return 0
end

function UseFlamingLasso()
	if not FlamingLasso:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = FlamingLasso:GetCastRange()
	local CastRange = (PAF.GetProperCastRange(CR) + 100)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange then
				return BOT_ACTION_DESIRE_HIGH, BotTarget
			end
		end
	end
	
	return 0
end