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

local Malefice = bot:GetAbilityByName("enigma_malefice")
local DemonicConversion = bot:GetAbilityByName("enigma_demonic_conversion")
local MidnightPulse = bot:GetAbilityByName("enigma_midnight_pulse")
local BlackHole = bot:GetAbilityByName("enigma_black_hole")

local MaleficeDesire = 0
local DemonicConversionDesire = 0
local MidnightPulseDesire = 0
local BlackHoleDesire = 0

local AttackRange
local BotTarget

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	-- The order to use abilities in
	MaleficeDesire, MaleficeTarget = UseMalefice()
	if MaleficeDesire > 0 then
		bot:Action_UseAbilityOnEntity(Malefice, MaleficeTarget)
		return
	end
	
	MidnightPulseDesire, MidnightPulseTarget = UseMidnightPulse()
	if MidnightPulseDesire > 0 then
		bot:Action_UseAbilityOnLocation(MidnightPulse, MidnightPulseTarget)
		return
	end
	
	BlackHoleDesire, BlackHoleTarget = UseBlackHole()
	if BlackHoleDesire > 0 then
		bot:Action_UseAbilityOnLocation(BlackHole, BlackHoleTarget)
		return
	end
	
	DemonicConversionDesire, DemonicConversionTarget = UseDemonicConversion()
	if DemonicConversionDesire > 0 then
		bot:Action_UseAbilityOnLocation(DemonicConversion, DemonicConversionTarget)
		return
	end
end

function UseMalefice()
	if not Malefice:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = Malefice:GetCastRange()
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
			and not PAF.IsMagicImmune(BotTarget) then
				return BOT_ACTION_DESIRE_HIGH, BotTarget
			end
		end
	end
	
	if P.IsRetreating(bot) and #EnemiesWithinRange > 0 then
		local ClosestTarget = PAF.GetClosestUnit(bot, EnemiesWithinRange)
		return BOT_ACTION_DESIRE_HIGH, ClosestTarget
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		local AttackTarget = bot:GetAttackTarget()
		
		if PAF.IsRoshan(AttackTarget)
		and GetUnitToUnitDistance(bot, AttackTarget) <= CastRange then
			return BOT_ACTION_DESIRE_VERYHIGH, AttackTarget
		end
	end
	
	return 0
end

function UseDemonicConversion()
	if not DemonicConversion:IsFullyCastable() then return 0 end
	if P.IsRetreating(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	if PAF.IsEngaging(bot) then
		return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()
	end
	
	return 0
end

function UseMidnightPulse()
	if not MidnightPulse:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = MidnightPulse:GetCastRange()
	local Radius = MidnightPulse:GetSpecialValueInt("radius")
	
	if PAF.IsEngaging(bot) then
		local AoE = bot:FindAoELocation(true, true, bot:GetLocation(), CastRange, Radius/2, 0, 0)
		if (AoE.count >= 2) then
			return BOT_ACTION_DESIRE_HIGH, AoE.targetloc;
		end
	end
	
	return 0
end

function UseBlackHole()
	if not BlackHole:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local Radius = BlackHole:GetSpecialValueInt("radius")
	
	if PAF.IsEngaging(bot) then
		local AoE = bot:FindAoELocation(true, true, bot:GetLocation(), AttackRange, Radius/2, 0, 0)
		if (AoE.count >= 2) then
			return BOT_ACTION_DESIRE_HIGH, AoE.targetloc;
		end
	end
	
	return 0
end