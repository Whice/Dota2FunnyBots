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

local Rage = bot:GetAbilityByName("life_stealer_rage")
local Feast = bot:GetAbilityByName("life_stealer_feast")
local GhoulFrenzy = bot:GetAbilityByName("life_stealer_ghoul_frenzy")
local Infest = bot:GetAbilityByName("life_stealer_infest")
local Consume = bot:GetAbilityByName("life_stealer_consume")
local OpenWounds = bot:GetAbilityByName("life_stealer_open_wounds")

local RageDesire = 0
local InfestDire = 0
local ConsumeDesire = 0

local AttackRange
local BotTarget

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	-- The order to use abilities in
	ConsumeDesire = UseConsume()
	if ConsumeDesire > 0 then
		bot:Action_UseAbility(Consume)
		return
	end
	
	InfestDesire, InfestTarget = UseInfest()
	if InfestDesire > 0 then
		bot:Action_UseAbilityOnEntity(Infest, InfestTarget)
		return
	end
	
	RageDesire = UseRage()
	if RageDesire > 0 then
		bot:Action_UseAbility(Rage)
		return
	end
	
	OpenWoundsDesire, OpenWoundsTarget = UseOpenWounds()
	if OpenWoundsDesire > 0 then
		bot:Action_UseAbilityOnEntity(OpenWounds, OpenWoundsTarget)
		return
	end
end

function UseRage()
	if not Rage:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	if Rage:IsHidden() then return 0 end
	
	if PAF.IsInTeamFight(bot) then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	local projectiles = bot:GetIncomingTrackingProjectiles()
	
	for v, proj in pairs(projectiles) do
		if GetUnitToLocationDistance(bot, proj.location) <= 300 and proj.is_attack == false then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	local enemies = bot:GetNearbyHeroes(800, true, BOT_MODE_NONE)
	
	if P.IsRetreating(bot) and #enemies >= 1 then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	return 0
end

function UseInfest()
	if not Infest:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	if Infest:IsHidden() then return 0 end
	
	local allies = bot:GetNearbyHeroes(800, false, BOT_MODE_NONE)
	local trueallies = {}
	
	for v, ally in pairs(allies) do
		if not ally:IsIllusion() and ally ~= bot then
			table.insert(trueallies, ally)
		end
	end
	
	if #trueallies >= 1 then
		local closestally = nil
		local closestdistance = 99999
		
		for v, ally in pairs(trueallies) do
			if GetUnitToUnitDistance(bot, ally) < closestdistance then
				closestally = ally
				closestdistance = GetUnitToUnitDistance(bot, ally)
			end
		end
		
		local enemies = bot:GetNearbyHeroes(800, true, BOT_MODE_NONE)
		
		if closestally ~= nil and bot:GetHealth() < (bot:GetMaxHealth() * 0.3) and #enemies >= 1 then
			return BOT_ACTION_DESIRE_HIGH, closestally
		end
	end
	
	return 0
end

function UseConsume()
	if Consume:IsHidden() then return 0 end
	
	if bot:GetHealth() >= (bot:GetMaxHealth() * 0.8) then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	return 0
end

function UseOpenWounds()
	if not OpenWounds:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	if OpenWounds:IsHidden() then return 0 end
	
	local CR = OpenWounds:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange then
				return BOT_ACTION_DESIRE_HIGH, BotTarget
			end
		end
	end
	
	return 0
end