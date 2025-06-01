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

local Disruption = bot:GetAbilityByName("shadow_demon_disruption")
local Disseminate = bot:GetAbilityByName("shadow_demon_disseminate")
local ShadowPoison = bot:GetAbilityByName("shadow_demon_shadow_poison")
local DemonicPurge = bot:GetAbilityByName("shadow_demon_demonic_purge")
local DemonicCleanse = bot:GetAbilityByName("shadow_demon_demonic_cleanse")

local PoisonRelease = bot:GetAbilityByName("shadow_demon_shadow_poison_release")

local DisruptionDesire = 0
local DisseminateDesire = 0
local ShadowPoisonDesire = 0
local DemonicPurgeDesire = 0
local DemonicCleanseDesire = 0

local AttackRange
local BotTarget
local manathreshold = 0

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	manathreshold = ShadowPoison:GetManaCost()
	if Disruption:IsFullyCastable() then
		manathreshold = manathreshold + Disruption:GetManaCost()
	end
	if Disseminate:IsFullyCastable() then
		manathreshold = manathreshold + Disseminate:GetManaCost()
	end
	if DemonicPurge:IsFullyCastable() then
		manathreshold = manathreshold + DemonicPurge:GetManaCost()
	end
	if DemonicCleanse:IsFullyCastable() then
		manathreshold = manathreshold + DemonicCleanse:GetManaCost()
	end
	
	-- The order to use abilities in
	PoisonReleaseDesire = UsePoisonRelease()
	if PoisonReleaseDesire > 0 then
		bot:Action_UseAbility(PoisonRelease)
		return
	end
	
	DisruptionDesire, DisruptionTarget = UseDisruption()
	if DisruptionDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbilityOnEntity(Disruption, DisruptionTarget)
		return
	end
	
	DemonicPurgeDesire, DemonicPurgeTarget = UseDemonicPurge()
	if DemonicPurgeDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbilityOnEntity(DemonicPurge, DemonicPurgeTarget)
		return
	end
	
	DemonicCleanseDesire, DemonicCleanseTarget = UseDemonicCleanse()
	if DemonicCleanseDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbilityOnEntity(DemonicCleanse, DemonicCleanseTarget)
		return
	end
	
	DisseminateDesire, DisseminateTarget = UseDisseminate()
	if DisseminateDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbilityOnEntity(Disseminate, DisseminateTarget)
		return
	end
	
	ShadowPoisonDesire, ShadowPoisonTarget = UseShadowPoison()
	if ShadowPoisonDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbilityOnLocation(ShadowPoison, ShadowPoisonTarget)
		return
	end
end

function UseDisruption()
	if not Disruption:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = Disruption:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterUnitsForStun(EnemiesWithinRange)
	
	local AlliesWithinRange = bot:GetNearbyHeroes(CastRange, false, BOT_MODE_NONE)
	local FilteredAllies = PAF.FilterTrueUnits(AlliesWithinRange)
	
	local WeakestAlly = PAF.GetWeakestUnit(FilteredAllies)
	
	if WeakestAlly ~= nil then
		local EnemiesNearAlly = WeakestAlly:GetNearbyHeroes(1000, true, BOT_MODE_NONE)
		
		if WeakestAlly:GetHealth() <= (WeakestAlly:GetMaxHealth() * 0.3)
		and WeakestAlly:WasRecentlyDamagedByAnyHero(1)
		and #EnemiesNearAlly > 0 then
			return BOT_ACTION_DESIRE_HIGH, WeakestAlly
		end
	end
	
	if P.IsRetreating(bot) and #EnemiesWithinRange > 0 then
		local ClosestTarget = PAF.GetClosestUnit(bot, EnemiesWithinRange)
		return BOT_ACTION_DESIRE_HIGH, ClosestTarget
	end
	
	for v, enemy in pairs(FilteredEnemies) do
		if enemy:IsChanneling() then
			return BOT_ACTION_DESIRE_HIGH, enemy
		end
	end
	
	if PAF.IsInTeamFight(bot) then
		local EnemiesWithinTeamFightRange = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
		local FilteredEnemiesTF = PAF.FilterUnitsForStun(EnemiesWithinTeamFightRange)
		
		if #FilteredEnemiesTF > 1 then
			local StrongestEnemy = PAF.GetStrongestPowerUnit(FilteredEnemiesTF)
			if StrongestEnemy ~= nil then
				return BOT_ACTION_DESIRE_HIGH, StrongestEnemy
			end
		end
	end
	
	return 0
end

function UseDisseminate()
	if not Disseminate:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = Disseminate:GetCastRange()
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

function UseShadowPoison()
	if not ShadowPoison:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = ShadowPoison:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget) then
				return BOT_ACTION_DESIRE_HIGH, BotTarget:GetLocation()
			end
		end
	end
	
	local EnemyHeroes = GetUnitList(UNIT_LIST_ENEMY_HEROES)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemyHeroes)
	
	for v, Enemy in pairs(FilteredEnemies) do
		if PAF.IsValidHeroTarget(Enemy) then
			if GetUnitToUnitDistance(bot, Enemy) <= CastRange then
				if Enemy:HasModifier("modifier_clarity_potion") or Enemy:HasModifier("modifier_flask_healing") then
					return BOT_ACTION_DESIRE_HIGH, Enemy:GetLocation()
				end
			end
		end
	end
	
	return 0
end

function UseDemonicPurge()
	if not DemonicPurge:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = DemonicPurge:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local enemies = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local filteredenemies = {}
	
	for v, enemy in pairs(enemies) do
		if not enemy:HasModifier("modifier_shadow_demon_purge_slow") and PAF.IsValidHeroAndNotIllusion(enemy) then
			table.insert(filteredenemies, enemy)
		end
	end
	
	local target = PAF.GetWeakestUnit(filteredenemies)
	
	if target ~= nil and PAF.IsEngaging(bot) then
		return BOT_ACTION_DESIRE_HIGH, target
	end
	
	return 0
end

function UseDemonicCleanse()
	if not DemonicCleanse:IsFullyCastable() then return 0 end
	if DemonicCleanse:IsHidden() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = DemonicCleanse:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local AlliesWithinRange = bot:GetNearbyHeroes(CastRange, false, BOT_MODE_NONE)
	local FilteredAllies = PAF.FilterTrueUnits(AlliesWithinRange)
	
	local WeakestAlly = PAF.GetWeakestUnit(FilteredAllies)
	
	if WeakestAlly ~= nil then
		if WeakestAlly:GetHealth() < (WeakestAlly:GetMaxHealth() * 0.65)
		and WeakestAlly:WasRecentlyDamagedByAnyHero(1)
		and not WeakestAlly:HasModifier("modifier_shadow_demon_purge_slow") then
			return BOT_ACTION_DESIRE_HIGH, WeakestAlly
		end
	end
	
	if PAF.IsInTeamFight(bot) then
		for v, Ally in pairs(FilteredAllies) do
			if PAF.IsDisabled(Ally)
			or PAF.IsTaunted(Ally)
			or PAF.IsSilencedOrMuted(Ally) then
				return BOT_ACTION_DESIRE_HIGH, Ally
			end
		end
	end
	
	return 0
end

function UsePoisonRelease()
	if not PoisonRelease:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local EnemyHeroes = GetUnitList(UNIT_LIST_ENEMY_HEROES)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemyHeroes)
	
	local StackDamage = ShadowPoison:GetSpecialValueInt("stack_damage")
	local MaxStacks = ShadowPoison:GetSpecialValueInt("max_multiply_stacks")
	local BonusStackDamage = ShadowPoison:GetSpecialValueInt("bonus_stack_damage")
	
	for v, Enemy in pairs(FilteredEnemies) do
		if PAF.IsValidHeroTarget(Enemy) then
			if Enemy:HasModifier("modifier_shadow_demon_shadow_poison") then
				local modifier = Enemy:GetModifierByName("modifier_shadow_demon_shadow_poison")
				local PoisonStacks = Enemy:GetModifierStackCount(modifier)
				
				local TotalDamage = 0
				local StackMultiplier = 0
				
				if PoisonStacks == 1 then
					StackMultiplier = 1
				elseif PoisonStacks == 2 then
					StackMultiplier = 2
				elseif PoisonStacks == 3 then
					StackMultiplier = 4
				elseif PoisonStacks == 4 then
					StackMultiplier = 8
				elseif PoisonStacks >= MaxStacks then
					StackMultiplier = 16
				end
				
				TotalDamage = (TotalDamage + (StackDamage * StackMultiplier))
				
				local ExtraStacks = 0
				if PoisonStacks > MaxStacks then
					ExtraStacks = (PoisonStacks - MaxStacks)
				end
				
				local ExtraStackDamage = (ExtraStacks * BonusStackDamage)
				
				TotalDamage = (TotalDamage + ExtraStackDamage)
				
				local ActualDamage = Enemy:GetActualIncomingDamage(TotalDamage, DAMAGE_TYPE_MAGICAL)
				if ActualDamage >= Enemy:GetHealth() then
					return BOT_ACTION_DESIRE_HIGH
				end
			end
		end
	end
	
	return 0
end