local bot = GetBot()

local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")
local PAF = require(GetScriptDirectory() ..  "/Library/PhalanxAbilityFunctions")

local NeutralCamps = {}
local SuitableCamps = {}

local LastUpdatedTime = 0

local FarmMode = "FarmLane"
local LaneToFarm = LANE_MID
local HealthyToFarmJungle = true

local FinishedLaning = false
local TeamAncient = nil

local LastHitCreepTarget = nil

function GetDesire()
	UpdateNeutralCamps()
	TeamAncient = GetAncient(bot:GetTeam())
	
	if ShouldLastHitCreep() and PAF.IsValidCreepTarget(LastHitCreepTarget) then
		return 0.96
	end
	
	if not FinishedLaning and P.IsPushing(bot) then
		FinishedLaning = true -- Prevent bots from prematurely entering farm mode when they can still safely lane
	end
	
	if bot:GetUnitName() == "npc_dota_hero_enchantress"
	and DotaTime() >= 60 then
		local Enchant = bot:GetAbilityByName("enchantress_enchant")
		
		-- Added a level requirement so Enchantress isn't leaving lane often
		if Enchant:IsFullyCastable() and Enchant:GetLevel() >= 3 then -- change to 3
			if bot.DominatedUnitOne == nil
			or (bot:HasScepter() and bot.DominatedUnitTwo == nil) then
				FarmMode = "DominateCreep"
				return BOT_MODE_DESIRE_VERYHIGH
			end
		end
	end
	
	if bot:GetUnitName() == "npc_dota_hero_chen"
	and DotaTime() >= 60 then
		local HolyPersuasion = bot:GetAbilityByName("chen_holy_persuasion")
		local HandOfGod = bot:GetAbilityByName("chen_hand_of_god")
		local AllowedAncients = HandOfGod:GetSpecialValueInt("ancient_creeps_scepter")
		
		-- Added a level requirement so Enchantress isn't leaving lane often
		if HolyPersuasion:IsFullyCastable() then
			local MaxUnits = HolyPersuasion:GetSpecialValueInt("max_units")
			
			if bot.DominatedUnits < MaxUnits or bot.DominatedAncients < AllowedAncients then
				FarmMode = "DominateCreep"
				return BOT_MODE_DESIRE_VERYHIGH
			end
		end
	end
	
	--[[if bot:GetUnitName() == "npc_dota_hero_doom_bringer"
	and DotaTime() >= 60 then
		local Devour = bot:GetAbilityByName("doom_bringer_devour")
		
		-- Added a level requirement so Enchantress isn't leaving lane often
		if Devour:IsFullyCastable() then
			local CreepLevel = Devour:GetSpecialValueInt("creep_level")
			
			if bot:GetAbilityInSlot(3) == nil
			or bot:GetAbilityInSlot(3):GetName() == ""
			or bot:GetAbilityInSlot(3):GetName() == "doom_bringer_empty1"
			or bot.CreepLevelConsumed < CreepLevel then
				FarmMode = "DominateCreep"
				return BOT_MODE_DESIRE_VERYHIGH
			end
		end
	end]]--
	
	if P.IsInLaningPhase()
	or not FinishedLaning
	or bot:GetActiveMode() == BOT_MODE_SECRET_SHOP then
		return 0
	end
	
	if HealthyToFarmJungle then
		if bot:GetHealth() < (bot:GetMaxHealth() * 0.25) then
			HealthyToFarmJungle = false
		end
	elseif not HealthyToFarmJungle then
		if bot:GetHealth() >= (bot:GetMaxHealth() * 0.9) then
			HealthyToFarmJungle = true
		end
	end

	if IsCoreHero(bot) then
		if IsHeroSuitableToFarm(bot) then
			local SuitableCamps = GetSuitableCamps()
			
			local FarmLaneDesire = 0
			local FarmJungleDesire = 0
			if P.IsMeepoClone(bot) then
				FarmJungleDesire = 0.75
			end
			
			-- Farm lane desires
			--[[local FarmTopDesire = GetFarmLaneDesire(LANE_TOP)
			local FarmMidDesire = GetFarmLaneDesire(LANE_MID)
			local FarmBotDesire = GetFarmLaneDesire(LANE_BOT)]]--
			
			local FarmTopDesire = (1 - GetLaneFrontAmount(GetOpposingTeam(), LANE_TOP, true))
			local FarmMidDesire = (1 - GetLaneFrontAmount(GetOpposingTeam(), LANE_MID, true))
			local FarmBotDesire = (1 - GetLaneFrontAmount(GetOpposingTeam(), LANE_BOT, true))
			
			local ClosestLaneToBot = GetClosestLaneToBot()
			local ClosestCoreToLane = GetClosestCoreToLane(ClosestLaneToBot)
			
			if ClosestCoreToLane == bot then
				if ClosestLaneToBot == LANE_TOP then
					FarmLaneDesire = FarmTopDesire
					LaneToFarm = LANE_TOP
				end
				if ClosestLaneToBot == LANE_MID then
					FarmLaneDesire = FarmMidDesire
					LaneToFarm = LANE_MID
				end
				if ClosestLaneToBot == LANE_BOT then
					FarmLaneDesire = FarmBotDesire
					LaneToFarm = LANE_BOT
				end
			end
			
			-- Determine farm mode
			if FarmLaneDesire >= FarmJungleDesire then
				local FountainLocation = PAF.GetFountainLocation(bot)
				local LFL = GetLaneFrontLocation(GetOpposingTeam(), LaneToFarm, 0)
				local LFLDistanceToFountain = P.GetDistance(FountainLocation, LFL)
				
				if (HealthyToFarmJungle
				and (IsEnemyNearLane(LFL, GetLaneFrontAmount(bot:GetTeam(), LaneToFarm, true))
				and LFLDistanceToFountain >= 5000)) or IsLaneFrontUnderTower(LFL) then
					FarmMode = "Jungle"
				else
					FarmMode = "Lane"
				end
				
				local MaxDesire = 0.75
				local TierThree = nil
				
				if LaneToFarm == LANE_TOP then
					TierThree = TOWER_TOP_3
				elseif LaneToFarm == LANE_MID then
					TierThree = TOWER_MID_3
				elseif LaneToFarm == LANE_BOT then
					TierThree = TOWER_BOT_3
				end
				
				if not NotNilOrDead(GetTower(bot:GetTeam(), TierThree)) then
					MaxDesire = 0.9
				end
				
				return Clamp(FarmLaneDesire, 0.0, MaxDesire)
			else
				FarmMode = "Jungle"
				return FarmJungleDesire
			end
		end
	end
end

function Think()
	if ShouldLastHitCreep() then
		bot:Action_AttackUnit(LastHitCreepTarget, false)
		return
	end
	
	if FarmMode == "Lane" then
		local LaneFrontLocation = GetLaneFrontLocation(GetOpposingTeam(), LaneToFarm, 0)
		local NearbyTowers = bot:GetNearbyTowers(1000, true)
		
		local NearbyLaneCreeps = bot:GetNearbyLaneCreeps(1600, true)
		local IsBeingTargetedByLaneCreep = false
		
		for v, Creep in pairs(NearbyLaneCreeps) do
			if Creep:CanBeSeen() and Creep:GetAttackTarget() == bot then
				IsBeingTargetedByLaneCreep = true
				break
			end
		end
		
		if IsBeingTargetedByLaneCreep
		and GetUnitToLocationDistance(TeamAncient, LaneFrontLocation) > 3200 then
			bot:Action_MoveToLocation(PAF.GetFountainLocation(bot))
			return
		end
		
		if #NearbyTowers > 0 then
			bot:Action_MoveToLocation(PAF.GetFountainLocation(bot))
			return
		else
			if GetUnitToLocationDistance(bot, LaneFrontLocation) > 1600 then
				bot:Action_MoveToLocation(LaneFrontLocation)
				return
			else
				local StrongestCreep = PAF.GetHealthiestUnit(NearbyLaneCreeps)
				
				if StrongestCreep ~= nil then
					bot:Action_AttackUnit(StrongestCreep, false)
					return
				end
			end
		end
	end
	
	if FarmMode == "Jungle" then
		local NearbyNeutralCreeps = bot:GetNearbyNeutralCreeps(1600)
		
		if #NearbyNeutralCreeps > 0 then
			local WeakestCreep = PAF.GetWeakestUnit(NearbyNeutralCreeps)
			
			if WeakestCreep ~= nil then
				if WeakestCreep:IsAncientCreep() and bot:GetLevel() < 12 then
					-- Skip attacking
				else
					bot:Action_AttackUnit(WeakestCreep, false)
					return
				end
			end
		end
		
		local ClosestCamp = nil
		local ClosestDistance = 99999
		local CampID = 0
				
		for v, Camp in pairs(NeutralCamps) do
			local CanFarmCamp = true
					
			if Camp.team ~= bot:GetTeam() then
				if bot:GetLevel() < 18 then
					CanFarmCamp = false
				end
			end
					
			if Camp.type == "ancient" then
				if bot:GetLevel() < 12 then
					CanFarmCamp = false
				end
			end
					
			if CanFarmCamp then
				if GetUnitToLocationDistance(bot, Camp.location) < ClosestDistance then
					ClosestCamp = Camp
					ClosestDistance = GetUnitToLocationDistance(bot, Camp.location)
					CampID = v
				end
			end
		end
				
		if ClosestCamp ~= nil then
			if ClosestDistance > 300 then
				bot:Action_MoveToLocation(ClosestCamp.location)
			else
				if #NearbyNeutralCreeps <= 0 then
					table.remove(NeutralCamps, CampID)
				end
			end
		end
	end
	
	if FarmMode == "DominateCreep" then
		if bot:GetUnitName() == "npc_dota_hero_enchantress" then
			local NearbyNeutralCreeps = bot:GetNearbyNeutralCreeps(1600)
			
			local ClosestCamp = nil
			local ClosestDistance = 99999
			local CampID = 0
					
			for v, Camp in pairs(NeutralCamps) do
				local CanFarmCamp = true
				
				-- Enchantress can't dominate ancient creeps
				if Camp.type == "ancient" then
					CanFarmCamp = false
				end
						
				if CanFarmCamp then
					if GetUnitToLocationDistance(bot, Camp.location) < ClosestDistance then
						ClosestCamp = Camp
						ClosestDistance = GetUnitToLocationDistance(bot, Camp.location)
						CampID = v
					end
				end
			end
					
			if ClosestCamp ~= nil then
				if ClosestDistance > 300 then
					bot:Action_MoveToLocation(ClosestCamp.location)
				else
					table.remove(NeutralCamps, CampID)
				end
			end
		elseif bot:GetUnitName() == "npc_dota_hero_chen" then
			local HolyPersuasion = bot:GetAbilityByName("chen_holy_persuasion")
			local HandOfGod = bot:GetAbilityByName("chen_hand_of_god")
			local AllowedAncients = HandOfGod:GetSpecialValueInt("ancient_creeps_scepter")
			local NearbyNeutralCreeps = bot:GetNearbyNeutralCreeps(1600)
			
			local ClosestCamp = nil
			local ClosestDistance = 99999
			local CampID = 0
					
			for v, Camp in pairs(NeutralCamps) do
				local CanFarmCamp = true
				
				-- Enchantress can't dominate ancient creeps
				if Camp.type == "ancient"
				and (AllowedAncients <= 0 or bot.DominatedAncients >= AllowedAncients) then
					CanFarmCamp = false
				end
						
				if CanFarmCamp then
					if AllowedAncients > 0 and bot.DominatedAncients < AllowedAncients then
						if Camp.type == "ancient"
						and GetUnitToLocationDistance(bot, Camp.location) < ClosestDistance then
							ClosestCamp = Camp
							ClosestDistance = GetUnitToLocationDistance(bot, Camp.location)
							CampID = v
						end
					else
						if Camp.type ~= "ancient"
						and GetUnitToLocationDistance(bot, Camp.location) < ClosestDistance then
							ClosestCamp = Camp
							ClosestDistance = GetUnitToLocationDistance(bot, Camp.location)
							CampID = v
						end
					end
				end
			end
					
			if ClosestCamp ~= nil then
				if ClosestDistance > 300 then
					bot:Action_MoveToLocation(ClosestCamp.location)
				else
					table.remove(NeutralCamps, CampID)
				end
			end
		elseif bot:GetUnitName() == "npc_dota_hero_doom_bringer" then
			local Devour = bot:GetAbilityByName("doom_bringer_devour")
			local NearbyNeutralCreeps = bot:GetNearbyNeutralCreeps(1600)
			
			local ClosestCamp = nil
			local ClosestDistance = 99999
			local CampID = 0
					
			for v, Camp in pairs(NeutralCamps) do
				local CanFarmCamp = true
				
				-- Enchantress can't dominate ancient creeps
				if Camp.type == "ancient"
				and bot:GetLevel() < 15 then
					CanFarmCamp = false
				end
						
				if CanFarmCamp then
					if bot:GetLevel() >= 15 then
						if Camp.type == "ancient"
						and GetUnitToLocationDistance(bot, Camp.location) < ClosestDistance then
							ClosestCamp = Camp
							ClosestDistance = GetUnitToLocationDistance(bot, Camp.location)
							CampID = v
						end
					else
						if Camp.type ~= "ancient"
						and GetUnitToLocationDistance(bot, Camp.location) < ClosestDistance then
							ClosestCamp = Camp
							ClosestDistance = GetUnitToLocationDistance(bot, Camp.location)
							CampID = v
						end
					end
				end
			end
					
			if ClosestCamp ~= nil then
				if ClosestDistance > 300 then
					bot:Action_MoveToLocation(ClosestCamp.location)
				else
					table.remove(NeutralCamps, CampID)
				end
			end
		end
	end
end

-- Extra Functions --

function UpdateNeutralCamps()
	if (DotaTime() - LastUpdatedTime) >= 60 then
		NeutralCamps = GetNeutralSpawners()
		LastUpdatedTime = DotaTime()
	end
end

function GetSuitableCamps()
	local Camps = {}
	
	if bot:GetLevel() >= 18 then
		return NeutralCamps
	end
	
	for v, Camp in pairs(NeutralCamps) do
		if bot:GetLevel() < 12 then
			if Camp.type ~= "ancient" and Camp.team == bot:GetTeam() then
				table.insert(Camps, Camp)
			end
		elseif bot:GetLevel() >= 12 then
			if Camp.team == bot:GetTeam() then
				table.insert(Camps, Camp)
			end
		end
	end
	
	return Camps
end

function GetDesireToFarmLane(Lane)
	local MaxLaneDesire = 0.75
	
	local LaneFrontAmount = GetLaneFrontAmount(GetOpposingTeam(), Lane, true)
	local LaneFrontLocation = GetLaneFrontLocation(GetOpposingTeam(), Lane, 0)
	local FurthestAllyBuilding = PAF.GetFurthestBuildingOnLane(Lane)
	
	if LaneFrontAmount < 0.3 then
		return 0
	end
	
	local FarmLaneDesire = 0
	if LaneFrontAmount < 0.45 then
		FarmLaneDesire = (LaneFrontAmount / 2)
	else
		FarmLaneDesire = LaneFrontAmount
	end
	
	if GetUnitToLocationDistance(FurthestAllyBuilding, LaneFrontLocation) <= 1600 then
		FarmLaneDesire = 1.0
		MaxLaneDesire = 0.9
	else
		FarmLaneDesire = LaneFrontAmount
	end
	
	local LastKnownLocationPenalty = 0.25
	local EnemiesNearLaneFront = 0
		
	for v, Enemy in pairs(GetTeamPlayers(GetOpposingTeam())) do
		if IsHeroAlive(Enemy) then
			local LSI = GetHeroLastSeenInfo(Enemy)
			if LSI ~= nil then
				local nLSI = LSI[1]
				if nLSI ~= nil then
					if P.GetDistance(LaneFrontLocation, nLSI.location) <= 3200 then
						EnemiesNearLaneFront = (EnemiesNearLaneFront + 1)
					end
				end
			end
		end
	end
		
	local TotalPenalty = (EnemiesNearLaneFront * LastKnownLocationPenalty)
	FarmLaneDesire = (FarmLaneDesire - TotalPenalty)
		
	local ClampedDesire = RemapValClamped(FarmLaneDesire, 0.0, 1.0, 0.0, MaxLaneDesire)
	return ClampedDesire
end

function GetDesireToFarmJungle()
	if not HealthyToFarmJungle then
		return 0
	end
	
	local FarmJungleDesire = 0
	
	local GPM = GetGPM()
	local GPMGoal = GetGPMGoal()
	
	if GPM < GPMGoal then
		FarmJungleDesire = 0.5
	end
	
	local ClosestLaneToBot = GetClosestLaneToBot()
	local LaneFrontLocation = GetLaneFrontLocation(GetOpposingTeam(), ClosestLaneToBot, 0)
	local ThreatPenalty = 0.25
	local EnemiesNearLaneFront = 0
		
	for v, Enemy in pairs(GetTeamPlayers(GetOpposingTeam())) do
		if IsHeroAlive(Enemy) then
			local LSI = GetHeroLastSeenInfo(Enemy)
			if LSI ~= nil then
				local nLSI = LSI[1]
				if nLSI ~= nil then
					if P.GetDistance(LaneFrontLocation, nLSI.location) <= 3200 then
						EnemiesNearLaneFront = (EnemiesNearLaneFront + 1)
					end
				end
			end
		end
	end
	
	FarmJungleDesire = (FarmJungleDesire + (EnemiesNearLaneFront * ThreatPenalty))
	local ClampedDesire = RemapValClamped(FarmJungleDesire, 0.0, 1.0, 0.0, 0.65)
	return ClampedDesire
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
					
					if P.GetDistance(lane, nLSI.location) <= 3200
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

function IsLaneFrontUnderTower(LFL)
	local EnemyTowers = GetUnitList(UNIT_LIST_ENEMY_BUILDINGS)
	
	for v, Building in pairs(EnemyTowers) do
		if PAF.IsValidBuildingTarget(Building) and Building:IsTower() then
			if GetUnitToLocationDistance(Building, LFL) <= 700 then
				return true
			end
		end
	end
	
	return false
end

function GetClosestLaneToBot()
	local LaneFrontLocations = {
	LANE_TOP,
	LANE_MID,
	LANE_BOT
	}
	
	local ClosestLane = LANE_MID
	local ClosestLoc = 99999
	
	for v, Lane in pairs(LaneFrontLocations) do
		local LaneFront = GetLaneFrontLocation(GetOpposingTeam(), Lane, 0)
		
		if GetUnitToLocationDistance(bot, LaneFront) < ClosestLoc
		and GetClosestCoreToLane(Lane) == bot then
			ClosestLane = Lane
			ClosestLoc = GetUnitToLocationDistance(bot, LaneFront)
		end
	end
	
	return ClosestLane
end

function GetClosestCoreToLane(Lane)
	local AlliedHeroes = GetUnitList(UNIT_LIST_ALLIED_HEROES)
	local FilteredAllies = PAF.FilterTrueUnits(AlliedHeroes)
	
	local ClosestBot = nil
	local ClosestDistance = 99999
	
	local LaneFrontLocation = GetLaneFrontLocation(GetOpposingTeam(), Lane, 0)
	
	for v, Ally in pairs(FilteredAllies) do
		if IsCoreHero(Ally) and Ally:IsAlive() then
			if GetUnitToLocationDistance(Ally, LaneFrontLocation) < ClosestDistance then
				ClosestBot = Ally
				ClosestDistance = GetUnitToLocationDistance(Ally, LaneFrontLocation)
			end
		end
	end
	
	if ClosestBot ~= nil then
		return ClosestBot
	end
end

function GetGPM()
	local Minutes = (DotaTime() / 60)
	local Networth = bot:GetNetWorth()
	
	local GPM = (Networth / Minutes)
	return GPM
end

function GetGPMGoal()
	if PRoles.GetPRole(bot, bot:GetUnitName()) == "SafeLane" then
		return 450
	end
	if PRoles.GetPRole(bot, bot:GetUnitName()) == "MidLane" then
		return 400
	end
	if PRoles.GetPRole(bot, bot:GetUnitName()) == "OffLane" then
		return 350
	end
end

function IsCoreHero(Unit)
	if PRoles.GetPRole(Unit, Unit:GetUnitName()) == "SafeLane"
	or PRoles.GetPRole(Unit, Unit:GetUnitName()) == "MidLane"
	or PRoles.GetPRole(Unit, Unit:GetUnitName()) == "OffLane" then
		return true
	end
	
	return false
end

function IsHeroSuitableToFarm(Unit)
	if not P.IsInLaningPhase() and bot:GetLevel() >= 6 then
		return true
	end
	
	return false
end

function ShouldLastHitCreep()
	if PAF.IsEngaging(bot)
	or P.IsRetreating(bot)
	or bot:GetActiveMode() == BOT_MODE_EVASIVE_MANEUVERS
	or not FinishedLaning then
		return false
	end
	
	local AllowedToLastHit = true
	
	local AlliesWithinRange = bot:GetNearbyHeroes(1200, false, BOT_MODE_NONE)
	local FilteredAllies = PAF.FilterTrueUnits(AlliesWithinRange)
	
	if PRoles.GetPRole(bot, bot:GetUnitName()) == "MidLane" then
		for v, Ally in pairs(FilteredAllies) do
			if PRoles.GetPRole(Ally, Ally:GetUnitName()) == "SafeLane" then
				AllowedToLastHit = false
				break
			end
		end
	end
	
	if PRoles.GetPRole(bot, bot:GetUnitName()) == "OffLane" then
		for v, Ally in pairs(FilteredAllies) do
			if PRoles.GetPRole(Ally, Ally:GetUnitName()) == "SafeLane"
			or PRoles.GetPRole(Ally, Ally:GetUnitName()) == "MidLane" then
				AllowedToLastHit = false
				break
			end
		end
	end
	
	if PRoles.GetPRole(bot, bot:GetUnitName()) == "SoftSupport" then
		for v, Ally in pairs(FilteredAllies) do
			if PRoles.GetPRole(Ally, Ally:GetUnitName()) == "SafeLane"
			or PRoles.GetPRole(Ally, Ally:GetUnitName()) == "MidLane"
			or PRoles.GetPRole(Ally, Ally:GetUnitName()) == "OffLane"
			or not Ally:IsBot() then
				AllowedToLastHit = false
				break
			end
		end
	end
	
	if PRoles.GetPRole(bot, bot:GetUnitName()) == "HardSupport" then
		for v, Ally in pairs(FilteredAllies) do
			if PRoles.GetPRole(Ally, Ally:GetUnitName()) == "SafeLane"
			or PRoles.GetPRole(Ally, Ally:GetUnitName()) == "MidLane"
			or PRoles.GetPRole(Ally, Ally:GetUnitName()) == "OffLane"
			or PRoles.GetPRole(Ally, Ally:GetUnitName()) == "SoftSupport"
			or not Ally:IsBot() then
				AllowedToLastHit = false
				break
			end
		end
	end
	
	local NearbyLaneCreeps = bot:GetNearbyLaneCreeps(1200, true)
	local NearbyTowers = bot:GetNearbyTowers(1600, true)
	
	if AllowedToLastHit then
		for v, Creep in pairs(NearbyLaneCreeps) do
			local CreepWithinTowerRange = false
			
			for x, Tower in pairs(NearbyTowers) do
				if GetUnitToUnitDistance(Tower, Creep) <= 700 then
					CreepWithinTowerRange = true
					break
				end
			end
			
			if not CreepWithinTowerRange and PAF.CanLastHitCreep(Creep) then
				LastHitCreepTarget = Creep
				return true
			end
		end
	end
	
	if not FinishedLaning then
		NearbyLaneCreeps = bot:GetNearbyLaneCreeps(1200, false)
	
		for v, Creep in pairs(NearbyLaneCreeps) do
			local CreepWithinTowerRange = false
			
			for x, Tower in pairs(NearbyTowers) do
				if GetUnitToUnitDistance(Tower, Creep) <= 700 then
					CreepWithinTowerRange = true
					break
				end
			end
			
			if not CreepWithinTowerRange and PAF.CanLastHitCreep(Creep) then
				LastHitCreepTarget = Creep
				return true
			end
		end
	end
	
	return false
end

function NotNilOrDead(unit)
	if unit == nil or unit:IsNull() then
		return false
	end
	if unit:IsAlive() then
		return true
	end
	return false
end

function HasFlag(value, flag)
	if flag == 0 then return false end
		
	return (math.floor(value / flag) % 2) == 1
end