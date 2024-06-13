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

local SummonWolves = bot:GetAbilityByName("lycan_summon_wolves")
local Howl = bot:GetAbilityByName("lycan_howl")
local FeralImpulse = bot:GetAbilityByName("lycan_feral_impulse")
local Shapeshift = bot:GetAbilityByName("lycan_shapeshift")

local SummonWolvesDesire = 0
local HowlDesire = 0
local FeralImpulseDesire = 0
local ShapeshiftDesire = 0

local AttackRange
local BotTarget

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	-- The order to use abilities in
	ShapeshiftDesire = UseShapeshift()
	if ShapeshiftDesire > 0 then
		bot:Action_UseAbility(Shapeshift)
		return
	end
	
	HowlDesire = UseHowl()
	if HowlDesire > 0 then
		bot:Action_UseAbility(Howl)
		return
	end
	
	SummonWolvesDesire = UseSummonWolves()
	if SummonWolvesDesire > 0 then
		bot:Action_UseAbility(SummonWolves)
		return
	end
end

function UseSummonWolves()
	if not SummonWolves:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	if PAF.IsEngaging(bot)
	or bot:GetActiveMode() == BOT_MODE_FARM
	or bot:GetActiveMode() == BOT_MODE_ROSHAN
	or P.IsPushing(bot) then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	return 0
end

function UseHowl()
	if not Howl:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(1000, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	
	if PAF.IsEngaging(bot) and #FilteredEnemies > 0 then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	if GetTimeOfDay() < 0.5 then
		local Allies = GetUnitList(UNIT_LIST_ALLIED_HEROES)
		local FilteredAllies = PAF.FilterTrueUnits(Allies)
		
		for v, Ally in pairs(FilteredAllies) do
			if PAF.IsEngaging(Ally) then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end
	
	return 0
end

function UseShapeshift()
	if not Shapeshift:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	if PAF.IsInTeamFight(bot) then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	return 0
end