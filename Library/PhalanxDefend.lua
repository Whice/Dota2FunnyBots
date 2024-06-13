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
	if not P.IsInLaningPhase() then
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
		
		if DefendDesire > 0.1 then
			if not NotNilOrDead(LaneTierTwo) then
				return BOT_MODE_DESIRE_VERYHIGH
			end
		end
		
		if NotNilOrDead(LaneTierOne) and ShouldGoDefend(bot, lane) then
			return Clamp(DefendDesire, 0.0, 0.9)
		elseif NotNilOrDead(LaneTierTwo) and ShouldGoDefend(bot, lane) then
			return Clamp((DefendDesire * 2), 0.0, 0.9)
		end
	else
		return 0
	end
end

function ShouldGoDefend(bot, lane)
	local Enemies = {}
	for v, enemy in pairs(GetUnitList(UNIT_LIST_ENEMY_HEROES)) do
		local distance = GetUnitToUnitDistance(PAF.GetFurthestBuildingOnLane(lane), enemy)
		local lanefrontloc = GetLaneFrontLocation(bot:GetTeam(), lane, 0)
		
		if distance <= 2400
		and GetUnitToLocationDistance(PAF.GetFurthestBuildingOnLane(lane), lanefrontloc) <= 2400
		and not PAF.IsPossibleIllusion(enemy)
		and not P.IsMeepoClone(enemy) then
			table.insert(Enemies, enemy)
		end
	end
	
	if #Enemies == 1 then
		if PRoles.GetPRole(bot, bot:GetUnitName()) == "MidLane" 
		or PRoles.GetPRole(bot, bot:GetUnitName()) == "SoftSupport" then
			return true
		end
	elseif #Enemies == 2 then
		if PRoles.GetPRole(bot, bot:GetUnitName()) == "MidLane"
		or PRoles.GetPRole(bot, bot:GetUnitName()) == "SoftSupport"
		or PRoles.GetPRole(bot, bot:GetUnitName()) == "OffLane" then
			return true
		end
	elseif #Enemies == 3 then
		if PRoles.GetPRole(bot, bot:GetUnitName()) == "MidLane"
		or PRoles.GetPRole(bot, bot:GetUnitName()) == "SoftSupport"
		or PRoles.GetPRole(bot, bot:GetUnitName()) == "OffLane"
		or PRoles.GetPRole(bot, bot:GetUnitName()) == "HardSupport" then
			return true
		end
	elseif #Enemies == 4 then
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