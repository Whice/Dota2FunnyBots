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

local Starstorm = bot:GetAbilityByName("mirana_starfall")
local SacredArrow = bot:GetAbilityByName("mirana_arrow")
local Leap = bot:GetAbilityByName("mirana_leap")
local MoonlightShadow = bot:GetAbilityByName("mirana_invis")

local StarstormDesire = 0
local SacredArrowDesire = 0
local LeapDesire = 0
local MoonlightShadowDesire = 0

local AttackRange
local BotTarget

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	-- The order to use abilities in
	MoonlightShadowDesire = UseMoonlightShadow()
	if MoonlightShadowDesire > 0 then
		bot:Action_UseAbility(MoonlightShadow)
		return
	end
	
	SacredArrowDesire, SacredArrowTarget = UseSacredArrow()
	if SacredArrowDesire > 0 then
		bot:Action_UseAbilityOnLocation(SacredArrow, SacredArrowTarget)
		return
	end
	
	LeapDesire = UseLeap()
	if LeapDesire > 0 then
		bot:Action_UseAbility(Leap)
		return
	end
	
	StarstormDesire = UseStarstorm()
	if StarstormDesire > 0 then
		bot:Action_UseAbility(Starstorm)
		return
	end
end

function UseStarstorm()
	if not Starstorm:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local Radius = Starstorm:GetSpecialValueInt("starfall_radius")
	local SecondaryRadius = Starstorm:GetSpecialValueInt("starfall_secondary_radius")
	
	local NearbyUnits = {}
	
	local Heroes = bot:GetNearbyHeroes(Radius, true, BOT_MODE_NONE)
	local FilteredHeroes = PAF.FilterTrueUnits(Heroes)
	for v, Hero in pairs(FilteredHeroes) do
		table.insert(NearbyUnits, Hero)
	end
	
	local Creeps = bot:GetNearbyCreeps(Radius, true)
	for v, Creep in pairs(Creeps) do
		table.insert(NearbyUnits, Creep)
	end
	
	if PAF.IsInTeamFight(bot) then
		if #FilteredHeroes >= 2 then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= SecondaryRadius
			and not PAF.IsMagicImmune(BotTarget) then
				local ClosestUnit = PAF.GetClosestUnit(bot, NearbyUnits)
				
				if ClosestUnit ~= nil then
					if ClosestUnit == BotTarget
					and GetUnitToUnitDistance(bot, BotTarget) <= SecondaryRadius then
						return BOT_ACTION_DESIRE_HIGH
					end
				end
			end
		end
	end
	
	if P.IsRetreating(bot) and #FilteredHeroes > 0 then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	local AttackTarget = bot:GetAttackTarget()
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		if PAF.IsRoshan(AttackTarget)
		and GetUnitToUnitDistance(bot, AttackTarget) <= Radius then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	return 0
end

function UseSacredArrow()
	if not SacredArrow:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = SacredArrow:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	local CastPoint = SacredArrow:GetCastPoint()
	local Radius = SacredArrow:GetSpecialValueInt("arrow_width")
	local Speed = SacredArrow:GetSpecialValueFloat("arrow_speed")
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterUnitsForStun(EnemiesWithinRange)
	
	for v, enemy in pairs(FilteredEnemies) do
		if enemy:IsChanneling()
		or PAF.IsDisabled(enemy) then
			if not IsHeroBetweenMeAndTarget(bot, enemy, enemy:GetLocation(), Radius)
			and not IsCreepBetweenMeAndTarget(bot, enemy, enemy:GetLocation(), Radius) then
				return BOT_ACTION_DESIRE_HIGH, enemy:GetLocation()
			end
		end
	end
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			local MovementStability = BotTarget:GetMovementDirectionStability()
			local ExtrapNum = CastPoint + (GetUnitToUnitDistance(bot, BotTarget) / Speed)
			local PredictedLoc = BotTarget:GetExtrapolatedLocation(ExtrapNum)
			
			if not IsHeroBetweenMeAndTarget(bot, BotTarget, PredictedLoc, Radius) and not IsCreepBetweenMeAndTarget(bot, BotTarget, PredictedLoc, Radius) then
				if GetUnitToLocationDistance(bot, PredictedLoc) <= CastRange then
					return BOT_ACTION_DESIRE_HIGH, PredictedLoc
				elseif GetUnitToUnitDistance(bot, BotTarget) <= CastRange
				and GetUnitToLocationDistance(bot, PredictedLoc) > CastRange then
					return BOT_ACTION_DESIRE_HIGH, bot:GetXUnitsTowardsLocation(PredictedLoc, CastRange)
				end
			end
		end
	end
	
	if P.IsRetreating(bot) then
		local ClosestEnemy = PAF.GetClosestUnit(bot, FilteredEnemies)
		
		if PAF.IsValidHeroAndNotIllusion(ClosestEnemy) then
			local MovementStability = ClosestEnemy:GetMovementDirectionStability()
			local ExtrapNum = CastPoint + (GetUnitToUnitDistance(bot, ClosestEnemy) / Speed)
			local PredictedLoc = ClosestEnemy:GetExtrapolatedLocation(ExtrapNum)
			
			if not IsHeroBetweenMeAndTarget(bot, ClosestEnemy, PredictedLoc, Radius) and not IsCreepBetweenMeAndTarget(bot, ClosestEnemy, PredictedLoc, Radius) then
				if GetUnitToLocationDistance(bot, PredictedLoc) <= CastRange then
					return BOT_ACTION_DESIRE_HIGH, PredictedLoc
				elseif GetUnitToUnitDistance(bot, ClosestEnemy) <= CastRange
				and GetUnitToLocationDistance(bot, PredictedLoc) > CastRange then
					return BOT_ACTION_DESIRE_HIGH, bot:GetXUnitsTowardsLocation(PredictedLoc, CastRange)
				end
			end
		end
	end
	
	local AttackTarget = bot:GetAttackTarget()
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		if PAF.IsRoshan(AttackTarget)
		and GetUnitToUnitDistance(bot, AttackTarget) <= CastRange then
			return BOT_ACTION_DESIRE_HIGH, AttackTarget:GetLocation()
		end
	end
	
	return 0
end

function UseLeap()
	if not Leap:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = Leap:GetSpecialValueInt("leap_distance")
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if bot:IsFacingLocation(BotTarget:GetLocation(), 10)
			and GetUnitToUnitDistance(bot, BotTarget) <= (CastRange + AttackRange)
			and GetUnitToUnitDistance(bot, BotTarget) > AttackRange then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end
	
	if P.IsRetreating(bot) then
		local EnemiesWithinRange = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
		local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
		
		if #FilteredEnemies > 0 then
			if bot:IsFacingLocation(PAF.GetFountainLocation(bot), 20) then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end
	
	return 0
end

function UseMoonlightShadow()
	if not MoonlightShadow:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local FadeDelay = MoonlightShadow:GetSpecialValueFloat("fade_delay")
	
	local Allies = GetUnitList(UNIT_LIST_ALLIED_HEROES)
	local FilteredAllies = PAF.FilterTrueUnits(Allies)
	
	for v, Ally in pairs(FilteredAllies) do
		if not Ally:HasModifier("modifier_item_dustofappearance") then
			local EnemiesWithinRange = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
			local FilteredEnemies = PAF.FilterUnitsForStun(EnemiesWithinRange)
			local EstimatedDamage = PAF.CombineEstimatedDamage(false, FilteredEnemies, Ally, FadeDelay, DAMAGE_TYPE_ALL)
		
			if Ally:IsBot() and P.IsRetreating(Ally) then
				if EstimatedDamage < Ally:GetHealth() and Ally:WasRecentlyDamagedByAnyHero(1) then
					return BOT_ACTION_DESIRE_HIGH
				end
			elseif not Ally:IsBot() then
				if Ally:WasRecentlyDamagedByAnyHero(1) and Ally:GetHealth() < (Ally:GetMaxHealth() * 0.75) then
					if Ally:IsFacingLocation(PAF.GetFountainLocation(Ally), 20)
					and #FilteredEnemies > 0
					and EstimatedDamage < Ally:GetHealth() then
						return BOT_ACTION_DESIRE_HIGH
					end
				end
			end
		end
	end
	
	return 0
end

function IsHeroBetweenMeAndTarget(source, target, endLoc, radius)
	local vStart = source:GetLocation()
	local vEnd = endLoc
	local enemy_heroes = source:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	for i=1, #enemy_heroes do
		if enemy_heroes[i] ~= target
			and enemy_heroes[i] ~= source
		then	
			local tResult = PointToLineDistance(vStart, vEnd, enemy_heroes[i]:GetLocation())
			if tResult ~= nil 
				and tResult.within == true  
				and tResult.distance < radius	
			then
				return true
			end
		end
	end
	
	return false
end

function IsCreepBetweenMeAndTarget(hSource, hTarget, vLoc, nRadius)
	local vStart = hSource:GetLocation()
	local vEnd = vLoc
	
	creeps = hSource:GetNearbyCreeps(1600, true)
	for i,creep in pairs(creeps) do
		local tResult = PointToLineDistance(vStart, vEnd, creep:GetLocation());
		if tResult ~= nil and tResult.within and tResult.distance <= nRadius then
			return true
		end
	end
	
	if hTarget:IsHero() then
		creeps = hTarget:GetNearbyCreeps(1600, false)
		for i,creep in pairs(creeps) do
			local tResult = PointToLineDistance(vStart, vEnd, creep:GetLocation());
			if tResult ~= nil and tResult.within and tResult.distance <= nRadius then
				return true
			end
		end
	end
	
	return false
end