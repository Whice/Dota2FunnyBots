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

local FortunesEnd = bot:GetAbilityByName("oracle_fortunes_end")
local FatesEdict = bot:GetAbilityByName("oracle_fates_edict")
local PurifyingFlames = bot:GetAbilityByName("oracle_purifying_flames")
local FalsePromise = bot:GetAbilityByName("oracle_false_promise")
local RainOfDestiny = bot:GetAbilityByName("oracle_rain_of_destiny")

local FortunesEndDesire = 0
local FatesEdictDesire = 0
local PurifyingFlamesDesire = 0
local FalsePromiseDesire = 0
local RainOfDestinyDesire = 0

local AttackRange
local BotTarget

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	-- The order to use abilities in
	FalsePromiseDesire, FalsePromiseTarget = UseFalsePromise()
	if FalsePromiseDesire > 0 then
		bot:Action_UseAbilityOnEntity(FalsePromise, FalsePromiseTarget)
		return
	end
	
	FatesEdictDesire, FatesEdictTarget = UseFatesEdict()
	if FatesEdictDesire > 0 then
		bot:Action_UseAbilityOnEntity(FatesEdict, FatesEdictTarget)
		return
	end
	
	RainOfDestinyDesire, RainOfDestinyTarget = UseRainOfDestiny()
	if RainOfDestinyDesire > 0 then
		bot:Action_UseAbilityOnLocation(RainOfDestiny, RainOfDestinyTarget)
		return
	end
	
	PurifyingFlamesDesire, PurifyingFlamesTarget = UsePurifyingFlames()
	if PurifyingFlamesDesire > 0 then
		bot:Action_UseAbilityOnEntity(PurifyingFlames, PurifyingFlamesTarget)
		return
	end
	
	FortunesEndDesire, FortunesEndTarget = UseFortunesEnd()
	if FortunesEndDesire > 0 then
		bot:Action_UseAbilityOnEntity(FortunesEnd, FortunesEndTarget)
		return
	end
end

function UseFortunesEnd()
	if not FortunesEnd:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = FortunesEnd:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget)
			and not PAF.IsDisabled(BotTarget) then
				return BOT_ACTION_DESIRE_HIGH, BotTarget
			end
		end
	end
	
	return 0
end

function UseFatesEdict()
	if not FatesEdict:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = PurifyingFlames:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local AlliesWithinRange = bot:GetNearbyHeroes(CastRange, false, BOT_MODE_NONE)
	local FilteredAllies = PAF.FilterTrueUnits(AlliesWithinRange)
	
	local WeakestAlly = PAF.GetWeakestUnit(FilteredAllies)
	
	if WeakestAlly ~= nil then
		local EnemiesWithinRange = WeakestAlly:GetNearbyHeroes(1000, true, BOT_MODE_NONE)
		local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
		
		if WeakestAlly:GetHealth() <= (WeakestAlly:GetMaxHealth() * 0.75) then
			return BOT_ACTION_DESIRE_HIGH, WeakestAlly
		end
	end
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	
	if P.IsRetreating(bot) and #FilteredEnemies > 0 then
		local ClosestTarget = PAF.GetClosestUnit(bot, FilteredEnemies)
		return BOT_ACTION_DESIRE_HIGH, ClosestTarget
	end
	
	return 0
end

function UsePurifyingFlames()
	if not PurifyingFlames:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = PurifyingFlames:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	local Damage = PurifyingFlames:GetSpecialValueInt("damage")
	
	local AlliesWithinRange = bot:GetNearbyHeroes(CastRange, false, BOT_MODE_NONE)
	local FilteredAllies = PAF.FilterTrueUnits(AlliesWithinRange)
	
	local WeakestAlly = PAF.GetWeakestUnit(FilteredAllies)
	
	for v, Ally in pairs(FilteredAllies) do
		if Ally:HasModifier("modifier_oracle_false_promise")
		or Ally:HasModifier("modifier_oracle_false_promise_timer")
		or Ally:HasModifier("modifier_oracle_false_promise_invis")
		or Ally:HasModifier("modifier_oracle_fates_edict") then
			return BOT_ACTION_DESIRE_ABSOLUTE, Ally
		end
	end
	
	if WeakestAlly ~= nil then
		local EnemiesWithinRange = WeakestAlly:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
		local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
		
		if WeakestAlly:GetHealth() <= (WeakestAlly:GetMaxHealth() * 0.6)
		and #FilteredEnemies <= 0
		and not WeakestAlly:HasModifier("modifier_oracle_purifying_flames") then
			return BOT_ACTION_DESIRE_HIGH, WeakestAlly
		end
	end
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	
	for v, Enemy in pairs(FilteredEnemies) do
		if Enemy:CanBeSeen() and not PAF.IsMagicImmune(Enemy) then
			local EstimatedDamage = Enemy:GetActualIncomingDamage(Damage, DAMAGE_TYPE_MAGICAL)
				
			if EstimatedDamage >= Enemy:GetHealth() then
				return BOT_ACTION_DESIRE_HIGH, Enemy
			end
		end
	end
	
	return 0
end

function UseFalsePromise()
	if not FalsePromise:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = FalsePromise:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local AlliesWithinRange = bot:GetNearbyHeroes(CastRange, false, BOT_MODE_NONE)
	local FilteredAllies = PAF.FilterTrueUnits(AlliesWithinRange)
	
	local WeakestAlly = PAF.GetWeakestUnit(FilteredAllies)
	
	if WeakestAlly ~= nil then
		local EnemiesWithinRange = WeakestAlly:GetNearbyHeroes(1000, true, BOT_MODE_NONE)
		local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
		
		if #FilteredEnemies > 0 and WeakestAlly:GetHealth() <= (WeakestAlly:GetMaxHealth() * 0.35) then
			return BOT_ACTION_DESIRE_HIGH, WeakestAlly
		end
	end
	
	return 0
end

function UseRainOfDestiny()
	if not RainOfDestiny:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = RainOfDestiny:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	local Radius = RainOfDestiny:GetSpecialValueInt("radius")
	
	if PAF.IsInTeamFight(bot) then
		local AoE = bot:FindAoELocation(true, true, bot:GetLocation(), CastRange, Radius/2, 0, 0)
		if (AoE.count >= 2) then
			return BOT_ACTION_DESIRE_HIGH, AoE.targetloc
		end
	end
	
	return 0
end