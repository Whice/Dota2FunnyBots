local bot
local X = {}
local J = require(GetScriptDirectory()..'/FunLib/jmz_func')

local botTarget

local AcidSpray
local UnstableConcoction
local UnstableConcoctionThrow
local ChemicalRage
local BerserkPotion

local defDuration = 2
local offDuration = 4.25
local ConcoctionThrowTime = 0

function X.ConsiderStolenSpell(ability)
    bot = GetBot()

    if J.CanNotUseAbility(bot) then return end

    botTarget = J.GetProperTarget(bot)
    local abilityName = ability:GetName()

    if abilityName == 'alchemist_chemical_rage'
    then
        ChemicalRage = ability
        ChemicalRageDesire = X.ConsiderChemicalRage()
        if ChemicalRageDesire > 0
        then
            bot:Action_UseAbility(ChemicalRage)
            return
        end
    end

    if abilityName == 'alchemist_unstable_concoction_throw'
    then
        UnstableConcoctionThrow = ability
        UnstableConcoctionThrowDesire, UnstableConcoctionThrowTarget = X.ConsiderUnstableConcoctionThrow()
        if UnstableConcoctionThrowDesire > 0
        then
            bot:Action_UseAbilityOnEntity(UnstableConcoctionThrow, UnstableConcoctionThrowTarget)
            return
        end
    end

    if abilityName == 'alchemist_unstable_concoction'
    then
        UnstableConcoction = ability
        UnstableConcoctionDesire = X.ConsiderUnstableConcoction()
        if UnstableConcoctionDesire > 0
        then
            bot:Action_UseAbility(UnstableConcoction)
            ConcoctionThrowTime = DotaTime()
            return
        end
    end

    if abilityName == 'alchemist_acid_spray'
    then
        AcidSpray = ability
        AcidSprayDesire, AcidSprayLocation = X.ConsiderAcidSpray()
        if AcidSprayDesire > 0
        then
            J.SetQueuePtToINT(bot, false)
            bot:Action_UseAbilityOnLocation(AcidSpray, AcidSprayLocation)
            return
        end
    end

    if abilityName == 'alchemist_berserk_potion'
    then
        BerserkPotion = ability
        BerserkPotionDesire, BerserkPotionTarget = X.ConsiderBerserkPotion()
        if BerserkPotionDesire > 0
        then
            bot:Action_UseAbilityOnEntity(BerserkPotion, BerserkPotionTarget)
            return
        end
    end
end

function X.ConsiderAcidSpray()
	if not AcidSpray:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE, 0
	end

	local nCastRange = J.GetProperCastRange(false, bot, AcidSpray:GetCastRange())
	local nCastPoint = AcidSpray:GetCastPoint()
	local nRadius = AcidSpray:GetSpecialValueInt('radius')

	if J.IsInTeamFight(bot, 1200)
	then
		local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0)
		if nLocationAoE.count >= 2
		then
			local realEnemyCount = J.GetEnemiesNearLoc(nLocationAoE.targetloc, nRadius)
            if realEnemyCount ~= nil and #realEnemyCount >= 2
            then
                return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
            end
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
		local nInRangeAlly = J.GetNearbyHeroes(bot,900, false, BOT_MODE_NONE)

		if J.IsValidTarget(botTarget)
		and J.CanCastOnNonMagicImmune(botTarget)
		and J.IsInRange(bot, botTarget, nCastRange)
		and J.IsAttacking(botTarget)
		and botTarget:IsFacingLocation(bot:GetLocation(), 45)
		and not J.IsSuspiciousIllusion(botTarget)
		and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
		and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
		and nInRangeAlly ~= nil and nInRangeEnemy ~= nil
		and #nInRangeAlly >= #nInRangeEnemy
		then
			local nTargetInRangeAlly = J.GetNearbyHeroes(botTarget, 900, false, BOT_MODE_NONE)

            if nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
            and #nInRangeAlly >= #nTargetInRangeAlly
            then
                return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
            end
		end
	end

	if J.IsRetreating(bot)
	then
		local nInRangeAlly = J.GetNearbyHeroes(bot,1000, false, BOT_MODE_NONE)
        local nInRangeEnemy = J.GetNearbyHeroes(bot,1000, true, BOT_MODE_NONE)

        if nInRangeAlly ~= nil and nInRangeEnemy
        and J.IsValidHero(nInRangeEnemy[1])
        and J.CanCastOnNonMagicImmune(nInRangeEnemy[1])
        and J.IsInRange(bot, nInRangeEnemy[1], 600)
        and J.IsRunning(nInRangeEnemy[1])
        and nInRangeEnemy[1]:IsFacingLocation(bot:GetLocation(), 30)
        and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
		and not J.IsDisabled(nInRangeEnemy[1])
        then
            local nTargetInRangeAlly = J.GetNearbyHeroes(nInRangeEnemy[1], 800, false, BOT_MODE_NONE)

            if nTargetInRangeAlly ~= nil
            and ((#nTargetInRangeAlly > #nInRangeAlly)
                or (J.GetHP(bot) < 0.45 and bot:WasRecentlyDamagedByAnyHero(2.5)))
            then
                return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()
            end
        end
	end

	if (J.IsDefending(bot) or J.IsPushing(bot))
	then
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)
		local nLocationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), nCastRange, nRadius, 0, 0)
		local nTeamLaneFrontLoc = GetLaneFrontLocation(GetTeam(), bot:GetAssignedLane(), 0)
		local nEnemyLaneFrontLoc = GetLaneFrontLocation(GetOpposingTeam(), bot:GetAssignedLane(), 0)

		if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 5
		and nLocationAoE.count >= 5
		and J.GetLocationToLocationDistance(nTeamLaneFrontLoc, nEnemyLaneFrontLoc) < 150
		then
			return BOT_ACTION_DESIRE_MODERATE, nLocationAoE.targetloc
		end
	end

	if J.IsFarming(bot)
	then
		local nLocationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), nCastRange, nRadius, 0, 0)
		local nNeutralCreeps = bot:GetNearbyNeutralCreeps(600)
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(600, true)

		if J.IsAttacking(bot)
		and J.GetMP(bot) > 0.33
		then
			if nNeutralCreeps ~= nil
			and ((#nNeutralCreeps >= 3 and nLocationAoE.count >= 3)
				or (#nNeutralCreeps >= 2 and nLocationAoE.count >= 2 and nNeutralCreeps[1]:IsAncientCreep()))
			then
				return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
			end

			if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 4
			and nLocationAoE.count >= 4
			then
				return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
			end
		end
	end

	if J.IsLaning(bot)
	then
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(600, true)
		local nLocationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), nCastRange, nRadius, 0, 0)

		if J.IsAttacking(bot)
		and J.GetMP(bot) > 0.65
		then
			if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 4
			and nLocationAoE.count >= 4
			then
				return BOT_ACTION_DESIRE_HIGH, nLocationAoE.targetloc
			end
		end
	end

    if J.IsDoingRoshan(bot)
    then
        if J.IsRoshan(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, 500)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
        end
    end

    if J.IsDoingTormentor(bot)
    then
        if J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, 400)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
        end
    end

	return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderUnstableConcoction()
	if not UnstableConcoction:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE
	end

	local nCastRange = J.GetProperCastRange(false, bot, UnstableConcoction:GetCastRange())
	local nDamage = UnstableConcoction:GetSpecialValueInt('max_damage')

	local nEnemyHeroes = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)
	for _, enemyHero in pairs(nEnemyHeroes)
	do
		if J.IsValidHero(enemyHero)
		and J.CanCastOnNonMagicImmune(enemyHero)
		and J.IsInRange(bot, enemyHero, nCastRange - 200)
		and not J.IsSuspiciousIllusion(enemyHero)
		then
			if enemyHero:IsChanneling()
			then
				return BOT_ACTION_DESIRE_HIGH
			end

			if J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_PHYSICAL)
			and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
			and not enemyHero:HasModifier('modifier_abaddon_aphotic_shield')
			and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
			and not enemyHero:HasModifier('modifier_enigma_black_hole_pull')
			and not enemyHero:HasModifier('modifier_faceless_void_chronosphere_freeze')
			and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
			and not enemyHero:HasModifier('modifier_item_solar_crest_armor_addition')
			then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
		local nInRangeAlly = J.GetNearbyHeroes(bot,1000, false, BOT_MODE_NONE)
		local nInRangeEnemy = J.GetNearbyHeroes(bot,nCastRange - 175, true, BOT_MODE_NONE)

		for _, enemyHero in pairs(nInRangeEnemy)
		do
			if J.IsValidTarget(enemyHero)
			and J.CanCastOnNonMagicImmune(enemyHero)
			and not J.IsSuspiciousIllusion(enemyHero)
			and not J.IsDisabled(enemyHero)
			and not enemyHero:HasModifier('modifier_enigma_black_hole_pull')
			and not enemyHero:HasModifier('modifier_faceless_void_chronosphere_freeze')
			and not enemyHero:HasModifier('modifier_legion_commander_duel')
			and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
			then
				local nTargetInRangeAlly = J.GetNearbyHeroes(enemyHero, 1000, false, BOT_MODE_NONE)

				if nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
				and #nInRangeAlly >= #nTargetInRangeAlly
				then
					return BOT_ACTION_DESIRE_HIGH, enemyHero
				end
			end
		end
	end

	if J.IsRetreating(bot)
	then
		local nInRangeAlly = J.GetNearbyHeroes(bot,nCastRange + 175, false, BOT_MODE_NONE)
		local nInRangeEnemy = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)

		if nInRangeAlly ~= nil and nInRangeEnemy ~= nil
		and J.IsValidHero(nInRangeEnemy[1])
		and J.CanCastOnNonMagicImmune(nInRangeEnemy[1])
		and J.IsInRange(bot, nInRangeEnemy[1], nCastRange - 175)
		and J.IsRunning(nInRangeEnemy[1])
        and nInRangeEnemy[1]:IsFacingLocation(bot:GetLocation(), 30)
		and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
		and not J.IsDisabled(nInRangeEnemy[1])
		and not nInRangeEnemy[1]:HasModifier('modifier_enigma_black_hole_pull')
		and not nInRangeEnemy[1]:HasModifier('modifier_faceless_void_chronosphere_freeze')
		and not nInRangeEnemy[1]:HasModifier('modifier_necrolyte_reapers_scythe')
		then
			local nTargetInRangeAlly = J.GetNearbyHeroes(nInRangeEnemy[1], 800, false, BOT_MODE_NONE)

            if nTargetInRangeAlly ~= nil
            and ((#nTargetInRangeAlly > #nInRangeAlly)
                or (J.GetHP(bot) < 0.6 and bot:WasRecentlyDamagedByAnyHero(2.2)))
            then
                return BOT_ACTION_DESIRE_HIGH
            end
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderUnstableConcoctionThrow()
	if UnstableConcoctionThrow:IsHidden()
	or not UnstableConcoctionThrow:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE, nil
	end

	local nCastRange = J.GetProperCastRange(false, bot, UnstableConcoctionThrow:GetCastRange())
	local nDamage = UnstableConcoction:GetSpecialValueInt("max_damage")

	local nEnemyHeroes = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)
	for _, enemyHero in pairs(nEnemyHeroes)
	do
		if J.IsValidHero(enemyHero)
		and J.CanCastOnNonMagicImmune(enemyHero)
		and not J.IsSuspiciousIllusion(enemyHero)
		and DotaTime() >= ConcoctionThrowTime + offDuration
		then
			if enemyHero:IsChanneling()
			then
				return BOT_ACTION_DESIRE_HIGH, enemyHero
			end

			if J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_PHYSICAL)
			and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
			and not enemyHero:HasModifier('modifier_abaddon_aphotic_shield')
			and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
			and not enemyHero:HasModifier('modifier_enigma_black_hole_pull')
			and not enemyHero:HasModifier('modifier_faceless_void_chronosphere_freeze')
			and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
			and not enemyHero:HasModifier('modifier_item_solar_crest_armor_addition')
			then
				return BOT_ACTION_DESIRE_HIGH, enemyHero
			end
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
		local nInRangeAlly = J.GetNearbyHeroes(bot,1000, false, BOT_MODE_NONE)
		local nInRangeEnemy = J.GetNearbyHeroes(bot,nCastRange - 175, true, BOT_MODE_NONE)

		for _, enemyHero in pairs(nInRangeEnemy)
		do
			if J.IsValidTarget(enemyHero)
			and J.CanCastOnNonMagicImmune(enemyHero)
			and not J.IsSuspiciousIllusion(enemyHero)
			and not J.IsDisabled(enemyHero)
			and not enemyHero:HasModifier('modifier_enigma_black_hole_pull')
			and not enemyHero:HasModifier('modifier_faceless_void_chronosphere_freeze')
			and not enemyHero:HasModifier('modifier_legion_commander_duel')
			and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
			and DotaTime() >= ConcoctionThrowTime + offDuration
			then
				local nTargetInRangeAlly = J.GetNearbyHeroes(enemyHero, 1000, false, BOT_MODE_NONE)

				if nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
				and #nInRangeAlly >= #nTargetInRangeAlly
				then
					return BOT_ACTION_DESIRE_HIGH, enemyHero
				end
			end
		end
	end

	if J.IsRetreating(bot)
	then
		local nInRangeAlly = J.GetNearbyHeroes(bot,800, false, BOT_MODE_NONE)
		local nInRangeEnemy = J.GetNearbyHeroes(bot,1000, true, BOT_MODE_NONE)

		if nInRangeAlly ~= nil and nInRangeEnemy ~= nil
		and J.IsValidHero(nInRangeEnemy[1])
		and J.CanCastOnNonMagicImmune(nInRangeEnemy[1])
		and J.IsInRange(bot, nInRangeEnemy[1], nCastRange)
		and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
		and not nInRangeEnemy[1]:HasModifier('modifier_enigma_black_hole_pull')
		and not nInRangeEnemy[1]:HasModifier('modifier_faceless_void_chronosphere_freeze')
		and not nInRangeEnemy[1]:HasModifier('modifier_necrolyte_reapers_scythe')
		and DotaTime() >= ConcoctionThrowTime + defDuration
		then
			local nTargetInRangeAlly = J.GetNearbyHeroes(nInRangeEnemy[1], 800, false, BOT_MODE_NONE)

            if nTargetInRangeAlly ~= nil
            and ((#nTargetInRangeAlly > #nInRangeAlly)
                or (J.GetHP(bot) < 0.6 and bot:WasRecentlyDamagedByAnyHero(2.2)))
            then
                return BOT_ACTION_DESIRE_HIGH, nInRangeEnemy[1]
            end
		end
	end

	if nEnemyHeroes ~= nil and #nEnemyHeroes >= 1
	and DotaTime() >= ConcoctionThrowTime + defDuration
	then
		return BOT_ACTION_DESIRE_HIGH, nEnemyHeroes[1]
	end

	return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderChemicalRage()
	if not ChemicalRage:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE
	end

	if J.IsInTeamFight(bot, 1200)
	then
		local nRealInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), 700)
		if nRealInRangeEnemy ~= nil and #nRealInRangeEnemy >= 2
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
		local nInRangeAlly = J.GetNearbyHeroes(bot,1000, false, BOT_MODE_NONE)

		if J.IsValidTarget(botTarget)
		and J.IsInRange(bot, botTarget, 800)
		and not J.IsSuspiciousIllusion(botTarget)
		and not botTarget:HasModifier('modifier_enigma_black_hole_pull')
		and not botTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
		and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
		then
            local nTargetInRangeAlly = J.GetNearbyHeroes(botTarget, 1000, false, BOT_MODE_NONE)

            if nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
            and #nInRangeAlly >= #nTargetInRangeAlly
            then
                return BOT_ACTION_DESIRE_HIGH
            end
		end
	end

	if J.IsRetreating(bot)
	then
		local nInRangeAlly = J.GetNearbyHeroes(bot,800, false, BOT_MODE_NONE)
		local nInRangeEnemy = J.GetNearbyHeroes(bot,800, true, BOT_MODE_NONE)

		if nInRangeAlly ~= nil and nInRangeEnemy ~= nil
		and J.IsValidHero(nInRangeEnemy[1])
		and J.IsRunning(nInRangeEnemy[1])
        and nInRangeEnemy[1]:IsFacingLocation(bot:GetLocation(), 30)
		and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
		and not J.IsDisabled(nInRangeEnemy[1])
		and not nInRangeEnemy[1]:HasModifier('modifier_enigma_black_hole_pull')
		and not nInRangeEnemy[1]:HasModifier('modifier_faceless_void_chronosphere_freeze')
		and not nInRangeEnemy[1]:HasModifier('modifier_necrolyte_reapers_scythe')
		then
			local nTargetInRangeAlly = J.GetNearbyHeroes(nInRangeEnemy[1], 800, false, BOT_MODE_NONE)

            if nTargetInRangeAlly ~= nil
            and ((#nTargetInRangeAlly > #nInRangeAlly)
                or (J.GetHP(bot) < 0.35 and bot:WasRecentlyDamagedByAnyHero(1.5)))
            then
                return BOT_ACTION_DESIRE_HIGH
            end
		end
	end

	if J.IsFarming(bot)
	then
		if J.IsAttacking(bot)
		and J.IsValid(botTarget)
		and botTarget:IsCreep()
		and J.GetHP(bot) < 0.3
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	if J.IsDoingRoshan(bot)
    then
        if J.IsRoshan(botTarget)
        and J.IsInRange(bot, botTarget, 500)
        and J.IsAttacking(bot)
		and (J.IsModeTurbo() and DotaTime() < 15 * 60 or DotaTime() < 30 * 60)
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

    if J.IsDoingTormentor(bot)
    then
        if J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, 400)
        and J.IsAttacking(bot)
		and (J.IsModeTurbo() and DotaTime() < 16 * 60 or DotaTime() < 32 * 60)
        then
            return BOT_ACTION_DESIRE_HIGH
        end
    end

	return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderBerserkPotion()
	if not BerserkPotion:IsTrained()
	or not BerserkPotion:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE, nil
	end

	local nCastRange = J.GetProperCastRange(false, bot, BerserkPotion:GetCastRange())

	local nAllyHeroes = J.GetNearbyHeroes(bot,nCastRange, false, BOT_MODE_NONE)
	for _, allyHero in pairs(nAllyHeroes)
	do
		if J.IsValidHero(allyHero)
		and J.IsInRange(bot, allyHero, nCastRange)
		and not allyHero:HasModifier('modifier_legion_commander_press_the_attack')
		and not allyHero:HasModifier('modifier_item_satanic_unholy')
		and not allyHero:IsMagicImmune()
		and not allyHero:IsInvulnerable()
		and not allyHero:IsIllusion()
		and allyHero:CanBeSeen()
		then
			if J.IsDisabled(allyHero)
			then
				return BOT_ACTION_DESIRE_HIGH, allyHero
			end

			if J.IsRetreating(allyHero)
			and J.IsRunning(allyHero)
			and J.GetHP(allyHero) < 0.6
			and allyHero:WasRecentlyDamagedByAnyHero(2.5)
			and allyHero:IsFacingLocation(GetAncient(GetTeam()):GetLocation(), 45)
			then
				return BOT_ACTION_DESIRE_HIGH, allyHero
			end

			if J.IsGoingOnSomeone(allyHero)
			then
				local allyTarget = J.GetProperTarget(allyHero)

				if J.IsValidHero(allyTarget)
				and allyHero:IsFacingLocation( allyTarget:GetLocation(), 20)
				and J.IsInRange(allyHero, allyTarget, allyHero:GetAttackRange() + 100)
				then
					return BOT_ACTION_DESIRE_HIGH, allyHero
				end

				if J.GetHP(allyHero) < 0.33
				then
					return BOT_ACTION_DESIRE_HIGH, allyHero
				end
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE, nil
end

return X