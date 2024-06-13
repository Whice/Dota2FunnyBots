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

local Spear = bot:GetAbilityByName("mars_spear")
local GodsRebuke = bot:GetAbilityByName("mars_gods_rebuke")
local Bulwark = bot:GetAbilityByName("mars_bulwark")
local ArenaOfBlood = bot:GetAbilityByName("mars_arena_of_blood")

local SpearDesire = 0
local GodsRebukeDesire = 0
local BulwarkDesire = 0
local ArenaOfBloodDesire = 0

local AttackRange
local BotTarget
local manathreshold = 0

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	manathreshold = 100
	manathreshold = manathreshold + Spear:GetManaCost()
	manathreshold = manathreshold + GodsRebuke:GetManaCost()
	manathreshold = manathreshold + ArenaOfBlood:GetManaCost()
	
	-- The order to use abilities in
	ArenaOfBloodDesire, ArenaOfBloodTarget = UseArenaOfBlood()
	if ArenaOfBloodDesire > 0 then
		bot:Action_UseAbilityOnLocation(ArenaOfBlood, ArenaOfBloodTarget)
		return
	end
	
	SpearDesire, SpearTarget = UseSpear()
	if SpearDesire > 0 then
		bot:Action_UseAbilityOnLocation(Spear, SpearTarget)
		return
	end
	
	GodsRebukeDesire, GodsRebukeTarget = UseGodsRebuke()
	if GodsRebukeDesire > 0 then
		bot:Action_UseAbilityOnLocation(GodsRebuke, GodsRebukeTarget)
		return
	end
	
	BulwarkDesire = UseBulwark()
	if BulwarkDesire > 0 then
		bot:Action_UseAbility(Bulwark)
		return
	end
end

function UseSpear()
	if not Spear:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = Spear:GetSpecialValueInt("spear_range")
	local CastRange = PAF.GetProperCastRange(CR)
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterUnitsForStun(EnemiesWithinRange)
	
	for v, enemy in pairs(FilteredEnemies) do
		if enemy:IsChanneling() then
			return BOT_ACTION_DESIRE_HIGH, enemy:GetLocation()
		end
	end
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget)
			and not PAF.IsDisabled(BotTarget) then
				return BOT_ACTION_DESIRE_HIGH, BotTarget:GetExtrapolatedLocation(0.5)
			end
		end
	end
	
	if P.IsRetreating(bot) and #EnemiesWithinRange > 0 then
		local ClosestTarget = PAF.GetClosestUnit(bot, EnemiesWithinRange)
		return BOT_ACTION_DESIRE_HIGH, ClosestTarget:GetExtrapolatedLocation(0.5)
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		local AttackTarget = bot:GetAttackTarget()
		
		if PAF.IsRoshan(AttackTarget)
		and GetUnitToUnitDistance(bot, AttackTarget) <= CastRange then
			return BOT_ACTION_DESIRE_VERYHIGH, AttackTarget:GetExtrapolatedLocation(0.5)
		end
	end
	
	return 0
end

function UseGodsRebuke()
	if not GodsRebuke:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = GodsRebuke:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	local Radius = GodsRebuke:GetSpecialValueInt("spear_width")
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterUnitsForStun(EnemiesWithinRange)
	
	for v, enemy in pairs(FilteredEnemies) do
		if enemy:IsChanneling() then
			return BOT_ACTION_DESIRE_HIGH, enemy:GetLocation()
		end
	end
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget)
			and not PAF.IsDisabled(BotTarget) then
				return BOT_ACTION_DESIRE_HIGH, BotTarget:GetLocation()
			end
		end
	end
	
	if P.IsRetreating(bot) and #EnemiesWithinRange > 0 then
		local ClosestTarget = PAF.GetClosestUnit(bot, EnemiesWithinRange)
		return BOT_ACTION_DESIRE_HIGH, ClosestTarget:GetLocation()
	end
	
	local AttackTarget = bot:GetAttackTarget()
	
	if not P.IsInLaningPhase() then
		if AttackTarget ~= nil and AttackTarget:IsCreep() then
			local NearbyCreeps = bot:GetNearbyCreeps((CastRange + Radius), true)
			local AoECount = PAF.GetUnitsNearTarget(AttackTarget:GetLocation(), NearbyCreeps, Radius)
			
			if AoECount > 0 and (bot:GetMana() - GodsRebuke:GetManaCost()) > manathreshold then
				return BOT_ACTION_DESIRE_HIGH, AttackTarget:GetLocation()
			end
		end
		
		if bot:GetActiveMode() == BOT_MODE_ROSHAN then	
			if PAF.IsRoshan(AttackTarget)
			and GetUnitToUnitDistance(bot, AttackTarget) <= CastRange then
				return BOT_ACTION_DESIRE_VERYHIGH, AttackTarget:GetLocation()
			end
		end
	end
	
	return 0
end

function UseBulwark()
	if not Bulwark:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	if ArenaOfBlood:IsFullyCastable()
	or Spear:IsFullyCastable()
	or GodsRebuke:IsFullyCastable() then
		if Bulwark:GetToggleState() == true then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	local Radius = GodsRebuke:GetSpecialValueInt("redirect_range")
	
	local AlliesWithinRange = bot:GetNearbyHeroes(Radius, false, BOT_MODE_NONE)
	local FilteredAllies = PAF.FilterTrueUnits(AlliesWithinRange)
	
	if PAF.IsInTeamFight(bot)
	and #FilteredAllies >= 2 then
		if Bulwark:GetToggleState() == false then
			return BOT_ACTION_DESIRE_HIGH
		else
			return 0
		end
	end
	
	if Bulwark:GetToggleState() == true then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	return 0
end

function UseArenaOfBlood()
	if not ArenaOfBlood:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	if not PAF.IsInTeamFight(bot) then return 0 end
	
	local CR = ArenaOfBlood:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	local Radius = ArenaOfBlood:GetSpecialValueInt("radius")
	
	local AoE = bot:FindAoELocation(true, true, bot:GetLocation(), CastRange, Radius/2, 0, 0)
	if (AoE.count >= 1) then
		return BOT_ACTION_DESIRE_HIGH, AoE.targetloc
	end
	
	return 0
end