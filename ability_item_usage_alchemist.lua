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
local AttackTarget
local ManaThreshold

local UCTime = 0

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
	UnstableConcoctionThrowDesire, UnstableConcoctionThrowTarget = UseUnstableConcoctionThrow()
	if UnstableConcoctionThrowDesire > 0 then
		UCTime = 0
		bot:Action_UseAbilityOnEntity(UnstableConcoctionThrow, UnstableConcoctionThrowTarget)
		return
	end
	
	UnstableConcoctionDesire, UnstableConcoctionTarget = UseUnstableConcoction()
	if UnstableConcoctionDesire > 0 then
		UCTime = DotaTime()
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbility(UnstableConcoction)
		return
	end
	
	ChemicalRageDesire = UseChemicalRage()
	if ChemicalRageDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbility(ChemicalRage)
		return
	end
	
	BerserkPotionDesire, BerserkPotionTarget = UseBerserkPotion()
	if BerserkPotionDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbilityOnEntity(BerserkPotion, BerserkPotionTarget)
		return
	end
	
	AcidSprayDesire, AcidSprayTarget = UseAcidSpray()
	if AcidSprayDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbilityOnLocation(AcidSpray, AcidSprayTarget)
		return
	end
end

function UseAcidSpray()
	if not AcidSpray:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = AcidSpray:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	local CastPoint = AcidSpray:GetCastPoint()
	local ManaCost = AcidSpray:GetManaCost()
	local Radius = AcidSpray:GetSpecialValueInt("radius")
	
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
	
	if PAF.IsInCreepAttackingMode(bot) then
		if PAF.IsValidCreepTarget(AttackTarget) then
			if AttackTarget:GetTeam() ~= bot:GetTeam()
			and PAF.ShouldCastAbilityToFarm(bot, ManaCost, ManaThreshold, false) then
				local AoELocation = bot:FindAoELocation(true, false, bot:GetLocation(), CastRange, Radius, 0, 0)
				
				if AoELocation.count >= 3 then
					return 1, AoELocation.targetloc
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

function UseUnstableConcoction()
	if not UnstableConcoction:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = UnstableConcoctionThrow:GetCastRange()
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange then
				return 1
			end
		end
	end
	
	return 0
end

function UseChemicalRage()
	if not ChemicalRage:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local ManaCost = ChemicalRage:GetManaCost()
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= 1200 then
				return 1
			end
		end
	end
	
	if PAF.IsInCreepAttackingMode(bot) then
		if PAF.IsValidCreepTarget(AttackTarget) then
			if AttackTarget:GetTeam() == TEAM_NEUTRAL
			and PAF.ShouldCastAbilityToFarm(bot, ManaCost, ManaThreshold, false) then
				local NeutralCreepsWithinRange = bot:GetNearbyNeutralCreeps(300)
				
				if #NeutralCreepsWithinCastRange >= 3 then
					return 1
				end
			end
		end
	end
	
	if bot:IsDisarmed()
	or bot:IsRooted()
	or bot:IsBlind()
	or (bot:GetCurrentMovementSpeed() <= 300 and not P.IsInLaningPhase()) then
		return 1
	end
	
	if bot:GetActiveMode() == BOT_MODE_RETREAT then
		local EnemiesWithinRange = PAF.GetNearbyFilteredHeroes(bot, 1200, true, BOT_MODE_NONE)
		local EnemyPower = PAF.CombineEnemyEstimatedOffensivePower(EnemiesWithinRange)
		
		if EnemyPower >= bot:GetHealth() then
			return 1
		end
	end
	
	return 0
end

function UseUnstableConcoctionThrow()
	if not UnstableConcoctionThrow:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	if UnstableConcoctionThrow:IsHidden() then return 0 end
	
	local CastRange = UnstableConcoctionThrow:GetCastRange()
	
	if (DotaTime() - UCTime) > 3 then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			return 1, BotTarget
		else -- If desperate to throw
			local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
			local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
			
			if #FilteredEnemies > 0 then
				local WeakestEnemy = PAF.GetWeakestUnit(FilteredEnemies)
				return 1, WeakestEnemy
			end
		end
	end
	
	if PAF.IsValidHeroAndNotIllusion(BotTarget) then
		if (DotaTime() - UCTime) >= 2 and GetUnitToUnitDistance(bot, BotTarget) > (CastRange - 200) then
			return 1, BotTarget
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
		return 1, bot
	end
	
	local AlliesWithinRange = bot:GetNearbyHeroes(CastRange, false, BOT_MODE_NONE)
	local FilteredAllies = PAF.FilterTrueUnits(AlliesWithinRange)
	
	local StrongestAlly = PAF.GetStrongestDPSUnit(FilteredAllies)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			return 1, StrongestAlly
		end
	end
	
	return 0
end