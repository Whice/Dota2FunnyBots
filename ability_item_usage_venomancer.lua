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

local VenomousGale = bot:GetAbilityByName("venomancer_venomous_gale")
local PoisonSting = bot:GetAbilityByName("venomancer_poison_sting")
local PlagueWard = bot:GetAbilityByName("venomancer_plague_ward")
local NoxiousPlague = bot:GetAbilityByName("venomancer_noxious_plague")
local PoisonNova = bot:GetAbilityByName("venomancer_poison_nova")
local LatentToxicity = bot:GetAbilityByName("venomancer_latent_poison")

local VenomousGaleDesire = 0
local PlagueWardDesire = 0
local NoxiousPlagueDesire = 0
local LatentToxicityDesire = 0

local AttackRange
local BotTarget

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	-- The order to use abilities in
	NoxiousPlagueDesire, NoxiousPlagueTarget = UseNoxiousPlague()
	if NoxiousPlagueDesire > 0 then
		bot:Action_UseAbilityOnEntity(NoxiousPlague, NoxiousPlagueTarget)
		return
	end
	
	VenomousGaleDesire, VenomousGaleTarget = UseVenomousGale()
	if VenomousGaleDesire > 0 then
		bot:Action_UseAbilityOnLocation(VenomousGale, VenomousGaleTarget)
		return
	end
	
	LatentToxicityDesire, LatentToxicityTarget = UseLatentToxicity()
	if LatentToxicityDesire > 0 then
		bot:Action_UseAbilityOnEntity(LatentToxicity, LatentToxicityTarget)
		return
	end
	
	PlagueWardDesire, PlagueWardTarget = UsePlagueWard()
	if PlagueWardDesire > 0 then
		bot:Action_UseAbilityOnLocation(PlagueWard, PlagueWardTarget)
		return
	end
end

function UseVenomousGale()
	if not VenomousGale:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = VenomousGale:GetCastRange()
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
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		if PAF.IsRoshan(AttackTarget)
		and GetUnitToUnitDistance(bot, AttackTarget) <= CastRange then
			return BOT_ACTION_DESIRE_VERYHIGH, AttackTarget:GetLocation()
		end
	end
	
	return 0
end

function UsePlagueWard()
	if not PlagueWard:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = PlagueWard:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange then
				return BOT_ACTION_DESIRE_HIGH, BotTarget:GetLocation()
			end
		end
	end
	
	return 0
end

function UseNoxiousPlague()
	if not NoxiousPlague:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = NoxiousPlague:GetCastRange()
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

function UseLatentToxicity()
	if not LatentToxicity:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = LatentToxicity:GetCastRange()
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
		if PAF.IsRoshan(AttackTarget)
		and GetUnitToUnitDistance(bot, AttackTarget) <= CastRange then
			return BOT_ACTION_DESIRE_VERYHIGH, AttackTarget
		end
	end
	
	return 0
end