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

local ManaBreak = bot:GetAbilityByName("antimage_mana_break")
local Blink = bot:GetAbilityByName("antimage_blink")
local SpellShield = bot:GetAbilityByName("antimage_counterspell")
local ManaVoid = bot:GetAbilityByName("antimage_mana_void")
local CounterSpellAlly = bot:GetAbilityByName("antimage_counterspell_ally")

local BlinkDesire = 0
local SpellShieldDesire = 0
local ManaVoidDesire = 0
local CounterSpellAllyDesire = 0

local AttackRange
local BotTarget

local RadiantBase = Vector(-7171.12, -7261.72, 1469.28)
local DireBase = Vector(6977.84, 5797.69, 1357.99)
local team = bot:GetTeam()

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	AttackRange = bot:GetAttackRange()
	
	-- The order to use abilities in
	SpellShieldDesire = UseSpellShield()
	if SpellShieldDesire > 0 then
		bot:Action_UseAbility(SpellShield)
		return
	end
	
	CounterSpellAllyDesire, CounterSpellAllyTarget = UseCounterSpellAlly()
	if CounterSpellAllyDesire > 0 then
		bot:Action_UseAbilityOnEntity(CounterSpellAlly, CounterSpellAllyTarget)
		return
	end
	
	ManaVoidDesire, ManaVoidTarget = UseManaVoid()
	if ManaVoidDesire > 0 then
		bot:Action_UseAbilityOnEntity(ManaVoid, ManaVoidTarget)
		return
	end
	
	BlinkDesire, BlinkTarget = UseBlink()
	if BlinkDesire > 0 then
		bot:Action_UseAbilityOnLocation(Blink, BlinkTarget)
		return
	end
end

function UseBlink()
	if not Blink:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = Blink:GetSpecialValueInt("blink_range")
	local CastRange = PAF.GetProperCastRange(CR)
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	
	if P.IsRetreating(bot) then
		return BOT_ACTION_DESIRE_ABSOLUTE, PAF.GetFountainLocation(bot)
	end
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			local EstimatedDamage = bot:GetEstimatedDamageToTarget(true, BotTarget, 3, DAMAGE_TYPE_ALL)
			
			if EstimatedDamage > BotTarget:GetHealth() then
				if GetUnitToUnitDistance(bot, BotTarget) < CastRange
				and GetUnitToUnitDistance(bot, BotTarget) > (AttackRange + 50) then
					return BOT_ACTION_DESIRE_HIGH, BotTarget:GetLocation()
				end
			end
			
			if PAF.IsChasing(bot, BotTarget) then
				local AoECount = PAF.GetUnitsNearTarget(BotTarget:GetLocation(), FilteredEnemies, 800)
				
				if AoECount <= 2 then
					if GetUnitToUnitDistance(bot, BotTarget) > (AttackRange + 50) then
						return BOT_ACTION_DESIRE_HIGH, BotTarget:GetExtrapolatedLocation(1)
					end
				end
			end
		end
	end
	
	return 0
end

function UseSpellShield()
	if not SpellShield:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local projectiles = bot:GetIncomingTrackingProjectiles()
	
	for v, proj in pairs(projectiles) do
		if GetUnitToLocationDistance(bot, proj.location) <= 300 and proj.is_attack == false then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	return 0
end

function UseManaVoid()
	if not ManaVoid:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = ManaVoid:GetCastRange()
	local DamagePerMana = 0
	
	if ManaVoid:GetLevel() == 1 then
		DamagaPerMana = 0.8
	elseif ManaVoid:GetLevel() == 2 then
		DamagePerMana = 0.95
	elseif ManaVoid:GetLevel() == 3 then
		DamagePerMana = 1.1
	end
	
	local initenemies = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	local enemies = PAF.FilterTrueUnits(initenemies)
	local target = nil
	
	if target == nil then
		for v, enemy in pairs(enemies) do
			local EstimatedDamage = DamagaPerMana * ( enemy:GetMaxMana() - enemy:GetMana())
			local RealDamage = enemy:GetActualIncomingDamage(EstimatedDamage, DAMAGE_TYPE_MAGICAL)
			
			if RealDamage >= enemy:GetHealth() 
			and PAF.IsValidHeroTarget(enemy) 
			and not PAF.IsMagicImmune(enemy) then
				target = enemy
				break
			end
		end
	end
	
	if target ~= nil then
		return BOT_ACTION_DESIRE_HIGH, target
	end
	
	return 0
end

function UseCounterSpellAlly()
	if not CounterSpellAlly:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = CounterSpellAlly:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local AlliesWithinRange = bot:GetNearbyHeroes(CastRange, false, BOT_MODE_NONE)
	local Allies = PAF.FilterTrueUnits(AlliesWithinRange)
	
	for v, Ally in pairs(Allies) do
		if bot ~= Ally then
			local projectiles = Ally:GetIncomingTrackingProjectiles()
			
			for v, proj in pairs(projectiles) do
				if GetUnitToLocationDistance(Ally, proj.location) <= 300 and proj.is_attack == false then
					return BOT_ACTION_DESIRE_HIGH, Ally
				end
			end
		end
	end
	
	return 0
end