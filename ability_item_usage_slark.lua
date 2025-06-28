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

local DarkPact = bot:GetAbilityByName("slark_dark_pact")
local Pounce = bot:GetAbilityByName("slark_pounce")
local EssenceShift = bot:GetAbilityByName("slark_essence_shift")
local DepthShroud = bot:GetAbilityByName("slark_depth_shroud")
local ShadowDance = bot:GetAbilityByName("slark_shadow_dance")

local Barracuda = bot:GetAbilityByName("slark_barracuda") -- Innate Ability

local DarkPactDesire = 0
local PounceDesire = 0
local DepthShroudDesire = 0
local ShadowDanceDesire = 0

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
	ShadowDanceDesire = UseShadowDance()
	if ShadowDanceDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbility(ShadowDance)
		return
	end
	
	DepthShroudDesire, DepthShroudTarget = UseDepthShroud()
	if DepthShroudDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbilityOnLocation(DepthShroud, DepthShroudTarget)
		return
	end
	
	PounceDesire = UsePounce()
	if PounceDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbility(Pounce)
		return
	end
	
	DarkPactDesire = UseDarkPact()
	if DarkPactDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbility(DarkPact)
		return
	end
end

function UseDarkPact()
	if not DarkPact:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local Radius = DarkPact:GetSpecialValueInt("radius")
	local ManaCost = DarkPact:GetManaCost()
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= Radius
			and not PAF.IsMagicImmune(BotTarget) then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end
	
	if PAF.IsInCreepAttackingMode(bot) then
		if PAF.IsValidCreepTarget(AttackTarget) then
			if AttackTarget:GetTeam() ~= bot:GetTeam()
			and PAF.ShouldCastAbilityToFarm(bot, ManaCost, ManaThreshold, false) then
				local CreepsWithinCastRange = bot:GetNearbyCreeps(Radius, true)
				
				if #CreepsWithinCastRange >= 2 then
					return 1
				end
			end
		end
	end
	
	if bot:IsDisarmed()
	or bot:IsRooted()
	or bot:IsBlind()
	or (bot:GetCurrentMovementSpeed() <= 300 and not P.IsInLaningPhase()) then
		return 1
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

function UsePounce()
	if not Pounce:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = Pounce:GetSpecialValueInt("pounce_distance")
	local Radius = Pounce:GetSpecialValueInt("leash_radius")
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if bot:IsFacingLocation(BotTarget:GetLocation(), 10)
			and GetUnitToUnitDistance(bot, BotTarget) < CastRange then
				return 1
			end
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_RETREAT then
		local EnemiesWithinRange = PAF.GetNearbyFilteredHeroes(bot, CastRange, true, BOT_MODE_NONE)
		
		if #EnemiesWithinRange > 0 then
			if bot:IsFacingLocation(PAF.GetFountainLocation(bot), 20) then
				return 1
			end
		end
	end
	
	return 0
end

function UseShadowDance()
	if not ShadowDance:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local RegenPerSecond = (Barracuda:GetSpecialValueInt("bonus_regen") + bot:GetHealthRegen())
	local Duration = ShadowDance:GetSpecialValueInt("duration")
	local TotalHeals = (RegenPerSecond + Duration)
	
	if bot:GetActiveMode() == BOT_MODE_RETREAT
	and bot:GetHealth() <= (bot:GetMaxHealth() - TotalHeals) then
		return 1
	end
	
	return 0
end
function UseDepthShroud()
	if not DepthShroud:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = DepthShroud:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local AlliesWithinRange = PAF.GetNearbyFilteredHeroes(bot, CastRange, false, BOT_MODE_NONE)
	
	for v, Ally in pairs(AlliesWithinRange) do
		if Ally:GetHealth() <= (Ally:GetMaxHealth() * 0.4) and Ally:WasRecentlyDamagedByAnyHero(2) then
			return 1, Ally:GetLocation()
		end
	end
	
	return 0
end