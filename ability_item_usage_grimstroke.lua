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

local StrokeOfFateDesire = 0
local PhantomsEmbraceDesire = 0
local InkSwellDesire = 0
local SoulbindDesire = 0
local DarkPortraitDesire = 0

local AttackRange
local BotTarget

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	-- The order to use abilities in
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
					return BOT_ACTION_DESIRE_HIGH, bot:GetXUnitsTowardsLocation(BotTarget:GetExtrapolatedLocation(1), CastRange)
				else
					return BOT_ACTION_DESIRE_HIGH, BotTarget:GetExtrapolatedLocation(1)
				end
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
	end
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget) then
				return BOT_ACTION_DESIRE_HIGH, BotTarget
			end
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
	
	return 0
end

function UseInkSwell()
	if not InkSwell:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = InkSwell:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local allies = nil
	
	if BotTarget ~= nil then
		allies = BotTarget:GetNearbyHeroes(300, true, BOT_MODE_NONE)
	end
	
	local closestally = nil
	local closestdistance = 9999
	
	if allies ~= nil then
		for v, ally in pairs(allies) do
			if GetUnitToUnitDistance(ally, BotTarget) < closestdistance then
				closestdistance = GetUnitToUnitDistance(ally, BotTarget)
				closestally = ally
			end
		end
	end
	
	if closestally ~= nil and PAF.IsEngaging(bot) then
		return BOT_ACTION_DESIRE_HIGH, closestally
	end
	
	if P.IsRetreating(bot) then
		return BOT_ACTION_DESIRE_HIGH, bot
	end
	
	return 0
end

function UseSoulbind()
	if not Soulbind:IsFullyCastable() then return 0 end
	if not PAF.IsInTeamFight(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = PhantomsEmbrace:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	if PAF.IsEngaging(bot) and BotTarget ~= nil then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange then
				local TargetAllies = BotTarget:GetNearbyHeroes(600, false, BOT_MODE_NONE)
				
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
	
	if PAF.IsEngaging(bot) then
		if #FilteredEnemies > 0 then
			local StrongestEnemy = GetStrongestAttackDamageUnit(FilteredEnemies)
			
			if StrongestEnemy ~= nil then
				if GetUnitToUnitDistance(bot, StrongestEnemy) <= CastRange then
					return BOT_ACTION_DESIRE_HIGH, StrongestEnemy
				end
			end
		end
	end
	
	return 0
end