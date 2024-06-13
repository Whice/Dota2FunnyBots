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

local Impale = bot:GetAbilityByName("lion_impale")
local Voodoo = bot:GetAbilityByName("lion_voodoo")
local ManaDrain = bot:GetAbilityByName("lion_mana_drain")
local FingerOfDeath = bot:GetAbilityByName("lion_finger_of_death")

local ImpaleDesire = 0
local VoodooDesire = 0
local ManaDrainDesire = 0
local FingerOfDeathDesire = 0

local AttackRange
local BotTarget

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	-- The order to use abilities in
	FingerOfDeathDesire, FingerOfDeathTarget = UseFingerOfDeath()
	if FingerOfDeathDesire > 0 then
		bot:Action_ClearActions(false)
		bot:Action_UseAbilityOnEntity(FingerOfDeath, FingerOfDeathTarget)
		return
	end
	
	VoodooDesire, VoodooTarget = UseVoodoo()
	if VoodooDesire > 0 then
		bot:Action_UseAbilityOnEntity(Voodoo, VoodooTarget)
		return
	end
	
	ImpaleDesire, ImpaleTarget = UseImpale()
	if ImpaleDesire > 0 then
		bot:Action_UseAbilityOnLocation(Impale, ImpaleTarget)
		return
	end
	
	ManaDrainDesire, ManaDrainTarget = UseManaDrain()
	if ManaDrainDesire > 0 then
		bot:Action_UseAbilityOnEntity(ManaDrain, ManaDrainTarget)
		return
	end
end

function UseImpale()
	if not Impale:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = Impale:GetCastRange()
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
			and not PAF.IsMagicImmune(BotTarget)
			and not PAF.IsDisabled(BotTarget) then
				if GetUnitToLocationDistance(bot, BotTarget:GetExtrapolatedLocation(1)) > CastRange then
					return BOT_ACTION_DESIRE_HIGH, bot:GetXUnitsTowardsLocation(BotTarget:GetExtrapolatedLocation(1), CastRange)
				else
					return BOT_ACTION_DESIRE_HIGH, BotTarget:GetExtrapolatedLocation(1)
				end
			end
		end
	end
	
	if P.IsRetreating(bot) and #EnemiesWithinRange > 0 then
		local ClosestTarget = PAF.GetClosestUnit(bot, EnemiesWithinRange)
		return BOT_ACTION_DESIRE_HIGH, ClosestTarget:GetLocation()
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		local AttackTarget = bot:GetAttackTarget()
		
		if PAF.IsRoshan(AttackTarget)
		and GetUnitToUnitDistance(bot, AttackTarget) <= CastRange then
			return BOT_ACTION_DESIRE_VERYHIGH, AttackTarget:GetLocation()
		end
	end
	
	return 0
end

function UseVoodoo()
	if not Voodoo:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = Voodoo:GetCastRange()
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
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget)
			and not PAF.IsDisabled(BotTarget) then
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

function UseManaDrain()
	if not ManaDrain:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = Impale:GetCastRange()
	local enemies = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local target = nil
	
	if PAF.IsEngaging(bot) and #enemies >= 1 then
		if Impale:IsFullyCastable() or Voodoo:IsFullyCastable() then
			target = PAF.GetClosestUnit(bot, enemies)
			return BOT_ACTION_DESIRE_HIGH, target
		end
	end
	
	local nearenemies = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	
	if #nearenemies <= 0 and bot:GetMana() < (bot:GetMaxMana() * 0.5) then
		local creeps = bot:GetNearbyCreeps(CastRange + 200, true)
		
		if #creeps >= 1 and creeps[1]:GetMana() > 100 then
			target = creeps[1]
			return BOT_ACTION_DESIRE_HIGH, target
		end
	end
	
	return 0
end

function UseFingerOfDeath()
	if not FingerOfDeath:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = FingerOfDeath:GetCastRange()
	local Damage = FingerOfDeath:GetAbilityDamage()
	
	local enemies = bot:GetNearbyHeroes(CastRange + 500, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(enemies)
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