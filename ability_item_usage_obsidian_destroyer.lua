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

local ArcaneOrb = bot:GetAbilityByName("obsidian_destroyer_arcane_orb")
local AstralImprisonment = bot:GetAbilityByName("obsidian_destroyer_astral_imprisonment")
local EssenceAura = bot:GetAbilityByName("obsidian_destroyer_equilibrium")
local SanityEclipse = bot:GetAbilityByName("obsidian_destroyer_sanity_eclipse")

local ArcaneOrbDesire = 0
local AstralImprisonmentDesire = 0
local SanityEclipseDesire = 0

local AttackRange
local BotTarget
local manathreshold = 0

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	manathreshold = 100
	manathreshold = manathreshold + ArcaneOrb:GetManaCost()
	manathreshold = manathreshold + AstralImprisonment:GetManaCost()
	manathreshold = manathreshold + SanityEclipse:GetManaCost()
	
	if EssenceAura:GetLevel() >= 3 and ArcaneOrb:GetAutoCastState() == false then
		ArcaneOrb:ToggleAutoCast()
	end
	
	-- The order to use abilities in
	SanityEclipseDesire, SanityEclipseTarget = UseSanityEclipse()
	if SanityEclipseDesire > 0 then
		bot:Action_UseAbilityOnLocation(SanityEclipse, SanityEclipseTarget)
		return
	end
	
	AstralImprisonmentDesire, AstralImprisonmentTarget = UseAstralImprisonment()
	if AstralImprisonmentDesire > 0 then
		bot:Action_UseAbilityOnEntity(AstralImprisonment, AstralImprisonmentTarget)
		return
	end
	
	ArcaneOrbDesire, ArcaneOrbTarget = UseArcaneOrb()
	if ArcaneOrbDesire > 0 then
		bot:Action_UseAbilityOnEntity(ArcaneOrb, ArcaneOrbTarget)
		return
	end
end

function UseArcaneOrb()
	if not ArcaneOrb:IsFullyCastable() or bot:IsDisarmed() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	if ArcaneOrb:GetAutoCastState() == true then return 0 end
	
	if P.IsInLaningPhase() then
		local EnemiesWithinExtraRange = bot:GetNearbyHeroes((AttackRange + 200), true, BOT_MODE_NONE)
		local FilteredEnemies = PAF.FilterUnitsForStun(EnemiesWithinExtraRange)
		local WeakestEnemy = PAF.GetWeakestUnit(FilteredEnemies)
		
		if PAF.IsValidHeroTarget(WeakestEnemy) and not PAF.IsMagicImmune(WeakestEnemy) then
			return BOT_ACTION_DESIRE_HIGH, WeakestEnemy
		end
	end
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= (AttackRange + 50)
			and not PAF.IsMagicImmune(BotTarget) and not PAF.IsPhysicalImmune(BotTarget) then
				return BOT_ACTION_DESIRE_HIGH, BotTarget
			end
		end
	end
	
	local AttackTarget = bot:GetAttackTarget()
	
	if bot:GetActiveMode() == BOT_MODE_FARM then
		if AttackTarget:IsCreep() and (bot:GetMana() - ArcaneOrb:GetManaCost()) > manathreshold then
			return BOT_ACTION_DESIRE_HIGH, AttackTarget
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		if PAF.IsRoshan(AttackTarget) then
			return BOT_ACTION_DESIRE_HIGH, AttackTarget
		end
	end
	
	return 0
end

function UseAstralImprisonment()
	if not AstralImprisonment:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = AstralImprisonment:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local EnemiesWithinExtraRange = bot:GetNearbyHeroes((CastRange + 200), true, BOT_MODE_NONE)
	local FilteredEnemies
	local AlliesWithinRange = bot:GetNearbyHeroes(CastRange, false, BOT_MODE_NONE)
	local FilteredAllies = PAF.FilterTrueUnits(AlliesWithinRange)
	
	if P.IsInLaningPhase() then
		FilteredEnemies = PAF.FilterUnitsForStun(EnemiesWithinExtraRange)
		local WeakestEnemy = PAF.GetWeakestUnit(FilteredEnemies)
		
		if PAF.IsValidHeroTarget(WeakestEnemy) and not PAF.IsMagicImmune(WeakestEnemy) then
			return BOT_ACTION_DESIRE_HIGH, WeakestEnemy
		end
	end
	
	FilteredEnemies = PAF.FilterUnitsForStun(EnemiesWithinRange)
	
	if PAF.IsInTeamFight(bot) then
		for v, Ally in pairs(FilteredAllies) do
			if Ally:GetHealth() < (Ally:GetMaxHealth() * 0.3) then
				return BOT_ACTION_DESIRE_HIGH, Ally
			end
		end
	end
	
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
	
	return 0
end

function UseSanityEclipse()
	if not SanityEclipse:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = SanityEclipse:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local BaseDamage = SanityEclipse:GetSpecialValueInt("base_damage")
	local DamageMultiplier = SanityEclipse:GetSpecialValueInt("damage_multiplier")
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	
	for v, Enemy in pairs(FilteredEnemies) do
		if Enemy:CanBeSeen()
		and not PAF.IsMagicImmune(Enemy)
		and Enemy:IsAlive()
		and bot:GetMana() > Enemy:GetMana() then
			local ManaDifference = (bot:GetMana() - Enemy:GetMana())
			local EclipseDamage = (ManaDifference * DamageMultiplier)
			local MagicDamage = Enemy:GetActualIncomingDamage(EclipseDamage, DAMAGE_TYPE_MAGICAL)
			
			local EstimatedDamage = (BaseDamage + MagicDamage)
			if Enemy:GetHealth() > BaseDamage
			and Enemy:GetHealth() <= EstimatedDamage then
				return BOT_ACTION_DESIRE_HIGH, Enemy:GetLocation()
			end
		end
	end
	
	return 0
end