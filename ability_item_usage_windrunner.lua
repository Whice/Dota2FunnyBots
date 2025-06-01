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

local Shackleshot = bot:GetAbilityByName("windrunner_shackleshot")
local Powershot = bot:GetAbilityByName("windrunner_powershot")
local Windrun = bot:GetAbilityByName("windrunner_windrun")
local FocusFire = bot:GetAbilityByName("windrunner_focusfire")
local GaleForce = bot:GetAbilityByName("windrunner_gale_force")

local ShackleshotDesire = 0
local PowershotDesire = 0
local WindrunDesire = 0
local FocusFireDesire = 0
local GaleForceDesire = 0

local AttackRange
local BotTarget

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	-- The order to use abilities in
	WindrunDesire = UseWindrun()
	if WindrunDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbility(Windrun)
		return
	end
	
	ShackleshotDesire, ShackleshotTarget = UseShackleshot()
	if ShackleshotDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbilityOnEntity(Shackleshot, ShackleshotTarget)
		return
	end
	
	GaleForceDesire, GaleForceTarget = UseGaleForce()
	if GaleForceDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbilityOnLocation(GaleForce, GaleForceTarget)
		return
	end
	
	--[[PowershotDesire, PowershotTarget = UsePowershot()
	if PowershotDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbilityOnLocation(Powershot, PowershotTarget)
		return
	end]]--
	
	FocusFireDesire, FocusFireTarget = UseFocusFire()
	if FocusFireDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbilityOnEntity(FocusFire, FocusFireTarget)
		return
	end
end

function UseShackleshot()
	if not Shackleshot:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = Shackleshot:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	local NearbyTrees = bot:GetNearbyTrees(1600)
	local ShackleDistance = Shackleshot:GetSpecialValueInt("shackle_distance")
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterUnitsForStun(EnemiesWithinRange)
	
	for v, enemy in pairs(FilteredEnemies) do
		if enemy:IsChanneling() then
			return 1, enemy
		end
	end
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget)
			and not PAF.IsDisabled(BotTarget) then
				for v, Enemy in pairs(FilteredEnemies) do
					if Enemy ~= BotTarget then
						if GetUnitToUnitDistance(BotTarget, Enemy) <= ShackleDistance then
							local PTL = PointToLineDistance(bot:GetLocation(), Enemy:GetLocation(), BotTarget:GetLocation())
							if PTL.within == true then
								return 1, BotTarget
							end
						end
					end
				end
				
				for v, Tree in pairs(NearbyTrees) do
					local TreeLoc = GetTreeLocation(Tree)
					
					if GetUnitToLocationDistance(BotTarget, TreeLoc) <= ShackleDistance then
						local PTL = PointToLineDistance(bot:GetLocation(), TreeLoc, BotTarget:GetLocation())
						if PTL.within == true then
							return 1, BotTarget
						end
					end
				end
			end
		end
	end
	
	if P.IsRetreating(bot) and #EnemiesWithinRange > 0 then
		local ClosestTarget = PAF.GetClosestUnit(bot, FilteredEnemies)
		
		for v, Tree in pairs(NearbyTrees) do
			local TreeLoc = GetTreeLocation(Tree)
					
			if GetUnitToLocationDistance(ClosestTarget, TreeLoc) <= ShackleDistance then
				local PTL = PointToLineDistance(bot:GetLocation(), TreeLoc, ClosestTarget:GetLocation())
				if PTL.within == true then
					return 1, ClosestTarget
				end
			end
		end
	end
	
	return 0
end

function UsePowershot()
	if not Powershot:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	if bot:HasModifier("modifier_windrunner_focusfire") then return 0 end
	
	local CR = Powershot:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	local ExecuteThreshold = Powershot:GetSpecialValueInt("max_execute_threshold")
	local ExecutePct = (ExecuteThreshold / 100)
	
	--[[local Enemies = GetUnitList(UNIT_LIST_ENEMY_HEROES)
	local FilteredEnemies = PAF.FilterTrueUnits(Enemies)
	
	for v, Enemy in pairs(FilteredEnemies) do
		if Enemy:GetHealth() < (Enemy:GetMaxHealth() * ExecutePct) then
			return 1, Enemy:GetLocation()
		end
	end]]--
	
	if PAF.IsInTeamFight(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if not PAF.IsMagicImmune(BotTarget) then
				return 1, BotTarget:GetLocation()
			end
		end
	end
	
	return 0
end

function UseWindrun()
	if not Windrun:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterUnitsForStun(EnemiesWithinRange)
	
	if P.IsRetreating(bot) then
		if #FilteredEnemies > 0 then
			return 1
		end
	end
	
	if bot:HasModifier("modifier_windrunner_focusfire") then
		return 1
	end
	
	return 0
end

function UseFocusFire()
	if not FocusFire:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = (FocusFire:GetCastRange() + 50)
	local CastRange = PAF.GetProperCastRange(CR)
	
	if PAF.IsInTeamFight(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange then
				return 1, BotTarget
			end
		end
	end
	
	return 0
end

function UseGaleForce()
	if not GaleForce:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = GaleForce:GetCastRange()
	local Radius = GaleForce:GetSpecialValueInt("radius")
	
	if PAF.IsInTeamFight(bot) then
		local AoE = bot:FindAoELocation(true, true, bot:GetLocation(), CastRange, Radius/2, 0, 0)
		if (AoE.count >= 2) then
			return 1, AoE.targetloc
		end
	end
	
	return 0
end