local X = {}
local bDebugMode = ( 1 == 10 )
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )

local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

local tTalentTreeList = {
						['t25'] = {0, 10},
						['t20'] = {0, 10},
						['t15'] = {0, 10},
						['t10'] = {10, 0},
}

local tAllAbilityBuildList = {
						{1,2,1,3,1,6,1,3,3,3,2,6,2,2,6},--pos1,2
}

local nAbilityBuildList = J.Skill.GetRandomBuild( tAllAbilityBuildList )

local nTalentBuildList = J.Skill.GetTalentBuild( tTalentTreeList )

local sRoleItemsBuyList = {}

sRoleItemsBuyList['pos_1'] = {
	"item_tango",
	"item_double_branches",
	"item_slippers",
	"item_circlet",

	"item_magic_wand",
	"item_wraith_band",
	"item_wraith_band",
	"item_power_treads",
	
	"item_mask_of_madness",
	"item_dragon_lance",
	"item_lesser_crit",
	"item_hurricane_pike",--
	"item_aghanims_shard",
	"item_greater_crit",--
	"item_invis_sword",
	"item_silver_edge",--
	"item_butterfly",--
	"item_travel_boots",
	"item_moon_shard",
	"item_satanic",--
	"item_travel_boots_2",--
	"item_ultimate_scepter_2",
}

sRoleItemsBuyList['pos_2'] = sRoleItemsBuyList['pos_1']

sRoleItemsBuyList['pos_4'] = sRoleItemsBuyList['pos_1']

sRoleItemsBuyList['pos_5'] = sRoleItemsBuyList['pos_1']

sRoleItemsBuyList['pos_3'] = sRoleItemsBuyList['pos_1']

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

npc_dota_hero_muerta

Modifier or ability names not supported as of 5.5.2024

--]]

local abilityQ = bot:GetAbilityByName( sAbilityList[1] )
local abilityW = bot:GetAbilityByName( sAbilityList[2] )
local abilityE = bot:GetAbilityByName( sAbilityList[3] )
local abilityR = bot:GetAbilityByName( sAbilityList[6] )
local abilityAS = bot:GetAbilityByName( sAbilityList[4] )

local castQDesire, castQTarget
local castWDesire, castWLocation
local castEDesire, castRDesire
local castASDesire, castASTarget

local nKeepMana = 280
local botTarget = nil

-- was for fully takeover, but not used atm.
function X.Think()
	-- X.AbilityItemUsage = dofile( GetScriptDirectory()..'/ability_item_usage_generic')

	-- bot:Action_AttackMove(J.GetEnemyFountain())
    if X.TeamRoam == nil then
		X.TeamRoam = require(GetScriptDirectory() .. "/FunLib/mode_team_roam_generic_shared")
        -- X.FarmGeneric = dofile(GetScriptDirectory() .. "/FunLib/mode_farm_generic_shared")
    --     -- X.ItemPurchase = require(GetScriptDirectory() .. "/item_purchase_generic")
    --     -- X.TeamRoam = require(GetScriptDirectory() .. "/mode_team_roam_generic")
    --     -- X.AbilityItemUsage = require(GetScriptDirectory() .. "/ability_item_usage_generic")
    end

    -- -- X.ItemPurchase.ItemPurchaseThink()

    if X.TeamRoam.GetDesire() > 0 then
        X.TeamRoam.Think()
    end
    -- if X.FarmGeneric.GetDesire() > 0 then
    --     X.FarmGeneric.Think()
    -- end

    -- X.AbilityItemUsage.ItemUsageThink()
    -- X.AbilityItemUsage.AbilityUsageThink()
    -- X.AbilityItemUsage.BuybackUsageThink()
    -- X.AbilityItemUsage.AbilityLevelUpThink()

end

function X.SkillsComplement()

	X.ConsiderTarget()
	J.ConsiderForMkbDisassembleMask( bot )

	if J.CanNotUseAbility( bot ) or bot:IsInvisible() then return end

	botTarget = J.GetProperTarget(bot)

    castQDesire, castQTarget = X.ConsiderQ()
    if castQDesire > 0
    then
        bot:Action_UseAbilityOnEntity(abilityQ, castQTarget)
        -- bot:Action_UseAbilityOnTree(abilityQ, castQTarget) -- dont know how to choose release angle.
        return
    end

	castRDesire = X.ConsiderR()
	if ( castRDesire > 0 )
	then
		J.SetQueuePtToINT( bot, true )
		bot:ActionQueue_UseAbility( abilityR )
		return
	end

	castWDesire, castWLocation = X.ConsiderW()
	if ( castWDesire > 0 )
	then
		J.SetQueuePtToINT( bot, false )
		bot:ActionQueue_UseAbilityOnLocation( abilityW, castWLocation )
		return
	end
	
	castEDesire = X.ConsiderE()
	if ( castEDesire > 0 )
	then
		bot:Action_ClearActions( false )
		bot:ActionQueue_UseAbility( abilityE )
		return
	end

	castASDesire, castASTarget = X.ConsiderAS()
	if ( castASDesire > 0 )
	then
		J.SetQueuePtToINT( bot, true )
		bot:ActionQueue_UseAbilityOnEntity( abilityAS, castASTarget )
		return
	end


end

function X.ConsiderTarget()
	if not J.IsRunning( bot )
		or bot:HasModifier( "modifier_item_hurricane_pike_range" )
	then return end

	local nAttackRange = math.max(1600, bot:GetAttackRange() + 60)
	local nInAttackRangeWeakestEnemyHero = J.GetAttackableWeakestUnit( bot, nAttackRange, true, true )

	local npcTarget = J.GetProperTarget( bot )
	local nTargetUint = nil

	if J.IsValidHero( npcTarget )
		and GetUnitToUnitDistance( npcTarget, bot ) > nAttackRange
		and J.IsValidHero( nInAttackRangeWeakestEnemyHero )
	then
		nTargetUint = nInAttackRangeWeakestEnemyHero
		bot:SetTarget( nTargetUint )
		return
	end

end

function X.ConsiderQ()
	if not abilityQ:IsFullyCastable() then return 0 end

	local nCastRange = J.GetProperCastRange(false, bot, abilityQ:GetCastRange())
    local nDamage = abilityQ:GetSpecialValueInt('damage')
	
	-- local nCastPoint = abilityQ:GetCastPoint()
	-- local nRadius = abilityQ:GetSpecialValueInt('bounce_range')
    -- local nSpeed = abilityQ:GetSpecialValueInt('projectile_speed')
    -- local nAbilityLevel = abilityQ:GetLevel()

	-- get the kill
    local nEnemyHeroes = J.GetNearbyHeroes(bot,nCastRange, true, BOT_MODE_NONE)
    for _, enemyHero in pairs(nEnemyHeroes)
    do
		if J.IsValidHero( enemyHero )
		and J.IsInRange( bot, enemyHero, nCastRange )
		and J.CanCastOnNonMagicImmune( enemyHero )
		and J.CanCastOnTargetAdvanced( enemyHero )
        and J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_PHYSICAL)
        and not J.IsSuspiciousIllusion(enemyHero)
		then
			return BOT_ACTION_DESIRE_HIGH, enemyHero, 'Q-Kill'
		end
    end

	--进攻
	if J.IsGoingOnSomeone( bot )
	then
		if J.IsValidHero( botTarget )
			and J.CanCastOnNonMagicImmune( botTarget )
			and J.CanCastOnTargetAdvanced( botTarget )
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget, 'Q-Attack'
		end
	end

	--撤退
	if J.IsRetreating( bot )
	then
		for _, npcEnemy in pairs( nEnemyHeroes )
		do
			if J.IsValidHero( npcEnemy )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and J.CanCastOnTargetAdvanced( npcEnemy )
				and bot:WasRecentlyDamagedByHero( npcEnemy, 3.0 )
			then
				return BOT_ACTION_DESIRE_HIGH, botTarget, 'Q-Retreat'
			end
		end
	end

	if J.IsDoingRoshan(bot)
    then
        if J.IsRoshan(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget
        end
    end

    if J.IsDoingTormentor(bot)
    then
        if J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget
        end
    end

	return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderW()

	if not abilityW:IsFullyCastable() then return 0 end

	local nCastRange = abilityW:GetCastRange() + 200
	local nSkillLV = abilityW:GetLevel()
	local nRadius = abilityW:GetAOERadius()
	local nCastPoint = abilityW:GetCastPoint()
	local botLocation = bot:GetLocation()

	local nEnemysHeroesInSkillRange = J.GetNearbyHeroes(bot, nCastRange, true, BOT_MODE_NONE )

	local nCanHurtHeroLocationAoE = bot:FindAoELocation( true, true, botLocation, nCastRange, nRadius-30, 0.8, 0 )

	--对多个敌方英雄使用
	if #nEnemysHeroesInSkillRange >= 2
		and ( nCanHurtHeroLocationAoE.cout ~= nil and nCanHurtHeroLocationAoE.cout >= 2 )
		and bot:GetActiveMode() ~= BOT_MODE_LANING
		and ( bot:GetActiveMode() ~= BOT_MODE_RETREAT or ( bot:GetActiveMode() == BOT_MODE_RETREAT and bot:GetActiveModeDesire() < 0.6 ) )
	then
		return BOT_ACTION_DESIRE_HIGH, nCanHurtHeroLocationAoE.targetloc
	end

	--对当前目标英雄使用
	if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidHero( botTarget )
			and J.CanCastOnNonMagicImmune( botTarget )
			and J.IsInRange( botTarget, bot, nCastRange + 300 )
			and ( nSkillLV >= 3 or bot:GetMana() >= nKeepMana )
		then

			if botTarget:IsFacingLocation( J.GetEnemyFountain(), 30 )
				and J.GetHP( botTarget ) < 0.4
				and J.IsRunning( botTarget )
			then
				--追击减速当前目标
				for i=0, 800, 200
				do
					local nCastLocation = J.GetLocationTowardDistanceLocation( botTarget, J.GetEnemyFountain(), nRadius + 800 - i )
					if GetUnitToLocationDistance( bot, nCastLocation ) <= nCastRange + 200
					then
						return BOT_ACTION_DESIRE_HIGH, nCastLocation
					end
				end
			end

			--对当前目标使用技能
			local npcTargetLocInFuture = J.GetCorrectLoc( botTarget, nCastPoint + 1.8 )
			if J.GetLocationToLocationDistance( botTarget:GetLocation(), npcTargetLocInFuture ) > 300
				and botTarget:GetMovementDirectionStability() > 0.4
			then
				return BOT_ACTION_DESIRE_HIGH, npcTargetLocInFuture
			end

			--近处预测将到近处来的目标
			local castDistance = GetUnitToUnitDistance( bot, botTarget )
			if botTarget:IsFacingLocation( botLocation, 30 ) and J.IsMoving( botTarget )
			then
				if castDistance > 400
				then
					castDistance = castDistance - 200
				end
				return BOT_ACTION_DESIRE_HIGH, J.GetUnitTowardDistanceLocation( bot, botTarget, castDistance )
			end

			--远处预测将到远处去的目标
			if bot:IsFacingLocation( botTarget:GetLocation(), 30 )
			then
				if castDistance <= nCastRange - 200
				then
					castDistance = castDistance + 400
				else
					castDistance = nCastRange + 300
				end
				return BOT_ACTION_DESIRE_HIGH, J.GetUnitTowardDistanceLocation( bot, botTarget, castDistance )
			end

			--目标位置无规律
			return BOT_ACTION_DESIRE_HIGH, J.GetLocationTowardDistanceLocation( botTarget, J.GetEnemyFountain(), nRadius/2 )

		end
	end

	--撤退时
	if J.IsRetreating( bot )
		and not bot:IsInvisible()
	then
		local nCanHurtHeroLocationAoENearby = bot:FindAoELocation( true, true, botLocation, nCastRange - 400, nRadius, 1.5, 0 )
		if nCanHurtHeroLocationAoENearby.count >= 2
		then
			return BOT_ACTION_DESIRE_HIGH, nCanHurtHeroLocationAoENearby.targetloc
		end

		if bot:GetActiveModeDesire() > 0.8
		then
			local nEnemyNearby = J.GetNearbyHeroes(bot, 800, true, BOT_MODE_NONE )
			for _, npcEnemy in pairs( nEnemyNearby )
			do
				if J.IsValid( npcEnemy )
					and bot:WasRecentlyDamagedByHero( npcEnemy, 2.0 )
					and J.CanCastOnNonMagicImmune( npcEnemy )
				then
					local nCastLocation = ( botLocation + npcEnemy:GetLocation() )/2
                    --对特定位置使用技能
                    return BOT_ACTION_DESIRE_HIGH, nCastLocation
				end
			end
		end
	end

	if J.IsFarming( bot ) and bot:GetMana() >= nKeepMana
	then
		local nNeutralCreeps = bot:GetNearbyNeutralCreeps( 800 )
		if #nNeutralCreeps >= 4
			and J.IsValid( botTarget )
			and not J.CanKillTarget( botTarget, bot:GetAttackDamage() * 3.88 , DAMAGE_TYPE_PHYSICAL )
		then
			local nAoE = bot:FindAoELocation( true, false, botLocation, nCastRange, nRadius, 0.8, 0 )
			if nAoE.count >= 5
			then
				return BOT_ACTION_DESIRE_HIGH, nAoE.targetloc
			end
		end
	end

	if bot:GetActiveMode() == BOT_MODE_ROSHAN
	then
		local nAttackTarget = bot:GetAttackTarget()
		if J.IsValid( nAttackTarget )
			and J.GetHP( nAttackTarget ) > 0.5
			and J.IsInRange( nAttackTarget, bot, 600 )
		then
			local nAllies = J.GetNearbyHeroes(bot, 800, false, BOT_MODE_ROSHAN )
			if #nAllies >= 4
			then
				return BOT_ACTION_DESIRE_HIGH, nAttackTarget:GetLocation()
			end
		end
	end

	return 0
end

function X.ConsiderE()
	if not abilityE:IsTrained() or not abilityE:IsFullyCastable() then 
        return BOT_ACTION_DESIRE_NONE 
    end

    if not abilityE:GetToggleState() then
        return BOT_ACTION_DESIRE_HIGH
    end
	return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderR()

	if not abilityR:IsFullyCastable() then return 0 end

    local nAttackRange = bot:GetAttackRange()
	local nEnemyHeroes = J.GetNearbyHeroes(bot, 1000, true, BOT_MODE_NONE )

    if J.IsRetreating( bot )
	then
		if bot:WasRecentlyDamagedByAnyHero( 2.0 ) and #nEnemyHeroes > 0 and J.GetHP(bot) < 0.5
		then
			return BOT_ACTION_DESIRE_MODERATE
		end
	end

	if J.IsWithoutTarget( bot ) and J.GetAttackProjectileDamageByRange( bot, 800 ) >= bot:GetHealth()
	then
		return BOT_ACTION_DESIRE_MODERATE
	end

	if J.IsGoingOnSomeone( bot ) and false
	then
		local npcTarget = bot:GetTarget()
		if J.IsValidHero( npcTarget )
			and J.IsInRange( npcTarget, bot, nAttackRange )
		then
            if J.GetHP(npcTarget) <= 0.7 then return BOT_ACTION_DESIRE_MODERATE end

            if npcTarget:HasModifier('modifier_item_ethereal_blade_ethereal')
            or npcTarget:HasModifier('modifier_necrophos_death_seeker_ethereal')
            or npcTarget:HasModifier('modifier_necrolyte_sadist_active')
            or npcTarget:HasModifier('modifier_pugna_decrepify')
            or npcTarget:HasModifier('modifier_ghost_state')
            then
		        return BOT_ACTION_DESIRE_HIGH
            end
		end
	end

	if not bot:IsMagicImmune()
    and not bot:IsInvulnerable()
    and J.IsInTeamFight(bot)
	then
        if J.GetEnemyCount(bot, 1000) >= 2
		then
			return BOT_ACTION_DESIRE_HIGH
		end
    end
	return 0
end

function X.ConsiderAS()

	if not abilityAS:IsTrained()
		or not abilityAS:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE, 0
	end

	local nCastRange = abilityAS:GetCastRange() + 200
	-- local nRadius = 100
	-- local nCastPoint = abilityAS:GetCastPoint()
	-- local nManaCost = abilityAS:GetManaCost()

	local nInBonusEnemyList = J.GetAroundEnemyHeroList( nCastRange + 200 )

	--撤退时保护自己
	if J.IsRetreating( bot )
		and ( bot:WasRecentlyDamagedByAnyHero( 3.0 ) or bot:GetActiveModeDesire() > 0.7 )
	then
		for _, npcEnemy in pairs( nInBonusEnemyList )
		do
			if J.IsValid( npcEnemy )
				and J.CanCastOnNonMagicImmune( npcEnemy )
				and J.CanCastOnTargetAdvanced( npcEnemy )
				and not J.IsDisabled( npcEnemy )
				and not npcEnemy:IsDisarmed()
			then
				local hCastTarget = npcEnemy
				local sCastMotive = '撤退'
				return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
			end
		end
	end

	--团战中对最能输出的人使用
	if J.IsInTeamFight( bot, 1200 )
	then
		local npcStrongestEnemy = nil
		local nStrongestPower = 0
		local nEnemyCount = 0
		
		for _, npcEnemy in pairs( nInBonusEnemyList )
		do
			if J.IsValid( npcEnemy )
				and J.CanCastOnNonMagicImmune( npcEnemy )
			then
				nEnemyCount = nEnemyCount + 1
				if J.CanCastOnTargetAdvanced( npcEnemy )
					and not J.IsDisabled( npcEnemy )
					and not npcEnemy:IsDisarmed()
				then
					local npcEnemyPower = npcEnemy:GetEstimatedDamageToTarget( true, bot, 6.0, DAMAGE_TYPE_ALL )
					if ( npcEnemyPower > nStrongestPower )
					then
						nStrongestPower = npcEnemyPower
						npcStrongestEnemy = npcEnemy
					end
				end
			end
		end

		if npcStrongestEnemy ~= nil and nEnemyCount >= 2
			and J.IsInRange( bot, npcStrongestEnemy, nCastRange + 150 )
		then
			local hCastTarget = npcStrongestEnemy
			local sCastMotive = '团战控制输出'
			return BOT_ACTION_DESIRE_HIGH, hCastTarget, sCastMotive
		end
	end

	if J.IsGoingOnSomeone( bot )
	then
		local targetHero = J.GetProperTarget( bot )
		if J.IsValidHero( targetHero )
			and J.IsInRange( bot, targetHero, nCastRange )
			and J.CanCastOnNonMagicImmune( targetHero )
		then
			return BOT_ACTION_DESIRE_HIGH, targetHero
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0

end


return X
