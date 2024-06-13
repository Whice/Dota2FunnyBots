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
local manathreshold = 0

local RadiantBase = Vector(-7171.12, -7261.72, 1469.28)
local DireBase = Vector(6977.84, 5797.69, 1357.99)
local base
local team = bot:GetTeam()

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	manathreshold = 100
	manathreshold = manathreshold + SmokeScreen:GetManaCost()
	manathreshold = manathreshold + (BlinkStrike:GetManaCost() * 2)
	manathreshold = manathreshold + TricksOfTheTrade:GetManaCost()
	
	if team == TEAM_RADIANT then
		base = RadiantBase
	elseif team == TEAM_DIRE then
		base = DireBase
	end
	
	-- The order to use abilities in
	BlinkStrikeDesire, BlinkStrikeTarget = UseBlinkStrike()
	if BlinkStrikeDesire > 0 then
		bot:Action_UseAbilityOnEntity(BlinkStrike, BlinkStrikeTarget)
		return
	end
	
	SmokeScreenDesire, SmokeScreenTarget = UseSmokeScreen()
	if SmokeScreenDesire > 0 then
		bot:Action_UseAbilityOnLocation(SmokeScreen, SmokeScreenTarget)
		return
	end
	
	TricksOfTheTradeDesire, TricksOfTheTradeTarget = UseTricksOfTheTrade()
	if TricksOfTheTradeDesire > 0 then
		bot:Action_UseAbilityOnLocation(TricksOfTheTrade, TricksOfTheTradeTarget)
		return
	end
end

function UseSmokeScreen()
	if not SmokeScreen:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = SmokeScreen:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange and not PAF.IsMagicImmune(BotTarget) then
				return BOT_ACTION_DESIRE_HIGH, BotTarget:GetLocation()
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
--	local Charges = BlinkStrike:GetCurrentCharges()
	
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
			if ally ~= bot and GetUnitToLocationDistance(ally, base) < AllyClosestToBaseDist then
				AllyClosestToBase = ally
				AllyClosestToBaseDist = GetUnitToLocationDistance(ally, base)
			end
		end
		
		if AllyClosestToBase ~= nil and AllyClosestToBaseDist < GetUnitToLocationDistance(bot, base) and GetUnitToUnitDistance(bot, AllyClosestToBase) > 300 then
			return BOT_ACTION_DESIRE_HIGH, AllyClosestToBase
		end
	end
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange 
			and GetUnitToUnitDistance(bot, BotTarget) >= 300 then
				return BOT_ACTION_DESIRE_HIGH, BotTarget
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
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange then
				return BOT_ACTION_DESIRE_HIGH, BotTarget:GetLocation()
			end
		end
	end
	
	local AttackTarget = bot:GetAttackTarget()
	
	if bot:GetActiveMode() == BOT_MODE_FARM then
		local Neutrals = bot:GetNearbyNeutralCreeps(CastRange)
		
		if AttackTarget ~= nil and AttackTarget:IsCreep() and #Neutrals >= 2 then
			return BOT_ACTION_DESIRE_HIGH, AttackTarget:GetLocation()
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		if AttackTarget ~= nil and PAF.IsRoshan(AttackTarget) then
			return BOT_ACTION_DESIRE_HIGH, AttackTarget:GetLocation()
		end
	end
	
	return 0
end