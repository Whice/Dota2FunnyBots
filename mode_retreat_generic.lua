local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")
local PAF = require(GetScriptDirectory() ..  "/Library/PhalanxAbilityFunctions")

local bot = GetBot()
local UrgentRetreat = false

function GetDesire()
	if bot:HasModifier("modifier_skeleton_king_reincarnation_scepter_active") then
		return 0
	end
	
	local RetreatDesire = 0
	
	local BotHealth = bot:GetHealth()
	local BotMaxHealth = bot:GetMaxHealth()
	
	if bot:GetUnitName() == "npc_dota_hero_medusa" then
		BotHealth = (BotHealth + bot:GetMana())
		BotMaxHealth = (BotMaxHealth + bot:GetMaxMana())
	end
	
	local HealthMissing = (BotMaxHealth - BotHealth)
	
	local HealthRetreatVal = RemapValClamped(HealthMissing, 0, BotMaxHealth, 0.0, 1.0)
	local RecentlyDamagedVal = 0.1 -- The amount to add if the bot is being attacked by a hero(s)
	local OutnumberedVal = 0.25 -- Multiplier for every hero that outnumbers the bot's team
	local OffensivePowerVal = 0.2 -- The amount to add if the enemy has enough raw power to kill the bot
	local SafeVal = 0.25 -- How much to subtract from the desire to retreat if there are no visible enemy heroes
	
	if (BotHealth <= (BotMaxHealth * 0.3)
	or (bot:GetUnitName() ~= "npc_dota_hero_huskar" and bot:GetMana() <= (bot:GetMaxMana() * 0.2)))
	and bot:DistanceFromFountain() < 3500 then
		UrgentRetreat = true
	elseif UrgentRetreat and BotHealth > (BotMaxHealth * 0.95) then
		UrgentRetreat = false
	end
	
	if UrgentRetreat then
		return 0.9
	end
	
	
	
	RetreatDesire = HealthRetreatVal
	
	if bot:WasRecentlyDamagedByAnyHero(1) or bot:WasRecentlyDamagedByTower(1) then
		RetreatDesire = (RetreatDesire + RecentlyDamagedVal)
	end
	
	local Allies = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
	local Enemies = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	local EnemyTowers = bot:GetNearbyTowers(1600, true)
	
	local TrueAllies = {}
	local TrueEnemies = {}
	
	local NearbyEnemies = 0
	

	if #Allies > 0 then
		for v, Ally in pairs(Allies) do
			if not PAF.IsPossibleIllusion(Ally)
			and not P.IsMeepoClone(Ally)
			and not Ally:HasModifier("modifier_arc_warden_tempest_double") then
				table.insert(TrueAllies, Ally)
			end
		end
	end
		
	if #Enemies > 0 then
		for v, Enemy in pairs(Enemies) do
			if not PAF.IsPossibleIllusion(Enemy)
			and not P.IsMeepoClone(Enemy)
			and not Enemy:HasModifier("modifier_arc_warden_tempest_double") then
				table.insert(TrueEnemies, Enemy)
			end
		end
	end
		
	local EnemyIDs = GetTeamPlayers(GetOpposingTeam())
	for v, EID in pairs(EnemyIDs) do
		local LSI = GetHeroLastSeenInfo(EID)
		if LSI ~= nil then
			local nLSI = LSI[1]
			--print(nLSI.location)
				
			if nLSI ~= nil then
				if GetUnitToLocationDistance(bot, nLSI.location) <= 1600 then
					NearbyEnemies = (NearbyEnemies + 1)
				end
			end
		end
	end
		
	local EnemyUnits = GetUnitList(UNIT_LIST_ENEMIES)
		
	for v, Unit in pairs(EnemyUnits) do
		if string.find(Unit:GetUnitName(), "tombstone")
		or string.find(Unit:GetUnitName(), "warlock_golem") then
			if GetUnitToUnitDistance(bot, Unit) <= 1200 then
				NearbyEnemies = (NearbyEnemies + 1)
			end
		end
	end
		
	if (NearbyEnemies - #TrueAllies) > 0 then
		local Difference = (NearbyEnemies - #TrueAllies)
		local OVal = (OutnumberedVal * Difference)
			
		RetreatDesire = (RetreatDesire + OVal)
	end
	
	
	
	local CombinedEnemiesOffensivePower = PAF.CombineOffensivePower(TrueEnemies, true)
	local CombinedAlliesOffensivePower = PAF.CombineOffensivePower(TrueAllies, true)
	
	if CombinedEnemiesOffensivePower > CombinedAlliesOffensivePower then
		RetreatDesire = (RetreatDesire + OffensivePowerVal)
	end
	
	--[[if #EnemyTowers > 0 then
		if bot:GetLevel() < 12 then
			RetreatDesire = (RetreatDesire + (UnderTowerVal * 2))
		else
			RetreatDesire = (RetreatDesire + UnderTowerVal)
		end
	end]]--
	
	if NearbyEnemies == 0
	and #EnemyTowers == 0 then
		RetreatDesire = (RetreatDesire - SafeVal)
	end
	
	local ClampedRetreatDesire = Clamp(RetreatDesire, 0.0, 1.0)
	return ClampedRetreatDesire
end