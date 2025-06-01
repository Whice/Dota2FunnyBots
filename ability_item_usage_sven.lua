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
local AttackTarget
local ManaThreshold

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	AttackTarget = bot:GetAttackTarget()
	ManaThreshold = (100 + StormBolt:GetManaCost() + WarCry:GetManaCost() + GodsStrength:GetManaCost())
	
	-- The order to use abilities in
	GodsStrengthDesire = UseGodsStrength()
	if GodsStrengthDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbility(GodsStrength)
		return
	end
	
	StormBoltDesire, StormBoltTarget = UseStormBolt()
	if StormBoltDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbilityOnEntity(StormBolt, StormBoltTarget)
		return
	end
	
	WarCryDesire, WarCryTarget = UseWarCry()
	if WarCryDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbility(WarCry)
		return
	end
end

function UseStormBolt()
	if not StormBolt:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = StormBolt:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	local Damage = StormBolt:GetAbilityDamage()
	local DamageType = StormBolt:GetDamageType()
	
	local EnemiesWithinCastRange = PAF.GetNearbyFilteredHeroes(bot, CastRange, true, BOT_MODE_NONE)
	
	for x, Enemy in pairs(EnemiesWithinCastRange) do
		if Enemy:IsChanneling() or PAF.CanDamageKillEnemy(Enemy, Damage, DamageType) then
			return 1, Enemy
		end
	end
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget) then
				if not PAF.IsDisabled(BotTarget) then
					return 1, BotTarget
				else
					local EnemiesWithinRange = PAF.GetNearbyFilteredHeroes(bot, 1600, true, BOT_MODE_NONE)
					local FilteredUnits = PAF.FilterExceptedUnit(EnemiesWithinRange, BotTarget)
					
					local StrongestEnemy = PAF.GetStrongestPowerUnit(FilteredUnits)
					
					if StrongestEnemy ~= nil
					and not PAF.IsDisabled(StrongestEnemy)
					and GetUnitToUnitDistance(bot, StrongestEnemy) <= CastRange then
						return 1, StrongestEnemy
					end
				end
			end
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_RETREAT then
		local StrongestEnemy = PAF.GetStrongestPowerUnit(EnemiesWithinCastRange)
		
		if StrongestEnemy ~= nil then
			return 1, StrongestEnemy
		end
	end
	
	local NearbyAlliedTowers = bot:GetNearbyTowers(1600, false)
	
	for x, Tower in pairs(NearbyAlliedTowers) do
		local TowerTarget = Tower:GetAttackTarget()
		
		if PAF.IsValidHeroAndNotIllusion(TowerTarget)
		and not PAF.IsMagicImmune(TowerTarget)
		and not PAF.IsDisabled(TowerTarget) then
			return 1, TowerTarget
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		if PAF.IsRoshan(AttackTarget) then
			return 1, AttackTarget
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_SIDE_SHOP then
		if PAF.IsTormentor(AttackTarget) then
			return 1, AttackTarget
		end
	end
	
	return 0
end

function UseWarCry()
	if not WarCry:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= 1600 then
				return 1
			end
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_RETREAT then
		local EnemiesWithinRange = PAF.GetNearbyFilteredHeroes(bot, 1200, true, BOT_MODE_NONE)
		
		if #EnemiesWithinRange > 0 then
			return 1
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		if PAF.IsRoshan(AttackTarget) then
			return 1
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_SIDE_SHOP then
		if PAF.IsTormentor(AttackTarget) then
			return 1
		end
	end
	
	return 0
end

function UseGodsStrength()
	if not GodsStrength:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= 1600 then
				return 1
			end
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		if PAF.IsRoshan(AttackTarget) then
			return 1
		end
	end
	
	return 0
end