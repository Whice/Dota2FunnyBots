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

local BurrowStrike = bot:GetAbilityByName("sandking_burrowstrike")
local SandStorm = bot:GetAbilityByName("sandking_sand_storm")
local Stinger = bot:GetAbilityByName("sandking_scorpion_strike")
local Epicenter = bot:GetAbilityByName("sandking_epicenter")

local BurrowStrikeDesire = 0
local SandStormDesire = 0
local StingerDesire = 0
local EpicenterDesire = 0

local AttackRange
local BotTarget
local manathreshold = 0

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()

	manathreshold = (bot:GetMaxMana() * 0.4)
	
	-- The order to use abilities in
	EpicenterDesire = UseEpicenter()
	if EpicenterDesire > 0 then
		bot:Action_UseAbility(Epicenter)
		return
	end
	
	BurrowStrikeDesire, BurrowStrikeTarget = UseBurrowStrike()
	if BurrowStrikeDesire > 0 then
		bot:Action_UseAbilityOnLocation(BurrowStrike, BurrowStrikeTarget)
		return
	end
	
	SandStormDesire = UseSandStorm()
	if SandStormDesire > 0 then
		bot:Action_UseAbility(SandStorm)
		return
	end
	
	StingerDesire, StingerTarget = UseStinger()
	if StingerDesire > 0 then
		bot:Action_UseAbilityOnLocation(Stinger, StingerTarget)
		return
	end
end

function UseBurrowStrike()
	if not BurrowStrike:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = BurrowStrike:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	local Radius = BurrowStrike:GetSpecialValueInt("burrow_width")
	
	if P.IsRetreating(bot) then
		return BOT_ACTION_DESIRE_HIGH, PAF.GetXUnitsTowardsLocation(bot:GetLocation(), PAF.GetFountainLocation(bot), CastRange)
	end
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget) then
				return BOT_ACTION_DESIRE_HIGH, BotTarget:GetLocation()
			end
		end
	end
	
	local AttackTarget = bot:GetAttackTarget()
	
	if not P.IsInLaningPhase() and (bot:GetMana() - BurrowStrike:GetManaCost()) > manathreshold then
		if AttackTarget ~= nil and AttackTarget:IsCreep() then
			local NearbyCreeps = bot:GetNearbyCreeps(CastRange, true)
			local AoECount = PAF.GetUnitsNearTarget(AttackTarget:GetLocation(), NearbyCreeps, Radius)
			
			if AoECount >= 3 then
				return BOT_ACTION_DESIRE_HIGH, AttackTarget:GetLocation()
			end
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		if PAF.IsRoshan(AttackTarget)
		and GetUnitToUnitDistance(bot, AttackTarget) <= CastRange then
			return BOT_ACTION_DESIRE_VERYHIGH, AttackTarget:GetLocation()
		end
	end
	
	return 0
end

function UseSandStorm()
	if not SandStorm:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = SandStorm:GetSpecialValueInt("sand_storm_radius")
	
	local EnemiesWithinRange = bot:GetNearbyHeroes((CastRange - 150), true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	
	if (PAF.IsInTeamFight(bot) or P.IsRetreating(bot)) and #FilteredEnemies >= 1 then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	local AttackTarget = bot:GetAttackTarget()
	
	if not P.IsInLaningPhase() and (bot:GetMana() - SandStorm:GetManaCost()) > manathreshold then
		if AttackTarget ~= nil and AttackTarget:IsCreep() then
			local NearbyCreeps = bot:GetNearbyCreeps(CastRange, true)
			
			if #NearbyCreeps >= 4 then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end
	
	return 0
end

function UseStinger()
	if not Stinger:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = Stinger:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange then
				return BOT_ACTION_DESIRE_HIGH, BotTarget:GetLocation()
			end
		end
	end
	
	local AttackTarget = bot:GetAttackTarget()
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		if PAF.IsRoshan(AttackTarget)
		and GetUnitToUnitDistance(bot, AttackTarget) <= CastRange then
			return BOT_ACTION_DESIRE_VERYHIGH, AttackTarget:GetLocation()
		end
	end
	
	return 0
end

function UseEpicenter()
	if not Epicenter:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = Epicenter:GetSpecialValueInt("epicenter_radius_base")
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	
	if PAF.IsInTeamFight(bot) and #FilteredEnemies >= 1 then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	return 0
end