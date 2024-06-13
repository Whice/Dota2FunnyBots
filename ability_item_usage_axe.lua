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

local BerserkersCall = bot:GetAbilityByName("axe_berserkers_call")
local BattleHunger = bot:GetAbilityByName("axe_battle_hunger")
local CounterHelix = bot:GetAbilityByName("axe_counter_helix")
local CullingBlade = bot:GetAbilityByName("axe_culling_blade")

local BerserkersCallDesire = 0
local BattleHungerDesire = 0
local CullingBladeDesire = 0

local AttackRange
local BotTarget

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	-- The order to use abilities in
	CullingBladeDesire, CullingBladeTarget = UseCullingBlade()
	if CullingBladeDesire > 0 then
		bot:Action_UseAbilityOnEntity(CullingBlade, CullingBladeTarget)
		return
	end
	
	BerserkersCallDesire = UseBerserkersCall()
	if BerserkersCallDesire > 0 then
		bot:Action_UseAbility(BerserkersCall)
		return
	end
	
	BattleHungerDesire, BattleHungerTarget = UseBattleHunger()
	if BattleHungerDesire > 0 then
		bot:Action_UseAbilityOnEntity(BattleHunger, BattleHungerTarget)
		return
	end
end

function UseBerserkersCall()
	if not BerserkersCall:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = BerserkersCall:GetSpecialValueInt("radius")
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end
	
	if P.IsRetreating(bot) then
		local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
		local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	
		if #FilteredEnemies > 0 then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	return 0
end

function UseBattleHunger()
	if not BattleHunger:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = BattleHunger:GetCastRange()
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
		if AttackTarget ~= nil and PAF.IsRoshan(AttackTarget) then
			return BOT_ACTION_DESIRE_HIGH, AttackTarget
		end
	end
	
	return 0
end

function UseCullingBlade()
	if not CullingBlade:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = CullingBlade:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	local AbilityLevel = CullingBlade:GetLevel()
	local AbilityDamage = 150 + (100 * AbilityLevel)
	
	if bot:GetLevel() >= 20 then
		AbilityDamage = (AbilityDamage + 150)
	end
	
	local enemies = bot:GetNearbyHeroes(500, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(enemies)
	
	local LowestHealth = AbilityDamage
	local target = nil
	
	if #enemies > 0 then
		for v, enemy in pairs(FilteredEnemies) do
			if PAF.IsValidHeroTarget(enemy) then
				if enemy:GetHealth() <= LowestHealth then
					target = enemy
					LowestHealth = enemy:GetHealth()
				end
			end
		end
	end
	
	if target ~= nil then
		return BOT_ACTION_DESIRE_HIGH, target
	end
	
	return 0
end