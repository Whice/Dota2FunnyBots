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
	ConsumeDesire = UseConsume()
	if ConsumeDesire > 0 then
		bot:Action_UseAbility(Consume)
		return
	end
	
	InfestDesire, InfestTarget = UseInfest()
	if InfestDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbilityOnEntity(Infest, InfestTarget)
		return
	end
	
	RageDesire = UseRage()
	if RageDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbility(Rage)
		return
	end
	
	OpenWoundsDesire, OpenWoundsTarget = UseOpenWounds()
	if OpenWoundsDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbilityOnEntity(OpenWounds, OpenWoundsTarget)
		return
	end
end

function UseRage()
	if not Rage:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	if Rage:IsHidden() then return 0 end
	
	local projectiles = bot:GetIncomingTrackingProjectiles()
	
	for v, proj in pairs(projectiles) do
		if GetUnitToLocationDistance(bot, proj.location) <= 300
		and proj.is_attack == false
		and proj.caster ~= nil
		and proj.caster:GetTeam() ~= bot:GetTeam() then
			return 1
		end
	end
	
	if PAF.IsInTeamFight(bot) or bot:GetActiveMode() == BOT_MODE_RETREAT then
		if bot:WasRecentlyDamagedByAnyHero(1) then
			return 1
		end
	end
	
	return 0
end

function UseInfest()
	if not Infest:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	if Infest:IsHidden() then return 0 end
	
	if bot:HasScepter() then
		local MaxHPRegenRate = ((Infest:GetSpecialValueInt("self_regen") * 2) / 100)
		local EnemyDuration = Infest:GetSpecialValueInt("infest_duration_enemy")
		local RegenPerSecond = (bot:GetMaxHealth() * MaxHPRegenRate)
		local TotalRegen = (RegenPerSecond * EnemyDuration)
		
		if bot:GetHealth() <= (bot:GetMaxHealth() - TotalRegen) then
			if PAF.IsEngaging(bot) then
				if PAF.IsValidHeroAndNotIllusion(BotTarget) then
					return 1, BotTarget
				end
			else
				local EnemiesWithinRange = PAF.GetNearbyFilteredHeroes(bot, 1200, true, BOT_MODE_NONE)
				
				local WeakestEnemy = PAF.GetHealthiestUnit(EnemiesWithinRange)
				if WeakestEnemy ~= nil
				and PAF.IsValidHeroAndNotIllusion(WeakestEnemy) then
					return 1, BotTarget
				end
			end
		end
	end
	
	if bot:GetHealth() <= (bot:GetMaxHealth() * 0.25) then
		local AlliesWithinRange = PAF.GetNearbyFilteredHeroes(bot, 1200, false, BOT_MODE_NONE)
		local FilteredAllies = PAF.FilterExceptedUnit(AlliesWithinRange, bot)
		local ClosestAlly = PAF.GetClosestUnit(bot, FilteredAllies)
		
		if ClosestAlly ~= nil then
			return 1, ClosestAlly
		end
	end
	
	return 0
end

function UseConsume()
	if Consume:IsHidden() then return 0 end
	
	if bot:GetHealth() >= (bot:GetMaxHealth() * 0.95) then
		return 1
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
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget)
			and not PAF.IsReflectingSpells(BotTarget) then
				return 1, BotTarget
			end
		end
	end
	
	return 0
end