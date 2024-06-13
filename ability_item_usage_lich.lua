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

local FrostNova = bot:GetAbilityByName("lich_frost_nova")
local FrostShield = bot:GetAbilityByName("lich_frost_shield")
local SinisterGaze = bot:GetAbilityByName("lich_sinister_gaze")
local ChainFrost = bot:GetAbilityByName("lich_chain_frost")
local IceSpire = bot:GetAbilityByName("lich_ice_spire")

local FrostNovaDesire = 0
local FrostShieldDesire = 0
local SinisterGazeDesire = 0
local ChainFrostDesire = 0

local AttackRange
local BotTarget

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	-- The order to use abilities in
	ChainFrostDesire, ChainFrostTarget = UseChainFrost()
	if ChainFrostDesire > 0 then
		bot:Action_UseAbilityOnEntity(ChainFrost, ChainFrostTarget)
		return
	end
	
	IceSpireDesire, IceSpireTarget = UseIceSpire()
	if IceSpireDesire > 0 then
		bot:Action_UseAbilityOnLocation(IceSpire, IceSpireTarget)
		return
	end
	
	FrostNovaDesire, FrostNovaTarget = UseFrostNova()
	if FrostNovaDesire > 0 then
		bot:Action_UseAbilityOnEntity(FrostNova, FrostNovaTarget)
		return
	end
	
	FrostShieldDesire, FrostShieldTarget = UseFrostShield()
	if FrostShieldDesire > 0 then
		bot:Action_UseAbilityOnEntity(FrostShield, FrostShieldTarget)
		return
	end
	
	SinisterGazeDesire, SinisterGazeTarget = UseSinisterGaze()
	if SinisterGazeDesire > 0 then
		if bot:HasScepter() then
			bot:Action_UseAbilityOnLocation(SinisterGaze, SinisterGazeTarget:GetLocation())
			return
		else
			bot:Action_UseAbilityOnEntity(SinisterGaze, SinisterGazeTarget)
			return
		end
	end
end

function UseFrostNova()
	if not FrostNova:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = FrostNova:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local enemies = bot:GetNearbyHeroes(CastRange + 100, true, BOT_MODE_NONE)
	local target = P.GetWeakestEnemyHero(enemies)
	
	if target ~= nil then
		return BOT_ACTION_DESIRE_HIGH, target
	end
	
	return 0
end

function UseFrostShield()
	if not FrostShield:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = FrostShield:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local enemies = bot:GetNearbyHeroes(CastRange + 100, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterUnitsForStun(enemies)
	local allies = bot:GetNearbyHeroes(CastRange + 200, false, BOT_MODE_NONE)
	local target = P.GetWeakestAllyHero(allies)
	
	if target ~= nil and #FilteredEnemies > 0 then
		return BOT_ACTION_DESIRE_HIGH, target
	end
	
	if P.IsRetreating(bot) and #FilteredEnemies > 0 then
		return BOT_ACTION_DESIRE_HIGH, bot
	end
	
	if PAF.IsEngaging(bot) then
		local target = PAF.GetWeakestUnit(FilteredEnemies)
		local allies = {}
		
		if target ~= nil then
			allies = target:GetNearbyHeroes(300, true, BOT_MODE_NONE)
		end
		
		local closestally = nil
		local closestdistance = 9999
		
		for v, ally in pairs(allies) do
			if GetUnitToUnitDistance(ally, target) < closestdistance then
				closestdistance = GetUnitToUnitDistance(ally, target)
				closestally = ally
			end
		end
		
		if closestally ~= nil then
			return BOT_ACTION_DESIRE_HIGH, closestally
		end
	end
	
	return 0
end

function UseSinisterGaze()
	if not SinisterGaze:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = SinisterGaze:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget)
			and not PAF.IsDisabled(BotTarget) then
				return BOT_ACTION_DESIRE_HIGH, BotTarget
			end
		end
	end
	
	return 0
end

function UseChainFrost()
	if not ChainFrost:IsFullyCastable() then return 0 end
	if not PAF.IsInTeamFight(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = ChainFrost:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	local BounceRange = ChainFrost:GetSpecialValueInt("jump_range")
	
	if BotTarget ~= nil then
		local EnemiesWithinBounceRange = BotTarget:GetNearbyHeroes(BounceRange, false, BOT_MODE_NONE)
		local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinBounceRange)
		
		if PAF.IsEngaging(bot) then
			if PAF.IsValidHeroAndNotIllusion(BotTarget) then
				if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
				and not PAF.IsMagicImmune(BotTarget)
				and #FilteredEnemies >= 2 then
					return BOT_ACTION_DESIRE_HIGH, BotTarget
				end
			end
		end
	end
	
	return 0
end

function UseIceSpire()
	if not IceSpire:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = IceSpire:GetCastRange()
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