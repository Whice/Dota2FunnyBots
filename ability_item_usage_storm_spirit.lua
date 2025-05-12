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
		if bot:HasScepter() then
			bot:Action_UseAbility(ElectricVortex)
			return
		else
			bot:Action_UseAbilityOnEntity(ElectricVortex, ElectricVortexTarget)
			return
		end
	end
	
	OverloadDesire = UseOverload()
	if OverloadDesire > 0 then
		bot:Action_UseAbility(Overload)
		return
	end
	
	StaticRemnantDesire, StaticRemnantTarget = UseStaticRemnant()
	if StaticRemnantDesire > 0 then
		bot:Action_UseAbilityOnLocation(StaticRemnant, StaticRemnantTarget)
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
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	
	local AttackTarget = bot:GetAttackTarget()
	
	if not bot:HasModifier("modifier_storm_spirit_overload")
	and AttackTarget ~= nil
	and AttackTarget:IsHero()
	and GetUnitToUnitDistance(bot, AttackTarget) <= (AttackRange + 50)
	and Overload:IsTrained() then
		return BOT_ACTION_DESIRE_ABSOLUTE, AttackTarget:GetLocation()
	end
	
	if #FilteredEnemies >= 1 then
		return BOT_ACTION_DESIRE_ABSOLUTE, FilteredEnemies[1]:GetLocation()
	end
	
	if bot:GetActiveMode() == BOT_MODE_FARM and not P.IsInLaningPhase() then
		local neutrals = bot:GetNearbyCreeps((CastRange + 200), true)
		
		if #neutrals >= 1 and (bot:GetMana() - StaticRemnant:GetManaCost()) > manathreshold then
			return BOT_ACTION_DESIRE_ABSOLUTE, neutrals[1]:GetLocation()
		end
	end
	
	local AttackTarget = bot:GetAttackTarget()
	
	if AttackTarget ~= nil then
		if bot:GetActiveMode() == BOT_MODE_ROSHAN then
			if PAF.IsRoshan(AttackTarget) then
				return BOT_ACTION_DESIRE_VERYHIGH, AttackTarget:GetLocation()
			end
		end
		
		if PAF.IsTormentor(AttackTarget) then
			return BOT_ACTION_DESIRE_HIGH, AttackTarget:GetLocation()
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
	local FilteredEnemies = PAF.FilterTrueUnits(enemies)
	
	if bot:GetHealth() <= (bot:GetMaxHealth() * 0.35)
	and P.IsRetreating(bot)
	and #FilteredEnemies > 0 then
		return BOT_ACTION_DESIRE_HIGH, PAF.GetXUnitsTowardsLocation(bot:GetLocation(), PAF.GetFountainLocation(bot), 1600)
	end
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= 1600
			and not PAF.IsMagicImmune(BotTarget) then
				if GetUnitToUnitDistance(bot, BotTarget) > AttackRange
				or not bot:HasModifier("modifier_storm_spirit_overload") then
					return BOT_ACTION_DESIRE_HIGH, BotTarget:GetExtrapolatedLocation(1)
				end
			end
		end
	end
	
	return 0
end