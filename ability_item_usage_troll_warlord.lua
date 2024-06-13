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

local BerserkersRage = bot:GetAbilityByName("troll_warlord_berserkers_rage")
local WhirlingAxesRanged = bot:GetAbilityByName("troll_warlord_whirling_axes_ranged")
local WhirlingAxesMelee = bot:GetAbilityByName("troll_warlord_whirling_axes_melee")
local Fervor = bot:GetAbilityByName("troll_warlord_fervor")
local BattleTrance = bot:GetAbilityByName("troll_warlord_battle_trance")

local BerserkersRageDesire = 0
local WhirlingAxesRangedDesire = 0
local WhirlingAxesMeleeDesire = 0
local UBattleTranceDesire = 0

local AttackRange
local BotTarget

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	-- The order to use abilities in
	BattleTranceDesire = UseBattleTrance()
	if BattleTranceDesire > 0 then
		bot:Action_UseAbility(BattleTrance)
		return
	end
	
	BerserkersRageDesire = UseBerserkersRage()
	if BerserkersRageDesire > 0 then
		bot:Action_UseAbility(BerserkersRage)
		return
	end
	
	WhirlingAxesMeleeDesire = UseWhirlingAxesMelee()
	if WhirlingAxesMeleeDesire > 0 then
		bot:Action_UseAbility(WhirlingAxesMelee)
		return
	end
	
	WhirlingAxesRangedDesire, WhirlingAxesRangedTarget = UseWhirlingAxesRanged()
	if WhirlingAxesRangedDesire > 0 then
		bot:Action_UseAbilityOnLocation(WhirlingAxesRanged, WhirlingAxesRangedTarget)
		return
	end
end

function UseBerserkersRage()
	if not BerserkersRage:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local BonusAttackRange = BerserkersRage:GetSpecialValueInt("bonus_range")
	local BonusMovementSpeed = BerserkersRage:GetSpecialValueInt("bonus_move_speed")
	local RangedAttackRange = (AttackRange + BonusAttackRange)
	local BaseMovementSpeed = bot:GetCurrentMovementSpeed()
	if BerserkersRage:GetToggleState() == false then
		BaseMovementSpeed = (BaseMovementSpeed + BonusMovementSpeed)
	end
	local BaseAttackRange = AttackRange
	if BerserkersRage:GetToggleState() == true then
		BaseAttackRange = (BaseAttackRange - BonusAttackRange)
	end
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget)
		and GetUnitToUnitDistance(bot, BotTarget) > BaseAttackRange
		and GetUnitToUnitDistance(bot, BotTarget) <= RangedAttackRange
		and PAF.IsChasing(bot, BotTarget)
		and BaseMovementSpeed <= BotTarget:GetCurrentMovementSpeed()
		and not PAF.IsDisabled(BotTarget) then
			if BerserkersRage:GetToggleState() == true then
				return BOT_ACTION_DESIRE_HIGH
			else
				return 0
			end
		end
	else
		if BerserkersRage:GetToggleState() == false then
			return BOT_ACTION_DESIRE_HIGH
		else
			return 0
		end
	end
	
	
	return 0
end

function UseWhirlingAxesRanged()
	if not WhirlingAxesRanged:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = WhirlingAxesRanged:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	local Damage = WhirlingAxesRanged:GetSpecialValueInt("axe_damage")
	local Radius = WhirlingAxesRanged:GetSpecialValueInt("axe_width")
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget) then
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
	
	if bot:GetActiveMode() == BOT_MODE_FARM
	or bot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP
	or bot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID
	or bot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT then
		if AttackTarget ~= nil 
		and AttackTarget:IsCreep() then
			local NearbyCreeps = bot:GetNearbyCreeps(CastRange, true)
			local AoECount = PAF.GetUnitsNearTarget(AttackTarget:GetLocation(), NearbyCreeps, Radius)
			
			if AoECount >= 3
			and (bot:GetMana() - WhirlingAxesRanged:GetManaCost()) > (bot:GetMaxMana() * 0.5) then
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

function UseWhirlingAxesMelee()
	if not WhirlingAxesMelee:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = WhirlingAxesMelee:GetSpecialValueFloat("max_range")
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	
	if P.IsRetreating(bot)
	and #FilteredEnemies > 0 then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget) then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_FARM
	or bot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP
	or bot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID
	or bot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT then
		if AttackTarget ~= nil 
		and AttackTarget:IsCreep() then
			local NearbyCreeps = bot:GetNearbyCreeps(CastRange, true)
			
			if NearbyCreeps >= 3
			and (bot:GetMana() - WhirlingAxesMelee:GetManaCost()) > (bot:GetMaxMana() * 0.5) then
				return BOT_ACTION_DESIRE_HIGH, AttackTarget:GetLocation()
			end
		end
	end
	
	return 0
end

function UseBattleTrance()
	if not BattleTrance:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = BattleTrance:GetSpecialValueInt("range")
	local Duration = BattleTrance:GetSpecialValueFloat("trance_duration")
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	
	if PAF.IsInTeamFight(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			local EstimatedDamage = bot:GetEstimatedDamageToTarget(true, BotTarget, Duration, DAMAGE_TYPE_PHYSICAL)
		
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsPhysicalImmune(BotTarget)
			and BotTarget:GetHealth() <= EstimatedDamage then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end
	
	local projectiles = bot:GetIncomingTrackingProjectiles()
	
	for v, proj in pairs(projectiles) do
		if GetUnitToLocationDistance(bot, proj.location) <= 300
		and proj.is_attack == false
		and bot:GetHealth() < (bot:GetMaxHealth() * 0.35) then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	if bot:GetHealth() < (bot:GetMaxHealth() * 0.35)
	and bot:WasRecentlyDamagedByAnyHero(1)
	and #FilteredEnemies > 0 then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	return 0
end