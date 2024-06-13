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

local HoofStomp = bot:GetAbilityByName("centaur_hoof_stomp")
local DoubleEdge = bot:GetAbilityByName("centaur_double_edge")
local Retaliate = bot:GetAbilityByName("centaur_return")
local Stampede = bot:GetAbilityByName("centaur_stampede")

local HoofStompDesire = 0
local DoubleEdgeDesire = 0
local StampedeDesire = 0

local AttackRange
local BotTarget
local manathreshold = 0

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	manathreshold = (bot:GetMaxMana() * 0.4)
	
	-- The order to use abilities in
	StampedeDesire = UseStampede()
	if StampedeDesire > 0 then
		bot:Action_UseAbility(Stampede)
		return
	end
	
	HoofStompDesire = UseHoofStomp()
	if HoofStompDesire > 0 then
		bot:Action_UseAbility(HoofStomp)
		return
	end
	
	DoubleEdgeDesire, DoubleEdgeTarget = UseDoubleEdge()
	if DoubleEdgeDesire > 0 then
		bot:Action_UseAbilityOnEntity(DoubleEdge, DoubleEdgeTarget)
		return
	end
end

function UseHoofStomp()
	if not HoofStomp:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local ManaCost = 0
	if HoofStomp:GetLevel() == 1 then
		ManaCost = 100
	elseif HoofStomp:GetLevel() == 2 then
		ManaCost = 110
	elseif HoofStomp:GetLevel() == 3 then
		ManaCost = 120
	elseif HoofStomp:GetLevel() == 4 then
		ManaCost = 130
	end
	if bot:GetMana() < ManaCost then return 0 end -- Fix weird Valve bug where Centaur can cast with not enough mana
	
	local CastRange = HoofStomp:GetSpecialValueInt("radius")
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterUnitsForStun(EnemiesWithinRange)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= (CastRange - 25)
			and not PAF.IsDisabled(BotTarget)
			and not PAF.IsMagicImmune(BotTarget) then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end
	
	if #FilteredEnemies >= 1 and P.IsRetreating(bot) then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	local AttackTarget = bot:GetAttackTarget()
	
	if AttackTarget ~= nil and not P.IsInLaningPhase() then
		if AttackTarget:IsCreep() then
			local CreepsWithinRange = bot:GetNearbyCreeps(CastRange, true)
			
			if #CreepsWithinRange >= 3 and (bot:GetMana() - HoofStomp:GetManaCost()) > manathreshold then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
		
		if bot:GetActiveMode() == BOT_MODE_ROSHAN and PAF.IsRoshan(AttackTarget) then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	return 0
end

function UseDoubleEdge()
	if not DoubleEdge:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = DoubleEdge:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	--local Radius = DoubleEdge:GetSpecialValueInt("radius")
	local Radius = 220
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget) then
				return BOT_ACTION_DESIRE_HIGH, BotTarget
			end
		end
	end
	
	local AttackTarget = bot:GetAttackTarget()
	
	if AttackTarget ~= nil and not P.IsInLaningPhase() then
		if AttackTarget:IsCreep() then
			local NearbyCreeps = bot:GetNearbyCreeps((CastRange + Radius), true)
			local AoECount = PAF.GetUnitsNearTarget(AttackTarget:GetLocation(), NearbyCreeps, Radius)
			
			if AoECount >= 3 and bot:GetHealth() > (bot:GetMaxHealth() * 0.55) then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
		
		if bot:GetActiveMode() == BOT_MODE_ROSHAN and PAF.IsRoshan(AttackTarget) then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		if AttackTarget ~= nil and PAF.IsRoshan(AttackTarget) then
			return BOT_ACTION_DESIRE_HIGH, AttackTarget
		end
	end
	
	return 0
end

function UseStampede()
	if not Stampede:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local Allies = GetUnitList(UNIT_LIST_ALLIED_HEROES)
	local FilteredAllies = PAF.FilterTrueUnits(Allies)
	
	for v, Ally in pairs(FilteredAllies) do
		if PAF.IsInTeamFight(Ally) and not P.IsInLaningPhase() then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	return 0
end