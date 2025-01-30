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

local FrostArrows = bot:GetAbilityByName("drow_ranger_frost_arrows")
local Gust = bot:GetAbilityByName("drow_ranger_wave_of_silence")
local Multishot = bot:GetAbilityByName("drow_ranger_multishot")
local Marksmanship = bot:GetAbilityByName("drow_ranger_marksmanship")
local Glacier = bot:GetAbilityByName("drow_ranger_glacier")

local FrostArrowsDesire = 0
local GustDesire = 0
local MultishotDesire = 0
local GlacierDesire = 0

local AttackRange
local BotTarget

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	-- The order to use abilities in
	GustDesire, GustTarget = UseGust()
	if GustDesire > 0 then
		bot:Action_UseAbilityOnLocation(Gust, GustTarget)
		return
	end
	
	GlacierDesire = UseGlacier()
	if GlacierDesire > 0 then
		bot:Action_UseAbility(Glacier)
		return
	end
	
	MultishotDesire, MultishotTarget = UseMultishot()
	if MultishotDesire > 0 then
		bot:Action_UseAbilityOnLocation(Multishot, MultishotTarget)
		return
	end
	
	FrostArrowsDesire, FrostArrowsTarget = UseFrostArrows()
	if FrostArrowsDesire > 0 then
		bot:Action_UseAbilityOnEntity(FrostArrows, FrostArrowsTarget)
		return
	end
end

function UseFrostArrows()
	if not FrostArrows:IsFullyCastable() or bot:IsDisarmed() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = FrostArrows:GetCastRange()
	
	if P.IsInLaningPhase() then
		local EnemiesWithinRange = bot:GetNearbyHeroes((AttackRange + 50), true, BOT_MODE_NONE)
		local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
		local WeakestEnemy = PAF.GetWeakestUnit(FilteredEnemies)
		
		if WeakestEnemy ~= nil
		and not PAF.IsPhysicalImmune(WeakestEnemy)
		and not P.IsRetreating(bot) then
			return BOT_ACTION_DESIRE_HIGH, WeakestEnemy
		end
	end
	
	local target = bot:GetAttackTarget()
	
	if target ~= nil
	and target:IsHero()
	and not P.IsRetreating(bot) then
		if FrostArrows:GetAutoCastState() == false then
			FrostArrows:ToggleAutoCast()
			return 0
		end
	end
	
	if target == nil then
		if FrostArrows:GetAutoCastState() == true then
			FrostArrows:ToggleAutoCast()
			return 0
		end
	else
		if not target:IsHero() then
			if FrostArrows:GetAutoCastState() == true then
				FrostArrows:ToggleAutoCast()
				return 0
			end
		end
	end
	
	return 0
end

function UseGust()
	if not Gust:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = Gust:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterUnitsForStun(EnemiesWithinRange)
	
	for v, enemy in pairs(FilteredEnemies) do
		if enemy:IsChanneling() then
			return BOT_ACTION_DESIRE_HIGH, enemy:GetLocation()
		end
	end
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not BotTarget:IsSilenced()
			and not BotTarget:IsMuted() then
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

function UseMultishot()
	if not Multishot:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local Radius = 250
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= (AttackRange + 50) then
				return BOT_ACTION_DESIRE_HIGH, BotTarget:GetLocation()
			end
		end
	end
	
	local AttackTarget = bot:GetAttackTarget()
	
	if AttackTarget ~= nil and not P.IsInLaningPhase() then
		if AttackTarget:IsCreep() then
			local NearbyCreeps = bot:GetNearbyCreeps(1600, true)
			local AoECount = PAF.GetUnitsNearTarget(AttackTarget:GetLocation(), NearbyCreeps, Radius)
			
			if AoECount >= 3 and bot:GetMana() > (bot:GetMaxMana() * 0.6) then
				return BOT_ACTION_DESIRE_HIGH, AttackTarget:GetLocation()
			end
		end
		
		if bot:GetActiveMode() == BOT_MODE_ROSHAN and PAF.IsRoshan(AttackTarget) then
			return BOT_ACTION_DESIRE_HIGH, AttackTarget:GetLocation()
		end
	end
	
	return 0
end

function UseGlacier()
	if not Glacier:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	if PAF.IsInTeamFight(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= (AttackRange + 50) then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end
	
	return 0
end