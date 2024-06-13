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

local ArcticBurn = bot:GetAbilityByName("winter_wyvern_arctic_burn")
local SplinterBlast = bot:GetAbilityByName("winter_wyvern_splinter_blast")
local ColdEmbrace = bot:GetAbilityByName("winter_wyvern_cold_embrace")
local WintersCurse = bot:GetAbilityByName("winter_wyvern_winters_curse")

local ArcticBurnDesire = 0
local SplinterBlastDesire = 0
local ColdEmbraceDesire = 0
local WintersCurseDesire = 0

local AttackRange
local BotTarget

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	-- The order to use abilities in
	WintersCurseDesire, WintersCurseTarget = UseWintersCurse()
	if WintersCurseDesire > 0 then
		bot:Action_UseAbilityOnEntity(WintersCurse, WintersCurseTarget)
		return
	end
	
	ColdEmbraceDesire, ColdEmbraceTarget = UseColdEmbrace()
	if ColdEmbraceDesire > 0 then
		bot:Action_UseAbilityOnEntity(ColdEmbrace, ColdEmbraceTarget)
		return
	end
	
	SplinterBlastDesire, SplinterBlastTarget = UseSplinterBlast()
	if SplinterBlastDesire > 0 then
		bot:Action_UseAbilityOnEntity(SplinterBlast, SplinterBlastTarget)
		return
	end
	
	ArcticBurnDesire = UseArcticBurn()
	if ArcticBurnDesire > 0 then
		bot:Action_UseAbility(ArcticBurn)
		return
	end
end

function UseArcticBurn()
	if not ArcticBurn:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local AttackRangeBonus = ArcticBurn:GetSpecialValueInt("attack_range_bonus")
	local CastRange = ((bot:GetAttackRange() + AttackRangeBonus) + 200)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget) then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end
	
	if P.IsRetreating(bot) then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		local AttackTarget = bot:GetAttackTarget()
		
		if PAF.IsRoshan(AttackTarget)
		and GetUnitToUnitDistance(bot, AttackTarget) <= CastRange then
			return BOT_ACTION_DESIRE_VERYHIGH
		end
	end
	
	return 0
end

function UseSplinterBlast()
	if not SplinterBlast:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = SplinterBlast:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	local SplitRadius = SplinterBlast:GetSpecialValueInt("split_radius")
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget) then
				local CreepsNearTarget = BotTarget:GetNearbyCreeps(SplitRadius, false)
				if CreepsNearTarget ~= nil and #CreepsNearTarget > 0 then
					return BOT_ACTION_DESIRE_HIGH, CreepsNearTarget[1]
				end
				
				local HeroesNearTarget = BotTarget:GetNearbyHeroes(SplitRadius, false, BOT_MODE_NONE)
				if HeroesNearTarget ~= nil and #HeroesNearTarget > 1 then
					return BOT_ACTION_DESIRE_HIGH, HeroesNearTarget[2]
				end
			end
		end
	end
	
	return 0
end

function UseColdEmbrace()
	if not ColdEmbrace:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = ColdEmbrace:GetCastRange()
	local BaseHeal = ColdEmbrace:GetSpecialValueInt("heal_additive")
	local HealPercentage = (ColdEmbrace:GetSpecialValueInt("heal_percentage") / 100)
	local HealDuration = ColdEmbrace:GetSpecialValueInt("duration")
	
	local AlliesWithinRange = bot:GetNearbyHeroes(CastRange, false, BOT_MODE_NONE)
	local FilteredAllies = PAF.FilterTrueUnits(AlliesWithinRange)
	
	local WeakestAlly = PAF.GetWeakestUnit(FilteredAllies)
	
	if WeakestAlly ~= nil then
		if WeakestAlly:IsChanneling() then return 0 end
	
		if WeakestAlly:GetHealth() < (WeakestAlly:GetMaxHealth() * 0.4)
		and WeakestAlly:WasRecentlyDamagedByAnyHero(1) then
			return BOT_ACTION_DESIRE_HIGH, WeakestAlly
		end
	
		local HealPercentRegen = (WeakestAlly:GetMaxHealth() * HealPercentage)
		local TotalCEHeal = ((BaseHeal + HealPercentRegen) * HealDuration)
	
		local AllyHPRegen = WeakestAlly:GetHealthRegen()
		local AllyHPRegenTotalHeal = (AllyHPRegen * HealDuration)
		
		local TotalHeal = (TotalCEHeal + AllyHPRegenTotalHeal)
		
		local EnemiesWithinRange = WeakestAlly:GetNearbyHeroes(1000, true, BOT_MODE_NONE)
		local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
		
		if WeakestAlly:GetHealth() < (WeakestAlly:GetMaxHealth() - TotalHeal)
		and #FilteredEnemies <= 0 then
			return BOT_ACTION_DESIRE_HIGH, WeakestAlly
		end
	end
	
	return 0
end

function UseWintersCurse()
	if not WintersCurse:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = WintersCurse:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	local CurseRadius = WintersCurse:GetSpecialValueInt("radius")
	local CurseDuration = WintersCurse:GetSpecialValueFloat("duration")
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	
	local AlliesWithinRange = bot:GetNearbyHeroes(CastRange, false, BOT_MODE_NONE)
	local FilteredAllies = PAF.FilterTrueUnits(AlliesWithinRange)
	
	if #FilteredEnemies > 0 then
		local PotentialTargets = {}
		
		for v, Enemy in pairs(FilteredEnemies) do
			local HeroesNearTarget = Enemy:GetNearbyHeroes(CurseRadius, false, BOT_MODE_NONE)
			
			local TotalEstimatedDamage = 0
			
			if HeroesNearTarget ~= nil and #HeroesNearTarget > 0 then
				for v, HNT in pairs(HeroesNearTarget) do
					if HNT ~= Enemy then
						local EstDmg = HNT:GetEstimatedDamageToTarget(false, Enemy, CurseDuration, DAMAGE_TYPE_PHYSICAL)
						TotalEstimatedDamage = (TotalEstimatedDamage + EstDmg)
					end
				end
			end
			
			if Enemy:GetHealth() < TotalEstimatedDamage then
				table.insert(PotentialTargets, Enemy)
			end
		end
		
		local StrongestPotentialTarget = nil
		if #PotentialTargets > 0 then
			StrongestPotentialTarget = PAF.GetStrongestPowerUnit(PotentialTargets)
		end
		
		if #AlliesWithinRange <= 1 and StrongestPotentialTarget ~= nil then
			return BOT_ACTION_DESIRE_HIGH, StrongestPotentialTarget
		end
	end
	
	if P.IsRetreating(bot) then
		if #FilteredAllies <= #FilteredEnemies then
			local ShouldCurse = true
		
			for v, Ally in pairs(FilteredAllies) do
				if not Ally:IsFacingLocation(PAF.GetFountainLocation(bot), 45) then
					ShouldCurse = false
				end
			end
			
			if ShouldCurse then
				if StrongestPotentialTarget ~= nil then
					return BOT_ACTION_DESIRE_HIGH, StrongestPotentialTarget
				else
					return BOT_ACTION_DESIRE_HIGH, PAF.GetWeakestUnit(FilteredEnemies)
				end
			end
		end
	end
	
	return 0
end