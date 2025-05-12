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

local Fissure = bot:GetAbilityByName("earthshaker_fissure")
local EnchantTotem = bot:GetAbilityByName("earthshaker_enchant_totem")
local Aftershock = bot:GetAbilityByName("earthshaker_aftershock")
local EchoSlam = bot:GetAbilityByName("earthshaker_echo_slam")

local FissureDesire = 0
local EnchantTotemDesire = 0
local EchoSlamDesire = 0

local AttackRange
local BotTarget

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	-- The order to use abilities in
	EchoSlamDesire = UseEchoSlam()
	if EchoSlamDesire > 0 then
		bot:Action_UseAbility(EchoSlam)
		return
	end
	
	if bot:HasScepter() then		
		EnchantTotemDesire, EnchantTotemTarget = UseEnchantTotem()
		if EnchantTotemDesire > 0 then
			if EnchantTotemTarget == bot then
				bot:Action_UseAbilityOnEntity(EnchantTotem, EnchantTotemTarget)
				return
			else
				bot:Action_UseAbilityOnLocation(EnchantTotem, EnchantTotemTarget)
				return
			end
		end
	else
		EnchantTotemDesire = UseEnchantTotem()
		if EnchantTotemDesire > 0 then
			bot:Action_UseAbility(EnchantTotem)
			return
		end
	end
	
	FissureDesire, FissureTarget = UseFissure()
	if FissureDesire > 0 then
		bot:Action_UseAbilityOnLocation(Fissure, FissureTarget)
		return
	end
end

function UseFissure()
	if not Fissure:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = Fissure:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterUnitsForStun(EnemiesWithinRange)
	
	for v, enemy in pairs(FilteredEnemies) do
		if enemy:IsChanneling() then
			return BOT_ACTION_DESIRE_HIGH, enemy:GetLocation()
		end
	end
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget)
			and not PAF.IsDisabled(BotTarget) then
				if GetUnitToLocationDistance(bot, BotTarget:GetExtrapolatedLocation(1)) > CastRange then
					return BOT_ACTION_DESIRE_HIGH, PAF.GetXUnitsTowardsLocation(bot:GetLocation(), BotTarget:GetExtrapolatedLocation(1), CastRange)
				else
					return BOT_ACTION_DESIRE_HIGH, BotTarget:GetExtrapolatedLocation(1)
				end
			end
		end
	end
	
	if P.IsRetreating(bot) and #EnemiesWithinRange > 0 then
		local ClosestTarget = PAF.GetClosestUnit(bot, EnemiesWithinRange)
		return BOT_ACTION_DESIRE_HIGH, ClosestTarget:GetLocation()
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

function UseEnchantTotem()
	if not EnchantTotem:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = Aftershock:GetSpecialValueInt("aftershock_range")
	local LeapRange = EnchantTotem:GetSpecialValueInt("scepter_height")
	
	local AttackTarget = bot:GetAttackTarget()
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	
	if bot:HasScepter() then
		if PAF.IsEngaging(bot) then
			if PAF.IsValidHeroAndNotIllusion(BotTarget) then
				if GetUnitToUnitDistance(bot, BotTarget) <= LeapRange then
					if GetUnitToUnitDistance(bot, BotTarget) <= CastRange then
						return BOT_ACTION_DESIRE_HIGH, bot
					else
						return BOT_ACTION_DESIRE_HIGH, BotTarget:GetLocation()
					end
				end
			end
		end
		
		if #FilteredEnemies >= 1 and P.IsRetreating(bot) then
			return BOT_ACTION_DESIRE_HIGH, PAF.GetXUnitsTowardsLocation(bot:GetLocation(), PAF.GetFountainLocation(bot), LeapRange)
		end
	else
		if PAF.IsEngaging(bot) then
			if PAF.IsValidHeroAndNotIllusion(BotTarget) then
				if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
				and not PAF.IsDisabled(BotTarget) then
					return BOT_ACTION_DESIRE_HIGH
				end
			end
		end
		
		if #FilteredEnemies >= 1
		and P.IsRetreating(bot)
		and GetUnitToUnitDistance(bot, FilteredEnemies[1]) <= CastRange then
			return BOT_ACTION_DESIRE_HIGH
		end
		
		if bot:GetActiveMode() == BOT_MODE_LANING then
			local NearbyEnemyLaneCreeps = bot:GetNearbyLaneCreeps(1200, true)
			local NearbyAlliedLaneCreeps = bot:GetNearbyLaneCreeps(1200, false)
			
			for x, EnemyCreep in pairs(NearbyEnemyLaneCreeps) do
				if string.find(EnemyCreep:GetUnitName(), "ranged")
				or string.find(EnemyCreep:GetUnitName(), "flagbearer") then
					for y, AlliedCreep in pairs(NearbyAlliedLaneCreeps) do
						if AlliedCreep:GetAttackTarget() == EnemyCreep
						and not bot:HasModifier("modifier_earthshaker_enchant_totem") then
							return BOT_ACTION_DESIRE_HIGH
						end
					end
				end
			end
		end
	end
	
	if AttackTarget ~= nil and not P.IsInLaningPhase() then
		if AttackTarget:IsCreep() then
			local CreepsWithinRange = bot:GetNearbyCreeps(CastRange, true)
				
			if #CreepsWithinRange >= 3
			and (bot:GetMana() - EnchantTotem:GetManaCost()) >= (bot:GetMaxMana() * 0.5) then
				return BOT_ACTION_DESIRE_HIGH, bot
			end
		end
			
		if bot:GetActiveMode() == BOT_MODE_ROSHAN and PAF.IsRoshan(AttackTarget) then
			return BOT_ACTION_DESIRE_HIGH, bot
		end
		
		if PAF.IsTormentor(AttackTarget) then
			return BOT_ACTION_DESIRE_HIGH, bot
		end
	end
	
	return 0
end

function UseEchoSlam()
	if not EchoSlam:IsFullyCastable() then return 0 end
	if not PAF.IsInTeamFight(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = (EchoSlam:GetSpecialValueInt("echo_slam_echo_range") - 50)
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	
	if #FilteredEnemies >= 3 then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	return 0
end