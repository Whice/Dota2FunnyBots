------------------------------
-- CREATED BY: MANSLAUGHTER --
------------------------------

local bot = GetBot()
if bot:IsInvulnerable() or not bot:IsHero() or bot:IsIllusion() then return end

local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")

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

local Onslaught = bot:GetAbilityByName("primal_beast_onslaught")
local Trample = bot:GetAbilityByName("primal_beast_trample")
local Uproar = bot:GetAbilityByName("primal_beast_uproar")
local Pulverize = bot:GetAbilityByName("primal_beast_pulverize")

local OnslaughtDesire = 0
local TrampleDesire = 0
local UproarDesire = 0
local PulverizeDesire = 0

local AttackRange = 0

function AbilityUsageThink()
	SetTarget()
	
	AttackRange = bot:GetAttackRange()
	
	-- The order to use abilities in
	PulverizeDesire, PulverizeTarget = UsePulverize()
	if PulverizeDesire > 0 then
		bot:Action_UseAbilityOnEntity(Pulverize, PulverizeTarget)
		return
	end
	
	OnslaughtDesire, OnslaughtTarget = UseOnslaught()
	if OnslaughtDesire > 0 then
		bot:Action_UseAbilityOnLocation(Onslaught, OnslaughtTarget)
		return
	end
	
	UproarDesire = UseUproar()
	if UproarDesire > 0 then
		bot:Action_UseAbility(Uproar)
		return
	end
	
	TrampleDesire = UseTrample()
	if TrampleDesire > 0 then
		bot:Action_UseAbility(Trample)
		return
	end
end

function UseOnslaught()
	-- Check if ability can be casted or if the bot is disarmed
	if not Onslaught:IsFullyCastable() then return 0 end
	if not P.IsInCombativeMode(bot) then return 0 end
	if not P.IsInPhalanxTeamFight(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = Onslaught:GetCastRange()
	
	local enemies = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local target = P.GetWeakestEnemyHero(enemies)
	
	if target ~= nil and not P.IsRetreating(bot) then
		return BOT_ACTION_DESIRE_HIGH, target:GetLocation()
	end
	
	return 0
end

function UseTrample()
	-- Check if ability can be casted or if the bot is disarmed
	if not Trample:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	if P.IsRetreating(bot) then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	return 0
end

function UseUproar()
	-- Check if ability can be casted or if the bot is disarmed
	if not Uproar:IsFullyCastable() then return 0 end
	if not P.IsInCombativeMode(bot) then return 0 end
	if not P.IsInPhalanxTeamFight(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	if P.IsRetreating(bot) or (bot:GetHealth() <= (bot:GetMaxHealth() * 0.75)) then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	return 0
end

function UsePulverize()
	-- Check if ability can be casted or if the bot is disarmed
	if not Pulverize:IsFullyCastable() then return 0 end
	if not P.IsInCombativeMode(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = Pulverize:GetCastRange()
	
	local enemies = bot:GetNearbyHeroes(CastRange + 100, true, BOT_MODE_NONE)
	local target = P.GetWeakestEnemyHero(enemies)
	
	if target ~= nil and not P.IsRetreating(bot) then
		return BOT_ACTION_DESIRE_HIGH, target
	end
	
	return 0
end

function SetTarget()
	local attacktarget = bot:GetAttackTarget()
	
	if not P.IsValidTarget(attacktarget) then return end
	
	local enemies = bot:GetNearbyHeroes(AttackRange + 50, true, BOT_MODE_NONE)
	local target = P.GetWeakestEnemyHero(enemies)
	
	if target ~= nil and not target:IsAttackImmune() then
		bot:SetTarget(target)
		return
	end
end