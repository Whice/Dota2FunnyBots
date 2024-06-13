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

local CrystalNova = bot:GetAbilityByName("crystal_maiden_crystal_nova")
local Frostbite = bot:GetAbilityByName("crystal_maiden_frostbite")
local ArcaneAura = bot:GetAbilityByName("crystal_maiden_brilliance_aura")
local FreezingField = bot:GetAbilityByName("crystal_maiden_freezing_field")
local CrystalClone = bot:GetAbilityByName("crystal_maiden_crystal_clone")

local CrystalNovaDesire = 0
local FrostbiteDesire = 0
local FreezingFieldDesire = 0
local CrystalCloneDesire = 0

local AttackRange
local BotTarget

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	-- The order to use abilities in
	CrystalCloneDesire = UseCrystalClone()
	if CrystalCloneDesire > 0 then
		bot:Action_UseAbility(CrystalClone)
		return
	end
	
	CrystalNovaDesire, CrystalNovaTarget = UseCrystalNova()
	if CrystalNovaDesire > 0 then
		bot:Action_UseAbilityOnLocation(CrystalNova, CrystalNovaTarget)
		return
	end
	
	FrostbiteDesire, FrostbiteTarget = UseFrostbite()
	if FrostbiteDesire > 0 then
		bot:Action_UseAbilityOnEntity(Frostbite, FrostbiteTarget)
		return
	end
	
	FreezingFieldDesire = UseFreezingField()
	if FreezingFieldDesire > 0 then
		bot:Action_UseAbility(FreezingField)
		return
	end
end

function UseCrystalNova()
	if not CrystalNova:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = CrystalNova:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	local Radius = CrystalNova:GetSpecialValueInt("radius")
	
	local AoE = bot:FindAoELocation(true, true, bot:GetLocation(), CastRange, Radius/2, 0, 0)
	if (AoE.count >= 2) then
		return BOT_ACTION_DESIRE_HIGH, AoE.targetloc
	end
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget) then
				return BOT_ACTION_DESIRE_HIGH, BotTarget:GetLocation()
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

function UseFrostbite()
	if not Frostbite:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = Frostbite:GetCastRange()
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

function UseFreezingField()
	if not FreezingField:IsFullyCastable() then return 0 end
	if not PAF.IsInTeamFight(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = FreezingField:GetSpecialValueInt("radius")
	local enemies = bot:GetNearbyHeroes(CastRange - 100, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(enemies)
	
	if #FilteredEnemies >= 2 then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	return 0
end

function UseCrystalClone()
	if not CrystalClone:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local AoE = 400
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(AoE, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	
	for v, Enemy in pairs(FilteredEnemies) do
		if bot:IsFacingLocation(Enemy:GetLocation(), 10) then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	return 0
end