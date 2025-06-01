local bot = GetBot()

local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")
local PAF = require(GetScriptDirectory() ..  "/Library/PhalanxAbilityFunctions")

---------------
-- VARIABLES --
---------------

local AllyWisdomFountainLoc, EnemyWisdomFountainLoc
local AllyLotusPoolLoc, EnemyLotusPoolLoc
local TormentorLoc

local WisdomShrinePinged = false
local IsAllyInAllyWisdomFountain = false
local AllyWisdomFountainBeginCollectTime = -90
local IsAllyInEnemyWisdomFountain = false
local EnemyWisdomFountainBeginCollectTime = -90
local AlliesInAllyWisdomFountain = {}
local AlliesInEnemyWisdomFountain = {}
local AllyWisdomFountainAvailable = false
local EnemyWisdomFountainAvailable = false
local AllyWisdomFountainSpawnTime = (7 * 60)
local EnemyWisdomFountainSpawnTime = (7 * 60)
local WisdomFountainRespawnTimer = (7 * 60)
local WisdomFountainCollectRadius = 300
local WisdomFountainCollectTime = 3

local LastTormentorChatTime = -90
local LastTormentorPing = -90
local AlliesInTormentorAttackRange = 0
local TeamHealthyForTormentor = true
local TormentorAvailable = false
local TormentorSpawnTime = (20 * 60)
local TormentorRespawnTimer = (10 * 60)

local AllyLotusPoolCount = 0
local EnemyLotusPoolCount = 0
local LotusPoolSpawnTime = (3 * 60)
local LotusPoolRespawnTimer = (3 * 60)
local LotusPoolCollectRadius = 350
local LotusPoolCollectTime = 1.5
local LotusPoolSubsequentPctReduction = 0.3

-------------------------
-- BUILDING REFERENCES --
-------------------------

-- npc_dota_xp_fountain
local RadiantWisdomFountain = Vector(-8088.000000, 408.000183, 280.742340)
local DireWisdomFountain = Vector(8340.000000, -1008.000000, 280.742340)

-- npc_dota_lotus_pool
local RadiantLotusPool = Vector(7603.976074, -4804.689941, 101.000000)
local DireLotusPool = Vector(-7627.282227, 4598.102539, 98.000000)

-- npc_dota_unit_twin_gate
local RadiantTwinGate = Vector(7360.000000, -6528.000000, 256.000000)
local DireTwinGate = Vector(-7488.000000, 6912.000000, 256.000000)

-- npc_dota_miniboss
local RadiantTormentor = Vector(7488.000000, -7856.705566, 256.000000)
local DireTormentor = Vector(-7201.829102, 7947.317871, 256.000000)

--------------------------
-- BUILDING ASSIGNMENTS --
--------------------------

if bot:GetTeam() == TEAM_RADIANT then
	AllyWisdomFountainLoc = RadiantWisdomFountain
	EnemyWisdomFountainLoc = DireWisdomFountain
	AllyLotusPoolLoc = RadiantLotusPool
	EnemyLotusPoolLoc = DireLotusPool
elseif bot:GetTeam() == TEAM_DIRE then
	AllyWisdomFountainLoc = DireWisdomFountain
	EnemyWisdomFountainLoc = RadiantWisdomFountain
	AllyLotusPoolLoc = DireLotusPool
	EnemyLotusPoolLoc = RadiantLotusPool
end

-----------
-- LOGIC --
-----------

function GetDesire()
	if GetTimeOfDay() >= 0.25 and GetTimeOfDay() < 0.75 then
		TormentorLoc = DireTormentor
	elseif GetTimeOfDay() >= 0.75 or GetTimeOfDay() < 0.25 then
		TormentorLoc = RadiantTormentor
	end
	
	UpdateWisdomFountainAvailability()
	UpdateTormentorAvailability()
	SetTeamHealthForTormentor()
	
	------------
	-- TIMING --
	------------
	
	-- Tell bots when Wisdom Shrines are available
	if DotaTime() > AllyWisdomFountainSpawnTime then
		AllyWisdomFountainSpawnTime = (AllyWisdomFountainSpawnTime + WisdomFountainRespawnTimer)
		
		if not AllyWisdomFountainAvailable then
			AllyWisdomFountainAvailable = true
			BotPingWisdomShrine()
		end
	end
	
	if DotaTime() > EnemyWisdomFountainSpawnTime then
		EnemyWisdomFountainSpawnTime = (EnemyWisdomFountainSpawnTime + WisdomFountainRespawnTimer)
		
		if not EnemyWisdomFountainAvailable then
			EnemyWisdomFountainAvailable = true
		end
	end
	
	-- Tell bots when Lotus Pools are available
	if DotaTime() > LotusPoolSpawnTime then
		AllyLotusPoolCount = (AllyLotusPoolCount + 1)
		EnemyLotusPoolCount = (EnemyLotusPoolCount + 1)
		
		LotusPoolSpawnTime = (LotusPoolSpawnTime + LotusPoolRespawnTimer)
	end
	
	-- Tell bots when Tormentor is available
	if not TormentorAvailable then
		if DotaTime() > TormentorSpawnTime then
			TormentorAvailable = true
		end
	end
	
	if ShouldCollectAllyWisdomFountain() then
		if P.IsInLaningPhase() then
			return BOT_MODE_DESIRE_VERYHIGH
		else
			if GetUnitToLocationDistance(bot, AllyWisdomFountainLoc) <= 8000 then
				return BOT_MODE_DESIRE_VERYHIGH
			end
		end
	end
	
	if ShouldCollectEnemyWisdomFountain() then
	--and GetUnitToLocationDistance(bot, EnemyWisdomFountainLoc) > (WisdomFountainCollectRadius / 2) then
		return BOT_MODE_DESIRE_VERYHIGH
	end
	
	if ShouldTeamDoTormentor() then
		return BOT_MODE_DESIRE_VERYHIGH
	end
	
	return BOT_MODE_DESIRE_NONE
end

function Think()
	if ShouldCollectAllyWisdomFountain() then
		bot:Action_MoveToLocation(AllyWisdomFountainLoc)
		return
	end
	
	if ShouldCollectEnemyWisdomFountain() then
		bot:Action_MoveToLocation(EnemyWisdomFountainLoc)
		return
	end
	
	if ShouldTeamDoTormentor() then
		if (DotaTime() - LastTormentorChatTime) >= 60 then
			LastTormentorChatTime = DotaTime()
			bot:ActionImmediate_Chat("Doing Tormentor!", false)
		end
		
		if IsRadiusVisible(TormentorLoc, 300)
		and GetUnitToLocationDistance(bot, TormentorLoc) <= 500 then
			if AlliesInTormentorAttackRange >= GetNumberOfBots() then
				local Neutrals = bot:GetNearbyNeutralCreeps(1600)
			
				if #Neutrals > 0 then
					for v, Neutral in pairs(Neutrals) do
						if Neutral:GetUnitName() == "npc_dota_miniboss" then
							if GetHighestLevelBot() == bot
							and (DotaTime() - LastTormentorPing) >= 60 then
								bot:ActionImmediate_Ping(TormentorLoc.x, TormentorLoc.y, true)
								LastTormentorPing = DotaTime()
							end
							
							bot:Action_AttackUnit(Neutral, false)
							return
						end
					end
				end
			else
				bot:Action_MoveToLocation(bot:GetLocation())
				return
			end
		else
			bot:Action_MoveToLocation(TormentorLoc)
			return
		end
	end
end

---------------
-- FUNCTIONS --
---------------

function UpdateWisdomFountainAvailability()
	local Allies = GetUnitList(UNIT_LIST_ALLIED_HEROES)
	local FilteredAllies = PAF.FilterTrueUnits(Allies)
	local Enemies = GetUnitList(UNIT_LIST_ENEMY_HEROES)
	local FilteredEnemies = PAF.FilterTrueUnits(Enemies)
	
	--------------------------
	-- ALLY WISDOM FOUNTAIN --
	--------------------------
	
	if AllyWisdomFountainAvailable == true then
		-- Determine if there is currently an ally in the Wisdom Shrine radius
		local AIAWF = false
		for x, Ally in pairs(FilteredAllies) do
			if GetUnitToLocationDistance(Ally, AllyWisdomFountainLoc) <= WisdomFountainCollectRadius then
				AIAWF = true
				break
			end
		end
		
		-- If there is an ally within radius, then set the time the ally got there to keep track of collection time
		if AIAWF then
			if not IsAllyInAllyWisdomFountain then
				IsAllyInAllyWisdomFountain = true
			end
		else
			IsAllyInAllyWisdomFountain = false
			AllyWisdomFountainBeginCollectTime = DotaTime()
		end
		
		-- Reset the start of collection time if an enemy steps into the radius with the ally
		if IsAllyInAllyWisdomFountain then
			for x, Ally in pairs(FilteredAllies) do
				if GetUnitToLocationDistance(Ally, AllyWisdomFountainLoc) <= WisdomFountainCollectRadius then
					local EnemyInRadius = false
					
					for y, Enemy in pairs(Enemies) do
						if GetUnitToLocationDistance(Enemy, AllyWisdomFountainLoc) <= WisdomFountainCollectRadius then
							EnemyInRadius = true
							break
						end
					end
					
					if EnemyInRadius then
						AllyWisdomFountainBeginCollectTime = DotaTime()
					else
						AlliesInAllyWisdomFountain[Ally:GetUnitName()] = DotaTime()
					end
				end
			end
		end
		
		-- If an ally was within the radius for the duration of the collection time uninterrupted then mark the pool unavailable
		for v, AllyTime in pairs(AlliesInAllyWisdomFountain) do
			if (AllyTime - AllyWisdomFountainBeginCollectTime) >= WisdomFountainCollectTime then
				if AllyWisdomFountainAvailable then
					AllyWisdomFountainAvailable = false
					break
				end
			end
		end
	end
	
	---------------------------
	-- ENEMY WISDOM FOUNTAIN --
	---------------------------
	
	if EnemyWisdomFountainAvailable == true then
		-- Determine if there is currently an ally in the Wisdom Shrine radius
		local AIEWF = false
		for x, Ally in pairs(FilteredAllies) do
			if GetUnitToLocationDistance(Ally, EnemyWisdomFountainLoc) <= WisdomFountainCollectRadius then
				AIEWF = true
				break
			end
		end
		
		-- If there is an ally within radius, then set the time the ally got there to keep track of collection time
		if AIEWF then
			if not IsAllyInEnemyWisdomFountain then
				IsAllyInEnemyWisdomFountain = true
			end
		else
			IsAllyInEnemyWisdomFountain = false
			EnemyWisdomFountainBeginCollectTime = DotaTime()
		end
		
		-- Reset the start of collection time if an enemy steps into the radius with the ally
		if IsAllyInEnemyWisdomFountain then
			for x, Ally in pairs(FilteredAllies) do
				if GetUnitToLocationDistance(Ally, EnemyWisdomFountainLoc) <= WisdomFountainCollectRadius then
					local EnemyInRadius = false
					
					for y, Enemy in pairs(Enemies) do
						if GetUnitToLocationDistance(Enemy, EnemyWisdomFountainLoc) <= WisdomFountainCollectRadius then
							EnemyInRadius = true
							break
						end
					end
					
					if EnemyInRadius then
						EnemyWisdomFountainBeginCollectTime = DotaTime()
					else
						AlliesInEnemyWisdomFountain[Ally:GetUnitName()] = DotaTime()
					end
				end
			end
		end
		
		-- If an ally was within the radius for the duration of the collection time uninterrupted then mark the pool unavailable
		for v, AllyTime in pairs(AlliesInEnemyWisdomFountain) do
			if (AllyTime - EnemyWisdomFountainBeginCollectTime) >= WisdomFountainCollectTime then
				if EnemyWisdomFountainAvailable then
					EnemyWisdomFountainAvailable = false
					break
				end
			end
		end
	end
end

function BotPingWisdomShrine()
	local Allies = GetUnitList(UNIT_LIST_ALLIED_HEROES)
	
	local LowestLevelHero = nil
	local LowestLevel = 31
		
	for v, Ally in pairs(Allies) do
		if Ally:IsBot() and Ally:GetLevel() < LowestLevel then
			LowestLevelHero = Ally
			LowestLevel = Ally:GetLevel()
		end
	end
	
	if LowestLevelHero == bot then
		bot:ActionImmediate_Ping(AllyWisdomFountainLoc.x, AllyWisdomFountainLoc.y, true)
	end
end

function ShouldCollectAllyWisdomFountain()
	local HeroToCollectWisdomFountain = nil
	
	if not AllyWisdomFountainAvailable then
		return false
	end
	
	local Allies = GetUnitList(UNIT_LIST_ALLIED_HEROES)
	local FilteredAllies = PAF.FilterTrueUnits(Allies)
	
	if P.IsInLaningPhase() then
		for v, Ally in pairs(Allies) do
			if not PAF.IsPossibleIllusion(Ally) then
				if PRoles.GetPRole(Ally, Ally:GetUnitName()) == "SoftSupport" then
					HeroToCollectWisdomFountain = Ally
					break
				end
			end
		end
	else
		local LowestLevelHero = nil
		local LowestLevel = 31
		
		for v, Ally in pairs(FilteredAllies) do
			if Ally:GetLevel() < LowestLevel then
				LowestLevelHero = Ally
				LowestLevel = Ally:GetLevel()
			end
		end
		
		HeroToCollectWisdomFountain = LowestLevelHero
	end
	
	if HeroToCollectWisdomFountain == bot then
		return true
	else
		return false
	end
end

function ShouldCollectEnemyWisdomFountain()
	local HeroToCollectWisdomFountain = nil
	
	if not EnemyWisdomFountainAvailable then
		return false
	end
	
	if P.IsInLaningPhase() then
		if PRoles.GetPRole(bot, bot:GetUnitName()) == "HardSupport" then
			HeroToCollectWisdomFountain = bot
		end
	else
		local Allies = GetUnitList(UNIT_LIST_ALLIED_HEROES)
		local FilteredAllies = PAF.FilterTrueUnits(Allies)
		
		local ClosestHero = nil
		local ClosestDist = 99999999
		
		for v, Ally in pairs(FilteredAllies) do
			if GetUnitToLocationDistance(Ally, EnemyWisdomFountainLoc) <= ClosestDist then
				ClosestHero = Ally
				ClosestDist = GetUnitToLocationDistance(Ally, EnemyWisdomFountainLoc)
			end
		end
		
		HeroToCollectWisdomFountain = ClosestHero
	end
	
	if HeroToCollectWisdomFountain == bot then
		if P.IsInLaningPhase() then
			if GetUnitToLocationDistance(bot, EnemyWisdomFountainLoc) <= 1600 then
				return true
			end
		else
			local EnemyTierOne = nil
			
			if bot:GetTeam() == TEAM_RADIANT then
				EnemyTierOne = GetTower(GetOpposingTeam(), TOWER_BOT_1)
			elseif bot:GetTeam() == TEAM_DIRE then
				EnemyTierOne = GetTower(GetOpposingTeam(), TOWER_TOP_1)
			end
			
			if EnemyTierOne == nil or EnemyTierOne:IsNull() then
				if GetUnitToLocationDistance(bot, EnemyWisdomFountainLoc) <= 3200 then
					return true
				end
			end
		end
	end
	
	return false
end

function SetTeamHealthForTormentor()
	local Allies = GetUnitList(UNIT_LIST_ALLIED_HEROES)
	local FilteredAllies = PAF.FilterTrueUnits(Allies)
	
	local NumHealthyAllies = 0
	
	for v, Ally in pairs(FilteredAllies) do
		if not P.IsMeepoClone(Ally)
		and not Ally:HasModifier("modifier_arc_warden_tempest_double") then
			if Ally:GetHealth() >= (Ally:GetMaxHealth() * 0.8) then
				NumHealthyAllies = (NumHealthyAllies + 1)
			elseif Ally:GetHealth() <= (Ally:GetHealth() * 0.2) then
				TeamHealthyForTormentor = false
				return
			end
		end
	end
	
	if NumHealthyAllies >= 5 then
		TeamHealthyForTormentor = true
		return
	end
	
	return
end

function UpdateTormentorAvailability()
	local Allies = GetUnitList(UNIT_LIST_ALLIED_HEROES)
	
	for x, Ally in pairs(Allies) do
		if IsRadiusVisible(TormentorLoc, 300)
		and GetUnitToLocationDistance(Ally, TormentorLoc) <= 500 then
			local Neutrals = GetUnitList(UNIT_LIST_NEUTRAL_CREEPS)
			local Tormentor = nil
			
			for v, Neutral in pairs(Neutrals) do
				if Neutral:GetUnitName() == "npc_dota_miniboss" then
					Tormentor = Neutral
				end
			end
			
			if Tormentor == nil then
				TormentorSpawnTime = (DotaTime() + TormentorRespawnTimer)
				TormentorAvailable = false
				print("No tormentor available")
				return
			else
				if Tormentor:IsAlive() == false then
					TormentorSpawnTime = (DotaTime() + TormentorRespawnTimer)
					TormentorAvailable = false
					print("No tormentor available")
					return
				end
			end
		end
	end
	
	return
end

function GetHighestLevelBot()
	local Allies = GetUnitList(UNIT_LIST_ALLIED_HEROES)
	
	local HighestLevelHero = nil
	local HighestLevel = 0
		
	for v, Ally in pairs(Allies) do
		if Ally:IsBot() and Ally:GetLevel() > HighestLevel then
			HighestLevelHero = Ally
			HighestLevel = Ally:GetLevel()
		end
	end
	
	return HighestLevelHero
end

function ShouldTeamDoTormentor()
	if TormentorAvailable and TeamHealthyForTormentor then
		local AlliesNearby = 0
		local AlliesInRange = 0
		
		local Allies = GetUnitList(UNIT_LIST_ALLIED_HEROES)
		local FilteredAllies = PAF.FilterTrueUnits(Allies)
		
		for v, Ally in pairs(FilteredAllies) do
			if Ally:IsBot()
			and not P.IsMeepoClone(Ally)
			and not Ally:HasModifier("modifier_arc_warden_tempest_double") then
				if GetUnitToLocationDistance(Ally, TormentorLoc) <= 12800 then
					AlliesNearby = (AlliesNearby + 1)
				end
				
				if GetUnitToLocationDistance(Ally, TormentorLoc) <= 1200 then
					AlliesInRange = (AlliesInRange + 1)
				end
			end
		end
		
		AlliesInTormentorAttackRange = AlliesInRange
		
		if AlliesNearby >= GetNumberOfBots() then
			return true
		end
	end
	
	return false
end

function GetNumberOfBots()
	local NumBots = 0
	
	for x, Player in pairs(GetTeamPlayers(bot:GetTeam())) do
		if IsPlayerBot(Player) then
			NumBots = (NumBots + 1)
		end
	end
	
	return NumBots
end