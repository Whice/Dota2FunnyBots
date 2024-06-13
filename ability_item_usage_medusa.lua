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

local SplitShot = bot:GetAbilityByName("medusa_split_shot")
local MysticSnake = bot:GetAbilityByName("medusa_mystic_snake")
local ManaShield = bot:GetAbilityByName("medusa_mana_shield")
local StoneGaze = bot:GetAbilityByName("medusa_stone_gaze")

local SplitShotDesire = 0
local MysticSnakeDesire = 0
local ManaShieldDesire = 0
local StoneGazeDesire = 0

local AttackRange
local BotTarget

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	-- The order to use abilities in
	StoneGazeDesire = UseStoneGaze()
	if StoneGazeDesire > 0 then
		bot:Action_UseAbility(StoneGaze)
		return
	end
	
	SplitShotDesire = UseSplitShot()
	if SplitShotDesire > 0 then
		bot:Action_UseAbility(SplitShot)
		return
	end
	
	MysticSnakeDesire, MysticSnakeTarget = UseMysticSnake()
	if MysticSnakeDesire > 0 then
		bot:Action_UseAbilityOnEntity(MysticSnake, MysticSnakeTarget)
		return
	end
end

function UseSplitShot()
	if not SplitShot:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end

	if P.IsInLaningPhase() then
		if SplitShot:GetToggleState() == true then
			return BOT_ACTION_DESIRE_HIGH
		end
		
		return 0
	else
		local AttackTarget = bot:GetAttackTarget()
		
		if AttackTarget ~= nil then
			if AttackTarget:IsHero() then
				local EnemiesWithinRange = bot:GetNearbyHeroes(AttackRange, true, BOT_MODE_NONE)
				
				if #EnemiesWithinRange > 1 then
					if SplitShot:GetToggleState() == false then
						return BOT_ACTION_DESIRE_HIGH
					else
						return 0
					end
				end
			end
			
			if AttackTarget:IsCreep() then
				local CreepsWithinRange = bot:GetNearbyCreeps(AttackRange, true)
				
				if #CreepsWithinRange > 1 then
					if SplitShot:GetToggleState() == false then
						return BOT_ACTION_DESIRE_HIGH
					else
						return 0
					end
				end
			end
			
			if SplitShot:GetToggleState() == true then
				return BOT_ACTION_DESIRE_HIGH
			end
			
			return 0
		end
	end
	
	return 0
end

function UseMysticSnake()
	if not MysticSnake:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = MysticSnake:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	local JumpRadius = MysticSnake:GetSpecialValueInt("radius")
	local Jumps = MysticSnake:GetSpecialValueInt("snake_jumps")
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange then
				return BOT_ACTION_DESIRE_HIGH, BotTarget
			end
		end
	end
	
	if P.IsRetreating(bot) and #EnemiesWithinRange > 0 then
		local ClosestTarget = PAF.GetClosestUnit(bot, EnemiesWithinRange)
		local NearbyHeroes = ClosestTarget:GetNearbyHeroes(JumpRadius, false, BOT_MODE_NONE)
		
		if #NearbyHeroes > 1 then
			return BOT_ACTION_DESIRE_HIGH, ClosestTarget
		end
	end
	
	if P.IsInLaningPhase() and #FilteredEnemies > 0 then
		local WeakestEnemy = PAF.GetWeakestUnit(FilteredEnemies)
		
		local NearbyCreeps = bot:GetNearbyCreeps(CastRange, true)
		for v, Creep in pairs(NearbyCreeps) do
			if string.find(Creep:GetUnitName(), "ranged") then
				if GetUnitToUnitDistance(WeakestEnemy, Creep) then
					return BOT_ACTION_DESIRE_HIGH, Creep
				end
			end
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_FARM then
		local NearbyCreeps = bot:GetNearbyCreeps(CastRange, true)
		
		for v, Creep in pairs(NearbyCreeps) do
			local AoECount = PAF.GetUnitsNearTarget(Creep:GetLocation(), NearbyCreeps, JumpRadius)
			if AoECount >= Jumps then
				return BOT_ACTION_DESIRE_HIGH, Creep
			end
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		local AttackTarget = bot:GetAttackTarget()
		
		if PAF.IsRoshan(AttackTarget)
		and GetUnitToUnitDistance(bot, AttackTarget) <= CastRange then
			return BOT_ACTION_DESIRE_VERYHIGH, AttackTarget
		end
	end
	
	return 0
end

function UseManaShield()
	if not ManaShield:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end

	if bot:GetActiveMode() == BOT_MODE_FARM or bot:GetActiveMode() == BOT_MODE_ROSHAN then
		if bot:GetMana() > (bot:GetMaxMana() * 0.5) then
			if ManaShield:GetToggleState() == false then
				return BOT_ACTION_DESIRE_HIGH
			else
				return 0
			end
		end
	end
	
	if PAF.IsEngaging(bot) or P.IsRetreating(bot) then
		if ManaShield:GetToggleState() == false then
			return BOT_ACTION_DESIRE_HIGH
		else
			return 0
		end
	end
	
	if ManaShield:GetToggleState() == true then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	return 0
end

function UseStoneGaze()
	if not StoneGaze:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	if PAF.IsInTeamFight(bot) then
		return BOT_ACTION_DESIRE_HIGH
	end
end