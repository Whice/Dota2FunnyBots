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

local GraveChill = bot:GetAbilityByName("visage_grave_chill")
local SoulAssumption = bot:GetAbilityByName("visage_soul_assumption")
local GravekeepersCloak = bot:GetAbilityByName("visage_gravekeepers_cloak")
local SummonFamiliars = bot:GetAbilityByName("visage_summon_familiars")
local SilentAsTheGrave = bot:GetAbilityByName("visage_silent_as_the_grave")

local GraveChillDesire = 0
local SoulAssumptionDesire = 0
local GravekeepersCloakDesire = 0
local SummonFamiliarsDesire = 0
local SilentAsTheGraveDesire = 0

local AttackRange
local BotTarget

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	-- The order to use abilities in
	GravekeepersCloakDesire = UseGravekeepersCloak()
	if GravekeepersCloakDesire > 0 then
		bot:Action_UseAbility(GravekeepersCloak)
		return
	end
	
	SummonFamiliarsDesire = UseSummonFamiliars()
	if SummonFamiliarsDesire > 0 then
		bot:Action_UseAbility(SummonFamiliars)
		return
	end
	
	SilentAsTheGraveDesire = UseSilentAsTheGrave()
	if SilentAsTheGraveDesire > 0 then
		bot:Action_UseAbility(SilentAsTheGrave)
		return
	end
	
	SoulAssumptionDesire, SoulAssumptionTarget = UseSoulAssumption()
	if SoulAssumptionDesire > 0 then
		bot:Action_UseAbilityOnEntity(SoulAssumption, SoulAssumptionTarget)
		return
	end
	
	GraveChillDesire, GraveChillTarget = UseGraveChill()
	if GraveChillDesire > 0 then
		bot:Action_UseAbilityOnEntity(GraveChill, GraveChillTarget)
		return
	end
end

function UseGraveChill()
	if not GraveChill:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = GraveChill:GetCastRange()
	
	if P.IsInLaningPhase(bot) then
		local EnemiesWithinRange = bot:GetNearbyHeroes((CastRange + 100), true, BOT_MODE_NONE)
		local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
		
		local StrongestUnit = PAF.GetStrongestAttackDamageUnit(FilteredEnemies)
		
		if StrongestUnit ~= nil
		and not PAF.IsMagicImmune(StrongestUnit) then
			return BOT_ACTION_DESIRE_HIGH, StrongestUnit
		end
	else
		local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
		local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
		
		if P.IsRetreating(bot) and #FilteredEnemies > 0 then
			local ClosestTarget = PAF.GetClosestUnit(bot, FilteredEnemies)
			return BOT_ACTION_DESIRE_HIGH, ClosestTarget
		end
		
		local StrongestUnit = PAF.GetStrongestAttackDamageUnit(FilteredEnemies)
		
		if PAF.IsEngaging(bot) and StrongestUnit ~= nil then
			if PAF.IsValidHeroAndNotIllusion(StrongestUnit) then
				if GetUnitToUnitDistance(bot, StrongestUnit) <= CastRange
				and not PAF.IsMagicImmune(StrongestUnit) then
					return BOT_ACTION_DESIRE_HIGH, StrongestUnit
				end
			end
		end
	end
	
	return 0
end

function UseSoulAssumption()
	if not SoulAssumption:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = SoulAssumption:GetCastRange()
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
		if AttackTarget ~= nil and PAF.IsRoshan(AttackTarget) then
			return BOT_ACTION_DESIRE_HIGH, AttackTarget
		end
	end
	
	return 0
end

function UseGravekeepersCloak()
	if not bot:HasScepter() then return 0 end
	if not GravekeepersCloak:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	if P.IsRetreating(bot) then
		if bot:GetHealth() <= (bot:GetMaxHealth() * 0.5) then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	return 0
end

function UseSummonFamiliars()
	if not SummonFamiliars:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	if P.IsInLaningPhase() then return 0 end
	
	local MaxFamiliars = SummonFamiliars:GetSpecialValueInt("familiar_count")
	local AllyList = GetUnitList(UNIT_LIST_ALLIES)
	local FamiliarCount = 0
	
	for v, Ally in pairs(AllyList) do
		if string.find(Ally:GetUnitName(), "visage_familiar") then
			FamiliarCount = (FamiliarCount + 1)
		end
	end
	
	if FamiliarCount < MaxFamiliars then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	return 0
end

function UseSilentAsTheGrave()
	if not SilentAsTheGrave:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	if PAF.IsEngaging(bot) or P.IsRetreating(bot) then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	return 0
end