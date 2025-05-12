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

local StrokeOfFate = bot:GetAbilityByName("grimstroke_dark_artistry")
local PhantomsEmbrace = bot:GetAbilityByName("grimstroke_ink_creature")
local InkSwell = bot:GetAbilityByName("grimstroke_spirit_walk")
local Soulbind = bot:GetAbilityByName("grimstroke_soul_chain")
local DarkPortrait = bot:GetAbilityByName("grimstroke_dark_portrait")

local InkExplosion = bot:GetAbilityByName("grimstroke_return")

local StrokeOfFateDesire = 0
local PhantomsEmbraceDesire = 0
local InkSwellDesire = 0
local SoulbindDesire = 0
local DarkPortraitDesire = 0
local InkExplosionDesire = 0

local AttackRange
local BotTarget

local LastInkSwellTime = DotaTime()

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	-- The order to use abilities in
	InkExplosionDesire = UseInkExplosion()
	if InkExplosionDesire > 0 then
		bot:Action_UseAbility(InkExplosion)
		return
	end
	
	SoulbindDesire, SoulbindTarget = UseSoulbind()
	if SoulbindDesire > 0 then
		bot:Action_UseAbilityOnEntity(Soulbind, SoulbindTarget)
		return
	end
	
	DarkPortraitDesire, DarkPortraitTarget = UseDarkPortrait()
	if DarkPortraitDesire > 0 then
		bot:Action_UseAbilityOnEntity(DarkPortrait, DarkPortraitTarget)
		return
	end
	
	PhantomsEmbraceDesire, PhantomsEmbraceTarget = UsePhantomsEmbrace()
	if PhantomsEmbraceDesire > 0 then
		bot:Action_UseAbilityOnEntity(PhantomsEmbrace, PhantomsEmbraceTarget)
		return
	end
	
	InkSwellDesire, InkSwellTarget = UseInkSwell()
	if InkSwellDesire > 0 then
		bot:Action_UseAbilityOnEntity(InkSwell, InkSwellTarget)
		LastInkSwellTime = DotaTime()
		return
	end
	
	StrokeOfFateDesire, StrokeOfFateTarget = UseStrokeOfFate()
	if StrokeOfFateDesire > 0 then
		bot:Action_UseAbilityOnLocation(StrokeOfFate, StrokeOfFateTarget)
		return
	end
end

function UseStrokeOfFate()
	if not StrokeOfFate:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = StrokeOfFate:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget) then
				if GetUnitToLocationDistance(bot, BotTarget:GetExtrapolatedLocation(1)) > CastRange then
					return BOT_ACTION_DESIRE_HIGH, PAF.GetXUnitsTowardsLocation(bot:GetLocation(), BotTarget:GetExtrapolatedLocation(1), CastRange)
				else
					return BOT_ACTION_DESIRE_HIGH, BotTarget:GetExtrapolatedLocation(1)
				end
			end
		end
	end
	
	local AttackTarget = bot:GetAttackTarget()
	
	if AttackTarget ~= nil then
		if bot:GetActiveMode() == BOT_MODE_ROSHAN then
			if PAF.IsRoshan(AttackTarget)
			and GetUnitToUnitDistance(bot, AttackTarget) <= CastRange then
				return BOT_ACTION_DESIRE_VERYHIGH, AttackTarget:GetLocation()
			end
		end
		
		if PAF.IsTormentor(AttackTarget) then
			return BOT_ACTION_DESIRE_HIGH, AttackTarget:GetLocation()
		end
	end
	
	return 0
end

function UsePhantomsEmbrace()
	if not PhantomsEmbrace:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = PhantomsEmbrace:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterUnitsForStun(EnemiesWithinRange)
	
	for v, enemy in pairs(FilteredEnemies) do
		if enemy:IsChanneling() then
			return BOT_ACTION_DESIRE_HIGH, enemy
		end
		
		if enemy:HasModifier("modifier_grimstroke_soul_chain") then
			return BOT_ACTION_DESIRE_HIGH, enemy
		end
	end
	
	if P.IsRetreating(bot) and #EnemiesWithinRange > 0 then
		local ClosestTarget = PAF.GetClosestUnit(bot, EnemiesWithinRange)
		return BOT_ACTION_DESIRE_HIGH, ClosestTarget
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		local AttackTarget = bot:GetAttackTarget()
		
		if PAF.IsRoshan(AttackTarget)
		and GetUnitToUnitDistance(bot, AttackTarget) <= CastRange then
			return BOT_ACTION_DESIRE_VERYHIGH, AttackTarget
		end
	end
	
	if PAF.IsInTeamFight(bot) and Soulbind:IsFullyCastable() then return 0 end
	
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

function UseInkSwell()
	if not InkSwell:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = InkSwell:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local AlliesWithinRange = bot:GetNearbyHeroes(CastRange, false, BOT_MODE_NONE)
	local FilteredAllies = PAF.FilterTrueUnits(AlliesWithinRange)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= 1200 then
				local AllyWithShortestAR = nil
				local ShortestAR = 99999999
				
				for v, Ally in pairs(FilteredAllies) do
					if Ally:GetAttackRange() < ShortestAR then
						AllyWithShortestAR = Ally
						ShortestAR = Ally:GetAttackRange()
					end
				end
				
				if AllyWithShortestAR ~= nil then
					return BOT_ACTION_DESIRE_HIGH, AllyWithShortestAR
				end
			end
		end
	end
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	
	if P.IsRetreating(bot) then
		if #FilteredEnemies > 0
		and bot:WasRecentlyDamagedByAnyHero(1) then
			return BOT_ACTION_DESIRE_HIGH, bot
		end
	end
	
	for v, Ally in pairs(FilteredAllies) do
		if Ally:GetHealth() < (Ally:GetMaxHealth() * 0.35) then
			EnemiesWithinRange = Ally:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
			FilteredEnemies = PAF.FilterUnitsForStun(EnemiesWithinRange)
			
			if #FilteredEnemies > 0
			and Ally:WasRecentlyDamagedByAnyHero(1) then
				return BOT_ACTION_DESIRE_HIGH, Ally
			end
		end
	end
	
	return 0
end

function UseSoulbind()
	if not Soulbind:IsFullyCastable() then return 0 end
	if not PAF.IsInTeamFight(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = PhantomsEmbrace:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local Radius = Soulbind:GetSpecialValueInt("chain_latch_radius")
	
	if PAF.IsEngaging(bot) and BotTarget ~= nil then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange then
				local TargetAllies = BotTarget:GetNearbyHeroes(Radius, false, BOT_MODE_NONE)
				
				if #TargetAllies >= 2 then
					return BOT_ACTION_DESIRE_HIGH, BotTarget
				end
			end
		end
	end
	
	return 0
end

function UseDarkPortrait()
	if not DarkPortrait:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = DarkPortrait:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	
	for v, enemy in pairs(FilteredEnemies) do
		if enemy:HasModifier("modifier_grimstroke_soul_chain") then
			return BOT_ACTION_DESIRE_HIGH, enemy
		end
	end
	
	if PAF.IsEngaging(bot) then
		if #FilteredEnemies > 0 then
			local StrongestEnemy = PAF.GetStrongestAttackDamageUnit(FilteredEnemies)
			
			if StrongestEnemy ~= nil then
				if GetUnitToUnitDistance(bot, StrongestEnemy) <= CastRange then
					return BOT_ACTION_DESIRE_HIGH, StrongestEnemy
				end
			end
		end
	end
	
	return 0
end

function UseInkExplosion()
	if not InkExplosion:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	if InkExplosion:IsHidden() then return 0 end
	
	local Threshold = InkSwell:GetSpecialValueFloat("max_threshold_duration")
	local Radius = InkSwell:GetSpecialValueInt("radius")
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if (DotaTime() - LastInkSwellTime) >= Threshold then
				local Allies = GetUnitList(UNIT_LIST_ALLIED_HEROES)
				for v, Ally in pairs(Allies) do
					if Ally:HasModifier("modifier_grimstroke_spirit_walk_buff") then
						if GetUnitToUnitDistance(Ally, BotTarget) <= Radius then
							return BOT_ACTION_DESIRE_HIGH
						end
					end
				end
			end
		end
	end
end