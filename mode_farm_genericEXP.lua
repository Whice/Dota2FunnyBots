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

function GetDesire()
	UpdateNeutralCamps()
	
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
			
			-- Farm lane desires
			local FarmTopDesire = GetDesireToFarmLane(LANE_TOP)
			local FarmMidDesire = GetDesireToFarmLane(LANE_MID)
			local FarmBotDesire = GetDesireToFarmLane(LANE_BOT)
			
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
				FarmMode = "Lane"
				return FarmLaneDesire
			else
				FarmMode = "Jungle"
				if P.IsMeepoClone(bot) then
					return BOT_MODE_DESIRE_HIGH
				else
					return FarmJungleDesire
				end
			end
		end
	end
end

function Think()
	if FarmMode == "Lane" then
		local LaneFrontLocation = GetLaneFrontLocation(GetOpposingTeam(), LaneToFarm, 0)
		local NearbyTowers = bot:GetNearbyTowers(1000, true)
		
		if #NearbyTowers > 0 then
			bot:Action_MoveToLocation(PAF.GetFountainLocation(bot))
		else
			if GetUnitToLocationDistance(bot, LaneFrontLocation) > 1600 then
				bot:Action_MoveToLocation(LaneFrontLocation)
			else
				local NearbyLaneCreeps = bot:GetNearbyLaneCreeps(1600, true)
				local StrongestCreep = PAF.GetHealthiestUnit(NearbyLaneCreeps)
				
				if StrongestCreep ~= nil then
					bot:Action_AttackUnit(StrongestCreep, false)
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
	if not HealthyToFarmJungle or bot:GetLevel() < 10 then
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