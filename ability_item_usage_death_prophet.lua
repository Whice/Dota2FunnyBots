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

local Swarm = bot:GetAbilityByName("death_prophet_carrion_swarm")
local Silence = bot:GetAbilityByName("death_prophet_silence")
local SpiritSiphon = bot:GetAbilityByName("death_prophet_spirit_siphon")
local Exorcism = bot:GetAbilityByName("death_prophet_exorcism")

local SwarmDesire = 0
local SilenceDesire = 0
local SpiritSiphonDesire = 0
local ExorcismDesire = 0

local AttackRange
local BotTarget
local manathreshold = 0

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	manathreshold = 100
	manathreshold = manathreshold + Swarm:GetManaCost()
	manathreshold = manathreshold + Silence:GetManaCost()
	manathreshold = manathreshold + SpiritSiphon:GetManaCost()
	manathreshold = manathreshold + Exorcism:GetManaCost()
	
	-- The order to use abilities in
	ExorcismDesire = UseExorcism()
	if ExorcismDesire > 0 then
		bot:Action_UseAbility(Exorcism)
		return
	end
	
	SilenceDesire, SilenceTarget = UseSilence()
	if SilenceDesire > 0 then
		bot:Action_UseAbilityOnLocation(Silence, SilenceTarget)
		return
	end
	
	SpiritSiphonDesire, SpiritSiphonTarget = UseSpiritSiphon()
	if SpiritSiphonDesire > 0 then
		bot:Action_UseAbilityOnEntity(SpiritSiphon, SpiritSiphonTarget)
		return
	end
	
	SwarmDesire, SwarmTarget = UseSwarm()
	if SwarmDesire > 0 then
		bot:Action_UseAbilityOnLocation(Swarm, SwarmTarget)
		return
	end
end

function UseSwarm()
	if not Swarm:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = Swarm:GetSpecialValueInt("range")
	local CastRange = PAF.GetProperCastRange(CR)
	local Radius = Swarm:GetSpecialValueInt("end_radius")
	local Damage = Swarm:GetAbilityDamage()
	local CastDistance = Swarm:GetCastRange()
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget) then
				return BOT_ACTION_DESIRE_HIGH, bot:GetXUnitsTowardsLocation(BotTarget:GetLocation(), CastDistance)
			end
		end
	end
	
	if P.IsInLaningPhase()
	and bot:GetActiveMode() == BOT_MODE_LANING then
		local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
		local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	
		for v, enemy in pairs(FilteredEnemies) do
			if PAF.CanLastHitCreepAndHarass(bot, enemy, Radius, Damage, DAMAGE_TYPE_MAGICAL) then
				return BOT_ACTION_DESIRE_HIGH, bot:GetXUnitsTowardsLocation(enemy:GetLocation(), CastDistance)
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
			and (bot:GetMana() - Swarm:GetManaCost()) > manathreshold then
				return BOT_ACTION_DESIRE_HIGH, bot:GetXUnitsTowardsLocation(AttackTarget:GetLocation(), CastDistance)
			end
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		if AttackTarget ~= nil and PAF.IsRoshan(AttackTarget) then
			return BOT_ACTION_DESIRE_HIGH, bot:GetXUnitsTowardsLocation(AttackTarget:GetLocation(), CastDistance)
		end
	end
	
	return 0
end

function UseSilence()
	if not Silence:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = Silence:GetCastRange()
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
			and not BotTarget:IsSilenced()
			and not BotTarget:IsMuted() then
				return BOT_ACTION_DESIRE_HIGH, BotTarget:GetLocation()
			end
		end
	end
	
	return 0
end

function UseSpiritSiphon()
	if not SpiritSiphon:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = SpiritSiphon:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	
	if PAF.IsEngaging(bot) then
		for v, enemy in pairs(FilteredEnemies) do
			if not enemy:HasModifier("modifier_death_prophet_spirit_siphon")
			and not enemy:HasModifier("modifier_death_prophet_spirit_siphon_debuff")
			and not	enemy:HasModifier("modifier_death_prophet_spirit_siphon_fear")
			and not enemy:HasModifier("modifier_death_prophet_spirit_siphon_slow")
			and not PAF.IsMagicImmune(enemy) then
				return BOT_ACTION_DESIRE_HIGH, enemy
			end
		end
	end
	
	return 0
end

function UseExorcism()
	if not Exorcism:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(700, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	
	if PAF.IsInTeamFight(bot) and #FilteredEnemies >= 2 then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	local attacktarget = bot:GetAttackTarget()
	
	if attacktarget ~= nil then
		if attacktarget:IsBuilding() then
			return BOT_ACTION_DESIRE_HIGH
		end
		
		if bot:GetActiveMode() == BOT_MODE_ROSHAN then
			if PAF.IsRoshan(attacktarget) then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end
	
	return 0
end