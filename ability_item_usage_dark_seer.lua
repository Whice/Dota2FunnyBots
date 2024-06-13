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

local Vacuum = bot:GetAbilityByName("dark_seer_vacuum")
local IonShell = bot:GetAbilityByName("dark_seer_ion_shell")
local Surge = bot:GetAbilityByName("dark_seer_surge")
local WallOfReplica = bot:GetAbilityByName("dark_seer_wall_of_replica")

local VacuumDesire = 0
local IonShellDesire = 0
local SurgeDesire = 0
local WallOfReplicaDesire = 0

-- Combo Desires
local WallComboDesire = 0

local AttackRange
local BotTarget
local AttackRange = 0

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	-- The order to use abilities in
	WallComboDesire, WallComboTarget = UseWallCombo()
	if WallComboDesire > 0 then
		bot:Action_ClearActions(false)
		
		bot:ActionQueue_UseAbilityOnLocation(WallOfReplica, WallComboTarget)
		bot:ActionQueue_UseAbilityOnLocation(Vacuum, WallComboTarget)
		return
	end
	
	WallOfReplicaDesire, WallOfReplicaTarget = UseWallOfReplica()
	if WallOfReplicaDesire > 0 then
		bot:Action_UseAbilityOnLocation(WallOfReplica, WallOfReplicaTarget)
		return
	end
	
	IonShellDesire, IonShellTarget = UseIonShell()
	if IonShellDesire > 0 then
		bot:Action_UseAbilityOnEntity(IonShell, IonShellTarget)
		return
	end
	
	VacuumDesire, VacuumTarget = UseVacuum()
	if VacuumDesire > 0 then
		bot:Action_UseAbilityOnLocation(Vacuum, VacuumTarget)
		return
	end
	
	SurgeDesire, SurgeTarget = UseSurge()
	if SurgeDesire > 0 then
		bot:Action_UseAbilityOnEntity(Surge, SurgeTarget)
		return
	end
end

function UseWallCombo()
	if not CanCastWallCombo() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local ComboCastRange = Vacuum:GetCastRange()
	local Radius = Vacuum:GetSpecialValueInt("radius")
	
	if PAF.IsInTeamFight(bot) then
		local AoE = bot:FindAoELocation(true, true, bot:GetLocation(), ComboCastRange, Radius/2, 0, 0)
		if (AoE.count >= 2) then
			return BOT_ACTION_DESIRE_HIGH, AoE.targetloc
		end
	end
	
	return 0
end

function UseVacuum()
	if not Vacuum:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = Vacuum:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	local Radius = Vacuum:GetSpecialValueInt("radius")
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterUnitsForStun(EnemiesWithinRange)
	
	if P.IsRetreating(bot) and #FilteredEnemies > 0 then
		local ClosestTarget = PAF.GetClosestUnit(bot, FilteredEnemies)
		return BOT_ACTION_DESIRE_HIGH, BotTarget:GetXUnitsTowardsLocation(PAF.GetFountainLocation(ClosestTarget), Radius)
	end
	
	if PAF.IsEngaging(bot) and not CanCastWallCombo() then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange then
				return BOT_ACTION_DESIRE_HIGH, BotTarget:GetXUnitsTowardsLocation(PAF.GetFountainLocation(bot), (Radius - 200))
			end
		end
	end
	
	return 0
end

function UseIonShell()
	if not IonShell:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = IonShell:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	local Radius = IonShell:GetSpecialValueInt("radius")
	local Duration = IonShell:GetSpecialValueInt("duration")
	
	local AlliesWithinRange = bot:GetNearbyHeroes(CastRange, false, BOT_MODE_NONE)
	local FilteredAllies = PAF.FilterTrueUnits(AlliesWithinRange)
	
	if PAF.IsEngaging(bot) then
		local AlliesWithoutShell = {}
		
		for v, Ally in pairs(FilteredAllies) do
			if not Ally:HasModifier("modifier_dark_seer_ion_shell")
			and Ally:GetAttackRange() <= Radius then
				table.insert(AlliesWithoutShell, Ally)
			end
		end
		
		if #AlliesWithoutShell > 0 then
			local StrongestAlly = nil
			local StrongestPower = 0
			
			for v, Ally in pairs(AlliesWithoutShell) do
				local EstDmg = Ally:GetEstimatedDamageToTarget(true, BotTarget, Duration, DAMAGE_TYPE_ALL)
				
				if EstDmg > StrongestPower then
					StrongestAlly = Ally
					StrongestPower = EstDmg
				end
			end
			
			if PAF.IsValidHeroAndNotIllusion(BotTarget)
			and GetUnitToUnitDistance(StrongestAlly, BotTarget) <= 1200 then
				return BOT_ACTION_DESIRE_HIGH, StrongestAlly
			end
		end
	end
	
	local AttackTarget = bot:GetAttackTarget()
	
	if bot:GetActiveMode() == BOT_MODE_FARM then
		if AttackTarget:GetTeam() == TEAM_NEUTRAL then
			return BOT_ACTION_DESIRE_HIGH, bot
		else
			local NearbyFriendlyLaneCreeps = bot:GetNearbyLaneCreeps(1600, false)
			local NearbyEnemyLaneCreeps = bot:GetNearbyLaneCreeps(1600, true)
			
			if #NearbyFriendlyLaneCreeps > 0 then
				local FriendlyCreepHasShell = false
				for v, FriendlyCreep in pairs(NearbyFriendlyLaneCreeps) do
					if FriendlyCreep:HasModifier("modifier_dark_seer_ion_shell") then
						FriendlyCreepHasShell = false
						break
					end
				end
				
				if not FriendlyCreepHasShell then
					NearbyFriendlyLaneCreeps = bot:GetNearbyLaneCreeps(CastRange, false)
					
					if #NearbyFriendlyLaneCreeps > 0 then
						for v, Creep in pairs(NearbyFriendlyLaneCreeps) do
							if string.find(Creep:GetUnitName(), "melee")
							and Creep:GetAttackTarget() ~= nil
							and Creep:GetHealth() == Creep:GetMaxHealth() then
								return BOT_ACTION_DESIRE_HIGH, Creep
							end
						end
					end
				end
			end
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		local AttackTarget = bot:GetAttackTarget()
		
		if PAF.IsRoshan(AttackTarget) then
			return BOT_ACTION_DESIRE_VERYHIGH, bot
		end
	end
	
	return 0
end

function UseSurge()
	if not Surge:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = Surge:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	if P.IsRetreating(bot) then
		return BOT_ACTION_DESIRE_HIGH, bot
	end
	
	local AlliesWithinRange = bot:GetNearbyHeroes(CastRange, false, BOT_MODE_NONE)
	local FilteredAllies = PAF.FilterTrueUnits(AlliesWithinRange)
	
	local WeakestAlly = PAF.GetWeakestUnit(FilteredAllies)
	
	if WeakestAlly:GetHealth() < (WeakestAlly:GetMaxHealth() * 0.35)
	and WeakestAlly:WasRecentlyDamagedByAnyHero(1)
	and WeakestAlly:IsFacingLocation(PAF.GetFountainLocation(WeakestAlly), 45) then
		return BOT_ACTION_DESIRE_HIGH, WeakestAlly
	end
	
	if PAF.IsEngaging(bot) and BotTarget ~= nil then
		local ChasingAllies = {}
		for v, Ally in pairs(FilteredAllies) do
			if PAF.IsChasing(Ally, BotTarget) then
				table.insert(ChasingAllies, Ally)
			end
		end
		
		if #ChasingAllies > 0 then
			local StrongestAlly = PAF.GetStrongestAttackDamageUnit(ChasingAllies)
			
			if StrongestAlly ~= nil
			and GetUnitToUnitDistance(StrongestAlly, BotTarget) > (StrongestAlly:GetAttackRange() + 300)
			and GetUnitToUnitDistance(StrongestAlly, BotTarget) <= 1600 then
				return BOT_ACTION_DESIRE_HIGH, WeakestAlly
			end
		end
	end
	
	return 0
end

function UseWallOfReplica()
	if not WallOfReplica:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	if CanCastWallCombo() then return 0 end
	
	local CR = WallOfReplica:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	local Width = WallOfReplica:GetSpecialValueInt("width")
	
	if PAF.IsInTeamFight(bot) then
		local AoE = bot:FindAoELocation(true, true, bot:GetLocation(), CastRange, Width/2, 0, 0)
		if (AoE.count >= 2) then
			return BOT_ACTION_DESIRE_HIGH, AoE.targetloc
		end
	end
	
	return 0
end

function CanCastWallCombo()
	if Vacuum:IsFullyCastable()
	and WallOfReplica:IsFullyCastable() then
		local TotalManaCost = 0
		
		TotalManaCost = (TotalManaCost + Vacuum:GetManaCost())
		TotalManaCost = (TotalManaCost + WallOfReplica:GetManaCost())
		
		if bot:GetMana() > TotalManaCost then
			return true
		end
	end
	
	return false
end