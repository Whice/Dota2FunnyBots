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

local InnerFire = bot:GetAbilityByName("huskar_inner_fire")
local BurningSpear = bot:GetAbilityByName("huskar_burning_spear")
local BerserkersBlood = bot:GetAbilityByName("huskar_berserkers_blood")
local LifeBreak = bot:GetAbilityByName("huskar_life_break")

local Desire = 0
local BurningSpearDesire = 0
local LifeBreakDesire = 0

local AttackRange
local BotTarget
local manathreshold = 0

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	-- The order to use abilities in
	LifeBreakDesire, LifeBreakTarget = UseLifeBreak()
	if LifeBreakDesire > 0 then
		bot:Action_UseAbilityOnEntity(LifeBreak, LifeBreakTarget)
		return
	end
	
	InnerFireDesire = UseInnerFire()
	if InnerFireDesire > 0 then
		bot:Action_UseAbility(InnerFire)
		return
	end
	
	BurningSpearDesire, BurningSpearTarget = UseBurningSpear()
	if BurningSpearDesire > 0 then
		bot:Action_UseAbilityOnEntity(BurningSpear, BurningSpearTarget)
		return
	end
end

function UseInnerFire()
	if not InnerFire:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = InnerFire:GetSpecialValueInt("radius")
	local CastRange = PAF.GetProperCastRange(CR)
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end
	
	if P.IsRetreating(bot) then
		if #EnemiesWithinRange > 0 then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_FARM then
		local neutrals = bot:GetNearbyNeutralCreeps(CastRange)
		
		if #neutrals >= 2 then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		local AttackTarget = bot:GetAttackTarget()
		
		if PAF.IsRoshan(AttackTarget)
		and GetUnitToUnitDistance(bot, AttackTarget) <= CastRange then
			return BOT_ACTION_DESIRE_VERYHIGH
		end
	end
	
	return 0
end

function UseBurningSpear()
	if not BurningSpear:IsFullyCastable() then return 0 end
	if P.IsRetreating(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	if P.IsInLaningPhase() then
		local enemies = bot:GetNearbyHeroes(AttackRange + 50, true, BOT_MODE_NONE)
		local target = P.GetWeakestEnemyHero(enemies)
		
		if target ~= nil then
			return BOT_ACTION_DESIRE_HIGH, target
		end
	end
	
	local AttackTarget = bot:GetAttackTarget()
	
	if (AttackTarget ~= nil and AttackTarget:IsHero()) or bot:GetActiveMode() == BOT_MODE_FARM then
		if BurningSpear:GetAutoCastState() == false then
			BurningSpear:ToggleAutoCast()
		end
	else
		if BurningSpear:GetAutoCastState() == true then
			BurningSpear:ToggleAutoCast()
		end
	end
	
	return 0
end

function UseLifeBreak()
	if not LifeBreak:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = LifeBreak:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange then
				return BOT_ACTION_DESIRE_HIGH, BotTarget
			end
		end
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