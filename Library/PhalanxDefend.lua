local PDefend = {}

local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")
local PAF = require(GetScriptDirectory() ..  "/Library/PhalanxAbilityFunctions")

function PDefend.GetDefendDesire(bot, lane)
	local Buildings
	local TierThree = nil
	if lane == LANE_TOP then
		Buildings = {
			GetTower(bot:GetTeam(), TOWER_TOP_1),
			GetTower(bot:GetTeam(), TOWER_TOP_2),
			GetTower(bot:GetTeam(), TOWER_TOP_3),
			GetBarracks(bot:GetTeam(), BARRACKS_TOP_MELEE),
			GetBarracks(bot:GetTeam(), BARRACKS_TOP_RANGED),
		}
		
		TierThree = GetTower(bot:GetTeam(), TOWER_TOP_3)
	elseif lane == LANE_MID then
		Buildings = {
			GetTower(bot:GetTeam(), TOWER_MID_1),
			GetTower(bot:GetTeam(), TOWER_MID_2),
			GetTower(bot:GetTeam(), TOWER_MID_3),
			GetBarracks(bot:GetTeam(), BARRACKS_MID_MELEE),
			GetBarracks(bot:GetTeam(), BARRACKS_MID_RANGED),
		}
		
		TierThree = GetTower(bot:GetTeam(), TOWER_MID_3)
	elseif lane == LANE_BOT then
		Buildings = {
			GetTower(bot:GetTeam(), TOWER_BOT_1),
			GetTower(bot:GetTeam(), TOWER_BOT_2),
			GetTower(bot:GetTeam(), TOWER_BOT_3),
			GetBarracks(bot:GetTeam(), BARRACKS_BOT_MELEE),
			GetBarracks(bot:GetTeam(), BARRACKS_BOT_RANGED),
		}
		
		TierThree = GetTower(bot:GetTeam(), TOWER_BOT_3)
	end
	
	local BaseBuildings = {
		GetTower(GetTeam(), TOWER_BASE_1),
		GetTower(GetTeam(), TOWER_BASE_1),
		GetAncient(GetTeam())
	}
	
	if bot:GetLevel() < 6 then
		return BOT_MODE_DESIRE_NONE
	end
	
	for v, Building in pairs(Buildings) do
		if not Building:IsInvulnerable() then
			for x, Human in pairs(PAF.GetAllyHumanHeroes()) do
				local LastPing = Human:GetMostRecentPing()
				if (GameTime() - LastPing.time) < 30
				and GetUnitToLocationDistance(Building, LastPing.location) <= 300 then
					return BOT_MODE_DESIRE_VERYHIGH
				end
			end
		end
	end
	
	for v, Building in pairs(BaseBuildings) do
		if not Building:IsInvulnerable() then
			for x, Human in pairs(PAF.GetAllyHumanHeroes()) do
				local LastPing = Human:GetMostRecentPing()
				if (GameTime() - LastPing.time) < 30
				and GetUnitToLocationDistance(Building, LastPing.location) <= 300
				and not PAF.IsValidBuildingTarget(TierThree) then
					return BOT_MODE_DESIRE_VERYHIGH
				end
			end
		end
	end
	
	local CurrentBuilding = PAF.GetFurthestBuildingOnLane(lane)
	local DesireMultiplier = GetDesireMultiplier(CurrentBuilding, bot:GetTeam())
	
	local BuildingHP = CurrentBuilding:GetHealth()
	local BuildingMaxHP = CurrentBuilding:GetMaxHealth()
	
	local HPVal = RemapValClamped(BuildingHP, 0, BuildingMaxHP, 0.0, 1.0)
	local BuildingHPDesireVal = (1.0 - HPVal)
	
	local NearbyEnemyCount = GetNearbyEnemyCount(CurrentBuilding)
	local EnemyMultiplier = 0.2
	local EnemyCountDesireVal = (NearbyEnemyCount * EnemyMultiplier)
	
	local DefendDesire = ((BuildingHPDesireVal + EnemyCountDesireVal) * DesireMultiplier)
	
	local RespondingUnits = GetRespondingUnits(NearbyEnemyCount, lane)
	
	if NearbyEnemyCount > 0 then
		for v, Responder in pairs(RespondingUnits) do
			if Responder == bot then
				return Clamp(DefendDesire, BOT_MODE_DESIRE_NONE, BOT_MODE_DESIRE_VERYHIGH)
			end
		end
	end
	
	return BOT_MODE_DESIRE_NONE
end

function GetDesireMultiplier(CurrentBuilding, BotTeam)
	if CurrentBuilding == GetTower(BotTeam, TOWER_TOP_1)
	or CurrentBuilding == GetTower(BotTeam, TOWER_MID_1)
	or CurrentBuilding == GetTower(BotTeam, TOWER_BOT_1) then
		return 1
	end
	
	if CurrentBuilding == GetTower(BotTeam, TOWER_TOP_2)
	or CurrentBuilding == GetTower(BotTeam, TOWER_MID_2)
	or CurrentBuilding == GetTower(BotTeam, TOWER_BOT_2) then
		return 2
	end
	
	return 100
end

function GetNearbyEnemyCount(CurrentBuilding)
	local EnemyCount = 0
	
	local EnemyIDs = GetTeamPlayers(GetOpposingTeam())
	for v, EID in pairs(EnemyIDs) do
		if IsHeroAlive(EID) then
			local LSI = GetHeroLastSeenInfo(EID)
			if LSI ~= nil then
				local nLSI = LSI[1]
				if nLSI ~= nil then
					if GetUnitToLocationDistance(CurrentBuilding, nLSI.location) <= 1600
					and nLSI.time_since_seen <= 5 then
						EnemyCount = (EnemyCount + 1)
					end
				end
			end
		end
	end
	
	return EnemyCount
end

function GetRespondingUnits(NearbyEnemyCount, lane)
	local AlliesToRespond = (NearbyEnemyCount + 1)
	
	local RespondingUnits = {}
	local SafeLane = nil
	local MidLane = nil
	local OffLane = nil
	local SoftSupport = nil
	local HardSupport = nil
	
	local Allies = GetUnitList(UNIT_LIST_ALLIED_HEROES)
	local FilteredAllies = PAF.FilterTrueUnits(Allies)
	
	for v, Ally in pairs(FilteredAllies) do
		if PRoles.GetPRole(Ally, Ally:GetUnitName()) == "SafeLane" then
			SafeLane = Ally
		end
		
		if PRoles.GetPRole(Ally, Ally:GetUnitName()) == "MidLane" then
			MidLane = Ally
		end
		
		if PRoles.GetPRole(Ally, Ally:GetUnitName()) == "OffLane" then
			OffLane = Ally
		end
		
		if PRoles.GetPRole(Ally, Ally:GetUnitName()) == "SoftSupport" then
			SoftSupport = Ally
		end
		
		if PRoles.GetPRole(Ally, Ally:GetUnitName()) == "HardSupport" then
			HardSupport = Ally
		end
	end
	
	if #RespondingUnits < AlliesToRespond
	and MidLane ~= nil
	and MidLane:GetLevel() >= 6
	and not IsDefendingAnotherLane(MidLane, lane) then
		table.insert(RespondingUnits, MidLane)
	end
	
	if #RespondingUnits < AlliesToRespond
	and SoftSupport ~= nil
	and SoftSupport:GetLevel() >= 6
	and not IsDefendingAnotherLane(SoftSupport, lane) then
		table.insert(RespondingUnits, SoftSupport)
	end
	
	if #RespondingUnits < AlliesToRespond
	and OffLane ~= nil
	and OffLane:GetLevel() >= 6
	and not IsDefendingAnotherLane(OffLane, lane) then
		table.insert(RespondingUnits, OffLane)
	end
	
	if #RespondingUnits < AlliesToRespond
	and HardSupport ~= nil
	and HardSupport:GetLevel() >= 6
	and not IsDefendingAnotherLane(HardSupport, lane) then
		table.insert(RespondingUnits, HardSupport)
	end
	
	if #RespondingUnits < AlliesToRespond
	and SafeLane ~= nil
	and SafeLane:GetLevel() >= 6
	and not IsDefendingAnotherLane(SafeLane, lane) then
		table.insert(RespondingUnits, SafeLane)
	end
	
	return RespondingUnits
end

function IsDefendingAnotherLane(Ally, lane)
	if lane == LANE_TOP then
		if Ally:GetActiveMode() == BOT_MODE_DEFEND_TOWER_MID
		or Ally:GetActiveMode() == BOT_MODE_DEFEND_TOWER_BOT then
			return true
		end
	elseif lane == LANE_MID then
		if Ally:GetActiveMode() == BOT_MODE_DEFEND_TOWER_TOP
		or Ally:GetActiveMode() == BOT_MODE_DEFEND_TOWER_BOT then
			return true
		end
	elseif lane == LANE_BOT then
		if Ally:GetActiveMode() == BOT_MODE_DEFEND_TOWER_TOP
		or Ally:GetActiveMode() == BOT_MODE_DEFEND_TOWER_MID then
			return true
		end
	end
	
	return false
end

return PDefend