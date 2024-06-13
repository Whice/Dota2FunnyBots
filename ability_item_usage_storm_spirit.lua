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

local StaticRemnant = bot:GetAbilityByName("storm_spirit_static_remnant")
local ElectricVortex = bot:GetAbilityByName("storm_spirit_electric_vortex")
local Overload = bot:GetAbilityByName("storm_spirit_overload")
local BallLightning = bot:GetAbilityByName("storm_spirit_ball_lightning")

local StaticRemnantDesire = 0
local ElectricVortexDesire = 0
local OverloadDesire = 0
local BallLightningDesire = 0

local AttackRange
local BotTarget
local manathreshold = 0

local RadiantBase = Vector(-7171.12, -7261.72, 1469.28)
local DireBase = Vector(6977.84, 5797.69, 1357.99)
local team = bot:GetTeam()

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	manathreshold = 200
	
	-- The order to use abilities in
	ElectricVortexDesire, ElectricVortexTarget = UseElectricVortex()
	if ElectricVortexDesire > 0 then
		bot:Action_UseAbilityOnEntity(ElectricVortex, ElectricVortexTarget)
		return
	end
	
	OverloadDesire = UseOverload()
	if OverloadDesire > 0 then
		bot:Action_UseAbility(Overload)
		return
	end
	
	StaticRemnantDesire = UseStaticRemnant()
	if StaticRemnantDesire > 0 then
		bot:Action_UseAbility(StaticRemnant)
		return
	end
	
	BallLightningDesire, BallLightningTarget = UseBallLightning()
	if BallLightningDesire > 0 then
		bot:Action_UseAbilityOnLocation(BallLightning, BallLightningTarget)
		return
	end
end

function UseStaticRemnant()
	if not StaticRemnant:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = StaticRemnant:GetSpecialValueInt("static_remnant_radius")
	
	local AttackTarget = bot:GetAttackTarget()
	
	if not bot:HasModifier("modifier_storm_spirit_overload") and AttackTarget ~= nil and AttackTarget:IsHero() and GetUnitToUnitDistance(bot, AttackTarget) <= (AttackRange + 50) then
		return BOT_ACTION_DESIRE_ABSOLUTE
	end
	
	local enemies = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local trueenemies = PAF.FilterTrueUnits(enemies)
	local nonimmuneenemies = {}
	
	for v, enemy in pairs(trueenemies) do
		if P.IsNotImmune(enemy) then
			table.insert(nonimmuneenemies, enemy)
		end
	end
	
	if #nonimmuneenemies >= 1 then
		return BOT_ACTION_DESIRE_ABSOLUTE
	end
	
	if bot:GetActiveMode() == BOT_MODE_FARM then
		local neutrals = bot:GetNearbyNeutralCreeps(CastRange + 200)
		
		if #neutrals >= 1 and (bot:GetMana() - StaticRemnant:GetManaCost()) > manathreshold then
			return BOT_ACTION_DESIRE_ABSOLUTE
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		if PAF.IsRoshan(AttackTarget) then
			return BOT_ACTION_DESIRE_ABSOLUTE
		end
	end
	
	return 0
end

function UseElectricVortex()
	if not ElectricVortex:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = ElectricVortex:GetCastRange()
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
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange then
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

function UseOverload()
	if not Overload:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	if Overload:IsPassive() then return 0 end
	
	local CastRange = Overload:GetSpecialValueInt("shard_activation_radius")
	local allies = bot:GetNearbyHeroes(CastRange, false, BOT_MODE_NONE)
	local filteredallies = PAF.FilterTrueUnits(allies)
	
	local AttackTarget = bot:GetAttackTarget()
	
	if not bot:HasModifier("modifier_storm_spirit_overload") and PAF.IsEngaging(bot) and #filteredallies >= 2 then
		return BOT_ACTION_DESIRE_ABSOLUTE
	end
	
	return 0
end

function UseBallLightning()
	if not BallLightning:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local enemies = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	local AttackTarget = P.GetWeakestEnemyHero(enemies)
	
	if bot:GetHealth() <= (bot:GetMaxHealth() * 0.35) and P.IsRetreating(bot) then
		if team == TEAM_RADIANT and GetUnitToLocationDistance(bot, RadiantBase) > 800 then
			return BOT_ACTION_DESIRE_HIGH, RadiantBase
		elseif team == TEAM_DIRE and GetUnitToLocationDistance(bot, DireBase) > 800 then
			return BOT_ACTION_DESIRE_HIGH, DireBase
		end
	end
	
	if AttackTarget ~= nil and not AttackTarget:IsAttackImmune() and not P.IsRetreating(bot) and bot:GetActiveMode() == BOT_MODE_ATTACK then
		if GetUnitToUnitDistance(bot, AttackTarget) <= 1400 and GetUnitToUnitDistance(bot, AttackTarget) >= 400 then
			return BOT_ACTION_DESIRE_HIGH, AttackTarget:GetExtrapolatedLocation(1)
		end
		if not bot:HasModifier("modifier_storm_spirit_overload") then
			return BOT_ACTION_DESIRE_HIGH, AttackTarget:GetExtrapolatedLocation(1)
		end
	end
	
	return 0
end