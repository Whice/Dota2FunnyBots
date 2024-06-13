local bot = GetBot()

local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles")
local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions")
local PAF = require(GetScriptDirectory() ..  "/Library/PhalanxAbilityFunctions")

local target = nil
local PATarget = nil
local desiremode = ""
local StartRunTime = 0
local RetreatTime = 0
local itemtarget = nil

local StuckTime = 0 
local StuckLocation = Vector(0,0,0)

function GetDesire()
	local allycreeps = bot:GetNearbyLaneCreeps(1000, false)
	local enemycreeps = bot:GetNearbyLaneCreeps(1000, true)
	local neutralcreeps = bot:GetNearbyNeutralCreeps(1000)
	
	target = nil
	
	local attackdmg = bot:GetAttackDamage()
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
					desiremode = "unstuck"
					return BOT_MODE_DESIRE_ABSOLUTE * 1.3
				end
			end
		end
	end
	
	
	if DotaTime() > 0 and not P.IsRetreating(bot) then
		ShouldRetreat()
		if (DotaTime() - StartRunTime) < RetreatTime then
			desiremode = "ForceRetreat"
			return BOT_MODE_DESIRE_ABSOLUTE * 1.2
		end
	end
	
	--[[if bot:DistanceFromFountain() < 10 then
		local DroppedItems = GetDroppedItemList()
		for v, ditem in pairs(DroppedItems) do
			if GetUnitToLocationDistance(bot, ditem.location) <= 700 then
				itemtarget = ditem.item
				desiremode = "AttackItem"
				return BOT_MODE_DESIRE_ABSOLUTE * 1.21
			end
		end
	end]]--
	
	if bot:GetUnitName() == "npc_dota_hero_shadow_shaman" then
		local Shackles = bot:GetAbilityByName("shadow_shaman_shackles")
		if Shackles:IsInAbilityPhase() or Shackles:IsChanneling() or bot:IsChanneling() then
			desiremode = "AbilityChannel"
			return BOT_MODE_DESIRE_ABSOLUTE * 1.1
		end
	end
	if bot:GetUnitName() == "npc_dota_hero_drow_ranger" then
		local Multishot = bot:GetAbilityByName("drow_ranger_multishot")
		if Multishot:IsInAbilityPhase() or Multishot:IsChanneling() or bot:IsChanneling() then
			desiremode = "AbilityChannel"
			return BOT_MODE_DESIRE_ABSOLUTE * 1.1
		end
	end
	if bot:GetUnitName() == "npc_dota_hero_enigma" then
		local BlackHole = bot:GetAbilityByName("enigma_black_hole")
		if BlackHole:IsInAbilityPhase() or BlackHole:IsChanneling() or bot:IsChanneling() then
			desiremode = "AbilityChannel"
			return BOT_MODE_DESIRE_ABSOLUTE * 1.1
		end
	end
	if bot:GetUnitName() == "npc_dota_hero_pugna" then
		local LifeDrain = bot:GetAbilityByName("pugna_life_drain")
		if LifeDrain:IsInAbilityPhase() or LifeDrain:IsChanneling() or bot:IsChanneling() then
			desiremode = "AbilityChannel"
			return BOT_MODE_DESIRE_ABSOLUTE * 1.1
		end
	end
	if bot:GetUnitName() == "npc_dota_hero_bane" then
		local FiendsGrip = bot:GetAbilityByName("bane_fiends_grip")
		if FiendsGrip:IsInAbilityPhase() or FiendsGrip:IsChanneling() or bot:IsChanneling() then
			desiremode = "AbilityChannel"
			return BOT_MODE_DESIRE_ABSOLUTE * 1.1
		end
	end
	if bot:GetUnitName() == "npc_dota_hero_pudge" then
		local Dismember = bot:GetAbilityByName("pudge_dismember")
		if Dismember:IsInAbilityPhase() or Dismember:IsChanneling() or bot:IsChanneling() then
			desiremode = "AbilityChannel"
			return BOT_MODE_DESIRE_ABSOLUTE * 1.1
		end
	end
	if bot:GetUnitName() == "npc_dota_hero_riki" then
		local TricksOfTheTrade = bot:GetAbilityByName("riki_tricks_of_the_trade")
		if TricksOfTheTrade:IsInAbilityPhase() or TricksOfTheTrade:IsChanneling() or bot:IsChanneling() then
			desiremode = "AbilityChannel"
			return BOT_MODE_DESIRE_ABSOLUTE * 1.1
		end
	end
	if bot:GetUnitName() == "npc_dota_hero_sand_king" then
		local Epicenter = bot:GetAbilityByName("sandking_epicenter")
		if Epicenter:IsInAbilityPhase() or Epicenter:IsChanneling() or bot:IsChanneling() then
			desiremode = "AbilityChannel"
			return BOT_MODE_DESIRE_ABSOLUTE * 1.1
		end
	end
	if bot:GetUnitName() == "npc_dota_hero_tiny" then
		local TreeVolley = bot:GetAbilityByName("tiny_tree_channel")
		if TreeVolley:IsInAbilityPhase() or TreeVolley:IsChanneling() or bot:IsChanneling() then
			desiremode = "AbilityChannel"
			return BOT_MODE_DESIRE_ABSOLUTE * 1.1
		end
	end
	if bot:GetUnitName() == "npc_dota_hero_oracle" then
		local FortunesEnd = bot:GetAbilityByName("oracle_fortunes_end")
		if FortunesEnd:IsInAbilityPhase() or FortunesEnd:IsChanneling() or bot:IsChanneling() then
			desiremode = "AbilityChannel"
			return BOT_MODE_DESIRE_ABSOLUTE * 1.1
		end
	end
	
	if P.IsInLaningPhase() then
		if IsSuitableToLastHit() then
			if CanLastHitCreep(enemycreeps) and not IsCoreNearby() then
				desiremode = "LH"
				return 0.56
			end
			if CanLastHitCreep(allycreeps) then
				desiremode = "Deny"
				return 0.56
			end
		end
	end
	
	local AlliesWithinRange = bot:GetNearbyHeroes(1000, false, BOT_MODE_NONE)
	local FilteredAllies = PAF.FilterTrueUnits(AlliesWithinRange)
	
	if IsSuitableToLastHit()
	and not IsCoreNearby()
	and bot:GetActiveMode() ~= BOT_MODE_DEFEND_TOWER_TOP
	and bot:GetActiveMode() ~= BOT_MODE_DEFEND_TOWER_MID
	and bot:GetActiveMode() ~= BOT_MODE_DEFEND_TOWER_BOT then
		if CanLastHitCreep(enemycreeps) then
			desiremode = "LH"
			return BOT_MODE_DESIRE_ABSOLUTE * 1.12
		end
	end
	
	local Courier = GetCourier(bot.courierID)
	if bot:GetCourierValue() >= 25
	and Courier:IsAlive()
	and GetUnitToUnitDistance(bot, Courier) <= 1600
	and GetCourierState(Courier) == COURIER_STATE_DELIVERING_ITEMS
	and Courier:IsFacingLocation(bot:GetLocation(), 45)
	and P.IsInLaningPhase() then
		desiremode = "CourierRetrieve"
		return BOT_MODE_DESIRE_HIGH
	end
	
	return 0
end

function Think()
	if desiremode == "LH" or desiremode == "Deny" then
		bot:Action_AttackUnit(target, false)
	elseif desiremode == "unstuck" then
		local ScrollSlot = bot:FindItemSlot("item_tpscroll")
		local tpScroll = bot:GetItemInSlot(ScrollSlot)
		
		bot:Action_UseAbilityOnLocation(tpScroll, PAF.GetFountainLocation(bot))
		--bot:ActionImmediate_Chat("TPing because I'm stuck", true)
		
		StuckTime = DotaTime()
		StuckLocation = bot:GetLocation()
	elseif desiremode == "StopLH" then
		bot:Action_ClearActions(true)
	elseif desiremode == "Harass" then
		bot:Action_AttackUnit(bot:GetAttackTarget(), false)
	elseif desiremode == "PartnerAttack" then
		bot:Action_AttackUnit(PATarget, true)
	elseif desiremode == "SFRaze" and target ~= nil then
		bot:Action_MoveToLocation(target:GetLocation())
	elseif desiremode == "ForceRetreat" then
		if P.IsInLaningPhase() then
			local FriendlyTowers = GetUnitList(UNIT_LIST_ALLIED_BUILDINGS)
			local ClosestTower = nil
			local ClosestDistance = 99999999
			
			for v, Tower in pairs(FriendlyTowers) do
				if Tower:IsTower() and GetUnitToUnitDistance(bot, Tower) < ClosestDistance then
					ClosestTower = Tower
					ClosestDistance = GetUnitToUnitDistance(bot, Tower)
				end
			end
			
			local RetreatSpot = ClosestTower:GetLocation()
			
			local Enemies = bot:GetNearbyHeroes(800, false, BOT_MODE_NONE)
			
			for v, enemy in pairs(Enemies) do
				if GetUnitToUnitDistance(enemy, ClosestTower) <= 800 then
					if bot:GetTeam() == TEAM_RADIANT then
						RetreatSpot = Vector(-7174.0, -6671.0, 0.0)
					elseif bot:GetTeam() == TEAM_DIRE then
						RetreatSpot = Vector(7023.0, 6450.0, 0.0)
					end
					
					break
				end
			end
			
			bot:Action_MoveToLocation(RetreatSpot)
		else
			if bot:GetTeam() == TEAM_RADIANT then
				bot:Action_MoveToLocation(Vector(-7174.0, -6671.0, 0.0))
			elseif bot:GetTeam() == TEAM_DIRE then
				bot:Action_MoveToLocation(Vector(7023.0, 6450.0, 0.0))
			end
		end
	elseif desiremode == "AttackItem" then
		print("Attack item")
		print(itemtarget)
		bot:Action_AttackUnit(itemtarget, true)
	elseif desiremode == "AbilityChannel" then
		--return
	elseif desiremode == "CourierRetrieve" then
		local Courier = GetCourier(bot.courierID)
		bot:Action_MoveToLocation(Courier:GetLocation())
	end
end

function OnEnd()
	StartRunTime = 0
	RetreatTime = 0
end

-----------------------------------------------------------------------------------------------------------------------------

function CanLastHitCreep(creeps)
	local attackdmg = bot:GetAttackDamage()
	
	if bot:FindItemSlot("item_quelling_blade") >= 0 then
		if bot:GetUnitName() == "npc_dota_hero_templar_assassin"
		or bot:GetAttackRange() > 301 then
			attackdmg = (attackdmg + 4)
		else
			attackdmg = (attackdmg + 8)
		end
	elseif bot:FindItemSlot("item_bfury") >= 0 then
		if bot:GetUnitName() == "npc_dota_hero_templar_assassin"
		or bot:GetAttackRange() > 301 then
			attackdmg = (attackdmg + 5)
		else
			attackdmg = (attackdmg + 10)
		end
	end

	for v, hcreep in pairs(creeps) do
		if #creeps > 0 and hcreep ~= nil and hcreep:CanBeSeen() then
			local incdmg = hcreep:GetActualIncomingDamage(attackdmg, DAMAGE_TYPE_PHYSICAL)
					
			local projectiles = hcreep:GetIncomingTrackingProjectiles()
			local casterdmg = 0
			local projloc = Vector(0,0,0)
					
			for i, proj in pairs(projectiles) do
				if proj.is_attack == true then
					local caster = proj.caster
							
					if caster ~= nil and caster:CanBeSeen() then
						casterdmg = caster:GetAttackDamage()
						projloc = proj.location
						break
					end
				end
			end
					
			local actualcasterdmg = hcreep:GetActualIncomingDamage(casterdmg, DAMAGE_TYPE_PHYSICAL)
				
			if hcreep:GetHealth() <= incdmg or ((hcreep:GetHealth() - actualcasterdmg) < incdmg and GetUnitToLocationDistance(hcreep, projloc) <= 300) then
				target = hcreep
				return true
			end
		end
	end
	
	return false
end

function IsCoreNearby()
	local AlliesWithinRange = bot:GetNearbyHeroes(1000, false, BOT_MODE_NONE)
	local FilteredAllies = PAF.FilterTrueUnits(AlliesWithinRange)
	
	if PRoles.GetPRole(bot, bot:GetUnitName()) == "SoftSupport"
	or PRoles.GetPRole(bot, bot:GetUnitName()) == "HardSupport" then
		for v, Ally in pairs(FilteredAllies) do
			if PRoles.GetPRole(Ally, Ally:GetUnitName()) == "MidLane"
			or PRoles.GetPRole(Ally, Ally:GetUnitName()) == "OffLane"
			or PRoles.GetPRole(Ally, Ally:GetUnitName()) == "SafeLane" then
				return true
			end
				
			if not Ally:IsBot() then
				return true
			end
		end
	end
	
	return false
end

function IsSuitableToLastHit()
	return bot:GetActiveMode() ~= BOT_MODE_EVASIVE_MANEUVERS
	and not P.IsRetreating(bot)
	and not PAF.IsEngaging(bot)
	and bot:GetHealth() > (bot:GetMaxHealth() * 0.35)
end

function ShouldRetreat()
	if not ShouldIgnoreRetreatMode() then
		--[[local AlliedHeroes = GetUnitList(UNIT_LIST_ALLIED_HEROES)
		for v, AllyHero in pairs(AlliedHeroes) do
			local ID = AllyHero:GetPlayerID()
			if not IsPlayerBot(ID) then
				local RecentPing = AllyHero:GetMostRecentPing()
				
				if RecentPing.normal_ping == false then
					if GameTime() - RecentPing.time <= 5 then
						if GetUnitToLocationDistance(bot, RecentPing.location) <= 1600 then
							StartRunTime = DotaTime()
							RetreatTime = 2.5
							return true
						end
					end
				end
			end
		end]]--
	
		if P.IsInLaningPhase() then
			local towers = bot:GetNearbyTowers(1000, true)
			if #towers >= 1 and PAF.IsEngaging(bot) then
				StartRunTime = DotaTime()
				RetreatTime = 1
				return true
			end
			
			--[[local EnemiesWithinRange = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
			local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
			local FearedEnemies = {}
			if #FilteredEnemies > 0 then
				for v, Enemy in pairs(FilteredEnemies) do
					if not P.IsMeepoClone(Enemy) then
						table.insert(FearedEnemies, Enemy)
					end
				end
			end
			
			local AlliesWithinRange = bot:GetNearbyHeroes(1200, false, BOT_MODE_NONE)
			local FilteredAllies = PAF.FilterTrueUnits(AlliesWithinRange)
			local ConsideredAllies = {}
			if #FilteredAllies > 0 then
				for v, Ally in pairs(FilteredAllies) do
					if not P.IsMeepoClone(Ally) then
						table.insert(ConsideredAllies, Ally)
					end
				end
			end
			
			if #ConsideredAllies < #FearedEnemies then
				StartRunTime = DotaTime()
				RetreatTime = 1.5
				return true
			end]]--
		else
			local EnemiesWithinRange = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
			local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
			local AlliesWithinRange = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
			local FilteredAllies = PAF.FilterTrueUnits(EnemiesWithinRange)
			local EnemyTowers = bot:GetNearbyTowers(1200, true)
			
			if #FilteredEnemies - #FilteredAllies >= 2 then
				StartRunTime = DotaTime()
				RetreatTime = 1.3
				return true
			end
		end
		
		if PAF.IsEngaging(bot) then
			local BotTarget = bot:GetTarget()
			
			if PAF.IsValidHeroAndNotIllusion(BotTarget) then
				local NearbyTowers = bot:GetNearbyTowers(1200, true)
						
				if GetUnitToLocationDistance(bot, PAF.GetFountainLocation(BotTarget)) <= 1200 then
					StartRunTime = DotaTime()
					RetreatTime = 1.65
					return true
				end
						
				if bot:GetLevel() < 6
				and GetUnitToLocationDistance(bot, PAF.GetFountainLocation(BotTarget)) <= 7500
				and (BotTarget:GetHealth() >= (BotTarget:GetMaxHealth() * 0.3)
				or GetUnitToUnitDistance(bot, BotTarget) > bot:GetAttackRange() + 200) then
					StartRunTime = DotaTime()
					RetreatTime = 2.1
					return true
				end
			end
		end
		
		return false
	end
end

function ShouldIgnoreRetreatMode()
	--[[if P.IsInPhalanxTeamFight(bot) then
		if bot:HasModifier("modifier_item_satanic_unholy") 
		or bot:HasModifier("modifier_abaddon_borrowed_time")
		or bot:HasModifier("modifier_item_mask_of_madness_berserk")
		or bot:HasModifier("modifier_oracle_false_promise_timer")
		or bot:HasModifier("modifier_black_king_bar_immune") then
			return true
		end
		
		if bot:GetUnitName() == "npc_dota_hero_razor" and bot:GetLevel() >= 6 then
			if bot:HasModifier("modifier_item_bloodstone_active") then
				return true
			end
		end
		
		if bot:GetUnitName() == "npc_dota_hero_skeleton_king" and bot:GetLevel() >= 6 then
			local Reincarnation = bot:GetAbilityByName("skeleton_king_reincarnation")
			
			if Reincarnation:GetCooldownTimeRemaining() <= 1 and bot:GetMana() >= Reincarnation:GetManaCost() then
				return true
			end
		end
	end]]--

	return false
end

function CanAttackWithPartner()
	--if PRoles.GetPRole(bot, bot:GetUnitName()) ~= "MidLane" then
		local allies = bot:GetNearbyHeroes(800, false, BOT_MODE_NONE)
		local enemies = bot:GetNearbyHeroes(600, true, BOT_MODE_NONE)
		local attacktarget = PAF.GetWeakestUnit(enemies)
		local AttackRange = bot:GetAttackRange()
		
		local CCPower = 2
		local TargetHealth = 0
		local EstimatedDamage = 0
		
		if attacktarget ~= nil then
			for v, AllyP in pairs(allies) do
				local StunDuration = AllyP:GetStunDuration(true)
				local SlowDuration = AllyP:GetSlowDuration(true)
				
				CCPower = CCPower + (StunDuration + SlowDuration)
			end
			
			for v, AllyP in pairs(allies) do
				EstimatedDamage = EstimatedDamage + AllyP:GetEstimatedDamageToTarget(true, attacktarget, CCPower, DAMAGE_TYPE_ALL)
			end
			
			local TargetHealth = attacktarget:GetHealth()
			print (EstimatedDamage.." to "..TargetHealth)
		end
		
		if attacktarget ~= nil and #allies >= 2 and EstimatedDamage > TargetHealth and GetUnitToUnitDistance(bot, attacktarget) <= 800 and GetUnitToUnitDistance(allies[2], attacktarget) <= 600 then
			PATarget = attacktarget
			return true
		end
	--end
	
	return false
end