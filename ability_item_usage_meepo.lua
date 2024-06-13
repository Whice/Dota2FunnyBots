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

local Earthbind = bot:GetAbilityByName("meepo_earthbind")
local Poof = bot:GetAbilityByName("meepo_poof")
local Ransack = bot:GetAbilityByName("meepo_ransack")
local DividedWeStand = bot:GetAbilityByName("meepo_divided_we_stand")
local Dig = bot:GetAbilityByName("meepo_petrify")

local EarthbindDesire = 0
local PoofDesire = 0
local DigDesire = 0

local AttackRange
local BotTarget
local manathreshold = 0

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()

	manathreshold = (bot:GetMaxMana() * 0.4)
	
	-- The order to use abilities in
	DigDesire = UseDig()
	if DigDesire > 0 then
		bot:Action_UseAbility(Dig)
		return
	end
	
	EarthbindDesire, EarthbindTarget = UseEarthbind()
	if EarthbindDesire > 0 then
		bot:Action_UseAbilityOnLocation(Earthbind, EarthbindTarget)
		return
	end
	
	PoofDesire, PoofTarget = UsePoof()
	if PoofDesire > 0 then
		bot:Action_UseAbilityOnEntity(Poof, PoofTarget)
		return
	end
end

function UseEarthbind()
	if not Earthbind:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = Earthbind:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterUnitsForStun(EnemiesWithinRange)
	
	for v, enemy in pairs(FilteredEnemies) do
		if enemy:IsChanneling() then
			return BOT_ACTION_DESIRE_HIGH, enemy:GetExtrapolatedLocation(1)
		end
	end
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange then
				return BOT_ACTION_DESIRE_HIGH, BotTarget:GetExtrapolatedLocation(1)
			end
		end
	end
	
	if P.IsRetreating(bot) and #EnemiesWithinRange > 0 then
		local ClosestTarget = PAF.GetClosestUnit(bot, EnemiesWithinRange)
		return BOT_ACTION_DESIRE_HIGH, ClosestTarget:GetExtrapolatedLocation(1)
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

function UsePoof()
	if not Poof:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = Poof:GetSpecialValueInt("radius")
	
	local allies = GetUnitList(UNIT_LIST_ALLIED_HEROES)
	local MeepoTable = {}
	for v, ally in pairs(allies) do
		if ally:GetUnitName() == "npc_dota_hero_meepo" and not P.IsPossibleIllusion(ally) then
			table.insert(MeepoTable, ally)
		end
	end
	
	if P.IsRetreating(bot) then
		FurthestMeepo = nil
		FurthestDistance = 0
	
		for v, meepo in pairs(MeepoTable) do
			local enemies = bot:GetNearbyHeroes(1000, true, BOT_MODE_NONE)
			
			if #enemies >= 1 then
				if GetUnitToUnitDistance(bot, meepo) > FurthestDistance and bot:DistanceFromFountain() > FurthestDistance then
					FurthestMeepo = meepo
					FurthestDistance = GetUnitToUnitDistance(bot, meepo)
				end
			end
		end
		
		if FurthestMeepo ~= nil and FurthestMeepo ~= bot then
			return BOT_ACTION_DESIRE_HIGH, FurthestMeepo
		end
	end
	
	local enemies = bot:GetNearbyHeroes(CastRange - 50, true, BOT_MODE_NONE)
	
	if #enemies >= 1 then
		for v, enemy in pairs(enemies) do
			if PAF.IsDisabled(enemy) then
				return BOT_ACTION_DESIRE_HIGH, bot
			end
		end
	end
	
	for v, meepo in pairs(MeepoTable) do
		if not P.IsRetreating(bot) and PAF.IsEngaging(meepo) and GetUnitToUnitDistance(bot, meepo) > 2000 then
			return BOT_ACTION_DESIRE_HIGH, meepo
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_FARM and (bot:GetMana() - Poof:GetManaCost()) > manathreshold then
		local neutrals = bot:GetNearbyNeutralCreeps(CastRange)
		
		if #neutrals >= 1 then
			return BOT_ACTION_DESIRE_HIGH, bot
		end
	end
	
	return 0
end

--[[function UseDividedWeStand()
	if not DividedWeStand:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	if DividedWeStand:IsPassive() then return 0 end
	if P.IsRetreating(bot) then return 0 end
	
	local CR = DividedWeStand:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	local FlingRadius = 300
	
	local allies = GetUnitList(UNIT_LIST_ALLIED_HEROES)
	local MeepoTable = {}
	for v, ally in pairs(allies) do
		if ally:GetUnitName() == "npc_dota_hero_meepo" and not PAF.IsPossibleIllusion(ally) then
			table.insert(MeepoTable, ally)
		end
	end
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange then
				return BOT_ACTION_DESIRE_HIGH, BotTarget
			end
		end
	end
	
	if PAF.IsEngaging(bot) and PAF.IsValidHeroAndNotIllusion(BotTarget) then
		for v, meepo in pairs(MeepoTable) do
			if meepo ~= bot and GetUnitToUnitDistance(bot, meepo) <= FlingRadius then
				return BOT_ACTION_DESIRE_HIGH, BotTarget
			end
		end
	end
	
	return 0
end]]--

function UseDig()
	if not Dig:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	if bot:GetHealth() < bot:GetMaxHealth() * 0.5 then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	return 0
end