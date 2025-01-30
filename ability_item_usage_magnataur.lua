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

local ShockWave = bot:GetAbilityByName("magnataur_shockwave")
local Empower = bot:GetAbilityByName("magnataur_empower")
local Skewer = bot:GetAbilityByName("magnataur_skewer")
local ReversePolarity = bot:GetAbilityByName("magnataur_reverse_polarity")
local HornToss = bot:GetAbilityByName("magnataur_horn_toss")

local ShockWaveDesire = 0
local EmpowerDesire = 0
local SkewerDesire = 0
local ReversePolarityDesire = 0
local HornTossDesire = 0

local AttackRange
local BotTarget

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	-- The order to use abilities in
	ReversePolarityDesire = UseReversePolarity()
	if ReversePolarityDesire > 0 then
		bot:Action_UseAbility(ReversePolarity)
		return
	end
	
	SkewerDesire, SkewerTarget = UseSkewer()
	if SkewerDesire > 0 then
		bot:Action_UseAbilityOnLocation(Skewer, SkewerTarget)
		return
	end
	
	HornTossDesire = UseHornToss()
	if HornTossDesire > 0 then
		bot:Action_UseAbility(HornToss)
		return
	end
	
	ShockWaveDesire, ShockWaveTarget = UseShockWave()
	if ShockWaveDesire > 0 then
		bot:Action_UseAbilityOnLocation(ShockWave, ShockWaveTarget)
		return
	end
	
	EmpowerDesire, EmpowerTarget = UseEmpower()
	if EmpowerDesire > 0 then
		bot:Action_UseAbilityOnEntity(Empower, EmpowerTarget)
		return
	end
end

function UseShockWave()
	if not ShockWave:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = ShockWave:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	local Radius = ShockWave:GetSpecialValueInt("shock_width")
	local Damage = ShockWave:GetSpecialValueInt("shock_damage")
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange and not PAF.IsMagicImmune(BotTarget) then
				return BOT_ACTION_DESIRE_HIGH, BotTarget:GetLocation()
			end
		end
	end
	
	if P.IsInLaningPhase()
	and bot:GetActiveMode() == BOT_MODE_LANING then
		local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
		local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	
		for v, enemy in pairs(FilteredEnemies) do
			if PAF.CanLastHitCreepAndHarass(bot, enemy, Radius, Damage, DAMAGE_TYPE_MAGICAL) then
				return BOT_ACTION_DESIRE_HIGH, enemy:GetLocation()
			end
		end
	end
	
	local AttackTarget = bot:GetAttackTarget()

	if bot:GetActiveMode() == BOT_MODE_FARM
	or bot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP
	or bot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID
	or bot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT then
		if AttackTarget ~= nil 
		and AttackTarget:IsCreep()
		and not bot:HasModifier("modifier_magnataur_empower") then
			local NearbyCreeps = bot:GetNearbyCreeps(CastRange, true)
			local AoECount = PAF.GetUnitsNearTarget(AttackTarget:GetLocation(), NearbyCreeps, Radius)
			
			if AoECount >= 3
			and (bot:GetMana() - ShockWave:GetManaCost()) > (bot:GetMaxMana() * 0.5) then
				return BOT_ACTION_DESIRE_HIGH, AttackTarget:GetLocation()
			end
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		if AttackTarget ~= nil and PAF.IsRoshan(AttackTarget) then
			return BOT_ACTION_DESIRE_HIGH, AttackTarget:GetLocation()
		end
	end
	
	return 0
end

function UseEmpower()
	if not Empower:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = Empower:GetCastRange()
	local Cooldown = Empower:GetSpecialValueInt("AbilityCooldown")
	
	if not PAF.IsEngaging(bot)
	and bot:GetActiveMode() ~= BOT_MODE_FARM then
		return 0
	end
	
	if not bot:HasModifier("modifier_magnataur_empower") then
		return BOT_ACTION_DESIRE_HIGH, bot
	end
	
	if bot:HasModifier("modifier_magnataur_empower") then
		local mIndex = bot:GetModifierByName("modifier_magnataur_empower")
		if bot:GetModifierRemainingDuration(mIndex) <= Cooldown then
			return BOT_ACTION_DESIRE_HIGH, bot
		end
	end
	
	local allies = bot:GetNearbyHeroes(CastRange + 300, false, BOT_MODE_NONE)
	local filteredallies = {}
	
	for v, ally in pairs(allies) do
		if not ally:HasModifier("modifier_magnataur_empower")
		and not PAF.IsPossibleIllusion(ally)
		and ally:GetAttackDamage() >= bot:GetAttackDamage() then
			table.insert(filteredallies, ally)
		end
	end
	
	local target = PAF.GetStrongestAttackDamageUnit(filteredallies)
	
	if target ~= nil then
		return BOT_ACTION_DESIRE_HIGH, target
	end
	
	return 0
end

function UseSkewer()
	if not Skewer:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = Skewer:GetSpecialValueInt("range")
	local Radius = Skewer:GetSpecialValueInt("skewer_radius")
	local Fountain = PAF.GetFountainLocation(bot)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange and not PAF.IsMagicImmune(BotTarget) then
				local PointLine = PointToLineDistance(bot:GetLocation(), Fountain, BotTarget:GetLocation())
				
				if PointLine ~= nil then
					if PointLine.within == true
					and PointLine.distance <= (Radius - 50)
					and GetUnitToLocationDistance(bot, Fountain) > GetUnitToLocationDistance(BotTarget, Fountain) then
						return BOT_ACTION_DESIRE_HIGH, PAF.GetXUnitsTowardsLocation(bot:GetLocation(), Fountain, CastRange)
					end
				end
			end
		end
	end
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	
	if P.IsRetreating(bot) then
		return BOT_ACTION_DESIRE_HIGH, PAF.GetXUnitsTowardsLocation(bot:GetLocation(), Fountain, CastRange)
	end
	
	return 0
end

function UseReversePolarity()
	if not ReversePolarity:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local Radius = ReversePolarity:GetSpecialValueInt("pull_radius")
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(Radius, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	
	if PAF.IsInTeamFight(bot) then
		if #FilteredEnemies >= 2 then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	return 0
end

function UseHornToss()
	if not HornToss:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = HornToss:GetSpecialValueInt("radius")
	local CastRange = PAF.GetProperCastRange(CR)
	local Fountain = PAF.GetFountainLocation(bot)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange and not PAF.IsMagicImmune(BotTarget) then
				if not bot:IsFacingLocation(Fountain, 135)
				and bot:IsFacingLocation(BotTarget:GetLocation(), 10)
				and GetUnitToLocationDistance(bot, Fountain) < GetUnitToLocationDistance(BotTarget, Fountain) then
					return BOT_ACTION_DESIRE_HIGH
				end
			end
		end
	end
	
	return 0
end