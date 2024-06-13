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

local SpiritLance = bot:GetAbilityByName("phantom_lancer_spirit_lance")
local DoppelGanger = bot:GetAbilityByName("phantom_lancer_doppelwalk")
local PhantomRush = bot:GetAbilityByName("phantom_lancer_phantom_edge")
local Juxtapose = bot:GetAbilityByName("phantom_lancer_juxtapose")

local SpiritLanceDesire = 0
local DoppelGangerDesire = 0

local AttackRange = 0

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	-- The order to use abilities in
	JuxtaposeDesire = UseJuxtapose()
	if JuxtaposeDesire > 0 then
		bot:Action_UseAbility(Juxtapose)
		return
	end
	
	PhantomRushDesire = UsePhantomRush()
	if PhantomRushDesire > 0 then
		bot:Action_UseAbility(PhantomRush)
		return
	end
	
	SpiritLanceDesire, SpiritLanceTarget = UseSpiritLance()
	if SpiritLanceDesire > 0 then
		bot:Action_UseAbilityOnEntity(SpiritLance, SpiritLanceTarget)
		return
	end
	
	DoppelGangerDesire, DoppelGangerTarget = UseDoppelGanger()
	if DoppelGangerDesire > 0 then
		bot:Action_UseAbilityOnLocation(DoppelGanger, DoppelGangerTarget)
		return
	end
end

function UseSpiritLance()
	if not SpiritLance:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = SpiritLance:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget) then
				return BOT_ACTION_DESIRE_HIGH, BotTarget
			end
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		local AttackTarget = bot:GetAttackTarget()
		
		if PAF.IsRoshan(AttackTarget)
		and GetUnitToUnitDistance(bot, AttackTarget) <= CastRange then
			return BOT_ACTION_DESIRE_VERYHIGH, AttackTarget
		end
	end
	
	return 0
end

function UseDoppelGanger()
	if not DoppelGanger:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = DoppelGanger:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	
	if P.IsRetreating(bot) then
		return BOT_ACTION_DESIRE_HIGH, bot:GetXUnitsTowardsLocation(PAF.GetFountainLocation(bot), CastRange)
	end
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange then
				return BOT_ACTION_DESIRE_HIGH, BotTarget:GetLocation()
			end
		end
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

function UsePhantomRush()
	if not PhantomRush:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end

	if PAF.IsEngaging(bot) then
		if PhantomRush:GetToggleState() == false and not SpiritLance:IsFullyCastable() and not DoppelGanger:IsFullyCastable() then
			return BOT_ACTION_DESIRE_HIGH
		else
			return 0
		end
	else
		if PhantomRush:GetToggleState() == true then
			return BOT_ACTION_DESIRE_HIGH
		else
			return 0
		end
	end
	
	return 0
end

function UseJuxtapose()
	if not Juxtapose:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	if Juxtapose:IsPassive() then return 0 end
	
	if P.IsRetreating(bot) then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	return 0
end