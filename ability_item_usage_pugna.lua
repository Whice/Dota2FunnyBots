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

local NetherBlast = bot:GetAbilityByName("pugna_nether_blast")
local Decrepify = bot:GetAbilityByName("pugna_decrepify")
local NetherWard = bot:GetAbilityByName("pugna_nether_ward")
local LifeDrain = bot:GetAbilityByName("pugna_life_drain")

local NetherBlastDesire = 0
local DecrepifyDesire = 0
local NetherWardDesire = 0
local LifeDrainDesire = 0

local AttackRange
local BotTarget
local manathreshold = 0

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	manathreshold = 100
	manathreshold = manathreshold + NetherBlast:GetManaCost()
	manathreshold = manathreshold + Decrepify:GetManaCost()
	manathreshold = manathreshold + NetherWard:GetManaCost()
	
	-- The order to use abilities in
	NetherWardDesire, NetherWardTarget = UseNetherWard()
	if NetherWardDesire > 0 then
		bot:Action_UseAbilityOnLocation(NetherWard, NetherWardTarget)
		return
	end
	
	DecrepifyDesire, DecrepifyTarget = UseDecrepify()
	if DecrepifyDesire > 0 then
		bot:Action_UseAbilityOnEntity(Decrepify, DecrepifyTarget)
		return
	end
	
	NetherBlastDesire, NetherBlastTarget = UseNetherBlast()
	if NetherBlastDesire > 0 then
		bot:Action_UseAbilityOnLocation(NetherBlast, NetherBlastTarget)
		return
	end
	
	LifeDrainDesire, LifeDrainTarget = UseLifeDrain()
	if LifeDrainDesire > 0 then
		bot:Action_UseAbilityOnEntity(LifeDrain, LifeDrainTarget)
		return
	end
end

function UseNetherBlast()
	if not NetherBlast:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = NetherBlast:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	local Radius = NetherBlast:GetSpecialValueInt("radius")
	local Damage = NetherBlast:GetSpecialValueInt("blast_damage")
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget) then
				return BOT_ACTION_DESIRE_HIGH, BotTarget:GetLocation()
			end
		end
	end
	
	if P.IsInLaningPhase()
	and bot:GetActiveMode() == BOT_MODE_LANING then
		local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
		local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
		
		local NearbyCreeps = bot:GetNearbyCreeps(CastRange, true)
		for v, Creep in pairs(NearbyCreeps) do
			local EstimatedDamage = Creep:GetActualIncomingDamage(Damage, DAMAGE_TYPE_MAGICAL)
			local AoECount = PAF.GetUnitsNearTarget(Creep:GetLocation(), FilteredEnemies, Radius)
			
			if Creep:GetHealth() <= EstimatedDamage
			and AoECount > 0 then
				return BOT_ACTION_DESIRE_HIGH, PAF.GetVectorInBetween(Creep:GetLocation(), PAF.GetClosestUnit(Creep, FilteredEnemies):GetLocation())
			end
		end
	end
	
	local AttackTarget = bot:GetAttackTarget()
	
	if AttackTarget ~= nil then
		if AttackTarget:IsBuilding() then
			return BOT_ACTION_DESIRE_HIGH, AttackTarget:GetLocation()
		end
		
		if bot:GetActiveMode() == BOT_MODE_FARM and AttackTarget:IsCreep() then
			if (bot:GetMana() - NetherBlast:GetManaCost()) > manathreshold then
				return BOT_ACTION_DESIRE_HIGH, AttackTarget:GetLocation()
			end
		end
		
		if bot:GetActiveMode() == BOT_MODE_ROSHAN and PAF.IsRoshan(AttackTarget) then
			return BOT_ACTION_DESIRE_HIGH, AttackTarget:GetLocation()
		end
	end
	
	return 0
end

function UseDecrepify()
	if not Decrepify:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = NetherBlast:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	
	if P.IsRetreating(bot) and (bot:WasRecentlyDamagedByAnyHero(1) or #FilteredEnemies > 0) then
		return BOT_ACTION_DESIRE_HIGH, bot
	end
	
	local AlliesWithinRange = bot:GetNearbyHeroes(CastRange, false, BOT_MODE_NONE)
	local FilteredAllies = PAF.FilterTrueUnits(AlliesWithinRange)
	
	local WeakestAlly = PAF.GetWeakestUnit(FilteredAllies)
	
	if WeakestAlly ~= nil then
		if WeakestAlly:GetHealth() <= (WeakestAlly:GetMaxHealth() * 0.3)
		and WeakestAlly:WasRecentlyDamagedByAnyHero(1) then
			return BOT_ACTION_DESIRE_HIGH, WeakestAlly
		end
	end
	
	if P.IsInLaningPhase()
	and bot:GetActiveMode() == BOT_MODE_LANING then
		for v, Enemy in pairs(FilteredEnemies) do
			local EnemyAttackTarget = Enemy:GetAttackTarget()
			local EnemyAttackDamage = Enemy:GetAttackDamage()
			
			if EnemyAttackTarget ~= nil then
				if EnemyAttackTarget:IsCreep() then
					local EstimatedDamage = EnemyAttackTarget:GetActualIncomingDamage(EnemyAttackDamage, DAMAGE_TYPE_PHYSICAL)
					if EnemyAttackTarget:GetHealth() <= EstimatedDamage then
						return BOT_ACTION_DESIRE_HIGH, Enemy
					end
				end
			end
		end
	end
	
	return 0
end

function UseNetherWard()
	if not NetherWard:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	if not PAF.IsInTeamFight(bot) then return 0 end
	
	return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()
end

function UseLifeDrain()
	if not LifeDrain:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = NetherBlast:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget) then
				return BOT_ACTION_DESIRE_HIGH, BotTarget
			end
		end
	end
	
	local AttackTarget = bot:GetAttackTarget()
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN and PAF.IsRoshan(AttackTarget) then
			return BOT_ACTION_DESIRE_HIGH, AttackTarget
		end
	
	return 0
end