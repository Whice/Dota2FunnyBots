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

local BladeFury = bot:GetAbilityByName("juggernaut_blade_fury")
local HealingWard = bot:GetAbilityByName("juggernaut_healing_ward")
local BladeDance = bot:GetAbilityByName("juggernaut_blade_dance")
local OmniSlash = bot:GetAbilityByName("juggernaut_omni_slash")

local BladeFuryDesire = 0
local HealingWardDesire = 0
local OmniSlashDesire = 0

local AttackRange
local BotTarget

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	-- The order to use abilities in
	OmniSlashDesire, OmniSlashTarget = UseOmniSlash()
	if OmniSlashDesire > 0 then
		bot:Action_UseAbilityOnEntity(OmniSlash, OmniSlashTarget)
		return
	end
	
	HealingWardDesire, HealingWardTarget = UseHealingWard()
	if HealingWardDesire > 0 then
		bot:Action_UseAbilityOnLocation(HealingWard, HealingWardTarget)
		return
	end
	
	BladeFuryDesire = UseBladeFury()
	if BladeFuryDesire > 0 then
		bot:Action_UseAbility(BladeFury)
		return
	end
end

function UseBladeFury()
	if not BladeFury:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = (AttackRange + 50)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end
	
	local initenemies = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
	local enemies = PAF.FilterTrueUnits(initenemies)
	
	if P.IsRetreating(bot) and #enemies > 0 then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	return 0
end

function UseHealingWard()
	if not HealingWard:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = HealingWard:GetCastRange()
	
	if PAF.IsInTeamFight(bot) or (bot:GetHealth() <= (bot:GetMaxHealth() * 0.5)) then
		return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()
	end
	
	return 0
end

function UseOmniSlash()
	if not OmniSlash:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = OmniSlash:GetCastRange()
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