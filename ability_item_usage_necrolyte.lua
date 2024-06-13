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

local DeathPulse = bot:GetAbilityByName("necrolyte_death_pulse")
local GhostShroud = bot:GetAbilityByName("necrolyte_ghost_shroud")
local HeartstopperAura = bot:GetAbilityByName("necrolyte_heartstopper_aura")
local ReapersScythe = bot:GetAbilityByName("necrolyte_reapers_scythe")
local DeathSeeker = bot:GetAbilityByName("necrolyte_death_seeker")

local DeathPulseDesire = 0
local GhostShroudDesire = 0
local ReapersScytheDesire = 0
local DeathSeekerDesire = 0

local AttackRange
local BotTarget
local manathreshold = 0

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	manathreshold = (bot:GetMaxMana() * 0.4)
	
	-- The order to use abilities in
	ReapersScytheDesire, ReapersScytheTarget = UseReapersScythe()
	if ReapersScytheDesire > 0 then
		bot:Action_UseAbilityOnEntity(ReapersScythe, ReapersScytheTarget)
		return
	end
	
	GhostShroudDesire, GhostShroudTarget = UseGhostShroud()
	if GhostShroudDesire > 0 then
		bot:Action_UseAbility(GhostShroud)
		return
	end
	
	DeathSeekerDesire, DeathSeekerTarget = UseDeathSeeker()
	if DeathSeekerDesire > 0 then
		bot:Action_UseAbilityOnEntity(DeathSeeker, DeathSeekerTarget)
		return
	end
	
	DeathPulseDesire, DeathPulseTarget = UseDeathPulse()
	if DeathPulseDesire > 0 then
		bot:Action_UseAbility(DeathPulse)
		return
	end
end

function UseDeathPulse()
	if not DeathPulse:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local Radius = DeathPulse:GetSpecialValueInt("area_of_effect")
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(Radius, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	
	if #FilteredEnemies > 0 then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	local AlliesWithinRange = bot:GetNearbyHeroes(Radius, false, BOT_MODE_NONE)
	local FilteredAllies = PAF.FilterTrueUnits(AlliesWithinRange)
	
	for v, Ally in pairs(FilteredAllies) do
		if Ally:GetHealth() < (Ally:GetMaxHealth() * 0.7) then
			if (bot:GetMana() - DeathPulse:GetManaCost()) > manathreshold then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end
	
	local AttackTarget = bot:GetAttackTarget()
	
	if not P.IsInLaningPhase() then
		if AttackTarget ~= nil then
			if AttackTarget:IsCreep() then
				local creeps = bot:GetNearbyCreeps(Radius, true)
				
				if #creeps >= 3
				and (bot:GetMana() - DeathPulse:GetManaCost()) > manathreshold then
					return BOT_ACTION_DESIRE_HIGH
				end
			end
			
			if PAF.IsRoshan(AttackTarget) then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end
	
	return 0
end

function UseGhostShroud()
	if not GhostShroud:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	if P.IsRetreating(bot) then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	return 0
end

function UseReapersScythe()
	if not ReapersScythe:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange
	
	if bot:GetLevel() >= 10 then
		CastRange = 700
	else
		CastRange = 600
	end
	
	local DmgMultiplier = ReapersScythe:GetSpecialValueFloat("damage_per_health")
	
	local EnemiesWithinRange = bot:GetNearbyHeroes((CastRange + 200), true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	
	if #FilteredEnemies > 0 then
		for v, Enemy in pairs(FilteredEnemies) do
			if Enemy:CanBeSeen() and not PAF.IsMagicImmune(Enemy) then
				local EnemyMaxHP = Enemy:GetMaxHealth()
				local EnemyCurrentHP = Enemy:GetHealth()
				
				local Damage = (EnemyMaxHP - EnemyCurrentHP) * DmgMultiplier
				local EstimatedDamage = Enemy:GetActualIncomingDamage(Damage, DAMAGE_TYPE_MAGICAL)
				
				if EstimatedDamage >= EnemyCurrentHP then
					return BOT_ACTION_DESIRE_HIGH, Enemy
				end
			end
		end
	end
	
	return 0
end

function UseDeathSeeker()
	if not DeathSeeker:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = DeathSeeker:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget) then
				return BOT_ACTION_DESIRE_HIGH, BotTarget
			end
		end
	end
	
	local AttackTarget = bot:GetAttackTarget()
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		if PAF.IsRoshan(AttackTarget)
		and GetUnitToUnitDistance(bot, AttackTarget) <= CastRange then
			return BOT_ACTION_DESIRE_VERYHIGH, AttackTarget
		end
	end
	
	return 0
end