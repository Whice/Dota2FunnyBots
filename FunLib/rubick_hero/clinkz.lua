local bot
local X = {}
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local Strafe
local TarBomb
local DeathPact
local BurningBarrage
local BurningArmy
local SkeletonWalk

local botTarget

function X.ConsiderStolenSpell(ability)
    bot = GetBot()

    if J.CanNotUseAbility(bot) then return end

    botTarget = J.GetProperTarget(bot)
    local abilityName = ability:GetName()

    if abilityName == 'clinkz_wind_walk'
    then
        SkeletonWalk = ability
        SkeletonWalkDesire = X.ConsiderSkeletonWalk()
        if SkeletonWalkDesire > 0
        then
            bot:Action_UseAbility(SkeletonWalk)
            return
        end
    end

    if abilityName == 'clinkz_tar_bomb'
    then
        TarBomb = ability
        TarBombDesire, TarBombTarget = X.ConsiderTarBomb()
        if TarBombDesire > 0
        then
            bot:Action_UseAbilityOnEntity(TarBomb, TarBombTarget)
            return
        end
    end

    if abilityName == 'clinkz_burning_barrage'
    then
        BurningArmy = ability
        BurningBarrageDesire, BurningBarrageLocation = X.ConsiderBurningBarrage()
        if BurningBarrageDesire > 0
        then
            bot:Action_UseAbilityOnLocation(BurningBarrage, BurningBarrageLocation)
            return
        end
    end

    if abilityName == 'clinkz_strafe'
    then
        Strafe = ability
        StrafeDesire = X.ConsiderStrafe()
        if StrafeDesire > 0
        then
            bot:Action_UseAbility(Strafe)
            return
        end
    end

    if abilityName == 'clinkz_death_pact'
    then
        DeathPact = ability
        DeathPactDesire, DeathPactTarget = X.ConsiderDeathPact()
        if DeathPactDesire > 0
        then
            bot:Action_UseAbilityOnEntity(DeathPact, DeathPactTarget)
            return
        end
    end

    if abilityName == 'clinkz_burning_army'
    then
        BurningArmy = ability
        BurningArmyDesire, BurningArmyLocation = X.ConsiderBurningArmy()
        if BurningArmyDesire > 0
        then
            bot:Action_UseAbilityOnLocation(BurningArmy, BurningArmyLocation)
            return
        end
    end
end

function X.ConsiderStrafe()
    if not Strafe:IsFullyCastable()
    then
		return BOT_ACTION_DESIRE_NONE
	end

    local nAttackRange = bot:GetAttackRange()

    if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidTarget(botTarget)
        and J.IsInRange(bot, botTarget, nAttackRange)
        and not J.IsChasingTarget(bot, botTarget)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
		then
            local nInRangeAlly = J.GetNearbyHeroes(botTarget, 1200, true, BOT_MODE_NONE)
            local nInRangeEnemy = J.GetNearbyHeroes(botTarget, 1200, false, BOT_MODE_NONE)

            if nInRangeAlly ~= nil and nInRangeEnemy ~= nil
            and #nInRangeAlly >= #nInRangeEnemy
            then
                return BOT_ACTION_DESIRE_HIGH
            end
		end
	end

    if J.IsFarming(bot)
    then
        if J.IsAttacking(bot)
        then
            local nNeutralCreeps = bot:GetNearbyNeutralCreeps(1000)
            if nNeutralCreeps ~= nil
            and (#nNeutralCreeps >= 3
                or (#nNeutralCreeps >= 2 and nNeutralCreeps[1]:IsAncientCreep()))
            then
                if J.GetMP(bot) > 0.25
                then
                    return BOT_ACTION_DESIRE_HIGH
                end
            end

            local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(1000, true)
            if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 4
            then
                if J.GetMP(bot) > 0.25
                then
                    return BOT_ACTION_DESIRE_HIGH
                end
            end
        end
    end

    if J.IsPushing(bot) or J.IsDefending(bot)
    then
        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(1000, true)
        if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 4
        then
            if J.GetMP(bot) > 0.25
            then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
    end

	if J.IsDoingRoshan(bot) or J.IsDoingTormentor(bot)
	then
		if (J.IsRoshan(botTarget) or J.IsTormentor(botTarget))
        and J.IsInRange(bot, botTarget, nAttackRange)
        and J.IsAttacking(bot)
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderTarBomb()
    if not TarBomb:IsFullyCastable()
    then
		return BOT_ACTION_DESIRE_NONE, nil
	end

    local nLevel = TarBomb:GetLevel()
    local nCastRange = J.GetProperCastRange(false, bot, TarBomb:GetCastRange())
    local nDamage = 40 + (20 * nLevel - 1)
    local nRadius = 325
    local nEnemyHeroes = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)
    local nAllyHeroes = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)

    for _, enemyHero in pairs(nEnemyHeroes)
    do
        if J.IsValidTarget(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
        and not J.IsSuspiciousIllusion(enemyHero)
        and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
        and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
        and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
        and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
        and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
        then
            return BOT_ACTION_DESIRE_HIGH, enemyHero
        end
    end

    if J.IsGoingOnSomeone(bot)
    then
        if J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange + nRadius)
        and not J.IsSuspiciousIllusion(botTarget)
        and not J.IsDisabled(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        then
            local nInRangeAlly = J.GetNearbyHeroes(botTarget, 1200, true, BOT_MODE_NONE)
            local nInRangeEnemy = J.GetNearbyHeroes(botTarget, 1200, false, BOT_MODE_NONE)

            if nInRangeAlly ~= nil and nInRangeEnemy ~= nil
            and #nInRangeAlly >= #nInRangeEnemy
            then
                if J.IsAttacking(bot)
                or (J.IsChasingTarget(bot, botTarget)
                    and bot:GetCurrentMovementSpeed() < botTarget:GetCurrentMovementSpeed())
                then
                    return BOT_ACTION_DESIRE_HIGH, botTarget
                end
            end
        end
    end

	if J.IsRetreating(bot)
    and bot:GetActiveModeDesire() > 0.5
	then
        local nInRangeEnemy = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)
        for _, enemyHero in pairs(nInRangeEnemy)
        do
            if J.IsValidHero(enemyHero)
            and J.IsChasingTarget(enemyHero, bot)
            and not J.IsSuspiciousIllusion(enemyHero)
            and not J.IsDisabled(enemyHero)
            then
                local nInRangeAlly = J.GetNearbyHeroes(enemyHero, 1200, true, BOT_MODE_NONE)
                local nTargetInRangeAlly = J.GetNearbyHeroes(enemyHero, 1200, false, BOT_MODE_NONE)

                if nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
                and ((#nTargetInRangeAlly > #nInRangeAlly)
                    or bot:WasRecentlyDamagedByAnyHero(1.5))
                and bot:GetCurrentMovementSpeed() < enemyHero:GetCurrentMovementSpeed()
                then
                    return BOT_ACTION_DESIRE_HIGH, enemyHero
                end
            end
        end
	end

    if J.IsPushing(bot)
    then
        if J.IsValidBuilding(botTarget)
        and J.CanBeAttacked(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and J.IsAttacking(botTarget)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget
        end
    end

    if J.IsFarming(bot)
    then
        if J.IsAttacking(bot)
        then
            local nNeutralCreeps = bot:GetNearbyNeutralCreeps(1000)
            if nNeutralCreeps ~= nil and #nNeutralCreeps >= 1
            and nNeutralCreeps[1]:GetHealth() >= 600
            then
                if J.GetMP(bot) > 0.4
                then
                    return BOT_ACTION_DESIRE_HIGH, nNeutralCreeps[1]
                end
            end

            local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(1000, true)
            if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 1
            and nEnemyLaneCreeps[1]:GetHealth() >= 550
            then
                if J.GetMP(bot) > 0.4
                then
                    return BOT_ACTION_DESIRE_HIGH, nEnemyLaneCreeps[1]
                end
            end
        end
    end

    if J.IsLaning(bot)
    then
        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)

		for _, creep in pairs(nEnemyLaneCreeps)
		do
			if J.IsValid(creep)
			and (J.IsKeyWordUnit('ranged', creep) or J.IsKeyWordUnit('siege', creep) or J.IsKeyWordUnit('flagbearer', creep))
			and creep:GetHealth() <= nDamage
			then
				local nCreepInRangeHero = J.GetNearbyHeroes(bot,1600, false, BOT_MODE_NONE)

				if nCreepInRangeHero ~= nil and #nCreepInRangeHero >= 1
                and GetUnitToUnitDistance(creep, nCreepInRangeHero[1]) < 600
                and botTarget ~= creep
                and J.GetMP(bot) > 0.3
                and J.CanBeAttacked(creep)
                and J.IsInLaningPhase()
				then
					return BOT_ACTION_DESIRE_HIGH, creep
				end
			end
		end
    end

	if J.IsDoingRoshan(bot) or J.IsDoingTormentor(bot)
	then
		if (J.IsRoshan(botTarget) or J.IsTormentor(botTarget))
        and J.IsInRange(bot, botTarget, bot:GetAttackRange())
        and J.IsAttacking(bot)
		then
            return BOT_ACTION_DESIRE_HIGH, botTarget
		end
	end

    for _, allyHero in pairs(nAllyHeroes)
    do
        local nAllyInRangeEnemy = J.GetNearbyHeroes(allyHero, 1200, true, BOT_MODE_NONE)

        if J.IsValidHero(allyHero)
        and J.IsRetreating(allyHero)
        and allyHero:WasRecentlyDamagedByAnyHero(2)
        and not allyHero:IsIllusion()
        then
            if nAllyInRangeEnemy ~= nil and #nAllyInRangeEnemy >= 1
            and J.IsValidHero(nAllyInRangeEnemy[1])
            and J.IsInRange(bot, nAllyInRangeEnemy[1], nCastRange)
            and J.IsChasingTarget(nAllyInRangeEnemy[1], allyHero)
            and allyHero:GetCurrentMovementSpeed() < nAllyInRangeEnemy[1]:GetCurrentMovementSpeed()
            and not J.IsDisabled(nAllyInRangeEnemy[1])
            and not J.IsTaunted(nAllyInRangeEnemy[1])
            and not J.IsSuspiciousIllusion(nAllyInRangeEnemy[1])
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_necrolyte_reapers_scythe')
            then
                return BOT_ACTION_DESIRE_HIGH, nAllyInRangeEnemy[1]
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderDeathPact()
    if not DeathPact:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local nCastRange = J.GetProperCastRange(false, bot, DeathPact:GetCastRange())
    local nMaxLevel = DeathPact:GetSpecialValueInt('creep_level')
    local nCreeps = bot:GetNearbyCreeps(nCastRange, true)

    if J.IsInLaningPhase()
    then
        if J.IsLaning(bot)
        then
            local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)

            for _, creep in pairs(nEnemyLaneCreeps)
            do
                if J.IsValid(creep)
                and J.CanBeAttacked(creep)
                and J.IsKeyWordUnit('ranged', creep) or J.IsKeyWordUnit('siege', creep)
                and creep:GetLevel() <= nMaxLevel
                then
                    local nCreepInRangeHero = J.GetNearbyHeroes(bot,1600, false, BOT_MODE_NONE)

                    if nCreepInRangeHero ~= nil and #nCreepInRangeHero >= 1
                    and GetUnitToUnitDistance(creep, nCreepInRangeHero[1]) < 600
                    and botTarget ~= creep
                    and not bot:HasModifier('modifier_clinkz_death_pact')
                    then
                        return BOT_ACTION_DESIRE_HIGH, creep
                    end
                end
            end
        end
    else
        local creep = X.GetMostHPCreepLevel(nCreeps, nMaxLevel)
        if creep ~= nil
        and not bot:HasModifier('modifier_clinkz_death_pact')
        and not creep:IsAncientCreep()
        then
            return BOT_ACTION_DESIRE_HIGH, creep
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderSkeletonWalk()
    if not SkeletonWalk:IsFullyCastable()
    or bot:HasModifier('modifier_clinkz_wind_walk')
    or J.IsRealInvisible(bot)
    then
        return BOT_ACTION_DESIRE_NONE
    end

    local RoshanLocation = J.GetCurrentRoshanLocation()
    local TormentorLocation = J.GetTormentorLocation(GetTeam())
    local nEnemyHeroes = J.GetNearbyHeroes(bot,1600, true, BOT_MODE_NONE)

    if J.IsGoingOnSomeone(bot)
    and bot:GetActiveModeDesire() > 0.65
	then
		if J.IsValidTarget(botTarget)
        and GetUnitToUnitDistance(bot, botTarget) > 1600
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
		then
            local nInRangeAlly = J.GetAlliesNearLoc(botTarget:GetLocation(), 1200)
            local nInRangeEnemy = J.GetEnemiesNearLoc(botTarget:GetLocation(), 1200)

            if nInRangeAlly ~= nil and nInRangeEnemy ~= nil
            and #nInRangeAlly >= #nInRangeEnemy
            then
                return BOT_ACTION_DESIRE_HIGH
            end
		end
	end

    if J.IsRetreating(bot)
    and bot:GetActiveModeDesire() > 0.5
	then
        local nInRangeEnemy = J.GetNearbyHeroes(bot,1200, true, BOT_MODE_NONE)
        for _, enemyHero in pairs(nInRangeEnemy)
        do
            if J.IsValidHero(enemyHero)
            and J.IsChasingTarget(enemyHero, bot)
            and not J.IsSuspiciousIllusion(enemyHero)
            and not J.IsDisabled(enemyHero)
            then
                local nInRangeAlly = J.GetNearbyHeroes(enemyHero, 1200, true, BOT_MODE_NONE)
                local nTargetInRangeAlly = J.GetNearbyHeroes(enemyHero, 1200, false, BOT_MODE_NONE)

                if nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
                and ((#nTargetInRangeAlly > #nInRangeAlly)
                    or bot:WasRecentlyDamagedByAnyHero(1.5))
                then
                    return BOT_ACTION_DESIRE_HIGH
                end
            end
        end
	end

    -- if J.IsPushing(bot)
    -- then
    --     if bot.laneToPush ~= nil
    --     then
    --         if GetUnitToLocationDistance(bot, GetLaneFrontLocation(GetTeam(), bot.laneToPush, 0)) > 3200
    --         and bot:GetActiveModeDesire() > 0.65
    --         then
    --             return  BOT_ACTION_DESIRE_HIGH
    --         end
    --     end
    -- end

    -- if J.IsDefending(bot)
    -- then
    --     if bot.laneToDefend ~= nil
    --     then
    --         if GetUnitToLocationDistance(bot, GetLaneFrontLocation(GetTeam(), bot.laneToDefend, 0)) > 3200
    --         and bot:GetActiveModeDesire() > 0.65
    --         then
    --             return  BOT_ACTION_DESIRE_HIGH
    --         end
    --     end
    -- end

    if J.IsFarming(bot)
    then
        if bot.farmLocation ~= nil
        then
            if GetUnitToLocationDistance(bot, bot.farmLocation) > 3200
            then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
    end

    if J.IsLaning(bot)
	then
		if J.GetManaAfter(SkeletonWalk:GetManaCost()) > 0.8
		and bot:DistanceFromFountain() > 100
		and bot:DistanceFromFountain() < 6000
		and J.IsInLaningPhase()
		and nEnemyHeroes ~= nil and #nEnemyHeroes == 0
		then
			local nLane = bot:GetAssignedLane()
			local nLaneFrontLocation = GetLaneFrontLocation(GetTeam(), nLane, 0)
			local nDistFromLane = GetUnitToLocationDistance(bot, nLaneFrontLocation)

			if nDistFromLane > 1600
			then
                return BOT_ACTION_DESIRE_HIGH
			end
		end
	end

    if J.IsDoingRoshan(bot)
    then
        if GetUnitToLocationDistance(bot, RoshanLocation) > 4000
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    if J.IsDoingTormentor(bot)
    then
        if GetUnitToLocationDistance(bot, TormentorLocation) > 4000
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

--Aghanim's Shard
function X.ConsiderBurningBarrage()
    if not BurningBarrage:IsTrained()
    or not BurningBarrage:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    local nCastRange = J.GetProperCastRange(false, bot, BurningBarrage:GetCastRange())
    local nRadius = BurningBarrage:GetSpecialValueInt('radius')

    if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidTarget(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange - 125)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
		then
            local nInRangeAlly = J.GetAlliesNearLoc(botTarget:GetLocation(), 1200)
            local nInRangeEnemy = J.GetEnemiesNearLoc(botTarget:GetLocation(), 1200)

            if nInRangeAlly ~= nil and nInRangeEnemy ~= nil
            and #nInRangeAlly >= #nInRangeEnemy
            then
                nInRangeEnemy = J.GetEnemiesNearLoc(botTarget:GetLocation(), nRadius - 75)
                if nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
                then
                    return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nInRangeEnemy)
                else
                    return BOT_ACTION_DESIRE_HIGH, botTarget:GetExtrapolatedLocation(0.5)
                end
            end
		end
	end

    if J.IsFarming(bot)
    then
        local nNeutralCreeps = bot:GetNearbyNeutralCreeps(1000)
        if nNeutralCreeps ~= nil and #nNeutralCreeps >= 1
        and J.IsAttacking(bot)
        and J.GetManaAfter(BurningBarrage:GetManaCost()) * bot:GetMana() > SkeletonWalk:GetManaCost()
        then
            if J.IsBigCamp(nNeutralCreeps)
            or nNeutralCreeps[1]:IsAncientCreep()
            then
                if #nNeutralCreeps >= 2
                then
                    return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nNeutralCreeps)
                end
            else
                if #nNeutralCreeps >= 3
                then
                    return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nNeutralCreeps)
                end
            end
        end

        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(1000, true)
		if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 4
		then
			return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nEnemyLaneCreeps)
		end
    end

    if J.IsPushing(bot) or J.IsDefending(bot)
    then
        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(1000, true)
		if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 4
		then
			return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nEnemyLaneCreeps)
		end
    end

    if J.IsDoingRoshan(bot) or J.IsDoingTormentor(bot)
	then
		if (J.IsRoshan(botTarget) or J.IsTormentor(botTarget))
        and J.IsInRange(bot, botTarget, bot:GetAttackRange())
        and J.IsAttacking(bot)
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
		end
	end

    return BOT_ACTION_DESIRE_NONE, 0
end

--Aghanim's Scepter
function X.ConsiderBurningArmy()
    if not BurningBarrage:IsTrained()
    or not BurningBarrage:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    local nAttackRange = bot:GetAttackRange()
	local nCastRange = J.GetProperCastRange(false, bot, BurningArmy:GetCastRange())
    local nSpawnRange = 900

	if J.IsInTeamFight(bot, 1200)
	then
		local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange + (nSpawnRange / 2), nSpawnRange, 0, 0)
        local nInRangeEnemy = J.GetEnemiesNearLoc(nLocationAoE.targetloc, nSpawnRange)

		if nInRangeEnemy ~= nil and #nInRangeEnemy >= 2
        then
            if GetUnitToLocationDistance(bot, J.GetCenterOfUnits(nInRangeEnemy)) > nCastRange
            then
                return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, J.GetCenterOfUnits(nInRangeEnemy), nCastRange)
            else
                return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nInRangeEnemy)
            end
		end
	end

    if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidTarget(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
		then
            local nInRangeAlly = J.GetAlliesNearLoc(botTarget:GetLocation(), 1200)
            local nInRangeEnemy = J.GetEnemiesNearLoc(botTarget:GetLocation(), 1200)

            if nInRangeAlly ~= nil and nInRangeEnemy ~= nil
            and #nInRangeAlly >= #nInRangeEnemy
            then
                nInRangeEnemy = J.GetEnemiesNearLoc(botTarget:GetLocation(), nSpawnRange)
                if nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
                then
                    if GetUnitToLocationDistance(bot, J.GetCenterOfUnits(nInRangeEnemy)) > nCastRange
                    then
                        return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, J.GetCenterOfUnits(nInRangeEnemy), nCastRange)
                    else
                        return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nInRangeEnemy)
                    end
                else
                    if GetUnitToUnitDistance(bot, botTarget) > nCastRange
                    then
                        return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, botTarget:GetLocation(), nCastRange)
                    else
                        return BOT_ACTION_DESIRE_HIGH, botTarget:GetExtrapolatedLocation(0.5)
                    end
                end
            end
		end
	end

    return BOT_ACTION_DESIRE_NONE, 0
end

-- Helper Funcs
function X.GetMostHPCreepLevel(creeList, level)
	local mostHpCreep = nil
	local maxHP = 0

	for _, creep in pairs(creeList)
	do
		local uHp = creep:GetHealth()
        local lvl = creep:GetLevel()

		if uHp > maxHP
        and lvl <= level
        and not J.IsKeyWordUnit("flagbearer", creep)
		then
			mostHpCreep = creep
			maxHP = uHp
		end
	end

	return mostHpCreep
end

return X