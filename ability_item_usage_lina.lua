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

local DragonSlave = bot:GetAbilityByName("lina_dragon_slave")
local LightStrikeArray = bot:GetAbilityByName("lina_light_strike_array")
local FierySoul = bot:GetAbilityByName("lina_fiery_soul")
local LagunaBlade = bot:GetAbilityByName("lina_laguna_blade")
local FlameCloak = bot:GetAbilityByName("lina_flame_cloak")

local DragonSlaveDesire = 0
local LightStrikeArrayDesire = 0
local LagunaBladeDesire = 0
local FlameCloakDesire = 0

local AttackRange
local BotTarget
local manathreshold = 0

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	manathreshold = 100
	manathreshold = manathreshold + DragonSlave:GetManaCost()
	manathreshold = manathreshold + LightStrikeArray:GetManaCost()
	manathreshold = manathreshold + LagunaBlade:GetManaCost()
	
	-- The order to use abilities in
	FlameCloakDesire = UseFlameCloak()
	if FlameCloakDesire > 0 then
		bot:Action_UseAbility(FlameCloak)
		return
	end
	
	LagunaBladeDesire, LagunaBladeTarget = UseLagunaBlade()
	if LagunaBladeDesire > 0 then
		bot:Action_UseAbilityOnEntity(LagunaBlade, LagunaBladeTarget)
		return
	end
	
	LightStrikeArrayDesire, LightStrikeArrayTarget = UseLightStrikeArray()
	if LightStrikeArrayDesire > 0 then
		bot:Action_UseAbilityOnLocation(LightStrikeArray, LightStrikeArrayTarget)
		return
	end
	
	DragonSlaveDesire, DragonSlaveTarget = UseDragonSlave()
	if DragonSlaveDesire > 0 then
		bot:Action_UseAbilityOnLocation(DragonSlave, DragonSlaveTarget)
		return
	end
end

function UseDragonSlave()
	if not DragonSlave:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = DragonSlave:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	local Radius = DragonSlave:GetSpecialValueInt("dragon_slave_width_initial")
	local Damage = DragonSlave:GetSpecialValueInt("dragon_slave_damage")
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange and not PAF.IsMagicImmune(BotTarget) then
				return BOT_ACTION_DESIRE_HIGH, BotTarget:GetLocation()
			end
		end
	end
	
	if P.IsInLaningPhase()
	and bot:GetActiveMode() == BOT_MODE_LANING then
		local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
		local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	
		for v, enemy in pairs(FilteredEnemies) do
			if PAF.CanLastHitCreepAndHarass(bot, enemy, Radius, Damage, DAMAGE_TYPE_MAGICAL) then
				return BOT_ACTION_DESIRE_HIGH, enemy:GetLocation()
			end
		end
	end
	
	local AttackTarget = bot:GetAttackTarget()

	if bot:GetActiveMode() == BOT_MODE_FARM
	or bot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP
	or bot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID
	or bot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT then
		if AttackTarget ~= nil 
		and AttackTarget:IsCreep() then
			local NearbyCreeps = bot:GetNearbyCreeps(CastRange, true)
			local AoECount = PAF.GetUnitsNearTarget(AttackTarget:GetLocation(), NearbyCreeps, Radius)
			
			if AoECount >= 3
			and (bot:GetMana() - DragonSlave:GetManaCost()) > manathreshold then
				return BOT_ACTION_DESIRE_HIGH, AttackTarget:GetLocation()
			end
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		if AttackTarget ~= nil and PAF.IsRoshan(AttackTarget) then
			return BOT_ACTION_DESIRE_HIGH, AttackTarget:GetLocation()
		end
	end
	
	return 0
end

function UseLightStrikeArray()
	if not LightStrikeArray:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = LightStrikeArray:GetCastRange()
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
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange then
				if GetUnitToLocationDistance(bot, BotTarget:GetExtrapolatedLocation(1.5)) > CastRange then
					return BOT_ACTION_DESIRE_HIGH, bot:GetXUnitsTowardsLocation(BotTarget:GetExtrapolatedLocation(1), CastRange)
				else
					return BOT_ACTION_DESIRE_HIGH, BotTarget:GetExtrapolatedLocation(1.5)
				end
			end
		end
	end
	
	if P.IsRetreating(bot) and #EnemiesWithinRange > 0 then
		local ClosestTarget = PAF.GetClosestUnit(bot, EnemiesWithinRange)
		return BOT_ACTION_DESIRE_HIGH, ClosestTarget:GetExtrapolatedLocation(1.5)
	end
	
	local AttackTarget = bot:GetAttackTarget()
	
	if bot:GetActiveMode() == BOT_MODE_FARM then
		local Neutrals = bot:GetNearbyNeutralCreeps(CastRange)
	
		if AttackTarget ~= nil 
		and AttackTarget:IsCreep() 
		and #Neutrals >= 2
		and (bot:GetMana() - LightStrikeArray:GetManaCost()) > manathreshold
		and GetUnitToUnitDistance(bot, AttackTarget) <= CastRange then
			return BOT_ACTION_DESIRE_HIGH, AttackTarget:GetExtrapolatedLocation(1.5)
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		if PAF.IsRoshan(AttackTarget)
		and GetUnitToUnitDistance(bot, AttackTarget) <= CastRange then
			return BOT_ACTION_DESIRE_VERYHIGH, AttackTarget:GetLocation()
		end
	end
	
	return 0
end

function UseLagunaBlade()
	if not LagunaBlade:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = LagunaBlade:GetCastRange()
	local Damage = LagunaBlade:GetSpecialValueInt("damage")
	
	if PAF.IsInTeamFight(bot) then
		if BotTarget ~= nil then
			return BOT_ACTION_DESIRE_HIGH, BotTarget
		end
	end
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	local target = PAF.GetWeakestUnit(FilteredEnemies)
	
	local RealDamage = 0
	
	if target ~= nil then
		RealDamage = target:GetActualIncomingDamage(Damage, DAMAGE_TYPE_MAGICAL)
	end
	
	if target ~= nil and target:GetHealth() < RealDamage then
		return BOT_ACTION_DESIRE_HIGH, target
	end
	
	return 0
end

function UseFlameCloak()
	if not FlameCloak:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	if PAF.IsEngaging(bot) and GetUnitToUnitDistance(bot, BotTarget) <= 1200 then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	if P.IsRetreating(bot) then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	return 0
end