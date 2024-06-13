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

local AcidSpray = bot:GetAbilityByName("alchemist_acid_spray")
local UnstableConcoction = bot:GetAbilityByName("alchemist_unstable_concoction")
local CorrosiveWeaponry = bot:GetAbilityByName("alchemist_corrosive_weaponry")
local ChemicalRage = bot:GetAbilityByName("alchemist_chemical_rage")
local BerserkPotion = bot:GetAbilityByName("alchemist_berserk_potion")
local UnstableConcoctionThrow = bot:GetAbilityByName("alchemist_unstable_concoction_throw")

local AcidSprayDesire = 0
local UnstableConcoctionDesire = 0
local ChemicalRageDesire = 0
local BerserkPotionDesire = 0
local UnstableConcoctionThrowDesire = 0

local AttackRange
local BotTarget
local AttackRange = 0

local UCTime = 0

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	-- The order to use abilities in
	UnstableConcoctionThrowDesire, UnstableConcoctionThrowTarget = UseUnstableConcoctionThrow()
	if UnstableConcoctionThrowDesire > 0 then
		UCTime = 0
		bot:Action_UseAbilityOnEntity(UnstableConcoctionThrow, UnstableConcoctionThrowTarget)
		return
	end
	
	UnstableConcoctionDesire, UnstableConcoctionTarget = UseUnstableConcoction()
	if UnstableConcoctionDesire > 0 then
		UCTime = DotaTime()
		bot:Action_UseAbility(UnstableConcoction)
		return
	end
	
	ChemicalRageDesire = UseChemicalRage()
	if ChemicalRageDesire > 0 then
		bot:Action_UseAbility(ChemicalRage)
		return
	end
	
	BerserkPotionDesire, BerserkPotionTarget = UseBerserkPotion()
	if BerserkPotionDesire > 0 then
		bot:Action_UseAbilityOnEntity(BerserkPotion, BerserkPotionTarget)
		return
	end
	
	AcidSprayDesire, AcidSprayTarget = UseAcidSpray()
	if AcidSprayDesire > 0 then
		bot:Action_UseAbilityOnLocation(AcidSpray, AcidSprayTarget)
		return
	end
end

function UseAcidSpray()
	if not AcidSpray:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = AcidSpray:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	local AcidRadius = AcidSpray:GetSpecialValueInt("radius")
	
	if PAF.IsEngaging(bot) then
		local AoE = bot:FindAoELocation(true, true, bot:GetLocation(), CastRange, AcidRadius/2, 0, 0)
		if (AoE.count >= 1) then
			return BOT_ACTION_DESIRE_HIGH, AoE.targetloc
		end
	end
	
	local AttackTarget = bot:GetAttackTarget()
	
	if AttackTarget ~= nil then
		if bot:GetActiveMode() == BOT_MODE_FARM then
			local NearbyCreeps = bot:GetNearbyCreeps((CastRange + AcidRadius), true)
			local AoECount = PAF.GetUnitsNearTarget(AttackTarget:GetLocation(), NearbyCreeps, AcidRadius)
			
			if AoECount >= 3 then
				return BOT_ACTION_DESIRE_HIGH, AttackTarget:GetLocation()
			end
		end
		
		if bot:GetActiveMode() == BOT_MODE_ROSHAN then
			if PAF.IsRoshan(AttackTarget) then
				return BOT_ACTION_DESIRE_HIGH, AttackTarget:GetLocation()
			end
		end
	end
	
	return 0
end

function UseUnstableConcoction()
	if not UnstableConcoction:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = UnstableConcoctionThrow:GetCastRange()
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end
	
	return 0
end

function UseChemicalRage()
	if not ChemicalRage:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= 500 then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end
	
	return 0
end

function UseUnstableConcoctionThrow()
	if not UnstableConcoctionThrow:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	if UnstableConcoctionThrow:IsHidden() then return 0 end
	
	local CastRange = UnstableConcoctionThrow:GetCastRange()
	
	if (DotaTime() - UCTime) > 5 then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			return BOT_ACTION_DESIRE_HIGH, BotTarget
		else -- If desperate to throw
			local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
			local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
			
			if #FilteredEnemies > 0 then
				local WeakestEnemy = PAF.GetWeakestUnit(FilteredEnemies)
				return BOT_ACTION_DESIRE_HIGH, WeakestEnemy
			end
		end
	end
	
	if PAF.IsValidHeroAndNotIllusion(BotTarget) then
		if (DotaTime() - UCTime) >= 2 and GetUnitToUnitDistance(bot, BotTarget) > (CastRange - 150) then
			return BOT_ACTION_DESIRE_HIGH, BotTarget
		end
	end
	
	return 0
end

function UseBerserkPotion()
	if not BerserkPotion:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = BerserkPotion:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	
	if P.IsRetreating(bot) and #FilteredEnemies > 0 then
		return BOT_ACTION_DESIRE_HIGH, bot
	end
	
	local AlliesWithinRange = bot:GetNearbyHeroes(CastRange, false, BOT_MODE_NONE)
	local FilteredAllies = PAF.FilterTrueUnits(AlliesWithinRange)
	
	local StrongestAlly = PAF.GetStrongestAttackDamageUnit(FilteredAllies)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			return BOT_ACTION_DESIRE_HIGH, StrongestAlly
		end
	end
	
	return 0
end