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

local InsatiableHunger = bot:GetAbilityByName("broodmother_insatiable_hunger")
local SpinWeb = bot:GetAbilityByName("broodmother_spin_web")
local IncapacitatingBite = bot:GetAbilityByName("broodmother_incapacitating_bite")
local SpawnSpiderlings = bot:GetAbilityByName("broodmother_spawn_spiderlings")

local InsatiableHungerDesire = 0
local SpinWebDesire = 0
local SilkenBolaDesire = 0
local SpawnSpiderlingsDesire = 0

local AttackRange
local BotTarget

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	-- The order to use abilities in
	SpawnSpiderlingsDesire, SpawnSpiderlingsTarget = UseSpawnSpiderlings()
	if SpawnSpiderlingsDesire > 0 then
		bot:Action_UseAbilityOnEntity(SpawnSpiderlings, SpawnSpiderlingsTarget)
		return
	end
	
	SpinWebDesire, SpinWebTarget = UseSpinWeb()
	if SpinWebDesire > 0 then
		bot:Action_UseAbilityOnLocation(SpinWeb, SpinWebTarget)
		return
	end
	
	InsatiableHungerDesire, InsatiableHungerTarget = UseInsatiableHunger()
	if InsatiableHungerDesire > 0 then
		bot:Action_UseAbility(InsatiableHunger)
		return
	end
end

function UseInsatiableHunger()
	if not InsatiableHunger:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= 1000 then
				return BOT_ACTION_DESIRE_HIGH, BotTarget
			end
		end
	end
	
	local AttackTarget = bot:GetAttackTarget()
	
	if AttackTarget ~= nil then
		if bot:GetActiveMode() == BOT_MODE_ROSHAN then
			if PAF.IsRoshan(AttackTarget) then
				return BOT_ACTION_DESIRE_VERYHIGH
			end
		end
		
		if PAF.IsTormentor(AttackTarget) then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	return 0
end

function UseSpinWeb()
	if not SpinWeb:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local Radius = SpinWeb:GetSpecialValueInt("radius")
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(Radius, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= Radius
			and not bot:HasModifier("modifier_broodmother_spin_web") then
				return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()
			end
		end
	end
	
	if P.IsRetreating(bot)
	and #FilteredEnemies > 0
	and not bot:HasModifier("modifier_broodmother_spin_web") then
		return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()
	end
	
	if bot:GetActiveMode() == BOT_MODE_LANING then
		local AssignedLane = bot:GetAssignedLane()
		local LaneFrontLoc = GetLaneFrontLocation(bot:GetTeam(), AssignedLane, 0)
		
		if GetUnitToLocationDistance(bot, LaneFrontLoc) <= (Radius/2)
		and not bot:HasModifier("modifier_broodmother_spin_web") then
			return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		local AttackTarget = bot:GetAttackTarget()
		
		if PAF.IsRoshan(AttackTarget)
		and not bot:HasModifier("modifier_broodmother_spin_web") then
			return BOT_ACTION_DESIRE_VERYHIGH, bot:GetLocation()
		end
	end
	
	return 0
end

--[[function UseSilkenBola()
	if not SilkenBola:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = SilkenBola:GetCastRange()
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
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		if PAF.IsRoshan(AttackTarget)
		and GetUnitToUnitDistance(bot, AttackTarget) <= CastRange then
			return BOT_ACTION_DESIRE_VERYHIGH, AttackTarget
		end
	end
	
	return 0
end]]--

function UseSpawnSpiderlings()
	if not SpawnSpiderlings:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = SpawnSpiderlings:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local Damage = SpawnSpiderlings:GetSpecialValueInt("damage")
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget) then
				local EstimatedDamage = BotTarget:GetActualIncomingDamage(Damage, DAMAGE_TYPE_MAGICAL)
				
				if EstimatedDamage >= BotTarget:GetHealth() then
					return BOT_ACTION_DESIRE_HIGH, BotTarget
				end
			end
		end
	end
	
	local creeps = bot:GetNearbyCreeps(CastRange, true)
	
	for v, creep in pairs(creeps) do
		local EstimatedDamage = creep:GetActualIncomingDamage(Damage, DAMAGE_TYPE_MAGICAL)
		
		if EstimatedDamage > creep:GetHealth() and not PAF.IsEngaging(bot) and not P.IsRetreating(bot) then
			return BOT_ACTION_DESIRE_HIGH, creep
		end
	end
	
	return 0
end