local PDefend = {}

local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")
local PAF = require(GetScriptDirectory() ..  "/Library/PhalanxAbilityFunctions")

local enemies

function NotNilOrDead(unit)
	if unit == nil or unit:IsNull() then
		return false
	end
	if unit:IsAlive() then
		return true
	end
	return false
end

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
	
	if not P.IsInLaningPhase() then
		for v, Building in pairs(Buildings) do
			if not Building:IsInvulnerable() then
				for x, Human in pairs(PAF.GetAllyHumanHeroes()) do
					local LastPing = Human:GetMostRecentPing()
					if (GameTime() - LastPing.time) < 30
					and LastPing.normal_ping == true
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
					and LastPing.normal_ping == true
					and GetUnitToLocationDistance(Building, LastPing.location) <= 300
					and not NotNilOrDead(TierThree) then
						return BOT_MODE_DESIRE_VERYHIGH
					end
				end
			end
		end
		
		local DefendDesire = GetDefendLaneDesire(lane)
		
		local LaneTierOne = nil
		if lane == LANE_TOP then
			LaneTierOne = GetTower(bot:GetTeam(), TOWER_TOP_1)
		elseif lane == LANE_MID then
			LaneTierOne = GetTower(bot:GetTeam(), TOWER_MID_1)
		elseif lane == LANE_BOT then
			LaneTierOne = GetTower(bot:GetTeam(), TOWER_BOT_1)
		end
		local LaneTierTwo = nil
		if lane == LANE_TOP then
			LaneTierTwo = GetTower(bot:GetTeam(), TOWER_TOP_2)
		elseif lane == LANE_MID then
			LaneTierTwo = GetTower(bot:GetTeam(), TOWER_MID_2)
		elseif lane == LANE_BOT then
			LaneTierTwo = GetTower(bot:GetTeam(), TOWER_BOT_2)
		end
		local LaneTierThree = nil
		if lane == LANE_TOP then
			LaneTierThree = GetTower(bot:GetTeam(), TOWER_TOP_3)
		elseif lane == LANE_MID then
			LaneTierThree = GetTower(bot:GetTeam(), TOWER_MID_3)
		elseif lane == LANE_BOT then
			LaneTierThree = GetTower(bot:GetTeam(), TOWER_BOT_3)
		end
		
		if not NotNilOrDead(LaneTierThree) then
			local TeamAncient = GetAncient(bot:GetTeam())
			
			if not TeamAncient:IsInvulnerable() then
				local AncientLoc = TeamAncient:GetLocation()
				
				local EnemyHeroes = GetUnitList(UNIT_LIST_ENEMY_HEROES)
				local FilteredEnemies = PAF.FilterTrueUnits(EnemyHeroes)
				
				for v, Enemy in pairs(FilteredEnemies) do
					if GetUnitToLocationDistance(Enemy, AncientLoc) <= 1400 then
						return BOT_MODE_DESIRE_VERYHIGH
					end
				end
			end
		end
		
		if not NotNilOrDead(LaneTierThree) then
			return Clamp((DefendDesire * 5), 0.0, 0.9)
		end
		
		if not NotNilOrDead(LaneTierTwo) then
			return Clamp((DefendDesire * 3), 0.0, 0.9)
		end
		
		if NotNilOrDead(LaneTierOne) and ShouldGoDefend(bot, lane) then
			return Clamp(DefendDesire, 0.0, 0.9)
		elseif NotNilOrDead(LaneTierTwo) and ShouldGoDefend(bot, lane) then
			return Clamp((DefendDesire * 2), 0.0, 0.9)
		end
	else
		if PRoles.GetPRole(bot, bot:GetUnitName()) == "MidLane" then
			if bot:HasModifier("modifier_rune_doubledamage")
			or bot:HasModifier("modifier_rune_haste")
			or bot:HasModifier("modifier_rune_invis")
			or bot:HasModifier("modifier_rune_arcane") then
				local DefendDesire = GetDefendLaneDesire(lane)
				
				if lane ~= LANE_MID then
					return Clamp(DefendDesire, 0.0, 0.9)
				end
			end
		end
		
		return 0
	end
end

function ShouldGoDefend(bot, lane)
	local Enemies = 0
	
	local EnemyIDs = GetTeamPlayers(GetOpposingTeam())
	for v, EID in pairs(EnemyIDs) do
		if IsHeroAlive(EID) then
			local LSI = GetHeroLastSeenInfo(EID)
			if LSI ~= nil then
				local nLSI = LSI[1]
				--print(nLSI.location)
					
				if nLSI ~= nil then
					if GetUnitToLocationDistance(GetCurrentBuilding(bot, lane), nLSI.location) <= 1600
					and nLSI.time_since_seen <= 5 then
						Enemies = (Enemies + 1)
					end
				end
			end
		end
	end
	
	if Enemies == 1 then
		if PRoles.GetPRole(bot, bot:GetUnitName()) == "MidLane" 
		or PRoles.GetPRole(bot, bot:GetUnitName()) == "SoftSupport" then
			return true
		end
	elseif Enemies == 2 then
		if PRoles.GetPRole(bot, bot:GetUnitName()) == "MidLane"
		or PRoles.GetPRole(bot, bot:GetUnitName()) == "SoftSupport"
		or PRoles.GetPRole(bot, bot:GetUnitName()) == "OffLane" then
			return true
		end
	elseif Enemies == 3 then
		if PRoles.GetPRole(bot, bot:GetUnitName()) == "MidLane"
		or PRoles.GetPRole(bot, bot:GetUnitName()) == "SoftSupport"
		or PRoles.GetPRole(bot, bot:GetUnitName()) == "OffLane"
		or PRoles.GetPRole(bot, bot:GetUnitName()) == "HardSupport" then
			return true
		end
	elseif Enemies >= 4 then
		return true
	end
	
	if PRoles.GetPRole(bot, bot:GetUnitName()) == "MidLane" then
		return true
	end
end

function GetCurrentBuilding(bot, lane)
	if lane == LANE_TOP then
		if NotNilOrDead(GetTower(bot:GetTeam(), TOWER_TOP_1)) then
			return GetTower(bot:GetTeam(), TOWER_TOP_1)
		end
		if NotNilOrDead(GetTower(bot:GetTeam(), TOWER_TOP_2)) then
			return GetTower(bot:GetTeam(), TOWER_TOP_2)
		end
		if NotNilOrDead(GetTower(bot:GetTeam(), TOWER_TOP_3)) then
			return GetTower(bot:GetTeam(), TOWER_TOP_3)
		end
		if NotNilOrDead(GetBarracks(bot:GetTeam(), BARRACKS_TOP_MELEE)) then
			return GetBarracks(bot:GetTeam(), BARRACKS_TOP_MELEE)
		end
		if NotNilOrDead(GetBarracks(bot:GetTeam(), BARRACKS_TOP_RANGED)) then
			return GetBarracks(bot:GetTeam(), BARRACKS_TOP_RANGED)
		end
		if NotNilOrDead(GetTower(bot:GetTeam(), TOWER_BASE_1)) then
			return GetTower(bot:GetTeam(), TOWER_BASE_1)
		end
		if NotNilOrDead(GetTower(bot:GetTeam(), TOWER_BASE_2)) then
			return GetTower(bot:GetTeam(), TOWER_BASE_2)
		end
		if NotNilOrDead(GetAncient(bot:GetTeam())) then
			return GetAncient(bot:GetTeam())
		end
	end
	
	if lane == LANE_MID then
		if NotNilOrDead(GetTower(bot:GetTeam(), TOWER_MID_1)) then
			return GetTower(bot:GetTeam(), TOWER_MID_1)
		end
		if NotNilOrDead(GetTower(bot:GetTeam(), TOWER_MID_2)) then
			return GetTower(bot:GetTeam(), TOWER_MID_2)
		end
		if NotNilOrDead(GetTower(bot:GetTeam(), TOWER_MID_3)) then
			return GetTower(bot:GetTeam(), TOWER_MID_3)
		end
		if NotNilOrDead(GetBarracks(bot:GetTeam(), BARRACKS_MID_MELEE)) then
			return GetBarracks(bot:GetTeam(), BARRACKS_MID_MELEE)
		end
		if NotNilOrDead(GetBarracks(bot:GetTeam(), BARRACKS_MID_RANGED)) then
			return GetBarracks(bot:GetTeam(), BARRACKS_MID_RANGED)
		end
		if NotNilOrDead(GetTower(bot:GetTeam(), TOWER_BASE_1)) then
			return GetTower(bot:GetTeam(), TOWER_BASE_1)
		end
		if NotNilOrDead(GetTower(bot:GetTeam(), TOWER_BASE_2)) then
			return GetTower(bot:GetTeam(), TOWER_BASE_2)
		end
		if NotNilOrDead(GetAncient(bot:GetTeam())) then
			return GetAncient(bot:GetTeam())
		end
	end
	
	if lane == LANE_BOT then
		if NotNilOrDead(GetTower(bot:GetTeam(), TOWER_BOT_1)) then
			return GetTower(bot:GetTeam(), TOWER_BOT_1)
		end
		if NotNilOrDead(GetTower(bot:GetTeam(), TOWER_BOT_2)) then
			return GetTower(bot:GetTeam(), TOWER_BOT_2)
		end
		if NotNilOrDead(GetTower(bot:GetTeam(), TOWER_BOT_3)) then
			return GetTower(bot:GetTeam(), TOWER_BOT_3)
		end
		if NotNilOrDead(GetBarracks(bot:GetTeam(), BARRACKS_BOT_MELEE)) then
			return GetBarracks(bot:GetTeam(), BARRACKS_BOT_MELEE)
		end
		if NotNilOrDead(GetBarracks(bot:GetTeam(), BARRACKS_BOT_RANGED)) then
			return GetBarracks(bot:GetTeam(), BARRACKS_BOT_RANGED)
		end
		if NotNilOrDead(GetTower(bot:GetTeam(), TOWER_BASE_1)) then
			return GetTower(bot:GetTeam(), TOWER_BASE_1)
		end
		if NotNilOrDead(GetTower(bot:GetTeam(), TOWER_BASE_2)) then
			return GetTower(bot:GetTeam(), TOWER_BASE_2)
		end
		if NotNilOrDead(GetAncient(bot:GetTeam())) then
			return GetAncient(bot:GetTeam())
		end
	end
end

return PDefend