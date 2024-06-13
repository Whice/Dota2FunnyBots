local PAF = {}

local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

function PAF.AcquireTarget()
	local bot = GetBot()
	
	local AttackRange = (bot:GetAttackRange() + 300)
	--local AttackRange = 1600
		
	if AttackRange > 1600 then
		AttackRange = 1600
	end
		
	local NearbyEnemies = bot:GetNearbyHeroes(AttackRange, true, BOT_MODE_NONE)
	if #NearbyEnemies <= 0 then
		NearbyEnemies = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	end
	
	local Enemies = PAF.FilterTrueUnits(NearbyEnemies)
	if #Enemies <= 0 then
		Enemies = NearbyEnemies
	end
	
	local ViableEnemies = {}
	
	for v, Enemy in pairs(Enemies) do
		if not Enemy:IsInvulnerable()
		and not Enemy:HasModifier("modifier_abaddon_borrowed_time")
		and not ((Enemy:HasModifier("modifier_item_blade_mail") or Enemy:HasModifier("modifier_item_blade_mail_reflect")) and #Enemies > 1) then
			table.insert(ViableEnemies, Enemy)
		end
	end
	
	local WeakestEnemy = nil
	
	if #ViableEnemies > 0 then
		WeakestEnemy = PAF.GetWeakestUnit(ViableEnemies)
	end
		
	if PAF.IsValidHeroTarget(WeakestEnemy)
	and GetUnitToUnitDistance(bot, WeakestEnemy) <= 1600 then
		bot:SetTarget(WeakestEnemy)
		return
	else
		if not PAF.IsEngaging(bot) then
			bot:SetTarget(nil)
			return
		end
	end
end

function PAF.CombineTables(TableOne, TableTwo)
	local CombinedTable = {}

	for v, TableItem in pairs(TableOne) do
		table.insert(CombinedTable, TableItem)
	end
	for v, TableItem in pairs(TableTwo) do
		table.insert(CombinedTable, TableItem)
	end
	
	return CombinedTable
end

function PAF.GetAllyTeamKills()
	local bot = GetBot()
	local Kills = 0
	
	local TeamPlayers = GetTeamPlayers(bot:GetTeam())
	for v, Ally in pairs(TeamPlayers) do
		Kills = (Kills + GetHeroKills(Ally))
	end
	
	return Kills
end

function PAF.GetEnemyTeamKills()
	local Kills = 0
	
	local EnemyPlayers = GetTeamPlayers(GetOpposingTeam())
	for v, Enemy in pairs(EnemyPlayers) do
		Kills = (Kills + GetHeroKills(Enemy))
	end
	
	return Kills
end

function PAF.GetAllyTeamLevels()
	local bot = GetBot()
	local Levels = 0
	
	local TeamPlayers = GetTeamPlayers(bot:GetTeam())
	for v, Ally in pairs(TeamPlayers) do
		Levels = (Levels + GetHeroLevel(Ally))
	end
	
	return Levels
end

function PAF.GetEnemyTeamLevels()
	local Levels = 0
	
	local EnemyPlayers = GetTeamPlayers(GetOpposingTeam())
	for v, Enemy in pairs(EnemyPlayers) do
		Levels = (Levels + GetHeroLevel(Enemy))
	end
	
	return Levels
end

function PAF.GetFountainLocation(unit)
	if unit:GetTeam() == TEAM_RADIANT then
		return Vector( -7169, -6654, 392 )
	elseif unit:GetTeam() == TEAM_DIRE then
		return Vector( 6974, 6402, 392 )
	end
	
	return nil
end

function PAF.CombineOffensivePower(units, bRaw)
	local TotalPower = 0
	
	for v, Unit in pairs(units) do
		local UnitPower = 0
	
		if bRaw then
			UnitPower = Unit:GetRawOffensivePower()
		else
			UnitPower = Unit:GetOffensivePower()
		end
		
		if Unit:GetUnitName() == "npc_dota_hero_medusa" then
			UnitPower = (UnitPower * 2)
		end
		if Unit:GetUnitName() == "npc_dota_hero_terrorblade" then
			UnitPower = (UnitPower / 2)
		end
		
		TotalPower = (TotalPower + UnitPower)
	end
	
	return TotalPower
end

function PAF.CombineEstimatedDamage(CurrentlyAvailable, TableUnits, Unit, Duration, Type)
	local TotalDamage = 0
	
	for v, TabledUnit in pairs(TableUnits) do
		TotalDamage = (TotalDamage + TabledUnit:GetEstimatedDamageToTarget(CurrentlyAvailable, Unit, Duration, Type))
	end
	
	return TotalDamage
end

-- Detect illusions
function PAF.IsPossibleIllusion(unit)
	local bot = GetBot()

	--Detect ally illusions
	if unit:HasModifier('modifier_illusion') 
	   or unit:HasModifier('modifier_phantom_lancer_doppelwalk_illusion') or unit:HasModifier('modifier_phantom_lancer_juxtapose_illusion')
       or unit:HasModifier('modifier_darkseer_wallofreplica_illusion') or unit:HasModifier('modifier_terrorblade_conjureimage')	   
	then
		return true
	else
	   --Detect replicate and wall of replica illusions
	    if GetGameMode() ~= GAMEMODE_MO then
			if unit:GetTeam() ~= bot:GetTeam() then
				local TeamMember = GetTeamPlayers(GetTeam())
				for i = 1, #TeamMember
				do
					local ally = GetTeamMember(i)
					if ally ~= nil and ally:GetUnitName() == unit:GetUnitName() then
						return true
					end
				end
			end
		end
		return false
	end
end

function PAF.FilterTrueUnits(units)
	local trueunits = {}

	for v, unit in pairs(units) do
		if not PAF.IsPossibleIllusion(unit) then
			table.insert(trueunits, unit)
		end
	end
	
	return trueunits
end

function PAF.FilterUnitsForStun(units)
	local filteredunits = {}
	
	for v, unit in pairs(units) do
		if not PAF.IsPossibleIllusion(unit) 
		and not PAF.IsDisabled(unit) 
		and not PAF.IsMagicImmune(unit) then
			table.insert(filteredunits, unit)
		end
	end
	
	return filteredunits
end

-- Is the bot properly engaging an enemy?
function PAF.IsEngaging(SelectedUnit)
	local mode = SelectedUnit:GetActiveMode()
	return mode == BOT_MODE_ATTACK or
		   mode == BOT_MODE_DEFEND_ALLY or
		   mode == BOT_MODE_ROAM
end

function PAF.IsInTeamFight(SelectedUnit)
	local nearbyallies = SelectedUnit:GetNearbyHeroes(1000, false, BOT_MODE_NONE)
	local nearbyenemies = SelectedUnit:GetNearbyHeroes(1000, true, BOT_MODE_NONE)
	local trueallies = PAF.FilterTrueUnits(nearbyallies)
	local trueenemies = PAF.FilterTrueUnits(nearbyenemies)
	
	if #trueallies >= 2 and #trueenemies >= 2 and PAF.IsEngaging(SelectedUnit) then
		return true
	else
		return false
	end
end

-- Some bots have abilities with shorter ranges than their attack range, preventing ability usage
function PAF.GetProperCastRange(CastRange)
	local bot = GetBot()
	local AttackRange = bot:GetAttackRange()
	
	if CastRange < AttackRange then
		return (AttackRange + 50)
	else
		if (CastRange + 50) > 1600 then
			return 1600
		else
			return (CastRange + 50)
		end
	end
end

-- Valid unit checks
function PAF.IsValidHeroTarget(unit)
	return unit ~= nil 
	and unit:IsAlive() 
	and unit:IsHero()
	and unit:CanBeSeen()
end

function PAF.IsValidCreepTarget(unit)
	return unit ~= nil 
	and unit:IsAlive() 
	and unit:IsCreep()
	and unit:CanBeSeen()
end

function PAF.IsValidBuildingTarget(unit)
	return unit ~= nil 
	and unit:IsAlive() 
	and unit:IsBuilding()
	and unit:CanBeSeen()
end

function PAF.IsRoshan(unit)
	return unit ~= nil
	and unit:IsAlive() 
	and (string.find(unit:GetUnitName(), "roshan") or string.find(unit:GetUnitName(), "miniboss"))
end

function PAF.IsValidHeroAndNotIllusion(unit)
	return PAF.IsValidHeroTarget(unit)
	and not PAF.IsPossibleIllusion(unit)
end

-- Immunity checks
function PAF.IsMagicImmune(unit)
	if unit:IsInvulnerable()
	or unit:IsMagicImmune()
	or unit:HasModifier("modifier_black_king_bar_immune")
	or unit:HasModifier("modifier_item_black_king_bar")
	or unit:HasModifier("modifier_life_stealer_rage")
	or unit:HasModifier("modifier_juggernaut_blade_fury") then
		return true
	else
		return false
	end
end

function PAF.IsPhysicalImmune(unit)
	if unit:IsInvulnerable() or unit:IsAttackImmune() then
		return true
	else
		return false
	end
end

-- Disabled checks
function PAF.IsDisabled(unit)
	return (unit:IsRooted() or unit:IsStunned() or unit:IsHexed() or unit:IsNightmared() or PAF.IsTaunted(unit))
end

function PAF.IsTaunted(unit)
	return (unit:HasModifier("modifier_axe_berserkers_call") 
	or unit:HasModifier("modifier_legion_commander_duel") 
	or unit:HasModifier("modifier_winter_wyvern_winters_curse") 
	or unit:HasModifier(" modifier_winter_wyvern_winters_curse_aura"))
end

function PAF.IsSilencedOrMuted(unit)
	return (unit:IsSilenced() or unit:IsMuted())
end

-- Get specific units
function PAF.GetWeakestUnit(units)
	local weakestunit = nil
	local lowesthealth = 99999

	for v, unit in pairs(units) do
		if not unit:HasModifier("modifier_item_chainmail")
		and not unit:HasModifier("modifier_abaddon_borrowed_time") then
			if unit:GetHealth() < lowesthealth then
				weakestunit = unit
				lowesthealth = unit:GetHealth()
			end
		end
	end
	
	return weakestunit
end

function PAF.GetHealthiestUnit(units)
	local healthiestunit = nil
	local highesthealth = 0

	for v, unit in pairs(units) do
		if unit:GetHealth() > highesthealth then
			healthiestunit = unit
			highesthealth = unit:GetHealth()
		end
	end
	
	return healthiestunit
end

function PAF.GetStrongestPowerUnit(units)
	local strongestunit = nil
	local strongestpower = 0
	
	for v, unit in pairs(units) do
		if unit:GetRawOffensivePower() < strongestpower then
			strongestunit = unit
			strongestpower = unit:GetRawOffensivePower()
		end
	end
	
	return strongestunit
end

function PAF.GetStrongestAttackDamageUnit(units)
	local strongestunit = nil
	local strongestdamage = 0
	
	for v, unit in pairs(units) do
		if unit:GetAttackDamage() > strongestdamage then
			strongestunit = unit
			strongestdamage = unit:GetAttackDamage()
		end
	end
	
	return strongestunit
end

function PAF.GetClosestUnit(SelectedUnit, units)
	local closestunit = nil
	local shortestdistance = 99999

	for v, unit in pairs(units) do
		if GetUnitToUnitDistance(SelectedUnit, unit) < shortestdistance then
			closestunit = unit
			shortestdistance = GetUnitToUnitDistance(SelectedUnit, unit)
		end
	end
	
	return closestunit
end

-- Misc
function PAF.GetUnitsNearTarget(Loc, Units, Radius)
	local AoECount = 0
	
	for v, unit in pairs(Units) do
		if GetUnitToLocationDistance(unit, Loc) <= Radius then
			AoECount = (AoECount + 1)
		end
	end
	
	return AoECount
end

function PAF.IsChasing(SelectedUnit, Target)
	if SelectedUnit:IsFacingLocation(Target:GetLocation(), 10)
	and not Target:IsFacingLocation(SelectedUnit:GetLocation(), 150) then
		return true
	end

	return false
end

function PAF.CanLastHitCreepAndHarass(bot, BotTarget, AOE, Damage, DamageType)
	local creeps = bot:GetNearbyCreeps(1600, true)
	for v, creep in pairs(creeps) do
		local EstimatedDamage = creep:GetActualIncomingDamage(Damage, DamageType)
	
		local tResult = PointToLineDistance(bot:GetLocation(), BotTarget:GetLocation(), creep:GetLocation())
		if tResult ~= nil
		and tResult.within
		and tResult.distance <= AOE
		and creep:GetHealth() <= EstimatedDamage then
			return true
		end
	end
	
	return false
end

function PAF.GetVectorInBetween(LocOne, LocTwo)
	local NewX = (LocOne.x + LocTwo.x) / 2
	local NewY = (LocOne.y + LocTwo.y) / 2
	local NewZ = (LocOne.z + LocTwo.z) / 2
	
	return Vector(NewX, NewY, NewZ)
end

function PAF.GetFurthestBuildingOnLane(lane)
	local bot = GetBot()
	local FurthestBuilding = nil

	if lane == LANE_TOP then
		FurthestBuilding = GetTower(bot:GetTeam(), TOWER_TOP_1)
		if PAF.IsValidBuildingTarget(FurthestBuilding) then
			return FurthestBuilding
		end
		
		FurthestBuilding = GetTower(bot:GetTeam(), TOWER_TOP_2)
		if PAF.IsValidBuildingTarget(FurthestBuilding) then
			return FurthestBuilding
		end
		
		FurthestBuilding = GetTower(bot:GetTeam(), TOWER_TOP_3)
		if PAF.IsValidBuildingTarget(FurthestBuilding) then
			return FurthestBuilding
		end
		
		FurthestBuilding = GetBarracks(bot:GetTeam(), BARRACKS_TOP_MELEE)
		if PAF.IsValidBuildingTarget(FurthestBuilding) then
			return FurthestBuilding
		end
		
		FurthestBuilding = GetBarracks(bot:GetTeam(), BARRACKS_TOP_RANGED)
		if PAF.IsValidBuildingTarget(FurthestBuilding) then
			return FurthestBuilding
		end
		
		FurthestBuilding = GetTower(bot:GetTeam(), TOWER_BASE_1)
		if PAF.IsValidBuildingTarget(FurthestBuilding) then
			return GetAncient(bot:GetTeam())
		end
		
		FurthestBuilding = GetTower(bot:GetTeam(), TOWER_BASE_2)
		if PAF.IsValidBuildingTarget(FurthestBuilding) then
			return GetAncient(bot:GetTeam())
		end
		
		FurthestBuilding = GetAncient(bot:GetTeam())
		if PAF.IsValidBuildingTarget(FurthestBuilding) then
			return GetAncient(bot:GetTeam())
		end
	end
	
	if lane == LANE_MID then
		FurthestBuilding = GetTower(bot:GetTeam(), TOWER_MID_1)
		if PAF.IsValidBuildingTarget(FurthestBuilding) then
			return FurthestBuilding
		end
		
		FurthestBuilding = GetTower(bot:GetTeam(), TOWER_MID_2)
		if PAF.IsValidBuildingTarget(FurthestBuilding) then
			return FurthestBuilding
		end
		
		FurthestBuilding = GetTower(bot:GetTeam(), TOWER_MID_3)
		if PAF.IsValidBuildingTarget(FurthestBuilding) then
			return FurthestBuilding
		end
		
		FurthestBuilding = GetBarracks(bot:GetTeam(), BARRACKS_MID_MELEE)
		if PAF.IsValidBuildingTarget(FurthestBuilding) then
			return FurthestBuilding
		end
		
		FurthestBuilding = GetBarracks(bot:GetTeam(), BARRACKS_MID_RANGED)
		if PAF.IsValidBuildingTarget(FurthestBuilding) then
			return FurthestBuilding
		end
		
		FurthestBuilding = GetTower(bot:GetTeam(), TOWER_BASE_1)
		if PAF.IsValidBuildingTarget(FurthestBuilding) then
			return GetAncient(bot:GetTeam())
		end
		
		FurthestBuilding = GetTower(bot:GetTeam(), TOWER_BASE_2)
		if PAF.IsValidBuildingTarget(FurthestBuilding) then
			return GetAncient(bot:GetTeam())
		end
		
		FurthestBuilding = GetAncient(bot:GetTeam())
		if PAF.IsValidBuildingTarget(FurthestBuilding) then
			return GetAncient(bot:GetTeam())
		end
	end
	
	if lane == LANE_BOT then
		FurthestBuilding = GetTower(bot:GetTeam(), TOWER_BOT_1)
		if PAF.IsValidBuildingTarget(FurthestBuilding) then
			return FurthestBuilding
		end
		
		FurthestBuilding = GetTower(bot:GetTeam(), TOWER_BOT_2)
		if PAF.IsValidBuildingTarget(FurthestBuilding) then
			return FurthestBuilding
		end
		
		FurthestBuilding = GetTower(bot:GetTeam(), TOWER_BOT_3)
		if PAF.IsValidBuildingTarget(FurthestBuilding) then
			return FurthestBuilding
		end
		
		FurthestBuilding = GetBarracks(bot:GetTeam(), BARRACKS_BOT_MELEE)
		if PAF.IsValidBuildingTarget(FurthestBuilding) then
			return FurthestBuilding
		end
		
		FurthestBuilding = GetBarracks(bot:GetTeam(), BARRACKS_BOT_RANGED)
		if PAF.IsValidBuildingTarget(FurthestBuilding) then
			return FurthestBuilding
		end
		
		FurthestBuilding = GetTower(bot:GetTeam(), TOWER_BASE_1)
		if PAF.IsValidBuildingTarget(FurthestBuilding) then
			return GetAncient(bot:GetTeam())
		end
		
		FurthestBuilding = GetTower(bot:GetTeam(), TOWER_BASE_2)
		if PAF.IsValidBuildingTarget(FurthestBuilding) then
			return GetAncient(bot:GetTeam())
		end
		
		FurthestBuilding = GetAncient(bot:GetTeam())
		if PAF.IsValidBuildingTarget(FurthestBuilding) then
			return GetAncient(bot:GetTeam())
		end
	end
	
	return nil
end

function PAF.GetClosestTPLocation(bot, Unit, TravelBootsAvailable)
	local TableUnits = GetUnitList(UNIT_LIST_ALLIED_BUILDINGS)
	
	if TravelBootsAvailable then
		if bot:FindItemSlot("item_travel_boots_2") >= 0 then
			return Unit
		elseif bot:FindItemSlot("item_travel_boots") >= 0 then
			local AlliedCreeps = GetUnitList(UNIT_LIST_ALLIED_CREEPS)
			for v, Creep in pairs(AlliedCreeps) do
				table.insert(TableUnits, Creep)
			end
		end
	end
	
	local ClosestUnit = PAF.GetClosestUnit(Unit, TableUnits)
	if ClosestUnit ~= nil then
		return ClosestUnit
	else
		return nil
	end
end

return PAF