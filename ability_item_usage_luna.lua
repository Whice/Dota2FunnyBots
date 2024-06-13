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

local LucentBeam = bot:GetAbilityByName("luna_lucent_beam")
local MoonGlaives = bot:GetAbilityByName("luna_moon_glaive")
local LunarBlessing = bot:GetAbilityByName("luna_lunar_blessing")
local Eclipse = bot:GetAbilityByName("luna_eclipse")

local LucentBeamDesire = 0
local EclipseDesire = 0
local MoonGlaivesDesire = 0

local AttackRange
local BotTarget
local manathreshold = 0

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	manathreshold = 100
	manathreshold = manathreshold + LucentBeam:GetManaCost()
	manathreshold = manathreshold + Eclipse:GetManaCost()
	manathreshold = manathreshold + MoonGlaives:GetManaCost()
	
	-- The order to use abilities in
	MoonGlaivesDesire = UseMoonGlaives()
	if MoonGlaivesDesire > 0 then
		bot:Action_UseAbility(MoonGlaives)
		return
	end
	
	EclipseDesire = UseEclipse()
	if EclipseDesire > 0 then
		bot:Action_UseAbility(Eclipse)
		return
	end
	
	LucentBeamDesire, LucentBeamTarget = UseLucentBeam()
	if LucentBeamDesire > 0 then
		bot:Action_UseAbilityOnEntity(LucentBeam, LucentBeamTarget)
		return
	end
end

function UseLucentBeam()
	if not LucentBeam:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = LucentBeam:GetCastRange()
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
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange then
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

function UseEclipse()
	if not Eclipse:IsFullyCastable() then return 0 end
	if not PAF.IsInTeamFight(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local Radius = Eclipse:GetSpecialValueInt("radius")
	local EnemiesWithinRange = bot:GetNearbyHeroes(Radius, true, BOT_MODE_NONE)
	
	if #EnemiesWithinRange >= 2 then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	return 0
end

function UseMoonGlaives()
	if not MoonGlaives:IsFullyCastable() then return 0 end
	if MoonGlaives:IsPassive() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local Radius = 150
	local EnemiesWithinRange = bot:GetNearbyHeroes(Radius, true, BOT_MODE_NONE)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end
	
	if P.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2) then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	return 0
end