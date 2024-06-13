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

local Fissure = bot:GetAbilityByName("earthshaker_fissure")
local EnchantTotem = bot:GetAbilityByName("earthshaker_enchant_totem")
local Aftershock = bot:GetAbilityByName("earthshaker_aftershock")
local EchoSlam = bot:GetAbilityByName("earthshaker_echo_slam")

local FissureDesire = 0
local EnchantTotemDesire = 0
local EchoSlamDesire = 0

local AttackRange
local BotTarget

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	-- The order to use abilities in
	EchoSlamDesire = UseEchoSlam()
	if EchoSlamDesire > 0 then
		bot:Action_UseAbility(EchoSlam)
		return
	end
	
	EnchantTotemDesire = UseEnchantTotem()
	if EnchantTotemDesire > 0 then
		bot:Action_UseAbility(EnchantTotem)
		return
	end
	
	FissureDesire, FissureTarget = UseFissure()
	if FissureDesire > 0 then
		bot:Action_UseAbilityOnLocation(Fissure, FissureTarget)
		return
	end
end

function UseFissure()
	if not Fissure:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = Fissure:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterUnitsForStun(EnemiesWithinRange)
	
	for v, enemy in pairs(FilteredEnemies) do
		if enemy:IsChanneling() then
			return BOT_ACTION_DESIRE_HIGH, enemy:GetLocation()
		end
	end
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget)
			and not PAF.IsDisabled(BotTarget) then
				if GetUnitToLocationDistance(bot, BotTarget:GetExtrapolatedLocation(1)) > CastRange then
					return BOT_ACTION_DESIRE_HIGH, bot:GetXUnitsTowardsLocation(BotTarget:GetExtrapolatedLocation(1), CastRange)
				else
					return BOT_ACTION_DESIRE_HIGH, BotTarget:GetExtrapolatedLocation(1)
				end
			end
		end
	end
	
	if P.IsRetreating(bot) and #EnemiesWithinRange > 0 then
		local ClosestTarget = PAF.GetClosestUnit(bot, EnemiesWithinRange)
		return BOT_ACTION_DESIRE_HIGH, ClosestTarget:GetLocation()
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		local AttackTarget = bot:GetAttackTarget()
		
		if PAF.IsRoshan(AttackTarget)
		and GetUnitToUnitDistance(bot, AttackTarget) <= CastRange then
			return BOT_ACTION_DESIRE_VERYHIGH, AttackTarget:GetLocation()
		end
	end
	
	return 0
end

function UseEnchantTotem()
	if not EnchantTotem:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = Aftershock:GetSpecialValueInt("aftershock_range")
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterUnitsForStun(EnemiesWithinRange)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= (CastRange - 50)
			and not PAF.IsDisabled(BotTarget) then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end
	
	if #FilteredEnemies >= 1 and P.IsRetreating(bot) then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	local AttackTarget = bot:GetAttackTarget()
	
	if AttackTarget ~= nil and not P.IsInLaningPhase() then
		if AttackTarget:IsCreep() then
			local CreepsWithinRange = bot:GetNearbyCreeps(CastRange, true)
			
			if #CreepsWithinRange >= 3 then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
		
		if bot:GetActiveMode() == BOT_MODE_ROSHAN and PAF.IsRoshan(AttackTarget) then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	return 0
end

function UseEchoSlam()
	if not EchoSlam:IsFullyCastable() then return 0 end
	if not PAF.IsInTeamFight(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = (EchoSlam:GetSpecialValueInt("echo_slam_echo_range") - 50)
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterUnitsForStun(EnemiesWithinRange)
	
	if #FilteredEnemies >= 3 then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	return 0
end