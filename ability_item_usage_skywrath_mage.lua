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

local ArcaneBolt = bot:GetAbilityByName("skywrath_mage_arcane_bolt")
local ConcussiveShot = bot:GetAbilityByName("skywrath_mage_concussive_shot")
local AncientSeal = bot:GetAbilityByName("skywrath_mage_ancient_seal")
local MysticFlare = bot:GetAbilityByName("skywrath_mage_mystic_flare")

local ArcaneBoltDesire = 0
local ConcussiveShotDesire = 0
local AncientSealDesire = 0
local MysticFlareSealDesire = 0

local AttackRange
local BotTarget

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()

	-- The order to use abilities in	
	ArcaneBoltDesire, ArcaneBoltTarget = UseArcaneBolt()
	if ArcaneBoltDesire > 0 then
		bot:Action_UseAbilityOnEntity(ArcaneBolt, ArcaneBoltTarget)
		return
	end
	
	AncientSealDesire, AncientSealTarget = UseAncientSeal()
	if AncientSealDesire > 0 then
		bot:Action_UseAbilityOnEntity(AncientSeal, AncientSealTarget)
		return
	end
	
	ConcussiveShotDesire = UseConcussiveShot()
	if ConcussiveShotDesire > 0 then
		bot:Action_UseAbility(ConcussiveShot)
		return
	end
	
	MysticFlareDesire, MysticFlareTarget = UseMysticFlare()
	if MysticFlareDesire > 0 then
		bot:Action_UseAbilityOnLocation(MysticFlare, MysticFlareTarget)
		return
	end
end

function UseArcaneBolt()
	if not ArcaneBolt:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = ArcaneBolt:GetCastRange()
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
	
	if AttackTarget ~= nil then
		if bot:GetActiveMode() == BOT_MODE_ROSHAN and PAF.IsRoshan(AttackTarget) then
			return BOT_ACTION_DESIRE_HIGH, AttackTarget
		end
	end
	
	return 0
end

function UseConcussiveShot()
	if not ConcussiveShot:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = ConcussiveShot:GetCastRange()
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	
	if PAF.IsEngaging(bot) or P.IsRetreating(bot) then
		if #FilteredEnemies > 0 then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	return 0
end
function UseAncientSeal()
	if not AncientSeal:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = AncientSeal:GetCastRange()
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
	
	if AttackTarget ~= nil then
		if bot:GetActiveMode() == BOT_MODE_ROSHAN and PAF.IsRoshan(AttackTarget) then
			return BOT_ACTION_DESIRE_HIGH, AttackTarget
		end
	end
	
	return 0
end

function UseMysticFlare()
	if not MysticFlare:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = MysticFlare:GetCastRange()
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