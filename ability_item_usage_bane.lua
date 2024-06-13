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

local Enfeeble = bot:GetAbilityByName("bane_enfeeble")
local BrainSap = bot:GetAbilityByName("bane_brain_sap")
local Nightmare = bot:GetAbilityByName("bane_nightmare")
local FiendsGrip = bot:GetAbilityByName("bane_fiends_grip")

local EnfeebleDesire = 0
local BrainSapDesire = 0
local NightmareDesire = 0
local FiendsGripDesire = 0

local AttackRange
local BotTarget

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	-- The order to use abilities in
	NightmareDesire, NightmareTarget = UseNightmare()
	if NightmareDesire > 0 then
		bot:Action_UseAbilityOnEntity(Nightmare, NightmareTarget)
		return
	end
	
	EnfeebleDesire, EnfeebleTarget = UseEnfeeble()
	if EnfeebleDesire > 0 then
		bot:Action_UseAbilityOnEntity(Enfeeble, EnfeebleTarget)
		return
	end
	
	BrainSapDesire, BrainSapTarget = UseBrainSap()
	if BrainSapDesire > 0 then
		bot:Action_UseAbilityOnEntity(BrainSap, BrainSapTarget)
		return
	end
	
	FiendsGripDesire, FiendsGripTarget = UseFiendsGrip()
	if FiendsGripDesire > 0 then
		bot:Action_UseAbilityOnEntity(FiendsGrip, FiendsGripTarget)
		return
	end
end

function UseEnfeeble()
	if not Enfeeble:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = Enfeeble:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	
	local Target = PAF.GetStrongestAttackDamageUnit(FilteredEnemies)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget) then
				return BOT_ACTION_DESIRE_HIGH, Target
			end
		end
	end
	
	return 0
end

function UseBrainSap()
	if not BrainSap:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = BrainSap:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget) then
				return BOT_ACTION_DESIRE_HIGH, BotTarget
			end
		end
	end
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterUnitsForStun(EnemiesWithinRange)
	
	if P.IsRetreating(bot) and #FilteredEnemies > 0 then
		local WeakestEnemy = PAF.GetWeakestUnit(FilteredEnemies)
		
		if WeakestEnemy ~= nil then
			return BOT_ACTION_DESIRE_HIGH, WeakestEnemy
		end
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

function UseNightmare()
	if not Nightmare:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = Nightmare:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterUnitsForStun(EnemiesWithinRange)
	
	for v, enemy in pairs(FilteredEnemies) do
		if enemy:IsChanneling() then
			return BOT_ACTION_DESIRE_HIGH, enemy
		end
	end
	
	local Target = PAF.GetStrongestPowerUnit(FilteredEnemies)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(Target) then
			if GetUnitToUnitDistance(bot, Target) <= CastRange
			and not PAF.IsMagicImmune(Target)
			and not PAF.IsDisabled(Target) then
				return BOT_ACTION_DESIRE_HIGH, Target
			end
		end
	end
	
	if P.IsRetreating(bot) and #EnemiesWithinRange > 0 then
		local ClosestTarget = PAF.GetClosestUnit(bot, EnemiesWithinRange)
		return BOT_ACTION_DESIRE_HIGH, ClosestTarget
	end
	
	return 0
end

function UseFiendsGrip()
	if not FiendsGrip:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = FiendsGrip:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsDisabled(BotTarget) then
				return BOT_ACTION_DESIRE_HIGH, BotTarget
			end
		end
	end
	
	return 0
end