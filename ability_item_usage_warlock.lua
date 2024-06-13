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

local FatalBonds = bot:GetAbilityByName("warlock_fatal_bonds")
local ShadowWord = bot:GetAbilityByName("warlock_shadow_word")
local Upheaval = bot:GetAbilityByName("warlock_upheaval")
local RainOfChaos = bot:GetAbilityByName("warlock_rain_of_chaos")

local FatalBondsDesire = 0
local ShadowWordDesire = 0
local UpheavalDesire = 0
local RainOfChaosDesire = 0

local AttackRange
local BotTarget

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	-- The order to use abilities in
	ShadowWordDesire, ShadowWordTarget = UseShadowWord()
	if ShadowWordDesire > 0 then
		bot:Action_UseAbilityOnEntity(ShadowWord, ShadowWordTarget)
		return
	end
	
	FatalBondsDesire, FatalBondsTarget = UseFatalBonds()
	if FatalBondsDesire > 0 then
		bot:Action_UseAbilityOnEntity(FatalBonds, FatalBondsTarget)
		return
	end
	
	RainOfChaosDesire, RainOfChaosTarget = UseRainOfChaos()
	if RainOfChaosDesire > 0 then
		bot:Action_UseAbilityOnLocation(RainOfChaos, RainOfChaosTarget)
		return
	end
	
	UpheavalDesire, UpheavalTarget = UseUpheaval()
	if UpheavalDesire > 0 then
		bot:Action_UseAbilityOnLocation(Upheaval, UpheavalTarget)
		return
	end
end

function UseFatalBonds()
	if not FatalBonds:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = FatalBonds:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	local SearchRadius = FatalBonds:GetSpecialValueInt("search_aoe")
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget) then
				local NearbyHeroes = BotTarget:GetNearbyHeroes(SearchRadius, false, BOT_MODE_NONE)
				local FilteredHeroes = PAF.FilterTrueUnits(NearbyHeroes)
			
				if #FilteredHeroes >= 2 then
					return BOT_ACTION_DESIRE_HIGH, BotTarget
				end
			end
		end
	end
	
	if P.IsInLaningPhase(bot) and bot:GetActiveMode() == BOT_MODE_LANING then
		local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
		local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
		
		if #FilteredEnemies > 0 then
			local WeakestEnemy = PAF.GetWeakestUnit(FilteredEnemies)
			
			if WeakestEnemy ~= nil then
				local NearbyCreeps = WeakestEnemy:GetNearbyLaneCreeps(SearchRadius, false)
				
				if #NearbyCreeps >= 3 then
					return BOT_ACTION_DESIRE_HIGH, WeakestEnemy
				end
			end
		end
	end
	
	return 0
end

function UseShadowWord()
	if not ShadowWord:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = ShadowWord:GetCastRange()
	local HealValue = ShadowWord:GetSpecialValueInt("damage")
	local HealDuration = ShadowWord:GetSpecialValueInt("duration")
	local TotalSWHeal = (HealValue * HealDuration)

	local AlliesWithinRange = bot:GetNearbyHeroes(CastRange, false, BOT_MODE_NONE)
	local FilteredAllies = PAF.FilterTrueUnits(AlliesWithinRange)
	
	local WeakestAlly = PAF.GetWeakestUnit(FilteredAllies)
	
	if WeakestAlly ~= nil then
		local AllyHPRegen = WeakestAlly:GetHealthRegen()
		local AllyHPRegenTotalHeal = (AllyHPRegen * HealDuration)
		
		local TotalHeal = (TotalSWHeal + AllyHPRegenTotalHeal)
		
		if WeakestAlly:GetHealth() < (WeakestAlly:GetMaxHealth() - TotalHeal) then
			return BOT_ACTION_DESIRE_HIGH, WeakestAlly
		end
		
		if WeakestAlly:GetHealth() < (WeakestAlly:GetMaxHealth() * 0.6)
		and WeakestAlly:WasRecentlyDamagedByAnyHero(1) then
			return BOT_ACTION_DESIRE_HIGH, WeakestAlly
		end
	end
	
	return 0
end

function UseUpheaval()
	if not Upheaval:IsFullyCastable() then return 0 end
	if not PAF.IsInTeamFight(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = Upheaval:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget) then
				return BOT_ACTION_DESIRE_HIGH, BotTarget:GetLocation()
			end
		end
	end
	
	return 0
end

function UseRainOfChaos()
	if not RainOfChaos:IsFullyCastable() then return 0 end
	if not PAF.IsInTeamFight(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = Upheaval:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange then
				return BOT_ACTION_DESIRE_HIGH, BotTarget:GetLocation()
			end
		end
	end
	
	return 0
end