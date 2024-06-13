local PPush = {}

local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local PC = require(GetScriptDirectory() ..  "/Library/PhalanxCarries")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")
local PAF = require(GetScriptDirectory() ..  "/Library/PhalanxAbilityFunctions")

function PPush.GetPushDesire(bot, lane)
	local NetworthMin = 0
	if PRoles.GetPRole(bot, bot:GetUnitName()) == "MidLane"
	or PRoles.GetPRole(bot, bot:GetUnitName()) == "OffLane"
	or PRoles.GetPRole(bot, bot:GetUnitName()) == "SafeLane" then
		NetworthMin = 3055
	end

	if not P.IsInLaningPhase() and bot:GetLevel() >= 6 and bot:GetNetWorth() >= NetworthMin then
		return GetPushLaneDesire(lane)
	else
		return 0
	end
end

function PPush.PushThink(bot, lane)
	local EnemyFrontVisible = true

	local LaneFrontLoc = GetLaneFrontLocation(bot:GetTeam(), lane, 0)
	
	local DeltaFromFront = 500
	local MoveToPos
	local EnemiesWithinRange = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	local AlliesWithinRange = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
	local FilteredAllies = PAF.FilterTrueUnits(AlliesWithinRange)
	local CombinedAllyPower = PAF.CombineOffensivePower(FilteredAllies, false)
	local CombinedEnemyPower = PAF.CombineOffensivePower(FilteredEnemies, true)
	
	local NearbyAllyLaneCreeps = bot:GetNearbyLaneCreeps(1600, false)
	local NearbyEnemyLaneCreeps = bot:GetNearbyLaneCreeps(1600, true)
	local NearbyEnemyFillers = bot:GetNearbyFillers(1600, true)
	local NearbyEnemyTowers = bot:GetNearbyTowers(1600, true)
	local NearbyEnemyBarracks = bot:GetNearbyBarracks(1600, true)
	local EnemyAncient = GetAncient(GetOpposingTeam())
	
	if CombinedAllyPower <= CombinedEnemyPower or #NearbyAllyLaneCreeps == 0 then
		DeltaFromFront = 1400
	end
	
	MoveToPos = GetLaneFrontLocation(bot:GetTeam(), lane, -DeltaFromFront)
	
	local IsBeingTargetedByTower = false
	for v, Tower in pairs(NearbyEnemyTowers) do
		local TowerAttackTarget = Tower:GetAttackTarget()
		if TowerAttackTarget == bot then
			IsBeingTargetedByTower = true
			break
		end
	end
	
	if IsBeingTargetedByTower then
		if NearbyAllyLaneCreeps[1] ~= nil and NearbyEnemyTowers[1] ~= nil then
			if GetUnitToUnitDistance(NearbyAllyLaneCreeps[1], NearbyEnemyTowers[1]) < 700 then
				bot:Action_AttackUnit(NearbyAllyLaneCreeps[1], false)
				return
			else
				bot:Action_MoveToLocation(MoveToPos)
				return
			end
		end
	end
	
	if #NearbyEnemyLaneCreeps > 0 then
		for v, Creep in pairs(NearbyEnemyLaneCreeps) do
			if Creep ~= nil
			and Creep:CanBeSeen()
			and not Creep:IsInvulnerable()
			and GetUnitToLocationDistance(Creep, MoveToPos) <= 1100 then
				bot:Action_AttackUnit(Creep, false)
				return
			end
		end
	end
	
	if EnemyAncient ~= nil
	and EnemyAncient:CanBeSeen()
	and not EnemyAncient:IsInvulnerable()
	and GetUnitToLocationDistance(EnemyAncient, MoveToPos) <= 1100 then
		bot:Action_AttackUnit(EnemyAncient, false)
		return
	end
	
	if #NearbyEnemyBarracks > 0 then
		for v, Barracks in pairs(NearbyEnemyBarracks) do
			if string.find(Barracks:GetUnitName(), "melee") then
				if Barracks ~= nil
				and Barracks:CanBeSeen()
				and not Barracks:IsInvulnerable()
				and GetUnitToLocationDistance(Barracks, MoveToPos) <= 1100 then
					bot:Action_AttackUnit(Barracks, false)
					return
				end
			end
		end
		
		for v, Barracks in pairs(NearbyEnemyBarracks) do
			if string.find(Barracks:GetUnitName(), "range") then
				if Barracks ~= nil
				and Barracks:CanBeSeen()
				and not Barracks:IsInvulnerable()
				and GetUnitToLocationDistance(Barracks, MoveToPos) <= 1100 then
					bot:Action_AttackUnit(Barracks, false)
					return
				end
			end
		end
	end
	
	if #NearbyEnemyTowers > 0 then
		for v, Tower in pairs(NearbyEnemyTowers) do
			if Tower ~= nil
			and Tower:CanBeSeen()
			and not Tower:IsInvulnerable()
			and GetUnitToLocationDistance(Tower, MoveToPos) <= 1100 then
				bot:Action_AttackUnit(Tower, false)
				return
			end
		end
	end
	
	if #NearbyEnemyFillers > 0 then
		for v, Filler in pairs(NearbyEnemyFillers) do
			if Filler ~= nil
			and Filler:CanBeSeen()
			and not Filler:IsInvulnerable()
			and GetUnitToLocationDistance(Filler, MoveToPos) <= 1100 then
				bot:Action_AttackUnit(Filler, false)
				return
			end
		end
	end
	
	if GetUnitToLocationDistance(bot, MoveToPos) <= 800 then
		bot:Action_MoveToLocation(MoveToPos+RandomVector(500))
		return
	else
		bot:Action_MoveToLocation(MoveToPos)
		return
	end
end

return PPush