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

local Flux = bot:GetAbilityByName("arc_warden_flux")
local MagneticField = bot:GetAbilityByName("arc_warden_magnetic_field")
local SparkWraith = bot:GetAbilityByName("arc_warden_spark_wraith")
local TempestDouble = bot:GetAbilityByName("arc_warden_tempest_double")

local FluxDesire = 0
local MagneticFieldDesire = 0
local SparkWraithDesire = 0
local TempestDoubleDesire = 0

local AttackRange
local BotTarget
local manathreshold = 0

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	manathreshold = 100
	manathreshold = manathreshold + Flux:GetManaCost()
	manathreshold = manathreshold + MagneticField:GetManaCost()
	manathreshold = manathreshold + SparkWraith:GetManaCost()
	manathreshold = manathreshold + TempestDouble:GetManaCost()
	
	-- The order to use abilities in
	TempestDoubleDesire, TempestDoubleTarget = UseTempestDouble()
	if TempestDoubleDesire > 0 then
		bot:Action_UseAbilityOnLocation(TempestDouble, TempestDoubleTarget)
		return
	end
	
	FluxDesire, FluxTarget = UseFlux()
	if FluxDesire > 0 then
		bot:Action_UseAbilityOnEntity(Flux, FluxTarget)
		return
	end
	
	MagneticFieldDesire, MagneticFieldTarget = UseMagneticField()
	if MagneticFieldDesire > 0 then
		bot:Action_UseAbilityOnLocation(MagneticField, MagneticFieldTarget)
		return
	end
	
	SparkWraithDesire, SparkWraithTarget = UseSparkWraith()
	if SparkWraithDesire > 0 then
		bot:Action_UseAbilityOnLocation(SparkWraith, SparkWraithTarget)
		return
	end
end

function UseFlux()
	if not Flux:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = Flux:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange then
				return BOT_ACTION_DESIRE_HIGH, BotTarget
			end
		end
	end
	
	local AttackTarget = bot:GetAttackTarget()
	
	if AttackTarget ~= nil then
		if bot:GetActiveMode() == BOT_MODE_ROSHAN then
			if PAF.IsRoshan(AttackTarget)
			and GetUnitToUnitDistance(bot, AttackTarget) <= CastRange then
				return BOT_ACTION_DESIRE_VERYHIGH, AttackTarget
			end
		end
		
		if PAF.IsTormentor(AttackTarget) then
			return BOT_ACTION_DESIRE_HIGH, AttackTarget
		end
	end
	
	return 0
end

function UseMagneticField()
	if not MagneticField:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = MagneticField:GetCastRange()
	
	local allies = bot:GetNearbyHeroes(CastRange + 100, false, BOT_MODE_NONE)
	local allytarget = P.GetWeakestAllyHero(allies)
	local EnemiesAroundAlly
	local Radius = MagneticField:GetSpecialValueInt("radius")
	
	if bot:HasModifier("modifier_arc_warden_tempest_double") then
		local AlliesWithinRadius = bot:GetNearbyHeroes(1200, false, BOT_MODE_NONE)
		local FilteredAllies = PAF.FilterTrueUnits(AlliesWithinRadius)
		
		for v, Ally in pairs(FilteredAllies) do
			if Ally ~= bot then
				if Ally:GetUnitName() == "npc_dota_hero_arc_warden" then
					if Ally:GetAbilityInSlot(1):IsFullyCastable() then
						return 0
					end
				end
			end
		end
	end
	
	if allytarget ~= nil then
		EnemiesAroundAlly = allytarget:GetNearbyHeroes(800, true, BOT_MODE_NONE)
	end
	
	if allytarget ~= nil and #EnemiesAroundAlly >= 1 and allytarget:GetHealth() < (allytarget:GetMaxHealth() * 0.4) 
	and not (allytarget:HasModifier("modifier_arc_warden_magnetic_field_evasion") and not allytarget:HasModifier("modifier_arc_warden_magnetic_field_attack_speed")) then
		return BOT_ACTION_DESIRE_HIGH, allytarget:GetLocation()
	end
	
	local enemies = bot:GetNearbyHeroes(AttackRange + 100, true, BOT_MODE_NONE)
	if (PAF.IsEngaging(bot) and #enemies >= 1) or P.IsRetreating(bot) 
	and not (bot:HasModifier("modifier_arc_warden_magnetic_field_evasion") and not bot:HasModifier("modifier_arc_warden_magnetic_field_attack_speed")) then
		
		if bot:HasModifier("modifier_arc_warden_tempest_double") then
			local AlliesWithinRadius = bot:GetNearbyHeroes(Radius, false, BOT_MODE_NONE)
			local FilteredAllies = PAF.FilterTrueUnits(AlliesWithinRadius)
			local ShouldCast = true
			
			for v, Ally in pairs(FilteredAllies) do
				if Ally ~= bot then
					if Ally:GetUnitName() == "npc_dota_hero_arc_warden" then
						if Ally:GetAbilityInSlot(1):IsFullyCastable() then
							ShouldCast = false
						end
					end
				end
			end
			
			if ShouldCast then
				return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()
			end
		else
			return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()
		end
		
	end
	
	local attacktarget = bot:GetAttackTarget()
	
	if attacktarget ~= nil then
		if attacktarget:IsBuilding()
		and not (bot:HasModifier("modifier_arc_warden_magnetic_field_evasion") and not bot:HasModifier("modifier_arc_warden_magnetic_field_attack_speed")) then
			return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()
		end
		
		if PAF.IsTormentor(AttackTarget) then
			return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_FARM then
		local neutrals = bot:GetNearbyNeutralCreeps(AttackRange)
		
		if #neutrals >= 2 and (bot:GetMana() - MagneticField:GetManaCost()) > manathreshold
		and not (bot:HasModifier("modifier_arc_warden_magnetic_field_evasion") and not bot:HasModifier("modifier_arc_warden_magnetic_field_attack_speed")) then
			return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()
		end
	end
	
	return 0
end

function UseSparkWraith()
	if not SparkWraith:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = 1600
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterUnitsForStun(EnemiesWithinRange)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange then
				return BOT_ACTION_DESIRE_HIGH, BotTarget:GetExtrapolatedLocation(2)
			end
		end
	end
	
	if P.IsInLaningPhase() then
		for v, enemy in pairs(FilteredEnemies) do
			local NearbyCreeps = enemy:GetNearbyCreeps(375, false)
			
			if PAF.IsValidHeroTarget(enemy) and #NearbyCreeps <= 0 then
				return BOT_ACTION_DESIRE_HIGH, enemy:GetLocation()
			end
		end
	end
	
	if P.IsRetreating(bot) then
		if #EnemiesWithinRange > 0 then
			return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()
		end
	end
	
	local AttackTarget = bot:GetAttackTarget()
	
	if AttackTarget ~= nil then
		if bot:GetActiveMode() == BOT_MODE_ROSHAN then
			if PAF.IsRoshan(AttackTarget)
			and GetUnitToUnitDistance(bot, AttackTarget) <= CastRange then
				return BOT_ACTION_DESIRE_VERYHIGH, AttackTarget:GetLocation()
			end
		end
		
		if PAF.IsTormentor(AttackTarget) then
			return BOT_ACTION_DESIRE_HIGH, AttackTarget:GetLocation()
		end
	end
	
	return 0
end

function UseTempestDouble()
	if not TempestDouble:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()
		end
	end
	
	if not P.IsInLaningPhase() then
		local AttackTarget = bot:GetAttackTarget()
		
		if AttackTarget ~= nil and AttackTarget:IsBuilding() then
			return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()
		end
	end
	
	local AttackTarget = bot:GetAttackTarget()
	
	if AttackTarget ~= nil then
		if bot:GetActiveMode() == BOT_MODE_ROSHAN then
			if PAF.IsRoshan(AttackTarget)
			and GetUnitToUnitDistance(bot, AttackTarget) <= CastRange then
				return BOT_ACTION_DESIRE_VERYHIGH, bot:GetLocation()
			end
		end
		
		if PAF.IsTormentor(AttackTarget) then
			return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()
		end
	end
	
	return 0
end