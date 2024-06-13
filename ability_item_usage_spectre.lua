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

local SpectralDagger = bot:GetAbilityByName("spectre_spectral_dagger")
local Desolate = bot:GetAbilityByName("spectre_desolate")
local Dispersion = bot:GetAbilityByName("spectre_dispersion")
local Haunt = bot:GetAbilityByName("spectre_haunt")
local ShadowStep = bot:GetAbilityByName("spectre_haunt_single")
local Reality = bot:GetAbilityByName("spectre_reality")

local SpectralDaggerDesire = 0
local DispersionDesire = 0
local HauntDesire = 0
local ShadowStepDesire = 0
local RealityDesire = 0

local AttackRange
local BotTarget

local HauntDuration
local HauntTime = 0
local ShadowStepTime = 0
local StepTarget = nil

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	HauntDuration = Haunt:GetSpecialValueFloat("duration")
	
	-- The order to use abilities in
	DispersionDesire = UseDispersion()
	if DispersionDesire > 0 then
		bot:Action_UseAbility(Dispersion)
		return
	end
	
	RealityDesire, RealityTarget = UseReality()
	if RealityDesire > 0 then
		bot:Action_UseAbilityOnLocation(Reality, RealityTarget)
		return
	end
	
	if bot:HasScepter() then
		HauntDesire = UseHaunt()
		if HauntDesire > 0 then
			bot:Action_UseAbility(Haunt)
			HauntTime = DotaTime()
			return
		end
	end
	
	ShadowStepDesire, ShadowStepTarget = UseShadowStep()
	if ShadowStepDesire > 0 then
		bot:Action_UseAbilityOnEntity(ShadowStep, ShadowStepTarget)
		ShadowStepTime = DotaTime()
		StepTarget = ShadowStepTarget
		return
	end
	
	SpectralDaggerDesire, SpectralDaggerTarget = UseSpectralDagger()
	if SpectralDaggerDesire > 0 then
		bot:Action_UseAbilityOnEntity(SpectralDagger, SpectralDaggerTarget)
		return
	end
end

function UseSpectralDagger()
	if not SpectralDagger:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = SpectralDagger:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange then
				return BOT_ACTION_DESIRE_HIGH, BotTarget
			end
		end
	end
	
	return 0
end

function UseDispersion()
	if Dispersion:IsPassive() then return 0 end
	if not Dispersion:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	if (PAF.IsEngaging(bot) or P.IsRetreating(bot)) and bot:WasRecentlyDamagedByAnyHero(2) then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	return 0
end

function UseHaunt()
	if not Haunt:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	if P.IsInLaningPhase() then return 0 end
	
	local allies = GetUnitList(UNIT_LIST_ALLIED_HEROES)
	local FilteredAllies = PAF.FilterTrueUnits(allies)
	
	for v, ally in pairs(FilteredAllies) do
		if PAF.IsInTeamFight(ally) then
			local enemies = ally:GetNearbyHeroes(1000, true, BOT_MODE_NONE)
			local FilteredEnemies = PAF.FilterTrueUnits(enemies)
			local target = PAF.GetWeakestUnit(enemies)
			
			if target ~= nil and not P.IsRetreating(bot) and not PAF.IsEngaging(bot) and GetUnitToUnitDistance(bot, target) > 1600 then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end
	
	return 0
end

function UseShadowStep()
	if not ShadowStep:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	if P.IsInLaningPhase() then return 0 end
	
	local allies = GetUnitList(UNIT_LIST_ALLIED_HEROES)
	local FilteredAllies = PAF.FilterTrueUnits(allies)
	
	for v, ally in pairs(FilteredAllies) do
		if PAF.IsInTeamFight(ally) then
			local enemies = ally:GetNearbyHeroes(1000, true, BOT_MODE_NONE)
			local FilteredEnemies = PAF.FilterTrueUnits(enemies)
			local target = PAF.GetWeakestUnit(enemies)
			
			if target ~= nil
			and not P.IsRetreating(bot)
			and not PAF.IsEngaging(bot)
			and GetUnitToUnitDistance(bot, target) > 1600
			and not Haunt:IsFullyCastable() then
				return BOT_ACTION_DESIRE_HIGH, target
			end
		end
	end
	
	if PAF.IsEngaging(bot) then
		if GetUnitToUnitDistance(bot, BotTarget) > 1000 then
			return BOT_ACTION_DESIRE_HIGH, BotTarget
		end
	end
	
	return 0
end

function UseReality()
	if not Reality:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	if (DotaTime() - HauntTime) < HauntDuration then
		local allies = GetUnitList(UNIT_LIST_ALLIED_HEROES)
		local FilteredAllies = PAF.FilterTrueUnits(allies)
		
		for v, ally in pairs(FilteredAllies) do
			if PAF.IsInTeamFight(ally) then
				local enemies = ally:GetNearbyHeroes(1000, true, BOT_MODE_NONE)
				local FilteredEnemies = PAF.FilterTrueUnits(enemies)
				local target = PAF.GetWeakestUnit(enemies)
				
				if target ~= nil and not P.IsRetreating(bot) and not PAF.IsEngaging(bot) and GetUnitToUnitDistance(bot, target) > 1600 then
					return BOT_ACTION_DESIRE_HIGH, target:GetLocation()
				end
			end
		end
	end
	
	if not bot:HasScepter() then
		HauntTime = 0
	end
	
	if (DotaTime() - ShadowStepTime) < HauntDuration then
		if StepTarget ~= nil and GetUnitToUnitDistance(bot, StepTarget) > 1000 then
			return BOT_ACTION_DESIRE_HIGH, StepTarget:GetLocation()
		end
	end
	
	return 0
end