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

local WildAxes = bot:GetAbilityByName("beastmaster_wild_axes")
local Boar = bot:GetAbilityByName("beastmaster_call_of_the_wild_boar")
local Hawk = bot:GetAbilityByName("beastmaster_call_of_the_wild_hawk")
local InnerBeast = bot:GetAbilityByName("beastmaster_inner_beast")
local PrimalRoar = bot:GetAbilityByName("beastmaster_primal_roar")

local WildAxesDesire = 0
local BoarDesire = 0
local HawkDesire = 0
local PrimalRoarDesire = 0

local AttackRange
local BotTarget
local manathreshold = 0

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	manathreshold = (bot:GetMaxMana() * 0.4)
	
	-- The order to use abilities in
	PrimalRoarDesire, PrimalRoarTarget = UsePrimalRoar()
	if PrimalRoarDesire > 0 then
		bot:Action_UseAbilityOnEntity(PrimalRoar, PrimalRoarTarget)
		return
	end
	
	WildAxesDesire, WildAxesTarget = UseWildAxes()
	if WildAxesDesire > 0 then
		bot:Action_UseAbilityOnLocation(WildAxes, WildAxesTarget)
		return
	end
	
	BoarDesire = UseBoar()
	if BoarDesire > 0 then
		bot:Action_UseAbility(Boar)
		return
	end
	
	HawkDesire = UseHawk()
	if HawkDesire > 0 then
		bot:Action_UseAbility(Hawk)
		return
	end
end

function UseWildAxes()
	if not WildAxes:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = WildAxes:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget) then
				return BOT_ACTION_DESIRE_HIGH, BotTarget:GetExtrapolatedLocation(1)
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

function UseBoar()
	if not Boar:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	if P.IsInLaningPhase() then
		if PAF.IsEngaging(bot) then
			return BOT_ACTION_DESIRE_HIGH
		end
	else
		local MaxBoars = 1
		local AllyList = GetUnitList(UNIT_LIST_ALLIES)
		local BoarCount = 0
		
		for v, Ally in pairs(AllyList) do
			if string.find(Ally:GetUnitName(), "beastmaster_boar") then
				BoarCount = (BoarCount + 1)
			end
		end
		
		if BoarCount < MaxBoars then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	return 0
end

function UseHawk()
	if not Hawk:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local AttackRadius = Hawk:GetSpecialValueInt("attack_radius")
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= AttackRadius then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end
	
	return 0
end

function UsePrimalRoar()
	if not PrimalRoar:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = PrimalRoar:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	if PAF.IsInTeamFight(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange then
				return BOT_ACTION_DESIRE_HIGH, BotTarget
			end
		end
	end
	
	return 0
end