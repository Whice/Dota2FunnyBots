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

local Impale = bot:GetAbilityByName("nyx_assassin_impale")
local MindFlare = bot:GetAbilityByName("nyx_assassin_jolt")
local SpikedCarapace = bot:GetAbilityByName("nyx_assassin_spiked_carapace")
local Vendetta = bot:GetAbilityByName("nyx_assassin_vendetta")

local ImpaleDesire = 0
local ManaBurnDesire = 0
local SpikedCarapaceDesire = 0
local VendettaDesire = 0

local AttackRange
local BotTarget

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	-- The order to use abilities in
	ImpaleDesire, ImpaleTarget = UseImpale()
	if ImpaleDesire > 0 then
		bot:Action_UseAbilityOnLocation(Impale, ImpaleTarget)
		return
	end
	
	MindFlareDesire, MindFlareTarget = UseMindFlare()
	if MindFlareDesire > 0 then
		bot:Action_UseAbilityOnEntity(MindFlare, MindFlareTarget)
		return
	end
	
	SpikedCarapaceDesire = UseSpikedCarapace()
	if SpikedCarapaceDesire > 0 then
		bot:Action_UseAbility(SpikedCarapace)
		return
	end
	
	VendettaDesire, VendettaTarget = UseVendetta()
	if VendettaDesire > 0 then
		bot:Action_UseAbility(Vendetta)
		return
	end
end

function UseImpale()
	if not Impale:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	if bot:HasModifier("modifier_nyx_assassin_vendetta") then return 0 end
	
	local CR = Impale:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterUnitsForStun(EnemiesWithinRange)
	
	for v, enemy in pairs(FilteredEnemies) do
		if enemy:IsChanneling() then
			return BOT_ACTION_DESIRE_HIGH, enemy:GetExtrapolatedLocation(1)
		end
	end
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget) then
				if GetUnitToLocationDistance(bot, BotTarget:GetExtrapolatedLocation(1)) > CastRange then
					return BOT_ACTION_DESIRE_HIGH, bot:GetXUnitsTowardsLocation(BotTarget:GetExtrapolatedLocation(1), CastRange)
				else
					return BOT_ACTION_DESIRE_HIGH, BotTarget:GetExtrapolatedLocation(1)
				end
			end
		end
	end
	
	if P.IsRetreating(bot) and #EnemiesWithinRange > 0 then
		local ClosestTarget = PAF.GetClosestUnit(bot, EnemiesWithinRange)
		return BOT_ACTION_DESIRE_HIGH, ClosestTarget:GetLocation()
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		local AttackTarget = bot:GetAttackTarget()
		
		if PAF.IsRoshan(AttackTarget)
		and GetUnitToUnitDistance(bot, AttackTarget) <= CastRange then
			return BOT_ACTION_DESIRE_VERYHIGH, AttackTarget:GetLocation()
		end
	end
	
	return 0
end

function UseMindFlare()
	if not MindFlare:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	if bot:HasModifier("modifier_nyx_assassin_vendetta") then return 0 end
	
	local CR = MindFlare:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget) then
				return BOT_ACTION_DESIRE_HIGH, BotTarget
			end
		end
	end
	
	return 0
end

function UseSpikedCarapace()
	if not SpikedCarapace:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	if bot:HasModifier("modifier_nyx_assassin_vendetta") then return 0 end
	
	local projectiles = bot:GetIncomingTrackingProjectiles()
	
	for v, proj in pairs(projectiles) do
		if GetUnitToLocationDistance(bot, proj.location) <= 300 then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	if bot:WasRecentlyDamagedByAnyHero(1) then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	return 0
end

function UseVendetta()
	if not Vendetta:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	if PAF.IsEngaging(bot) and not SpikedCarapace:IsFullyCastable() and not MindFlare:IsFullyCastable() and not Impale:IsFullyCastable() then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	if P.IsRetreating(bot) then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	return 0
end