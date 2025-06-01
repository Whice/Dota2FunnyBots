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
local AttackTarget
local ManaThreshold

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	AttackTarget = bot:GetAttackTarget()
	ManaThreshold = (100 + BladeFury:GetManaCost() + HealingWard:GetManaCost() + OmniSlash:GetManaCost())
	
	-- The order to use abilities in
	OmniSlashDesire, OmniSlashTarget = UseOmniSlash()
	if OmniSlashDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbilityOnEntity(OmniSlash, OmniSlashTarget)
		return
	end
	
	HealingWardDesire, HealingWardTarget = UseHealingWard()
	if HealingWardDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbilityOnLocation(HealingWard, HealingWardTarget)
		return
	end
	
	BladeFuryDesire = UseBladeFury()
	if BladeFuryDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbility(BladeFury)
		return
	end
end

function UseBladeFury()
	if not BladeFury:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = BladeFury:GetSpecialValueInt("blade_fury_radius")
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget) then
				return 1
			end
		end
	end
	
	if PAF.IsInTeamFight(bot) or bot:GetActiveMode() == BOT_MODE_RETREAT then
		local projectiles = bot:GetIncomingTrackingProjectiles()
		
		for v, proj in pairs(projectiles) do
			if GetUnitToLocationDistance(bot, proj.location) <= 300
			and proj.is_attack == false
			and proj.caster ~= nil
			and proj.caster:GetTeam() ~= bot:GetTeam() then
				return 1
			end
		end
		
		if bot:GetActiveMode() == BOT_MODE_RETREAT and bot:WasRecentlyDamagedByAnyHero(1) then
			return 1
		end
	end
	
	return 0
end

function UseHealingWard()
	if not HealingWard:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	if PAF.IsInTeamFight(bot) or bot:GetActiveMode() == BOT_MODE_RETREAT then
		return 1, bot:GetLocation()
	end
	
	if PAF.IsInCreepAttackingMode(bot) then
		if PAF.IsValidCreepTarget(AttackTarget) then
			if AttackTarget:GetTeam() ~= bot:GetTeam() then
				if bot:GetHealth() < (bot:GetMaxHealth() * 0.5) then
					return 1, bot:GetLocation()
				end
			end
		end
	end
	
	return 0
end

function UseOmniSlash()
	if not OmniSlash:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = OmniSlash:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	local Radius = OmniSlash:GetSpecialValueInt("omni_slash_radius")
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange then
				local EnemyHeroesNearTarget = BotTarget:GetNearbyHeroes(Radius, false, BOT_MODE_NONE)
				local EnemyCreepsNearTarget = BotTarget:GetNearbyCreeps(Radius, false)
				
				if #EnemyHeroesNearTarget <= 1
				and #EnemyCreepsNearTarget <= 0 then
					return 1, BotTarget
				end
			end
		end
	end
	
	return 0
end