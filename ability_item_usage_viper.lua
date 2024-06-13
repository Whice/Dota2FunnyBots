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

local PoisonAttack = bot:GetAbilityByName("viper_poison_attack")
local Nethertoxin = bot:GetAbilityByName("viper_nethertoxin")
local CorrosiveSkin = bot:GetAbilityByName("viper_corrosive_skin")
local ViperStrike = bot:GetAbilityByName("viper_viper_strike")

local PoisonAttackDesire = 0
local NetherToxinDesire = 0
local ViperStrikeDesire = 0

local AttackRange
local BotTarget
local AttackRange = 0

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()

	local HasUltimateAvailable = false
	local VSManaCost = 0
	
	if ViperStrike:IsTrained() and ViperStrike:IsFullyCastable() then
		VSManaCost = ViperStrike:GetManaCost()
		HasUltimateAvailable = true
	end

	
	-- The order to use abilities in
	ViperStrikeDesire, ViperStrikeTarget = UseViperStrike()
	if ViperStrikeDesire > 0 then
		bot:Action_UseAbilityOnEntity(ViperStrike, ViperStrikeTarget)
		return
	end
	
	NetherToxinDesire, NetherToxinTarget = UseNethertoxin()
	if NetherToxinDesire > 0 then
		bot:Action_UseAbilityOnLocation(Nethertoxin, NetherToxinTarget)
		return
	end
	
	PoisonAttackDesire, PoisonAttackTarget = UsePoisonAttack()
	if PoisonAttackDesire > 0 then
--		bot:Action_ClearActions(false)
		bot:Action_UseAbilityOnEntity(PoisonAttack, PoisonAttackTarget)
		return
	end
end

function UsePoisonAttack()
	if not PoisonAttack:IsFullyCastable() or bot:IsDisarmed() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = PoisonAttack:GetCastRange()
	
	if P.IsInLaningPhase() and PoisonAttack:GetLevel() >= 2 then
		local EnemiesWithinRange = bot:GetNearbyHeroes((AttackRange + 50), true, BOT_MODE_NONE)
		local FilteredEnemies = PAF.FilterUnitsForStun(EnemiesWithinRange)
		local WeakestEnemy = PAF.GetWeakestUnit(FilteredEnemies)
		
		if WeakestEnemy ~= nil
		and not PAF.IsPhysicalImmune(WeakestEnemy)
		and not P.IsRetreating(bot) then
			return BOT_ACTION_DESIRE_HIGH, WeakestEnemy
		end
	end
	
	local target = bot:GetAttackTarget()
	
	if target ~= nil
	and (target:IsHero() or target:IsBuilding())
	and not P.IsRetreating(bot) then
		if PoisonAttack:GetAutoCastState() == false then
			PoisonAttack:ToggleAutoCast()
			return 0
		end
	end
	
	if target == nil then
		if PoisonAttack:GetAutoCastState() == true then
			PoisonAttack:ToggleAutoCast()
			return 0
		end
	else
		if not target:IsHero() and not target:IsBuilding() then
			if PoisonAttack:GetAutoCastState() == true then
				PoisonAttack:ToggleAutoCast()
				return 0
			end
		end
	end
	
	return 0
end

function UseNethertoxin()
	if not Nethertoxin:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = Nethertoxin:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget)
		and	not PAF.IsMagicImmune(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange then
				return BOT_ACTION_DESIRE_HIGH, BotTarget:GetExtrapolatedLocation(1)
			end
		end
	end
	
	if not P.IsInLaningPhase() then
		local AttackTarget = bot:GetAttackTarget()
		
		if AttackTarget ~= nil and AttackTarget:IsCreep() then
			local NearbyCreeps = bot:GetNearbyCreeps(CastRange, true)
			local AoECount = PAF.GetUnitsNearTarget(AttackTarget:GetLocation(), NearbyCreeps, Nethertoxin:GetSpecialValueInt("radius"))
			
			if AoECount >= 3
			and GetUnitToUnitDistance(bot, AttackTarget) <= CastRange then
				return BOT_ACTION_DESIRE_VERYHIGH, AttackTarget:GetLocation()
			end
		end
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

function UseViperStrike()
	if not ViperStrike:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = ViperStrike:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterUnitsForStun(EnemiesWithinRange)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange then
				return BOT_ACTION_DESIRE_HIGH, BotTarget
			end
		end
	end
	
	if P.IsRetreating(bot) and #FilteredEnemies > 0 then
		local ClosestTarget = PAF.GetClosestUnit(bot, FilteredEnemies)
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