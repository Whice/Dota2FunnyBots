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

local SplitEarth = bot:GetAbilityByName("leshrac_split_earth")
local DiabolicEdict = bot:GetAbilityByName("leshrac_diabolic_edict")
local LightningStorm = bot:GetAbilityByName("leshrac_lightning_storm")
local PulseNova = bot:GetAbilityByName("leshrac_pulse_nova")
local Nihilism = bot:GetAbilityByName("leshrac_greater_lightning_storm")

local SplitEarthDesire = 0
local DiabolicEdictDesire = 0
local LightningStormDesire = 0
local PulseNovaDesire = 0
local NihilismDesire = 0

local AttackRange
local BotTarget
local AttackRange = 0

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	-- The order to use abilities in
	SplitEarthDesire, SplitEarthTarget = UseSplitEarth()
	if SplitEarthDesire > 0 then
		bot:Action_UseAbilityOnLocation(SplitEarth, SplitEarthTarget)
		return
	end
	
	NihilismDesire = UseNihilism()
	if NihilismDesire > 0 then
		bot:Action_UseAbility(Nihilism)
		return
	end
	
	PulseNovaDesire = UsePulseNova()
	if PulseNovaDesire > 0 then
		bot:Action_UseAbility(PulseNova)
		return
	end
	
	LightningStormDesire, LightningStormTarget = UseLightningStorm()
	if LightningStormDesire > 0 then
		bot:Action_UseAbilityOnEntity(LightningStorm, LightningStormTarget)
		return
	end
	
	DiabolicEdictDesire = UseDiabolicEdict()
	if DiabolicEdictDesire > 0 then
		bot:Action_UseAbility(DiabolicEdict)
		return
	end
end

function UseSplitEarth()
	if not SplitEarth:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = SplitEarth:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	local CastPoint = SplitEarth:GetCastPoint()
	local SplitEarthDelay = SplitEarth:GetSpecialValueInt("delay")
	local ExtrapLoc = (CastPoint + SplitEarthDelay)
	
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
			and (BotTarget:HasModifier("modifier_leshrac_lightning_storm_slow") or PAF.IsDisabled(BotTarget)) then
				if GetUnitToLocationDistance(bot, BotTarget:GetExtrapolatedLocation(ExtrapLoc)) > CastRange then
					return BOT_ACTION_DESIRE_HIGH, bot:GetXUnitsTowardsLocation(BotTarget:GetExtrapolatedLocation(ExtrapLoc), CastRange)
				else
					return BOT_ACTION_DESIRE_HIGH, BotTarget:GetExtrapolatedLocation(ExtrapLoc)
				end
			end
		end
	end
	
	if P.IsRetreating(bot) and #EnemiesWithinRange > 0 then
		local ClosestTarget = PAF.GetClosestUnit(bot, EnemiesWithinRange)
		return BOT_ACTION_DESIRE_HIGH, ClosestTarget:GetExtrapolatedLocation(ExtrapLoc)
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

function UseDiabolicEdict()
	if not DiabolicEdict:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = DiabolicEdict:GetSpecialValueInt("radius")
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end
	
	local AttackTarget = bot:GetAttackTarget()
	
	if AttackTarget:IsBuilding()
	and AttackTarget:GetTeam() ~= bot:GetTeam() then
		if GetUnitToUnitDistance(bot, AttackTarget) <= CastRange then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	return 0
end

function UseLightningStorm()
	if not LightningStorm:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = LightningStorm:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	local Damage = LightningStorm:GetSpecialValueInt("damage")
	local JumpRadius = LightningStorm:GetSpecialValueInt("radius")
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget) then
				return BOT_ACTION_DESIRE_HIGH, BotTarget
			end
		end
	end
	
	if P.IsRetreating(bot) and #EnemiesWithinRange > 0 then
		local ClosestTarget = PAF.GetClosestUnit(bot, EnemiesWithinRange)
		return BOT_ACTION_DESIRE_HIGH, ClosestTarget
	end
	
	local AttackTarget = bot:GetAttackTarget()
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		if PAF.IsRoshan(AttackTarget)
		and GetUnitToUnitDistance(bot, AttackTarget) <= CastRange then
			return BOT_ACTION_DESIRE_VERYHIGH, AttackTarget
		end
	end
	
	if P.IsInLaningPhase() and bot:GetActiveMode() == BOT_MODE_LANING then
		local NearbyCreeps = bot:GetNearbyLaneCreeps(CastRange, true)
		
		for v, Creep in pairs(NearbyCreeps) do
			if string.find(Creep:GetUnitName(), "ranged") then
				local EstimatedDamage = Creep:GetActualIncomingDamage(Damage, DAMAGE_TYPE_MAGICAL)
				
				local EnemiesWithinJumpRange = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
				local FilteredJumpEnemies = PAF.FilterTrueUnits(EnemiesWithinJumpRange)
				
				local EnemyNearCreep = false
				for x, Enemy in pairs(FilteredJumpEnemies) do
					if GetUnitToUnitDistance(Creep, Enemy) <= JumpRadius then
						EnemyNearCreep = true
						break
					end
				end
				
				if EnemyNearCreep and EstimatedDamage >= Creep:GetHealth() then
					return BOT_ACTION_DESIRE_HIGH, Creep
				end
			end
		end
	end
	
	return 0
end

function UsePulseNova()
	if not PulseNova:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = PulseNova:GetSpecialValueInt("radius")
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	local NearbyCreeps = bot:GetNearbyCreeps(CastRange, true)
	
	if (PAF.IsEngaging(bot) and #FilteredEnemies >= 1)
	or (bot:GetActiveMode() == BOT_MODE_FARM and #NearbyCreeps >= 2 and bot:GetMana() > (bot:GetMaxMana() * 0.5)) then
		if PulseNova:GetToggleState() == false then
			return BOT_ACTION_DESIRE_HIGH
		else
			return 0
		end
	else
		if PulseNova:GetToggleState() == true then
			return BOT_ACTION_DESIRE_HIGH
		else
			return 0
		end
	end
	
	return 0
end

function UseNihilism()
	if not Nihilism:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = Nihilism:GetSpecialValueInt("radius")
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	
	if P.IsRetreating(bot) and #EnemiesWithinRange > 0 then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	return 0
end