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
	DigDesire = UseDig()
	if DigDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbility(Dig)
		return
	end
	
	EarthbindDesire, EarthbindTarget = UseEarthbind()
	if EarthbindDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbilityOnLocation(Earthbind, EarthbindTarget)
		return
	end
	
	PoofDesire, PoofTarget = UsePoof()
	if PoofDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbilityOnEntity(Poof, PoofTarget)
		return
	end
end

function UseEarthbind()
	if not Earthbind:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = Earthbind:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	local CastPoint = Earthbind:GetCastPoint()
	local Speed = Earthbind:GetSpecialValueInt("speed")
	
	local EnemiesWithinCastRange = PAF.GetNearbyFilteredHeroes(bot, CastRange, true, BOT_MODE_NONE)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget)
			and not PAF.IsReflectingSpells(BotTarget) then
				if not PAF.IsDisabled(BotTarget) then
					local ExtrapolateTime = (CastPoint + (GetUnitToUnitDistance(bot, BotTarget) / Speed))
					local ExtrapolatedLocation = BotTarget:GetExtrapolatedLocation(ExtrapolateTime)
				
					if GetUnitToLocationDistance(bot, ExtrapolatedLocation) <= CastRange then
						return 1, ExtrapolatedLocation
					end
				end
			end
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_RETREAT then
		local StrongestEnemy = PAF.GetStrongestPowerUnit(EnemiesWithinCastRange)
		
		if StrongestEnemy ~= nil
		and not PAF.IsMagicImmune(StrongestEnemy)
		and not PAF.IsReflectingSpells(StrongestEnemy) then
			local ExtrapolateTime = (CastPoint + (GetUnitToUnitDistance(bot, StrongestEnemy) / Speed))
			local ExtrapolatedLocation = StrongestEnemy:GetExtrapolatedLocation(ExtrapolateTime)
				
			if GetUnitToLocationDistance(bot, ExtrapolatedLocation) <= CastRange then
				return 1, ExtrapolatedLocation
			end
		end
	end
	
	local NearbyAlliedTowers = bot:GetNearbyTowers(1600, false)
	
	for x, Tower in pairs(NearbyAlliedTowers) do
		local TowerTarget = Tower:GetAttackTarget()
		
		if PAF.IsValidHeroAndNotIllusion(TowerTarget)
		and not PAF.IsMagicImmune(TowerTarget)
		and not PAF.IsDisabled(TowerTarget)
		and not PAF.IsReflectingSpells(TowerTarget) then
			local ExtrapolateTime = (CastPoint + (GetUnitToUnitDistance(bot, TowerTarget) / Speed))
			local ExtrapolatedLocation = TowerTarget:GetExtrapolatedLocation(ExtrapolateTime)
				
			if GetUnitToLocationDistance(bot, ExtrapolatedLocation) <= CastRange then
				return 1, ExtrapolatedLocation
			end
		end
	end
	
	return 0
end

function UsePoof()
	if not Poof:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = Poof:GetSpecialValueInt("radius")
	local ManaCost = Poof:GetManaCost()
	
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
			return 1, FurthestMeepo
		end
	end
	
	local enemies = PAF.GetNearbyFilteredHeroes(bot, CastRange, true, BOT_MODE_NONE)
	
	if #enemies >= 1 then
		for v, enemy in pairs(enemies) do
			if PAF.IsDisabled(enemy) then
				return 1, bot
			end
		end
	end
	
	for v, meepo in pairs(MeepoTable) do
		if not P.IsRetreating(bot) and PAF.IsEngaging(meepo) and GetUnitToUnitDistance(bot, meepo) > 2000 then
			return 1, meepo
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_FARM
	and PAF.ShouldCastAbilityToFarm(bot, ManaCost, ManaThreshold, false) then
		local neutrals = bot:GetNearbyNeutralCreeps(CastRange)
		
		if #neutrals >= 1 then
			return 1, bot
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
		return 1
	end
	
	return 0
end