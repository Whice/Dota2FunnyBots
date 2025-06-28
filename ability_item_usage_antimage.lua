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
local AttackTarget
local ManaThreshold

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	AttackTarget = bot:GetAttackTarget()
	ManaThreshold = 100
	
	for x = 5, 1, -1 do
		local hAbility = bot:GetAbilityInSlot(x)
		if hAbility ~= nil
		and hAbility:IsTrained()
		and not hAbility:IsHidden() then
			local nManaCost = hAbility:GetManaCost()
			
			if nManaCost > 0 then
				ManaThreshold = (ManaThreshold + nManaCost)
			end
		end
	end
	
	-- The order to use abilities in
	SpellShieldDesire = UseSpellShield()
	if SpellShieldDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbility(SpellShield)
		return
	end
	
	CounterSpellAllyDesire, CounterSpellAllyTarget = UseCounterSpellAlly()
	if CounterSpellAllyDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbilityOnEntity(CounterSpellAlly, CounterSpellAllyTarget)
		return
	end
	
	ManaVoidDesire, ManaVoidTarget = UseManaVoid()
	if ManaVoidDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbilityOnEntity(ManaVoid, ManaVoidTarget)
		return
	end
	
	BlinkDesire, BlinkTarget = UseBlink()
	if BlinkDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbilityOnLocation(Blink, BlinkTarget)
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
		return 1, PAF.GetFountainLocation(bot)
	end
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			local EstimatedDamage = bot:GetEstimatedDamageToTarget(true, BotTarget, 3, DAMAGE_TYPE_ALL)
			
			if EstimatedDamage > BotTarget:GetHealth() then
				if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
				and GetUnitToUnitDistance(bot, BotTarget) > (AttackRange + 150) then
					return 1, BotTarget:GetLocation()
				end
			end
			
			if PAF.IsChasing(bot, BotTarget) then
				local AoECount = PAF.GetUnitsNearTarget(BotTarget:GetLocation(), FilteredEnemies, 800)
				
				if AoECount <= 2 then
					if GetUnitToUnitDistance(bot, BotTarget) > (AttackRange + 150) then
						return 1, BotTarget:GetExtrapolatedLocation(1)
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
		if GetUnitToLocationDistance(bot, proj.location) <= 300
		and proj.is_attack == false
		and proj.caster ~= nil
		and proj.caster:GetTeam() ~= bot:GetTeam() then
			return 1
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
			and not PAF.IsMagicImmune(enemy)
			and not PAF.IsReflectingSpells(enemy) then
				target = enemy
				break
			end
		end
	end
	
	if target ~= nil then
		return 1, target
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
					return 1, Ally
				end
			end
		end
	end
	
	return 0
end