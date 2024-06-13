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

local Swarm = bot:GetAbilityByName("weaver_the_swarm")
local Shukuchi = bot:GetAbilityByName("weaver_shukuchi")
local GeminateAttack = bot:GetAbilityByName("weaver_geminate_attack")
local TimeLapse = bot:GetAbilityByName("weaver_time_lapse")

local SwarmDesire = 0
local ShukuchiDesire = 0
local GeminateAttackDesire = 0
local TimeLapseDesire = 0

local AttackRange
local BotTarget

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	-- The order to use abilities in
	TimeLapseDesire = UseTimeLapse()
	if TimeLapseDesire > 0 then
		bot:Action_UseAbility(TimeLapse)
		return
	end
	
	ShukuchiDesire = UseShukuchi()
	if ShukuchiDesire > 0 then
		bot:Action_UseAbility(Shukuchi)
		return
	end
	
	SwarmDesire, SwarmTarget = UseSwarm()
	if SwarmDesire > 0 then
		bot:Action_UseAbilityOnLocation(Swarm, SwarmTarget)
		return
	end
	
	GeminateAttackDesire, GeminateAttackTarget = UseGeminateAttack()
	if GeminateAttackDesire > 0 then
		bot:Action_UseAbilityOnEntity(GeminateAttack, GeminateAttackTarget)
		return
	end
end

function UseSwarm()
	if not Swarm:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = Swarm:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget) then
				return BOT_ACTION_DESIRE_HIGH, BotTarget:GetLocation()
			end
		end
	end
	
	local AttackTarget = bot:GetAttackTarget()
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		if PAF.IsRoshan(AttackTarget)
		and GetUnitToUnitDistance(bot, AttackTarget) <= CastRange then
			return BOT_ACTION_DESIRE_VERYHIGH, AttackTarget:GetLocation()
		end
	end
	
	return 0
end

function UseShukuchi()
	if not Shukuchi:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = Shukuchi:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local projectiles = bot:GetIncomingTrackingProjectiles()
	
	for v, proj in pairs(projectiles) do
		if GetUnitToLocationDistance(bot, proj.location) <= 300 and proj.is_attack == false then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	if P.IsRetreating(bot) then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	if Shukuchi:GetLevel() == 4
	and bot:GetMana() > (bot:GetMaxMana() * 0.5) then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	return 0
end

function UseGeminateAttack()
	if not GeminateAttack:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local AttackTarget = bot:GetAttackTarget()
	
	if P.IsInLaningPhase() then
		if AttackTarget:GetTeam() ~= bot:GetTeam() and (AttackTarget:IsHero() or AttackTarget:IsBuilding()) then
			if GeminateAttack:GetToggleState() == false then
				return BOT_ACTION_DESIRE_HIGH
			else
				return 0
			end
		else
			if GeminateAttack:GetToggleState() == true then
				return BOT_ACTION_DESIRE_HIGH
			else
				return 0
			end
		end
	else
		if GeminateAttack:GetToggleState() == false then
			return BOT_ACTION_DESIRE_HIGH
		else
			return 0
		end
	end
	
	if P.IsInLaningPhase() then
		local AttackDamage = bot:GetAttackDamage()
		local GeminateDamage = GeminateAttack:GetSpecialValueInt("bonus_damage")
		local TotalDamage = ((AttackDamage * 2) + GeminateDamage)
		local NearbyLaneCreeps = bot:GetNearbyLaneCreeps(AttackRange, true)
		
		for v, Creep in pairs(NearbyLaneCreeps) do
			local EstimatedDamage = Creep:GetActualIncomingDamage(TotalDamage, DAMAGE_TYPE_PHYSICAL)
			
			if Creep:GetHealth() <= EstimatedDamage then
				return BOT_ACTION_DESIRE_HIGH, Creep
			end
		end
	end
	
	return 0
end

function UseTimeLapse()
	if not TimeLapse:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	if bot:GetHealth() <= (bot:GetMaxHealth() * 0.5)
	and bot:WasRecentlyDamagedByAnyHero(1) then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	return 0
end