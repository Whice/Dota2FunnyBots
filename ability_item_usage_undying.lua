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

local Decay = bot:GetAbilityByName("undying_decay")
local SoulRip = bot:GetAbilityByName("undying_soul_rip")
local Tombstone = bot:GetAbilityByName("undying_tombstone")
local FleshGolem = bot:GetAbilityByName("undying_flesh_golem")

local DecayDesire = 0
local SoulRipDesire = 0
local TombstoneDesire = 0
local FleshGolemDesire = 0

local AttackRange
local BotTarget

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	-- The order to use abilities in
	FleshGolemDesire = UseFleshGolem()
	if FleshGolemDesire > 0 then
		bot:Action_UseAbility(FleshGolem)
		return
	end
	
	TombstoneDesire, TombstoneTarget = UseTombstone()
	if TombstoneDesire > 0 then
		bot:Action_UseAbilityOnLocation(Tombstone, TombstoneTarget)
		return
	end
	
	SoulRipDesire, SoulRipTarget = UseSoulRip()
	if SoulRipDesire > 0 then
		bot:Action_UseAbilityOnEntity(SoulRip, SoulRipTarget)
		return
	end
	
	DecayDesire, DecayTarget = UseDecay()
	if DecayDesire > 0 then
		bot:Action_UseAbilityOnLocation(Decay, DecayTarget)
		return
	end
end

function UseDecay()
	if not Decay:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = Decay:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	local Radius = Decay:GetSpecialValueInt("radius")
	
	if P.IsInLaningPhase() then
		local AoE = bot:FindAoELocation(true, true, bot:GetLocation(), CastRange, Radius/2, 0, 0)
		if (AoE.count >= 2) then
			return BOT_ACTION_DESIRE_HIGH, AoE.targetloc
		end
	end
	
	if PAF.IsEngaging(bot) then
		local AoE = bot:FindAoELocation(true, true, bot:GetLocation(), CastRange, Radius/2, 0, 0)
		if (AoE.count >= 1) then
			return BOT_ACTION_DESIRE_HIGH, AoE.targetloc
		end
	end
	
	return 0
end

function UseSoulRip()
	if not SoulRip:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = SoulRip:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local allies = bot:GetNearbyHeroes(CastRange + 200, false, BOT_MODE_NONE)
	local target = P.GetWeakestAllyHero(allies)
	
	if target ~= nil then
		return BOT_ACTION_DESIRE_HIGH, target
	end
	
	if P.IsRetreating(bot) then
		return BOT_ACTION_DESIRE_HIGH, bot
	end
	
	return 0
end

function UseTombstone()
	if not Tombstone:IsFullyCastable() then return 0 end
	if not PAF.IsInTeamFight(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = Tombstone:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	if PAF.IsValidHeroAndNotIllusion(BotTarget) then
		if GetUnitToUnitDistance(bot, BotTarget) <= CastRange then
			return BOT_ACTION_DESIRE_HIGH, BotTarget:GetLocation()
		end
	end
	
	return 0
end

function UseFleshGolem()
	if not FleshGolem:IsFullyCastable() then return 0 end
	if not PAF.IsInTeamFight(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	return BOT_ACTION_DESIRE_HIGH
end