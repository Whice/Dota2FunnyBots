local P = {}

local RB = Vector(-7174.000000, -6671.00000,  0.000000)
local DB = Vector(7023.000000, 6450.000000, 0.000000)

local modifier = {
	"modifier_winter_wyvern_winters_curse",
	"modifier_winter_wyvern_winters_curse_aura"
	--"modifier_modifier_dazzle_shallow_grave",
	--"modifier_modifier_oracle_false_promise",
	--"modifier_oracle_fates_edict"
}

local calibrateTime = DotaTime()
local checkCourier = false
local define_courier = false
local cr = nil
P.pIDInc = 1
P.calibrateTime = DotaTime()

function P.IsInLaningPhase()
	return DotaTime() < 60 * 10
end

function P.CombineTables(TableOne, TableTwo)
	local CombinedTable = {}

	for v, TableItem in pairs(TableOne) do
		table.insert(CombinedTable, TableItem)
	end
	for v, TableItem in pairs(TableTwo) do
		table.insert(CombinedTable, TableItem)
	end
	for v, EnemyWard in pairs(GetUnitList(UNIT_LIST_ENEMY_WARDS)) do
		table.insert(CombinedTable, EnemyWard)
	end
	
	for v, EnemyBuildings in pairs(GetUnitList(UNIT_LIST_ENEMY_BUILDINGS)) do
		table.insert(CombinedTable, EnemyBuildings)
	end
	
	return CombinedTable
end

function P.HasShard(pbot)
	return pbot:HasModifier("modifier_item_aghanims_shard")
end

function P.IsValidTarget(botTarget)
	return botTarget ~= nil 
	and botTarget:IsAlive() 
	and botTarget:IsHero()
end

function P.IsNotImmune(botTarget)
	return P.IsValidTarget(botTarget)
	and botTarget:CanBeSeen()
	and not botTarget:IsInvulnerable()
	and not botTarget:IsMagicImmune()
end

function P.CanCastOnNonImmune(botTarget)	
	return P.IsValidTarget(botTarget)
	and botTarget:CanBeSeen()
	and not botTarget:IsInvulnerable()
end

function P.IsMeepoClone(unit)
	if unit:GetUnitName() == "npc_dota_hero_meepo" and unit:GetLevel() > 1 
	then
		for i=0, 5 do
			local item = unit:GetItemInSlot(i);
			if item ~= nil and not (string.find(item:GetName(),"boots") or string.find(item:GetName(),"treads"))  
			then
				return false
			end
		end
		return true
    end
	return false
end

function P.IllusionTargetTEST(hMinionUnit, bot)
	local BotTarget = bot:GetAttackTarget()
	
	if BotTarget ~= nil then
		return BotTarget
	end
	
	return nil
end

function P.IllusionTarget(hMinionUnit, bot)
	local enemies = bot:GetNearbyHeroes(1000, true, BOT_MODE_NONE)
	local target = nil
	
	if GetUnitToUnitDistance(hMinionUnit, GetAncient(GetOpposingTeam())) <= 1000 then
		target = GetAncient(GetOpposingTeam())
	end
	
	if #enemies >= 1 then
		target = P.GetWeakestEnemyHeroPhysical(enemies)
	end
	
	if target == nil and bot:GetActiveMode() == BOT_MODE_FARM then
		enemies = bot:GetNearbyNeutralCreeps(bot:GetAttackRange() + 100)
	
		local weakestunit = nil
		local smallesthealth = 99999
			
		for v, unit in pairs(enemies) do
			if unit ~= nil and unit:CanBeSeen() then
				if unit:GetHealth() < smallesthealth then
					weakestunit = unit
					smallesthealth = unit:GetHealth()
				end
			end
		end
	
		target = weakestunit
	end
	
	if target == nil then
		enemies = bot:GetNearbyLaneCreeps(1000, true)
		
		local weakestunit = nil
		local smallesthealth = 99999
			
		for v, unit in pairs(enemies) do
			if unit ~= nil and unit:CanBeSeen() then
				if unit:GetHealth() < smallesthealth then
					weakestunit = unit
					smallesthealth = unit:GetHealth()
				end
			end
		end
	
		target = weakestunit
	end
	
	if target == nil then
		enemies = bot:GetNearbyCreeps(1000, true)
		
		local weakestunit = nil
		local smallesthealth = 99999
			
		for v, unit in pairs(enemies) do
			if unit ~= nil and unit:CanBeSeen() then
				if unit:GetHealth() < smallesthealth then
					weakestunit = unit
					smallesthealth = unit:GetHealth()
				end
			end
		end
	
		target = weakestunit
	end
	
	if target == nil then
		enemies = hMinionUnit:GetNearbyBarracks(1000, true)
		
		local weakestunit = nil
		local smallesthealth = 99999
			
		for v, unit in pairs(enemies) do
			if unit ~= nil and unit:CanBeSeen() and not unit:IsInvulnerable() then
				if unit:GetHealth() < smallesthealth then
					weakestunit = unit
					smallesthealth = unit:GetHealth()
				end
			end
		end
	
		target = weakestunit
	end
	
	if target == nil then
		enemies = hMinionUnit:GetNearbyTowers(1000, true)
		
		local weakestunit = nil
		local smallesthealth = 99999
			
		for v, unit in pairs(enemies) do
			if unit ~= nil and unit:CanBeSeen() and not unit:IsInvulnerable() then
				if unit:GetHealth() < smallesthealth then
					weakestunit = unit
					smallesthealth = unit:GetHealth()
				end
			end
		end
	
		target = weakestunit
	end
	
	if target ~= nil and not target:IsAttackImmune() and not target:IsInvulnerable() then
		if GetUnitToUnitDistance(bot, target) > 1000 then
			target = nil
			return target
		else
			return target
		end
	end
	
	return target
end

function P.FilterEnemiesForStun(enemies)
	local filteredenemies = {}
	
	for v, enemy in pairs(enemies) do
		if not P.IsPossibleIllusion(enemy) and not enemy:IsRooted() and not enemy:IsStunned() and not enemy:IsHexed() and not enemy:IsNightmared() and not P.IsTaunted(enemy) then
			table.insert(filteredenemies, enemy)
		end
	end
	
	return filteredenemies
end

function P.IsPDisabled(pbot)
	return pbot:CanBeSeen() and (pbot:IsRooted() or pbot:IsStunned() or pbot:IsHexed() or pbot:IsNightmared() or P.IsTaunted(pbot))
end

function P.CantUseAbility(pbot)
	return pbot:IsAlive() == false 
	or pbot:IsInvulnerable() 
	or pbot:IsCastingAbility()
	or pbot:IsUsingAbility() 
	or pbot:IsChanneling()  
	or pbot:IsSilenced() 
	or pbot:IsStunned() 
	or pbot:IsHexed()  
	or pbot:HasModifier("modifier_doom_bringer_doom")
	or pbot:HasModifier('modifier_item_forcestaff_active')
end

function P.IsDisabled(enemy, pbot)
	if enemy then
		return pbot:IsRooted() or pbot:IsStunned() or pbot:IsHexed() or pbot:IsNightmared() or P.IsTaunted(pbot); 
	else
		return pbot:IsRooted() or pbot:IsStunned() or pbot:IsHexed() or pbot:IsNightmared() or pbot:IsSilenced() or P.IsTaunted(pbot);
	end
end

function P.IsTaunted(botTarget)
		return botTarget:HasModifier("modifier_axe_berserkers_call") 
	    or botTarget:HasModifier("modifier_legion_commander_duel") 
	    or botTarget:HasModifier("modifier_winter_wyvern_winters_curse") 
		or botTarget:HasModifier(" modifier_winter_wyvern_winters_curse_aura");
end

function P.CanCastOnMagicImmune(botTarget)
	return botTarget:CanBeSeen() and not botTarget:IsInvulnerable() and not P.IsPossibleIllusion(botTarget) and not P.HasForbiddenModifier(botTarget)
end

function P.CanCastOnNonMagicImmune(botTarget)
	return botTarget:CanBeSeen() and not botTarget:IsMagicImmune() and not botTarget:IsInvulnerable() and not P.IsPossibleIllusion(botTarget) and not P.HasForbiddenModifier(botTarget)
end

function P.HasForbiddenModifier(botTarget)
	for _,mod in pairs(modifier)
	do
		if botTarget:HasModifier(mod) then
			return true
		end	
	end
	return false;
end

function P.IsStuck(pbot)
	if pbot.stuckLoc ~= nil and pbot.stuckTime ~= nil then 
		local attackTarget = pbot:GetAttackTarget();
		local EAd = GetUnitToUnitDistance(pbot, GetAncient(GetOpposingTeam()));
		local TAd = GetUnitToUnitDistance(pbot, GetAncient(GetTeam()));
		local Et = pbot:GetNearbyTowers(450, true);
		local At = pbot:GetNearbyTowers(450, false);
		if pbot:GetCurrentActionType() == BOT_ACTION_TYPE_MOVE_TO and attackTarget == nil and EAd > 2200 and TAd > 2200 and #Et == 0 and #At == 0  
		   and DotaTime() > pbot.stuckTime + 5.0 and GetUnitToLocationDistance(pbot, pbot.stuckLoc) < 25    
		then
			return true;
		end
	end
	return false
end

function P.GetTeamFountain()
	local Team = GetTeam();
	if Team == TEAM_DIRE then
		return DB;
	else
		return RB;
	end
end

function P.GetEscapeLoc()
	local bot = GetBot();
	local team = GetTeam();
	if bot:DistanceFromFountain() > 2500 then
		return GetAncient(team):GetLocation();
	else
		if team == TEAM_DIRE then
			return DB;
		else
			return RB;
		end
	end
end

function P.GetEscapeLoc2(pbot)
	local team = pbot:GetTeam();
	if pbot:DistanceFromFountain() > 2500 then
		return GetAncient(team):GetLocation();
	else
		if team == TEAM_DIRE then
			return DB;
		else
			return RB;
		end
	end
end

function P.IsGoingOnSomeone(pbot)
	local mode = pbot:GetActiveMode();
	return mode == BOT_MODE_ROAM or
		   mode == BOT_MODE_TEAM_ROAM or
		   mode == BOT_MODE_ATTACK or
		   mode == BOT_MODE_DEFEND_ALLY
end

function P.IsDefending(pbot)
	local mode = pbot:GetActiveMode();
	return mode == BOT_MODE_DEFEND_TOWER_TOP or
		   mode == BOT_MODE_DEFEND_TOWER_MID or
		   mode == BOT_MODE_DEFEND_TOWER_BOT 
end

function P.IsPushing(pbot)
	local mode = pbot:GetActiveMode();
	return mode == BOT_MODE_PUSH_TOWER_TOP or
		   mode == BOT_MODE_PUSH_TOWER_MID or
		   mode == BOT_MODE_PUSH_TOWER_BOT 
end

function P.IsFarming(pbot)
	local mode = pbot:GetActiveMode();
	return mode == BOT_MODE_FARM
end

function P.IsInRange(botTarget, pbot, nCastRange)
	return GetUnitToUnitDistance( botTarget, pbot ) <= nCastRange;
end

function P.CanBeDominatedCreeps(name)
	return name == "npc_dota_neutral_centaur_khan"
		 or name == "npc_dota_neutral_polar_furbolg_ursa_warrior"	
		 or name == "npc_dota_neutral_satyr_hellcaller"	
		 or name == "npc_dota_neutral_dark_troll_warlord"	
		 or name == "npc_dota_neutral_mud_golem"	
		 or name == "npc_dota_neutral_harpy_storm"	
		 or name == "npc_dota_neutral_ogre_magi"	
		 or name == "npc_dota_neutral_alpha_wolf"	
		 or name == "npc_dota_neutral_enraged_wildkin"	
		 or name == "npc_dota_neutral_satyr_trickster"	
end

function P.IsInTeamFight(pbot, range)
	local tableNearbyAttackingAlliedHeroes = pbot:GetNearbyHeroes( range, false, BOT_MODE_ATTACK );
	return tableNearbyAttackingAlliedHeroes ~= nil and #tableNearbyAttackingAlliedHeroes >= 2;
end

function P.GetClosestEnemyUnitToLocation(hUnit, nRange, vLoc)
	local eHeroes = hUnit:GetNearbyHeroes(nRange, true, BOT_MODE_NONE);
	local eCreeps = hUnit:GetNearbyLaneCreeps(nRange, true);
		
	local botDist = GetUnitToLocationDistance(hUnit, vLoc);
	local closestUnit = hUnit;
	botDist, closestUnit = U.GetUnitWithMinDistanceToLoc(hUnit, eHeroes, closestUnit, botDist, vLoc);
	botDist, closestUnit = U.GetUnitWithMinDistanceToLoc(hUnit, eCreeps, closestUnit, botDist, vLoc);
	
	if closestUnit ~= bot then
		return closestUnit;
	end
	
	return nil;
	
end

function P.GetClosestEnemy(pbot, enemies)
	local closestenemy = nil
	local shortestdistance = 99999

	for v, enemy in pairs(enemies) do
		if P.IsValidTarget(enemy) and P.IsNotImmune(enemy) and not P.IsPossibleIllusion(enemy) then
			if GetUnitToUnitDistance(pbot, enemy) < shortestdistance then
				closestenemy = enemy
				shortestdistance = GetUnitToUnitDistance(pbot, enemy)
			end
		end
	end
	
	return closestenemy
end

function P.GetWeakestEnemyHero(enemies)
	local weakestenemy = nil
	local lowesthealth = 99999

	for v, enemy in pairs(enemies) do
		if P.IsValidTarget(enemy) 
		and P.IsNotImmune(enemy) 
		and not P.IsPossibleIllusion(enemy)
		and not enemy:HasModifier("modifier_item_chainmail")
		and not enemy:HasModifier("modifier_abaddon_borrowed_time") then
			if enemy:GetHealth() < lowesthealth then
				weakestenemy = enemy
				lowesthealth = enemy:GetHealth()
			end
		end
	end
	
	return weakestenemy
end

function P.GetWeakestEnemyHeroPhysical(enemies)
	local weakestenemy = nil
	local lowesthealth = 99999

	for v, enemy in pairs(enemies) do
		if P.IsValidTarget(enemy) 
		and not enemy:IsAttackImmune() 
		and not P.IsPossibleIllusion(enemy) 
		and not enemy:HasModifier("modifier_item_chainmail")
		and not enemy:HasModifier("modifier_abaddon_borrowed_time") then
			if enemy:GetHealth() < lowesthealth then
				weakestenemy = enemy
				lowesthealth = enemy:GetHealth()
			end
		end
	end
	
	return weakestenemy
end

function P.GetStrongestEnemyHero(enemies)
	local strongestenemy = nil
	local highesthealth = 0

	for v, enemy in pairs(enemies) do
		if P.IsValidTarget(enemy) and P.IsNotImmune(enemy) and not P.IsPossibleIllusion(enemy) then
			if enemy:GetHealth() > highesthealth then
				strongestenemy = enemy
				highesthealth = enemy:GetHealth()
			end
		end
	end
	
	return strongestenemy
end

function P.GetStrongestADEnemyHero(enemies)
	local strongestenemy = nil
	local highestdmg = 0

	for v, enemy in pairs(enemies) do
		if P.IsValidTarget(enemy) and P.IsNotImmune(enemy) and not P.IsPossibleIllusion(enemy) then
			if enemy:GetAttackDamage() > highestdmg then
				strongestenemy = enemy
				highestdmg = enemy:GetAttackDamage()
			end
		end
	end
	
	return strongestenemy
end

function P.GetStrongestUnit(nRange, hUnit, bEnemy, bMagicImune, fTime)
	local units = hUnit:GetNearbyHeroes(nRange, bEnemy, BOT_MODE_NONE)
	local strongest_unit = nil;
	local maxPower = 0;
	for i=1, #units do
		if U.IsValidTarget(units[i]) and
		   ( ( bMagicImune == true and P.CanCastOnMagicImmune(units[i]) == true ) or ( bMagicImune == false and P.CanCastOnNonImmune(units[i]) == true ) )
		then
			local power = units[i]:GetEstimatedDamageToTarget( true, hUnit, fTime, DAMAGE_TYPE_ALL );
			if power > maxPower then
				maxPower = power;
				strongest_unit = units[i];
			end
		end
	end
	return strongest_unit;
end

function P.GetWeakestNonImmuneEnemyHero(enemies)
	local weakestenemy = nil
	local lowesthealth = 99999

	for v, enemy in pairs(enemies) do
		if P.IsValidTarget(enemy) and P.CanCastOnNonImmune(enemy) and not P.IsPossibleIllusion(enemy) then
			if enemy:GetHealth() < lowesthealth then
				weakestenemy = enemy
				lowesthealth = enemy:GetHealth()
			end
		end
	end
	
	return weakestenemy
end

function P.GetWeakestAllyHero(allies)
	local weakestally = nil
	local lowesthealth = 99999

	for v, ally in pairs(allies) do
		if P.IsValidTarget(ally) and not P.IsPossibleIllusion(ally) then
			if ally:GetHealth() <= (ally:GetMaxHealth() * 0.75) then
				if ally:GetHealth() < lowesthealth then
					weakestally = ally
					lowesthealth = ally:GetHealth()
				end
			end
		end
	end
	
	return weakestally
end

function P.GetVulnerableUnitNearLoc(bHero, bEnemy, nCastRange, nRadius, vLoc, bot)
	local units = {};
	local weakest = nil;
	if bHero then
		units = bot:GetNearbyHeroes(nCastRange, bEnemy, BOT_MODE_NONE);
	else
		units = bot:GetNearbyLaneCreeps(nCastRange, bEnemy);
	end
	for _,u in pairs(units) do
		if GetUnitToLocationDistance(u, vLoc) < nRadius and U.CanCastOnNonMagicImmune(u) then
			weakest = u;
			break;
		end
	end
	return weakest;
end

function P.GetProperCastRange(bIgnore, hUnit, abilityCR)
	local attackRng = hUnit:GetAttackRange();
	if bIgnore then
		return abilityCR;
	elseif abilityCR <= attackRng then
		return attackRng + maxAddedRange;
	elseif abilityCR + maxAddedRange <= maxGetRange then
		return abilityCR + maxAddedRange;
	elseif abilityCR > maxGetRange then
		return maxGetRange;
	else
		return abilityCR;
	end
end

function P.IsInCombativeMode(pbot)
	return pbot:GetActiveMode() == BOT_MODE_ATTACK
	--or pbot:GetActiveMode() == BOT_MODE_ROAM
	--or pbot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP
	--or pbot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID
	--or pbot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT
	--or (pbot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_TOP and pbot:GetActiveModeDesire() > BOT_MODE_DESIRE_LOW)
	--or (pbot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_MID and pbot:GetActiveModeDesire() > BOT_MODE_DESIRE_LOW)
	--or (pbot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_BOT and pbot:GetActiveModeDesire() > BOT_MODE_DESIRE_LOW)
	or pbot:GetActiveMode() == BOT_MODE_TEAM_ROAM
	or pbot:GetActiveMode() == BOT_MODE_DEFEND_ALLY
	or pbot:GetActiveMode() == BOT_MODE_SECRET_SHOP
	--or (pbot:GetActiveMode() == BOT_MODE_SIDE_SHOP and pbot:GetActiveModeDesire() == 0.512)
	--or (pbot:GetActiveMode() == BOT_MODE_SIDE_SHOP and pbot:GetActiveModeDesire() == 0.751)
	--or (P.IsValidTarget(pbot:GetAttackTarget()) and not P.IsPossibleIllusion(pbot:GetAttackTarget()))
end

function P.FilterTrueEnemies(enemies)
	local trueenemies = {}

	for v, enemy in pairs(enemies) do
		if not P.IsPossibleIllusion(enemy) then
			table.insert(trueenemies, enemy)
		end
	end
	
	return trueenemies
end

function P.IsInPhalanxTeamFight(pbot)
	local nearbyallies = pbot:GetNearbyHeroes(1000, false, BOT_MODE_NONE)
	local nearbyenemies = pbot:GetNearbyHeroes(1000, true, BOT_MODE_NONE)
	local trueenemies = P.FilterTrueEnemies(nearbyenemies)
	
	if #nearbyallies >= 2 and #trueenemies >= 2 then
		return true
	else
		return false
	end
end

function P.IsRoshan(botTarget)
	return botTarget ~= nil and botTarget:IsAlive() and string.find(botTarget:GetUnitName(), "roshan")
end

function P.IsPossibleIllusion(botTarget)
	--TO DO Need to detect enemy hero's illusions better
	local bot = GetBot();
	--Detect allies's illusions
	if botTarget:HasModifier('modifier_illusion') 
	   or botTarget:HasModifier('modifier_phantom_lancer_doppelwalk_illusion') or botTarget:HasModifier('modifier_phantom_lancer_juxtapose_illusion')
       or botTarget:HasModifier('modifier_darkseer_wallofreplica_illusion') or botTarget:HasModifier('modifier_terrorblade_conjureimage')	   
	then
		return true
	else
	   --Detect replicate and wall of replica illusions
	    if GetGameMode() ~= GAMEMODE_MO then
			if botTarget:GetTeam() ~= bot:GetTeam() then
				local TeamMember = GetTeamPlayers(GetTeam())
				for i = 1, #TeamMember
				do
					local ally = GetTeamMember(i)
					if ally ~= nil and ally:GetUnitName() == botTarget:GetUnitName() then
						return true
					end
				end
			end
		end
		return false
	end
end

function P.IsRetreating(pbot)
	return ( pbot:GetActiveMode() == BOT_MODE_RETREAT and pbot:GetActiveModeDesire() > BOT_MODE_DESIRE_MODERATE and 
		     pbot:DistanceFromFountain() > 0 )
	or ( pbot:GetActiveMode() == BOT_MODE_EVASIVE_MANEUVERS and pbot:WasRecentlyDamagedByAnyHero(3.0) ) 
	or ( pbot:HasModifier('modifier_bloodseeker_rupture') and pbot:WasRecentlyDamagedByAnyHero(3.0) )
end

function P.GetDistance(startpos, endpos)
    return math.sqrt((startpos[1]-endpos[1])*(startpos[1]-endpos[1]) + (startpos[2]-endpos[2])*(startpos[2]-endpos[2]))
end

function P.CanUseRefresherOrb(pbot)
	local ult = P.GetUltimateAbility(pbot);
	if ult ~= nil and ult:IsPassive() == false then
		local ultCD = ult:GetCooldown();
		local manaCost = ult:GetManaCost();
		if pbot:GetMana() >= manaCost+375 and ult:GetCooldownTimeRemaining() >= ultCD/2 then
			return true;
		end
	end
	return false;
end

function P.GetUltimateAbility(pbot)
	--print(tostring(bot:GetAbilityInSlot(5):GetName()))
	return pbot:GetAbilityInSlot(5);
end

function P.IsHeroBetweenMeAndTarget(source, target, endLoc, radius)
	local vStart = source:GetLocation()
	local vEnd = endLoc
	local enemy_heroes = source:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	for i=1, #enemy_heroes do
		if enemy_heroes[i] ~= target
			and enemy_heroes[i] ~= source
		then	
			local tResult = PointToLineDistance(vStart, vEnd, enemy_heroes[i]:GetLocation())
			if tResult ~= nil 
				and tResult.within == true  
				and tResult.distance < radius	
			then
				return true;
			end
		end
	end
	local ally_heroes = source:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
	for i=1, #ally_heroes do
		if ally_heroes[i] ~= target
			and ally_heroes[i] ~= source
		then	
			local tResult = PointToLineDistance(vStart, vEnd, ally_heroes[i]:GetLocation())
			if tResult ~= nil 
				and tResult.within == true  
				and tResult.distance < radius		
			then
				return true
			end
		end
	end
	return false
end

function P.IsCreepBetweenMeAndTarget(hSource, hTarget, vLoc, nRadius)
	local vStart = hSource:GetLocation()
	local vEnd = vLoc
	local creeps = hSource:GetNearbyCreeps(1600, false)
	for i,creep in pairs(creeps) do
		local tResult = PointToLineDistance(vStart, vEnd, creep:GetLocation());
		if tResult ~= nil and tResult.within and tResult.distance <= nRadius then
			return true
		end
	end
	
	if hTarget:IsHero() then
		creeps = hTarget:GetNearbyCreeps(1600, true)
		for i,creep in pairs(creeps) do
			local tResult = PointToLineDistance(vStart, vEnd, creep:GetLocation());
			if tResult ~= nil and tResult.within and tResult.distance <= nRadius then
				return true
			end
		end
	end
	
	creeps = hSource:GetNearbyCreeps(1600, true)
	for i,creep in pairs(creeps) do
		local tResult = PointToLineDistance(vStart, vEnd, creep:GetLocation());
		if tResult ~= nil and tResult.within and tResult.distance <= nRadius then
			return true
		end
	end
	
	if hTarget:IsHero() then
		creeps = hTarget:GetNearbyCreeps(1600, false)
		for i,creep in pairs(creeps) do
			local tResult = PointToLineDistance(vStart, vEnd, creep:GetLocation());
			if tResult ~= nil and tResult.within and tResult.distance <= nRadius then
				return true
			end
		end
	end
	
	return false
end

return P