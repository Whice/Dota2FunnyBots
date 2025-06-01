local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")
local PAF = require(GetScriptDirectory() ..  "/Library/PhalanxAbilityFunctions")
local PIU = require(GetScriptDirectory() .. "/Library/PhalanxItemUsage")
local PChat = require(GetScriptDirectory() .. "/Library/PhalanxChat")

local bot = GetBot()
local RoamTarget = nil
local LastMessageTime = DotaTime()

local StuckTime = 0 
local StuckLocation = Vector(0,0,0)

local Courier = nil

local SuitableToAttackSpecialUnit = false

local IsWinterWyvernArcticBurn = false
local IsBatRiderLasso = false
local IsWeaverShukuchi = false

local RearmDesireTime = -90
local RearmChannelTime
local MultishotDesireTime = -90
local MultishotChannelTime
local MultishotLoc = Vector(0,0,0)
local PowershotDesireTime = -90
local PowershotChannelTime
local PowershotLoc = Vector(0,0,0)
local TameTheBeastsDesireTime = -90
local TameTheBeastsChannelTime
local TameTheBeastsLoc = Vector(0,0,0)

local ShukuchiTarget = nil

local backpack_item = {}
local update_bi_time = -90

local InitiatedKillChat = false
local LastKills = 0
local LastKillChatAmt = 0
local LastChatTime = 0
local ChatDelay = 0

local ChattedAncientCritical = false
local InitiatedAncientCriticalChat = false
local AncientChatSent = false
local AncientCriticalDelayStart = 0
local AncientCriticalChatDelay = 0

function GetDesire()
	--PAF.AcquireTarget()
	ItemUsage()
	PChat.ChatModule()
	KillStreakChat()
	AncientCriticalChat()
	
	Courier = GetCourier(bot.courierID)
	
	if IsBotStuck() then
		return 2.0
	end
	
	if Courier ~= nil and ShouldRunToCourier() then
		return BOT_MODE_DESIRE_HIGH
	end
	
	if ShouldTinkerRearm() == true then
		return (BOT_MODE_DESIRE_ABSOLUTE * 1.5)
	end
	
	if ShouldDrowMultishot() == true then
		return (BOT_MODE_DESIRE_ABSOLUTE * 1.5)
	end
	
	if ShouldRingmasterTame() == true then
		return (BOT_MODE_DESIRE_ABSOLUTE * 1.5)
	end
	
	if ShouldWindrangerPowershot() == true then
		return (BOT_MODE_DESIRE_ABSOLUTE * 1.5)
	end
	
	if IsInWraithForm() then
		return (BOT_MODE_DESIRE_ABSOLUTE * 1.2)
	end
	
	if IsRuptured() then
		return (BOT_MODE_DESIRE_ABSOLUTE * 1.1)
	end
	
	if ShouldAttackCogs() then
		return (BOT_MODE_DESIRE_ABSOLUTE * 1.1)
	end
	
	if (bot:IsChanneling() or ShouldFixChannelInterruption())
	and not bot:HasModifier("modifier_teleporting")
	and not bot:HasModifier("modifier_teleporting_root_logic")
	and bot:GetActiveMode() ~= BOT_MODE_OUTPOST then
		return 2.0
	end
	
	if P.IsRetreating(bot) then return 0 end

	if bot:GetTeam() == TEAM_RADIANT then
		EnemyBase = DireSpawn
	elseif bot:GetTeam() == TEAM_DIRE then
		EnemyBase = RadiantSpawn
	end
	
	IsWinterWyvernArcticBurn = IsWinterWyvernAndCastingArcticBurn()
	if IsWinterWyvernArcticBurn then
		return 0.98
	end
	
	IsWindrangerFocusFiring = IsWindrangerCastingFocusFire()
	if IsWindrangerFocusFiring then
		if not P.IsRetreating(bot) then
			local EnemiesWithinRange = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
			local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
			
			if #FilteredEnemies > 0 then
				return 0.98
			end
		end
	end
	
	IsBatRiderLasso = IsBatRiderCastingLasso()
	if IsBatRiderLasso then
		return BOT_MODE_DESIRE_ABSOLUTE
	end
	
	IsWeaverShukuchi = IsWeaverCastingShukuchi()
	if IsWeaverShukuchi then
		local EnemiesWithinRange = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
		local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
		local WeakestEnemy = PAF.GetWeakestUnit(FilteredEnemies)
		
		if WeakestEnemy ~= nil and WeakestEnemy:CanBeSeen() then
			local NearbyTowers = WeakestEnemy:GetNearbyTowers(900, false)
			
			if #NearbyTowers <= 0 then
				ShukuchiTarget = WeakestEnemy
				return BOT_MODE_DESIRE_ABSOLUTE
			end
		end
	end
	
	if ShouldDenyTower() == true then
		return BOT_MODE_DESIRE_VERYHIGH
	end
	
	SuitableToAttackSpecialUnit = CanAttackSpecialUnit()
	if SuitableToAttackSpecialUnit then
		return 0.98
	end
end

function Think()
	if IsBotStuck() then
		local ScrollSlot = bot:FindItemSlot("item_tpscroll")
		local tpScroll = bot:GetItemInSlot(ScrollSlot)
		
		bot:Action_UseAbilityOnLocation(tpScroll, PAF.GetFountainLocation(bot))
		--bot:ActionImmediate_Chat("TPing because I'm stuck", true)
		
		StuckTime = DotaTime()
		StuckLocation = bot:GetLocation()
	end
	
	if Courier ~= nil and ShouldRunToCourier() then
		bot:Action_MoveToLocation(Courier:GetLocation())
	end
	
	if ShouldTinkerRearm() then
		if (DotaTime() - RearmDesireTime) < 0.2 then
			bot:Action_ClearActions(false)
		else
			if bot:GetUnitName() == "npc_dota_hero_tinker" and not bot:IsChanneling() then
				local Rearm = bot:GetAbilityByName("tinker_rearm")
				
				PAF.SwitchTreadsToInt(bot)
				bot:ActionQueue_UseAbility(Rearm)
			end
		end
	end
	
	if ShouldDrowMultishot() then
		if (DotaTime() - MultishotDesireTime) < 0.2 then
			bot:Action_ClearActions(false)
		else
			if bot:GetUnitName() == "npc_dota_hero_drow_ranger" and not bot:IsChanneling() then
				local Multishot = bot:GetAbilityByName("drow_ranger_multishot")
				
				PAF.SwitchTreadsToInt(bot)
				bot:ActionQueue_UseAbilityOnLocation(Multishot, MultishotLoc)
			end
		end
	end
	
	if ShouldRingmasterTame() then
		if (DotaTime() - TameTheBeastsDesireTime) < 0.2 then
			bot:Action_ClearActions(false)
		else
			if bot:GetUnitName() == "npc_dota_hero_ringmaster" and not bot:IsChanneling() then
				local TameTheBeasts = bot:GetAbilityByName("ringmaster_tame_the_beasts")
				
				PAF.SwitchTreadsToInt(bot)
				bot:ActionQueue_UseAbilityOnLocation(TameTheBeasts, TameTheBeastsLoc)
			end
		end
	end
	
	if ShouldWindrangerPowershot() then
		if (DotaTime() - PowershotDesireTime) < 0.2 then
			bot:Action_ClearActions(false)
		else
			if bot:GetUnitName() == "npc_dota_hero_windrunner" and not bot:IsChanneling() then
				local Powershot = bot:GetAbilityByName("windrunner_powershot")
				
				PAF.SwitchTreadsToInt(bot)
				
				if GetUnitToLocationDistance(bot, PowershotLoc) > Powershot:GetCastRange() then
					bot:ActionQueue_UseAbilityOnLocation(Powershot, PAF.GetXUnitsTowardsLocation(bot:GetLocation(), PowershotLoc, Powershot:GetCastRange()))
				else
					bot:ActionQueue_UseAbilityOnLocation(Powershot, PowershotLoc)
				end
			end
		end
	end
	
	if (bot:IsChanneling() or ShouldFixChannelInterruption())
	and not bot:HasModifier("modifier_teleporting")
	and not bot:HasModifier("modifier_teleporting_root_logic")
	and bot:GetActiveMode() ~= BOT_MODE_OUTPOST then
		return
	end
	
	if IsInWraithForm() then
		local AttackRange = bot:GetAttackRange()
		local EnemiesWithinRange = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
		local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
		local WeakestEnemy = PAF.GetWeakestUnit(FilteredEnemies)
		
		if WeakestEnemy ~= nil then
			bot:Action_AttackUnit(WeakestEnemy, true)
		end
	end
	
	if IsRuptured() then
		local AttackRange = bot:GetAttackRange()
		local EnemiesWithinRange = bot:GetNearbyHeroes(AttackRange, true, BOT_MODE_NONE)
		local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
		local WeakestEnemy = PAF.GetWeakestUnit(FilteredEnemies)
		
		if WeakestEnemy ~= nil then
			bot:Action_AttackUnit(WeakestEnemy, true)
		else
			bot:Action_ClearActions(true)
		end
	end
	
	if ShouldAttackCogs()
	and RoamTarget ~= nil
	and RoamTarget:CanBeSeen() then
		bot:Action_AttackUnit(RoamTarget, false)
		return
	end

	if IsWinterWyvernArcticBurn then
		local NonBurnedEnemies = GetEnemiesWithoutArcticBurn()
		local WeakestUnit = PAF.GetWeakestUnit(NonBurnedEnemies)
		
		if WeakestUnit ~= nil then
			bot:Action_AttackUnit(WeakestUnit, false)
			return
		elseif bot:GetTarget() ~= nil then
			bot:Action_AttackUnit(bot:GetTarget(), false)
			return
		end
	end
	
	if IsWindrangerFocusFiring then
		local EnemiesWithinRange = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
		local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
		
		local WeakestEnemy = PAF.GetWeakestUnit(FilteredEnemies)
		
		if WeakestEnemy ~= nil then
			local MoveToLoc = WeakestEnemy:GetExtrapolatedLocation(2)
			
			local AttackTarget = bot:GetAttackTarget()
			if AttackTarget ~= nil then
				bot:Action_AttackUnit(WeakestEnemy, false)
			else
				bot:Action_MoveToLocation(MoveToLoc)
			end
		end
	end
	
	if IsBatRiderLasso then
		bot:Action_MoveToLocation(PAF.GetFountainLocation(bot))
		return
	end
	
	if IsWeaverShukuchi then
		local Shukuchi = bot:GetAbilityByName("weaver_shukuchi")
		local Radius = Shukuchi:GetSpecialValueInt("radius")
		
		if GetUnitToUnitDistance(bot, ShukuchiTarget) > (Radius - 25) then
			bot:Action_MoveToLocation(ShukuchiTarget:GetLocation())
			return
		else
			bot:Action_AttackUnit(ShukuchiTarget, false)
			return
		end
	end
	
	if ShouldDenyTower() then
		bot:Action_AttackUnit(RoamTarget, false)
		return
	end

	if SuitableToAttackSpecialUnit
	and RoamTarget ~= nil
	and RoamTarget:CanBeSeen() then
		bot:Action_AttackUnit(RoamTarget, false)
		return
	end
end

function OnEnd()
	RoamTarget = nil
	ShukuchiTarget = nil
end

function IsBotStuck()
	local StuckNearbyHeroes = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
	local StuckNearbyCreeps = bot:GetNearbyLaneCreeps(1200, true)
	
	if DotaTime() > 10 then
		if bot:GetActiveMode() == BOT_MODE_ATTACK
		or bot:GetActiveMode() == BOT_MODE_SECRET_SHOP
		or bot:GetAttackTarget() ~= nil
		or not bot:IsAlive()
		or bot:DistanceFromFountain() <= 100 then
			StuckTime = DotaTime()
			StuckLocation = Vector(0,0,0)
		else
			if GetUnitToLocationDistance(bot, StuckLocation) > 100
			or #StuckNearbyHeroes > 0
			or #StuckNearbyCreeps > 0 then
				StuckTime = DotaTime()
				StuckLocation = bot:GetLocation()
			else
				if DotaTime() - StuckTime > 15 then
					return true
				end
			end
		end
	end
	
	return false
end

function ShouldRunToCourier()
	if bot:GetCourierValue() >= 25
	and Courier:IsAlive()
	and GetUnitToUnitDistance(bot, Courier) <= 1600
	and GetCourierState(Courier) == COURIER_STATE_DELIVERING_ITEMS
	and Courier:IsFacingLocation(bot:GetLocation(), 45)
	and P.IsInLaningPhase() then
		return true
	end
	
	return false
end

function CanAttackSpecialUnit()
	local SearchRange = (bot:GetAttackRange() + 150)
	
	--[[if SearchRange < 1000 then
		SearchRange = 1000
	end]]--

	local EnemyUnits = GetUnitList(UNIT_LIST_ENEMIES)
	
	for v, Unit in pairs(EnemyUnits) do
		if Unit ~= nil
		and Unit:IsAlive() 
		and Unit:CanBeSeen() then
			if string.find(Unit:GetUnitName(), "courier") then
				if GetUnitToUnitDistance(bot, Unit) <= SearchRange
				and not PAF.IsPhysicalImmune(Unit) then
					if PAF.IsChasing(bot, Unit)
					and GetUnitToUnitDistance(bot, Unit) > (bot:GetAttackRange() + 300)
					and Unit:GetCurrentMovementSpeed() >= bot:GetCurrentMovementSpeed() then
						-- Do nothing
					else
						RoamTarget = Unit
						return true
					end
				end
			end
		
			if string.find(Unit:GetUnitName(), "tombstone")
			or string.find(Unit:GetUnitName(), "phoenix_sun")
			or string.find(Unit:GetUnitName(), "warlock_golem")
			or string.find(Unit:GetUnitName(), "ignis_fatuus")
			or string.find(Unit:GetUnitName(), "visage_familiar")
			or string.find(Unit:GetUnitName(), "grimstroke_ink_creature")
			or string.find(Unit:GetUnitName(), "observer_ward")
			or string.find(Unit:GetUnitName(), "sentry_ward")
			or string.find(Unit:GetUnitName(), "healing_ward")
			or string.find(Unit:GetUnitName(), "weaver_swarm") then
				if string.find(Unit:GetUnitName(), "observer_ward") or string.find(Unit:GetUnitName(), "sentry_ward") then
					SearchRange = 1600
				end
				
				if GetUnitToUnitDistance(bot, Unit) <= SearchRange
				and not PAF.IsPhysicalImmune(Unit) then
					RoamTarget = Unit
					return true
				end
			end
		end
	end
end

function ShouldFixChannelInterruption()
	local ChanneledAbility
	
	if bot:GetUnitName() == "npc_dota_hero_shadow_shaman" then
		local ChanneledAbility = bot:GetAbilityByName("shadow_shaman_shackles")
		
		if ChanneledAbility:IsInAbilityPhase() or ChanneledAbility:IsChanneling() then
			return true
		end
	end
	
	if bot:GetUnitName() == "npc_dota_hero_drow_ranger" then
		local ChanneledAbility = bot:GetAbilityByName("drow_ranger_multishot")
		
		if ChanneledAbility:IsInAbilityPhase() or ChanneledAbility:IsChanneling() then
			return true
		end
	end
	
	if bot:GetUnitName() == "npc_dota_hero_enigma" then
		local ChanneledAbility = bot:GetAbilityByName("enigma_black_hole")
		
		if ChanneledAbility:IsInAbilityPhase() or ChanneledAbility:IsChanneling() then
			return true
		end
	end
	
	if bot:GetUnitName() == "npc_dota_hero_pugna" then
		local ChanneledAbility = bot:GetAbilityByName("pugna_life_drain")
		
		if ChanneledAbility:IsInAbilityPhase() or ChanneledAbility:IsChanneling() then
			return true
		end
	end
	
	if bot:GetUnitName() == "npc_dota_hero_bane" then
		local ChanneledAbility = bot:GetAbilityByName("bane_fiends_grip")
		
		if ChanneledAbility:IsInAbilityPhase() or ChanneledAbility:IsChanneling() then
			return true
		end
	end
	
	if bot:GetUnitName() == "npc_dota_hero_pudge" then
		local ChanneledAbility = bot:GetAbilityByName("pudge_dismember")
		
		if ChanneledAbility:IsInAbilityPhase() or ChanneledAbility:IsChanneling() then
			return true
		end
	end
	
	if bot:GetUnitName() == "npc_dota_hero_riki" then
		local ChanneledAbility = bot:GetAbilityByName("riki_tricks_of_the_trade")
		
		if ChanneledAbility:IsInAbilityPhase() or ChanneledAbility:IsChanneling() then
			return true
		end
	end
	
	if bot:GetUnitName() == "npc_dota_hero_sand_king" then
		local ChanneledAbility = bot:GetAbilityByName("sandking_epicenter")
		
		if ChanneledAbility:IsInAbilityPhase() or ChanneledAbility:IsChanneling() then
			return true
		end
	end
	
	if bot:GetUnitName() == "npc_dota_hero_tiny" then
		local ChanneledAbility = bot:GetAbilityByName("tiny_tree_channel")
		
		if ChanneledAbility:IsInAbilityPhase() or ChanneledAbility:IsChanneling() then
			return true
		end
	end
	
	if bot:GetUnitName() == "npc_dota_hero_oracle" then
		local ChanneledAbility = bot:GetAbilityByName("oracle_fortunes_end")
		
		if ChanneledAbility:IsInAbilityPhase() or ChanneledAbility:IsChanneling() then
			return true
		end
	end
	
	if bot:GetUnitName() == "npc_dota_hero_ringmaster" then
		local ChanneledAbility = bot:GetAbilityByName("ringmaster_tame_the_beasts")
		
		if ChanneledAbility:IsInAbilityPhase() or ChanneledAbility:IsChanneling() then
			return true
		end
	end
	
	if bot:GetUnitName() == "npc_dota_hero_tinker" then
		local ChanneledAbility = bot:GetAbilityByName("tinker_rearm")
		
		if ChanneledAbility:IsInAbilityPhase() or ChanneledAbility:IsChanneling() then
			return true
		end
	end
	
	if bot:GetUnitName() == "npc_dota_hero_windrunner" then
		local ChanneledAbility = bot:GetAbilityByName("windrunner_powershot")
		
		if ChanneledAbility:IsInAbilityPhase() or ChanneledAbility:IsChanneling() then
			return true
		end
	end
	
	if bot:GetUnitName() == "npc_dota_hero_chen" then
		local ChanneledAbility = bot:GetAbilityByName("chen_hand_of_god")
		
		if ChanneledAbility:IsInAbilityPhase() or ChanneledAbility:IsChanneling() then
			return true
		end
	end
	
	return false
end

function ShouldAttackCogs()
	local EnemyWardList = GetUnitList(UNIT_LIST_ENEMIES)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(bot:GetTarget()) then
			if GetUnitToUnitDistance(bot, bot:GetTarget()) <= (bot:GetAttackRange() + 100) then
				return false
			end
		end
	end
	
	for v, Cog in pairs(EnemyWardList) do
		if string.find(Cog:GetUnitName(), "rattletrap_cog") then
			if GetUnitToUnitDistance(bot, Cog) <= 200 and bot:IsFacingLocation(Cog:GetLocation(), 75) then
				RoamTarget = Cog
				return true
			end
		end
	end
	
	local AlliedWardList = GetUnitList(UNIT_LIST_ALLIES)
	
	for v, Cog in pairs(AlliedWardList) do
		if string.find(Cog:GetUnitName(), "rattletrap_cog") then
			if GetUnitToUnitDistance(bot, Cog) <= 200
			and bot:IsFacingLocation(Cog:GetLocation(), 75)
			and not PAF.IsEngaging(bot)
			and bot:GetActiveMode() ~= BOT_MODE_ROAM then
				RoamTarget = Cog
				return true
			end
		end
	end
	
	return false
end

function ShouldTinkerRearm()
	if bot:GetUnitName() == "npc_dota_hero_tinker" then
		
		local Laser = bot:GetAbilityByName("tinker_laser")
		local MarchOfTheMachines = bot:GetAbilityByName("tinker_march_of_the_machines")
		local DefenseMatrix = bot:GetAbilityByName("tinker_defense_matrix")
		local KeenConveyance = bot:GetAbilityByName("tinker_keen_teleport")
		local Rearm = bot:GetAbilityByName("tinker_rearm")
		
		local RearmChannelTime = Rearm:GetChannelTime()
		if (DotaTime() - RearmDesireTime) < (0.2 + RearmChannelTime) then
			return true
		end
		
		if not Rearm:IsFullyCastable() then return 0 end
		if P.CantUseAbility(bot) then return 0 end
		
		if (P.IsRetreating(bot) and bot:DistanceFromFountain() <= 0) or not PAF.IsEngaging(bot) then
			if not Laser:IsFullyCastable()
			or not MarchOfTheMachines:IsFullyCastable()
			or not DefenseMatrix:IsFullyCastable()
			or not KeenConveyance:IsFullyCastable() then
				RearmDesireTime = DotaTime()
				return true
			end
		end
		
		if PAF.IsInTeamFight(bot) then
			if not Laser:IsFullyCastable()
			and not MarchOfTheMachines:IsFullyCastable()
			and not DefenseMatrix:IsFullyCastable() then
				RearmDesireTime = DotaTime()
				return true
			end
		elseif PAF.IsEngaging(bot) then
			if PAF.IsValidHeroAndNotIllusion(BotTarget) then
				if GetUnitToUnitDistance(bot, BotTarget) <= 1600 then
					local AlliesWithinRange = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
					local FilteredAllies = PAF.FilterTrueUnits(AlliesWithinRange)
					local CombinedOffensivePower = (PAF.CombineOffensivePower(FilteredAllies, false) / 2)
					
					if CombinedOffensivePower < BotTarget:GetHealth() then
						if not Laser:IsFullyCastable()
						and not MarchOfTheMachines:IsFullyCastable()
						and not DefenseMatrix:IsFullyCastable() then
							RearmDesireTime = DotaTime()
							return true
						end
					end
				end
			end
		end
	end
	
	return false
end

function ShouldDrowMultishot()
	if bot:GetUnitName() == "npc_dota_hero_drow_ranger" then
		
		local Multishot = bot:GetAbilityByName("drow_ranger_multishot")
		
		--local MultishotChannelTime = Multishot:GetChannelTime()
		local MultishotChannelTime = 1.75
		if (DotaTime() - MultishotDesireTime) < (0.2 + MultishotChannelTime) then
			return true
		end
		
		if not Multishot:IsFullyCastable() then return 0 end
		if P.CantUseAbility(bot) then return 0 end
		
		local AttackRange = bot:GetAttackRange()
		local BotTarget = bot:GetTarget()
		local Radius = 250
		
		if PAF.IsEngaging(bot) then
			if PAF.IsValidHeroAndNotIllusion(BotTarget) then
				if GetUnitToUnitDistance(bot, BotTarget) <= (AttackRange + 50) then
					MultishotDesireTime = DotaTime()
					MultishotLoc = BotTarget:GetLocation()
					return true
				end
			end
		end
		
		local AttackTarget = bot:GetAttackTarget()
		
		if AttackTarget ~= nil and not P.IsInLaningPhase() then
			if AttackTarget:IsCreep() then
				local NearbyCreeps = bot:GetNearbyCreeps(1600, true)
				local AoECount = PAF.GetUnitsNearTarget(AttackTarget:GetLocation(), NearbyCreeps, Radius)
				
				if AoECount >= 3 and bot:GetMana() > (bot:GetMaxMana() * 0.6) then
					MultishotDesireTime = DotaTime()
					MultishotLoc = AttackTarget:GetLocation()
					return true
				end
			end
			
			if bot:GetActiveMode() == BOT_MODE_ROSHAN and PAF.IsRoshan(AttackTarget) then
				MultishotDesireTime = DotaTime()
				MultishotLoc = AttackTarget:GetLocation()
				return true
			end
		end
	end
	
	return false
end

function ShouldWindrangerPowershot()
	if bot:GetUnitName() == "npc_dota_hero_windrunner" then
		
		local Powershot = bot:GetAbilityByName("windrunner_powershot")
		
		local PowershotChannelTime = 1
		if (DotaTime() - PowershotDesireTime) < (0.2 + PowershotChannelTime) then
			return true
		end
		
		if not Powershot:IsFullyCastable() then return 0 end
		if P.CantUseAbility(bot) then return 0 end
		if bot:HasModifier("modifier_windrunner_focusfire") then return 0 end
		
		local CR = Powershot:GetCastRange()
		local CastRange = PAF.GetProperCastRange(CR)
		local Speed = Powershot:GetSpecialValueInt("arrow_speed")
		local ExecuteThreshold = Powershot:GetSpecialValueInt("max_execute_threshold")
		local ExecutePct = (ExecuteThreshold / 100)
		
		--[[local Enemies = GetUnitList(UNIT_LIST_ENEMY_HEROES)
		local FilteredEnemies = PAF.FilterTrueUnits(Enemies)
		
		for v, Enemy in pairs(FilteredEnemies) do
			if Enemy:GetHealth() < (Enemy:GetMaxHealth() * ExecutePct)
			and GetUnitToUnitDistance(bot, Enemy) <= CastRange then
				local ExtrapNum = (GetUnitToUnitDistance(bot, BotTarget) / Speed)
				local PredictedLoc = Enemy:GetExtrapolatedLocation(ExtrapNum)
				
				PowershotDesireTime = DotaTime()
				PowershotLoc = PredictedLoc
				return true
			end
		end]]--
		
		local BotTarget = bot:GetTarget()
		
		if PAF.IsInTeamFight(bot) then
			if PAF.IsValidHeroAndNotIllusion(BotTarget) then
				if not PAF.IsMagicImmune(BotTarget) then
					PowershotDesireTime = DotaTime()
					PowershotLoc = BotTarget:GetLocation()
					return true
				end
			end
		end
	end
	
	return false
end

function ShouldRingmasterTame()
	if bot:GetUnitName() == "npc_dota_hero_ringmaster" then
		
		local TameTheBeasts = bot:GetAbilityByName("ringmaster_tame_the_beasts")
		
		local TameTheBeastsChannelTime = TameTheBeasts:GetChannelTime()
		if (DotaTime() - TameTheBeastsDesireTime) < (0.2 + TameTheBeastsChannelTime) then
			return true
		end
		
		if not TameTheBeasts:IsFullyCastable() then return 0 end
		if P.CantUseAbility(bot) then return 0 end
		
		local CR = TameTheBeasts:GetCastRange()
		local CastRange = PAF.GetProperCastRange(CR)
		local BotTarget = bot:GetTarget()
		
		local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
		local FilteredEnemies = PAF.FilterUnitsForStun(EnemiesWithinRange)
		
		for v, enemy in pairs(FilteredEnemies) do
			if enemy:IsChanneling() then
				TameTheBeastsDesireTime = DotaTime()
				TameTheBeastsLoc = enemy:GetLocation()
				return true
			end
		end
		
		if PAF.IsEngaging(bot) then
			if PAF.IsValidHeroAndNotIllusion(BotTarget) then
				if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
				and not PAF.IsMagicImmune(BotTarget)
				and PAF.IsDisabled(BotTarget) or BotTarget:GetCurrentMovementSpeed() <= 300 then
					TameTheBeastsDesireTime = DotaTime()
					TameTheBeastsLoc = BotTarget:GetLocation()
					return true
				end
			end
		end
		
		if P.IsRetreating(bot) and #EnemiesWithinRange > 0 then
			local ClosestTarget = PAF.GetClosestUnit(bot, EnemiesWithinRange)
			TameTheBeastsDesireTime = DotaTime()
			TameTheBeastsLoc = ClosestTarget:GetLocation()
			return true
		end
	end
	
	return false
end

function GetEnemiesWithoutArcticBurn()
	local EnemiesWithinRange = bot:GetNearbyHeroes((bot:GetAttackRange()), true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
		
	local NonBurnedEnemies = {}
	if #FilteredEnemies > 0 then
		for v, Enemy in pairs(FilteredEnemies) do
			if not Enemy:HasModifier("modifier_winter_wyvern_arctic_burn_slow") then
				table.insert(NonBurnedEnemies, Enemy)
			end
		end
	end
	
	return NonBurnedEnemies
end

function IsWinterWyvernAndCastingArcticBurn()
	if bot:GetUnitName() == "npc_dota_hero_winter_wyvern"
	and bot:HasModifier("modifier_winter_wyvern_arctic_burn_flight") then
		local NonBurnedEnemies = GetEnemiesWithoutArcticBurn()
		
		if #NonBurnedEnemies > 0 then
			return true
		end
	end
	
	return false
end

function IsWindrangerCastingFocusFire()
	if bot:GetUnitName() == "npc_dota_hero_windrunner"
	and bot:HasModifier("modifier_windrunner_focusfire") then
		return true
	end
	
	return false
end

function IsBatRiderCastingLasso()
	if bot:GetUnitName() == "npc_dota_hero_batrider" then
		if bot:HasModifier("modifier_batrider_flaming_lasso_self") then
			return true
		end	
		
		if PAF.IsEngaging(bot) then
			local BotTarget = bot:GetTarget()
			if PAF.IsValidHeroAndNotIllusion(BotTarget) then
				if BotTarget:HasModifier("modifier_batrider_flaming_lasso") then
					return true
				end
			end
		end
	end
	
	return false
end

function IsTimbersawCastingChakram()
	if bot:GetUnitName() == "npc_dota_hero_shredder" then
		if bot:HasModifier("modifier_shredder_chakram_disarm") then
			return true
		end
	end
end

function IsWeaverCastingShukuchi()
	if bot:GetUnitName() == "npc_dota_hero_weaver" then
		if bot:HasModifier("modifier_weaver_shukuchi")
		and not P.IsRetreating(bot) then
			return true
		end
	end
end

function ShouldDenyTower()
	local NearbyTowers = bot:GetNearbyTowers(1600, false)
	
	for v, Tower in pairs(NearbyTowers) do
		if Tower ~= GetTower(bot:GetTeam(), TOWER_TOP_3)
		and Tower ~= GetTower(bot:GetTeam(), TOWER_MID_3)
		and Tower ~= GetTower(bot:GetTeam(), TOWER_BOT_3)
		and Tower ~= GetTower(bot:GetTeam(), TOWER_BASE_1)
		and Tower ~= GetTower(bot:GetTeam(), TOWER_BASE_2) then
			if Tower:GetHealth() < (Tower:GetMaxHealth() * 0.1) then
				RoamTarget = Tower
				return true
			end
		end
	end
	
	return false
end

function GetClosestLastKnownLocation()
	local ClosestLocation = nil
	local ClosestDistance = 99999

	local EnemyIDs = GetTeamPlayers(GetOpposingTeam())
	for v, EID in pairs(EnemyIDs) do
		local LSI = GetHeroLastSeenInfo(EID)
		if LSI ~= nil then
			local nLSI = LSI[1]
				
			if nLSI ~= nil then
				if GetUnitToLocationDistance(bot, nLSI.location) <= ClosestDistance then
					ClosestLocation = nLSI.location
					ClosestDistance = GetUnitToLocationDistance(bot, nLSI.location)
				end
			end
		end
	end
	
	return ClosestLocation
end

function IsRuptured()
	if bot:HasModifier("modifier_bloodseeker_rupture") then
		return true
	end
	
	return false
end

function IsInWraithForm()
	local EnemiesWithinRange = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	
	if (bot:HasModifier("modifier_skeleton_king_reincarnation_scepter_active")
	or bot:HasModifier("modifier_skeleton_king_reincarnation_scepter_respawn_time"))
	and #FilteredEnemies > 0 then
		return true
	end
	
	return false
end

function KillStreakChat()
	if P.IsMeepoClone(bot) or bot:HasModifier("modifier_arc_warden_tempest_double") then
		return
	end
	
	local botID = bot:GetPlayerID()
	local CurrentKills = GetHeroKills(botID)
	
	if not IsHeroAlive(botID) then
		if CurrentKills > LastKills then
			LastKills = GetHeroKills(botID)
		end
	else
		if CurrentKills > LastKillChatAmt
		and CurrentKills > (LastKills + 2)
		and not InitiatedKillChat then
			LastKillChatAmt = CurrentKills
			local ChatChance = RandomInt(1, 100)
			
			if ChatChance <= 20 then
				InitiatedKillChat = true
				LastChatTime = DotaTime()
				ChatDelay = (RandomInt(100, 300) / 100)
			end
		end
	end
	
	if InitiatedKillChat then
		if (DotaTime() - LastChatTime) >= ChatDelay then
			local KillstreakPhrase = PChat["KillstreakPhrases"][RandomInt(1, #PChat["KillstreakPhrases"])]
			
			bot:ActionImmediate_Chat(KillstreakPhrase, true)
			InitiatedKillChat = false
		end
	end
end

function AncientCriticalChat()
	if P.IsMeepoClone(bot) or bot:HasModifier("modifier_arc_warden_tempest_double") then
		return
	end
	
	local TeamAncient = GetAncient(bot:GetTeam())
	
	if not ChattedAncientCritical
	and TeamAncient:GetHealth() <= (TeamAncient:GetMaxHealth() * 0.5) then
		ChattedAncientCritical = true
		local ChatChance = RandomInt(1, 100)
			
		if ChatChance <= 50 then
			InitiatedAncientCriticalChat = true
			AncientCriticalDelayStart = DotaTime()
			AncientCriticalChatDelay = (RandomInt(100, 500) / 100)
		end
	end
	
	if not AncientChatSent and InitiatedAncientCriticalChat then
		if (DotaTime() - AncientCriticalDelayStart) >= AncientCriticalChatDelay then
			AncientChatSent = true
			local AncientCriticalPhrase = PChat["AncientCriticalPhrases"][RandomInt(1, #PChat["AncientCriticalPhrases"])]
			bot:ActionImmediate_Chat(AncientCriticalPhrase, true)
		end
	end
end

-- ITEM USAGE --

function ItemUsage()
	if bot:IsAlive() == false 
	   or bot:IsHero() == false 
	   or bot:IsMuted() == true 
	   or bot:IsHexed() == true
	   or bot:IsStunned() == true
	   or bot:IsChanneling() == true
	   or bot:IsInvulnerable() == true
	   or bot:IsUsingAbility() == true
	   or bot:IsCastingAbility() == true
	   or bot:NumQueuedActions() > 0 
	   or P.IsTaunted(bot) == true
	   or bot:HasModifier('modifier_teleporting') == true
	   or bot:HasModifier('modifier_doom_bringer_doom') == true
	   or bot:HasModifier('modifier_phantom_lancer_phantom_edge_boost') == true
	   or bot:HasModifier("modifier_ringmaster_unicycle_movement")
	   or ( bot:IsInvisible() == true and not bot:HasModifier("modifier_phantom_assassin_blur_active") == true )
    then 
		return	BOT_ACTION_DESIRE_NONE 
	end
	
	local extra_range = 0;
	local aether_lens_slot_type = bot:GetItemSlotType(bot:FindItemSlot('item_aether_lens'))
	if aether_lens_slot_type == ITEM_SLOT_TYPE_MAIN 
	then
		extra_range = extra_range + 225
	end

	local item_slot = {0,1,2,3,4,5,15,16}
	local mode = bot:GetActiveMode()
	for i=1, #item_slot do
		local item = bot:GetItemInSlot(item_slot[i])
		if PIU.CanCastItem(item) == true 
			and JustSwapped(item:GetName()) == false
			and ShouldNotUseNeutralItemFromMainSlot(item:GetName(), item_slot[i]) == false
			and PIU.Use[item:GetName()] ~= nil
		then
			local desire, target, target_type = PIU.Use[item:GetName()](item, bot, mode, extra_range)
			
			if desire > BOT_ACTION_DESIRE_NONE 
			then
				if target_type == 'no_target' then
					bot:Action_ClearActions(false)
					
					if item:GetName() == "item_magic_stick"
					or item:GetName() == "item_magic_wand"
					or item:GetName() == "item_faerie_fire"
					or item:GetName() == "item_enchanted_mango"
					or item:GetName() == "item_bottle"
					or item:GetName() == "item_flask"
					or item:GetName() == "item_clarity"
					or item:GetName() == "item_arcane_boots"
					or item:GetName() == "item_mekansm"
					or item:GetName() == "item_guardian_greaves"
					or item:GetName() == "item_arcane_blink" then
						PAF.SwitchTreadsToAgi(bot)
					elseif item:GetName() == "item_soul_ring" then
						PAF.SwitchTreadsToStr(bot)
					elseif item:GetName() == "item_manta" then
						local PrimaryAttribute = PRoles.GetActualPrimaryAttribute(bot)
						
						if PrimaryAttribute == 0 then
							PAF.SwitchTreadsToStr(bot)
						elseif PrimaryAttribute == 1 then
							PAF.SwitchTreadsToInt(bot)
						elseif PrimaryAttribute == 2 or PrimaryAttribute == 3 then
							PAF.SwitchTreadsToAgi(bot)
						end
					else
						if item:GetName() ~= "item_power_treads"
						and item:GetName() ~= "item_armlet"
						and item:GetName() ~= "item_blink"
						and item:GetName() ~= "item_overwhelming_blink"
						and item:GetName() ~= "item_swift_blink" then
							PAF.SwitchTreadsToInt(bot)
						end
					end
					
					if item:GetName() == "item_power_treads" then
						bot:Action_UseAbility(item)
						return
					end
					
					bot:ActionQueue_UseAbility(item)
					return
				elseif target_type == 'point' then
					bot:Action_ClearActions(false)
					
					PAF.SwitchTreadsToInt(bot)
					bot:ActionQueue_UseAbilityOnLocation(item, target)
					return
				elseif target_type == 'unit' then
					bot:Action_ClearActions(false)
					
					if item:GetName() ~= "item_hand_of_midas"
					and item:GetName() ~= "item_moon_shard" then
						PAF.SwitchTreadsToInt(bot)
					end
						
					bot:ActionQueue_UseAbilityOnEntity(item, target)
					return
				elseif target_type == 'tree' then
					bot:Action_UseAbilityOnTree(item, target)
					return
				end
			end
		end	
	end
end

function JustSwapped(item_name)
	return backpack_item[item_name] ~= nil and backpack_item[item_name] + 6.5 > DotaTime();
end

function UpdateBackPackItem(bot)
	local curr_time = DotaTime();
	for i=6, 8 do
		local bp_item = bot:GetItemInSlot(i);
		if bp_item ~= nil then
			backpack_item[bp_item:GetName()] = curr_time;
		end
	end
	
	if curr_time > update_bi_time + 7.0 then
		for k,v in pairs(backpack_item) do
			if v ~= nil and v + 7.0 < curr_time then
				backpack_item[k] = nil;
			end
		end
		update_bi_time = curr_time;
	end
end

function ShouldNotUseNeutralItemFromMainSlot(item_name, slot)
	return PItems.GetNeutralItemTier(item_name) > 0 and bot:GetItemSlotType(slot) == ITEM_SLOT_TYPE_MAIN
end