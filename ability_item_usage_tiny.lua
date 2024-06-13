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

local Avalanche = bot:GetAbilityByName("tiny_avalanche")
local Toss = bot:GetAbilityByName("tiny_toss")
local TreeGrab = bot:GetAbilityByName("tiny_tree_grab")
local Grow = bot:GetAbilityByName("tiny_grow")
local TreeVolley = bot:GetAbilityByName("tiny_tree_channel")
local TossTree = bot:GetAbilityByName("tiny_toss_tree")

local AvalancheDesire = 0
local TossDesire = 0
local TreeGrabDesire = 0
local TreeVolleyDesire = 0
local TossTreeDesire = 0

local AttackRange
local BotTarget

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	-- The order to use abilities in
	AvalancheDesire, AvalancheTarget = UseAvalanche()
	if AvalancheDesire > 0 then
		bot:Action_UseAbilityOnLocation(Avalanche, AvalancheTarget)
		return
	end
	
	TossDesire, TossTarget = UseToss()
	if TossDesire > 0 then
		bot:Action_UseAbilityOnEntity(Toss, TossTarget)
		return
	end
	
	TreeVolleyDesire, TreeVolleyTarget = UseTreeVolley()
	if TreeVolleyDesire > 0 then
		bot:Action_UseAbilityOnLocation(TreeVolley, TreeVolleyTarget)
		return
	end
	
	TossTreeDesire, TossTreeTarget = UseTossTree()
	if TossTreeDesire > 0 then
		bot:Action_UseAbilityOnEntity(TossTree, TossTreeTarget)
		return
	end
	
	TreeGrabDesire, TreeGrabTarget = UseTreeGrab()
	if TreeGrabDesire > 0 then
		bot:Action_UseAbilityOnTree(TreeGrab, TreeGrabTarget)
		return
	end
end

function UseAvalanche()
	if not Avalanche:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = Avalanche:GetCastRange()
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
				return BOT_ACTION_DESIRE_HIGH, BotTarget:GetLocation()
			end
		end
	end
	
	if P.IsRetreating(bot) and #EnemiesWithinRange > 0 then
		local ClosestTarget = PAF.GetClosestUnit(bot, EnemiesWithinRange)
		return BOT_ACTION_DESIRE_HIGH, ClosestTarget:GetLocation()
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		local AttackTarget = bot:GetAttackTarget()
		
		if PAF.IsRoshan(AttackTarget)
		and GetUnitToUnitDistance(bot, AttackTarget) <= CastRange then
			return BOT_ACTION_DESIRE_VERYHIGH, AttackTarget:GetLocation()
		end
	end
	
	return 0
end

function UseToss()
	if not Toss:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = Toss:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange then
				return BOT_ACTION_DESIRE_HIGH, BotTarget
			end
		end
	end
	
	--[[if PAF.IsValidHeroAndNotIllusion(BotTarget) then
		local ClosestUnit = PAF.GetClosestUnit(bot, GetUnitList(UNIT_LIST_ALL))
		
		if BotTarget == ClosestUnit then
			return BOT_ACTION_DESIRE_VERYHIGH, BotTarget
		end
	end]]--
	
	--[[if P.IsRetreating(bot) then
		local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
		local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
		
		local TableUnits = {}
		
		local AlliesWithinRange = bot:GetNearbyHeroes(CastRange, false, BOT_MODE_NONE)
		local EnemyCreepsWithinRange = bot:GetNearbyCreeps(CastRange, true)
		local AllyCreepsWithinRange = bot:GetNearbyCreeps(CastRange, false)
		
		TableUnits = PAF.CombineTables(EnemiesWithinRange, AlliesWithinRange)
		TableUnits = PAF.CombineTables(TableUnits, EnemyCreepsWithinRange)
		TableUnits = PAF.CombineTables(TableUnits, AllyCreepsWithinRange)
		
		local ClosestUnit = PAF.GetClosestUnit(bot, TableUnits)
		
		if ClosestUnit ~= nil and ClosestUnit:IsHero() and GetUnitToUnitDistance(bot, ClosestUnit) <= (CastRange/2) then
			return BOT_ACTION_DESIRE_VERYHIGH, TableUnits[#TableUnits]
		end
	end]]--
	
	return 0
end

function UseTreeGrab()
	if not TreeGrab:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	if bot:HasModifier("modifier_tiny_tree_grab") then return 0 end
	
	local Trees = bot:GetNearbyTrees(1600)
	
	if #Trees > 0 and bot:DistanceFromFountain() > 0 then
		return BOT_ACTION_DESIRE_VERYHIGH, Trees[1]
	end
	
	return 0
end

function UseTossTree()
	if not TossTree:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	if not bot:HasModifier("modifier_tiny_tree_grab") then return 0 end
	
	local CR = TossTree:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local ModifierIndex = bot:GetModifierByName("modifier_tiny_tree_grab")
	local Stacks = bot:GetModifierStackCount(ModifierIndex)
	
	if Stacks == 1 then
		local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
		local FilteredEnemies = PAF.FilterUnitsForStun(EnemiesWithinRange)
		
		local WeakestUnit = PAF.GetWeakestUnit(FilteredEnemies)
		
		if WeakestUnit ~= nil then
			return BOT_ACTION_DESIRE_VERYHIGH, WeakestUnit
		end
	end
	
	return 0
end

function UseTreeVolley()
	if not TreeVolley:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = TreeVolley:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local GrabRadius = TreeVolley:GetSpecialValueInt("tree_grab_radius")
	local Trees = bot:GetNearbyTrees(GrabRadius)
	
	if PAF.IsInTeamFight(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange then
				return BOT_ACTION_DESIRE_HIGH, BotTarget:GetLocation()
			end
		end
	end
	
	return 0
end