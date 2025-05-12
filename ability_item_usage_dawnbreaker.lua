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

local Starbreaker = bot:GetAbilityByName("dawnbreaker_fire_wreath")
local CelestialHammer = bot:GetAbilityByName("dawnbreaker_celestial_hammer")
local Luminosity = bot:GetAbilityByName("dawnbreaker_luminosity")
local SolarGuardian = bot:GetAbilityByName("dawnbreaker_solar_guardian")
local Converge = bot:GetAbilityByName("dawnbreaker_converge")

local StarbreakerDesire = 0
local CelestialHammerDesire = 0
local SolarGuardianDesire = 0
local ConvergeDesire = 0

local AttackRange
local BotTarget
local manathreshold = 0

local LastCelestialHammerTime = -90

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	manathreshold = 50
	manathreshold = manathreshold + Starbreaker:GetManaCost()
	manathreshold = manathreshold + CelestialHammer:GetManaCost()
	manathreshold = manathreshold + SolarGuardian:GetManaCost()
	
	-- The order to use abilities in
	StarbreakerDesire, StarbreakerTarget = UseStarbreaker()
	if StarbreakerDesire > 0 then
		bot:Action_UseAbilityOnLocation(Starbreaker, StarbreakerTarget)
		return
	end
	
	CelestialHammerDesire, CelestialHammerTarget = UseCelestialHammer()
	if CelestialHammerDesire > 0 then
		LastCelestialHammerTime = DotaTime()
		bot:Action_UseAbilityOnLocation(CelestialHammer, CelestialHammerTarget)
		return
	end
	
	SolarGuardianDesire, SolarGuardianTarget = UseSolarGuardian()
	if SolarGuardianDesire > 0 then
		bot:Action_UseAbilityOnLocation(SolarGuardian, SolarGuardianTarget)
		return
	end
	
	ConvergeDesire = UseConverge()
	if ConvergeDesire > 0 then
		bot:Action_UseAbility(Converge)
		return
	end
end

function UseStarbreaker()
	if not Starbreaker:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = 300
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterUnitsForStun(EnemiesWithinRange)
	
	for v, enemy in pairs(FilteredEnemies) do
		if enemy:IsChanneling() then
			return 1, enemy:GetLocation()
		end
	end
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget)
			and PAF.IsDisabled(BotTarget) or BotTarget:GetCurrentMovementSpeed() <= 300 then
				return 1, BotTarget:GetLocation()
			end
		end
	end
	
	local AttackTarget = bot:GetAttackTarget()
	
	if bot:GetActiveMode() == BOT_MODE_FARM
	and not P.IsInLaningPhase()
	and AttackTarget ~= nil then
		local NearbyCreeps = bot:GetNearbyCreeps(CastRange, true)
		local AoECount = PAF.GetUnitsNearTarget(AttackTarget:GetLocation(), NearbyCreeps, CastRange)
				
		if AoECount >= 3 then
			if (bot:GetMana() - Starbreaker:GetManaCost()) > manathreshold then
				return 1, AttackTarget:GetLocation()
			end
		end
	end
	
	return 0
end

function UseCelestialHammer()
	if not CelestialHammer:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = CelestialHammer:GetSpecialValueInt("range")
	local CastPoint = CelestialHammer:GetCastPoint()
	local Speed = CelestialHammer:GetSpecialValueInt("projectile_speed")
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			local MovementStability = BotTarget:GetMovementDirectionStability()
			local ExtrapNum = CastPoint + (GetUnitToUnitDistance(bot, BotTarget) / Speed)
			local PredictedLoc = BotTarget:GetExtrapolatedLocation(ExtrapNum + 2)
			
			if GetUnitToLocationDistance(bot, PredictedLoc) <= CastRange
			and GetUnitToLocationDistance(bot, PredictedLoc) > 300
			and GetUnitToUnitDistance(bot, BotTarget) > 300 then
				return BOT_ACTION_DESIRE_HIGH, PredictedLoc
			elseif GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and GetUnitToLocationDistance(bot, PredictedLoc) > CastRange
			and GetUnitToLocationDistance(bot, PredictedLoc) > 300
			and GetUnitToUnitDistance(bot, BotTarget) > 300 then
				return BOT_ACTION_DESIRE_HIGH, PAF.GetXUnitsTowardsLocation(bot:GetLocation(), PredictedLoc, CastRange)
			end
		end
	end
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	
	if P.IsRetreating(bot) and #FilteredEnemies > 0 then
		return 1, PAF.GetXUnitsTowardsLocation(bot:GetLocation(), PAF.GetFountainLocation(bot), CastRange)
	end
	
	return 0
end

function UseSolarGuardian()
	if not SolarGuardian:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= 1600 then
				return 0
			end
		end
	end
	
	local Allies = GetUnitList(UNIT_LIST_ALLIED_HEROES)
	local FilteredAllies = PAF.FilterTrueUnits(Allies)
	
	for v, Ally in pairs(FilteredAllies) do
		if Ally ~= bot and GetUnitToUnitDistance(bot, Ally) > 3200 then
			if PAF.IsInTeamFight(Ally) then
				local EnemiesWithinRange = Ally:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
				local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
				
				local WeakestEnemy = PAF.GetWeakestUnit(FilteredEnemies)
				
				if WeakestEnemy ~= nil and GetUnitToUnitDistance(bot, WeakestEnemy) > 3200 then
					return 1, WeakestEnemy:GetLocation()
				end
			end
		end
	end
	
	return 0
end

function UseConverge()
	if not Converge:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	if Converge:IsHidden() then return 0 end
	
	if (DotaTime() - LastCelestialHammerTime) >= 1 then
		return 1
	end
	
	return 0
end