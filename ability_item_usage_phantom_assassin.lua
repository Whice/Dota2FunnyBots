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
local AttackTarget
local ManaThreshold

local RadiantBase = Vector(-7171.12, -7261.72, 1469.28)
local DireBase = Vector(6977.84, 5797.69, 1357.99)
local base
local team = bot:GetTeam()

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	AttackTarget = bot:GetAttackTarget()
	ManaThreshold = (100 + StiflingDagger:GetManaCost() + PhantomStrike:GetManaCost() + Blur:GetManaCost() + FanOfKnives:GetManaCost())
	
	if team == TEAM_RADIANT then
		base = RadiantBase
	elseif team == TEAM_DIRE then
		base = DireBase
	end
	
	-- The order to use abilities in
	FanOfKnivesDesire, FanOfKnivesTarget = UseFanOfKnives()
	if FanOfKnivesDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbility(FanOfKnives)
		return
	end
	
	BlurDesire, BlurTarget = UseBlur()
	if BlurDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbility(Blur)
		return
	end
	
	StiflingDaggerDesire, StiflingDaggerTarget = UseStiflingDagger()
	if StiflingDaggerDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbilityOnEntity(StiflingDagger, StiflingDaggerTarget)
		return
	end
	
	PhantomStrikeDesire, PhantomStrikeTarget = UsePhantomStrike()
	if PhantomStrikeDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbilityOnEntity(PhantomStrike, PhantomStrikeTarget)
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
	local DamageType = StiflingDagger:GetDamageType()
	
	local EnemiesWithinCastRange = PAF.GetNearbyFilteredHeroes(bot, CastRange, true, BOT_MODE_NONE)
	
	for x, Enemy in pairs(EnemiesWithinCastRange) do
		if PAF.CanDamageKillEnemy(Enemy, DaggerDamage, DamageType) then
			return 1
		end
	end
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange then
				return 1, BotTarget
			end
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_LANING then
		local LaneCreepsWithinRange = bot:GetNearbyLaneCreeps(CastRange, true)
		
		for v, Creep in pairs(LaneCreepsWithinRange) do
			local EstimatedDaggerDamage = Creep:GetActualIncomingDamage(DaggerDamage, DamageType)
			
			if Creep:GetHealth() < EstimatedDaggerDamage
			and GetUnitToUnitDistance(bot, Creep) > 450 then
				return 1, Creep
			end
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		if PAF.IsRoshan(AttackTarget) then
			return 1, AttackTarget
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_SIDE_SHOP then
		if PAF.IsTormentor(AttackTarget) then
			return 1, AttackTarget
		end
	end
	
	return 0
end

function UsePhantomStrike()
	if not PhantomStrike:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = PhantomStrike:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	local ManaCost = PhantomStrike:GetManaCost()
	
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
			return 1, AllyClosestToBase
		end
	end
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange then
				return 1, BotTarget
			end
		end
	end
	
	if PAF.IsInCreepAttackingMode(bot) then
		if PAF.IsValidCreepTarget(AttackTarget) then
			if AttackTarget:GetTeam() ~= bot:GetTeam()
			and PAF.ShouldCastAbilityToFarm(bot, ManaCost, ManaThreshold, false) then
				return 1, AttackTarget
			end
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		if PAF.IsRoshan(AttackTarget) then
			return 1, AttackTarget
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_SIDE_SHOP then
		if PAF.IsTormentor(AttackTarget) then
			return 1, AttackTarget
		end
	end
	
	return 0
end

function UseBlur()
	if not Blur:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local Radius = Blur:GetSpecialValueInt("radius")
	
	local projectiles = bot:GetIncomingTrackingProjectiles()
	
	for v, proj in pairs(projectiles) do
		if GetUnitToLocationDistance(bot, proj.location) <= 200
		and proj.is_dodgeable
		and proj.is_attack == false then
			return 1
		end
	end
	
	local HeroesWithinRange = bot:GetNearbyHeroes((Radius * 1.5), true, BOT_MODE_NONE)
	local BuildingsWithinRange = {}
		
	local Buildings = GetUnitList(UNIT_LIST_ENEMY_BUILDINGS)
	for x, Building in pairs(Buildings) do
		if GetUnitToUnitDistance(bot, Building) <= (Radius * 1.5) then
			table.insert(BuildingsWithinRange, Building)
		end
	end
	
	if #HeroesWithinRange > 0 or #BuildingsWithinRange > 0 then
		return 0
	end
	
	if bot:GetActiveMode() == BOT_MODE_RETREAT
	or bot:GetActiveMode() == BOT_MODE_ROSHAN then
		if #HeroesWithinRange <= 0 and #BuildingsWithinRange <= 0 then
			return 1
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_FARM then
		if PAF.IsValidCreepTarget(AttackTarget) then
			if AttackTarget:GetTeam() == TEAM_NEUTRAL then
				return 1
			end
		end
	end
	
	return 0
end

function UseFanOfKnives()
	if not FanOfKnives:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = FanOfKnives:GetSpecialValueInt("radius")
	local ManaCost = FanOfKnives:GetManaCost
	local DamageType = FanOfKnives:GetDamageType()
	
	local EnemiesWithinCastRange = PAF.GetNearbyFilteredHeroes(bot, CastRange, true, BOT_MODE_NONE)
	
	for x, Enemy in pairs(EnemiesWithinCastRange) do
		if PAF.CanDamageKillEnemy(Enemy, (Enemy:GetMaxHealth() * 0.3), DamageType) then
			return 1
		end
	end
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange then
				return 1
			end
		end
	end
	
	if PAF.IsInCreepAttackingMode(bot) then
		if PAF.IsValidCreepTarget(AttackTarget) then
			if AttackTarget:GetTeam() ~= bot:GetTeam()
			and PAF.ShouldCastAbilityToFarm(bot, ManaCost, ManaThreshold, false) then
				local CreepsWithinRange = bot:GetNearbyCreeps(CastRange, true)
				
				if #CreepsWithinRange >= 3 then
					return 1
				end
			end
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		if PAF.IsRoshan(AttackTarget) then
			return 1
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_SIDE_SHOP then
		if PAF.IsTormentor(AttackTarget) then
			return 1
		end
	end
	
	return 0
end