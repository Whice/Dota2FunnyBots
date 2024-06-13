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

local Bloodrage = bot:GetAbilityByName("bloodseeker_bloodrage")
local BloodBath = bot:GetAbilityByName("bloodseeker_blood_bath")
local Thirst = bot:GetAbilityByName("bloodseeker_thirst")
local Rupture = bot:GetAbilityByName("bloodseeker_rupture")

local BloodrageDesire = 0
local BloodBathDesire = 0
local RuptureDesire = 0

local AttackRange
local BotTarget

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	-- The order to use abilities in
	RuptureDesire, RuptureTarget = UseRupture()
	if RuptureDesire > 0 then
		bot:Action_UseAbilityOnEntity(Rupture, RuptureTarget)
		return
	end
	
	BloodBathDesire, BloodBathTarget = UseBloodBath()
	if BloodBathDesire > 0 then
		bot:Action_UseAbilityOnLocation(BloodBath, BloodBathTarget)
		return
	end
	
	BloodrageDesire, BloodrageTarget = UseBloodrage()
	if BloodrageDesire > 0 then
		bot:Action_UseAbilityOnEntity(Bloodrage, BloodrageTarget)
		return
	end
end

function UseBloodrage()
	if not Bloodrage:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			return BOT_ACTION_DESIRE_HIGH, bot
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_FARM then
		local AttackTarget = bot:GetAttackTarget()
		
		if AttackTarget ~= nil and AttackTarget:IsCreep() then
			return BOT_ACTION_DESIRE_HIGH, bot
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		local AttackTarget = bot:GetAttackTarget()
		
		if PAF.IsRoshan(AttackTarget)
		and GetUnitToUnitDistance(bot, AttackTarget) <= CastRange then
			return BOT_ACTION_DESIRE_VERYHIGH, bot
		end
	end
	
	return 0
end

function UseBloodBath()
	if not BloodBath:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = BloodBath:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	local CastPoint = BloodBath:GetCastPoint()
	local BBDelay = BloodBath:GetSpecialValueInt("delay")
	
	local initenemies = bot:GetNearbyHeroes(1000, true, BOT_MODE_NONE)
	local enemies = PAF.FilterTrueUnits(initenemies)
	
	if P.IsRetreating(bot) and #enemies >= 1 then
		return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()
	end
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget) then
				return BOT_ACTION_DESIRE_HIGH, BotTarget:GetExtrapolatedLocation(CastPoint + BBDelay)
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

function UseRupture()
	if not Rupture:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = Rupture:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	local PotentialEnemies = {}
	
	for v, Enemy in pairs(FilteredEnemies) do
		if not Enemy:HasModifier("modifier_bloodseeker_rupture") then
			table.insert(PotentialEnemies, Enemy)
		end
	end
	
	local WeakestEnemy = nil
	if #PotentialEnemies > 0 then
		WeakestEnemy = PAF.GetWeakestUnit(PotentialEnemies)
	end
	
	if PAF.IsEngaging(bot) and WeakestEnemy ~= nil then
		return BOT_ACTION_DESIRE_HIGH, WeakestEnemy
	end
	
	return 0
end