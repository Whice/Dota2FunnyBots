local P = require(GetScriptDirectory() ..  "/Library/PhalanxFunctions");
local PRoles = require(GetScriptDirectory() .. "/Library/PhalanxRoles");
local PAF = require(GetScriptDirectory() ..  "/Library/PhalanxAbilityFunctions")

PIU = {}

PIU.Use = {}

local myTeam = GetTeam();
local opTeam = GetOpposingTeam();

local RadiantFountain = Vector(-7166.000000, -6659.000000, 0.000000);
local DireFountain = Vector(7024.000000, 6448.000000, 0.000000);

local giveTime = -90;

local teamT1Top = nil;
local teamT1Mid = nil;
local teamT1Bot = nil;
local enemyT1Top = nil;
local enemyT1Mid = nil;
local enemyT1Bot = nil;

if myTeam == TEAM_DIRE then
	teamT1Top = GetTower(myTeam,TOWER_TOP_1) == nil and Vector(-4693, 5998) or GetTower(myTeam,TOWER_TOP_1):GetLocation();
	teamT1Mid = GetTower(myTeam,TOWER_MID_1) == nil and Vector(530, 657) or GetTower(myTeam,TOWER_MID_1):GetLocation();
	teamT1Bot = GetTower(myTeam,TOWER_BOT_1) == nil and Vector(6262, -1687) or GetTower(myTeam,TOWER_BOT_1):GetLocation();
	enemyT1Top = GetTower(opTeam,TOWER_TOP_1) == nil and Vector(-6262, 1815) or GetTower(opTeam,TOWER_TOP_1):GetLocation();
	enemyT1Mid = GetTower(opTeam,TOWER_MID_1) == nil and Vector(-1530, -1412) or GetTower(opTeam,TOWER_MID_1):GetLocation();
	enemyT1Bot = GetTower(opTeam,TOWER_BOT_1) == nil and Vector(4949, -6130) or GetTower(opTeam,TOWER_BOT_1):GetLocation();
else
	teamT1Top = GetTower(myTeam,TOWER_TOP_1) == nil and Vector(-6262, 1815) or GetTower(myTeam,TOWER_TOP_1):GetLocation();
	teamT1Mid = GetTower(myTeam,TOWER_MID_1) == nil and Vector(-1530, -1412) or GetTower(myTeam,TOWER_MID_1):GetLocation();
	teamT1Bot = GetTower(myTeam,TOWER_BOT_1) == nil and Vector(4949, -6130) or GetTower(myTeam,TOWER_BOT_1):GetLocation();
	enemyT1Top = GetTower(opTeam,TOWER_TOP_1) == nil and Vector(-4693, 5998) or GetTower(opTeam,TOWER_TOP_1):GetLocation();
	enemyT1Mid = GetTower(opTeam,TOWER_MID_1) == nil and Vector(530, 657) or GetTower(opTeam,TOWER_MID_1):GetLocation();
	enemyT1Bot = GetTower(opTeam,TOWER_BOT_1) == nil and Vector(6262, -1687) or GetTower(opTeam,TOWER_BOT_1):GetLocation();
end

function PIU.IsHPHealing(bot)
	return bot:HasModifier('modifier_flask_healing') 
		or bot:HasModifier('modifier_tango_heal') 
		or bot:HasModifier('modifier_fountain_aura') 
		or bot:HasModifier("modifier_filler_heal")
		or bot:HasModifier("modifier_item_urn_heal")
		or bot:HasModifier("modifier_item_spirit_vessel_heal")
		or bot:HasModifier("modifier_bottle_regeneration")
end

function PIU.IsManaHealing(bot)
	return bot:HasModifier('modifier_clarity_potion') 
		or bot:HasModifier('modifier_fountain_aura') 
end

function PIU.IsForceStafed(target)
	return target:HasModifier('modifier_item_forcestaff_active') == true 
		or target:HasModifier('modifier_item_hurricane_pike_active') == true 
		or target:HasModifier('modifier_item_hurricane_pike_active_alternate') == true 
		or target:HasModifier('modifier_force_boots_active') == true 
end

function PIU.CanCastItem(item)
	return item~=nil and item:IsFullyCastable(); 
end 

function PIU.CanDodgeProjectile(bot, range)
	local incProj = bot:GetIncomingTrackingProjectiles()
	for _,p in pairs(incProj)
	do
		if p.is_dodgeable 
			and p.is_attack == false
			and GetUnitToLocationDistance(bot, p.location) <= range 
		then
			return true;
		end
	end
	return false;
end

function PIU.UseItemOnLocation(npc, item, loc)
    npc:Action_UseAbilityOnLocation(item, loc)
end

function PIU.CanSwitchPTStat(bot, pt)
	local pt_stat = pt:GetPowerTreadsStat();
	if bot:GetPrimaryAttribute() == ATTRIBUTE_STRENGTH and pt_stat ~= ATTRIBUTE_STRENGTH then
		return true;
	elseif bot:GetPrimaryAttribute() == ATTRIBUTE_AGILITY  and pt_stat ~= ATTRIBUTE_INTELLECT then
		return true;
	elseif bot:GetPrimaryAttribute() == ATTRIBUTE_INTELLECT and pt_stat ~= ATTRIBUTE_AGILITY then
		return true;
	end 
	return false;
end

function PIU.CheckFlag(bitfield, flag)
    return ((bitfield/flag) % 2) >= 1
end

function PIU.HasInvisCounterBuff(bot)
	return bot:HasModifier('modifier_item_dustofappearance') == true
		or bot:HasModifier('modifier_bounty_hunter_track') == true
		or bot:HasModifier('modifier_slardar_amplify_damage') == true
end

function PIU.GetNonDisabledStrongestEnemy(bot, nCastRange)

	local units = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
	local strongest_unit = nil;
	local maxPower = 0;
	for i=1, #units do
		if P.IsValidTarget(units[i]) == true
		   and P.CanCastOnNonMagicImmune(units[i]) == true 
		   and P.IsDisabled(true, units[i]) == false
		then
			local power = units[i]:GetEstimatedDamageToTarget( true, bot, 3.0, DAMAGE_TYPE_ALL );
			if power > maxPower then
				maxPower = power;
				strongest_unit = units[i];
			end
		end
	end
		
	return strongest_unit;

end

local enemyPids = nil;
local tpThreshold = 4500;

function PIU.GetDefendTPLocation(nLane)
	return GetLaneFrontLocation(opTeam,nLane,-1600)
end

function PIU.GetPushTPLocation(nLane)
	return GetLaneFrontLocation(myTeam,nLane,0)
end

function PIU.CanJuke(bot)
	if enemyPids == nil then
		enemyPids = GetTeamPlayers(GetOpposingTeam())
	end	
	local heroHG = GetHeightLevel(bot:GetLocation())
	for i = 1, #enemyPids do
		local info = GetHeroLastSeenInfo(enemyPids[i])
		if info ~= nil then
			local dInfo = info[1]; 
			if dInfo ~= nil and dInfo.time_since_seen < 2.5  
				and GetUnitToLocationDistance(bot,dInfo.location) < 1500 
				and GetHeightLevel(dInfo.location) <= heroHG + 1   
			then
				return false;
			end
		end	
	end
	return true;
end	

function PIU.GetLaningTPLocation(nLane)
	if nLane == LANE_TOP then
		return teamT1Top
	elseif nLane == LANE_MID then
		return teamT1Mid
	elseif nLane == LANE_BOT then
		return teamT1Bot			
	end	
	return teamT1Mid
end	

function PIU.GetNumHeroWithinRange(bot, nRange)
	if enemyPids == nil then
		enemyPids = GetTeamPlayers(GetOpposingTeam())
	end	
	local cHeroes = 0;
	for i = 1, #enemyPids do
		local info = GetHeroLastSeenInfo(enemyPids[i])
		if info ~= nil then
			local dInfo = info[1]; 
			if dInfo ~= nil and dInfo.time_since_seen < 2.0  
				and GetUnitToLocationDistance(bot,dInfo.location) < nRange 
			then
				cHeroes = cHeroes + 1;
			end
		end	
	end
	return cHeroes;
end	

function PIU.ShouldTP(bot)
    local stuckTP = false;
	local tpLoc = nil;
	local mode = bot:GetActiveMode();
	local modDesire = bot:GetActiveModeDesire();
	local botLoc = bot:GetLocation();
	local enemies = PIU.GetNumHeroWithinRange(bot, 1600);
	if P.IsStuck(bot) and enemies == 0 then
		bot:ActionImmediate_Chat("I'm teleporting due to being stuck.", false);
		tpLoc = GetAncient(GetTeam()):GetLocation()
	elseif mode == BOT_MODE_LANING and enemies == 0 then
		local assignedLane = bot:GetAssignedLane();
		if assignedLane == LANE_TOP  then
			local botAmount = GetAmountAlongLane(LANE_TOP, botLoc)
			local laneFront = GetLaneFrontAmount(myTeam, LANE_TOP, false)
			if botAmount.distance > tpThreshold or botAmount.amount < laneFront / 5 then 
				tpLoc = PIU.GetLaningTPLocation(LANE_TOP)
			end	
		elseif assignedLane == LANE_MID then
			local botAmount = GetAmountAlongLane(LANE_MID, botLoc)
			local laneFront = GetLaneFrontAmount(myTeam, LANE_MID, false)
			if botAmount.distance > tpThreshold or botAmount.amount < laneFront / 5 then 
				tpLoc = PIU.GetLaningTPLocation(LANE_MID)
			end	
		elseif assignedLane == LANE_BOT then
			local botAmount = GetAmountAlongLane(LANE_BOT, botLoc)
			local laneFront = GetLaneFrontAmount(myTeam, LANE_BOT, false)
			if botAmount.distance > tpThreshold or botAmount.amount < laneFront / 5 then 
				tpLoc = PIU.GetLaningTPLocation(LANE_BOT)
			end	
		end
	elseif mode == BOT_MODE_DEFEND_TOWER_TOP and modDesire >= BOT_MODE_DESIRE_MODERATE and enemies == 0 then
		local botAmount = GetAmountAlongLane(LANE_TOP, botLoc)
		local laneFront = GetLaneFrontAmount(myTeam, LANE_TOP, false)
		if botAmount.distance > tpThreshold or botAmount.amount < laneFront / 5 then 
			tpLoc = PIU.GetDefendTPLocation(LANE_TOP)
		end	
	elseif mode == BOT_MODE_DEFEND_TOWER_MID and modDesire >= BOT_MODE_DESIRE_MODERATE and enemies == 0 then
		local botAmount = GetAmountAlongLane(LANE_MID, botLoc)
		local laneFront = GetLaneFrontAmount(myTeam, LANE_MID, false)
		if botAmount.distance > tpThreshold or botAmount.amount < laneFront / 5 then 
			tpLoc = PIU.GetDefendTPLocation(LANE_MID)
		end	
	elseif mode == BOT_MODE_DEFEND_TOWER_BOT and modDesire >= BOT_MODE_DESIRE_MODERATE and enemies == 0 then	
		local botAmount = GetAmountAlongLane(LANE_BOT, botLoc)
		local laneFront = GetLaneFrontAmount(myTeam, LANE_BOT, false)
		if botAmount.distance > tpThreshold or botAmount.amount < laneFront / 5 then 
			tpLoc = PIU.GetDefendTPLocation(LANE_BOT)
		end	
--[[	elseif mode == BOT_MODE_PUSH_TOWER_TOP and modDesire >= BOT_MODE_DESIRE_MODERATE and enemies == 0 then
		local botAmount = GetAmountAlongLane(LANE_TOP, botLoc)
		local laneFront = GetLaneFrontAmount(myTeam, LANE_TOP, false)
		if botAmount.distance > tpThreshold or botAmount.amount < laneFront / 5 then 
			tpLoc = PIU.GetPushTPLocation(LANE_TOP)
		end	
	elseif mode == BOT_MODE_PUSH_TOWER_MID and modDesire >= BOT_MODE_DESIRE_MODERATE and enemies == 0 then
		local botAmount = GetAmountAlongLane(LANE_MID, botLoc)
		local laneFront = GetLaneFrontAmount(myTeam, LANE_MID, false)
		if botAmount.distance > tpThreshold or botAmount.amount < laneFront / 5 then 
			tpLoc = PIU.GetPushTPLocation(LANE_MID)
		end	
	elseif mode == BOT_MODE_PUSH_TOWER_BOT and modDesire >= BOT_MODE_DESIRE_MODERATE and enemies == 0 then
		local botAmount = GetAmountAlongLane(LANE_BOT, botLoc)
		local laneFront = GetLaneFrontAmount(myTeam, LANE_BOT, false)
		if botAmount.distance > tpThreshold or botAmount.amount < laneFront / 5 then 
			tpLoc = PIU.GetPushTPLocation(LANE_BOT)
		end	]]--
	elseif mode == BOT_MODE_DEFEND_ALLY and modDesire >= BOT_MODE_DESIRE_MODERATE and (PRoles.GetPRole(bot, bot:GetUnitName()) == "SoftSupport" or PRoles.GetPRole(bot, bot:GetUnitName()) == "HardSupport") and enemies == 0 then
		local target = bot:GetTarget()
		if target ~= nil and target:IsHero() then
			local nearbyTower = target:GetNearbyTowers(1300, true)
			if nearbyTower ~= nil and #nearbyTower > 0 and bot:GetMana() >  0.25*bot:GetMaxMana()  then
				tpLoc = nearbyTower[1]:GetLocation()
			end
		end
	elseif mode == BOT_MODE_RETREAT and modDesire >= BOT_MODE_DESIRE_HIGH 
	then
		if bot:GetHealth() < 0.15*bot:GetMaxHealth() and bot:WasRecentlyDamagedByAnyHero(2.0) and enemies == 0 then
			tpLoc = P.GetTeamFountain();
		elseif bot:GetHealth() < 0.25*bot:GetMaxHealth() and bot:WasRecentlyDamagedByAnyHero(3.0) and PIU.CanJuke(bot) == true then
			-- print(bot:GetUnitName().." JUKE TP")
			tpLoc = P.GetTeamFountain();	
		end
	elseif bot:HasModifier('modifier_bloodseeker_rupture') and enemies <= 1 then
		local allies = bot:GetNearbyHeroes(1000, false, BOT_MODE_NONE);
		if #allies <= 1 then
			tpLoc = P.GetTeamFountain();
		end
	end	
	if ( stuckTP == true and tpLoc ~= nil ) or ( stuckTP == false and tpLoc ~= nil and GetUnitToLocationDistance(bot, tpLoc) > 2000 ) then
		return true, tpLoc;
	end
	return false, nil;
end

function PIU.GetItemCount(unit, item_name)
	local count = 0;
	for i = 0, 8 
	do
		local item = unit:GetItemInSlot(i)
		if item ~= nil and item:GetName() == item_name then
			count = count + 1;
		end
	end
	return count;
end

function PIU.GiveToMidLaner(bot)
	local teamPlayers = GetTeamPlayers(GetTeam())
	local target = nil;
	for k,v in pairs(teamPlayers)
	do
		local member = GetTeamMember(k);
		if member ~= nil and member ~= bot and not member:IsIllusion() and member:IsAlive() then
			local num_stg = PIU.GetItemCount(member, "item_tango_single"); 
			local num_ff = PIU.GetItemCount(member, "item_faerie_fire"); 
			if num_ff > 0 and num_stg < 2 then
				return member;
			end
		end
	end
	return nil;
end

function PIU.IsInventoryFull(bot)
	for i = 6, 8 do
		local item = bot:GetItemInSlot(i);
		if item == nil then
			return false;
		end	
	end	
	return true;
end

function PIU.IsUnitWillGoInvisible(unit)
	return unit:HasModifier('modifier_sandking_sand_storm') == true
		or unit:HasModifier('modifier_bounty_hunter_wind_walk') == true
		or unit:HasModifier('modifier_clinkz_wind_walk') == true
		or unit:HasModifier('modifier_weaver_shukuchi') == true
		or ( unit:HasModifier('modifier_oracle_false_promise') == true and unit:HasModifier('modifier_oracle_false_promise_invis') == true )
		or ( unit:HasModifier('modifier_windrunner_windrun') == true and unit:HasModifier('modifier_windrunner_windrun_invis') == true )
		or unit:HasModifier('modifier_item_invisibility_edge') == true
		or unit:HasModifier('modifier_item_invisibility_edge_windwalk') == true
		or unit:HasModifier('modifier_item_silver_edge') == true
		or unit:HasModifier('modifier_item_silver_edge_windwalk') == true
		or unit:HasModifier('modifier_item_glimmer_cape_fade') == true
		or unit:HasModifier('modifier_item_glimmer_cape') == true
		or unit:HasModifier('modifier_item_shadow_amulet') == true
		or unit:HasModifier('modifier_item_shadow_amulet_fade') == true
		
end

function PIU.GetXUnitsTowardsLocation( iLoc, tLoc, nUnits)
    local direction = (tLoc - iLoc):Normalized()
    return iLoc + direction * nUnits;
end

local allyPids = nil;
function PIU.IsClosestToDustLocation(bot, loc)
	if allyPids == nil then
		allyPids = GetTeamPlayers(myTeam)
	end	
	local closest = nil;
	local closest_dist = 100000;
	for i=1, #allyPids
	do
		local member = GetTeamMember(allyPids[i]);
		if member ~= nil 
			and not member:IsIllusion() 
			and member:IsAlive() 
			and member:GetItemSlotType(member:FindItemSlot('item_dust')) == ITEM_SLOT_TYPE_MAIN
			and member:GetItemInSlot(member:FindItemSlot('item_dust')):IsFullyCastable() == true
		then
			local dist = GetUnitToLocationDistance(member, loc);
			if dist <= closest_dist then
				closest = member;
				closest_dist = dist;
			end
		end
	end
	return closest == bot;
end

-------ITEM USAGE---------
local enemyPids = nil;
local castDustTime = -90;
--item_dust
PIU.Use['item_dust'] = function(item, bot, mode, extra_range)
	
	-- if DotaTime() < castDustTime + 0.5 then return BOT_ACTION_DESIRE_NONE end
	
	local nRadius = 1050;
	
	if enemyPids == nil then
		enemyPids = GetTeamPlayers(GetOpposingTeam())
	end	
	for i = 1, #enemyPids do
		local info = GetHeroLastSeenInfo(enemyPids[i])
		if IsHeroAlive(enemyPids[i]) == true and info ~= nil then
			local dInfo = info[1]; 
			if dInfo ~= nil 
				and dInfo.time_since_seen > 0.20 
				and dInfo.time_since_seen < 0.50 
				and GetUnitToLocationDistance(bot, dInfo.location) + 150 <  nRadius 
				and PIU.IsClosestToDustLocation(bot, dInfo.location)
			then	
				local front_loc = PIU.GetXUnitsTowardsLocation( dInfo.location, DireFountain, 200)
				if myTeam == TEAM_DIRE then
					front_loc = PIU.GetXUnitsTowardsLocation( dInfo.location, RadiantFountain, 200)
				end
				if IsLocationVisible(front_loc) == true and IsLocationPassable(front_loc) == true then
					-- print('sec 1')
					castDustTime = DotaTime();
					return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
				end
			end
		end	
	end
	
	local enemies = bot:GetNearbyHeroes(1000, true, BOT_MODE_NONE)
	if #enemies == 0 then
		if bot:HasModifier('modifier_item_radiance_debuff') 
			or bot:HasModifier('modifier_sandking_sand_storm_slow') 
			or bot:HasModifier('modifier_sandking_sand_storm_slow_aura_thinker') 
		then
			-- print('sec 2')
			castDustTime = DotaTime();
			return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
		end
		for i = 1, #enemyPids do
			if IsHeroAlive(enemyPids[i]) == true 
				and bot:WasRecentlyDamagedByPlayer(enemyPids[i], 0.5) == true  
			then
				-- print('sec 3')
				local info = GetHeroLastSeenInfo(enemyPids[i])	
				local dInfo = info[1]; 
				if dInfo ~= nil and GetUnitToLocationDistance(bot, dInfo.location) < nRadius 
				then
					castDustTime = DotaTime();
					return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
				end
			end
		end
	else
		for i=1, #enemies do
			if P.IsValidTarget(enemies[i])
				and PIU.HasInvisCounterBuff(enemies[i]) == false
				and PIU.IsUnitWillGoInvisible(enemies[i]) == true
				and PIU.IsClosestToDustLocation(bot, enemies[i]:GetLocation())
			then
				local towers = enemies[i]:GetNearbyTowers(750, true);
				if towers == nil or #towers == 0 then
					-- print('sec 4')
					castDustTime = DotaTime();
					return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
				end
			end	
		end	
	end
	
	return BOT_ACTION_DESIRE_NONE;
	
end

--item_tpscroll
PIU.Use['item_tpscroll'] = function(item, bot, mode, extra_range)
	local MinDistanceForTP = 5500
	local MaxDistanceFromBuilding = 800
	local CurrentMode = bot:GetActiveMode()
	local CurrentModeDesire = bot:GetActiveModeDesire()
	
	local NearbyHeroes = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
	local NearbyTowers = bot:GetNearbyTowers(750, true)
	if #NearbyHeroes > 0
	or #NearbyTowers > 0
	or CurrentMode == BOT_MODE_RUNE then
		return BOT_ACTION_DESIRE_NONE
	end
	
	local HasTravelBootsAvailable = false
	if bot:FindItemSlot("item_travel_boots") >= 0
	or bot:FindItemSlot("item_travel_boots_2") >= 0 then
		HasTravelBootsAvailable = true
	end
	
	if P.IsInLaningPhase(bot) then
		if CurrentMode == BOT_MODE_LANING then
			local LaneBuilding = PAF.GetFurthestBuildingOnLane(bot:GetAssignedLane())
			if GetUnitToUnitDistance(bot, LaneBuilding) >= MinDistanceForTP then
				return BOT_ACTION_DESIRE_ABSOLUTE, LaneBuilding:GetLocation(), 'point'
			end
		end
	end
	
	if (CurrentMode == BOT_MODE_DEFEND_TOWER_TOP
	or CurrentMode == BOT_MODE_DEFEND_TOWER_MID
	or CurrentMode == BOT_MODE_DEFEND_TOWER_BOT)
	and CurrentModeDesire >= BOT_MODE_DESIRE_LOW then
		local FurthestBuilding = nil
		
		if CurrentMode == BOT_MODE_DEFEND_TOWER_TOP then
			FurthestBuilding = PAF.GetFurthestBuildingOnLane(LANE_TOP)
		elseif CurrentMode == BOT_MODE_DEFEND_TOWER_MID then
			FurthestBuilding = PAF.GetFurthestBuildingOnLane(LANE_MID)
		elseif CurrentMode == BOT_MODE_DEFEND_TOWER_BOT then
			FurthestBuilding = PAF.GetFurthestBuildingOnLane(LANE_BOT)
		end
		
		if FurthestBuilding ~= nil then
			if GetUnitToUnitDistance(bot, FurthestBuilding) >= MinDistanceForTP then
				local tpLoc = FurthestBuilding:GetXUnitsTowardsLocation(PAF.GetFountainLocation(bot), MaxDistanceFromBuilding)
				return BOT_ACTION_DESIRE_ABSOLUTE, tpLoc, 'point'
			end
		end
	end
	
	local AlliedHeroes = GetUnitList(UNIT_LIST_ALLIED_HEROES)
	local FilteredAllies = PAF.FilterTrueUnits(AlliedHeroes)
	
	--[[if not P.IsInLaningPhase() then
		for v, Ally in pairs(FilteredAllies) do
			if PAF.IsInTeamFight(Ally) then
				if GetUnitToUnitDistance(bot, Ally) >= MinDistanceForTP then
					local ClosestTP = PAF.GetClosestTPLocation(bot, Ally, HasTravelBootsAvailable)
					if GetUnitToUnitDistance(bot, ClosestTP) >= MinDistanceForTP
					and GetUnitToUnitDistance(Ally, ClosestTP) <= 1600 then
						return BOT_ACTION_DESIRE_ABSOLUTE, ClosestTP:GetLocation(), 'point'
					end
				end
			end
		end
	end]]--
	
	if CurrentMode == BOT_MODE_DEFEND_ALLY
	and CurrentModeDesire >= BOT_MODE_DESIRE_LOW
	and (PRoles.GetPRole(bot, bot:GetUnitName()) == "SoftSupport"
	or PRoles.GetPRole(bot, bot:GetUnitName()) == "HardSupport") then
		local BotTarget = bot:GetTarget()
		if BotTarget ~= nil then
			if GetUnitToUnitDistance(bot, BotTarget) >= MinDistanceForTP then
				local ClosestTP = PAF.GetClosestTPLocation(bot, BotTarget, HasTravelBootsAvailable)
				
				if GetUnitToUnitDistance(bot, ClosestTP) >= MinDistanceForTP
				and GetUnitToUnitDistance(BotTarget, ClosestTP) <= 1000 then
					return BOT_ACTION_DESIRE_ABSOLUTE, ClosestTP:GetLocation(), 'point'
				end
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE
end

--item_tango
PIU.Use['item_tango'] = function(item, bot, mode, extra_range)
	
	local tCharge = item:GetCurrentCharges()
	if DotaTime() > -80 and DotaTime() < 0 and bot:DistanceFromFountain() == 0 and (PRoles.GetPRole(bot, bot:GetUnitName()) == "SoftSupport" or PRoles.GetPRole(bot, bot:GetUnitName()) == "HardSupport")
	   and bot:GetAssignedLane() ~= LANE_MID and tCharge > 2 and DotaTime() > giveTime + 2.0 then
		--[[local target = PIU.GiveToMidLaner(bot)
		if target ~= nil then
			giveTime = DotaTime();
			return BOT_ACTION_DESIRE_ABSOLUTE, target, 'unit';
		end]]--
	elseif bot:GetActiveMode() == BOT_MODE_LANING and (PRoles.GetPRole(bot, bot:GetUnitName()) == "SoftSupport" or PRoles.GetPRole(bot, bot:GetUnitName()) == "HardSupport") and tCharge > 1 and DotaTime() > giveTime + 2.0 then
		local allies = bot:GetNearbyHeroes(600, false, BOT_MODE_NONE)
		for _,ally in pairs(allies)
		do
			local tangoSlot = ally:FindItemSlot('item_tango');
			local single_tangoSlot = ally:FindItemSlot('item_tango_single');
			if ally:GetUnitName() ~= bot:GetUnitName() and not ally:IsIllusion() and DotaTime() > 0
			   and tangoSlot == -1 and single_tangoSlot == -1
			   and not PIU.IsHPHealing(ally) and ally:GetHealth() <= (ally:GetMaxHealth() * 0.8)
			then
				giveTime = DotaTime();
				return BOT_ACTION_DESIRE_ABSOLUTE, ally, 'unit';
			end
		end
	end

	return PIU.Use['item_tango_single'](item, bot, mode, extra_range);
end

--item_tango_single
PIU.Use['item_tango_single'] = function(item, bot, mode, extra_range)

	if bot:DistanceFromFountain() < 2500 or PIU.IsHPHealing(bot) == true then return BOT_ACTION_DESIRE_NONE end
	
	local health_regen = 7.0;
	local duration = 16;
	local total_heal = ( bot:GetHealthRegen() + health_regen ) * duration;
	
	if bot:GetHealth() + total_heal <= bot:GetMaxHealth() then
		local trees = bot:GetNearbyTrees(600);
		local enemies = bot:GetNearbyHeroes(1300, true, BOT_MODE_NONE);
		local closest_enemy = enemies[1];
		local towers = bot:GetNearbyTowers(1300, true);
		local closest_tower = towers[1];
		for i=1, #trees do
			local tree_loc = GetTreeLocation(trees[i]);
			if IsLocationVisible(tree_loc)
				and IsLocationPassable(tree_loc)
				and ( #enemies == 0 or GetUnitToLocationDistance(bot, tree_loc) * 1.5 <  GetUnitToUnitDistance(bot, closest_enemy) )
				and ( #towers == 0 or GetUnitToLocationDistance(closest_tower, tree_loc) > 750 )
			then
				return BOT_ACTION_DESIRE_ABSOLUTE, trees[i], 'tree';
			end	
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end

--item_flask
PIU.Use['item_flask'] = function(item, bot, mode, extra_range)
	if bot:WasRecentlyDamagedByAnyHero(3.1) then return 0 end

	local health_regen = 30;
	local duration = 13;
	local total_heal = ( bot:GetHealthRegen() + health_regen ) * duration;
	
	if bot:GetHealth() + total_heal <= bot:GetMaxHealth() then
		local enemies = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE);
		if #enemies == 0 then
			return BOT_ACTION_DESIRE_ABSOLUTE, bot, 'unit';
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end

--item_clarity
PIU.Use['item_clarity'] = function(item, bot, mode, extra_range)

	if PIU.IsManaHealing(bot) == true then return BOT_ACTION_DESIRE_NONE end

	local mana_regen = 6;
	local duration = 25;
	local total_mana = ( bot:GetManaRegen() + mana_regen ) * duration;
	
	if bot:GetMana() + total_mana <= bot:GetMaxMana() 
	and bot:WasRecentlyDamagedByAnyHero(3.1) == false 
	then
		local enemies = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE);
		if #enemies == 0 then
			return BOT_ACTION_DESIRE_ABSOLUTE, bot, 'unit';
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end

--item_faerie_fire
PIU.Use['item_faerie_fire'] = function(item, bot, mode, extra_range)
	
	if ( P.IsRetreating(bot) and
		( bot:GetHealth() / bot:GetMaxHealth() ) < 0.15 ) 
		or DotaTime() > 10*60
	then
		return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
	end
	
	if PIU.IsInventoryFull(bot) == true then
		return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
	end
	
	return BOT_ACTION_DESIRE_NONE;
end

--item_enchanted_mango
PIU.Use['item_enchanted_mango'] = function(item, bot, mode, extra_range)
	
	if bot:GetMana() < 0.30*bot:GetMaxMana() 
		and mode == BOT_MODE_ATTACK 
		or DotaTime() > 10*60
	then
		return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
	end
	
	return BOT_ACTION_DESIRE_NONE;
end

--item_tome_of_knowledge
PIU.Use['item_tome_of_knowledge'] = function(item, bot, mode, extra_range)
	return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
end

PIU.Use['item_bottle'] = function(item, bot, mode, extra_range)
	local nCastRange = 350 + extra_range
	local Charges = item:GetCurrentCharges()
	
	local HPRegen = 110
	local ManaRegen = 60
	local Duration = 2.7
	
	local TotalHPRegen = (HPRegen * Duration)
	local TotalManaRegen = (ManaRegen * Duration)
	
	if Charges > 0 then
		if bot:DistanceFromFountain() <= 50 then
			if bot:GetHealth() < bot:GetMaxHealth()
			or bot:GetMana() < bot:GetMaxMana() then
				return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target'
			end
		else
			if bot:GetActiveMode() == BOT_MODE_RUNE
			and bot:GetActiveModeDesire() >= 0.75 then
				return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target'
			end
			
			if not bot:WasRecentlyDamagedByAnyHero(2)
			and not bot:HasModifier("modifier_bottle_regeneration") then
				local BotHealthRegen = (bot:GetHealthRegen() * Duration)
				local CombinedHPRegen = (TotalHPRegen + BotHealthRegen)
				local BotManaRegen = (bot:GetManaRegen() * Duration)
				local CombinedManaRegen = (TotalManaRegen + BotManaRegen)
				
				if bot:GetHealth() < (bot:GetMaxHealth() - (CombinedHPRegen - 100))
				and bot:GetMana() < (bot:GetMaxMana() - (CombinedManaRegen - 100)) then
					return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target'
				end
				
				if bot:GetHealth() < (bot:GetMaxHealth() * 0.7)
				or bot:GetMana() < (bot:GetMaxMana() * 0.5) then
					return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target'
				end
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE
end

--item_bottle
--RUNE_INVALID -1
--RUNE_DOUBLEDAMAGE 0
--RUNE_HASTE 1
--RUNE_ILLUSION 2
--RUNE_INVISIBILITY 3
--RUNE_REGENERATION 4
--RUNE_BOUNTY 5
--RUNE_ARCANE 6
--[[PIU.Use['item_bottle'] = function(item, bot, mode, extra_range)

	local nCastRange = 350 + extra_range
	local charges = item:GetCurrentCharges()
	
	local nHP = 110
	local nMP = 60
	local duration = 2.7
	
	if bot:DistanceFromFountain() == 0 
		and bot.RuneType == RUNE_INVALID
		and bot:HasModifier('modifier_bottle_regeneration') == false 
		and ( bot:GetHealth() < bot:GetMaxHealth() or bot:GetMana() < bot:GetMaxMana() ) 
	then
		bot.RuneType = RUNE_INVALID
		return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target'
	end

	if charges > 0 then
		if bot:WasRecentlyDamagedByAnyHero(3.15) == false 
			and bot:HasModifier('modifier_bottle_regeneration') == false 
			and  ( bot:GetHealth() + nHP*duration < 0.75*bot:GetMaxHealth() 
			or bot:GetMana() + nMP*duration < 0.75*bot:GetMaxMana() )
		then
			bot.RuneType = RUNE_INVALID;
			return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
		end
		
		if bot.RuneType == RUNE_BOUNTY then
			bot.RuneType = RUNE_INVALID;
			return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
		elseif bot.RuneType == RUNE_DOUBLEDAMAGE or bot.RuneType == RUNE_ARCANE then
			if 	P.IsGoingOnSomeone(bot)
			then
				local target = bot:GetTarget();
				if  P.IsValidTarget(target) 
					and P.IsInRange(target, bot, 1000) == true
				then
					bot.RuneType = RUNE_INVALID;
					return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
				end
			end	
		elseif bot.RuneType == RUNE_ILLUSION or bot.RuneType == RUNE_HASTE then
			if 	P.IsGoingOnSomeone(bot)
			then
				local target = bot:GetTarget();
				if  P.IsValidTarget(target) 
					and P.IsInRange(target, bot, 1000) == true
				then
					bot.RuneType = RUNE_INVALID;
					return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
				end
			end	
			if P.IsRetreating(bot) 
				and bot:WasRecentlyDamagedByAnyHero(2.5) 
			then
				local enemies = bot:GetNearbyHeroes(1300, true, BOT_MODE_NONE)
				if #enemies > 0 then
					bot.RuneType = RUNE_INVALID;
					return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
				end
			end		
		elseif bot.RuneType == RUNE_INVISIBILITY then
			if P.IsRetreating(bot) 
				and bot:WasRecentlyDamagedByAnyHero(2.5) 
			then
				local enemies = bot:GetNearbyHeroes(1300, true, BOT_MODE_NONE)
				if #enemies > 0 then
					bot.RuneType = RUNE_INVALID;
					return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
				end
			end	
		elseif bot.RuneType == RUNE_REGENERATION then
			if P.IsRetreating(bot) 
				and bot:WasRecentlyDamagedByAnyHero(3.15) == false 
			then
				local enemies = bot:GetNearbyHeroes(1300, true, BOT_MODE_NONE)
				if #enemies == 0 then
					bot.RuneType = RUNE_INVALID;
					return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
				end
			end	
		elseif bot.RuneType == RUNE_WATER then
			bot.RuneType = RUNE_INVALID;
			return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
		end
	end

	return BOT_ACTION_DESIRE_NONE;
end]]--

--item_quelling_blade
PIU.Use['item_quelling_blade'] = function(item, bot, mode, extra_range)
	if bot:GetUnitName() ~= 'npc_dota_hero_monkey_king' 
		and ( P.IsGoingOnSomeone(bot) == true 
		or ( P.IsRetreating(bot) == true and bot:IsInvisible() == false ) )
	then	
		local nCastRange = 300 + extra_range;
		local trees = bot:GetNearbyTrees(nCastRange);
		for i=1,#trees do
			if bot:IsFacingLocation(GetTreeLocation(trees[i]), 5) then
				return BOT_ACTION_DESIRE_ABSOLUTE, trees[i], 'tree';
			end
		end
	end	
	return BOT_ACTION_DESIRE_NONE;
end

--item_magic_stick
PIU.Use['item_magic_stick'] = function(item, bot, mode, extra_range)

	local charges = item:GetCurrentCharges();
	local hp_ratio = bot:GetHealth() / bot:GetMaxHealth();
	local mp_ratio = bot:GetMana() / bot:GetMaxMana();
	
	if charges > 5 
		and P.IsGoingOnSomeone(bot)
		and hp_ratio < 0.55 and mp_ratio < 0.25
	then
		local enemies = bot:GetNearbyHeroes(800, true, BOT_MODE_NONE);
		if #enemies > 0 
		then
			return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
		end
	elseif charges > 1 
		and P.IsRetreating(bot)
		and ( bot:WasRecentlyDamagedByAnyHero(2.0) == true or bot:WasRecentlyDamagedByTower(3.0) == true )
	then
		local enemies = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE);
		if #enemies > 0 
		then
			return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
		end
	end	

	return BOT_ACTION_DESIRE_NONE;
end

--item_shadow_amulet
PIU.Use['item_shadow_amulet'] = function(item, bot, mode, extra_range)
	
	local nCastRange = 600 + extra_range;
	
	if bot:IsInvisible() == false
		and bot:HasModifier('modifier_item_glimmer_cape') == false
		and bot:HasModifier('modifier_item_shadow_amulet_fade') == false
		and PIU.HasInvisCounterBuff(bot) == false
		and DotaTime() + bot.castAmuletTime + 1.275
	then	
	
		local towers = bot:GetNearbyTowers(750,true);
		if #towers == 0 then
			local enemies = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
			for i=1, #enemies do
				if P.IsValidTarget(enemies[i])
					and ( enemies[i]:GetAttackTarget() == bot
					or enemies[i]:IsFacingLocation(bot:GetLocation(), 15) )
				then
					bot.castAmuletTime = DotaTime();
					return BOT_ACTION_DESIRE_ABSOLUTE, bot, 'unit';
				end	
			end
			
			if bot:IsSilenced() == true and #enemies > 0
			then
				bot.castAmuletTime = DotaTime();
				return BOT_ACTION_DESIRE_ABSOLUTE, bot, 'unit';	
			end
		end
	end
	
	local allies = bot:GetNearbyHeroes(nCastRange,false,BOT_MODE_NONE);
	for i = 1, #allies
	do
		local towers = allies[i]:GetNearbyTowers(750,true);
		if #towers == 0 then
			if P.IsValidTarget(allies[i])
			   and allies[i] ~= bot
			   and allies[i]:IsIllusion() == false
			   and P.CanCastOnNonMagicImmune(allies[i])
			   and allies[i]:IsInvisible() == false
			   and allies[i]:HasModifier('modifier_item_glimmer_cape') == false
			   and allies[i]:HasModifier('modifier_item_shadow_amulet_fade') == false
			   and PIU.HasInvisCounterBuff(allies[i]) == false
			   and ( allies[i]:IsStunned() == true or allies[i]:IsSilenced() == true or allies[i]:IsNightmared() == true )
			then
				return BOT_ACTION_DESIRE_ABSOLUTE, allies[i], 'unit';
			end
		end	
	end

	return BOT_ACTION_DESIRE_NONE;
end

--item_ghost
PIU.Use['item_ghost'] = function(item, bot, mode, extra_range)
	if P.IsRetreating(bot) 
		and ( bot:WasRecentlyDamagedByAnyHero(2.5) == true or bot:WasRecentlyDamagedByTower(3.0) == true ) 
	then
		local enemies = bot:GetNearbyHeroes(1300, true, BOT_MODE_NONE)
		if #enemies > 0 then
			return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
		end
	end
	return BOT_ACTION_DESIRE_NONE;
end

--item_blink
PIU.Use['item_blink'] = function(item, bot, mode, extra_range)

	if bot:IsRooted() then return 0 end
	
	local nCastRange = (1200 + extra_range)
	if item:GetName() == "item_arcane_blink" then
		nCastRange = (1400 + extra_range)
	end

	local AttackRange = bot:GetAttackRange()
	local Allies = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
	local FilteredAllies = PAF.FilterTrueUnits(Allies)
	local Enemies = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(Enemies)
	
	if P.IsRetreating(bot) then
		return BOT_ACTION_DESIRE_HIGH, bot:GetXUnitsTowardsLocation(PAF.GetFountainLocation(bot), nCastRange), 'point'
	end
	
	local projectiles = bot:GetIncomingTrackingProjectiles()
	
	for v, proj in pairs(projectiles) do
		if GetUnitToLocationDistance(bot, proj.location) <= 200
		and proj.is_dodgeable
		and proj.is_attack == false then
			return BOT_ACTION_DESIRE_ABSOLUTE, (bot:GetLocation()+RandomVector(150)), 'point'
		end
	end
	
	if PAF.IsEngaging(bot) then
		local BotTarget = bot:GetTarget()
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			local CombinedAllyPower = PAF.CombineOffensivePower(FilteredAllies, true)
			local CombinedEnemyPower = PAF.CombineOffensivePower(FilteredEnemies, true)
			
			if CombinedAllyPower >= CombinedEnemyPower then
				if GetUnitToUnitDistance(bot, BotTarget) <= nCastRange
				and GetUnitToUnitDistance(bot, BotTarget) > (AttackRange + 150) then
					if bot:GetUnitName() == "npc_dota_hero_magnataur" then
						local Skewer = bot:GetAbilityByName("magnataur_skewer")
						if Skewer:IsFullyCastable() then
							local Radius = Skewer:GetSpecialValueInt("skewer_radius")
							return BOT_ACTION_DESIRE_HIGH, BotTarget:GetXUnitsTowardsLocation(PAF.GetFountainLocation(BotTarget), Radius), 'point'
						end
					end
					
					return BOT_ACTION_DESIRE_ABSOLUTE, BotTarget:GetLocation(), 'point'
				end
			end
			
			if PAF.IsChasing(bot, BotTarget) then
				local AoECount = PAF.GetUnitsNearTarget(BotTarget:GetLocation(), FilteredEnemies, 800)
					
				if AoECount <= 2 then
					if GetUnitToUnitDistance(bot, BotTarget) <= (nCastRange + (AttackRange + 150))
					and GetUnitToUnitDistance(bot, BotTarget) > (AttackRange + 150) then
						return BOT_ACTION_DESIRE_HIGH, BotTarget:GetExtrapolatedLocation(1), 'point'
					end
				end
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end

--item_magic_wand
PIU.Use['item_magic_wand'] = function(item, bot, mode, extra_range)
	return PIU.Use['item_magic_stick'](item, bot, mode, extra_range);
end

--item_soul_ring
PIU.Use['item_soul_ring'] = function(item, bot, mode, extra_range)
	if  P.IsGoingOnSomeone(bot) and bot:GetHealth() - 150 > 0.25 * bot:GetMaxHealth() and bot:GetMana() < 0.5 * bot:GetMaxMana() then
		local target = bot:GetTarget();
		if  P.IsValidTarget(target) 
			and P.IsInRange(target, bot, bot:GetAttackRange() + 250) 
		then	
			local skillslot = {0,1,2,3,4,5};
			for i=1, #skillslot do
				local ability = bot:GetAbilityInSlot(skillslot[i]);
				if ability ~= nil 
					and ability:IsTrained() == true
					and PIU.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_PASSIVE) == false
					and PIU.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_HIDDEN) == false
					and ( ( ability:GetCooldownTimeRemaining() == 0 and ability:IsFullyCastable() == false ) or ability:IsFullyCastable() )
					
				then
					return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
				end
			end
		end		
	end
	return BOT_ACTION_DESIRE_NONE;
end

--item_power_treads
PIU.Use['item_power_treads'] = function(item, bot, mode, extra_range)
	local tread_stat = item:GetPowerTreadsStat();
	if P.IsRetreating(bot) == true and tread_stat ~= ATTRIBUTE_STRENGTH and bot:WasRecentlyDamagedByAnyHero(5.0) == true then
		return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
	elseif P.IsRetreating(bot) == false and PIU.IsHPHealing(bot) == true and bot:GetHealth() < 0.95*bot:GetMaxHealth() and tread_stat == ATTRIBUTE_STRENGTH then
		return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';	
	elseif PIU.IsHPHealing(bot) == false and bot:WasRecentlyDamagedByAnyHero(3.0) == false and P.IsRetreating(bot) == false then
		local enemies = bot:GetNearbyHeroes( 1200, true, BOT_MODE_NONE );
		if #enemies == 0 and PIU.CanSwitchPTStat(bot, item) == true  then
			return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
		end
	end
	return BOT_ACTION_DESIRE_NONE;
end

--item_mask_of_madness
PIU.Use['item_mask_of_madness'] = function(item, bot, mode, extra_range)
	local skillslot = {0,1,2,3,4,5};
	local n_ability = 0;
	for i=1, #skillslot do
		local ability = bot:GetAbilityInSlot(skillslot[i]);
		if ability ~= nil 
			and ability:IsTrained() == true
			and PIU.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_PASSIVE) == false
			and PIU.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_HIDDEN) == false
		then
			n_ability = n_ability + 1;
			if ability:IsFullyCastable() == false then
				n_ability = n_ability - 1;
			end
		end
	end
	if  n_ability <= 0 and P.IsGoingOnSomeone(bot) then
		local target = bot:GetTarget();
		if  P.IsValidTarget(target) 
			and P.IsInRange(target, bot, bot:GetAttackRange() + 200) 
		then	
			return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
		end		
	end
	if P.IsRetreating(bot)
		and ( bot:WasRecentlyDamagedByAnyHero(6.0) == true or bot:WasRecentlyDamagedByTower(6.0) == true )
	then	
		local enemies = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
		if #enemies == 0 then
			return BOT_ACTION_DESIRE_ABSOLUTE, nil,  'no_target';
		end
	end	
	if bot:GetActiveMode() == BOT_MODE_FARM then
		local neutrals = bot:GetNearbyNeutralCreeps(bot:GetAttackRange())
		
		if #neutrals >= 2 then
			return BOT_ACTION_DESIRE_ABSOLUTE, nil,  'no_target'
		end
	end
	return BOT_ACTION_DESIRE_NONE;
end

--item_moon_shard
PIU.Use['item_moon_shard'] = function(item, bot, mode, extra_range)
	if bot:HasModifier("modifier_item_moon_shard_consumed") == false
	then
		return BOT_ACTION_DESIRE_ABSOLUTE, bot, 'unit';
	end
end

--item_phase_boots
PIU.Use['item_phase_boots'] = function(item, bot, mode, extra_range)
	if P.IsGoingOnSomeone(bot) == true 
	then
		local target = bot:GetTarget();
		if  P.IsValidTarget(target) 
			and P.IsInRange(target, bot, bot:GetAttackRange()) == false
		then	
			return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
		end		
	end
	if P.IsRetreating(bot) == true and bot:IsInvisible() == false 
	then
		return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
	end
	return BOT_ACTION_DESIRE_NONE;
end

--item_helm_of_the_dominator
PIU.Use['item_helm_of_the_dominator'] = function(item, bot, mode, extra_range)
	local nCastRange = 700 + extra_range;
	local neutrals = bot:GetNearbyNeutralCreeps(nCastRange);
	for _,u in pairs(neutrals) do
		if P.CanBeDominatedCreeps(u:GetUnitName()) 
		then
			return BOT_ACTION_DESIRE_ABSOLUTE, u, 'unit';
		end
	end	
	return BOT_ACTION_DESIRE_NONE;
end

--item_hand_of_midas
PIU.Use['item_hand_of_midas'] = function(item, bot, mode, extra_range)
	local nCastRange = 600 + extra_range;
	local creeps = bot:GetNearbyCreeps(nCastRange, true);
	for _,u in pairs(creeps) do
		if u:IsAncientCreep() == false 
		then
			return BOT_ACTION_DESIRE_ABSOLUTE, u, 'unit';
		end
	end	
	return BOT_ACTION_DESIRE_NONE;
end

--item_pipe
PIU.Use['item_pipe'] = function(item, bot, mode, extra_range)
	
	if P.IsInPhalanxTeamFight(bot) then
		return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target'
	end
	
	return BOT_ACTION_DESIRE_NONE
end

--item_medallion_of_courage
PIU.Use['item_medallion_of_courage'] = function(item, bot, mode, extra_range)
	
	local CastRange = 1000 + extra_range
	local ItemDuration = 8
	
	local Allies = bot:GetNearbyHeroes(CastRange, false, BOT_MODE_NONE)
	local FilteredAllies = PAF.FilterTrueUnits(Allies)
	
	local Enemies = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(Enemies)
	
	-- Use on strongest ally hero in a team fight
	if PAF.IsInTeamFight(bot) then
		local StrongestAlly = nil
		local HighestDamage = 0
		
		for v, Ally in pairs(FilteredAllies) do
			local EstimatedDamage = Ally:GetEstimatedDamageToTarget(true, bot:GetTarget(), ItemDuration, DAMAGE_TYPE_PHYSICAL)
			if EstimatedDamage > HighestDamage then
				StrongestAlly = Ally
				HighestDamage = EstimatedDamage
			end
		end
		
		if StrongestAlly ~= bot then
			return BOT_ACTION_DESIRE_ABSOLUTE, StrongestAlly, 'unit'
		end
	end

	-- Use on retreating ally
	if #FilteredAllies > 0 then
		local WeakestAlly = PAF.GetWeakestUnit(FilteredAllies)
		if WeakestAlly ~= bot then
			if WeakestAlly:GetHealth() <= (WeakestAlly:GetMaxHealth() * 0.4)
			and WeakestAlly:WasRecentlyDamagedByAnyHero(2) then
				return BOT_ACTION_DESIRE_ABSOLUTE, WeakestAlly, 'unit'
			end
		end
	end
	
	-- Use on isolated enemy
	--[[if PAF.IsEngaging(bot) then
		if #FilteredEnemies == 1 then
			return BOT_ACTION_DESIRE_ABSOLUTE, bot:GetTarget(), 'unit'
		end
	end]]--

	return BOT_ACTION_DESIRE_NONE;
end

--item_mekansm
PIU.Use['item_mekansm'] = function(item, bot, mode, extra_range)

	local nRadius = 1200;
	local nHeal = 275;
	
	if P.IsRetreating(bot) then
		local enemies = bot:GetNearbyHeroes(1300, true, BOT_MODE_NONE);
		if #enemies > 0 and bot:GetHealth() + nHeal <= 0.5*bot:GetMaxHealth() then
			return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
		end
	end
	
	if P.IsInTeamFight(bot, 1300) then
		local n_low_hp = 0;
		local allies = bot:GetNearbyHeroes(nRadius, false, BOT_MODE_NONE);
		for i=1, #allies do
			if allies[i]:GetHealth() + nHeal <= 0.5*allies[i]:GetMaxHealth() then
				n_low_hp = n_low_hp + 1;
			end
		end
		if n_low_hp > 0 then
			return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
		end
	end	
	
	if P.IsGoingOnSomeone(bot) then
		local target = bot:GetTarget();
		if  P.IsValidTarget(target) 
			and P.IsInRange(target, bot, bot:GetAttackRange() + 500) 
		then
			local n_low_hp = 0;
			local allies = bot:GetNearbyHeroes(nRadius, false, BOT_MODE_NONE);
			for i=1, #allies do
				if allies[i]:GetHealth() + nHeal <= 0.5*allies[i]:GetMaxHealth() then
					n_low_hp = n_low_hp + 1;
				end
			end
			if n_low_hp > 0 then
				return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
			end
		end		
	end

	return BOT_ACTION_DESIRE_NONE;
end

--item_guardian_greaves
PIU.Use['item_guardian_greaves'] = function(item, bot, mode, extra_range)
	return PIU.Use['item_mekansm'](item, bot, mode, extra_range);
end

--item_arcane_boots
PIU.Use['item_arcane_boots'] = function(item, bot, mode, extra_range)
	local nRadius = 1200;
	local n_low_mp = 0;
	local n_mana = 160;
	if item:GetName() == 'item_arcane_ring' then
		n_mana = 75;
	end
	local allies = bot:GetNearbyHeroes(nRadius, false, BOT_MODE_NONE);
	for i=1, #allies do
		if allies[i]:GetMana() + n_mana <= 0.75*allies[i]:GetMaxMana() then
			n_low_mp = n_low_mp + 1;
		end
	end
	if n_low_mp > 1 then
		return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
	end
	if bot:GetMana() < 0.25 * bot:GetMaxMana() then
		return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
	end
	return BOT_ACTION_DESIRE_NONE;
end

--item_holy_locket
PIU.Use['item_holy_locket'] = function(item, bot, mode, extra_range)
	local charges = item:GetCurrentCharges();
	local hp_ratio = bot:GetHealth() / bot:GetMaxHealth();
	local mp_ratio = bot:GetMana() / bot:GetMaxMana();
	local nCastRange = 500 + extra_range;
	
	if charges > 5 
		and P.IsGoingOnSomeone(bot)
		and hp_ratio < 0.55 and mp_ratio < 0.25
	then
		local enemies = bot:GetNearbyHeroes(800, true, BOT_MODE_NONE);
		if #enemies > 0 
		then
			return BOT_ACTION_DESIRE_ABSOLUTE, bot, 'unit';
		end
	elseif charges > 1 
		and P.IsRetreating(bot)
		and ( bot:WasRecentlyDamagedByAnyHero(2.0) == true or bot:WasRecentlyDamagedByTower(3.0) == true )
	then
		local enemies = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE);
		if #enemies > 0 
		then
			return BOT_ACTION_DESIRE_ABSOLUTE, bot, 'unit';
		end
	end	
	
	if charges >= 10 then
		local allies=bot:GetNearbyHeroes(nCastRange,false,BOT_MODE_NONE);
		for i=1, #allies do
			if allies[i]:GetUnitName() ~= bot:GetUnitName() 
				and P.CanCastOnNonMagicImmune(allies[i]) == true
				and allies[i]:WasRecentlyDamagedByAnyHero(2.5) == true
			then
				local mode2 = allies[i]:GetActiveMode();
				if  ( ( mode2 == BOT_MODE_RETREAT and allies[i]:GetHealth() < 0.15 * allies[i]:GetMaxHealth() ) 
						or ( allies[i]:GetHealth() < 0.25 * allies[i]:GetMaxHealth() 
							and ( ( allies[i]:GetAttackTarget() == nil ) or ( allies[i]:GetTarget() == nil ) ) ) )
				then	
					return BOT_ACTION_DESIRE_ABSOLUTE, allies[i], 'unit';
				end
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE;
end

--item_urn_of_shadows
PIU.Use['item_urn_of_shadows'] = function(item, bot, mode, extra_range)
	local charges = item:GetCurrentCharges()
	if charges <= 0 then return BOT_ACTION_DESIRE_NONE end
	
	local CR = (750 + extra_range)
	local nCastRange = PAF.GetProperCastRange(CR)
	
	if PAF.IsEngaging(bot) then
		local BotTarget = bot:GetTarget()
	
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= nCastRange
			and not PAF.IsMagicImmune(BotTarget)
			and not BotTarget:HasModifier("modifier_item_urn_damage")
			and not BotTarget:HasModifier("modifier_item_spirit_vessel_damage") then
				return BOT_ACTION_DESIRE_HIGH, BotTarget, 'unit'
			end
		end
	end
	
	local AlliesWithinRange = bot:GetNearbyHeroes(nCastRange, false, BOT_MODE_NONE)
	local FilteredAllies = PAF.FilterTrueUnits(AlliesWithinRange)
	
	local WeakestAlly = PAF.GetWeakestUnit(FilteredAllies)
	if WeakestAlly ~= nil and WeakestAlly:GetHealth() < (WeakestAlly:GetMaxHealth() * 0.65) then
		if not WeakestAlly:HasModifier("modifier_item_urn_heal")
		and not WeakestAlly:HasModifier("modifier_item_spirit_vessel_heal")
		and not WeakestAlly:WasRecentlyDamagedByAnyHero(2) then
			return BOT_ACTION_DESIRE_HIGH, WeakestAlly, 'unit'
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

--item_ancient_janggo
PIU.Use['item_ancient_janggo'] = function(item, bot, mode, extra_range)
	local charges = item:GetCurrentCharges();
	if charges == 0 then return BOT_ACTION_DESIRE_NONE; end
	return PIU.Use['item_pipe'](item, bot, mode, extra_range);
end

--item_boots_of_bearing
PIU.Use['item_boots_of_bearing'] = function(item, bot, mode, extra_range)
	local charges = item:GetCurrentCharges();
	if charges == 0 then return BOT_ACTION_DESIRE_NONE; end
	return PIU.Use['item_pipe'](item, bot, mode, extra_range);
end

--item_spirit_vessel
PIU.Use['item_spirit_vessel'] = function(item, bot, mode, extra_range)
	return PIU.Use['item_urn_of_shadows'](item, bot, mode, extra_range);
end

--item_glimmer_cape
PIU.Use['item_glimmer_cape'] = function(item, bot, mode, extra_range)
	local CastRange = (600 + extra_range)
	
	local AlliesWithinRange = bot:GetNearbyHeroes(CastRange, false, BOT_MODE_NONE)
	local FilteredAllies = PAF.FilterTrueUnits(AlliesWithinRange)
	
	for v, Ally in pairs(FilteredAllies) do
		if Ally:GetHealth() <= (Ally:GetMaxHealth() * 0.35) and Ally:WasRecentlyDamagedByAnyHero(2) then
			if not Ally:HasModifier("modifier_item_dustofappearance")
			and not Ally:HasModifier("modifier_slardar_amplify_damage")
			and not Ally:HasModifier("modifier_arc_warden_tempest_double")
			and not Ally:HasModifier("modifier_item_glimmer_cape") then
				return BOT_ACTION_DESIRE_ABSOLUTE, Ally, 'unit'
			end
		end
		
		if PAF.IsDisabled(Ally)
		or PAF.IsTaunted(Ally)
		or (PAF.IsSilencedOrMuted(Ally) and Ally:WasRecentlyDamagedByAnyHero(1)) then
			return BOT_ACTION_DESIRE_ABSOLUTE, Ally, 'unit'
		end
	end
	
	if P.IsRetreating(bot) then
		return BOT_ACTION_DESIRE_ABSOLUTE, bot, 'unit'
	end
	
	return BOT_ACTION_DESIRE_NONE
end

--item_necronomicon
PIU.Use['item_necronomicon'] = function(item, bot, mode, extra_range)

	if P.IsGoingOnSomeone(bot)
	then
		local target = bot:GetTarget();
		if P.IsValidTarget(target) 
		   and P.CanCastOnMagicImmune(target) == true
		   and P.IsInRange(target, bot, bot:GetAttackRange() + 250) 
		then
			return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
		end
	end
	return BOT_ACTION_DESIRE_NONE;
end

--item_necronomicon_2
PIU.Use['item_necronomicon_2'] = function(item, bot, mode, extra_range)
	return PIU.Use['item_necronomicon'](item, bot, mode, extra_range);
end

--item_necronomicon_3
PIU.Use['item_necronomicon_3'] = function(item, bot, mode, extra_range)
	return PIU.Use['item_necronomicon'](item, bot, mode, extra_range);
end

--item_solar_crest
PIU.Use['item_solar_crest'] = function(item, bot, mode, extra_range)
	return PIU.Use['item_medallion_of_courage'](item, bot, mode, extra_range);
end

--item_refresher
PIU.Use['item_refresher'] = function(item, bot, mode, extra_range)
	if P.IsGoingOnSomeone(bot) and P.CanUseRefresherOrb(bot)  
	then
		local target = bot:GetTarget();
		if P.IsValidTarget(target) 
		   and P.IsInRange(target, bot, bot:GetAttackRange() + 200) 
		then
			return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
		end
	end
	return BOT_ACTION_DESIRE_NONE;
end

--item_veil_of_discord
PIU.Use['item_veil_of_discord'] = function(item, bot, mode, extra_range)
	local CastRange = 900
	local Duration = 16
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, false, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	
	if PAF.IsInTeamFight(bot) and #FilteredEnemies >= 2 then
		return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target'
	end
	
	if P.IsRetreating(bot) and #FilteredEnemies > 0 then
		return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target'
	end
	
	--[[if PAF.IsEngaging(bot) then
		local BotTarget = bot:GetTarget()
	
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange then
				local AlliesWithinRange = bot:GetNearbyHeroes(1000, false, BOT_MODE_NONE)
				local FilteredAllies = PAF.FilterTrueUnits(AlliesWithinRange)
				
				local EstimatedDamage = PAF.CombineEstimatedDamage(true, FilteredAllies, BotTarget, Duration, DAMAGE_TYPE_MAGICAL)
				if BotTarget:GetHealth() <= EstimatedDamage then
					return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target'
				end
			end
		end
	end]]--
	
	return BOT_ACTION_DESIRE_NONE
end

--item_dagon
PIU.Use['item_dagon'] = function(item, bot, mode, extra_range)
	
	local nCastRange = 600 + extra_range;
	local nDamage = 400;
	
	if item:GetName() == "item_dagon_2" then 
		nCastRange = 650;
		nDamage = 500;
	elseif item:GetName() == "item_dagon_3" then
		nCastRange = 700;
		nDamage = 600;
	elseif item:GetName() == "item_dagon_4" then
		nCastRange = 750;
		nDamage = 700;
	elseif item:GetName() == "item_dagon_5" then
		nCastRange = 800;
		nDamage = 800;
	end
	
	if P.IsRetreating(bot) then
		local enemies = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
		local target = P.GetWeakestEnemyHero(enemies)
		if target ~= nil then
			return BOT_ACTION_DESIRE_ABSOLUTE, target, 'unit';
		end
	end
	
	if P.IsGoingOnSomeone(bot)
	then
		local target = bot:GetTarget();
		if P.IsValidTarget(target) 
		   and P.CanCastOnNonMagicImmune(target) == true
		   and P.IsInRange(target, bot, nCastRange) 
		then
			return BOT_ACTION_DESIRE_ABSOLUTE, target, 'unit';
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end

--item_dagon_2
PIU.Use['item_dagon_2'] = function(item, bot, mode, extra_range)
	return PIU.Use['item_dagon'](item, bot, mode, extra_range);
end

--item_dagon_3
PIU.Use['item_dagon_3'] = function(item, bot, mode, extra_range)
	return PIU.Use['item_dagon'](item, bot, mode, extra_range);
end

--item_dagon_4
PIU.Use['item_dagon_4'] = function(item, bot, mode, extra_range)
	return PIU.Use['item_dagon'](item, bot, mode, extra_range);
end

--item_dagon_5
PIU.Use['item_dagon_5'] = function(item, bot, mode, extra_range)
	return PIU.Use['item_dagon'](item, bot, mode, extra_range);
end

--item_orchid
PIU.Use['item_orchid'] = function(item, bot, mode, extra_range)
	local nCastRange = 900 + extra_range
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterUnitsForStun(EnemiesWithinRange)
	
	if PAF.IsEngaging(bot) then
		local BotTarget = bot:GetTarget()
		
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= nCastRange
			and not PAF.IsMagicImmune(BotTarget) then
				return BOT_ACTION_DESIRE_ABSOLUTE, BotTarget, 'unit'
			end
		end
	end
	
	if P.IsRetreating(bot) and #FilteredEnemies > 0 then
		local ClosestTarget = PAF.GetClosestUnit(bot, FilteredEnemies)
		return BOT_ACTION_DESIRE_ABSOLUTE, ClosestTarget, 'unit'
	end
	
	return BOT_ACTION_DESIRE_NONE
end

--item_sheepstick
PIU.Use['item_sheepstick'] = function(item, bot, mode, extra_range)
	local nCastRange = 800 + extra_range
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterUnitsForStun(EnemiesWithinRange)
	
	for v, enemy in pairs(FilteredEnemies) do
		if enemy:IsChanneling() then
			return BOT_ACTION_DESIRE_ABSOLUTE, enemy, 'unit'
		end
	end
	
	if PAF.IsEngaging(bot) then
		local BotTarget = bot:GetTarget()
	
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= nCastRange then
				return BOT_ACTION_DESIRE_ABSOLUTE, BotTarget, 'unit'
			end
		end
	end
	
	if P.IsRetreating(bot) and #FilteredEnemies > 0 then
		local ClosestTarget = PAF.GetClosestUnit(bot, FilteredEnemies)
		return BOT_ACTION_DESIRE_ABSOLUTE, ClosestTarget, 'unit'
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		local AttackTarget = bot:GetAttackTarget()
		
		if PAF.IsRoshan(AttackTarget)
		and GetUnitToUnitDistance(bot, AttackTarget) <= nCastRange then
			return BOT_ACTION_DESIRE_ABSOLUTE, AttackTarget, 'unit'
		end
	end
	
	return BOT_ACTION_DESIRE_NONE
end

--item_force_staff
PIU.Use['item_force_staff'] = function(item, bot, mode, extra_range)
	
	local aCastRange = 550;
	local eCastRange = 550;
	
	if item:GetName() == 'item_hurricane_pike' then
		eCastRange = 450;
	elseif item:GetName() == 'item_force_boots' then
		aCastRange = 750
		eCastRange = 750
	end
	
	if P.IsRetreating(bot) == true
		and ( bot:WasRecentlyDamagedByAnyHero(3.0) == true or bot:WasRecentlyDamagedByTower(3.0) == true )
	then
		if item:GetName() == 'item_hurricane_pike' then
			local loc = P.GetEscapeLoc2(bot);
			local bot_dist = GetUnitToLocationDistance(bot, loc);
			local enemies = bot:GetNearbyHeroes(eCastRange, true, BOT_MODE_NONE)
			for i=1, #enemies do
				if P.IsValidTarget(enemies[i])
					and P.CanCastOnNonMagicImmune(enemies[i])
					and GetUnitToLocationDistance(enemies[i], loc) > bot_dist + 50 
				then
					return BOT_ACTION_DESIRE_ABSOLUTE, enemies[i], 'unit';
				end				
			end
		end
		local loc = P.GetEscapeLoc();
		if bot:IsFacingLocation(loc,15) then
			return BOT_ACTION_DESIRE_ABSOLUTE, bot, 'unit';
		end
	end
	
	if P.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		if P.IsValidTarget(target) == true 
			and P.CanCastOnNonMagicImmune(target) == true
			and P.IsInRange(target, bot, eCastRange) == true 
			and PIU.IsForceStafed(target) == false
		then
			if item:GetName() == 'item_hurricane_pike' then
				local loc = P.GetEscapeLoc2(bot);
				local bot_dist = GetUnitToLocationDistance(bot, loc);
				local target_dist = GetUnitToLocationDistance(target, loc);
				if target_dist > bot_dist + 50 
					and ( target:IsFacingUnit(bot, 15) == true or target:GetAttackTarget() == bot )  
					and P.IsInRange(bot, target, eCastRange) == true  
				then
					return BOT_ACTION_DESIRE_ABSOLUTE, target, 'unit';
				end
			end
			if item:GetName() == 'item_force_staff' and target:IsFacingUnit(bot, 15) then
				return BOT_ACTION_DESIRE_ABSOLUTE, target, 'unit';
			end
		elseif P.IsValidTarget(target) == true 
			and P.IsInRange(target, bot, bot:GetAttackRange() - 200) == false 
			and P.IsInRange(target, bot, bot:GetAttackRange() + 300) == true 
			and PIU.IsForceStafed(bot) == false
			and bot:IsFacingUnit(target, 15)
		then
			local enemies = target:GetNearbyHeroes(1000, false, BOT_MODE_NONE);
			local allies = target:GetNearbyHeroes(1000, true, BOT_MODE_NONE);
			if enemies ~= nil and allies ~= nil and  #enemies <= #allies then
				return BOT_ACTION_DESIRE_ABSOLUTE, bot, 'unit';
			end
		end
	end
	
	local allies=bot:GetNearbyHeroes(aCastRange,false,BOT_MODE_NONE);
	for i=1, #allies do
		if allies[i]:GetUnitName() ~= bot:GetUnitName() 
			and P.CanCastOnNonMagicImmune(allies[i]) == true
			and allies[i]:WasRecentlyDamagedByAnyHero(2.5) == true
		then
			local mode2 = allies[i]:GetActiveMode();
			local loc = P.GetEscapeLoc2(allies[i]);
			if  allies[i]:IsFacingLocation(loc,15)
				and ( ( mode2 == BOT_MODE_RETREAT ) 
					or ( allies[i]:GetHealth() < 0.25 * allies[i]:GetMaxHealth() 
						and ( ( allies[i]:GetAttackTarget() == nil ) or ( allies[i]:GetTarget() == nil ) ) ) )
			then	
				return BOT_ACTION_DESIRE_ABSOLUTE, allies[i], 'unit';
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end

--item_cyclone
PIU.Use['item_cyclone'] = function(item, bot, mode, extra_range)
	
	local nCastRange = 550 + extra_range;
	
	if item:GetName() == 'item_rod_of_atos' then
		nCastRange = 1100 + extra_range;
	end
	
	if P.IsRetreating(bot) == true
		and ( bot:WasRecentlyDamagedByAnyHero(2.0) == true
		or bot:WasRecentlyDamagedByTower(2.0) == true )
	then
		local target = PIU.GetNonDisabledStrongestEnemy(bot, nCastRange);
		if target ~= nil then
			return BOT_ACTION_DESIRE_ABSOLUTE, target, 'unit';
		end
	end
	
	if P.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		if P.IsValidTarget(target) == true
			and P.IsInRange(bot, target, nCastRange) == true
			and P.CanCastOnNonMagicImmune(target) == true
			and target:WasRecentlyDamagedByAnyHero(3.5) == false
			and P.IsDisabled(true, target) == false
		then
			local enemies = target:GetNearbyHeroes(1000, false, BOT_MODE_NONE);
			local allies = bot:GetNearbyHeroes(1200, false, BOT_MODE_ATTACK);
			local allies2 = target:GetNearbyHeroes(500, true, BOT_MODE_NONE);
			if enemies ~= nil and #enemies == 1 
				and allies ~= nil and #allies > 1 
				and allies2 ~= nil and #allies2 <= 1 
			then
				return BOT_ACTION_DESIRE_ABSOLUTE, target, 'unit';
			end
		end
	end
	
	if item:GetName() == 'item_cyclone' then
		if ( bot:IsSilenced() == true or bot:IsRooted( ) == true )
			and bot:WasRecentlyDamagedByAnyHero(3.0) == true 
			and bot:GetHealth() < 0.65*bot:GetMaxHealth() 
		then
			return BOT_ACTION_DESIRE_ABSOLUTE, bot, 'unit';
		end
	end
	
	local enemies = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE);
	for i=1, #enemies do
		if P.IsValidTarget(enemies[i]) == true 
			and P.CanCastOnNonMagicImmune(enemies[i]) == true 
			and ( enemies[i]:IsChanneling()
			or enemies[i]:HasModifier('modifier_teleporting') or enemies[i]:HasModifier('modifier_abaddon_borrowed_time') )
		then
			return BOT_ACTION_DESIRE_ABSOLUTE, enemies[i], 'unit';
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end

--item_rod_of_atos
PIU.Use['item_rod_of_atos'] = function(item, bot, mode, extra_range)
	return PIU.Use['item_cyclone'](item, bot, mode, extra_range);
end

--item_nullifier
PIU.Use['item_nullifier'] = function(item, bot, mode, extra_range)
	
	local nCastRange = 900 + extra_range;
	
	if P.IsRetreating(bot) == true
		and bot:WasRecentlyDamagedByAnyHero(2.0) == true
	then
		local target = PIU.GetNonDisabledStrongestEnemy(bot, nCastRange);
		if target ~= nil then
			return BOT_ACTION_DESIRE_ABSOLUTE, target, 'unit';
		end
	end
	
	if P.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		if P.IsValidTarget(target) == true
			and P.IsInRange(bot, target, nCastRange) == true
			and P.CanCastOnNonMagicImmune(target) == true
			and P.IsDisabled(true, target) == false
		then
			return BOT_ACTION_DESIRE_ABSOLUTE, target, 'unit';
		end
	end

	return BOT_ACTION_DESIRE_NONE;
end

--item_hood_of_defiance
PIU.Use['item_hood_of_defiance'] = function(item, bot, mode, extra_range)

	if P.IsRetreating(bot) == true
		and bot:WasRecentlyDamagedByAnyHero(2.0) == true
	then
		local enemies = bot:GetNearbyHeroes(1300, true, BOT_MODE_NONE);
		if #enemies > 0 then
			return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
		end
	end
	
	if P.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		if P.IsValidTarget(target) == true
		then
			local enemies = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
			for i=1, #enemies do
				if P.IsValidTarget(enemies[i])
					and P.IsInRange(bot, enemies[i], enemies[i]:GetAttackRange()+150)
					and ( enemies[i]:GetAttackTarget() == bot
					or enemies[i]:IsFacingLocation(bot:GetLocation(), 15) )
				then
					return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
				end	
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE;
end

--item_hurricane_pike
PIU.Use['item_hurricane_pike'] = function(item, bot, mode, extra_range)
	return PIU.Use['item_force_staff'](item, bot, mode, extra_range);
end

--item_sphere
PIU.Use['item_sphere'] = function(item, bot, mode, extra_range)
	return BOT_ACTION_DESIRE_NONE;
end

--item_crimson_guard
PIU.Use['item_crimson_guard'] = function(item, bot, mode, extra_range)
	return PIU.Use['item_pipe'](item, bot, mode, extra_range);
end

--item_shivas_guard
PIU.Use['item_shivas_guard'] = function(item, bot, mode, extra_range)
	local CastRange = 900
	local Duration = 4
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, false, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	
	if PAF.IsInTeamFight(bot) and #FilteredEnemies >= 2 then
		return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target'
	end
	
	if P.IsRetreating(bot) and #FilteredEnemies > 0 then
		return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target'
	end
	
	if PAF.IsEngaging(bot) then
		local BotTarget = bot:GetTarget()
	
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange then
				local AlliesWithinRange = bot:GetNearbyHeroes(1000, false, BOT_MODE_NONE)
				local FilteredAllies = PAF.FilterTrueUnits(AlliesWithinRange)
				
				local EstimatedDamage = PAF.CombineEstimatedDamage(true, FilteredAllies, BotTarget, Duration, DAMAGE_TYPE_ALL)
				if BotTarget:GetHealth() <= EstimatedDamage then
					return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target'
				end
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE
end

--item_blade_mail
PIU.Use['item_blade_mail'] = function(item, bot, mode, extra_range)
	local Duration = 5.5

	if P.IsRetreating(bot)
	and bot:WasRecentlyDamagedByAnyHero(1) then
		return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target'
	end
	
	if PAF.IsEngaging(bot) then
		local EnemiesWithinRange = bot:GetNearbyHeroes(1200, false, BOT_MODE_NONE)
		local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
		
		local EstimatedDamage = PAF.CombineEstimatedDamage(false, FilteredEnemies, bot, Duration, DAMAGE_TYPE_ALL)
		if bot:GetHealth() <= EstimatedDamage
		and bot:WasRecentlyDamagedByAnyHero(1) then
			return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target'
		end
	end

	local projectiles = bot:GetIncomingTrackingProjectiles()
	
	for v, proj in pairs(projectiles) do
		if GetUnitToLocationDistance(bot, proj.location) <= 300 and proj.is_attack == false then
			return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target'
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

--item_lotus_orb
PIU.Use['item_lotus_orb'] = function(item, bot, mode, extra_range)
	local CastRange = (900 + extra_range)
	local Duration = 6
	
	local AlliesWithinRange = bot:GetNearbyHeroes(CastRange, false, BOT_MODE_NONE)
	local FilteredAllies = PAF.FilterTrueUnits(AlliesWithinRange)
	
	for v, Ally in pairs(FilteredAllies) do
		if Ally:WasRecentlyDamagedByAnyHero(1)
		and not Ally:HasModifier("modifier_arc_warden_tempest_double") then
			if PAF.IsDisabled(Ally)
			or PAF.IsTaunted(Ally)
			or PAF.IsSilencedOrMuted(Ally) then
				return BOT_ACTION_DESIRE_ABSOLUTE, Ally, 'unit'
			end
		end
		
		local projectiles = Ally:GetIncomingTrackingProjectiles()
		
		for v, proj in pairs(projectiles) do
			if GetUnitToLocationDistance(bot, proj.location) <= 300 and proj.is_attack == false then
				return BOT_ACTION_DESIRE_ABSOLUTE, Ally, 'unit'
			end
		end
	end
	
	local WeakestAlly = PAF.GetWeakestUnit(FilteredAllies)
	if WeakestAlly ~= nil then
		local EnemiesWithinRange = WeakestAlly:GetNearbyHeroes(1200, false, BOT_MODE_NONE)
		local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
		local EstimatedDamage = PAF.CombineEstimatedDamage(false, FilteredEnemies, WeakestAlly, Duration, DAMAGE_TYPE_MAGICAL)
		
		if WeakestAlly:GetHealth() <= EstimatedDamage
		and WeakestAlly:WasRecentlyDamagedByAnyHero(1) then
			return BOT_ACTION_DESIRE_ABSOLUTE, WeakestAlly, 'unit'
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

--item_manta
PIU.Use['item_manta'] = function(item, bot, mode, extra_range)
	local projectiles = bot:GetIncomingTrackingProjectiles()
	
	for v, proj in pairs(projectiles) do
		if GetUnitToLocationDistance(bot, proj.location) <= 200
		and proj.is_dodgeable
		and proj.is_attack == false then
			return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target'
		end
	end
	
	if (bot:IsSilenced() and not bot:HasModifier("modifier_item_mask_of_madness_berserk"))
	or bot:IsRooted() then
		return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target'
	end
	
	return BOT_ACTION_DESIRE_NONE
end

--item_black_king_bar
PIU.Use['item_black_king_bar'] = function(item, bot, mode, extra_range)
	local BotTarget = bot:GetTarget()
	
	local AlliesWithinRange = bot:GetNearbyHeroes(1200, false, BOT_MODE_NONE)
	local FilteredAllies = PAF.FilterTrueUnits(AlliesWithinRange)
	local CombinedOffensivePower = PAF.CombineOffensivePower(FilteredAllies, false)
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	local CombinedEstimatedPhysicalDamage = PAF.CombineEstimatedDamage(false, FilteredEnemies, bot, 3, DAMAGE_TYPE_PHYSICAL)
	
	if PAF.IsEngaging(bot)
	and CombinedOffensivePower > BotTarget:GetHealth() then
		if bot:GetHealth() <= (bot:GetMaxHealth() * 0.8)
		and bot:WasRecentlyDamagedByAnyHero(1) then
			return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target'
		end
		
		if (bot:IsSilenced() and not bot:HasModifier("modifier_item_mask_of_madness_berserk"))
		or bot:IsRooted() then
			return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target'
		end
	end
	
	if P.IsRetreating(bot) then
		if #FilteredEnemies > 0
		and bot:GetHealth() > CombinedEstimatedPhysicalDamage then
			if bot:IsSilenced() or bot:IsRooted() then
				return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target'
			end
		end
		
		local projectiles = bot:GetIncomingTrackingProjectiles()
	
		for v, proj in pairs(projectiles) do
			if GetUnitToLocationDistance(bot, proj.location) <= 300 and proj.is_attack == false then
				return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target'
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE
end

--item_bloodstone
PIU.Use['item_bloodstone'] = function(item, bot, mode, extra_range)
	if  P.IsRetreating(bot)
		and bot:GetHealth() < 0.25*bot:GetMaxHealth()  
		and bot:GetMana() > 0.6*bot:GetMaxMana() 
	then
		return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
	end
	return BOT_ACTION_DESIRE_NONE;
end

--item_radiance
PIU.Use['item_radiance'] = function(item, bot, mode, extra_range)
	return BOT_ACTION_DESIRE_NONE;
end


--item_armlet
PIU.Use['item_armlet'] = function(item, bot, mode, extra_range)
		if P.IsRetreating(bot) == true
			and bot:WasRecentlyDamagedByAnyHero(2.0) == true
			and item:GetToggleState( ) == true
		then
			return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
		end
		
		if P.IsGoingOnSomeone(bot) 
		then
			local target = bot:GetTarget();
			if P.IsValidTarget(target) == true
				and P.IsInRange(bot, target, bot:GetAttackRange() + 150) == true
				and item:GetToggleState( ) == false
			then
				return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
			end
		end
		local enemies = bot:GetNearbyHeroes(1300, true, BOT_MODE_NONE);
		if #enemies == 0 and item:GetToggleState( ) == true then
			return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
		end
	
	-- local projectiles = bot:GetIncomingTrackingProjectiles();
	-- local nearestprojectile = nil;
	-- local lowest_distance = 9999;
	-- for k, projectile in pairs(projectiles) do
		-- if (GetUnitToLocationDistance( bot, projectile.location) < lowest_distance 
			-- and projectile.caster ~= nil 
			-- and projectile.playerid ~= nil 
			-- and GetTeamForPlayer( projectile.playerid ) ~= GetTeam() ) 
		-- then
			-- lowest_distance = GetUnitToLocationDistance( bot, projectile.location);
			-- nearestprojectile = projectile.ability;
		-- end
	-- end
	
	return BOT_ACTION_DESIRE_NONE;
end

--item_abyssal_blade
PIU.Use['item_abyssal_blade'] = function(item, bot, mode, extra_range)
	
	local nCastRange = 300 + extra_range;
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterUnitsForStun(EnemiesWithinRange)
	
	for v, enemy in pairs(FilteredEnemies) do
		if enemy:IsChanneling() then
			return BOT_ACTION_DESIRE_ABSOLUTE, enemy, 'unit'
		end
	end
	
	if PAF.IsEngaging(bot) then
		local BotTarget = bot:GetTarget()
	
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= nCastRange then
				return BOT_ACTION_DESIRE_ABSOLUTE, BotTarget, 'unit'
			end
		end
	end
	
	if P.IsRetreating(bot) and #FilteredEnemies > 0 then
		local ClosestTarget = PAF.GetClosestUnit(bot, FilteredEnemies)
		return BOT_ACTION_DESIRE_ABSOLUTE, ClosestTarget, 'unit'
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		local AttackTarget = bot:GetAttackTarget()
		
		if PAF.IsRoshan(AttackTarget)
		and GetUnitToUnitDistance(bot, AttackTarget) <= nCastRange then
			return BOT_ACTION_DESIRE_ABSOLUTE, AttackTarget, 'unit'
		end
	end

	return BOT_ACTION_DESIRE_NONE;
end

--item_meteor_hammer
PIU.Use['item_meteor_hammer'] = function(item, bot, mode, extra_range)

	local nCastRange = 600 + extra_range;
	
	if item:GetName() == 'item_fallen_sky' then
		nCastRange = 1600;
	end

	if P.IsPushing(bot) then
		local towers = bot:GetNearbyTowers(800, true);
		if #towers > 0 and towers[1] ~= nil and  towers[1]:IsInvulnerable() == false then 
			return BOT_ACTION_DESIRE_ABSOLUTE, towers[1]:GetLocation(), 'point';
		end
	elseif  P.IsInTeamFight(bot, 1200) then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), 600, 300, 0, 0 );
		if ( locationAoE.count >= 2 ) 
		then
			return BOT_ACTION_DESIRE_ABSOLUTE, locationAoE.targetloc, 'point';
		end
	elseif P.IsGoingOnSomeone(bot) then
		local target = bot:GetTarget();
		if P.IsValidTarget(target) and P.CanCastOnNonMagicImmune(target) and P.IsInRange(target, bot, nCastRange) 
		then
			if item:GetName() == 'item_meteor_hammer' and P.IsDisabled(true, target) == true	 
			then
				return BOT_ACTION_DESIRE_ABSOLUTE, target:GetLocation(), 'point';
			end
			if item:GetName() == 'item_fallen_sky' then
				local allies = target:GetNearbyHeroes(1300, true, BOT_MODE_NONE);
				local enemies = target:GetNearbyHeroes(1300, false, BOT_MODE_NONE);
				if ( enemies ~= nil and allies ~= nil and #allies >= #enemies ) 
				then
					return BOT_ACTION_DESIRE_ABSOLUTE, target:GetLocation(), 'point';
				end
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE;
end

--item_bfury
PIU.Use['item_bfury'] = function(item, bot, mode, extra_range)
	return PIU.Use['item_quelling_blade'](item, bot, mode, extra_range);
end

--item_invis_sword
PIU.Use['item_invis_sword'] = function(item, bot, mode, extra_range)
	if P.IsRetreating(bot)
	or bot:GetActiveMode() == BOT_MODE_ROAM then
		return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target'
	end
	
	local AttackTarget = bot:GetAttackTarget()
	local AttackRange = bot:GetAttackRange()
	
	if PAF.IsValidHeroAndNotIllusion(AttackTarget) then
		for v, PassiveHero in pairs(PRoles["StrongPassiveHeroes"]) do
			if AttackTarget:GetUnitName() == PassiveHero then
				if GetUnitToUnitDistance(bot, AttackTarget) <= (AttackRange + 50) then
					return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target'
				end
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE
end

PIU.Use['item_smoke_of_deceit'] = function(item, bot, mode, extra_range)
	local Radius = 1025
	
	local AlliesWithinRange = bot:GetNearbyHeroes(1200, false, BOT_MODE_NONE)
	local FilteredAllies = PAF.FilterTrueUnits(AlliesWithinRange)
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	local TowersWithinRange = bot:GetNearbyTowers((Radius + 300), true)
	local AlliesCanSmoke = true
	
	for v, ally in pairs(FilteredAllies) do
		local EnemiesWithinAllyRange = ally:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
		local TowersWithinAllyRange = ally:GetNearbyTowers((Radius + 300), true)
		
		if #EnemiesWithinAllyRange > 0 or #TowersWithinAllyRange > 0 then
			AlliesCanSmoke = false
			break
		end
	end
	
	if (bot:GetActiveMode() == BOT_MODE_ROAM or (bot:GetActiveMode() == BOT_MODE_TEAM_ROAM and bot.teamroaming == true))
	and #FilteredAllies > 1
	and #EnemiesWithinRange == 0
	and #TowersWithinRange == 0
	and AlliesCanSmoke then
		return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target'
	end
	
	--[[if bot.cangank == true
	and #FilteredAllies > 1
	and #EnemiesWithinRange == 0
	and #TowersWithinRange == 0
	and AlliesCanSmoke then
		return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target'
	end]]--
	
	return BOT_ACTION_DESIRE_NONE
end

--item_ethereal_blade
PIU.Use['item_ethereal_blade'] = function(item, bot, mode, extra_range)
	
	local nCastRange = 800 + extra_range;
	
	if P.IsRetreating(bot) == true
		and bot:WasRecentlyDamagedByAnyHero(2.0) == true
	then
		local target = PIU.GetNonDisabledStrongestEnemy(bot, nCastRange);
		if target ~= nil then
			return BOT_ACTION_DESIRE_ABSOLUTE, target, 'unit';
		end
	end
	
	if P.IsInTeamFight(bot, 1300)
	then
		local enemies =  bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
		if #enemies > 1 then
			local target = PIU.GetNonDisabledStrongestEnemy(bot, nCastRange);
			if target ~= nil then
				return BOT_ACTION_DESIRE_ABSOLUTE, target, 'unit';
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end

--item_silver_edge
PIU.Use['item_silver_edge'] = function(item, bot, mode, extra_range)
	return PIU.Use['item_invis_sword'](item, bot, mode, extra_range);
end

--item_bloodthorn
PIU.Use['item_bloodthorn'] = function(item, bot, mode, extra_range)
	return PIU.Use['item_orchid'](item, bot, mode, extra_range);
end

--item_satanic
PIU.Use['item_satanic'] = function(item, bot, mode, extra_range)

	if P.IsGoingOnSomeone(bot) and bot:IsDisarmed() == false
	then
		local target = bot:GetTarget();
		if P.IsValidTarget(target) == true
			and P.IsInRange(bot, target, bot:GetAttackRange()+150) == true
		then
			return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end

--item_diffusal_blade
PIU.Use['item_diffusal_blade'] = function(item, bot, mode, extra_range)
	local nCastRange = 600 + extra_range
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterUnitsForStun(EnemiesWithinRange)
	
	if PAF.IsEngaging(bot) then
		local BotTarget = bot:GetTarget()
	
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= nCastRange then
				return BOT_ACTION_DESIRE_ABSOLUTE, BotTarget, 'unit'
			end
		end
	end
	
	if P.IsRetreating(bot) and #FilteredEnemies > 0 then
		local ClosestTarget = PAF.GetClosestUnit(bot, FilteredEnemies)
		return BOT_ACTION_DESIRE_ABSOLUTE, ClosestTarget, 'unit'
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		local AttackTarget = bot:GetAttackTarget()
		
		if PAF.IsRoshan(AttackTarget)
		and GetUnitToUnitDistance(bot, AttackTarget) <= nCastRange then
			return BOT_ACTION_DESIRE_ABSOLUTE, AttackTarget, 'unit'
		end
	end
	
	return BOT_ACTION_DESIRE_NONE
end

--item_mjollnir
PIU.Use['item_mjollnir'] = function(item, bot, mode, extra_range)
	
	local nCastRange = 800;
	
	if P.IsRetreating(bot) == true
		and bot:WasRecentlyDamagedByAnyHero(2.0) == true
	then
		local enemies = bot:GetNearbyHeroes(1300, true, BOT_MODE_NONE);
		if #enemies > 0 then
			return BOT_ACTION_DESIRE_ABSOLUTE, bot, 'unit';
		end
	end
	
	if P.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		if P.IsValidTarget(target) == true
			and P.IsInRange(bot, target, nCastRange) == true
		then
			return BOT_ACTION_DESIRE_ABSOLUTE, bot, 'unit';
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end

--item_blood_grenade
PIU.Use['item_blood_grenade'] = function(item, bot, mode, extra_range)
	local CastRange = (900 + extra_range)
	local Duration = 5
	local BotTarget = bot:GetTarget()
	
	if BotTarget == nil then return BOT_ACTION_DESIRE_NONE end
	
	local AlliesWithinRange = bot:GetNearbyHeroes(CastRange, false, BOT_MODE_NONE)
	local FilteredAllies = PAF.FilterTrueUnits(AlliesWithinRange)
	
	local StunDuration = Duration
	local EstimatedDamage = 0
	
	for v, Ally in pairs(FilteredAllies) do
		if GetUnitToUnitDistance(Ally, BotTarget) <= CastRange then
			StunDuration = (StunDuration + Ally:GetStunDuration(true))
		end
	end
	
	for v, Ally in pairs(FilteredAllies) do
		if GetUnitToUnitDistance(Ally, BotTarget) <= CastRange then
			EstimatedDamage = (EstimatedDamage + Ally:GetEstimatedDamageToTarget(true, BotTarget, StunDuration, DAMAGE_TYPE_ALL))
		end
	end
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget)
			and BotTarget:GetHealth() <= EstimatedDamage then
				return BOT_ACTION_DESIRE_ABSOLUTE, BotTarget:GetLocation(), 'point'
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE
end

--item_pavise
PIU.Use['item_pavise'] = function(item, bot, mode, extra_range)
	local CastRange = (1000 + extra_range)
	
	local AlliesWithinRange = bot:GetNearbyHeroes(CastRange, false, BOT_MODE_NONE)
	local FilteredAllies = PAF.FilterTrueUnits(AlliesWithinRange)
	
	for v, Ally in pairs(FilteredAllies) do
		if Ally:GetHealth() <= (Ally:GetMaxHealth() * 0.5)
		and Ally:WasRecentlyDamagedByAnyHero(2)
		and not Ally:HasModifier("modifier_arc_warden_tempest_double") then
			return BOT_ACTION_DESIRE_ABSOLUTE, Ally, 'unit'
		end
	end
	
	return BOT_ACTION_DESIRE_NONE
end

--item_pavise
PIU.Use['item_disperser'] = function(item, bot, mode, extra_range)
	local CastRange = (600 + extra_range)
	local BotTarget = bot:GetTarget()
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, false, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	local AlliesWithinRange = bot:GetNearbyHeroes(CastRange, false, BOT_MODE_NONE)
	local FilteredAllies = PAF.FilterTrueUnits(AlliesWithinRange)
	
	for v, Ally in pairs(FilteredAllies) do
		if Ally:GetHealth() <= (Ally:GetMaxHealth() * 0.35) and #EnemiesWithinRange > 0 then
			return BOT_ACTION_DESIRE_ABSOLUTE, Ally, 'unit'
		end
	end
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsDisabled(BotTarget) then
				return BOT_ACTION_DESIRE_ABSOLUTE, BotTarget, 'unit'
			end
		end
	end
	
	if P.IsRetreating(bot) and #FilteredEnemies > 0 then
		local ClosestTarget = PAF.GetClosestUnit(bot, FilteredEnemies)
		return BOT_ACTION_DESIRE_ABSOLUTE, ClosestTarget, 'unit'
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		local AttackTarget = bot:GetAttackTarget()
		
		if PAF.IsRoshan(AttackTarget)
		and GetUnitToUnitDistance(bot, AttackTarget) <= nCastRange then
			return BOT_ACTION_DESIRE_ABSOLUTE, AttackTarget, 'unit'
		end
	end
	
	return BOT_ACTION_DESIRE_NONE
end

--item_harpoon
PIU.Use['item_harpoon'] = function(item, bot, mode, extra_range)
	local CastRange = (700 + extra_range)
	local BotTarget = bot:GetTarget()
	local AttackRange = bot:GetAttackRange()
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and GetUnitToUnitDistance(bot, BotTarget) > (AttackRange + 150) then
				return BOT_ACTION_DESIRE_ABSOLUTE, BotTarget, 'unit'
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE
end

--item_heavens_halberd
PIU.Use['item_heavens_halberd'] = function(item, bot, mode, extra_range)
	local CastRange = (650 + extra_range)
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	
	if P.IsRetreating(bot) and #FilteredEnemies > 0 then
		local ClosestEnemy = PAF.GetClosestUnit(bot, FilteredEnemies)
		
		if ClosestEnemy ~= nil then
			if PAF.IsValidHeroAndNotIllusion(ClosestEnemy) then
				if GetUnitToUnitDistance(bot, ClosestEnemy) <= CastRange then
					return BOT_ACTION_DESIRE_ABSOLUTE, ClosestEnemy, 'unit'
				end
			end
		end
	end
	
	if PAF.IsEngaging(bot) and #FilteredEnemies > 0 then
		local StrongestEnemy = PAF.GetStrongestAttackDamageUnit(FilteredEnemies)
		
		if StrongestEnemy ~= nil then
			if PAF.IsValidHeroAndNotIllusion(StrongestEnemy) then
				if GetUnitToUnitDistance(bot, StrongestEnemy) <= CastRange then
					return BOT_ACTION_DESIRE_ABSOLUTE, StrongestEnemy, 'unit'
				end
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE
end

----------NEUTRAL ITEM------------

--item_iron_talon
--[[PIU.Use['item_iron_talon'] = function(item, bot, mode, extra_range)
	if bot:GetActiveMode() == BOT_MODE_FARM or P.IsDefending(bot) or P.IsPushing(bot) 
	then
		local neutrals = bot:GetNearbyCreeps(350, true);
		local maxHP = 0;
		local target = nil;
		for _,c in pairs(neutrals) do
			local cHP = c:GetHealth();
			if cHP > maxHP and not c:IsAncientCreep() then
				maxHP = cHP;
				target = c;
			end
		end
		if target ~= nil then
			return BOT_ACTION_DESIRE_ABSOLUTE, target, 'unit';
		end
	end
	return BOT_ACTION_DESIRE_NONE;
end

--item_ironwood_tree
PIU.Use['item_ironwood_tree'] = function(item, bot, mode, extra_range)
	local nCastRange = 600;
	if P.IsRetreating(bot)
		and bot:WasRecentlyDamagedByAnyHero(3.0) 
	then
		local enemies = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE);
		if #enemies > 0 and enemies[1] ~= nil and GetUnitToUnitDistance(bot, enemies[1]) > 150 then
			return BOT_ACTION_DESIRE_ABSOLUTE, bot:GetXUnitsTowardsLocation(enemies[1]:GetLocation(), 75), 'point';
		end
	end
	return BOT_ACTION_DESIRE_NONE;
end

--item_royal_jelly
PIU.Use['item_royal_jelly'] = function(item, bot, mode, extra_range)
	local nCastRange = 250 + 200;
	local allies = bot:GetNearbyHeroes(nCastRange, false, BOT_MODE_NONE);
	for i=1, #allies do
		if allies[i]:HasModifier("modifier_royal_jelly") == false
			and P.CanCastOnNonMagicImmune(allies[i]) 
		then
			return BOT_ACTION_DESIRE_ABSOLUTE, allies[i], 'unit';
		end
	end
	return BOT_ACTION_DESIRE_NONE;
end

--item_mango_tree
PIU.Use['item_mango_tree'] = function(item, bot, mode, extra_range)
	local nCastRange = 200;
	return BOT_ACTION_DESIRE_ABSOLUTE, bot:GetLocation() + RandomVector(nCastRange), 'point';
end

--item_trusty_shovel
PIU.Use['item_trusty_shovel'] = function(item, bot, mode, extra_range)
	local nCastRange = 250;
	local enemies = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
	if #enemies == 0 then
		return BOT_ACTION_DESIRE_ABSOLUTE, bot:GetLocation() + RandomVector(nCastRange), 'point';
	end
	return BOT_ACTION_DESIRE_NONE;
end

--item_arcane_ring
PIU.Use['item_arcane_ring'] = function(item, bot, mode, extra_range)
	return PIU.Use['item_arcane_boots'](item, bot, mode, extra_range);
end

--item_essence_ring
PIU.Use['item_essence_ring'] = function(item, bot, mode, extra_range)
	local hpRes = 425;
	if P.IsRetreating(bot)
		and bot:GetHealth() < 0.35 * bot:GetMaxHealth()  
		and ( bot:WasRecentlyDamagedByAnyHero(3.0) or bot:WasRecentlyDamagedByTower(3.0) )
	then
		return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
	end
	return BOT_ACTION_DESIRE_NONE;
end

--item_vambrace
PIU.Use['item_vambrace'] = function(item, bot, mode, extra_range)
	return BOT_ACTION_DESIRE_NONE;
end

--item_clumsy_net
PIU.Use['item_clumsy_net'] = function(item, bot, mode, extra_range)
	local nCastRange = 650;
	
	if P.IsGoingOnSomeone(bot)
	then	
		local target = bot:GetTarget();
		if P.IsValidTarget(target) == true
			and P.CanCastOnNonMagicImmune(target) == true 
			and P.IsInRange(target, bot, nCastRange) == true 
			and P.IsDisabled(true, target) == false
		then
			return BOT_ACTION_DESIRE_ABSOLUTE, target, 'unit';
		end
	end
	return BOT_ACTION_DESIRE_NONE;
end

--item_repair_kit
PIU.Use['item_repair_kit'] = function(item, bot, mode, extra_range)
	local nCastRange = 600;
	local towers = bot:GetNearbyTowers(nCastRange, false);
	for i=1, #towers do
		if towers[i]:GetHealth() <= 0.6 * towers[i]:GetMaxHealth() and towers[i]:HasModifier("modifier_repair_kit") == false then
			return BOT_ACTION_DESIRE_ABSOLUTE, towers[i], 'unit';
		end
	end
	return BOT_ACTION_DESIRE_NONE;
end

--item_greater_faerie_fire
PIU.Use['item_greater_faerie_fire'] = function(item, bot, mode, extra_range)
	local hpRes = 500;
	if P.IsRetreating(bot) == true
		and bot:DistanceFromFountain() > 0 == true 
		and ( bot:WasRecentlyDamagedByAnyHero(3.0) == true or bot:WasRecentlyDamagedByTower(3.0) == true )
		and bot:GetHealth() < 0.25 * bot:GetMaxHealth()   
	then
		return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
	end
	return BOT_ACTION_DESIRE_NONE;
end

--item_spider_legs
PIU.Use['item_spider_legs'] = function(item, bot, mode, extra_range)
	if P.IsRetreating(bot)
		and ( bot:WasRecentlyDamagedByAnyHero(3.0) == true or bot:WasRecentlyDamagedByTower(3.0) == true )
	then
		return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
	end
	
	if P.IsGoingOnSomeone(bot)
	then	
		local target = bot:GetTarget();
		if P.IsValidTarget(target) == true
			and P.IsInRange(target, bot, bot:GetAttackRange() + 200) == false 
		then
			return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
		end
	end
	return BOT_ACTION_DESIRE_NONE;
end

--item_flicker
PIU.Use['item_flicker'] = function(item, bot, mode, extra_range)
	if bot:IsRooted() then return BOT_ACTION_DESIRE_NONE end
	if  P.IsRetreating(bot)
		and ( bot:WasRecentlyDamagedByAnyHero(3.0) == true or bot:WasRecentlyDamagedByTower(3.0) == true )
		and bot:IsRooted() == false 
		then
			return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
		end
	return BOT_ACTION_DESIRE_NONE;
end

--item_ninja_gear
PIU.Use['item_ninja_gear'] = function(item, bot, mode, extra_range)
	local nCastRange = 1025
	if P.IsGoingOnSomeone(bot)
	then	
		local target = bot:GetTarget();
		if P.IsValidTarget(target) and P.IsInRange(target, bot, nCastRange+600) == false 
		and P.IsInRange(target, bot, 2500) == true 
		then
			return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
		end
	end
	if P.IsRetreating(bot)
		and ( bot:WasRecentlyDamagedByAnyHero(3.0) == true or bot:WasRecentlyDamagedByTower(3.0) == true )
	then
		local enemies = bot:GetNearbyHeroes(nCastRange+150, true, BOT_MODE_NONE);
		if #enemies == 0 then
			return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
		end
	end
	return BOT_ACTION_DESIRE_NONE;
end

--item_illusionsts_cape
PIU.Use['item_illusionsts_cape'] = function(item, bot, mode, extra_range)
	local nCastRange = bot:GetAttackRange();
	local target = bot:GetTarget();
	if P.IsGoingOnSomeone(bot)
	then	
		if P.IsValidTarget(target) and P.CanCastOnNonMagicImmune(target) 
			and P.IsInRange(target, bot, nCastRange+200) 
		then
			return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
		end
	end
	if P.IsRetreating(bot)
		and ( bot:WasRecentlyDamagedByAnyHero(3.0) == true or bot:WasRecentlyDamagedByTower(3.0) == true )
	then
		return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
	end
	return BOT_ACTION_DESIRE_NONE;
end

--item_havoc_hammer
PIU.Use['item_havoc_hammer'] = function(item, bot, mode, extra_range)
	local nRadius = 300;
	if P.IsRetreating(bot)
		and bot:WasRecentlyDamagedByAnyHero(3.0) 
	then
		local enemies = bot:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE);
		if #enemies >= 1 then
			return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
		end
	end
	if P.IsGoingOnSomeone(bot)
	then	
		local target = bot:GetTarget();
		if P.IsValidTarget(target) and P.IsInRange(target, bot, bot:GetAttackRange()+200) == true
		then
			local enemies = bot:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE);
			if #enemies >= 1 then
				return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
			end
		end
	end
	return BOT_ACTION_DESIRE_NONE;
end

--item_minotaur_horn
PIU.Use['item_minotaur_horn'] = function(item, bot, mode, extra_range)
	return PIU.Use['item_black_king_bar'](item, bot, mode, extra_range);
end

--item_force_boots
PIU.Use['item_force_boots'] = function(item, bot, mode, extra_range)
	return PIU.Use['item_force_staff'](item, bot, mode, extra_range);
end

--item_force_boots_old
PIU.Use['item_force_boots_old'] = function(item, bot, mode, extra_range)
	if P.IsRetreating(bot) == true
		and ( bot:WasRecentlyDamagedByAnyHero(3.0) == true or bot:WasRecentlyDamagedByTower(3.0) == true )
	then
		local loc = P.GetEscapeLoc();
		if bot:IsFacingLocation(loc,15) then
			return BOT_ACTION_DESIRE_ABSOLUTE, bot, 'unit';
		end
	end
	
	if P.IsGoingOnSomeone(bot) 
	then
		local target = bot:GetTarget();
		if P.IsValidTarget(target) == true 
			and P.IsInRange(target, bot, bot:GetAttackRange() - 200) == false 
			and P.IsInRange(target, bot, bot:GetAttackRange() + 300) == true 
			and PIU.IsForceStafed(bot) == false
			and bot:IsFacingUnit(target, 15)
		then
			local enemies = target:GetNearbyHeroes(1000, false, BOT_MODE_NONE);
			local allies = target:GetNearbyHeroes(1000, true, BOT_MODE_NONE);
			if enemies ~= nil and allies ~= nil and  #enemies <= #allies then
				return BOT_ACTION_DESIRE_ABSOLUTE, bot, 'unit';
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end

--item_woodland_striders
PIU.Use['item_woodland_striders'] = function(item, bot, mode, extra_range)
	if P.IsRetreating(bot) == true
		and bot:WasRecentlyDamagedByAnyHero(0.5) == true
	then
		return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
	end
	return BOT_ACTION_DESIRE_NONE;
end

--item_demonicon
PIU.Use['item_demonicon'] = function(item, bot, mode, extra_range)
	return PIU.Use['item_necronomicon'](item, bot, mode, extra_range);
end

--item_fallen_sky
PIU.Use['item_fallen_sky'] = function(item, bot, mode, extra_range)
	local nCastRange = 1600;
	if P.IsStuck(bot)
	then
		local loc = P.GetEscapeLoc();
		return BOT_ACTION_DESIRE_ABSOLUTE, bot:GetXUnitsTowardsLocation( loc, nCastRange ), 'point';
	elseif P.IsRetreating(bot)
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
		if ( bot:WasRecentlyDamagedByAnyHero(2.0) or bot:WasRecentlyDamagedByTower(2.0) or ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes > 1  ) )
		then
			local loc = P.GetEscapeLoc();
			return BOT_ACTION_DESIRE_ABSOLUTE, bot:GetXUnitsTowardsLocation( loc, nCastRange ), 'point';
		end	
	end
	return PIU.Use['item_meteor_hammer'](item, bot, mode, extra_range);
end

--item_ex_machina
PIU.Use['item_ex_machina'] = function(item, bot, mode, extra_range)
	local nCastRange = bot:GetAttackRange()
	local target = bot:GetTarget();
	if P.IsGoingOnSomeone(bot)
	then	
		if P.IsValidTarget(target) and P.IsInRange(target, bot, nCastRange+200) == true
		then
			local nCdItem = 0;
			for i=0, 5 do
				local cdIt = bot:GetItemInSlot(i);
				if cdIt ~= nil and cdIt:GetCooldownTimeRemaining() > 10 then
					nCdItem = nCdItem + 1;
				end
			end
			if nCdItem >= 2 then
				return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
			end
		end
	end
	if P.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(1.0) 
	then
		local nCdItem = 0;
		for i=0, 5 do
			local cdIt = bot:GetItemInSlot(i);
			if cdIt ~= nil and cdIt:GetCooldownTimeRemaining() > 10 then
				nCdItem = nCdItem + 1;
			end
		end
		if nCdItem >= 2 then
			return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
		end
	end
	return BOT_ACTION_DESIRE_NONE;
end]]--

--------ROSHAN DROP------
--item_refresher_shard
PIU.Use['item_refresher_shard'] = function(item, bot, mode, extra_range)
	if P.IsGoingOnSomeone(bot) and P.CanUseRefresherShard(bot)  
	then
		return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
	end
	return BOT_ACTION_DESIRE_NONE;
end
--item_cheese
PIU.Use['item_cheese'] = function(item, bot, mode, extra_range)
	local maxHP = 2500;
	local maxMP = 1500;
	
	if bot:GetHealth()+0.5*maxHP < bot:GetMaxHealth() 
		or bot:GetMana()+0.5*maxMP < bot:GetMaxMana()
	then
		return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
	end
	
	return BOT_ACTION_DESIRE_NONE;
end

--------- PATCH 7.28 -----------
--item_gungir
PIU.Use['item_gungir'] = function(item, bot, mode, extra_range)
	local nCastRange = 1100 + extra_range;
	
	if  P.IsInTeamFight(bot, 1200) then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, 300, 0, 0 );
		if ( locationAoE.count >= 2 ) 
		then
			return BOT_ACTION_DESIRE_ABSOLUTE, locationAoE.targetloc, 'point';
		end
	elseif P.IsGoingOnSomeone(bot) then
		local target = bot:GetTarget();
		if P.IsValidTarget(target) and P.CanCastOnNonMagicImmune(target) and P.IsInRange(target, bot, nCastRange) 
		then
			return BOT_ACTION_DESIRE_ABSOLUTE, target:GetLocation(), 'point';
		end
	end

	return BOT_ACTION_DESIRE_NONE;
end
--item_helm_of_the_dominator_2
PIU.Use['item_helm_of_the_overlord'] = function(item, bot, mode, extra_range)
	return PIU.Use['item_helm_of_the_dominator'](item, bot, mode, extra_range);
end
--item_overwhelming_blink
PIU.Use['item_overwhelming_blink'] = function(item, bot, mode, extra_range)
	return PIU.Use['item_blink'](item, bot, mode, extra_range);
end
--item_swift_blink
PIU.Use['item_swift_blink'] = function(item, bot, mode, extra_range)
	return PIU.Use['item_blink'](item, bot, mode, extra_range);
end
--item_arcane_blink
PIU.Use['item_arcane_blink'] = function(item, bot, mode, extra_range)
	return PIU.Use['item_blink'](item, bot, mode, extra_range);
end
--item_wind_waker
PIU.Use['item_wind_waker'] = function(item, bot, mode, extra_range)
	return PIU.Use['item_cyclone'](item, bot, mode, extra_range);
end
--item_bullwhip
--[[PIU.Use['item_bullwhip'] = function(item, bot, mode, extra_range)
	local nCastRange = 850 + extra_range;

	if P.IsGoingOnSomeone(bot)
	then
		local target = bot:GetTarget();
		if P.IsValidTarget(target) 
			and P.CanCastOnNonMagicImmune(bot) 
			and P.IsInRange(target, bot, bot:GetAttackRange()) == false 
			and P.IsInRange(target, bot, bot:GetAttackRange() + 200) == true 
		then
			return BOT_ACTION_DESIRE_ABSOLUTE, target, 'unit';
		end
	end

	local allies = bot:GetNearbyHeroes(nCastRange,false,BOT_MODE_RETREAT);
	for i = 1, #allies
	do
		if P.IsValidTarget(allies[i])
		   and allies[i]:IsIllusion() == false
		   and P.CanCastOnNonMagicImmune(allies[i])
		   and allies[i]:WasRecentlyDamagedByAnyHero(1.0)
		then
			return BOT_ACTION_DESIRE_ABSOLUTE, allies[i], 'unit';
		end
	end

	local allies = bot:GetNearbyHeroes(nCastRange,false,BOT_MODE_ATTACK);
	for i = 1, #allies
	do
		if P.IsValidTarget(allies[i])
		   and allies[i]:IsIllusion() == false
		   and P.CanCastOnNonMagicImmune(allies[i])
		   and allies[i]:GetAttackRange() < 325
		then
			return BOT_ACTION_DESIRE_ABSOLUTE, allies[i], 'unit';
		end
	end

	return BOT_ACTION_DESIRE_NONE;
end
--item_psychic_headband
PIU.Use['item_psychic_headband'] = function(item, bot, mode, extra_range)
	local nCastRange = 800 + extra_range;

	if P.IsRetreating(bot) == true
		and ( bot:WasRecentlyDamagedByAnyHero(2.0) == true
		or bot:WasRecentlyDamagedByTower(2.0) == true )
	then
		local target = PIU.GetNonDisabledStrongestEnemy(bot, nCastRange);
		if target ~= nil then
			return BOT_ACTION_DESIRE_ABSOLUTE, target, 'unit';
		end
	end

	return BOT_ACTION_DESIRE_NONE;
end
--item_stormcrafter
PIU.Use['item_stormcrafter'] = function(item, bot, mode, extra_range)
	
	if ( bot:IsSilenced() == true or bot:IsRooted( ) == true )
		and bot:WasRecentlyDamagedByAnyHero(3.0) == true 
		and bot:GetHealth() < 0.65*bot:GetMaxHealth() 
		and P.CanCastOnNonMagicImmune(bot)
	then
		return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
	end
	
	return BOT_ACTION_DESIRE_NONE;
end
--item_trickster_cloak
PIU.Use['item_trickster_cloak'] = function(item, bot, mode, extra_range)
	
	if P.IsRetreating(bot) == true
		and ( bot:WasRecentlyDamagedByAnyHero(3.0) == true or bot:WasRecentlyDamagedByTower(3.0) == true )
	then
		local enemies = bot:GetNearbyHeroes(1300, true, BOT_MODE_NONE);
		if #enemies > 0 then
			return BOT_ACTION_DESIRE_ABSOLUTE, nil, 'no_target';
		end
	end
	return BOT_ACTION_DESIRE_NONE;
end
--item_book_of_shadows
PIU.Use['item_book_of_shadows'] = function(item, bot, mode, extra_range)
	local nCastRange = 700 + extra_range
	if P.IsRetreating(bot) and bot:WasRecentlyDamagedByAnyHero(2.0)
	then
		local target = PIU.GetNonDisabledStrongestEnemy(bot, nCastRange);
		if target ~= nil then
			return BOT_ACTION_DESIRE_ABSOLUTE, target, 'unit';
		end
	end
	if P.IsGoingOnSomeone(bot)
	then	
		local target = bot:GetTarget();
		if P.IsValidTarget(target)
		then
			local enemies = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE);
			if #enemies > 1 then
				for i=1, #enemies do
					if enemies[i] ~= target and P.CanCastOnNonMagicImmune(enemies[i]) then
						return BOT_ACTION_DESIRE_ABSOLUTE, enemies[i], 'unit';
					end
				end
			end
		end
	end
	return BOT_ACTION_DESIRE_NONE;
end]]--

return PIU;