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

local Earthshock = bot:GetAbilityByName("ursa_earthshock")
local Overpower = bot:GetAbilityByName("ursa_overpower")
local FurySwipes = bot:GetAbilityByName("ursa_fury_swipes")
local Enrage = bot:GetAbilityByName("ursa_enrage")

local EarthshockDesire = 0
local OverpowerDesire = 0
local EnrageDesire = 0

local AttackRange
local BotTarget
local AttackTarget
local ManaThreshold

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	AttackTarget = bot:GetAttackTarget()
	ManaThreshold = 100
	
	for x = 5, 1, -1 do
		local hAbility = bot:GetAbilityInSlot(x)
		if hAbility ~= nil
		and hAbility:IsTrained()
		and not hAbility:IsHidden() then
			local nManaCost = hAbility:GetManaCost()
			
			if nManaCost > 0 then
				ManaThreshold = (ManaThreshold + nManaCost)
			end
		end
	end
	
	-- The order to use abilities in
	EnrageDesire = UseEnrage()
	if EnrageDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbility(Enrage)
		return
	end
	
	OverpowerDesire = UseOverpower()
	if OverpowerDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbility(Overpower)
		return
	end
	
	EarthshockDesire = UseEarthshock()
	if EarthshockDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbility(Earthshock)
		return
	end
end

function UseEarthshock()
	if not Earthshock:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = Earthshock:GetSpecialValueInt("hop_distance")
	local Radius = Earthshock:GetSpecialValueInt("shock_radius")
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if bot:IsFacingLocation(BotTarget:GetLocation(), 10)
			and GetUnitToUnitDistance(bot, BotTarget) < (CastRange + Radius) then
				return 1
			end
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_RETREAT then
		local EnemiesWithinRange = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
		local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
		
		if #FilteredEnemies > 0 then
			if bot:IsFacingLocation(PAF.GetFountainLocation(bot), 20) then
				return 1
			end
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		if PAF.IsRoshan(AttackTarget) then
			if bot:IsFacingLocation(AttackTarget:GetLocation(), 10)
			and GetUnitToUnitDistance(bot, AttackTarget) < (CastRange + Radius) then
				return 1
			end
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_SIDE_SHOP then
		if PAF.IsTormentor(AttackTarget) then
			if bot:IsFacingLocation(AttackTarget:GetLocation(), 10)
			and GetUnitToUnitDistance(bot, AttackTarget) < (CastRange + Radius) then
				return 1
			end
		end
	end
	
	return 0
end

function UseOverpower()
	if not Overpower:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	if bot:HasModifier("modifier_ursa_overpower") then return 0 end
	
	local ManaCost = Overpower:GetManaCost()
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= 1600 then
				return 1
			end
		end
	end
	
	if PAF.IsInCreepAttackingMode(bot) then
		if PAF.IsValidCreepTarget(AttackTarget) then
			if AttackTarget:GetTeam() ~= bot:GetTeam()
			and PAF.ShouldCastAbilityToFarm(bot, ManaCost, ManaThreshold, false) then
				if AttackTarget:IsCreep()
				or AttackTarget:IsBuilding() then
					return 1
				end
			end
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		if PAF.IsRoshan(AttackTarget) then
			return 1
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_SIDE_SHOP then
		if PAF.IsTormentor(AttackTarget) then
			return 1
		end
	end
	
	return 0
end

function UseEnrage()
	if not Enrage:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	if bot:GetHealth() <= (bot:GetMaxHealth() * 0.75)
	and WasRecentlyDamagedByAnyHero(1) then
		return 1
	end
	
	local projectiles = bot:GetIncomingTrackingProjectiles()
	
	for v, proj in pairs(projectiles) do
		if GetUnitToLocationDistance(bot, proj.location) <= 300
		and proj.is_attack == false
		and proj.caster ~= nil
		and proj.caster:GetTeam() ~= bot:GetTeam() then
			return 1
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		if PAF.IsRoshan(AttackTarget) then
			local RoshanTarget = AttackTarget:GetAttackTarget()
			
			if RoshanTarget == bot then
				return 1
			end
		end
	end
	
	return 0
end