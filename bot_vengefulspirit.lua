local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")
local PAF = require(GetScriptDirectory() ..  "/Library/PhalanxAbilityFunctions")
local PNA = require(GetScriptDirectory() ..  "/Library/PhalanxNeutralAbilities")

local bot = GetBot()

local AttackRange
local BotTarget = nil

function MinionThink(hMinionUnit) 
	if bot:IsAlive() then
		if bot.StrongIllusion ~= nil then
			bot.StrongIllusion = nil
		end
	else
		if bot.StrongIllusion == nil and bot:HasScepter() then
			local Allies = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
			local NearestIllusion = nil
			local ClosestDist = 2000
			
			for v, Ally in pairs(Allies) do
				if Ally:IsIllusion() then
					if GetUnitToUnitDistance(bot, Ally) < ClosestDist then
						NearestIllusion = Ally
						ClosestDist = GetUnitToUnitDistance(bot, Ally)
					end
				end
			end
			
			if NearestIllusion ~= nil then
				bot.StrongIllusion = NearestIllusion
			end
		end
	end
	
	if not hMinionUnit:IsNull() and hMinionUnit ~= nil then	
		-- Strong illusion ability usage
		if bot.StrongIllusion ~= nil and hMinionUnit == bot.StrongIllusion then
			local MagicMissile = hMinionUnit:GetAbilityByName("vengefulspirit_magic_missile")
			local WaveOfTerror = hMinionUnit:GetAbilityByName("vengefulspirit_wave_of_terror")
			local NetherSwap = hMinionUnit:GetAbilityByName("vengefulspirit_nether_swap")
			
			local MagicMissileDesire = 0
			local WaveOfTerrorDesire = 0
			local NetherSwapDesire = 0
			
			AttackRange = hMinionUnit:GetAttackRange()
			
			local EnemiesWithinRange = hMinionUnit:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
			local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
			
			if #FilteredEnemies > 0 then
				BotTarget = PAF.GetWeakestUnit(FilteredEnemies)
			end
			
			if BotTarget ~= nil and BotTarget:CanBeSeen() then
				MagicMissileDesire, MagicMissileTarget = UseMagicMissile(hMinionUnit, MagicMissile)
				if MagicMissileDesire > 0 then
					hMinionUnit:Action_UseAbilityOnEntity(MagicMissile, MagicMissileTarget)
					return
				end
				
				NetherSwapDesire, NetherSwapTarget = UseNetherSwap(hMinionUnit, NetherSwap)
				if NetherSwapDesire > 0 then
					hMinionUnit:Action_UseAbilityOnEntity(NetherSwap, NetherSwapTarget)
					return
				end
				
				WaveOfTerrorDesire, WaveOfTerrorTarget = UseWaveOfTerror(hMinionUnit, WaveOfTerror)
				if WaveOfTerrorDesire > 0 then
					hMinionUnit:Action_UseAbilityOnLocation(WaveOfTerror, WaveOfTerrorTarget)
					return
				end
			end
			
			PAF.StrongIllusionTarget(hMinionUnit, bot)
			return
		end
		
		
		if hMinionUnit:IsCreep() then
			local MinionAbilities = {
				hMinionUnit:GetAbilityInSlot(0),
				hMinionUnit:GetAbilityInSlot(1),
				hMinionUnit:GetAbilityInSlot(2),
				hMinionUnit:GetAbilityInSlot(3),
				hMinionUnit:GetAbilityInSlot(4),
				hMinionUnit:GetAbilityInSlot(5),
			}
			
			for v, hAbility in pairs(MinionAbilities) do
				if hAbility ~= nil and hAbility:GetName() ~= "" and not hAbility:IsPassive() then
					if PNA.UseNeutralAbility(hAbility, bot, hMinionUnit) == true then
						return
					end
				end
			end
		end
		
		PAF.IllusionTarget(hMinionUnit, bot)
		return
		
	end
end

function UseMagicMissile(hMinionUnit, MagicMissile)
	if not MagicMissile:IsFullyCastable() then return 0 end
	if P.CantUseAbility(hMinionUnit) then return 0 end
	
	local CR = MagicMissile:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local EnemiesWithinRange = hMinionUnit:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterUnitsForStun(EnemiesWithinRange)
	
	for v, enemy in pairs(FilteredEnemies) do
		if enemy:IsChanneling() then
			return BOT_ACTION_DESIRE_HIGH, enemy
		end
	end
	
	if PAF.IsValidHeroAndNotIllusion(BotTarget) then
		if GetUnitToUnitDistance(hMinionUnit, BotTarget) <= CastRange
		and not PAF.IsMagicImmune(BotTarget)
		and not PAF.IsDisabled(BotTarget) then
			return BOT_ACTION_DESIRE_HIGH, BotTarget
		end
	end
	
	return 0
end

function UseWaveOfTerror(hMinionUnit, WaveOfTerror)
	if not WaveOfTerror:IsFullyCastable() then return 0 end
	if P.CantUseAbility(hMinionUnit) then return 0 end
	
	local CR = WaveOfTerror:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	if PAF.IsValidHeroAndNotIllusion(BotTarget) then
		if GetUnitToUnitDistance(hMinionUnit, BotTarget) <= CastRange
		and not PAF.IsMagicImmune(BotTarget) then
			return BOT_ACTION_DESIRE_HIGH, BotTarget:GetLocation()
		end
	end
	
	return 0
end

function UseNetherSwap(hMinionUnit, NetherSwap)
	if not NetherSwap:IsFullyCastable() then return 0 end
	if P.CantUseAbility(hMinionUnit) then return 0 end
	
	local CR = NetherSwap:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	if PAF.IsValidHeroAndNotIllusion(BotTarget) then
		if GetUnitToUnitDistance(hMinionUnit, BotTarget) <= CastRange then
			if PAF.IsChasing(hMinionUnit, BotTarget)
			and GetUnitToUnitDistance(hMinionUnit, BotTarget) > (AttackRange + 50)
			and GetUnitToLocationDistance(hMinionUnit, PAF.GetFountainLocation(bot)) < GetUnitToLocationDistance(BotTarget, PAF.GetFountainLocation(bot)) then
				return BOT_ACTION_DESIRE_HIGH, BotTarget
			end
		end
	end
	
	local AlliesWithinRange = hMinionUnit:GetNearbyHeroes(CastRange, false, BOT_MODE_NONE)
	local FilteredAllies = PAF.FilterTrueUnits(AlliesWithinRange)
	
	for v, Ally in pairs(FilteredAllies) do
		if Ally ~= hMinionUnit then
			if Ally:GetHealth() < (Ally:GetMaxHealth() * 0.4)
			and Ally:WasRecentlyDamagedByAnyHero(1)
			and Ally:IsFacingLocation(PAF.GetFountainLocation(Ally), 45) then
				local EnemiesWithinRange = hMinionUnit:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
				local FilteredEnemies = PAF.FilterUnitsForStun(EnemiesWithinRange)
				
				local AverageLoc = PAF.GetAverageLocationOfUnits(FilteredEnemies)
				
				if GetUnitToLocationDistance(Ally, AverageLoc) < GetUnitToLocationDistance(hMinionUnit, AverageLoc) then
					return BOT_ACTION_DESIRE_HIGH, Ally
				end
			end
		end
	end
	
	return 0
end