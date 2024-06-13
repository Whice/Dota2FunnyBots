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

local Void = bot:GetAbilityByName("night_stalker_void")
local CripplingFear = bot:GetAbilityByName("night_stalker_crippling_fear")
local Darkness = bot:GetAbilityByName("night_stalker_darkness")
local HunterInTheNight = bot:GetAbilityByName("night_stalker_hunter_in_the_night")

local VoidDesire = 0
local CripplingFearDesire = 0
local DarknessDesire = 0
local HunterInTheNightDesire = 0

local AttackRange
local BotTarget
local manathreshold = 0

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()

	manathreshold = 100
	manathreshold = manathreshold + Void:GetManaCost()
	manathreshold = manathreshold + CripplingFear:GetManaCost()
	manathreshold = manathreshold + Darkness:GetManaCost()
	manathreshold = manathreshold + HunterInTheNight:GetManaCost()
	
	-- The order to use abilities in
	DarknessDesire = UseDarkness()
	if DarknessDesire > 0 then
		bot:Action_UseAbility(Darkness)
		return
	end
	
	CripplingFearDesire = UseCripplingFear()
	if CripplingFearDesire > 0 then
		bot:Action_UseAbility(CripplingFear)
		return
	end
	
	HunterInTheNightDesire, HunterInTheNightTarget = UseHunterInTheNight()
	if HunterInTheNightDesire > 0 then
		bot:Action_UseAbilityOnEntity(HunterInTheNight, HunterInTheNightTarget)
		return
	end
	
	VoidDesire, VoidTarget = UseVoid()
	if VoidDesire > 0 then
		bot:Action_UseAbilityOnEntity(Void, VoidTarget)
		return
	end
end

function UseVoid()
	if not Void:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = Void:GetCastRange()
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
			and not PAF.IsMagicImmune(BotTarget) then
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

function UseCripplingFear()
	if not CripplingFear:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = CripplingFear:GetSpecialValueInt("radius")
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterUnitsForStun(EnemiesWithinRange)
	
	if #FilteredEnemies >= 1 and (P.IsRetreating(bot) or PAF.IsEngaging(bot)) then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	return 0
end

function UseDarkness()
	if not Darkness:IsFullyCastable() then return 0 end
	if not PAF.IsInTeamFight(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	return BOT_ACTION_DESIRE_HIGH
end

function UseHunterInTheNight()
	if HunterInTheNight:IsPassive() then return 0 end
	if not HunterInTheNight:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	if (bot:GetHealth() <= (bot:GetMaxHealth() * 0.65)) or (bot:GetMana() <= (bot:GetMaxMana() * 0.75)) then
		local creeps = bot:GetNearbyCreeps(500, true)
		
		if #creeps >= 1 then
			return BOT_ACTION_DESIRE_HIGH, creeps[1]
		end
	end
	
	return 0
end