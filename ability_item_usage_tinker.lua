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

local Laser = bot:GetAbilityByName("tinker_laser")
local MarchOfTheMachines = bot:GetAbilityByName("tinker_march_of_the_machines")
local DefenseMatrix = bot:GetAbilityByName("tinker_defense_matrix")
local KeenConveyance = bot:GetAbilityByName("tinker_keen_teleport")
local Rearm = bot:GetAbilityByName("tinker_rearm")
local WarpFlare = bot:GetAbilityByName("tinker_warp_grenade")

local LaserDesire = 0
local MarchOfTheMachinesDesire = 0
local DefenseMatrixDesire = 0
local KeenConveyanceDesire = 0
local RearmDesire = 0
local WarpFlareDesire = 0

local AttackRange
local BotTarget

local StoppedLaning = false

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	if P.IsPushing(bot) then
		if not StoppedLaning then
			StoppedLaning = true
		end
	end
	
	-- The order to use abilities in
	DefenseMatrixDesire, DefenseMatrixTarget = UseDefenseMatrix()
	if DefenseMatrixDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbilityOnEntity(DefenseMatrix, DefenseMatrixTarget)
		return
	end
	
	WarpFlareDesire, WarpFlareTarget = UseWarpFlare()
	if WarpFlareDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbilityOnEntity(WarpFlare, WarpFlareTarget)
		return
	end
	
	LaserDesire, LaserTarget = UseLaser()
	if LaserDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbilityOnEntity(Laser, LaserTarget)
		return
	end
	
	MarchOfTheMachinesDesire, MarchOfTheMachinesTarget = UseMarchOfTheMachines()
	if MarchOfTheMachinesDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbilityOnLocation(MarchOfTheMachines, MarchOfTheMachinesTarget)
		return
	end
	
	KeenConveyanceDesire, KeenConveyanceTarget = UseKeenConveyance()
	if KeenConveyanceDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbilityOnLocation(KeenConveyance, KeenConveyanceTarget)
		return
	end
	
	--[[RearmDesire = UseRearm()
	if RearmDesire > 0 then
		bot:Action_ClearActions(false)
		bot:ActionQueue_UseAbility(Rearm)
		return
	end]]--
end

function UseLaser()
	if not Laser:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = Laser:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	if PAF.IsEngaging(bot) and not StoppedLaning then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget) then
				return BOT_ACTION_DESIRE_HIGH, BotTarget
			end
		end
	end
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	
	local StrongestEnemy = PAF.GetStrongestAttackDamageUnit(FilteredEnemies)
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(StrongestEnemy) then
			if GetUnitToUnitDistance(bot, StrongestEnemy) <= 1600
			and not PAF.IsMagicImmune(StrongestEnemy) then
				return BOT_ACTION_DESIRE_HIGH, StrongestEnemy
			end
		end
	end
	
	EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	
	StrongestEnemy = PAF.GetStrongestAttackDamageUnit(FilteredEnemies)
	if P.IsRetreating(bot) then
		if PAF.IsValidHeroAndNotIllusion(StrongestEnemy) then
			if GetUnitToUnitDistance(bot, StrongestEnemy) <= 1600
			and not PAF.IsMagicImmune(StrongestEnemy) then
				return BOT_ACTION_DESIRE_HIGH, StrongestEnemy
			end
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		local AttackTarget = bot:GetAttackTarget()
		
		if PAF.IsRoshan(AttackTarget)
		and GetUnitToUnitDistance(bot, AttackTarget) <= CastRange then
			return BOT_ACTION_DESIRE_VERYHIGH, AttackTarget
		end
	end
	
	return 0
end

function UseMarchOfTheMachines()
	if not MarchOfTheMachines:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = MarchOfTheMachines:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	local Radius = MarchOfTheMachines:GetSpecialValueInt("radius")
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(Radius, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	
	if PAF.IsEngaging(bot) and #FilteredEnemies >= 2 then
		return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()
	end
	
	local AttackTarget = bot:GetAttackTarget()
	
	if P.IsPushing(bot) then
		if PAF.IsValidCreepTarget(AttackTarget) then
			local NearbyCreeps = bot:GetNearbyCreeps(Radius, true)
			
			if #NearbyCreeps >= 3 then
				return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()
			end
		end
	end
	
	if P.IsDefending(bot) then
		local NearbyCreeps = bot:GetNearbyCreeps(Radius, true)
			
		if #NearbyCreeps >= 2 then
			return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		if PAF.IsRoshan(AttackTarget)
		and GetUnitToUnitDistance(bot, AttackTarget) <= CastRange then
			return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()
		end
	end
	
	if PAF.IsTormentor(AttackTarget) then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	return 0
end

function UseDefenseMatrix()
	if not DefenseMatrix:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = DefenseMatrix:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local AlliesWithinRange = bot:GetNearbyHeroes(CastRange, false, BOT_MODE_NONE)
	local FilteredAllies = PAF.FilterTrueUnits(AlliesWithinRange)
	
	for v, Ally in pairs(FilteredAllies) do
		if PAF.IsDisabled(Ally)
		or PAF.IsTaunted(Ally)
		or (PAF.IsSilencedOrMuted(Ally) and Ally:WasRecentlyDamagedByAnyHero(1)) then
			return BOT_ACTION_DESIRE_ABSOLUTE, Ally
		end
	end
	
	if PAF.IsInTeamFight(bot) then
		local StrongestAlly = PAF.GetStrongestAttackDamageUnit(FilteredAllies)
		
		if StrongestAlly ~= nil and not StrongestAlly:HasModifier("modifier_tinker_defense_matrix") then
			return BOT_ACTION_DESIRE_ABSOLUTE, StrongestAlly
		end
	end
	
	if #FilteredAllies > 0 then
		local WeakestAlly = PAF.GetWeakestUnit(FilteredAllies)
		if WeakestAlly:GetHealth() <= (WeakestAlly:GetMaxHealth() * 0.4)
		and WeakestAlly:WasRecentlyDamagedByAnyHero(2)
		and not WeakestAlly:HasModifier("modifier_tinker_defense_matrix") then
			return BOT_ACTION_DESIRE_ABSOLUTE, WeakestAlly
		end
	end
	
	local AttackTarget = bot:GetAttackTarget()
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		if PAF.IsRoshan(AttackTarget) then
			local NonMatrixedAllies = {}
			for v, Ally in pairs(FilteredAllies) do
				if not Ally:HasModifier("modifier_tinker_defense_matrix") then
					table.insert(NonMatrixedAllies, Ally)
				end
			end
			
			local StrongestAlly = PAF.GetStrongestAttackDamageUnit(NonMatrixedAllies)
			
			if StrongestAlly ~= nil then
				return BOT_ACTION_DESIRE_ABSOLUTE, StrongestAlly
			end
		end
	end
	
	return 0
end

function UseKeenConveyance()
	if not KeenConveyance:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= 1600 then
				return 0
			end
		end
	end
	
	if P.IsRetreating(bot)
	or bot:GetActiveMode() == BOT_MODE_WARD
	or bot:GetActiveMode() == BOT_MODE_ITEM
	or bot:GetActiveMode() == BOT_MODE_ROSHAN
	or bot:GetActiveMode() == BOT_MODE_EVASIVE_MANEUVERS
	or bot:GetActiveMode() == BOT_MODE_DEFEND_ALLY
	or bot:GetActiveMode() == BOT_MODE_FARM
	or bot:GetActiveMode() == BOT_MODE_TEAM_ROAM
	or bot:GetActiveMode() == BOT_MODE_SIDE_SHOP
	or bot:GetActiveMode() == BOT_MODE_SECRET_SHOP then
		return 0
	end
	
	local ManaThreshold = 0
	ManaThreshold = (ManaThreshold + Laser:GetManaCost())
	ManaThreshold = (ManaThreshold + MarchOfTheMachines:GetManaCost())
	ManaThreshold = (ManaThreshold + DefenseMatrix:GetManaCost())
	
	if bot:GetMana() < ManaThreshold and bot:DistanceFromFountain() > 1600 then
		return BOT_ACTION_DESIRE_ABSOLUTE, PAF.GetFountainLocation(bot)
	end
	
	local TPLevel = KeenConveyance:GetLevel()
	
	local Allies = GetUnitList(UNIT_LIST_ALLIED_HEROES)
	local FilteredAllies = PAF.FilterTrueUnits(Allies)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= 1600 then
				return 0
			end
		end
	end
	
	if TPLevel >= 3 then
		for v, Ally in pairs(FilteredAllies) do
			if PAF.IsInTeamFight(Ally) then
				local NearbyAllies = Ally:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
				local FilteredNA = PAF.FilterTrueUnits(NearbyAllies)
				table.insert(FilteredNA, bot)
				local NearbyEnemies = Ally:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
				local FilteredEnemies = PAF.FilterTrueUnits(NearbyEnemies)
				
				local AllyPower = PAF.CombineOffensivePower(FilteredNA, true)
				local EnemyPower = PAF.CombineOffensivePower(FilteredEnemies, true)
				
				if AllyPower > EnemyPower then
					if GetUnitToUnitDistance(bot, Ally) > 3200 then
						return BOT_ACTION_DESIRE_ABSOLUTE, Ally:GetLocation()
					end
				end
			end
		end
	end
	
	if TPLevel >= 2 then
		local AlliedCreeps = GetUnitList(UNIT_LIST_ALLIED_CREEPS)
		
		for v, Ally in pairs(FilteredAllies) do
			if PAF.IsInTeamFight(Ally) then
				local NearbyAllies = Ally:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
				local FilteredNA = PAF.FilterTrueUnits(NearbyAllies)
				table.insert(FilteredNA, bot)
				local NearbyEnemies = Ally:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
				local FilteredEnemies = PAF.FilterTrueUnits(NearbyEnemies)
				
				local AllyPower = PAF.CombineOffensivePower(FilteredNA, true)
				local EnemyPower = PAF.CombineOffensivePower(FilteredEnemies, true)
				
				if AllyPower > EnemyPower then
					local ClosestCreepToAlly = PAF.GetClosestUnit(Ally, AlliedCreeps)
					
					if GetUnitToUnitDistance(bot, Ally) > GetUnitToUnitDistance(ClosestCreepToAlly, Ally) then
						if GetUnitToUnitDistance(bot, Ally) > 3200
						and GetUnitToUnitDistance(ClosestCreepToAlly, Ally) <= 1600 then
							return BOT_ACTION_DESIRE_ABSOLUTE, Ally:GetLocation()
						end
					end
				end
			end
		end
	end
	
	if TPLevel >= 1 then
		local AlliedBuildings = GetUnitList(UNIT_LIST_ALLIED_BUILDINGS)
		
		for v, Ally in pairs(FilteredAllies) do
			if PAF.IsInTeamFight(Ally) then
				local NearbyAllies = Ally:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
				local FilteredNA = PAF.FilterTrueUnits(NearbyAllies)
				table.insert(FilteredNA, bot)
				local NearbyEnemies = Ally:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
				local FilteredEnemies = PAF.FilterTrueUnits(NearbyEnemies)
				
				local AllyPower = PAF.CombineOffensivePower(FilteredNA, true)
				local EnemyPower = PAF.CombineOffensivePower(FilteredEnemies, true)
				
				if AllyPower > EnemyPower then
					local ClosestBuildingToAlly = PAF.GetClosestUnit(Ally, AlliedBuildings)
					
					if GetUnitToUnitDistance(bot, Ally) > GetUnitToUnitDistance(ClosestBuildingToAlly, Ally) then
						if GetUnitToUnitDistance(bot, Ally) > 3200
						and GetUnitToUnitDistance(ClosestBuildingToAlly, Ally) <= 1600
						and not string.find(ClosestBuildingToAlly:GetUnitName(), "lantern") then
							return BOT_ACTION_DESIRE_ABSOLUTE, Ally:GetLocation()
						end
					end
				end
			end
		end
	end
	
	if P.IsPushing(bot) then
		local LaneFrontLocation
		local LaneFrontAmount
		
		if bot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP then
			LaneFrontLocation = GetLaneFrontLocation(bot:GetTeam(), LANE_TOP, -500)
			LaneFrontAmount = GetLaneFrontAmount(bot:GetTeam(), LANE_TOP, true)
		elseif bot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID then
			LaneFrontLocation = GetLaneFrontLocation(bot:GetTeam(), LANE_MID, -500)
			LaneFrontAmount = GetLaneFrontAmount(bot:GetTeam(), LANE_MID, true)
		elseif bot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT then
			LaneFrontLocation = GetLaneFrontLocation(bot:GetTeam(), LANE_BOT, -500)
			LaneFrontAmount = GetLaneFrontAmount(bot:GetTeam(), LANE_BOT, true)
		end
		
		if TPLevel >= 2 then
			if GetUnitToLocationDistance(bot, LaneFrontLocation) > 3200
			and not IsEnemyNearLane(LaneFrontLocation, LaneFrontAmount) then
				return BOT_ACTION_DESIRE_ABSOLUTE, LaneFrontLocation
			end
		elseif TPLevel == 1 then
			local AlliedBuildings = GetUnitList(UNIT_LIST_ALLIED_BUILDINGS)
			local ClosestBuilding = nil
			local ClosestDist = 99999999
			
			if GetUnitToLocationDistance(bot, LaneFrontLocation) > 3200 then
				for v, Building in pairs(AlliedBuildings) do
					if not string.find(Building:GetUnitName(), "lantern") then
						if GetUnitToLocationDistance(Building, LaneFrontLocation) < ClosestDist then
							ClosestBuilding = Building
							ClosestDist = GetUnitToLocationDistance(Building, LaneFrontLocation)
						end
					end
				end
				
				if PAF.IsValidBuildingTarget(ClosestBuilding) then
					if GetUnitToLocationDistance(bot, LaneFrontLocation) > ClosestDist
					and not IsEnemyNearLane(LaneFrontLocation, LaneFrontAmount) then
						return BOT_ACTION_DESIRE_ABSOLUTE, LaneFrontLocation
					end
				end
			end
		end
	end
	
	if P.IsDefending(bot) then
		local MinDistanceForTP = 3200
		local MaxDistanceFromBuilding = 800
		
		if (bot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_TOP
		or bot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_MID
		or bot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_BOT) then
			local FurthestBuilding = nil
			
			if bot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_TOP then
				FurthestBuilding = PAF.GetFurthestBuildingOnLane(LANE_TOP)
			elseif bot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_MID then
				FurthestBuilding = PAF.GetFurthestBuildingOnLane(LANE_MID)
			elseif bot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_BOT then
				FurthestBuilding = PAF.GetFurthestBuildingOnLane(LANE_BOT)
			end
			
			if FurthestBuilding ~= nil then
				if GetUnitToUnitDistance(bot, FurthestBuilding) >= MinDistanceForTP then
					local tpLoc = PAF.GetXUnitsTowardsLocation(FurthestBuilding:GetLocation(), PAF.GetFountainLocation(bot), MaxDistanceFromBuilding)
					return BOT_ACTION_DESIRE_ABSOLUTE, tpLoc
				end
			end
		end
	end
	
	return 0
end

function UseRearm()
	if not Rearm:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	if (P.IsRetreating(bot) and bot:DistanceFromFountain() <= 0) or not PAF.IsEngaging(bot) then
		if not Laser:IsFullyCastable()
		or not MarchOfTheMachines:IsFullyCastable()
		or not DefenseMatrix:IsFullyCastable()
		or not KeenConveyance:IsFullyCastable() then
			return BOT_ACTION_DESIRE_VERYHIGH
		end
	end
	
	if PAF.IsInTeamFight(bot) then
		if not Laser:IsFullyCastable()
		and not MarchOfTheMachines:IsFullyCastable()
		and not DefenseMatrix:IsFullyCastable() then
			return BOT_ACTION_DESIRE_VERYHIGH
		end
	elseif PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= 1600 then
				local AlliesWithinRange = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
				local FilteredAllies = PAF.FilterTrueUnits(AlliesWithinRange)
				local CombinedOffensivePower = (PAF.CombineOffensivePower(FilteredAllies, false) / 2)
				
				if CombinedOffensivePower < BotTarget:GetHealth() then
					if not Laser:IsFullyCastable()
					and not MarchOfTheMachines:IsFullyCastable()
					and not DefenseMatrix:IsFullyCastable() then
						return BOT_ACTION_DESIRE_VERYHIGH
					end
				end
			end
		end
	end
	
	return 0
end

function UseWarpFlare()
	if not WarpFlare:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = WarpFlare:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterUnitsForStun(EnemiesWithinRange)
	
	for v, enemy in pairs(FilteredEnemies) do
		if enemy:IsChanneling() then
			return BOT_ACTION_DESIRE_HIGH, enemy
		end
	end
	
	if PAF.IsInTeamFight(bot) then
		local StrongestEnemy = PAF.GetStrongestPowerUnit(FilteredEnemies)
		
		if PAF.IsValidHeroAndNotIllusion(StrongestEnemy) then
			if GetUnitToUnitDistance(bot, StrongestEnemy) <= CastRange
			and not PAF.IsMagicImmune(StrongestEnemy) then
				return BOT_ACTION_DESIRE_HIGH, StrongestEnemy
			end
		end
	end
	
	if P.IsRetreating(bot) and #EnemiesWithinRange > 0 then
		local ClosestTarget = PAF.GetClosestUnit(bot, FilteredEnemies)
		return BOT_ACTION_DESIRE_HIGH, ClosestTarget
	end
	
	return 0
end


function IsEnemyNearLane(lane, LFA)
	local EnemiesNearLaneFront = 0
		
	for v, Enemy in pairs(GetTeamPlayers(GetOpposingTeam())) do
		if IsHeroAlive(Enemy) then
			local LSI = GetHeroLastSeenInfo(Enemy)
			if LSI ~= nil then
				local nLSI = LSI[1]
				if nLSI ~= nil then
					local TSSVar = RemapValClamped(LFA, 0.0, 1.0, 0.0, 20.0)
					
					if P.GetDistance(lane, nLSI.location) <= 1600
					and nLSI.time_since_seen <= TSSVar then
						EnemiesNearLaneFront = (EnemiesNearLaneFront + 1)
					end
				end
			end
		end
	end
	
	if EnemiesNearLaneFront > 0 then
		return true
	else
		return false
	end
end