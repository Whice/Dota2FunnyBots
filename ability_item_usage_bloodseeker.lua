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

local Bloodrage = bot:GetAbilityByName("bloodseeker_bloodrage")
local BloodBath = bot:GetAbilityByName("bloodseeker_blood_bath")
local Thirst = bot:GetAbilityByName("bloodseeker_thirst")
local Rupture = bot:GetAbilityByName("bloodseeker_rupture")
--local BloodMist = bot:GetAbilityByName("bloodseeker_blood_mist")

local BloodrageDesire = 0
local BloodBathDesire = 0
local RuptureDesire = 0
--local BloodMistDesire = 0

local AttackRange
local BotTarget
local AttackTarget
local ManaThreshold

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	AttackTarget = bot:GetAttackTarget()
	ManaThreshold = (100 + BloodBath:GetManaCost() + Rupture:GetManaCost())
	
	-- The order to use abilities in
	RuptureDesire, RuptureTarget = UseRupture()
	if RuptureDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbilityOnEntity(Rupture, RuptureTarget)
		return
	end
	
	BloodBathDesire, BloodBathTarget = UseBloodBath()
	if BloodBathDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbilityOnLocation(BloodBath, BloodBathTarget)
		return
	end
	
	BloodrageDesire, BloodrageTarget = UseBloodrage()
	if BloodrageDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbilityOnEntity(Bloodrage, BloodrageTarget)
		return
	end
end

function UseBloodrage()
	if not Bloodrage:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			return 1, bot
		end
	end
	
	if PAF.IsInCreepAttackingMode(bot) then
		if PAF.IsValidCreepTarget(AttackTarget) then
			if AttackTarget:GetTeam() ~= bot:GetTeam() then
				return 1, bot
			end
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		if PAF.IsRoshan(AttackTarget) then
			return 1, bot
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_SIDE_SHOP then
		if PAF.IsTormentor(AttackTarget) then
			return 1, bot
		end
	end
	
	return 0
end

function UseBloodBath()
	if not BloodBath:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = BloodBath:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	local Radius = BloodBath:GetSpecialValueInt("radius")
	local ManaCost = BloodBath:GetManaCost()
	local CastPoint = BloodBath:GetCastPoint()
	local Delay = BloodBath:GetSpecialValueInt("delay")
	local ExtrapolateTime = (CastPoint + Delay)
	
	local EnemiesWithinCastRange = PAF.GetNearbyFilteredHeroes(bot, CastRange, true, BOT_MODE_NONE)
	
	for x, Enemy in pairs(EnemiesWithinCastRange) do
		if Enemy:HasModifier("modifier_bloodseeker_rupture") then
			return 1, Enemy:GetLocation()
		end
	end
	
	if PAF.IsInTeamFight(bot) then
		local AoELocation = bot:FindAoELocation(true, true, bot:GetLocation(), CastRange, Radius, ExtrapolateTime, 0)
		
		if AoELocation.count >= 2 then
			return 1, AoELocation.targetloc
		end
	elseif PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget) then
				local ExtrapolatedLocation = BotTarget:GetExtrapolatedLocation(ExtrapolateTime)
				
				if GetUnitToLocationDistance(bot, ExtrapolatedLocation) <= CastRange then
					return 1, ExtrapolatedLocation
				end
			end
		end
	end
	
	if PAF.IsInCreepAttackingMode(bot) then
		if PAF.IsValidCreepTarget(AttackTarget) then
			if AttackTarget:GetTeam() ~= bot:GetTeam()
			and PAF.ShouldCastAbilityToFarm(bot, ManaCost, ManaThreshold, false) then
				local AoELocation = bot:FindAoELocation(true, false, bot:GetLocation(), CastRange, Radius, 0, 0)
				
				if AoELocation.count >= 3 then
					return 1, AoELocation.targetloc
				end
			end
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		if PAF.IsRoshan(AttackTarget) then
			return 1, AttackTarget:GetLocation()
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_SIDE_SHOP then
		if PAF.IsTormentor(AttackTarget) then
			return 1, AttackTarget:GetLocation()
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_RETREAT then
		local EnemiesWithinRange = PAF.GetNearbyFilteredHeroes(bot, 1200, true, BOT_MODE_NONE)
		
		if #EnemiesWithinRange > 0 then
			return 1, bot:GetLocation()
		end
	end
	
	return 0
end

function UseThirst()
	if not Thirst:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	if PAF.IsInTeamFight(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= 1200 then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end
	
	return 0
end

function UseRupture()
	if not Rupture:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = Rupture:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange then
				if not BotTarget:HasModifier("modifier_bloodseeker_rupture") then
					return 1, BotTarget
				else
					local EnemiesWithinRange = PAF.GetNearbyFilteredHeroes(bot, 1600, true, BOT_MODE_NONE)
					local ViableRuptureTargets = {}
					
					for x, Enemy in pairs(EnemiesWithinCastRange) do
						if not Enemy:HasModifier("modifier_bloodseeker_rupture") then
							table.insert(ViableRuptureTargets, Enemy)
						end
					end
					
					local StrongestEnemy = PAF.GetStrongestPowerUnit(ViableRuptureTargets)
					
					if GetUnitToUnitDistance(bot, StrongestEnemy) <= CastRange then
						return 1, StrongestEnemy
					end
				end
			end
		end
	end
	
	return 0
end

function UseBloodMist()
	if not BloodMist:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end

	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= 1200 then
				if BloodMist:GetToggleState() == false then
					return BOT_ACTION_DESIRE_HIGH
				else
					return 0
				end
			end
		end
	end
	
	if BloodMist:GetToggleState() == true then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	return 0
end