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
	DisruptionDesire, DisruptionTarget = UseDisruption()
	if DisruptionDesire > 0 then
		bot:Action_UseAbilityOnEntity(Disruption, DisruptionTarget)
		return
	end
	
	DemonicPurgeDesire, DemonicPurgeTarget = UseDemonicPurge()
	if DemonicPurgeDesire > 0 then
		bot:Action_UseAbilityOnEntity(DemonicPurge, DemonicPurgeTarget)
		return
	end
	
	DemonicCleanseDesire, DemonicCleanseTarget = UseDemonicCleanse()
	if DemonicCleanseDesire > 0 then
		bot:Action_UseAbilityOnEntity(DemonicCleanse, DemonicCleanseTarget)
		return
	end
	
	DisseminateDesire, DisseminateTarget = UseDisseminate()
	if DisseminateDesire > 0 then
		bot:Action_UseAbilityOnEntity(Disseminate, DisseminateTarget)
		return
	end
	
	ShadowPoisonDesire, ShadowPoisonTarget = UseShadowPoison()
	if ShadowPoisonDesire > 0 then
		bot:Action_UseAbilityOnLocation(ShadowPoison, ShadowPoisonTarget)
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
	local FilteredAllies = PAF.FilterUnitsForStun(AlliesWithinRange)
	
	if PAF.IsInTeamFight(bot) then
		for v, Ally in pairs(FilteredAllies) do
			if Ally:GetHealth() < (Ally:GetMaxHealth() * 0.3) then
				return BOT_ACTION_DESIRE_HIGH, Ally
			end
		end
	end
	
	for v, enemy in pairs(FilteredEnemies) do
		if enemy:IsChanneling() then
			return BOT_ACTION_DESIRE_HIGH, enemy
		end
	end
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange then
				return BOT_ACTION_DESIRE_HIGH, BotTarget
			end
		end
	end
	
	if P.IsRetreating(bot) and #EnemiesWithinRange > 0 then
		local ClosestTarget = PAF.GetClosestUnit(bot, EnemiesWithinRange)
		return BOT_ACTION_DESIRE_HIGH, ClosestTarget
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