local bot = GetBot()

local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")
local PAF = require(GetScriptDirectory() ..  "/Library/PhalanxAbilityFunctions")
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")

local FinishedLaning = false

-- SUPPORT TIMINGS
local LotusPool = (3 * 60)
local BountyRuneOne = (4 * 60)
local WisdomFountain = (7 * 60)
local BountyRuneTwo = (8 * 60)

-- Locations
local RWR = Vector(-8088.000000, 408.000183, 280.742340)
local DWR = Vector(8340.000000, -1008.000000, 280.742340)

-- Tower diving
local LastTowerDive = -90

function GetDesire()
	if DotaTime() < 0 then
		return BOT_MODE_DESIRE_NONE
	end
	
	local NumBots = 0
	local BotsReadyToPush = 0
	
	local IDs = GetTeamPlayers(bot:GetTeam())
	for v, ID in pairs(IDs) do
		if IsPlayerBot(ID) then
			NumBots = (NumBots + 1)
			
			if GetHeroLevel(ID) >= 6 then
				BotsReadyToPush = (BotsReadyToPush + 1)
			end
		end
	end
	
	if BotsReadyToPush < NumBots then
		if IsTowerDivingForEnemy() then
			return BOT_MODE_DESIRE_ABSOLUTE
		end
		
		return BOT_MODE_DESIRE_MODERATE
	end

	return BOT_MODE_DESIRE_NONE
end

function Think()
	local AssignedLane = bot:GetAssignedLane()
	local FountainLoc = PAF.GetFountainLocation(bot)
	local AlliedLaneFrontLoc = GetLaneFrontLocation(bot:GetTeam(), AssignedLane, 0)
	local EnemyLaneFrontLoc = GetLaneFrontLocation(GetOpposingTeam(), AssignedLane, 0)
	local NearbyEnemyTowers = bot:GetNearbyTowers(1600, true)
	local DeltaStandPos = 300
	local MoveToLoc, MoveToLHLoc
	local TeamToPositionAround = bot:GetTeam()
	local StandBackFromTowerRange = 850
	
	local AttackRange = bot:GetAttackRange()
	local AttackDamage = bot:GetAttackDamage()
	local AttackSpeed = bot:GetAttackSpeed()
	local AttackPoint = bot:GetAttackPoint()
	local SecondsPerAttack = bot:GetSecondsPerAttack()
	local LastAttackTime = bot:GetLastAttackTime()
	
	local DamageVariance = bot:GetBaseDamageVariance()
	AttackDamage = (AttackDamage - DamageVariance)
	
	if PAF.IsItemAvailable("item_quelling_blade") == true then
		if IsRanged(bot) then
			AttackDamage = (AttackDamage + 4)
		else
			AttackDamage = (AttackDamage + 8)
		end
	end
	
	if bot:GetUnitName() == "npc_dota_hero_jakiro" then
		AttackDamage = (AttackDamage * 2)
	end
	
	-- If we're tower diving an enemy and likely can't kill them, force the bot to walk back
	if IsTowerDivingForEnemy() then
		bot:Action_MoveToLocation(PAF.GetFountainLocation(bot))
	end
	
	local LaneEnemyHeroes = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(LaneEnemyHeroes)
	local LaneAllyHeroes = bot:GetNearbyHeroes(1200, false, BOT_MODE_NONE)
	local FilteredAllies = PAF.FilterTrueUnits(LaneAllyHeroes)
	
	-- If we're outranged in laning phase, then try to stay out of attack range
	if #FilteredEnemies >= #FilteredAllies then
		local TotalAllyRange = 0
		local TotalEnemyRange = 0
		
		local LargestEnemyRange = 0
		
		for v, Unit in pairs(FilteredAllies) do
			TotalAllyRange = (TotalAllyRange + Unit:GetAttackRange())
		end
		
		for v, Unit in pairs(FilteredEnemies) do
			TotalEnemyRange = (TotalEnemyRange + Unit:GetAttackRange())
			
			if Unit:GetAttackRange() > LargestEnemyRange then
				LargestEnemyRange = Unit:GetAttackRange()
			end
		end
		
		if TotalEnemyRange > TotalAllyRange and LargestEnemyRange > DeltaStandPos then
			DeltaStandPos = (LargestEnemyRange - DeltaStandPos)
		end
	end
	
	--------------------
	-- DEAGGRO TOWERS --
	--------------------
	
	local TowerTargetingBot = nil
	local IsBeingTargetedByTower = false
	if #NearbyEnemyTowers > 0 then
		for v, Tower in pairs(NearbyEnemyTowers) do
			local TowerTarget = Tower:GetAttackTarget()
			
			if TowerTarget == bot then
				IsBeingTargetedByTower = true
				TowerTargetingBot = Tower
				break
			end
		end
	end
	
	if IsBeingTargetedByTower == true then
		local NALC = bot:GetNearbyLaneCreeps(1600, false)
		for v, Creep in pairs(NALC) do
			if GetUnitToUnitDistance(Creep, TowerTargetingBot) <= 700 then
				bot:Action_AttackUnit(Creep, false)
				return
			end
		end
		
		bot:Action_MoveToLocation(FountainLoc)
		return
	end
	
	---------------------------
	-- ESTABLISH POSITIONING --
	---------------------------
	
	if PRoles.IsCoreHero(bot) then
		-- Determine if our bot should position itself around the enemy creeps or allied creeps
		if P.GetDistance(EnemyLaneFrontLoc, FountainLoc) <= P.GetDistance(AlliedLaneFrontLoc, FountainLoc) then
			TeamToPositionAround = GetOpposingTeam()
		end
		
		-- Determine how far back the bot needs to position itself if allied creeps are within tower range
		if #NearbyEnemyTowers > 0 and NearbyEnemyTowers[1]:CanBeSeen() then
			local LaneFrontToTowerDist = GetUnitToLocationDistance(NearbyEnemyTowers[1], AlliedLaneFrontLoc)
			
			if LaneFrontToTowerDist <= 700 then
				if TeamToPositionAround == bot:GetTeam() then
					DeltaStandPos = (StandBackFromTowerRange + LaneFrontToTowerDist)
				else
					if GetUnitToUnitDistance(bot, NearbyEnemyTowers[1]) < GetUnitToLocationDistance(bot, EnemyLaneFrontLoc) then
						DeltaStandPos = StandBackFromTowerRange
					end
				end
			end
		end
		
		MoveToLoc = GetLaneFrontLocation(TeamToPositionAround, AssignedLane, -DeltaStandPos)
		
		local AlliesWithinRange = bot:GetNearbyHeroes(1200, false, BOT_MODE_NONE)
		local FilteredAllies = PAF.FilterTrueUnits(AlliesWithinRange)
		
		if #FilteredAllies >= 2 then
			MoveToLoc = GetSpreadMoveToLoc(MoveToLoc, AssignedLane, bot:GetTeam())
		end
	elseif PRoles.IsSupportHero(bot) then
		-- Determine if our bot should position itself around the enemy creeps or allied creeps
		if P.GetDistance(EnemyLaneFrontLoc, FountainLoc) <= P.GetDistance(AlliedLaneFrontLoc, FountainLoc) then
			TeamToPositionAround = GetOpposingTeam()
		end
		
		-- Determine how far back the bot needs to position itself if allied creeps are within tower range
		if #NearbyEnemyTowers > 0 and NearbyEnemyTowers[1]:CanBeSeen() then
			local LaneFrontToTowerDist = GetUnitToLocationDistance(NearbyEnemyTowers[1], AlliedLaneFrontLoc)
			
			if LaneFrontToTowerDist <= 700 then
				if TeamToPositionAround == bot:GetTeam() then
					DeltaStandPos = (StandBackFromTowerRange - LaneFrontToTowerDist)
				else
					if GetUnitToUnitDistance(bot, NearbyEnemyTowers[1]) < GetUnitToLocationDistance(bot, EnemyLaneFrontLoc) then
						DeltaStandPos = StandBackFromTowerRange
					end
				end
			end
		end
		
		if (DotaTime() >= (BountyRuneOne - 15) and DotaTime() < BountyRuneOne)
		or (DotaTime() >= (BountyRuneTwo - 15) and DotaTime() < BountyRuneTwo) then
			MoveToLoc = GetResponsibleRuneLoc()
		--[[elseif DotaTime() >= (WisdomFountain - 15)
		and DotaTime() < WisdomFountain
		and PRoles.GetPRole(bot, bot:GetUnitName()) == "SoftSupport" then
			MoveToLoc = GetWisdomRuneLoc()]]--
		else
			MoveToLoc = GetLaneFrontLocation(TeamToPositionAround, AssignedLane, -DeltaStandPos)
			
			local AlliesWithinRange = bot:GetNearbyHeroes(1200, false, BOT_MODE_NONE)
			local FilteredAllies = PAF.FilterTrueUnits(AlliesWithinRange)
			
			if #FilteredAllies >= 2 then
				MoveToLoc = GetSpreadMoveToLoc(MoveToLoc, AssignedLane, bot:GetTeam())
			end
		end
	end
	
	----------------------------
	-- HARASSING ENEMY HEROES --
	----------------------------
	
	local HarassRange = (AttackRange + 50)
	local CreepAggroRange = 500
	
	local NearbyEnemyHeroes = bot:GetNearbyHeroes(HarassRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(NearbyEnemyHeroes)
	local NearbyEnemyCreeps = bot:GetNearbyLaneCreeps(CreepAggroRange, true)
	local TowersInRange = bot:GetNearbyTowers(700, true)
	
	if IsAttackReady(LastAttackTime, AttackPoint, SecondsPerAttack)
	and #NearbyEnemyHeroes > 0
	and #TowersInRange <= 0 then
		local WeakestHero = PAF.GetWeakestUnit(FilteredEnemies)
		
		if #NearbyEnemyCreeps <= 3 then
			bot:Action_AttackUnit(WeakestHero, true)
			return
		end
	end
	
	--------------------------------
	-- CREEP SCORE (LAST HITTING) --
	--------------------------------
	
	local AllowedToLastHit = true
	
	if PRoles.IsSupportHero(bot) then
		local NearbyAllyHeroes = bot:GetNearbyHeroes(1200, false, BOT_MODE_NONE)
		local FilteredAllies = PAF.FilterTrueUnits(NearbyAllyHeroes)
		
		for v, Ally in pairs(FilteredAllies) do
			if (Ally:IsBot() and PRoles.IsCoreHero(Ally))
			or not Ally:IsBot() then
				AllowedToLastHit = false
			end
		end
	end
		
	if AllowedToLastHit then
		local NearbyEnemyCreeps = bot:GetNearbyCreeps(1200, true)
			
		if #NearbyEnemyCreeps > 0 then
			local WeakestCreep = PAF.GetWeakestUnit(NearbyEnemyCreeps)
				
			if PAF.IsValidCreepTarget(WeakestCreep) then
				local ShouldLastHit = true
					
				-- If we don't have a lot of allied creeps under the enemy tower, don't dive to last hit
				if #NearbyEnemyTowers > 0 and NearbyEnemyTowers[1]:CanBeSeen() then
					if GetUnitToUnitDistance(WeakestCreep, NearbyEnemyTowers[1]) <= 700 then
						if GetUnitToUnitDistance(WeakestCreep, bot) > AttackRange then
							local NearbyAllyCreeps = bot:GetNearbyCreeps(1600, false)
								
							local PrimaryTower = NearbyEnemyTowers[1]
							if IsSafeAmountOfCreepsInEnemyTowerRange(PrimaryTower, NearbyAllyCreeps) == false then
								ShouldLastHit = false
							end
						end
					end
				end
				
				-- Last hit creeps and position the bot to get a last hit
				if ShouldLastHit then
					local AttackingUnits = GetAttackingUnits(WeakestCreep, false)
					
					if CanLastHitCreep(WeakestCreep, AttackDamage, AttackPoint, AttackingUnits) == true then
						return
					end
					
					if ShouldPrepareToLastHitCreep(WeakestCreep, AttackingUnits, AttackDamage) then
						local MoveToLHLoc = PAF.GetXUnitsTowardsLocation(WeakestCreep:GetLocation(), MoveToLoc, AttackRange)
						local LastHitPos = PAF.GetXUnitsTowardsLocation(WeakestCreep:GetLocation(), MoveToLHLoc, AttackRange)
							
						if GetUnitToUnitDistance(bot, WeakestCreep) > AttackRange then
							bot:Action_MoveToLocation(LastHitPos)
							return
						else
							bot:Action_MoveToLocation(bot:GetLocation())
							return
						end
					end
				end
			end
		end
	end
	
	---------------------------
	-- CREEP SCORE (DENYING) --
	---------------------------
		
	local NearbyAllyCreeps = bot:GetNearbyCreeps(1200, false)
		
	if #NearbyAllyCreeps > 0 then
		local WeakestCreep = PAF.GetWeakestUnit(NearbyAllyCreeps)
			
		if PAF.IsValidCreepTarget(WeakestCreep) then
			local ShouldLastHit = true
				
			-- If we don't have a lot of allied creeps under the enemy tower, don't dive to last hit
			if #NearbyEnemyTowers > 0 and NearbyEnemyTowers[1]:CanBeSeen() then
				if GetUnitToUnitDistance(WeakestCreep, NearbyEnemyTowers[1]) <= 700 then
					if GetUnitToUnitDistance(WeakestCreep, bot) > AttackRange then
						local NearbyAllyCreepsTwo = bot:GetNearbyCreeps(1600, false)
							
						local PrimaryTower = NearbyEnemyTowers[1]
						if IsSafeAmountOfCreepsInEnemyTowerRange(PrimaryTower, NearbyAllyCreepsTwo) == false then
							ShouldLastHit = false
						end
					end
				end
			end
				
			-- Last hit creeps and position the bot to get a last hit
			if ShouldLastHit then
				local AttackingUnits = GetAttackingUnits(WeakestCreep, true)
				
				if CanLastHitCreep(WeakestCreep, AttackDamage, AttackPoint, AttackingUnits) == true then
					return
				end
					
				if ShouldPrepareToLastHitCreep(WeakestCreep, AttackingUnits, AttackDamage) then
					local MoveToLHLoc = PAF.GetXUnitsTowardsLocation(WeakestCreep:GetLocation(), MoveToLoc, AttackRange)
					local LastHitPos = PAF.GetXUnitsTowardsLocation(WeakestCreep:GetLocation(), MoveToLHLoc, AttackRange)
						
					if GetUnitToUnitDistance(bot, WeakestCreep) > AttackRange then
						bot:Action_MoveToLocation(LastHitPos)
						return
					else
						bot:Action_MoveToLocation(bot:GetLocation())
						return
					end
				end
			end
		end
	end
	
	-------------------------------------
	-- ATTACK TOWERS WITH SIEGE CREEPS --
	-------------------------------------
	
	if #NearbyEnemyTowers > 0 and NearbyEnemyTowers[1]:CanBeSeen() then
		local NearbyAllyLaneCreeps = bot:GetNearbyLaneCreeps(1600, false)
		
		if #NearbyAllyLaneCreeps > 0 then
			local NumCreepsInTowerRange = 0
			local SiegeCreepIsAttackingTower = false
			local WillTowerSoonAggro = false
			
			for v, Creep in pairs(NearbyAllyLaneCreeps) do
				if GetUnitToUnitDistance(Creep, NearbyEnemyTowers[1]) <= 700 then
					NumCreepsInTowerRange = (NumCreepsInTowerRange + 1)
				end
				
				if string.find(Creep:GetUnitName(), "siege") then
					if not SiegeCreepIsAttackingTower then
						SiegeCreepIsAttackingTower = true
					end
				end
			end
			
			local TowerTarget = NearbyEnemyTowers[1]:GetAttackTarget()
			if PAF.IsValidCreepTarget(TowerTarget) then
				local TowerDamage = NearbyEnemyTowers[1]:GetAttackDamage()
				local EstimatedTowerDmgToTarget = TowerTarget:GetActualIncomingDamage(TowerDamage, DAMAGE_TYPE_PHYSICAL)
				
				if TowerTarget:GetHealth() <= EstimatedTowerDmgToTarget then
					if not WillTowerSoonAggro then
						WillTowerSoonAggro = true
					end
				end
			end
			
			if NumCreepsInTowerRange >= 3 and SiegeCreepIsAttackingTower and not WillTowerSoonAggro then
				bot:Action_AttackUnit(NearbyEnemyTowers[1], true)
				return
			end
		end
	end
	
	-----------------
	-- POSITIONING --
	-----------------
	
	local NearbyAllyCreepsTwo = bot:GetNearbyCreeps(1600, false)
	
	-- Avoid being in tower range whenever possible
	if #NearbyEnemyTowers > 0 then
		local PrimaryTower = NearbyEnemyTowers[1]
		if IsSafeAmountOfCreepsInEnemyTowerRange(PrimaryTower, NearbyAllyCreepsTwo) == false then
			if GetUnitToUnitDistance(bot, NearbyEnemyTowers[1]) <= 1000 then
				local EscapeTowerLoc = GetLaneFrontLocation(TeamToPositionAround, AssignedLane, -1600)
				bot:Action_MoveToLocation(EscapeTowerLoc)
				return
			end
		end
	end
	
	-- Run back if we've drawn creep aggro
	for v, Creep in pairs(NearbyAllyCreepsTwo) do
		local CreepTarget = Creep:GetAttackTarget()
		
		if CreepTarget == bot then
			local EscapeTowerLoc = GetLaneFrontLocation(TeamToPositionAround, AssignedLane, -1200)
			bot:Action_MoveToLocation(EscapeTowerLoc)
			return
		end
	end
	
	if GetUnitToLocationDistance(bot, MoveToLoc) <= 1600 then
		local NewMoveToLoc = (MoveToLoc+RandomVector(150))
			
		bot:Action_MoveToLocation(NewMoveToLoc)
		return
	else
		bot:Action_MoveToLocation(MoveToLoc)
		return
	end
end

--// EXTRA FUNCTIONS \\--

function IsTowerDivingForEnemy()
	if bot:GetActiveMode() == BOT_MODE_ATTACK then
		local TowersInDiveRange = bot:GetNearbyTowers(850, true)
		local BotTarget = bot:GetTarget()
		local NearbyAttackingAllies = bot:GetNearbyHeroes(1200, false, BOT_MODE_ATTACK)
		local FilteredAllies = PAF.FilterTrueUnits(NearbyAttackingAllies)
		
		local AlliesAttackingTarget = {}
		
		for v, Ally in pairs(FilteredAllies) do
			if Ally:GetTarget() == BotTarget
			or Ally:GetAttackTarget() == BotTarget then
				table.insert(AlliesAttackingTarget, Ally)
			end
		end
		
		local CombinedDamageToTarget = PAF.CombineEstimatedDamage(true, AlliesAttackingTarget, BotTarget, 2.5, DAMAGE_TYPE_ALL)
		
		if #TowersInDiveRange > 0
		and BotTarget:GetHealth() > CombinedDamageToTarget then
			LastTowerDive = DotaTime()
		end
	end
	
	if (DotaTime() - LastTowerDive) <= 2 then
		return true
	end
	
	return false
end

function GetAttackingUnits(hCreep, bEnemies)
	local NearbyCreeps = bot:GetNearbyCreeps(1600, bEnemies)
	local NearbyTowers = bot:GetNearbyTowers(1600, bEnemies)
	local NearbyHeroes = bot:GetNearbyHeroes(1600, bEnemies, BOT_MODE_NONE)
	
	local AttackingUnits = {}
	
	if #NearbyCreeps > 0 then
		for v, Unit in pairs(NearbyCreeps) do
			if Unit:GetAttackTarget() == hCreep then
				table.insert(AttackingUnits, Unit)
			end
		end
	end
	
	if #NearbyTowers > 0 then
		for v, Unit in pairs(NearbyTowers) do
			if Unit:GetAttackTarget() == hCreep then
				table.insert(AttackingUnits, Unit)
			end
		end
	end
	
	if #NearbyHeroes > 0 then
		for v, Unit in pairs(NearbyHeroes) do
			if Unit:GetAttackTarget() == hCreep then
				table.insert(AttackingUnits, Unit)
			end
		end
	end
	
	return AttackingUnits
end

function ShouldPrepareToLastHitCreep(hCreep, tAttackingUnits, nBotAttackDmg)
	local CreepHP = hCreep:GetHealth()
	local TotalIncomingDamage = 0
	
	for v, Attacker in pairs(tAttackingUnits) do
		TotalIncomingDamage = (TotalIncomingDamage + (Attacker:GetAttackDamage() * 2))
	end
	
	local EstimatedDamage = hCreep:GetActualIncomingDamage(TotalIncomingDamage, DAMAGE_TYPE_PHYSICAL)
	
	if (CreepHP - EstimatedDamage) <= nBotAttackDmg then
		return true
	end
	
	return false
end

function CanLastHitCreep(hCreep, nBotAttackDmg, nBotAttackSpeed, tAttackingUnits)
	local CreepHP = hCreep:GetHealth()
	local EstimatedDamage = hCreep:GetActualIncomingDamage(nBotAttackDmg, DAMAGE_TYPE_PHYSICAL)
	
	local nBotAttackProjectileSpeed = 0
	local DistBetweenBotAndCreep = GetUnitToUnitDistance(bot, hCreep)
	if IsRanged(bot) then
		nBotAttackProjectileSpeed = bot:GetAttackProjectileSpeed()
		local AttackTravelTime = (DistBetweenBotAndCreep / nBotAttackProjectileSpeed)
		
		nBotAttackSpeed = (nBotAttackSpeed + AttackTravelTime)
	end
	
	if EstimatedDamage > CreepHP then
		bot:Action_AttackUnit(hCreep, false)
		return true
	end
	
	local TotalAttackerDamage = 0
	
	for v, Attacker in pairs(tAttackingUnits) do
		local AttackerDmg = (Attacker:GetAttackDamage() - Attacker:GetBaseDamageVariance())
		local EstimatedAttackerDamage = hCreep:GetActualIncomingDamage(AttackerDmg, DAMAGE_TYPE_PHYSICAL)
		TotalAttackerDamage = (TotalAttackerDamage + EstimatedAttackerDamage)
		
		if (CreepHP - EstimatedAttackerDamage) < EstimatedDamage then
			local AttackerSpeed = Attacker:GetAttackPoint()
			
			if Attacker:GetAnimActivity() == ACTIVITY_ATTACK
			or Attacker:GetAnimActivity() == ACTIVITY_ATTACK2 then
				local AttackerAnimCycle = Attacker:GetAnimCycle()
				local APValue = RemapValClamped(AttackerAnimCycle, 0.0, 1.0, 0.0, AttackerSpeed)
				AttackerSpeed = (AttackerSpeed - APValue)
			end
				
			if IsRanged(Attacker) then
					
				--[[if GetUnitToUnitDistance(hCreep, Attacker) <= 300 then
					
					if AttackerSpeed <= nBotAttackSpeed then
						bot:Action_AttackUnit(hCreep, false)
						return true
					else
						local DelayTime = (nBotAttackSpeed - AttackerSpeed)
						bot:ActionPush_Delay(DelayTime)
						bot:ActionPush_AttackUnit(hCreep, false)
						return true
					end
						
				else]]--
						
					local Projectiles = hCreep:GetIncomingTrackingProjectiles()
										
					for x, proj in pairs(Projectiles) do
						if proj.is_attack == true
						and proj.caster == Attacker then
							local ProjectileSpeed = Attacker:GetAttackProjectileSpeed()
							local DistBetween = GetUnitToLocationDistance(hCreep, proj.location)
							local TimeToLand = (DistBetween / ProjectileSpeed)
								
							if TimeToLand < nBotAttackSpeed
							and hCreep:GetAnimActivity() ~= ACTIVITY_RUN then
								bot:Action_AttackUnit(hCreep, false)
								return true
							end
						end
					end
						
				--end
			else
				
				if AttackerSpeed <= nBotAttackSpeed then
					bot:Action_AttackUnit(hCreep, false)
					return true
				--[[else
					local DelayTime = (nBotAttackSpeed - AttackerSpeed)
						
					bot:Action_ClearActions(false)
					bot:ActionQueue_Delay(DelayTime)
					bot:ActionQueue_AttackUnit(hCreep, false)
					return true]]--
				end
					
			end
		end
	end
	
	if (CreepHP - TotalAttackerDamage) < EstimatedDamage then
		local LastUnitThatWillHit = nil
		local LowestAnimCycleNum = 1.0
		
		for v, Attacker in pairs(tAttackingUnits) do
			if Attacker:GetAnimActivity() == ACTIVITY_ATTACK
			or Attacker:GetAnimActivity() == ACTIVITY_ATTACK2 then
				if Attacker:GetAnimCycle() < LowestAnimCycleNum then
					LowestAnimCycleNum = Attacker:GetAnimCycle()
					LastUnitThatWillHit = Attacker
				end
			end
		end
		
		if LastUnitThatWillHit ~= nil then
			local LastUnitAttackPoint = LastUnitThatWillHit:GetAttackPoint()
			local APValue = RemapValClamped(LowestAnimCycleNum, 0.0, 1.0, 0.0, LastUnitAttackPoint)
			local LastUnitCurrentPoint = (LastUnitAttackPoint - APValue)
			
			if IsRanged(LastUnitThatWillHit) then
				local UnitProjectileSpeed = bot:GetAttackProjectileSpeed()
				local DistBetweenLastUnitAndCreep = GetUnitToUnitDistance(LastUnitThatWillHit, hCreep)
				local LastUnitAttackTravelTime = (DistBetweenLastUnitAndCreep / UnitProjectileSpeed)
				
				LastUnitCurrentPoint = (LastUnitCurrentPoint + LastUnitAttackTravelTime)
			end
			
			if LastUnitCurrentPoint < nBotAttackSpeed then
				local DebugChat = ("Creep hit "..LastUnitCurrentPoint.." / My hit "..nBotAttackSpeed)
				
				--bot:ActionImmediate_Chat(DebugChat, true)
				bot:Action_AttackUnit(hCreep, false)
				return true
			--[[else
				local DelayTime = (nBotAttackSpeed - LastUnitCurrentPoint)
				
				bot:Action_ClearActions(false)
				bot:ActionQueue_Delay(DelayTime)
				bot:ActionQueue_AttackUnit(hCreep, false)
				return true]]--
			end
		end
	end
	
	return false
end

function IsRanged(hUnit)
	if hUnit:GetAttackRange() > 310 then
		return true
	end
	
	return false
end

function IsAttackReady(nLastAttackTime, nAttackPoint, nSecondsPerAttack)
	if GameTime() >= (nLastAttackTime + nSecondsPerAttack) then
		return true
	end
	
	return false
end

function IsSafeAmountOfCreepsInEnemyTowerRange(hTower, tCreeps)
	local NumCreeps = 0
	
	if #tCreeps > 0 then
		for v, Creep in pairs(tCreeps) do
			if GetUnitToUnitDistance(Creep, hTower) <= 700 then
				NumCreeps = (NumCreeps + 1)
			end
		end
	end
	
	if NumCreeps >= 3 then
		return true
	end
	
	return false
end

function GetResponsibleRuneLoc()
	if PRoles.GetPRole(bot, bot:GetUnitName()) == "SoftSupport" then
		if bot:GetTeam() == TEAM_RADIANT then
			return GetRuneSpawnLocation(RUNE_BOUNTY_1)
		elseif bot:GetTeam() == TEAM_DIRE then
			return GetRuneSpawnLocation(RUNE_BOUNTY_2)
		end
	elseif PRoles.GetPRole(bot, bot:GetUnitName()) == "HardSupport" then
		if bot:GetTeam() == TEAM_RADIANT then
			return GetRuneSpawnLocation(RUNE_BOUNTY_2)
		elseif bot:GetTeam() == TEAM_DIRE then
			return GetRuneSpawnLocation(RUNE_BOUNTY_1)
		end
	end
	
	return nil
end

function GetWisdomRuneLoc()
	if bot:GetTeam() == TEAM_RADIANT then
		if PRoles.GetPRole(bot, bot:GetUnitName()) == "SoftSupport" then
			return RWR
		elseif PRoles.GetPRole(bot, bot:GetUnitName()) == "HardSupport" then
			return DWR
		end
	elseif bot:GetTeam() == TEAM_DIRE then
		if PRoles.GetPRole(bot, bot:GetUnitName()) == "SoftSupport" then
			return DWR
		elseif PRoles.GetPRole(bot, bot:GetUnitName()) == "HardSupport" then
			return RWR
		end
	end
end

function GetSpreadMoveToLoc(vLaneFront, nAssignedLane, nTeam)
	local RadiantFountain = Vector( -7169, -6654, 392 )
	local DireFountain = Vector( 6974, 6402, 392 )
	
	local DistantToRadiantFountain = P.GetDistance(vLaneFront, RadiantFountain)
	local DistantToDireFountain = P.GetDistance(vLaneFront, DireFountain)
	
	local Offset = 300
	
	if nTeam == TEAM_RADIANT then
		if nAssignedLane == LANE_TOP then
			if PRoles.GetPRole(bot, bot:GetUnitName()) == "OffLane" then
				if DistantToRadiantFountain <= DistantToDireFountain then
					return Vector((vLaneFront.x - Offset), vLaneFront.y)
				elseif DistantToRadiantFountain > DistantToDireFountain then
					return Vector(vLaneFront.x, (vLaneFront.y - Offset))
				end
			elseif PRoles.GetPRole(bot, bot:GetUnitName()) == "SoftSupport" then
				if DistantToRadiantFountain <= DistantToDireFountain then
					return Vector((vLaneFront.x + Offset), vLaneFront.y)
				elseif DistantToRadiantFountain > DistantToDireFountain then
					return Vector(vLaneFront.x, (vLaneFront.y + Offset))
				end
			end
		elseif nAssignedLane == LANE_BOT then
			if PRoles.GetPRole(bot, bot:GetUnitName()) == "SafeLane" then
				if DistantToRadiantFountain <= DistantToDireFountain then
					return Vector(vLaneFront.x, (vLaneFront.y - Offset))
				elseif DistantToRadiantFountain > DistantToDireFountain then
					return Vector((vLaneFront.x + Offset), vLaneFront.y)
				end
			elseif PRoles.GetPRole(bot, bot:GetUnitName()) == "HardSupport" then
				if DistantToRadiantFountain <= DistantToDireFountain then
					return Vector(vLaneFront.x, (vLaneFront.y + Offset))
				elseif DistantToRadiantFountain > DistantToDireFountain then
					return Vector((vLaneFront.x - Offset), vLaneFront.y)
				end
			end
		end
	end
	
	if nTeam == TEAM_DIRE then
		if nAssignedLane == LANE_BOT then
			if PRoles.GetPRole(bot, bot:GetUnitName()) == "OffLane" then
				if DistantToRadiantFountain <= DistantToDireFountain then
					return Vector(vLaneFront.x, (vLaneFront.y + Offset))
				elseif DistantToRadiantFountain > DistantToDireFountain then
					return Vector((vLaneFront.x + Offset), vLaneFront.y)
				end
			elseif PRoles.GetPRole(bot, bot:GetUnitName()) == "SoftSupport" then
				if DistantToRadiantFountain <= DistantToDireFountain then
					return Vector(vLaneFront.x, (vLaneFront.y - Offset))
				elseif DistantToRadiantFountain > DistantToDireFountain then
					return Vector((vLaneFront.x - Offset), vLaneFront.y)
				end
			end
		elseif nAssignedLane == LANE_TOP then
			if PRoles.GetPRole(bot, bot:GetUnitName()) == "SafeLane" then
				if DistantToRadiantFountain < DistantToDireFountain then
					return Vector((vLaneFront.x - Offset), vLaneFront.y)
				elseif DistantToRadiantFountain >= DistantToDireFountain then
					return Vector(vLaneFront.x, (vLaneFront.y + Offset))
				end
			elseif PRoles.GetPRole(bot, bot:GetUnitName()) == "HardSupport" then
				if DistantToRadiantFountain < DistantToDireFountain then
					return Vector((vLaneFront.x + Offset), vLaneFront.y)
				elseif DistantToRadiantFountain >= DistantToDireFountain then
					return Vector(vLaneFront.x, (vLaneFront.y - Offset))
				end
			end
		end
	end
	
	return vLaneFront
end