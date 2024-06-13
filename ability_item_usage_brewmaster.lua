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

local ThunderClap = bot:GetAbilityByName("brewmaster_thunder_clap")
local CinderBrew = bot:GetAbilityByName("brewmaster_cinder_brew")
local DrunkenBrawler = bot:GetAbilityByName("brewmaster_drunken_brawler")
local PrimalSplit = bot:GetAbilityByName("brewmaster_primal_split")
local PrimalCompanion = bot:GetAbilityByName("brewmaster_primal_companion")

local ThunderClapDesire = 0
local CinderBrewDesire = 0
local DrunkenBrawlerDesire = 0
local PrimalSplitDesire = 0
local PrimalCompanionDesire = 0

local DrunkenBrawlerStance = "Earth"

local AttackRange
local BotTarget
local manathreshold = 0

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	manathreshold = 100
	
	-- The order to use abilities in
	PrimalCompanionDesire = UsePrimalCompanion()
	if PrimalCompanionDesire > 0 then
		bot:Action_UseAbility(PrimalCompanion)
		return
	end
	
	PrimalSplitDesire = UsePrimalSplit()
	if PrimalSplitDesire > 0 then
		bot:Action_UseAbility(PrimalSplit)
		return
	end
	
	DrunkenBrawlerDesire = UseDrunkenBrawler()
	if DrunkenBrawlerDesire > 0 then
		bot:Action_UseAbility(DrunkenBrawler)
		if DrunkenBrawlerStance == "Earth" then
			DrunkenBrawlerStance = "Storm"
		elseif DrunkenBrawlerStance == "Storm" then
			DrunkenBrawlerStance = "Fire"
		elseif DrunkenBrawlerStance == "Fire" then
			DrunkenBrawlerStance = "Earth"
		end
		return
	end
	
	ThunderClapDesire = UseThunderClap()
	if ThunderClapDesire > 0 then
		bot:Action_UseAbility(ThunderClap)
		return
	end
	
	CinderBrewDesire, CinderBrewTarget = UseCinderBrew()
	if CinderBrewDesire > 0 then
		bot:Action_UseAbilityOnLocation(CinderBrew, CinderBrewTarget)
		return
	end
end

function UseThunderClap()
	if not ThunderClap:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = ThunderClap:GetSpecialValueInt("radius")
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterUnitsForStun(EnemiesWithinRange)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= (CastRange - 50)
			and not PAF.IsMagicImmune(BotTarget) then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end
	
	if #FilteredEnemies >= 1 and P.IsRetreating(bot) then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	local AttackTarget = bot:GetAttackTarget()
	
	if AttackTarget ~= nil then
		if AttackTarget:IsCreep() then
			local CreepsWithinRange = bot:GetNearbyCreeps(CastRange, true)
			
			if #CreepsWithinRange >= 3 and (bot:GetMana() - ThunderClap:GetManaCost()) > manathreshold then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
		
		if bot:GetActiveMode() == BOT_MODE_ROSHAN and PAF.IsRoshan(AttackTarget) then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	return 0
end

function UseCinderBrew()
	if not CinderBrew:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = CinderBrew:GetCastRange()
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
	
	if AttackTarget ~= nil then
		if bot:GetActiveMode() == BOT_MODE_ROSHAN and PAF.IsRoshan(AttackTarget) then
			return BOT_ACTION_DESIRE_HIGH, AttackTarget:GetLocation()
		end
	end
	
	return 0
end

function UseDrunkenBrawler()
--[[	if not DrunkenBrawler:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	if not bot:IsAlive() or not P.IsPDisabled(bot) then return 0 end
	
	if bot:GetActiveMode() == BOT_MODE_ATTACK then
		if DrunkenBrawlerStance ~= "Earth" then
			return BOT_ACTION_DESIRE_HIGH
		end
	elseif P.IsRetreating(bot) then
		if DrunkenBrawlerStance ~= "Storm" then
			return BOT_ACTION_DESIRE_HIGH
		end
	else
		if DrunkenBrawlerStance ~= "Fire" then
			return BOT_ACTION_DESIRE_HIGH
		end
	end]]--
	
	return 0
end

function UsePrimalSplit()
	if not PrimalSplit:IsFullyCastable() then return 0 end
	if not PAF.IsInTeamFight(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	return BOT_ACTION_DESIRE_HIGH
end

function UsePrimalCompanion()
	if not PrimalCompanion:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local allies = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE)
	
	for v, ally in pairs(allies) do
		if string.find(ally:GetUnitName(), "npc_dota_brewmaster_earth") then
			return 0
		end
	end
	
	return BOT_ACTION_DESIRE_HIGH
end