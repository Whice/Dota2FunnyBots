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

local Purification = bot:GetAbilityByName("omniknight_purification")
local HeavenlyGrace = bot:GetAbilityByName("omniknight_martyr")
local HammerOfPurity = bot:GetAbilityByName("omniknight_hammer_of_purity")
local GuardianAngel = bot:GetAbilityByName("omniknight_guardian_angel")

local PurificationDesire = 0
local HeavenlyGraceDesire = 0
local HammerOfPurityDesire = 0
local GuardianAngelDesire = 0

local AttackRange
local BotTarget

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	-- The order to use abilities in
	GuardianAngelDesire, GuardianAngelTarget = UseGuardianAngel()
	if GuardianAngelDesire > 0 then
		bot:Action_UseAbilityOnEntity(GuardianAngel, GuardianAngelTarget)
		return
	end
	
	HeavenlyGraceDesire, HeavenlyGraceTarget = UseHeavenlyGrace()
	if HeavenlyGraceDesire > 0 then
		bot:Action_UseAbilityOnEntity(HeavenlyGrace, HeavenlyGraceTarget)
		return
	end
	
	PurificationDesire, PurificationTarget = UsePurification()
	if PurificationDesire > 0 then
		bot:Action_UseAbilityOnEntity(Purification, PurificationTarget)
		return
	end
	
	HammerOfPurityDesire, HammerOfPurityTarget = UseHammerOfPurity()
	if HammerOfPurityDesire > 0 then
		bot:Action_UseAbilityOnEntity(HammerOfPurity, HammerOfPurityTarget)
		return
	end
end

function UsePurification()
	if not Purification:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = Purification:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	local DamageRadius = Purification:GetSpecialValueInt("radius")
	
	local AlliesWithinRange = bot:GetNearbyHeroes(CastRange, false, BOT_MODE_NONE)
	local FilteredAllies = PAF.FilterTrueUnits(AlliesWithinRange)
	
	local WeakestAlly = PAF.GetWeakestUnit(FilteredAllies)
	
	if WeakestAlly:GetHealth() < (WeakestAlly:GetMaxHealth() * 0.8) then
		return BOT_ACTION_DESIRE_HIGH, WeakestAlly
	end
	
	for v, Ally in pairs(FilteredAllies) do
		local EnemiesWithinRange = Ally:GetNearbyHeroes((DamageRadius - 50), true, BOT_MODE_NONE)
		local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
		
		if #FilteredEnemies > 0 then
			for v, Enemy in pairs(FilteredEnemies) do
				if not PAF.IsMagicImmune(Enemy) then
					return BOT_ACTION_DESIRE_HIGH, Ally
				end
			end
		end
	end
	
	return 0
end

function UseHeavenlyGrace()
	if not HeavenlyGrace:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = HeavenlyGrace:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local AlliesWithinRange = bot:GetNearbyHeroes(CastRange, false, BOT_MODE_NONE)
	local FilteredAllies = PAF.FilterTrueUnits(AlliesWithinRange)
	
	local WeakestAlly = PAF.GetWeakestUnit(FilteredAllies)
	
	if WeakestAlly:GetHealth() < (WeakestAlly:GetMaxHealth() * 0.65)
	and WeakestAlly:WasRecentlyDamagedByAnyHero(1) then
		return BOT_ACTION_DESIRE_HIGH, WeakestAlly
	end
	
	if PAF.IsInTeamFight(bot) then
		for v, Ally in pairs(FilteredAllies) do
			if PAF.IsDisabled(Ally)
			or PAF.IsTaunted(Ally)
			or PAF.IsSilencedOrMuted(Ally) then
				return BOT_ACTION_DESIRE_HIGH, Ally
			end
		end
	end
	
	return 0
end

function UseHammerOfPurity()
	if not HammerOfPurity:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = HammerOfPurity:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget) then
				return BOT_ACTION_DESIRE_HIGH, BotTarget
			end
		end
	end
	
	return 0
end

function UseGuardianAngel()
	if not GuardianAngel:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = GuardianAngel:GetCastRange()
	
	local AlliesWithinRange = bot:GetNearbyHeroes(CastRange, false, BOT_MODE_NONE)
	if bot:HasScepter() then
		AlliesWithinRange = GetUnitList(UNIT_LIST_ALLIED_HEROES)
	end
	
	local FilteredAllies = PAF.FilterTrueUnits(AlliesWithinRange)
	
	for v, Ally in pairs(FilteredAllies) do
		if Ally:GetHealth() <= (Ally:GetMaxHealth() * 0.5)
		and Ally:WasRecentlyDamagedByAnyHero(2)
		and not Ally:HasModifier("modifier_arc_warden_tempest_double")
		and not Ally:HasModifier("modifier_omninight_guardian_angel") then
			return BOT_ACTION_DESIRE_ABSOLUTE, Ally
		end
	end
	
	return 0
end