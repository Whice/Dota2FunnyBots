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

local BatteryAssault = bot:GetAbilityByName("rattletrap_battery_assault")
local PowerCogs = bot:GetAbilityByName("rattletrap_power_cogs")
local RocketFlare = bot:GetAbilityByName("rattletrap_rocket_flare")
local Hookshot = bot:GetAbilityByName("rattletrap_hookshot")
local Overclocking = bot:GetAbilityByName("rattletrap_overclocking")
local Jetpack = bot:GetAbilityByName("rattletrap_jetpack")

local BatteryAssaultDesire = 0
local PowerCogsDesire = 0
local RocketFlareDesire = 0
local HookshotDesire = 0
local OverclockingDesire = 0
local JetpackDesire = 0

local AttackRange
local BotTarget

local LastRoshanCheck = -90

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	-- The order to use abilities in
	JetpackDesire = UseJetpack()
	if JetpackDesire > 0 then
		bot:Action_UseAbility(Jetpack)
		return
	end
	
	OverclockingDesire = UseOverclocking()
	if OverclockingDesire > 0 then
		bot:Action_UseAbility(Overclocking)
		return
	end
	
	PowerCogsDesire = UsePowerCogs()
	if PowerCogsDesire > 0 then
		bot:Action_UseAbility(PowerCogs)
		return
	end
	
	BatteryAssaultDesire = UseBatteryAssault()
	if BatteryAssaultDesire > 0 then
		bot:Action_UseAbility(BatteryAssault)
		return
	end
	
	HookshotDesire, HookshotTarget = UseHookshot()
	if HookshotDesire > 0 then
		bot:Action_UseAbilityOnLocation(Hookshot, HookshotTarget)
		return
	end
	
	RocketFlareDesire, RocketFlareTarget = UseRocketFlare()
	if RocketFlareDesire > 0 then
		bot:Action_UseAbilityOnLocation(RocketFlare, RocketFlareTarget)
		return
	end
end

function UseBatteryAssault()
	if not BatteryAssault:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local Radius = BatteryAssault:GetSpecialValueInt("radius")
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(Radius, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	
	for v, Enemy in pairs(FilteredEnemies) do
		if Enemy:IsChanneling()
		and GetUnitToUnitDistance(bot, Enemy) <= Radius
		and not PAF.IsMagicImmune(Enemy) then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= Radius
			and not PAF.IsMagicImmune(BotTarget) then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end
	
	if P.IsRetreating(bot) then
		if #FilteredEnemies > 0
		and bot:WasRecentlyDamagedByAnyHero(1) then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		local AttackTarget = bot:GetAttackTarget()
		
		if PAF.IsRoshan(AttackTarget)
		and GetUnitToUnitDistance(bot, AttackTarget) <= Radius then
			return BOT_ACTION_DESIRE_VERYHIGH
		end
	end
	
	return 0
end

function UsePowerCogs()
	if not PowerCogs:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local Radius = PowerCogs:GetSpecialValueInt("cogs_radius")
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= 160 then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end
	
	if P.IsRetreating(bot) then
		if bot:IsFacingLocation(PAF.GetFountainLocation(bot), 45) then
			if #FilteredEnemies > 0 then
				local IsEnemyInFront = false
				
				for v, Enemy in pairs(FilteredEnemies) do
					if Enemy:CanBeSeen() and (bot:IsFacingLocation(Enemy:GetLocation(), 90) or GetUnitToUnitDistance(bot, Enemy) <= Radius) then
						IsEnemyInFront = true
						break
					end
				end
				
				if not IsEnemyInFront and bot:WasRecentlyDamagedByAnyHero(1) then
					return BOT_ACTION_DESIRE_HIGH
				end
			end
		end
	end
	
	return 0
end

function UseRocketFlare()
	if not RocketFlare:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local allies = GetUnitList(UNIT_LIST_ALLIED_HEROES)
	local FilteredAllies = PAF.FilterTrueUnits(allies)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			return BOT_ACTION_DESIRE_HIGH, BotTarget:GetLocation()
		end
	end
	
	for v, ally in pairs(FilteredAllies) do
		if PAF.IsInTeamFight(ally) then
			local enemies = ally:GetNearbyHeroes(1000, true, BOT_MODE_NONE)
			local FilteredEnemies = PAF.FilterTrueUnits(enemies)
			local target = PAF.GetWeakestUnit(enemies)
			
			if target ~= nil then
				return BOT_ACTION_DESIRE_HIGH, target:GetLocation()
			end
		end
	end
	
	local RadiantLoc = Vector(7871, -7803, 13)
	local DireLoc = Vector(-7782, 7626, 13)
	local RoshanPitLoc = DireLoc
	
	if GetTimeOfDay() >= 0.25 and GetTimeOfDay() < 0.75 then
		RoshanPitLoc = RadiantLoc
	elseif GetTimeOfDay() >= 0.75 or GetTimeOfDay() < 0.25 then
		RoshanPitLoc = DireLoc
	end
	
	if DotaTime() >= (20 * 60) then
		local RoshanKillTime = DotaTime() - GetRoshanKillTime()
		
		if RoshanKillTime >= 480 then
			local EnemyIDs = GetTeamPlayers(GetOpposingTeam())
			local MissingEnemies = 0
			
			for v, EID in pairs(EnemyIDs) do
				if IsHeroAlive(EID) then
					local LSI = GetHeroLastSeenInfo(EID)
					if LSI ~= nil then
						local nLSI = LSI[1]
							
						if nLSI ~= nil then
							if nLSI.time_since_seen >= 7 then
								MissingEnemies = (MissingEnemies + 1)
							end
						end
					end
				end
			end
			
			if (DotaTime() - LastRoshanCheck >= 120)
			and MissingEnemies >= 4
			and bot:GetActiveMode() ~= BOT_MODE_ROSHAN
			and bot:GetActiveMode() ~= BOT_MODE_WARD then
				LastRoshanCheck = DotaTime()
				bot:ActionImmediate_Chat("Checking Roshan", false)
				return BOT_ACTION_DESIRE_HIGH, RoshanPitLoc
			end
		end
	end
	
	return 0
end

function UseHookshot()
	if not Hookshot:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = Hookshot:GetCastRange()
	local CastPoint = Hookshot:GetCastPoint()
	local Radius = Hookshot:GetSpecialValueInt('latch_radius')
	local Speed = Hookshot:GetSpecialValueInt('speed')
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			local MovementStability = BotTarget:GetMovementDirectionStability()
			local ExtrapNum = CastPoint + (GetUnitToUnitDistance(bot, BotTarget) / Speed)
			local PredictedLoc = BotTarget:GetExtrapolatedLocation(ExtrapNum)
			
			--[[if MovementStability < 0.6 then
				PredictedLoc = BotTarget:GetLocation()
			end]]--
			
			if not P.IsHeroBetweenMeAndTarget(bot, BotTarget, PredictedLoc, Radius) and not P.IsCreepBetweenMeAndTarget(bot, BotTarget, PredictedLoc, Radius) then
				if GetUnitToLocationDistance(bot, PredictedLoc) <= CastRange then
					return BOT_ACTION_DESIRE_HIGH, PredictedLoc
				elseif GetUnitToUnitDistance(bot, BotTarget) <= CastRange
				and GetUnitToLocationDistance(bot, PredictedLoc) > CastRange then
					return BOT_ACTION_DESIRE_HIGH, PAF.GetXUnitsTowardsLocation(bot:GetLocation(), PredictedLoc, CastRange)
				end
			end
		end
	end
	
	return 0
end

function UseOverclocking()
	if not Overclocking:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	if not bot:HasScepter() then return 0 end -- This is a scepter ability
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= 1600 then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end
	
	return 0
end

function UseJetpack()
	if Jetpack:IsHidden() then return 0 end
	if not Jetpack:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	
	if P.IsRetreating(bot) then
		if #FilteredEnemies > 0
		and bot:WasRecentlyDamagedByAnyHero(1)
		and bot:IsFacingLocation(PAF.GetFountainLocation(bot), 10) then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	return 0
end