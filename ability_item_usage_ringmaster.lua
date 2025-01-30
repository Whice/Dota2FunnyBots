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

local TameTheBeasts = bot:GetAbilityByName("ringmaster_tame_the_beasts")
local EscapeAct = bot:GetAbilityByName("ringmaster_the_box")
local ImpalementArts = bot:GetAbilityByName("ringmaster_impalement")
local WheelOfWonder = bot:GetAbilityByName("ringmaster_wheel")
local Spotlight = bot:GetAbilityByName("ringmaster_spotlight")

-- Souvenirs
local FunhouseMirror = bot:GetAbilityByName("ringmaster_funhouse_mirror")
local StrongmanTonic = bot:GetAbilityByName("ringmaster_strongman_tonic")
local WhoopeeCushion = bot:GetAbilityByName("ringmaster_whoopee_cushion")

local TameTheBeastsDesire = 0
local EscapeActDesire = 0
local ImpalementArtsDesire = 0
local WheelOfWonderDesire = 0
local SpotlightDesire = 0

local FunhouseMirrorDesire = 0
local StrongmanTonicDesire = 0
local WhoopeeCushionDesire = 0

local AttackRange
local BotTarget

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	local DarkSouvenir = bot:GetAbilityInSlot(3)
	
	-- The order to use abilities in
	EscapeActDesire, EscapeActTarget = UseEscapeAct()
	if EscapeActDesire > 0 then
		bot:Action_UseAbilityOnEntity(EscapeAct, EscapeActTarget)
		return
	end
	
	WheelOfWonderDesire, WheelOfWonderTarget = UseWheelOfWonder()
	if WheelOfWonderDesire > 0 then
		bot:Action_UseAbilityOnLocation(WheelOfWonder, WheelOfWonderTarget)
		return
	end
	
	SpotlightDesire, SpotlightTarget = UseSpotlight()
	if SpotlightDesire > 0 then
		bot:Action_UseAbilityOnLocation(Spotlight, SpotlightTarget)
		return
	end
	
	if DarkSouvenir == StrongmanTonic then
		StrongmanTonicDesire, StrongmanTonicTarget = UseStrongmanTonic()
		if StrongmanTonicDesire > 0 then
			bot:Action_UseAbilityOnEntity(StrongmanTonic, StrongmanTonicTarget)
			return
		end
	end
	
	ImpalementArtsDesire, ImpalementArtsTarget = UseImpalementArts()
	if ImpalementArtsDesire > 0 then
		bot:Action_UseAbilityOnLocation(ImpalementArts, ImpalementArtsTarget)
		return
	end
	
	if DarkSouvenir == FunhouseMirror then
		FunhouseMirrorDesire = UseFunhouseMirror()
		if FunhouseMirrorDesire > 0 then
			bot:Action_UseAbility(FunhouseMirror)
			return
		end
	end
	
	TameTheBeastsDesire, TameTheBeastsTarget = UseTameTheBeasts()
	if TameTheBeastsDesire > 0 then
		bot:Action_UseAbilityOnLocation(TameTheBeasts, TameTheBeastsTarget)
		return
	end
	
	if DarkSouvenir == WhoopeeCushion then
		WhoopeeCushionDesire = UseWhoopeeCushion()
		if WhoopeeCushionDesire > 0 then
			bot:Action_UseAbility(WhoopeeCushion)
			return
		end
	end
end

function UseTameTheBeasts()
	if not TameTheBeasts:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = TameTheBeasts:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterUnitsForStun(EnemiesWithinRange)
	
	for v, enemy in pairs(FilteredEnemies) do
		if enemy:IsChanneling() then
			return BOT_ACTION_DESIRE_HIGH, enemy
		end
	end
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget)
			and PAF.IsDisabled(BotTarget) or BotTarget:GetCurrentMovementSpeed() <= 300 then
				return BOT_ACTION_DESIRE_HIGH, BotTarget:GetLocation()
			end
		end
	end
	
	if P.IsRetreating(bot) and #EnemiesWithinRange > 0 then
		local ClosestTarget = PAF.GetClosestUnit(bot, EnemiesWithinRange)
		return BOT_ACTION_DESIRE_HIGH, ClosestTarget:GetLocation()
	end
	
	return 0
end

function UseEscapeAct()
	if not EscapeAct:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = EscapeAct:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterUnitsForStun(EnemiesWithinRange)
	
	local AlliesWithinRange = bot:GetNearbyHeroes(CastRange, false, BOT_MODE_NONE)
	local FilteredAllies = PAF.FilterTrueUnits(AlliesWithinRange)
	
	local WeakestAlly = PAF.GetWeakestUnit(FilteredAllies)
	
	if WeakestAlly ~= nil then
		local EnemiesNearAlly = WeakestAlly:GetNearbyHeroes(1000, true, BOT_MODE_NONE)
		
		if WeakestAlly:GetHealth() <= (WeakestAlly:GetMaxHealth() * 0.35)
		and WeakestAlly:WasRecentlyDamagedByAnyHero(1)
		and #EnemiesNearAlly > 0
		and not WeakestAlly:HasModifier("modifier_arc_warden_tempest_double")
		and not WeakestAlly:HasModifier("modifier_ringmaster_the_box_buff")
		and not WeakestAlly:HasModifier("modifier_muerta_pierce_the_veil_buff") then
			if WeakestAlly:IsInvisible() then
				if WeakestAlly:HasModifier("modifier_item_dustofappearance")
				or WeakestAlly:HasModifier("modifier_slardar_amplify_damage")
				or WeakestAlly:HasModifier("modifier_bounty_hunter_track") then
					return BOT_ACTION_DESIRE_HIGH, WeakestAlly
				end
			else
				return BOT_ACTION_DESIRE_HIGH, WeakestAlly
			end
		end
	end
	
	for v, Ally in pairs(FilteredAllies) do
		if PAF.IsDisabled(Ally)
		or PAF.IsTaunted(Ally) then
			return BOT_ACTION_DESIRE_ABSOLUTE, Ally
		end
	end
	
	return 0
end

function UseImpalementArts()
	if not ImpalementArts:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = ImpalementArts:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	local Width = ImpalementArts:GetSpecialValueInt("dagger_width")
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(1000, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterUnitsForStun(EnemiesWithinRange)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget)
			and not IsEnemyCreepBetweenMeAndTarget(BotTarget, Width)
			and not BotTarget:HasModifier("modifier_ringmaster_impalement_bleed") then
				return BOT_ACTION_DESIRE_HIGH, BotTarget:GetLocation()
			end
		end
	end
	
	if P.IsRetreating(bot) and #EnemiesWithinRange > 0 then
		local ClosestTarget = PAF.GetClosestUnit(bot, FilteredEnemies)
		if not IsEnemyCreepBetweenMeAndTarget(ClosestTarget, Width)
		and not ClosestTarget:HasModifier("modifier_ringmaster_impalement_bleed") then
			return BOT_ACTION_DESIRE_HIGH, ClosestTarget:GetLocation()
		end
	end
	
	return 0
end

function UseWheelOfWonder()
	if not WheelOfWonder:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = WheelOfWonder:GetSpecialValueInt("AbilityCastRange")
	local CastRange = PAF.GetProperCastRange(CR)
	local Radius = WheelOfWonder:GetSpecialValueInt("mesmerize_radius")
	
	if PAF.IsInTeamFight(bot) then
		local AoE = bot:FindAoELocation(true, true, bot:GetLocation(), CastRange, Radius/2, 0, 0)
		if (AoE.count >= 2) then
			return BOT_ACTION_DESIRE_HIGH, AoE.targetloc
		end
	end
	
	return 0
end

function UseSpotlight()
	if not Spotlight:IsFullyCastable() then return 0 end
	if Spotlight:IsHidden() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = Spotlight:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	local Radius = Spotlight:GetSpecialValueInt("radius")
	local SweepRadius = Spotlight:GetSpecialValueInt("SweepRadius")
	local TotalRadius = (Radius + SweepRadius)
	
	if PAF.IsInTeamFight(bot) then
		local AoE = bot:FindAoELocation(true, true, bot:GetLocation(), CastRange, TotalRadius/2, 0, 0)
		if (AoE.count >= 2) then
			return BOT_ACTION_DESIRE_HIGH, AoE.targetloc
		end
	end
	
	return 0
end

function UseFunhouseMirror()
	if not FunhouseMirror:IsFullyCastable() then return 0 end
	--if FunhouseMirror:IsHidden() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(1000, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterUnitsForStun(EnemiesWithinRange)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= (AttackRange + 150) then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end
	
	if P.IsRetreating(bot) and #EnemiesWithinRange > 0 then
		local ClosestTarget = PAF.GetClosestUnit(bot, EnemiesWithinRange)
		return BOT_ACTION_DESIRE_HIGH
	end
	
	return 0
end

function UseStrongmanTonic()
	if not StrongmanTonic:IsFullyCastable() then return 0 end
	--if StrongmanTonic:IsHidden() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = StrongmanTonic:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local AlliesWithinRange = bot:GetNearbyHeroes(CastRange, false, BOT_MODE_NONE)
	local FilteredAllies = PAF.FilterTrueUnits(AlliesWithinRange)
	
	if PAF.IsInTeamFight(bot) then
		local StrongestAlly = PAF.GetStrongestPowerUnit(FilteredAllies)
		
		if StrongestAlly ~= nil then
			return BOT_ACTION_DESIRE_HIGH, StrongestAlly
		end
	end
	
	return 0
end

function UseWhoopeeCushion()
	if not WhoopeeCushion:IsFullyCastable() then return 0 end
	--if WhoopeeCushion:IsHidden() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = WhoopeeCushion:GetSpecialValueInt("leap_distance")
	
	if P.IsRetreating(bot) then
		local EnemiesWithinRange = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
		local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
		
		if #FilteredEnemies > 0 then
			if bot:IsFacingLocation(PAF.GetFountainLocation(bot), 20) then
				return BOT_ACTION_DESIRE_VERYHIGH
			end
		end
	end
	
	return 0
end

function IsEnemyCreepBetweenMeAndTarget(target, nRadius)
	creeps = bot:GetNearbyCreeps(1600, true)
	for i,creep in pairs(creeps) do
		local tResult = PointToLineDistance(bot:GetLocation(), target:GetLocation(), creep:GetLocation())
		if tResult ~= nil and tResult.within and tResult.distance <= nRadius then
			return true
		end
	end
	
	return false
end