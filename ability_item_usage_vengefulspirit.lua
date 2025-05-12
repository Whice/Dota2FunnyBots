------------------------------
-- CREATED BY: MANSLAUGHTER --
------------------------------

local bot = GetBot()
if bot:IsInvulnerable() or not bot:IsHero() or bot:IsIllusion() then return end

local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")
local PAF = require(GetScriptDirectory() ..  "/Library/PhalanxAbilityFunctions")

local ability_item_usage_generic = dofile( GetScriptDirectory().."/ability_item_usage_generic" )

function AbilityLevelUpThink()  
	ability_item_usage_generic.AbilityLevelUpThink(); 
end
function BuybackUsageThink()
	ability_item_usage_generic.BuybackUsageThink();
end
function CourierUsageThink()
	ability_item_usage_generic.CourierUsageThink();
end
function ItemUsageThink()
	ability_item_usage_generic.ItemUsageThink();
end

local MagicMissile = bot:GetAbilityByName("vengefulspirit_magic_missile")
local WaveOfTerror = bot:GetAbilityByName("vengefulspirit_wave_of_terror")
local VengeanceAura = bot:GetAbilityByName("vengefulspirit_command_aura")
local NetherSwap = bot:GetAbilityByName("vengefulspirit_nether_swap")

local MagicMissileDesire = 0
local WaveOfTerrorDesire = 0
local NetherSwapDesire = 0

local AttackRange
local BotTarget

bot.StrongIllusion = nil

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	if bot:IsAlive() then
		if bot.StrongIllusion ~= nil then
			bot.StrongIllusion = nil
		end
	end
	
	-- The order to use abilities in
	MagicMissileDesire, MagicMissileTarget = UseMagicMissile()
	if MagicMissileDesire > 0 then
		bot:Action_UseAbilityOnEntity(MagicMissile, MagicMissileTarget)
		return
	end
	
	NetherSwapDesire, NetherSwapTarget = UseNetherSwap()
	if NetherSwapDesire > 0 then
		bot:Action_UseAbilityOnEntity(NetherSwap, NetherSwapTarget)
		return
	end
	
	WaveOfTerrorDesire, WaveOfTerrorTarget = UseWaveOfTerror()
	if WaveOfTerrorDesire > 0 then
		bot:Action_UseAbilityOnLocation(WaveOfTerror, WaveOfTerrorTarget)
		return
	end
end

function UseMagicMissile()
	if not MagicMissile:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = MagicMissile:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterUnitsForStun(EnemiesWithinRange)
	
	for v, enemy in pairs(FilteredEnemies) do
		if enemy:IsChanneling() then
			return BOT_ACTION_DESIRE_HIGH, enemy
		end
	end
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget)
			and not PAF.IsDisabled(BotTarget) then
				return BOT_ACTION_DESIRE_HIGH, BotTarget
			end
		end
	end
	
	if P.IsRetreating(bot) and #EnemiesWithinRange > 0 then
		local ClosestTarget = PAF.GetClosestUnit(bot, EnemiesWithinRange)
		return BOT_ACTION_DESIRE_HIGH, ClosestTarget
	end
	
	local AttackTarget = bot:GetAttackTarget()
	
	if AttackTarget ~= nil then
		if bot:GetActiveMode() == BOT_MODE_ROSHAN then
			if PAF.IsRoshan(AttackTarget)
			and GetUnitToUnitDistance(bot, AttackTarget) <= CastRange then
				return BOT_ACTION_DESIRE_VERYHIGH, AttackTarget
			end
		end
		
		if PAF.IsTormentor(AttackTarget) then
			return BOT_ACTION_DESIRE_HIGH, AttackTarget
		end
	end
	
	return 0
end

function UseWaveOfTerror()
	if not WaveOfTerror:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = WaveOfTerror:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget) then
				return BOT_ACTION_DESIRE_HIGH, BotTarget:GetLocation()
			end
		end
	end
	
	local AttackTarget = bot:GetAttackTarget()
	
	if AttackTarget ~= nil then
		if bot:GetActiveMode() == BOT_MODE_ROSHAN then
			if PAF.IsRoshan(AttackTarget)
			and GetUnitToUnitDistance(bot, AttackTarget) <= CastRange then
				return BOT_ACTION_DESIRE_VERYHIGH, AttackTarget:GetLocation()
			end
		end
		
		if PAF.IsTormentor(AttackTarget) then
			return BOT_ACTION_DESIRE_HIGH, AttackTarget:GetLocation()
		end
	end
	
	return 0
end

function UseNetherSwap()
	if not NetherSwap:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = NetherSwap:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange then
				if PAF.IsChasing(bot, BotTarget)
				and GetUnitToUnitDistance(bot, BotTarget) > (AttackRange + 50)
				and GetUnitToLocationDistance(bot, PAF.GetFountainLocation(bot)) < GetUnitToLocationDistance(BotTarget, PAF.GetFountainLocation(bot)) then
					return BOT_ACTION_DESIRE_HIGH, BotTarget
				end
			end
		end
	end
	
	local AlliesWithinRange = bot:GetNearbyHeroes(CastRange, false, BOT_MODE_NONE)
	local FilteredAllies = PAF.FilterTrueUnits(AlliesWithinRange)
	
	for v, Ally in pairs(FilteredAllies) do
		if Ally ~= bot then
			if Ally:GetHealth() < (Ally:GetMaxHealth() * 0.4)
			and Ally:WasRecentlyDamagedByAnyHero(1)
			and Ally:IsFacingLocation(PAF.GetFountainLocation(Ally), 45) then
				local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
				local FilteredEnemies = PAF.FilterUnitsForStun(EnemiesWithinRange)
				
				local AverageLoc = PAF.GetAverageLocationOfUnits(FilteredEnemies)
				
				if GetUnitToLocationDistance(Ally, AverageLoc) < GetUnitToLocationDistance(bot, AverageLoc) then
					return BOT_ACTION_DESIRE_HIGH, Ally
				end
			end
		end
	end
	
	return 0
end