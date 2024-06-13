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

local Sprint = bot:GetAbilityByName("slardar_sprint")
local SlithereenCrush = bot:GetAbilityByName("slardar_slithereen_crush")
local Bash = bot:GetAbilityByName("slardar_bash")
local CorrosiveHaze = bot:GetAbilityByName("slardar_amplify_damage")

local SprintDesire = 0
local SlithereenCrushDesire = 0
local CorrosiveHazeDesire = 0

local AttackRange
local BotTarget
local manathreshold = 0

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	manathreshold = 100
	manathreshold = manathreshold + Sprint:GetManaCost()
	manathreshold = manathreshold + SlithereenCrush:GetManaCost()
	manathreshold = manathreshold + CorrosiveHaze:GetManaCost()
	
	-- The order to use abilities in
	SlithereenCrushDesire = UseSlithereenCrush()
	if SlithereenCrushDesire > 0 then
		bot:Action_UseAbility(SlithereenCrush)
		return
	end
	
	CorrosiveHazeDesire, CorrosiveHazeTarget = UseCorrosiveHaze()
	if CorrosiveHazeDesire > 0 then
		bot:Action_UseAbilityOnEntity(CorrosiveHaze, CorrosiveHazeTarget)
		return
	end
	
	SprintDesire = UseSprint()
	if SprintDesire > 0 then
		bot:Action_UseAbility(Sprint)
		return
	end
end

function UseSprint()
	if not Sprint:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	
	if #FilteredEnemies >= 1 and (PAF.IsEngaging(bot) or P.IsRetreating(bot)) then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	return 0
end

function UseSlithereenCrush()
	if not SlithereenCrush:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = SlithereenCrush:GetSpecialValueInt("crush_radius")
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterUnitsForStun(EnemiesWithinRange)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= (CastRange - 50)
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
			
			if #CreepsWithinRange >= 3 and (bot:GetMana() - SlithereenCrush:GetManaCost()) > manathreshold then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
		
		if bot:GetActiveMode() == BOT_MODE_ROSHAN and PAF.IsRoshan(AttackTarget) then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	return 0
end

function UseCorrosiveHaze()
	if not CorrosiveHaze:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = CorrosiveHaze:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not BotTarget:HasModifier("modifier_slardar_amplify_damage") then
				return BOT_ACTION_DESIRE_HIGH, BotTarget
			end
		end
	end
	
	local AttackTarget = bot:GetAttackTarget()
	
	if AttackTarget ~= nil then
		if bot:GetActiveMode() == BOT_MODE_ROSHAN 
		and PAF.IsRoshan(AttackTarget)
		and not AttackTarget:HasModifier("modifier_slardar_amplify_damage") then
			return BOT_ACTION_DESIRE_HIGH, AttackTarget
		end
	end
	
	return 0
end