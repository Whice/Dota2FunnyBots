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

local Illuminate = bot:GetAbilityByName("keeper_of_the_light_illuminate")
local SpiritFormIlluminate = bot:GetAbilityByName("keeper_of_the_light_spirit_form_illuminate")
local BlindingLight = bot:GetAbilityByName("keeper_of_the_light_blinding_light")
local ChakraMagic = bot:GetAbilityByName("keeper_of_the_light_chakra_magic")
local SpiritForm = bot:GetAbilityByName("keeper_of_the_light_spirit_form")
local SolarBind = bot:GetAbilityByName("keeper_of_the_light_radiant_bind")
local WillOWisp = bot:GetAbilityByName("keeper_of_the_light_will_o_wisp")
local Recall = bot:GetAbilityByName("keeper_of_the_light_recall")

local IlluminateDesire = 0
local BlindingLightDesire = 0
local ChakraMagicDesire = 0
local SpiritFormDesire = 0
local SolarBindDesire = 0
local WillOWispDesire = 0
local RecallDesire = 0

local AttackRange
local BotTarget

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	-- The order to use abilities in
	SpiritFormDesire = UseSpiritForm()
	if SpiritFormDesire > 0 then
		bot:Action_UseAbility(SpiritForm)
		return
	end
	
	if not SpiritFormIlluminate:IsHidden() then
		IlluminateDesire, SpiritFormIlluminateTarget = UseIlluminate()
		if IlluminateDesire > 0 then
			bot:Action_UseAbilityOnLocation(SpiritFormIlluminate, SpiritFormIlluminateTarget)
			return
		end
	end
	
	BlindingLightDesire, BlindingLightTarget = UseBlindingLight()
	if BlindingLightDesire > 0 then
		bot:Action_UseAbilityOnLocation(BlindingLight, BlindingLightTarget)
		return
	end
	
	SolarBindDesire, SolarBindTarget = UseSolarBind()
	if SolarBindDesire > 0 then
		bot:Action_UseAbilityOnEntity(SolarBind, SolarBindTarget)
		return
	end
	
	WillOWispDesire, WillOWispTarget = UseWillOWisp()
	if WillOWispDesire > 0 then
		bot:Action_UseAbilityOnLocation(WillOWisp, WillOWispTarget)
		return
	end
	
	ChakraMagicDesire, ChakraMagicTarget = UseChakraMagic()
	if ChakraMagicDesire > 0 then
		bot:Action_UseAbilityOnEntity(ChakraMagic, ChakraMagicTarget)
		return
	end
	
	RecallDesire, RecallTarget = UseRecall()
	if RecallDesire > 0 then
		bot:Action_UseAbilityOnEntity(Recall, RecallTarget)
		return
	end
	
	if not Illuminate:IsHidden() then
		IlluminateDesire, IlluminateTarget = UseIlluminate()
		if IlluminateDesire > 0 then
			bot:Action_UseAbilityOnLocation(Illuminate, IlluminateTarget)
			return
		end
	end
end

function UseIlluminate()
	if P.CantUseAbility(bot) then return 0 end
	
	if Illuminate:IsFullyCastable() or SpiritFormIlluminate:IsFullyCastable() then
		local CR = Illuminate:GetCastRange()
		local CastRange = PAF.GetProperCastRange(CR)
		local Radius = Illuminate:GetSpecialValueInt("radius")
		
		if PAF.IsInTeamFight(bot) then
			local AoE = bot:FindAoELocation(true, true, bot:GetLocation(), CastRange, Radius/2, 0, 0)
			if (AoE.count >= 2) then
				return BOT_ACTION_DESIRE_HIGH, AoE.targetloc
			end
		end
		
		if bot:GetActiveMode() == BOT_MODE_ROSHAN then
			local AttackTarget = bot:GetAttackTarget()
			
			if PAF.IsRoshan(AttackTarget)
			and GetUnitToUnitDistance(bot, AttackTarget) <= CastRange then
				return BOT_ACTION_DESIRE_VERYHIGH, AttackTarget:GetLocation()
			end
		end
	end
	
	return 0
end

function UseBlindingLight()
	if not BlindingLight:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = BlindingLight:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	local Radius = BlindingLight:GetSpecialValueInt("radius")
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterUnitsForStun(EnemiesWithinRange)
	
	if PAF.IsInTeamFight(bot) then
		local AoE = bot:FindAoELocation(true, true, bot:GetLocation(), CastRange, Radius/2, 0, 0)
		if (AoE.count >= 2) then
			return BOT_ACTION_DESIRE_HIGH, AoE.targetloc
		end
	end
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget)
			and not PAF.IsDisabled(BotTarget) then
				return BOT_ACTION_DESIRE_HIGH, BotTarget
			end
		end
	end
	
	if P.IsRetreating(bot) and #FilteredEnemies > 0 then
		local ClosestTarget = PAF.GetClosestUnit(bot, FilteredEnemies)
		return BOT_ACTION_DESIRE_HIGH, ClosestTarget:GetXUnitsTowardsLocation(bot, (Radius / 2))
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

function UseChakraMagic()
	if not ChakraMagic:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = ChakraMagic:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local AlliesWithinRange = bot:GetNearbyHeroes(CastRange, false, BOT_MODE_NONE)
	local FilteredAllies = PAF.FilterTrueUnits(AlliesWithinRange)
	
	local LowestManaHero = nil
	local LowestManaPct = 1.0
	
	for v, Ally in pairs(FilteredAllies) do
		local ManaPct = (Ally:GetMana() / Ally:GetMaxMana())
		if ManaPct < LowestManaPct then
			LowestManaHero = Ally
			LowestManaPct = ManaPct
		end
	end
	
	if LowestManaHero ~= nil and LowestManaPct <= 0.5 then
		return BOT_ACTION_DESIRE_HIGH, LowestManaHero
	end
	
	return 0
end

function UseSpiritForm()
	if not SpiritForm:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= 1600 then
				return BOT_ACTION_DESIRE_HIGH, BotTarget
			end
		end
	end
	
	return 0
end

function UseSolarBind()
	if not SolarBind:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	if SolarBind:IsHidden() then return 0 end
	
	local CR = SolarBind:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterUnitsForStun(EnemiesWithinRange)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget) then
				return BOT_ACTION_DESIRE_HIGH, BotTarget
			end
		end
	end
	
	if P.IsRetreating(bot) and #FilteredEnemies > 0 then
		local ClosestTarget = PAF.GetClosestUnit(bot, FilteredEnemies)
		return BOT_ACTION_DESIRE_HIGH, ClosestTarget
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

function UseWillOWisp()
	if not WillOWisp:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = WillOWisp:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	local Radius = WillOWisp:GetSpecialValueInt("radius")
	
	if PAF.IsInTeamFight(bot) then
		local AoE = bot:FindAoELocation(true, true, bot:GetLocation(), CastRange, Radius/2, 0, 0)
		if (AoE.count >= 2) then
			return BOT_ACTION_DESIRE_HIGH, AoE.targetloc
		end
	end
	
	return 0
end

function UseRecall()
	if not Recall:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local Allies = GetUnitList(UNIT_LIST_ALLIED_HEROES)
	local FilteredAllies = PAF.FilterTrueUnits(Allies)
	
	if bot:DistanceFromFountain() <= 1600 then
		for v, Ally in pairs(FilteredAllies) do
			if P.IsRetreating(Ally)
			and Ally:GetHealth() <= (Ally:GetMaxHealth() * 0.5)
			and not Ally:WasRecentlyDamagedByAnyHero(2)
			and Ally:DistanceFromFountain() > 1600 then
				return BOT_ACTION_DESIRE_HIGH, Ally
			end
		end
	end
	
	return 0
end