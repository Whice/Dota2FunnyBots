local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

local tTalentTreeList = {
						['t25'] = {10, 0},
						['t20'] = {10, 0},
						['t15'] = {10, 0},
						['t10'] = {0, 10},
}

local tAllAbilityBuildList = {
						{1,2,1,3,1,6,2,2,2,1,6,3,3,3,6},--pos1
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local sRoleItemsBuyList = {}

sRoleItemsBuyList['pos_1'] = {
	"item_tango",
	"item_double_branches",
	"item_quelling_blade",

	"item_wraith_band",
	"item_magic_wand",
	"item_power_treads",
	"item_bfury",--
	"item_manta",--
	"item_butterfly",--
	"item_basher",
	"item_skadi",--
	"item_moon_shard",
	"item_disperser",--
	"item_abyssal_blade",--
	"item_ultimate_scepter_2",
	"item_aghanims_shard",
}

sRoleItemsBuyList['pos_2'] = sRoleItemsBuyList['pos_1']

sRoleItemsBuyList['pos_3'] = sRoleItemsBuyList['pos_1']

sRoleItemsBuyList['pos_4'] = sRoleItemsBuyList['pos_1']

sRoleItemsBuyList['pos_5'] = sRoleItemsBuyList['pos_1']


X['sBuyList'] = sRoleItemsBuyList[sRole]

X['sSellList'] = {
	'item_skadi',
	'item_magic_wand',
}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_antimage' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)

	if Minion.IsValidUnit( hMinionUnit )
	then
		if J.IsValidHero(hMinionUnit) and hMinionUnit:IsIllusion()
		then
			Minion.IllusionThink( hMinionUnit )
		end
	end

end

-- local ManaBreak 		= bot:GetAbilityByName('antimage_mana_break')
local Blink 			= bot:GetAbilityByName('antimage_blink')
local CounterSpell 		= bot:GetAbilityByName('antimage_counterspell')
local CounterSpellAlly 	= bot:GetAbilityByName('antimage_counterspell_ally')
local BlinkFragment		= bot:GetAbilityByName('antimage_mana_overload')
local ManaVoid 			= bot:GetAbilityByName('antimage_mana_void')

local BlinkDesire, BlinkLocation
local CounterSpellDesire
local CounterSpellAllyDesire, CounterSpellAllyTarget
local BlinkFragmentDesire, BlinkFragmentLocation
local ManaVoidDesire, ManaVoidTarget
local BlinkVoidDesire, BlinkVoidLocation, BlinkVoidTarget

local botTarget

function X.SkillsComplement()
	if J.CanNotUseAbility(bot) then return end

	botTarget = J.GetProperTarget(bot)

	BlinkVoidDesire, BlinkVoidLocation, BlinkVoidTarget = X.ConsiderBlinkVoid()
	if BlinkVoidDesire > 0
	then
		J.SetQueuePtToINT( bot, false )
		bot:ActionQueue_UseAbilityOnLocation(Blink, BlinkVoidLocation)
		bot:ActionQueue_Delay(0.1)
		bot:ActionQueue_UseAbilityOnEntity(ManaVoid, BlinkVoidTarget)
		return
	end

	CounterSpellDesire = X.ConsiderCounterSpell()
	if CounterSpellDesire > 0
	then
		J.SetQueuePtToINT(bot, false)
		bot:ActionQueue_UseAbility(CounterSpell)
		return
	end

	BlinkFragmentDesire, BlinkFragmentLocation = X.ConsiderBlinkFragment()
	if BlinkFragmentDesire > 0
	then
		bot:Action_UseAbilityOnLocation(BlinkFragment, BlinkFragmentLocation)
		return
	end

	BlinkDesire, BlinkLocation = X.ConsiderBlink()
	if BlinkDesire > 0
	then
		J.SetQueuePtToINT(bot, false)
		bot:ActionQueue_UseAbilityOnLocation(Blink, BlinkLocation)
		return
	end

	ManaVoidDesire, ManaVoidTarget = X.ConsiderManaVoid()
	if ManaVoidDesire > 0
	then
		J.SetQueuePtToINT(bot, false)
		bot:ActionQueue_UseAbilityOnEntity(ManaVoid, ManaVoidTarget)
		return
	end

	CounterSpellAllyDesire, CounterSpellAllyTarget = X.ConsiderCounterSpellAlly()
	if CounterSpellAllyDesire > 0
	then
		J.SetQueuePtToINT(bot, false)
		bot:ActionQueue_UseAbilityOnEntity(CounterSpellAlly, CounterSpellAllyTarget)
		return
	end
end

function X.ConsiderBlink()
	if not Blink:IsFullyCastable()
	or bot:IsRooted()
	or bot:HasModifier('modifier_bloodseeker_rupture')
	then return BOT_ACTION_DESIRE_NONE end

	local nCastRange = Blink:GetSpecialValueInt('AbilityCastRange') - 1
	local nCastPoint = Blink:GetCastPoint()
	local nAttackPoint = bot:GetAttackPoint()

	if J.IsStuck(bot)
	then
		local loc = J.GetEscapeLoc()
		return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, loc, nCastRange)
	end

	if (J.IsStunProjectileIncoming(bot, 600) or J.IsUnitTargetProjectileIncoming(bot, 400))
	and not CounterSpell:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, J.GetTeamFountain(), nCastRange)
    end

	if not bot:HasModifier('modifier_sniper_assassinate')
	and not bot:IsMagicImmune()
	and not CounterSpell:IsFullyCastable()
	then
		if J.IsWillBeCastUnitTargetSpell(bot, 400)
		then
			return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, J.GetTeamFountain(), nCastRange)
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidTarget(botTarget)
		and J.CanCastOnMagicImmune(botTarget)
		and not J.IsInRange(bot, botTarget, 400)
		and not botTarget:IsAttackImmune()
		and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
		and not botTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
		and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
		then
			local nInRangeAlly = J.GetNearbyHeroes(botTarget, 1200, true, BOT_MODE_NONE)
			local nInRangeEnemy = J.GetNearbyHeroes(botTarget, 1200, false, BOT_MODE_NONE)

			if nInRangeAlly ~= nil and nInRangeEnemy ~= nil
			and #nInRangeAlly >= #nInRangeEnemy
			then
				local targetLoc = botTarget:GetExtrapolatedLocation(nCastPoint + 0.53)

				if GetUnitToUnitDistance(bot, botTarget) > nCastRange
				then
					targetLoc = J.Site.GetXUnitsTowardsLocation(bot, botTarget:GetLocation(), nCastRange)
				end

				if J.IsInLaningPhase()
				then
					local nEnemysTowers = botTarget:GetNearbyTowers(700, false)
					if nEnemysTowers ~= nil and #nEnemysTowers == 0
					or (bot:GetHealth() > J.GetTotalEstimatedDamageToTarget(nInRangeEnemy, bot)
						and J.WillKillTarget(botTarget, bot:GetAttackDamage() * 3, DAMAGE_TYPE_PHYSICAL, 2))
					then
						bot:SetTarget(botTarget)
						return BOT_ACTION_DESIRE_HIGH, targetLoc
					end
				else
					bot:SetTarget(botTarget)
					return BOT_ACTION_DESIRE_HIGH, targetLoc
				end
			end
		end
	end

	if J.IsRetreating(bot)
	then
        local nInRangeEnemy = J.GetNearbyHeroes(bot,1200, true, BOT_MODE_NONE)
		for _, enemyHero in pairs(nInRangeEnemy)
        do
			if J.IsValidHero(enemyHero)
			and bot:DistanceFromFountain() > 600
			and not J.IsSuspiciousIllusion(enemyHero)
			and not J.IsDisabled(enemyHero)
			and not J.IsRealInvisible(bot)
			then
				local nInRangeAlly = J.GetNearbyHeroes(enemyHero, 1200, true, BOT_MODE_NONE)
				local nTargetInRangeAlly = J.GetNearbyHeroes(enemyHero, 1200, false, BOT_MODE_NONE)

				if nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
				and ((#nTargetInRangeAlly > #nInRangeAlly)
					or bot:WasRecentlyDamagedByAnyHero(2)
					or (J.GetHP(bot) < 0.2 and J.IsChasingTarget(enemyHero, bot)))
				then
					return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, J.GetTeamFountain(), nCastRange)
				end
			end
        end
	end

	if J.IsLaning(bot)
	then
		-- local nLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange + 80, true)
		-- for _, creep in pairs( nLaneCreeps )
		-- do
		-- 	if J.IsValid(creep)
		-- 	and J.CanBeAttacked(creep)
		-- 	and (J.IsKeyWordUnit('ranged', creep) or J.IsKeyWordUnit('siege', creep) or J.IsKeyWordUnit('flagbearer', creep))
		-- 	and GetUnitToUnitDistance(bot, creep) > 500
		-- 	then
		-- 		local nCreepInRangeHero = creep:GetNearbyHeroes(creep:GetCurrentVisionRange(), false, BOT_MODE_NONE)
		-- 		local nCreepInRangeTower = creep:GetNearbyTowers(700, false)
		-- 		local nDamage = bot:GetAttackDamage()

		-- 		if J.WillKillTarget(creep, nDamage, DAMAGE_TYPE_PHYSICAL, nCastPoint + nAttackPoint + 0.53)
		-- 		and nCreepInRangeHero ~= nil and #nCreepInRangeHero == 0
		-- 		and nCreepInRangeTower ~= nil and #nCreepInRangeTower == 0
		-- 		and botTarget ~= creep
		-- 		then
		-- 			bot:SetTarget(creep)
		-- 			return BOT_ACTION_DESIRE_HIGH, creep:GetLocation()
		-- 		end
		-- 	end
		-- end

		local nInRangeEnemy = J.GetNearbyHeroes(bot,1600, true, BOT_MODE_NONE)
		local nInRangeTower = bot:GetNearbyTowers(1600, true)
		if J.GetManaAfter(Blink:GetManaCost()) > 0.85
		and J.IsInLaningPhase()
		and bot:DistanceFromFountain() > 300
		and bot:DistanceFromFountain() < 6000
		and nInRangeEnemy ~= nil and #nInRangeEnemy == 0
		and nInRangeTower ~= nil and #nInRangeTower == 0
		then
			local nLane = bot:GetAssignedLane()
			local nLaneFrontLocation = GetLaneFrontLocation(GetTeam(), nLane, 0)
			local nDistFromLane = GetUnitToLocationDistance(bot, nLaneFrontLocation)

			if nDistFromLane > nCastRange
			then
				local nLocation = J.Site.GetXUnitsTowardsLocation(bot, nLaneFrontLocation, nCastRange)
				if IsLocationPassable(nLocation)
				then
					return BOT_ACTION_DESIRE_HIGH, nLocation
				end
			end
		end
	end

	if J.IsPushing(bot)
	and bot:GetActiveModeDesire() > BOT_MODE_DESIRE_HIGH
	then
        local nInRangeAlly = J.GetAlliesNearLoc(bot:GetLocation(), 600)
        local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), 1200)
		local nEnemyTowers = bot:GetNearbyTowers(700, true)
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(1200, true)

		if nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 3
        and nInRangeEnemy ~= nil and #nInRangeEnemy == 0
        and nInRangeAlly ~= nil and #nInRangeAlly <= 1
		and GetUnitToLocationDistance(bot, J.GetCenterOfUnits(nEnemyLaneCreeps)) > bot:GetAttackRange()
        and J.CanBeAttacked(nEnemyLaneCreeps[1])
		then
            local nEnemyTowers2 = nEnemyLaneCreeps[#nEnemyLaneCreeps]:GetNearbyTowers(700, false)
            if nEnemyTowers2 ~= nil and #nEnemyTowers2 == 0
            then
                return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nEnemyLaneCreeps)
            end
		end

        -- nInRangeEnemy = J.GetNearbyHeroes(bot,1600, true, BOT_MODE_NONE)
		-- if bot.laneToPush ~= nil
		-- then
		-- 	if J.GetManaAfter(Blink:GetManaCost()) * bot:GetMana() > ManaVoid:GetManaCost() * 2
		-- 	and nInRangeEnemy ~= nil and #nInRangeEnemy == 0
		-- 	and nEnemyTowers ~= nil and #nEnemyTowers == 0
		-- 	and GetUnitToLocationDistance(bot, GetLaneFrontLocation(GetTeam(), bot.laneToPush, 0)) > nCastRange
		-- 	and bot:IsFacingLocation(GetLaneFrontLocation(GetTeam(), bot.laneToPush, 0), 30)
		-- 	then
		-- 		return  BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, GetLaneFrontLocation(GetTeam(), bot.laneToPush, 0), nCastRange)
		-- 	end
		-- end
	end

	-- if J.IsDefending(bot)
	-- and bot:GetActiveModeDesire() > BOT_MODE_DESIRE_HIGH
	-- then
    --     local nInRangeEnemy = J.GetNearbyHeroes(bot,1600, true, BOT_MODE_NONE)
	-- 	if bot.laneToDefend ~= nil
	-- 	then
	-- 		if J.GetManaAfter(Blink:GetManaCost()) * bot:GetMana() > ManaVoid:GetManaCost() * 2
	-- 		and nInRangeEnemy ~= nil and #nInRangeEnemy == 0
	-- 		and GetUnitToLocationDistance(bot, GetLaneFrontLocation(GetTeam(), bot.laneToDefend, 0)) > nCastRange
	-- 		and bot:IsFacingLocation(GetLaneFrontLocation(GetTeam(), bot.laneToDefend, 0), 30)
	-- 		then
	-- 			return  BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, GetLaneFrontLocation(GetTeam(), bot.laneToDefend, 0), nCastRange)
	-- 		end
	-- 	end
	-- end

	if J.IsDoingRoshan(bot)
    then
		local RoshanLocation = J.GetCurrentRoshanLocation()
        if GetUnitToLocationDistance(bot, RoshanLocation) > nCastRange
        then
			local targetLoc = J.Site.GetXUnitsTowardsLocation(bot, RoshanLocation, nCastRange)
			local nInRangeEnemy = J.GetEnemiesNearLoc(RoshanLocation, 1600)

			if nInRangeEnemy ~= nil and #nInRangeEnemy == 0
			and IsLocationPassable(targetLoc)
			then
				return BOT_ACTION_DESIRE_HIGH, targetLoc
			end
        end
    end

    if J.IsDoingTormentor(bot)
    then
		local TormentorLocation = J.GetTormentorLocation(GetTeam())
        if GetUnitToLocationDistance(bot, TormentorLocation) > nCastRange
        then
			local targetLoc = J.Site.GetXUnitsTowardsLocation(bot, TormentorLocation, nCastRange)
			local nInRangeEnemy = J.GetEnemiesNearLoc(targetLoc, 1600)

			if nInRangeEnemy ~= nil and #nInRangeEnemy == 0
			and IsLocationPassable(targetLoc)
			then
				return BOT_ACTION_DESIRE_HIGH, targetLoc
			end

        end
    end

	return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderCounterSpell()
	if not CounterSpell:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE
	end

	if J.IsUnitTargetProjectileIncoming(bot, 400)
	then
		return BOT_ACTION_DESIRE_HIGH
	end

	if not bot:HasModifier('modifier_sniper_assassinate')
	and not bot:IsMagicImmune()
	then
		if J.IsWillBeCastUnitTargetSpell(bot, 1400)
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderManaVoid()
	if not ManaVoid:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE
	end

	local nCastRange = ManaVoid:GetCastRange()
	local nRadius = ManaVoid:GetSpecialValueInt('mana_void_aoe_radius')
	local nDamagaPerHealth = ManaVoid:GetSpecialValueFloat('mana_void_damage_per_mana')

	if J.IsInTeamFight(bot, 1200)
	then
		local nCastTarget = nil
		local nInRangeEnemy = J.GetNearbyHeroes(bot,nCastRange + 200, true, BOT_MODE_NONE)
		for _, enemyHero in pairs(nInRangeEnemy)
		do
			local nDamage = nDamagaPerHealth * (enemyHero:GetMaxMana() - enemyHero:GetMana())
			if J.IsValidHero(enemyHero)
				and J.CanCastOnTargetAdvanced(enemyHero)
				and J.CanCastOnNonMagicImmune(enemyHero)
				and J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
				and not J.IsHaveAegis(enemyHero)
				and not J.IsSuspiciousIllusion(enemyHero)
				and not enemyHero:HasModifier('modifier_arc_warden_tempest_double')
				and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
				and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
				and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
			then
				nCastTarget = enemyHero
				break
				-- if J.IsCore(enemyHero)
				-- then
				-- 	nCastTarget = enemyHero
				-- 	break
				-- else
				-- 	nCastTarget = enemyHero
				-- end
			end
		end

		if nCastTarget ~= nil
		then
			bot:SetTarget(nCastTarget)
			return BOT_ACTION_DESIRE_HIGH, nCastTarget
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidHero(botTarget)
		and J.IsInRange(bot, botTarget, nCastRange)
		and J.CanCastOnNonMagicImmune(botTarget)
		and J.CanCastOnTargetAdvanced(botTarget)
		and not J.IsHaveAegis(botTarget)
		and not J.IsSuspiciousIllusion(botTarget)
		and not botTarget:HasModifier('modifier_arc_warden_tempest_double')
		and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
		and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
		and not botTarget:HasModifier('modifier_oracle_false_promise_timer')
		then
			local nInRangeAlly = J.GetNearbyHeroes(botTarget, 1200, true, BOT_MODE_NONE)
			local nTargetInRangeAlly = J.GetNearbyHeroes(botTarget, 1200, false, BOT_MODE_NONE)
			local nDamage = nDamagaPerHealth * (botTarget:GetMaxMana() - botTarget:GetMana())

			if nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
			and #nInRangeAlly >= #nTargetInRangeAlly
			then
				if J.CanKillTarget(botTarget, nDamage, DAMAGE_TYPE_MAGICAL)
				then
					return BOT_ACTION_DESIRE_HIGH, botTarget
				end
			end
		end
	end

	return 0
end

function X.ConsiderCounterSpellAlly()
	if not CounterSpellAlly:IsTrained()
	or not CounterSpellAlly:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE, nil
	end

	local nCastRange = CounterSpellAlly:GetCastRange()
	local nInRangeAlly = J.GetNearbyHeroes(bot,nCastRange, false, BOT_MODE_NONE)

	for _, allyHero in pairs(nInRangeAlly)
	do
		if J.IsValidHero(allyHero)
		and not J.IsSuspiciousIllusion(allyHero)
		and not allyHero:HasModifier('modifier_necrolyte_reapers_scythe')
		then
			if J.IsUnitTargetProjectileIncoming(allyHero, 400)
			and not allyHero:IsMagicImmune()
			then
				return BOT_ACTION_DESIRE_HIGH, allyHero
			end

			if not allyHero:HasModifier('modifier_sniper_assassinate')
			and not allyHero:IsMagicImmune()
			then
				if J.IsWillBeCastUnitTargetSpell(allyHero, nCastRange)
				then
					return BOT_ACTION_DESIRE_HIGH, allyHero
				end
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE, nil
end

function X.ConsiderBlinkFragment()
	if not bot:HasScepter()
	or not BlinkFragment
	or not BlinkFragment:IsTrained()
	or not BlinkFragment:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE, 0
	end

	local nCastRange = BlinkFragment:GetCastRange()

	if J.IsGoingOnSomeone(bot)
	then
		local target = nil
		local hp = 99999
		local nInRangeEnemy = J.GetEnemiesNearLoc(bot:GetLocation(), nCastRange)
		for _, enemyHero in pairs(nInRangeEnemy)
		do
			if J.IsValidTarget(enemyHero)
			and J.CanCastOnMagicImmune(enemyHero)
			and not J.IsInRange(bot, enemyHero, nCastRange / 2)
			and not enemyHero:IsAttackImmune()
			and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
			and not enemyHero:HasModifier('modifier_faceless_void_chronosphere_freeze')
			and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
			then
				local nInRangeAlly = J.GetNearbyHeroes(enemyHero, 1200, true, BOT_MODE_NONE)
				local nTargetInRangeAlly = J.GetNearbyHeroes(enemyHero, 1200, false, BOT_MODE_NONE)

				if nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
				and #nInRangeAlly >= #nTargetInRangeAlly
				and hp < enemyHero:GetHealth()
				then
					hp = enemyHero:GetHealth()
					target = enemyHero
				end
			end
		end

		if target ~= nil
		then
			return BOT_ACTION_DESIRE_HIGH, target:GetLocation()
		end
	end

	if J.IsRetreating(bot)
	then
        local nInRangeEnemy = J.GetNearbyHeroes(bot,1200, true, BOT_MODE_NONE)
		for _, enemyHero in pairs(nInRangeEnemy)
        do
			if J.IsValidHero(enemyHero)
			and J.IsChasingTarget(enemyHero, bot)
			and not J.IsSuspiciousIllusion(enemyHero)
			and not J.IsDisabled(enemyHero)
			and not J.IsRealInvisible(bot)
			then
				local nInRangeAlly = J.GetNearbyHeroes(enemyHero, 1200, true, BOT_MODE_NONE)
				local nTargetInRangeAlly = J.GetNearbyHeroes(enemyHero, 1200, false, BOT_MODE_NONE)

				if nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
				and ((#nTargetInRangeAlly > #nInRangeAlly)
					or bot:WasRecentlyDamagedByAnyHero(1.2))
				then
					return BOT_ACTION_DESIRE_HIGH, enemyHero:GetLocation()
				end
			end
        end
	end

	return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderBlinkVoid()
	if not Blink:IsFullyCastable()
	or not ManaVoid:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE, 0, nil
	end

	if Blink:GetManaCost() + ManaVoid:GetManaCost() > bot:GetMana()
	then
		return BOT_ACTION_DESIRE_NONE, 0, nil
	end

	local nCastRange = Blink:GetSpecialValueInt('AbilityCastRange')
	local nDamagaPerHealth = ManaVoid:GetSpecialValueFloat('mana_void_damage_per_mana')
	local nCastTarget = nil

	local nMaxRange = ManaVoid:GetCastRange() + nCastRange

	local nEnemysHerosCanSeen = GetUnitList(UNIT_LIST_ENEMY_HEROES)
	for _, enemyHero in pairs(nEnemysHerosCanSeen)
	do
		if J.IsValidHero(enemyHero)
		and J.IsInRange(bot, enemyHero, nMaxRange)
		and J.CanCastOnTargetAdvanced(enemyHero)
		and J.CanCastOnNonMagicImmune(enemyHero)
		and not J.IsSuspiciousIllusion(enemyHero)
		and not enemyHero:HasModifier('modifier_arc_warden_tempest_double')
		and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
		and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
		and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
		then
			local nInRangeAlly = J.GetNearbyHeroes(enemyHero, 1600, true, BOT_MODE_NONE)
			local nInRangeEnemy = J.GetNearbyHeroes(enemyHero, 1600, false, BOT_MODE_NONE)
			local nDamage = nDamagaPerHealth * (enemyHero:GetMaxMana() - enemyHero:GetMana())

			if nInRangeAlly ~= nil and nInRangeEnemy ~= nil
			and #nInRangeAlly >= #nInRangeEnemy
			then
				if J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
				then
					nCastTarget = enemyHero
				end
			end
		end
	end

	if nCastTarget ~= nil
	then
		return BOT_ACTION_DESIRE_HIGH, nCastTarget:GetLocation(), nCastTarget
	end

	return BOT_ACTION_DESIRE_NONE, 0, nil
end

return X