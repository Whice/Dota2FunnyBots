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

local ShurikenToss = bot:GetAbilityByName("bounty_hunter_shuriken_toss")
local Jinada = bot:GetAbilityByName("bounty_hunter_jinada")
local ShadowWalk = bot:GetAbilityByName("bounty_hunter_wind_walk")
local Track = bot:GetAbilityByName("bounty_hunter_track")
local FriendlyShadow = bot:GetAbilityByName("bounty_hunter_wind_walk_ally")

local ShurikenTossDesire = 0
local JinadaDesire = 0
local ShadowWalkDesire = 0
local TrackDesire = 0
local FriendlyShadowDesire = 0

local AttackRange
local BotTarget

local DebugTime = 0

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	-- The order to use abilities in
	TrackDesire, TrackTarget = UseTrack()
	if TrackDesire > 0 then
		bot:Action_UseAbilityOnEntity(Track, TrackTarget)
		return
	end
	
	ShadowWalkDesire = UseShadowWalk()
	if ShadowWalkDesire > 0 then
		bot:Action_UseAbility(ShadowWalk)
		return
	end
	
	FriendlyShadowDesire, FriendlyShadowTarget = UseFriendlyShadow()
	if FriendlyShadowDesire > 0 then
		bot:Action_UseAbilityOnEntity(FriendlyShadow, FriendlyShadowTarget)
		return
	end
	
	JinadaDesire, JinadaTarget = UseJinada()
	if JinadaDesire > 0 then
		bot:Action_UseAbilityOnEntity(Jinada, JinadaTarget)
		return
	end
	
	ShurikenTossDesire, ShurikenTossTarget = UseShurikenToss()
	if ShurikenTossDesire > 0 then
		bot:Action_UseAbilityOnEntity(ShurikenToss, ShurikenTossTarget)
		return
	end
end

function UseShurikenToss()
	if not ShurikenToss:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	if bot:HasModifier("modifier_bounty_hunter_wind_walk") then return 0 end
	
	local CR = ShurikenToss:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget) then
				return BOT_ACTION_DESIRE_HIGH, BotTarget
			end
		end
	end
	
	local AttackTarget = bot:GetAttackTarget()
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		if AttackTarget ~= nil and PAF.IsRoshan(AttackTarget) then
			return BOT_ACTION_DESIRE_HIGH, AttackTarget
		end
	end
	
	return 0
end

function UseJinada()
	if not Jinada:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	if Jinada:GetAutoCastState() == true then
		Jinada:ToggleAutoCast()
	end
	
	local LaneRange = 350
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= 350 then
				return BOT_ACTION_DESIRE_HIGH, BotTarget
			end
		end
	end
	
	if P.IsInLaningPhase() then
		local EnemiesWithinRange = bot:GetNearbyHeroes(LaneRange, true, BOT_MODE_NONE)
		local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
		
		local WeakestUnit = PAF.GetWeakestUnit(FilteredEnemies)
		
		if WeakestUnit ~= nil then
			return BOT_ACTION_DESIRE_HIGH, WeakestUnit
		end
	end
	
	return 0
end

function UseShadowWalk()
	if not ShadowWalk:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local ModifierIndex = bot:GetModifierByName("modifier_bounty_hunter_wind_walk")
	local Cooldown = ShadowWalk:GetSpecialValueInt("AbilityCooldown")
	
	if PAF.IsEngaging(bot) or P.IsRetreating(bot) then
		if bot:HasModifier("modifier_bounty_hunter_wind_walk")
		and bot:GetModifierRemainingDuration(ModifierIndex) <= Cooldown then
			return BOT_ACTION_DESIRE_HIGH
		elseif not bot:HasModifier("modifier_bounty_hunter_wind_walk") then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	return 0
end

function UseTrack()
	if not Track:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = Track:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	if not P.IsRetreating(bot) then
		local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
		local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
		
		for v, Enemy in pairs(FilteredEnemies) do
			if not Enemy:HasModifier("modifier_bounty_hunter_track_effect") then
				return BOT_ACTION_DESIRE_HIGH, Enemy
			end
		end
	end
	
	return 0
end

function UseFriendlyShadow()
	if not FriendlyShadow:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = FriendlyShadow:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local AlliesWithinRange = bot:GetNearbyHeroes(CastRange, false, BOT_MODE_NONE)
	local FilteredAllies = PAF.FilterTrueUnits(AlliesWithinRange)
	
	for v, Ally in pairs(FilteredAllies) do
		if bot ~= Ally then
			if Ally:GetHealth() <= (Ally:GetMaxHealth() * 0.35) and Ally:WasRecentlyDamagedByAnyHero(2) then
				return BOT_ACTION_DESIRE_ABSOLUTE, Ally
			end
		end
	end
	
	return 0
end