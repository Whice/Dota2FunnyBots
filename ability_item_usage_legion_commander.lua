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

local OverwhelmingOdds = bot:GetAbilityByName("legion_commander_overwhelming_odds")
local PressTheAttack = bot:GetAbilityByName("legion_commander_press_the_attack")
local MomentOfCourage = bot:GetAbilityByName("legion_commander_moment_of_courage")
local Duel = bot:GetAbilityByName("legion_commander_duel")

local OverwhelmingOddsDesire = 0
local PressTheAttackDesire = 0
local DuelDesire = 0

local AttackRange
local BotTarget

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	-- The order to use abilities in
	OverwhelmingOddsDesire = UseOverwhelmingOdds()
	if OverwhelmingOddsDesire > 0 then
		bot:Action_UseAbility(OverwhelmingOdds)
		return
	end
	
	PressTheAttackDesire, PressTheAttackTarget = UsePressTheAttack()
	if PressTheAttackDesire > 0 then
		bot:Action_UseAbilityOnEntity(PressTheAttack, PressTheAttackTarget)
		return
	end
	
	DuelDesire, DuelTarget = UseDuel()
	if DuelDesire > 0 then
		bot:Action_UseAbilityOnEntity(Duel, DuelTarget)
		return
	end
end

function UseOverwhelmingOdds()
	if not OverwhelmingOdds:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = OverwhelmingOdds:GetSpecialValueInt("radius")
	local Damage = OverwhelmingOdds:GetSpecialValueInt("damage")
	local DamagePerCreep = OverwhelmingOdds:GetSpecialValueInt("damage_per_unit")
	local DamagePerHero = OverwhelmingOdds:GetSpecialValueInt("damage_per_hero")
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	local CreepsWithinRange = bot:GetNearbyCreeps(CastRange, true)
	
	local TotalDamage = Damage
	TotalDamage = (TotalDamage + (#FilteredEnemies * DamagePerHero))
	TotalDamage = (TotalDamage + (#CreepsWithinRange * DamagePerCreep))
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange then
				local EstimatedDamage = BotTarget:GetActualIncomingDamage(TotalDamage, DAMAGE_TYPE_MAGICAL)
				if EstimatedDamage >= (Damage * 2) or EstimatedDamage >= BotTarget:GetHealth() then
					return BOT_ACTION_DESIRE_HIGH
				end
			end
		end
	end
	
	if P.IsRetreating(bot) then
		if #FilteredEnemies > 0 then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		local AttackTarget = bot:GetAttackTarget()
		
		if PAF.IsRoshan(AttackTarget)
		and GetUnitToUnitDistance(bot, AttackTarget) <= CastRange then
			return BOT_ACTION_DESIRE_VERYHIGH
		end
	end
	
	return 0
end

function UsePressTheAttack()
	if not PressTheAttack:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = PressTheAttack:GetCastRange()
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(1000, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	
	if #EnemiesWithinRange >= 1 and (PAF.IsEngaging(bot) or P.IsRetreating(bot)) then
		return BOT_ACTION_DESIRE_HIGH, bot
	end
	
	local AlliesWithinRange = bot:GetNearbyHeroes(CastRange, false, BOT_MODE_NONE)
	local FilteredAllies = PAF.FilterTrueUnits(AlliesWithinRange)
	
	local WeakestAlly = PAF.GetWeakestUnit(FilteredAllies)
	
	if WeakestAlly:GetHealth() < (WeakestAlly:GetMaxHealth() * 0.4)
	and WeakestAlly:WasRecentlyDamagedByAnyHero(1) then
		return BOT_ACTION_DESIRE_HIGH, WeakestAlly
	end
	
	if PAF.IsInTeamFight(bot) then
		for v, Ally in pairs(FilteredAllies) do
			if PAF.IsDisabled(Ally)
			or PAF.IsTaunted(Ally)
			or PAF.IsSilencedOrMuted(Ally) then
				return BOT_ACTION_DESIRE_HIGH, Ally
			end
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		local AttackTarget = bot:GetAttackTarget()
		
		if PAF.IsRoshan(AttackTarget) then
			return BOT_ACTION_DESIRE_VERYHIGH, bot
		end
	end
	
	return 0
end

function UseDuel()
	if not Duel:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = Duel:GetCastRange()
	local DuelDuration = Duel:GetSpecialValueInt("duration")
	
	local AlliesWithinRange = bot:GetNearbyHeroes(800, false, BOT_MODE_NONE)
	local FilteredAllies = PAF.FilterTrueUnits(AlliesWithinRange)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= (CastRange * 2) then
				local EstimatedDamage = bot:GetEstimatedDamageToTarget(true, BotTarget, DuelDuration, DAMAGE_TYPE_PHYSICAL)
				
				for v, Ally in pairs(FilteredAllies) do
					if Ally ~= bot then
						local AllyEstDmg = Ally:GetEstimatedDamageToTarget(true, BotTarget, DuelDuration, DAMAGE_TYPE_ALL)
						EstimatedDamage = (EstimatedDamage + (AllyEstDmg / 2))
					end
				end
				
				if bot:GetHealth() > BotTarget:GetHealth() then
					if EstimatedDamage > BotTarget:GetHealth() then
						return BOT_ACTION_DESIRE_HIGH, BotTarget
					end
				end
			end
		end
	end
	
	return 0
end