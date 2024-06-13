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

local StiflingDagger = bot:GetAbilityByName("phantom_assassin_stifling_dagger")
local PhantomStrike = bot:GetAbilityByName("phantom_assassin_phantom_strike")
local Blur = bot:GetAbilityByName("phantom_assassin_blur")
local CoupDeGrace = bot:GetAbilityByName("phantom_assassin_coup_de_grace")
local FanOfKnives = bot:GetAbilityByName("phantom_assassin_fan_of_knives")

local StiflingDaggerDesire = 0
local PhantomStrikeDesire = 0
local BlurDesire = 0
local FanOfKnivesDesire = 0

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
	manathreshold = manathreshold + StiflingDagger:GetManaCost()
	manathreshold = manathreshold + PhantomStrike:GetManaCost()
	manathreshold = manathreshold + Blur:GetManaCost()
	manathreshold = manathreshold + FanOfKnives:GetManaCost()
	
	if team == TEAM_RADIANT then
		base = RadiantBase
	elseif team == TEAM_DIRE then
		base = DireBase
	end
	
	-- The order to use abilities in
	FanOfKnivesDesire, FanOfKnivesTarget = UseFanOfKnives()
	if FanOfKnivesDesire > 0 then
		bot:Action_UseAbility(FanOfKnives)
		return
	end
	
	BlurDesire, BlurTarget = UseBlur()
	if BlurDesire > 0 then
		bot:Action_UseAbility(Blur)
		return
	end
	
	StiflingDaggerDesire, StiflingDaggerTarget = UseStiflingDagger()
	if StiflingDaggerDesire > 0 then
		bot:Action_UseAbilityOnEntity(StiflingDagger, StiflingDaggerTarget)
		return
	end
	
	PhantomStrikeDesire, PhantomStrikeTarget = UsePhantomStrike()
	if PhantomStrikeDesire > 0 then
		bot:Action_UseAbilityOnEntity(PhantomStrike, PhantomStrikeTarget)
		return
	end
end

function UseStiflingDagger()
	if not StiflingDagger:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = StiflingDagger:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	local BaseDamage = StiflingDagger:GetSpecialValueInt("base_damage")
	local AttackFactor = StiflingDagger:GetSpecialValueInt("attack_factor_tooltip")
	local AFPercentage = (AttackFactor / 100)
	local AttackDamageBonus = (bot:GetAttackDamage() * AFPercentage)
	local DaggerDamage = (BaseDamage + AttackDamageBonus)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange then
				return BOT_ACTION_DESIRE_HIGH, BotTarget
			end
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_LANING then
		local LaneCreepsWithinRange = bot:GetNearbyLaneCreeps(CastRange, true)
		
		for v, Creep in pairs(LaneCreepsWithinRange) do
			local EstimatedDaggerDamage = Creep:GetActualIncomingDamage(DaggerDamage, DAMAGE_TYPE_PHYSICAL)
			
			if Creep:GetHealth() < EstimatedDaggerDamage
			and GetUnitToUnitDistance(bot, Creep) > 450 then
				return BOT_ACTION_DESIRE_HIGH, Creep
			end
		end
	end
	
	local AttackTarget = bot:GetAttackTarget()
	
	if AttackTarget ~= nil then
		if bot:GetActiveMode() == BOT_MODE_ROSHAN then
			if PAF.IsRoshan(AttackTarget)
			and GetUnitToUnitDistance(bot, AttackTarget) <= CastRange then
				return BOT_ACTION_DESIRE_VERYHIGH, AttackTarget
			end
		end
	end
	
	return 0
end

function UsePhantomStrike()
	if not PhantomStrike:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = PhantomStrike:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	local AlliesWithinRange = bot:GetNearbyHeroes(CastRange, false, BOT_MODE_NONE)
	local creeps = bot:GetNearbyCreeps(CastRange, false)
	local target
	
	if P.IsRetreating(bot) then
		for v, creep in pairs(creeps) do
			table.insert(AlliesWithinRange, creep)
		end
		
		local AllyClosestToBase = nil
		local AllyClosestToBaseDist = 99999
		
		for v, ally in pairs(AlliesWithinRange) do
			if ally ~= bot and GetUnitToLocationDistance(ally, base) < AllyClosestToBaseDist then
				AllyClosestToBase = ally
				AllyClosestToBaseDist = GetUnitToLocationDistance(ally, base)
			end
		end
		
		if AllyClosestToBase ~= nil and AllyClosestToBaseDist < GetUnitToLocationDistance(bot, base) then
			return BOT_ACTION_DESIRE_HIGH, AllyClosestToBase
		end
	end
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange then
				return BOT_ACTION_DESIRE_HIGH, BotTarget
			end
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_FARM then
		local neutrals = bot:GetNearbyNeutralCreeps(CastRange)
		
		if #neutrals >= 1 and (bot:GetMana() - PhantomStrike:GetManaCost()) > manathreshold then
			local AttackTarget = bot:GetAttackTarget()
			
			if AttackTarget ~= nil and AttackTarget:IsCreep() then
				return BOT_ACTION_DESIRE_HIGH, AttackTarget
			end
		end
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

function UseBlur()
	if not Blur:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local enemies = bot:GetNearbyHeroes((Blur:GetSpecialValueInt("radius") + 400), true, BOT_MODE_NONE)
	
	if bot:GetActiveMode() == BOT_MODE_FARM or bot:GetActiveMode() == BOT_MODE_ROAM then
		return BOT_ACTION_DESIRE_HIGH
	end

	if P.IsRetreating(bot) then
		if #enemies <= 0 then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	return 0
end

function UseFanOfKnives()
	if not FanOfKnives:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = FanOfKnives:GetSpecialValueInt("radius")
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local neutrals = bot:GetNearbyNeutralCreeps(FanOfKnives:GetSpecialValueInt("radius"))
	
	if PAF.IsEngaging(bot) and #EnemiesWithinRange >= 1 then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	if bot:GetActiveMode() == BOT_MODE_FARM and #neutrals >= 2 and (bot:GetMana() - FanOfKnives:GetManaCost()) > manathreshold then
		return BOT_ACTION_DESIRE_HIGH
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