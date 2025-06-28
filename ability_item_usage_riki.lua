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

local SmokeScreen = bot:GetAbilityByName("riki_smoke_screen")
local BlinkStrike = bot:GetAbilityByName("riki_blink_strike")
local TricksOfTheTrade = bot:GetAbilityByName("riki_tricks_of_the_trade")
local Backstab = bot:GetAbilityByName("riki_backstab")

local SmokeScreenDesire = 0
local BlinkStrikeDesire = 0
local TricksOfTheTradeDesire = 0

local AttackRange
local BotTarget
local AttackTarget
local ManaThreshold

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	manathreshold = 100
	manathreshold = manathreshold + SmokeScreen:GetManaCost()
	manathreshold = manathreshold + (BlinkStrike:GetManaCost() * 2)
	manathreshold = manathreshold + TricksOfTheTrade:GetManaCost()
	
	-- The order to use abilities in
	BlinkStrikeDesire, BlinkStrikeTarget = UseBlinkStrike()
	if BlinkStrikeDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbilityOnEntity(BlinkStrike, BlinkStrikeTarget)
		return
	end
	
	SmokeScreenDesire, SmokeScreenTarget = UseSmokeScreen()
	if SmokeScreenDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbilityOnLocation(SmokeScreen, SmokeScreenTarget)
		return
	end
	
	TricksOfTheTradeDesire, TricksOfTheTradeTarget = UseTricksOfTheTrade()
	if TricksOfTheTradeDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbilityOnLocation(TricksOfTheTrade, TricksOfTheTradeTarget)
		return
	end
end

function UseSmokeScreen()
	if not SmokeScreen:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = SmokeScreen:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	local CastPoint = SmokeScreen:GetCastPoint()
	local Radius = SmokeScreen:GetSpecialValueInt("radius")
	
	if PAF.IsInTeamFight(bot) then
		local AoELocation = bot:FindAoELocation(true, true, bot:GetLocation(), CastRange, Radius, CastPoint, 0)
		
		if AoELocation.count >= 2 then
			return 1, AoELocation.targetloc
		end
	elseif PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget) then
				local ExtrapolatedLocation = BotTarget:GetExtrapolatedLocation(CastPoint)
				
				if GetUnitToLocationDistance(bot, ExtrapolatedLocation) <= CastRange then
					return 1, ExtrapolatedLocation
				end
			end
		end
	end
	
	return 0
end

function UseBlinkStrike()
	if not BlinkStrike:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = BlinkStrike:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local allies = bot:GetNearbyHeroes(CastRange, false, BOT_MODE_NONE)
	local creeps = bot:GetNearbyCreeps(CastRange, false)
	local target
	
	if P.IsRetreating(bot) then
		for v, creep in pairs(creeps) do
			table.insert(allies, creep)
		end
		
		local AllyClosestToBase = nil
		local AllyClosestToBaseDist = 99999
		
		for v, ally in pairs(allies) do
			if ally ~= bot and GetUnitToLocationDistance(ally, PAF.GetFountainLocation(bot)) < AllyClosestToBaseDist then
				AllyClosestToBase = ally
				AllyClosestToBaseDist = GetUnitToLocationDistance(ally, PAF.GetFountainLocation(bot))
			end
		end
		
		if AllyClosestToBase ~= nil and AllyClosestToBaseDist < GetUnitToLocationDistance(bot, PAF.GetFountainLocation(bot)) and GetUnitToUnitDistance(bot, AllyClosestToBase) > 300 then
			return 1, AllyClosestToBase
		end
	end
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange 
			and GetUnitToUnitDistance(bot, BotTarget) >= 300 then
				return 1, BotTarget
			end
		end
	end
	
	return 0
end

function UseTricksOfTheTrade()
	if not TricksOfTheTrade:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = TricksOfTheTrade:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	local CastPoint = TricksOfTheTrade:GetCastPoint()
	local Radius = TricksOfTheTrade:GetSpecialValueInt("radius")
	
	if PAF.IsInTeamFight(bot)
	and not SmokeScreen:IsFullyCastable() then
		local AoELocation = bot:FindAoELocation(true, true, bot:GetLocation(), CastRange, Radius, CastPoint, 0)
		
		if AoELocation.count >= 2 then
			return 1, AoELocation.targetloc
		end
	elseif PAF.IsEngaging(bot)
	and not SmokeScreen:IsFullyCastable() then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget) then
				local ExtrapolatedLocation = BotTarget:GetExtrapolatedLocation(CastPoint)
				
				if GetUnitToLocationDistance(bot, ExtrapolatedLocation) <= CastRange then
					return 1, ExtrapolatedLocation
				end
			end
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		if PAF.IsRoshan(AttackTarget) then
			return 1, AttackTarget:GetLocation()
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_SIDE_SHOP then
		if PAF.IsTormentor(AttackTarget) then
			return 1, AttackTarget:GetLocation()
		end
	end
	
	return 0
end