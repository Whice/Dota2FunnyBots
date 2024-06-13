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

local StormBolt = bot:GetAbilityByName("sven_storm_bolt")
local GreatCleave = bot:GetAbilityByName("sven_great_cleave")
local WarCry = bot:GetAbilityByName("sven_warcry")
local GodsStrength = bot:GetAbilityByName("sven_gods_strength")

local StormBoltDesire = 0
local WarCryDesire = 0
local GodsStrengthDesire = 0

local AttackRange
local BotTarget
local AttackRange = 0

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	-- The order to use abilities in
	GodsStrengthDesire = UseGodsStrength()
	if GodsStrengthDesire > 0 then
		bot:Action_UseAbility(GodsStrength)
		return
	end
	
	StormBoltDesire, StormBoltTarget = UseStormBolt()
	if StormBoltDesire > 0 then
		bot:Action_UseAbilityOnEntity(StormBolt, StormBoltTarget)
		return
	end
	
	WarCryDesire, WarCryTarget = UseWarCry()
	if WarCryDesire > 0 then
		bot:Action_UseAbility(WarCry)
		return
	end
end

function UseStormBolt()
	if not StormBolt:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = StormBolt:GetCastRange()
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

function UseWarCry()
	if not WarCry:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local enemies = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	local tableTrueEnemies = PAF.FilterTrueUnits(enemies)
	
	if (PAF.IsEngaging(bot) and #tableTrueEnemies > 0)
	or P.IsRetreating(bot) then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		local AttackTarget = bot:GetAttackTarget()
		
		if PAF.IsRoshan(AttackTarget) then
			return BOT_ACTION_DESIRE_VERYHIGH
		end
	end
	
	return 0
end

function UseGodsStrength()
	if not GodsStrength:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local enemies = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	local tableTrueEnemies = PAF.FilterTrueUnits(enemies)
	
	if PAF.IsEngaging(bot) and #tableTrueEnemies > 0 then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		local AttackTarget = bot:GetAttackTarget()
		
		if PAF.IsRoshan(AttackTarget) then
			return BOT_ACTION_DESIRE_VERYHIGH
		end
	end
	
	return 0
end