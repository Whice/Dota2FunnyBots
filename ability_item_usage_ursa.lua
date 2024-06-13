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

local Earthshock = bot:GetAbilityByName("ursa_earthshock")
local Overpower = bot:GetAbilityByName("ursa_overpower")
local FurySwipes = bot:GetAbilityByName("ursa_fury_swipes")
local Enrage = bot:GetAbilityByName("ursa_enrage")

local EarthshockDesire = 0
local OverpowerDesire = 0
local EnrageDesire = 0

local AttackRange
local BotTarget

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	-- The order to use abilities in
	EnrageDesire = UseEnrage()
	if EnrageDesire > 0 then
		bot:Action_UseAbility(Enrage)
		return
	end
	
	OverpowerDesire = UseOverpower()
	if OverpowerDesire > 0 then
		bot:Action_UseAbility(Overpower)
		return
	end
	
	EarthshockDesire = UseEarthshock()
	if EarthshockDesire > 0 then
		bot:Action_UseAbility(Earthshock)
		return
	end
end

function UseEarthshock()
	if not Earthshock:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = Earthshock:GetSpecialValueInt("hop_distance")
	local CastRange = PAF.GetProperCastRange(CR)
	local Radius = Earthshock:GetSpecialValueInt("shock_radius")
	
	if PAF.IsEngaging(bot) or P.IsRetreating(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if bot:IsFacingLocation(BotTarget:GetLocation(), 10)
			and GetUnitToUnitDistance(bot, BotTarget) < (CastRange + Radius)
			and not PAF.IsMagicImmune(BotTarget) then
				return BOT_ACTION_DESIRE_VERYHIGH
			end
		end
	end
	
	if P.IsRetreating(bot) then
		local EnemiesWithinRange = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
		local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
		
		if #FilteredEnemies > 0 then
			if bot:IsFacingLocation(PAF.GetFountainLocation(bot), 20) then
				return BOT_ACTION_DESIRE_VERYHIGH
			end
		end
	end
	
	local AttackTarget = bot:GetAttackTarget()
	
	if not P.IsInLaningPhase() and AttackTarget ~= nil then
		if PAF.IsRoshan(AttackTarget) then
			if bot:IsFacingLocation(AttackTarget:GetLocation(), 10)
			and GetUnitToUnitDistance(bot, AttackTarget) < (CastRange + Radius)
			and not PAF.IsMagicImmune(AttackTarget) then
				return BOT_ACTION_DESIRE_VERYHIGH
			end
		end
	end
	
	return 0
end

function UseOverpower()
	if not Overpower:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	if bot:HasModifier("modifier_ursa_overpower") then return 0 end
	
	if PAF.IsEngaging(bot) then
		return BOT_ACTION_DESIRE_VERYHIGH
	end
	
	local AttackTarget = bot:GetAttackTarget()
	
	if not P.IsInLaningPhase() and AttackTarget ~= nil then
		local creeps = bot:GetNearbyCreeps((AttackRange + 300), true)
		
		if AttackTarget:IsCreep() and #creeps >= 2 then
			return BOT_ACTION_DESIRE_VERYHIGH
		end
	
		if PAF.IsRoshan(AttackTarget) then
			return BOT_ACTION_DESIRE_VERYHIGH
		end
	end
	
	return 0
end

function UseEnrage()
	if not Enrage:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	if PAF.IsInTeamFight(bot) or (bot:GetActiveMode() == BOT_MODE_RETREAT and bot:GetActiveModeDesire() >= 0.8) then
		return BOT_ACTION_DESIRE_VERYHIGH
	end
	
	if not P.IsInLaningPhase() and AttackTarget ~= nil then
		local AttackTarget = bot:GetAttackTarget()
		
		if PAF.IsRoshan(AttackTarget) then
			return BOT_ACTION_DESIRE_VERYHIGH
		end
	end
	
	return 0
end