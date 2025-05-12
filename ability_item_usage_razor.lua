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

local PlasmaField = bot:GetAbilityByName("razor_plasma_field")
local StaticLink = bot:GetAbilityByName("razor_static_link")
local UnstableCurrent = bot:GetAbilityByName("razor_storm_sturge")
local EyeOfTheStorm = bot:GetAbilityByName("razor_eye_of_the_storm")

local PlasmaFieldDesire = 0
local StaticLinkDesire = 0
local EyeOfTheStormDesire = 0

local AttackRange
local BotTarget
local manathreshold = 0

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	manathreshold = 100
	manathreshold = manathreshold + PlasmaField:GetManaCost()
	manathreshold = manathreshold + StaticLink:GetManaCost()
	manathreshold = manathreshold + EyeOfTheStorm:GetManaCost()
	
	-- The order to use abilities in
	EyeOfTheStormDesire = UseEyeOfTheStorm()
	if EyeOfTheStormDesire > 0 then
		bot:Action_UseAbility(EyeOfTheStorm)
		return
	end
	
	PlasmaFieldDesire = UsePlasmaField()
	if PlasmaFieldDesire > 0 then
		bot:Action_UseAbility(PlasmaField)
		return
	end
	
	StaticLinkDesire, StaticLinkTarget = UseStaticLink()
	if StaticLinkDesire > 0 then
		bot:Action_UseAbilityOnEntity(StaticLink, StaticLinkTarget)
		return
	end
end

function UsePlasmaField()
	if not PlasmaField:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = PlasmaField:GetSpecialValueInt("radius")
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterUnitsForStun(EnemiesWithinRange)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget) then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end
	
	if P.IsRetreating(bot) and #FilteredEnemies > 0 then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	local AttackTarget = bot:GetAttackTarget()
	
	if AttackTarget ~= nil then
		if AttackTarget:IsCreep() then
			local CreepsWithinRange = bot:GetNearbyCreeps(CastRange, true)
			
			if #CreepsWithinRange >= 2 and (bot:GetMana() - PlasmaField:GetManaCost()) > manathreshold then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
		
		if bot:GetActiveMode() == BOT_MODE_ROSHAN and PAF.IsRoshan(AttackTarget) then
			return BOT_ACTION_DESIRE_HIGH
		end
		
		if PAF.IsTormentor(AttackTarget) then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	return 0
end

function UseStaticLink()
	if not StaticLink:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = StaticLink:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local EnemiesWithinRange = bot:GetNearbyHeroes((CastRange * 1.5), true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	
	if PAF.IsEngaging(bot) then
		local StrongestTarget = PAF.GetStrongestAttackDamageUnit(FilteredEnemies)
		
		if StrongestTarget ~= nil then
			return BOT_ACTION_DESIRE_HIGH, StrongestTarget
		end
	end
	
	if P.IsRetreating(bot) then
		local ClosestTarget = PAF.GetClosestUnit(bot, FilteredEnemies)
		
		if ClosestTarget ~= nil then
			return BOT_ACTION_DESIRE_HIGH, ClosestTarget
		end
	end
	
	return 0
end

function UseEyeOfTheStorm()
	if not EyeOfTheStorm:IsFullyCastable() then return 0 end
	if not PAF.IsInTeamFight(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	return BOT_ACTION_DESIRE_HIGH
end