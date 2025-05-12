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

local DualBreath = bot:GetAbilityByName("jakiro_dual_breath")
local IcePath = bot:GetAbilityByName("jakiro_ice_path")
local LiquidFire = bot:GetAbilityByName("jakiro_liquid_fire")
local Macropyre = bot:GetAbilityByName("jakiro_macropyre")
local LiquidIce = bot:GetAbilityByName("jakiro_liquid_ice")

local DualBreathDesire = 0
local IcePathDesire = 0
local LiquidFireDesire = 0
local LiquidIceDesire = 0
local MacropyreDesire = 0
local LiquidIceDesire = 0

local AttackRange
local BotTarget

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	-- The order to use abilities in
	MacropyreDesire, MacropyreTarget = UseMacropyre()
	if MacropyreDesire > 0 then
		bot:Action_UseAbilityOnLocation(Macropyre, MacropyreTarget)
		return
	end
	
	IcePathDesire, IcePathTarget = UseIcePath()
	if IcePathDesire > 0 then
		bot:Action_UseAbilityOnLocation(IcePath, IcePathTarget)
		return
	end
	
	DualBreathDesire, DualBreathTarget = UseDualBreath()
	if DualBreathDesire > 0 then
		bot:Action_UseAbilityOnLocation(DualBreath, DualBreathTarget)
		return
	end
	
	LiquidIceDesire, LiquidIceTarget = UseLiquidIce()
	if LiquidIceDesire > 0 then
		bot:Action_UseAbilityOnEntity(LiquidIce, LiquidIceTarget)
		return
	end
	
	LiquidFireDesire, LiquidFireTarget = UseLiquidFire()
	if LiquidFireDesire > 0 then
		bot:Action_UseAbilityOnEntity(LiquidFire, LiquidFireTarget)
		return
	end
end

function UseDualBreath()
	if not DualBreath:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = DualBreath:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget) then
				return BOT_ACTION_DESIRE_HIGH, BotTarget:GetLocation()
			end
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

function UseIcePath()
	if not IcePath:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = IcePath:GetCastRange()
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
				if GetUnitToLocationDistance(bot, BotTarget:GetExtrapolatedLocation(2)) > CastRange then
					return BOT_ACTION_DESIRE_HIGH, PAF.GetXUnitsTowardsLocation(bot:GetLocation(), BotTarget:GetExtrapolatedLocation(2), CastRange)
				else
					return BOT_ACTION_DESIRE_HIGH, BotTarget:GetExtrapolatedLocation(2)
				end
			end
		end
	end
	
	if P.IsRetreating(bot) and #EnemiesWithinRange > 0 then
		local ClosestTarget = PAF.GetClosestUnit(bot, EnemiesWithinRange)
		return BOT_ACTION_DESIRE_HIGH, ClosestTarget:GetLocation()
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

function UseLiquidFire()
	if not LiquidFire:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local AttackTarget = bot:GetAttackTarget()
	
	if AttackTarget ~= nil then
		if AttackTarget:IsHero()
		or AttackTarget:IsBuilding()
		or PAF.IsRoshan(AttackTarget)
		or PAF.IsTormentor(AttackTarget) then
			if LiquidFire:GetAutoCastState() == false then
				LiquidFire:ToggleAutoCast()
				return 0
			else
				return 0
			end
		end
	end
	
	if LiquidFire:GetAutoCastState() == true then
		LiquidFire:ToggleAutoCast()
		return 0
	end
	
	return 0
end

function UseMacropyre()
	if not Macropyre:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = Macropyre:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	if PAF.IsInTeamFight(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget) then
				return BOT_ACTION_DESIRE_HIGH, BotTarget:GetLocation()
			end
		end
	end
	
	return 0
end

function UseLiquidIce()
	if not LiquidIce:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local AttackTarget = bot:GetAttackTarget()
	
	if AttackTarget ~= nil then
		if AttackTarget:IsHero()
		or AttackTarget:IsBuilding()
		or PAF.IsRoshan(AttackTarget)
		or PAF.IsTormentor(AttackTarget) then
			if LiquidIce:GetAutoCastState() == false then
				LiquidIce:ToggleAutoCast()
				return 0
			else
				return 0
			end
		end
	end
	
	if LiquidIce:GetAutoCastState() == true then
		LiquidIce:ToggleAutoCast()
		return 0
	end
end