----------------------------------------------------------------------------------------------------
--- The Creation Come From: BOT EXPERIMENT Credit:FURIOUSPUPPY
--- BOT EXPERIMENT Author: Arizona Fauzie 2018.11.21
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=837040016
--- Refactor: 决明子 Email: dota2jmz@163.com 微博@Dota2_决明子
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1573671599
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1627071163
----------------------------------------------------------------------------------------------------
local X = {}
local bDebugMode = ( 1 == 10 )
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

local tTalentTreeList = {
						['t25'] = {10, 0},
						['t20'] = {0, 10},
						['t15'] = {0, 10},
						['t10'] = {10, 0},
}

local tAllAbilityBuildList = {
						{2,3,2,1,2,1,2,6,1,1,3,3,3,6,6},--pos1
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )


local sRoleItemsBuyList = {}

sRoleItemsBuyList['pos_1'] = {
	'item_tango',
	'item_double_branches',
	'item_null_talisman',
	'item_null_talisman',
	"item_magic_wand",

	"item_ring_of_basilius",
	"item_power_treads",
	"item_manta",--
	"item_ultimate_scepter",
	"item_skadi",--
    "item_force_staff",
	"item_hurricane_pike",--
	"item_butterfly",--
	"item_greater_crit",--
	"item_travel_boots",
	"item_aghanims_shard",
	"item_disperser",--
	"item_moon_shard",
	"item_ultimate_scepter_2",
}

sRoleItemsBuyList['pos_2'] = {
	"item_medusa_outfit",
	"item_ultimate_scepter",
	"item_aghanims_shard",
	"item_dragon_lance",
	"item_manta",--
	"item_mjollnir",--
    "item_force_staff",
	"item_hurricane_pike", --
	"item_travel_boots",
	"item_skadi",--
--	"item_sphere",	
	"item_ultimate_scepter_2",
	"item_moon_shard",
	"item_butterfly",--
	"item_travel_boots_2",--
	
}

sRoleItemsBuyList['pos_4'] = sRoleItemsBuyList['pos_2']

sRoleItemsBuyList['pos_5'] = sRoleItemsBuyList['pos_2']

sRoleItemsBuyList['pos_3'] = sRoleItemsBuyList['pos_2']

X['sBuyList'] = sRoleItemsBuyList[sRole]

X['sSellList'] = {

	"item_black_king_bar",
	"item_quelling_blade",
}

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_mid' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )


X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false


function X.MinionThink(hMinionUnit)

	if Minion.IsValidUnit( hMinionUnit )
	then
		Minion.IllusionThink( hMinionUnit )
	end

end

--[[

npc_dota_hero_medusa

"Ability1"		"medusa_split_shot"
"Ability2"		"medusa_mystic_snake"
"Ability3"		"medusa_mana_shield"
"Ability4"		"generic_hidden"
"Ability5"		"generic_hidden"
"Ability6"		"medusa_stone_gaze"
"Ability10"		"special_bonus_attack_damage_15"
"Ability11"		"special_bonus_evasion_15"
"Ability12"		"special_bonus_attack_speed_30"
"Ability13"		"special_bonus_unique_medusa_3"
"Ability14"		"special_bonus_unique_medusa_5"
"Ability15"		"special_bonus_unique_medusa"
"Ability16"		"special_bonus_mp_1000"
"Ability17"		"special_bonus_unique_medusa_4"

modifier_medusa_split_shot
modifier_medusa_mana_shield
modifier_medusa_stone_gaze_tracker
modifier_medusa_stone_gaze
modifier_medusa_stone_gaze_slow
modifier_medusa_stone_gaze_facing
modifier_medusa_stone_gaze_stone


--]]

local abilityQ = bot:GetAbilityByName( sAbilityList[1] )
local abilityW = bot:GetAbilityByName( sAbilityList[2] )
local abilityE = bot:GetAbilityByName( sAbilityList[3] )
local abilityR = bot:GetAbilityByName( sAbilityList[6] )
local abilityM = nil
local GorgonGrasp = bot:GetAbilityByName('medusa_gorgon_grasp')

local castQDesire
local castWDesire, castWTarget
local castEDesire
local castRDesire
local GorgonGraspDesire, GorgonGraspLocation

local nKeepMana, nMP, nHP, nLV, hEnemyHeroList
local lastToggleTime = 0


function X.SkillsComplement()

	J.ConsiderForMkbDisassembleMask( bot )
	J.ConsiderTarget()

	if J.CanNotUseAbility( bot ) or bot:IsInvisible() then return end

	nKeepMana = 400
	nLV = bot:GetLevel()
	nMP = bot:GetMana()/bot:GetMaxMana()
	nHP = bot:GetHealth()/bot:GetMaxHealth()
	hEnemyHeroList = J.GetNearbyHeroes(bot, 1600, true, BOT_MODE_NONE )


	castWDesire, castWTarget = X.ConsiderW()
	if castWDesire > 0
	then

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbilityOnEntity( abilityW, castWTarget )
		return
	end


	castRDesire = X.ConsiderR()
	if castRDesire > 0 
	then

		J.SetQueuePtToINT( bot, true )

		bot:ActionQueue_UseAbility( abilityR )
		return

	end
	
	GorgonGraspDesire, GorgonGraspLocation = X.ConsiderGorgonGrasp()
	if GorgonGraspDesire > 0
	then
		J.SetQueuePtToINT(bot, false)
		bot:ActionQueue_UseAbilityOnLocation(GorgonGrasp, GorgonGraspLocation)
		return
	end

	castQDesire = X.ConsiderQ()
	if castQDesire > 0
	then
		bot:Action_UseAbility( abilityQ )
		return
	end

end

function X.ConsiderGorgonGrasp()
	if not GorgonGrasp:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE, 0
	end

	local nCastRange = J.GetProperCastRange(false, bot, GorgonGrasp:GetCastRange())
	local nCastPoint = GorgonGrasp:GetCastPoint()
	-- local nRadius = GorgonGrasp:GetSpecialValueInt('radius')
	-- local nRadiusGrow = GorgonGrasp:GetSpecialValueInt('radius_grow')
	local nDelay = GorgonGrasp:GetSpecialValueInt('delay')
	-- local nVolleyInterval = GorgonGrasp:GetSpecialValueInt('volley_interval')
	local nDamage = GorgonGrasp:GetSpecialValueInt('damage')
	local nDPS = GorgonGrasp:GetSpecialValueInt('damage_pers')
	local nDuration = GorgonGrasp:GetSpecialValueInt('duration')
	local botTarget = J.GetProperTarget(bot)

	local tAllyHeroes = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
	local tEnemyHeroes = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)

	local eta = nCastPoint + nDelay

	for _, enemyHero in pairs(tEnemyHeroes)
	do
		if J.IsValidHero(enemyHero)
		and J.IsInRange(bot, enemyHero, nCastRange)
		and J.CanCastOnNonMagicImmune(enemyHero)
		then
			if enemyHero:IsChanneling()
			then
				return BOT_ACTION_DESIRE_HIGH, enemyHero:GetLocation()
			end

			if J.CanKillTarget(enemyHero, nDamage + nDPS * nDuration, DAMAGE_TYPE_PHYSICAL)
			and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
			and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
			and not enemyHero:HasModifier('modifier_enigma_black_hole_pull')
			and not enemyHero:HasModifier('modifier_faceless_void_chronosphere_freeze')
			and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
			then
				return BOT_ACTION_DESIRE_HIGH, J.GetCorrectLoc(enemyHero, eta)
			end
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidHero(botTarget)
		and J.CanCastOnNonMagicImmune(botTarget)
		and J.IsInRange(bot, botTarget, nCastRange)
		and not J.IsDisabled(botTarget)
		and not botTarget:HasModifier('modifier_enigma_black_hole_pull')
		and not botTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
		and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
		then
			return BOT_ACTION_DESIRE_HIGH, J.GetCorrectLoc(botTarget, eta)
		end
	end

	if J.IsRetreating(bot)
	and not J.IsRealInvisible(bot)
	then
		for _, enemyHero in pairs(tEnemyHeroes)
		do
			if J.IsValidHero(enemyHero)
			and J.IsInRange(bot, enemyHero, nCastRange)
			and bot:WasRecentlyDamagedByHero(enemyHero, 2.5)
			and (J.IsChasingTarget(enemyHero, bot) or J.GetHP(bot) < 0.5)
			and J.CanCastOnNonMagicImmune(enemyHero)
			and not J.IsDisabled(enemyHero)
			and not enemyHero:HasModifier('modifier_enigma_black_hole_pull')
			and not enemyHero:HasModifier('modifier_faceless_void_chronosphere_freeze')
			and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
			then
				return BOT_ACTION_DESIRE_HIGH, (bot:GetLocation() + enemyHero:GetLocation()) / 2
			end
		end
	end

	for _, allyHero in pairs(tAllyHeroes)
    do
        if J.IsValidHero(allyHero)
        and J.IsRetreating(allyHero)
        and allyHero:GetActiveModeDesire() >= 0.7
        and allyHero:WasRecentlyDamagedByAnyHero(3)
        and not allyHero:IsIllusion()
        then
            local nAllyInRangeEnemy = allyHero:GetNearbyHeroes(1600, true, BOT_MODE_NONE)

            if J.IsValidHero(nAllyInRangeEnemy[1])
            and J.CanCastOnNonMagicImmune(nAllyInRangeEnemy[1])
            and J.IsInRange(bot, nAllyInRangeEnemy[1], nCastRange)
            and J.IsChasingTarget(nAllyInRangeEnemy[1], allyHero)
            and not J.IsDisabled(nAllyInRangeEnemy[1])
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_enigma_black_hole_pull')
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_faceless_void_chronosphere_freeze')
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_necrolyte_reapers_scythe')
            then
                return BOT_ACTION_DESIRE_HIGH, J.GetCorrectLoc(nAllyInRangeEnemy[1], eta)
            end
        end
    end

	return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderQ()

	if not abilityQ:IsFullyCastable() then return 0 end

	local nCastRange = bot:GetAttackRange() + 150
	local nSkillLv = abilityQ:GetLevel()
	
	local nInRangeEnemyHeroList = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)
	local nInRangeEnemyCreepList = bot:GetNearbyCreeps(nCastRange, true)
	local nInRangeEnemyLaneCreepList = bot:GetNearbyLaneCreeps(nCastRange, true)
	local nAllyLaneCreepList = bot:GetNearbyLaneCreeps(800, false)
	local botTarget = J.GetProperTarget(bot)
	
	--关闭分裂的情况
	if J.IsLaning( bot )
		or ( #nInRangeEnemyHeroList == 1 )
		or ( J.IsGoingOnSomeone(bot) and J.IsValidHero(botTarget) and nSkillLv <= 2 and #nInRangeEnemyHeroList == 2 )
		or ( #nInRangeEnemyHeroList == 0 and #nInRangeEnemyCreepList <= 1 )
		or ( #nInRangeEnemyHeroList == 0 and #nInRangeEnemyLaneCreepList >= 2 and #nAllyLaneCreepList >= 1 and nSkillLv <= 3 )
	then
		if abilityQ:GetToggleState()
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	else
		if not abilityQ:GetToggleState()
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	

	return BOT_ACTION_DESIRE_NONE
		
end


function X.ConsiderE()

	if not abilityE:IsFullyCastable() then return 0 end

	if nHP > 0.8 and nMP < 0.88 and nLV < 15
	  and J.GetEnemyCount( bot, 1600 ) <= 1
	  and lastToggleTime + 3.0 < DotaTime()
	then
		if abilityE:GetToggleState()
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	else
		if not abilityE:GetToggleState()
		then
			lastToggleTime = DotaTime()
			return BOT_ACTION_DESIRE_HIGH
		end
	end

	return BOT_ACTION_DESIRE_NONE


end

-- Calculate the best target for Mystic Snake
local function GetBestSnakeTarget(nCastRange, nSnakeJumpRadius, nSnakeJumps)
	local bestTarget = nil
	local possibleTargets = 0
	local nSnakeSearchRange = nSnakeJumpRadius * 1.2

	local tableNearbyEnemyCreeps = bot:GetNearbyCreeps(nCastRange + nSnakeSearchRange, true)
	if #tableNearbyEnemyCreeps < nSnakeJumps then
		local creep = tableNearbyEnemyCreeps[1]
		if J.IsValid(creep) then
			-- Check if the creep is a valid starting target and maximize hero jumps
			local nEnemies = #J.GetEnemiesNearLoc(creep:GetLocation(), nSnakeSearchRange)
			if nEnemies >= 1 then
				bestTarget = creep
				possibleTargets = math.min(#tableNearbyEnemyCreeps + nEnemies, nSnakeJumps)
			end
		end
	elseif #tableNearbyEnemyCreeps >= nSnakeJumps then
		if (J.IsFarming(bot) or J.IsPushing(bot)) and J.IsValid(tableNearbyEnemyCreeps[1]) then
			return tableNearbyEnemyCreeps[1], #tableNearbyEnemyCreeps
		end
	end

	return bestTarget, possibleTargets
end

function X.ConsiderW()

	if not abilityW:IsFullyCastable() then return 0 end

	local nCastRange = abilityW:GetCastRange() + 20
	local nSnakeJumps = abilityW:GetSpecialValueInt( 'snake_jumps' )
	local nSnakeDamage = abilityW:GetSpecialValueInt( 'snake_damage' )
	local nSnakeJumpRadius = abilityW:GetSpecialValueInt( 'radius' )
	local nSkillLv = abilityW:GetLevel()

	if J.IsRetreating( bot )
	then
		local tableNearbyEnemyHeroes = J.GetNearbyHeroes(bot, nCastRange - 200, true, BOT_MODE_NONE )
		for _, npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if J.IsValidHero( npcEnemy )
				and bot:WasRecentlyDamagedByHero( npcEnemy, 3.0 )
				and J.CanCastOnTargetAdvanced( npcEnemy )
				and J.CanCastOnNonMagicImmune( npcEnemy )
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy
			end
		end
	end

	if J.IsInTeamFight( bot, 1200 )
	then

		local npcMaxManaEnemy = nil
		local nEnemyMaxMana = 0

		local tableNearbyEnemyHeroes = J.GetNearbyHeroes(bot, nCastRange + 50, true, BOT_MODE_NONE )
		for _, npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if J.IsValidHero( npcEnemy )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and J.CanCastOnTargetAdvanced( npcEnemy )
			then
				local nMaxMana = npcEnemy:GetMaxMana()
				if ( nMaxMana > nEnemyMaxMana )
				then
					nEnemyMaxMana = nMaxMana
					npcMaxManaEnemy = npcEnemy
				end
			end
		end

		if ( npcMaxManaEnemy ~= nil )
		then
			return BOT_ACTION_DESIRE_HIGH, npcMaxManaEnemy
		end

	end

	if J.IsGoingOnSomeone( bot )
	then
		local npcTarget = J.GetProperTarget( bot )
		if J.IsValidHero( npcTarget )
			and J.CanCastOnNonMagicImmune( npcTarget )
			and J.CanCastOnTargetAdvanced( npcTarget )
		then
			local snakeTarget, possibleTargets = GetBestSnakeTarget(nCastRange, nSnakeJumpRadius, nSnakeJumps)
			if snakeTarget
			and J.IsInRange( snakeTarget, bot, nCastRange + 50 ) then
				return BOT_ACTION_DESIRE_HIGH, snakeTarget
			end
			if J.IsInRange( npcTarget, bot, nCastRange + 50 ) then
				return BOT_ACTION_DESIRE_HIGH, snakeTarget
			end
		end
	end

	local snakeTarget, possibleTargets = GetBestSnakeTarget(nCastRange, nSnakeJumpRadius, nSnakeJumps)
	if snakeTarget
	and J.IsInRange( snakeTarget, bot, nCastRange + 50 ) then
		return BOT_ACTION_DESIRE_HIGH, snakeTarget
	end


	if nSkillLv >= 3 then
		local nAoe = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange * 2, nSnakeJumpRadius * 1.2, 0, 0 )
		local nShouldAoeCount = 5
		local nCreeps = bot:GetNearbyCreeps( nCastRange, true )
		local nLaneCreeps = bot:GetNearbyLaneCreeps( 1600, true )

		if nSkillLv == 4 then nShouldAoeCount = 4 end
		if bot:GetLevel() >= 20 or J.GetMP( bot ) > 0.88 then nShouldAoeCount = 3 end

		if nAoe.count >= nShouldAoeCount
		then
			if J.IsValid( nCreeps[1] )
				and J.CanCastOnNonMagicImmune( nCreeps[1] )
				and not ( nCreeps[1]:GetTeam() == TEAM_NEUTRAL and #nLaneCreeps >= 1 )
				and J.GetAroundTargetEnemyUnitCount( nCreeps[1], 470 ) >= 2
			then
				return BOT_ACTION_DESIRE_HIGH, nCreeps[1]
			end
		end

		if #nCreeps >= 2 and nSkillLv >= 3
		then
			local creeps = bot:GetNearbyCreeps( 1400, true )
			local heroes = J.GetNearbyHeroes(bot, 1000, true, BOT_MODE_NONE )
			if J.IsValid( nCreeps[1] )
				and #creeps + #heroes >= 4
				and J.CanCastOnNonMagicImmune( nCreeps[1] )
				and not ( nCreeps[1]:GetTeam() == TEAM_NEUTRAL and #nLaneCreeps >= 1 )
				and J.GetAroundTargetEnemyUnitCount( nCreeps[1], 470 ) >= 2
			then
				return BOT_ACTION_DESIRE_HIGH, nCreeps[1]
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0

end


function X.ConsiderR()

	if not abilityR:IsFullyCastable() then return 0	end

	local nCastRange = abilityR:GetSpecialValueInt( "radius" )
	local nAttackRange = bot:GetAttackRange()

	--如果射程内无面对自己的真身则不开大
	local bRealHeroFace = false
	local realHeroList = J.GetEnemyList( bot, nAttackRange + 100 )
	for _, npcEnemy in pairs( realHeroList )
	do 
		if npcEnemy:IsFacingLocation( bot:GetLocation(), 50 )
		then
			bRealHeroFace = true
			break
		end
	end
	
	if not bRealHeroFace then return 0 end 
	

	if J.IsRetreating( bot )
	then
		local tableNearbyEnemyHeroes = J.GetNearbyHeroes(bot, 1000, true, BOT_MODE_NONE )
		for _, npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( bot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and npcEnemy:IsFacingLocation( bot:GetLocation(), 20 ) )
			then
				return BOT_ACTION_DESIRE_MODERATE
			end
		end
	end


	if J.IsInTeamFight( bot, 1200 ) or J.IsGoingOnSomeone( bot )
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nAttackRange, 400, 0, 0 )
		if ( locationAoE.count >= 2 )
		then
			local nInvUnit = J.GetInvUnitInLocCount( bot, nAttackRange + 200, 400, locationAoE.targetloc, true )
			if nInvUnit >= locationAoE.count then
				return BOT_ACTION_DESIRE_MODERATE
			end
		end

		local nEnemysHerosInSkillRange = J.GetNearbyHeroes(bot, 800, true, BOT_MODE_NONE )
		if #nEnemysHerosInSkillRange >= 3
		then
			return BOT_ACTION_DESIRE_HIGH
		end

		local nAoe = bot:FindAoELocation( true, true, bot:GetLocation(), 10, 700, 1.0, 0 )
		if nAoe.count >= 3
		then
			return BOT_ACTION_DESIRE_HIGH
		end

		local npcTarget = J.GetProperTarget( bot )
		if J.IsValidHero( npcTarget )
			and J.CanCastOnNonMagicImmune( npcTarget )
			and not J.IsDisabled( npcTarget )
			and GetUnitToUnitDistance( npcTarget, bot ) <= bot:GetAttackRange()
			and npcTarget:GetHealth() > 600
			and npcTarget:GetPrimaryAttribute() ~= ATTRIBUTE_INTELLECT
			and npcTarget:IsFacingLocation( bot:GetLocation(), 30 )
		then
			return BOT_ACTION_DESIRE_HIGH
		end

	end

	return BOT_ACTION_DESIRE_NONE

end


function X.GetHurtCount( nUnit, nCount )

	local nHeroes = J.GetNearbyHeroes(bot, 1600, true, BOT_MODE_NONE )
	local nCreeps = bot:GetNearbyCreeps( 1600, true, BOT_MODE_NONE )
	local nTable = {}
	table.insert( nTable, nUnit )
	local nHurtCount = 1

	for i=1, nCount
	do
		local nNeastUnit = X.GetNearestUnit( nUnit, nHeroes, nCreeps, nTable )

		if nNeastUnit ~= nil
			and GetUnitToUnitDistance( nUnit, nNeastUnit ) <= 475
		then
			nHurtCount = nHurtCount + 1
			table.insert( nTable, nNeastUnit )
		else
			break
		end
	end


	return nHurtCount

end

function X.GetNearestUnit( nUnit, nHeroes, nCreeps, nTable )

	local NearestUnit = nil
	local NearestDist = 9999
	for _, unit in pairs( nHeroes )
	do
		if unit ~= nil
			and unit:IsAlive()
			and not X.IsExistInTable( unit, nTable )
			and GetUnitToUnitDistance( nUnit, unit ) < NearestDist
		then
			NearestUnit = unit
			NearestDist = GetUnitToUnitDistance( nUnit, unit )
		end
	end

	for _, unit in pairs( nCreeps )
	do
		if unit ~= nil
			and unit:IsAlive()
			and not X.IsExistInTable( unit, nTable )
			and GetUnitToUnitDistance( nUnit, unit ) < NearestDist
		then
			NearestUnit = unit
			NearestDist = GetUnitToUnitDistance( nUnit, unit )
		end
	end

	return NearestUnit

end

function X.IsExistInTable( u, tUnit )
	for _, t in pairs( tUnit )
	do
		if t == u
		then
			return true
		end
	end
	return false
end

return X
-- dota2jmz@163.com QQ:2462331592..
