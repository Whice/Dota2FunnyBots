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

local DarkPact = bot:GetAbilityByName("slark_dark_pact")
local Pounce = bot:GetAbilityByName("slark_pounce")
local EssenceShift = bot:GetAbilityByName("slark_essence_shift")
local DepthShroud = bot:GetAbilityByName("slark_depth_shroud")
local ShadowDance = bot:GetAbilityByName("slark_shadow_dance")

local DarkPactDesire = 0
local PounceDesire = 0
local DepthShroudDesire = 0
local ShadowDanceDesire = 0

local AttackRange
local BotTarget
local manathreshold = 0

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	manathreshold = (bot:GetMaxMana() * 0.4)
	
	-- The order to use abilities in
	ShadowDanceDesire = UseShadowDance()
	if ShadowDanceDesire > 0 then
		bot:Action_UseAbility(ShadowDance)
		return
	end
	
	DepthShroudDesire, DepthShroudTarget = UseDepthShroud()
	if DepthShroudDesire > 0 then
		bot:Action_UseAbilityOnLocation(DepthShroud, DepthShroudTarget)
		return
	end
	
	PounceDesire = UsePounce()
	if PounceDesire > 0 then
		bot:Action_UseAbility(Pounce)
		return
	end
	
	DarkPactDesire = UseDarkPact()
	if DarkPactDesire > 0 then
		bot:Action_UseAbility(DarkPact)
		return
	end
end

function UseDarkPact()
	if not DarkPact:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = DarkPact:GetSpecialValueInt("radius")
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget) then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end
	
	local AttackTarget = bot:GetAttackTarget()
	
	if not P.IsInLaningPhase() and AttackTarget ~= nil then
		local creeps = bot:GetNearbyCreeps(CastRange, true)
		
		if AttackTarget:IsCreep()
		and #creeps >= 2
		and (bot:GetMana() - DarkPact:GetManaCost()) > manathreshold then
			return BOT_ACTION_DESIRE_VERYHIGH
		end
	
		if PAF.IsRoshan(AttackTarget) then
			return BOT_ACTION_DESIRE_VERYHIGH
		end
	end
	
	return 0
end

function UsePounce()
	if not Pounce:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = Pounce:GetSpecialValueInt("pounce_distance")
	local Radius = Pounce:GetSpecialValueInt("leash_radius")
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if bot:IsFacingLocation(BotTarget:GetLocation(), 10)
			and GetUnitToUnitDistance(bot, BotTarget) < (CastRange + Radius)
			and not PAF.IsMagicImmune(BotTarget) then
				return BOT_ACTION_DESIRE_VERYHIGH
			end
		end
	end
	
	if P.IsRetreating(bot) then
		local EnemiesWithinRange = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
		local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
		
		if #FilteredEnemies > 0 then
			if bot:IsFacingLocation(PAF.GetFountainLocation(bot), 20) then
				return BOT_ACTION_DESIRE_VERYHIGH
			end
		end
	end
	
	return 0
end

function UseShadowDance()
	if not ShadowDance:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	if P.IsRetreating(bot) then
		return BOT_ACTION_DESIRE_VERYHIGH
	end
	
	return 0
end
function UseDepthShroud()
	if not DepthShroud:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = DepthShroud:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local AlliesWithinRange = bot:GetNearbyHeroes(CastRange, false, BOT_MODE_NONE)
	local FilteredAllies = PAF.FilterTrueUnits(AlliesWithinRange)
	
	for v, Ally in pairs(FilteredAllies) do
		if Ally:GetHealth() <= (Ally:GetMaxHealth() * 0.4) and Ally:WasRecentlyDamagedByAnyHero(2) then
			return BOT_ACTION_DESIRE_ABSOLUTE, Ally:GetLocation()
		end
	end
	
	return 0
end