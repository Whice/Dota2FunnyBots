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

local ParalyzingCask = bot:GetAbilityByName("witch_doctor_paralyzing_cask")
local VodooRestoration = bot:GetAbilityByName("witch_doctor_voodoo_restoration")
local Maledict = bot:GetAbilityByName("witch_doctor_maledict")
local VoodooSwitcheroo = bot:GetAbilityByName("witch_doctor_voodoo_switcheroo")
local DeathWard = bot:GetAbilityByName("witch_doctor_death_ward")

local ParalyzingCaskDesire = 0
local VodooRestorationDesire = 0
local MaledictDesire = 0
local VoodooSwitcherooDesire = 0
local DeathWardDesire = 0

local AttackRange
local BotTarget

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	-- The order to use abilities in
	ParalyzingCaskDesire, ParalyzingCaskTarget = UseParalyzingCask()
	if ParalyzingCaskDesire > 0 then
		bot:Action_UseAbilityOnEntity(ParalyzingCask, ParalyzingCaskTarget)
		return
	end
	
	MaledictDesire, MaledictTarget = UseMaledict()
	if MaledictDesire > 0 then
		bot:Action_UseAbilityOnLocation(Maledict, MaledictTarget)
		return
	end
	
	DeathWardDesire, DeathWardTarget = UseDeathWard()
	if DeathWardDesire > 0 then
		bot:Action_UseAbilityOnLocation(DeathWard, DeathWardTarget)
		return
	end
	
	VoodooSwitcherooDesire = UseVoodooSwitcheroo()
	if VoodooSwitcherooDesire > 0 then
		bot:Action_UseAbility(VoodooSwitcheroo)
		return
	end
	
	VodooRestorationDesire = UseVodooRestoration()
	if VodooRestorationDesire > 0 then
		bot:Action_UseAbility(VodooRestoration)
		return
	end
end

function UseParalyzingCask()
	if not ParalyzingCask:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = ParalyzingCask:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterUnitsForStun(EnemiesWithinRange)
	
	for v, enemy in pairs(FilteredEnemies) do
		if enemy:IsChanneling() then
			return BOT_ACTION_DESIRE_HIGH, enemy
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
	
	if P.IsRetreating(bot) and #EnemiesWithinRange > 0 then
		local ClosestTarget = PAF.GetClosestUnit(bot, EnemiesWithinRange)
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

function UseVodooRestoration()
	if not VodooRestoration:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = VodooRestoration:GetSpecialValueInt("radius")

	if bot:GetMana() < (bot:GetMaxMana() * 0.4) then
		if VodooRestoration:GetToggleState() == true then
			return BOT_ACTION_DESIRE_HIGH
		else
			return 0
		end
	end

	local AlliesWithinRange = bot:GetNearbyHeroes(CastRange, false, BOT_MODE_NONE)
	local FilteredAllies = PAF.FilterTrueUnits(AlliesWithinRange)
	
	for v, Ally in pairs(FilteredAllies) do
		if Ally:GetHealth() < (Ally:GetMaxHealth() * 0.8) then
			if VodooRestoration:GetToggleState() == false then
				return BOT_ACTION_DESIRE_HIGH
			else
				return 0
			end
		end
	end
	
	if VodooRestoration:GetToggleState() == true then
		return BOT_ACTION_DESIRE_HIGH
	else
		return 0
	end
	
	return 0
end

function UseMaledict()
	if not Maledict:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = Maledict:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	local Radius = Maledict:GetSpecialValueInt("radius")
	
	local AoE = bot:FindAoELocation(true, true, bot:GetLocation(), CastRange, Radius/2, 0, 0)
	if (AoE.count >= 2) then
		return BOT_ACTION_DESIRE_HIGH, AoE.targetloc
	end
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget) then
				return BOT_ACTION_DESIRE_HIGH, BotTarget:GetLocation()
			end
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		local AttackTarget = bot:GetAttackTarget()
		
		if PAF.IsRoshan(AttackTarget)
		and GetUnitToUnitDistance(bot, AttackTarget) <= CastRange then
			return BOT_ACTION_DESIRE_VERYHIGH, AttackTarget:GetLocation()
		end
	end
	
	return 0
end

function UseDeathWard()
	if not DeathWard:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = DeathWard:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	if PAF.IsInTeamFight(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange then
				return BOT_ACTION_DESIRE_HIGH, BotTarget:GetLocation()
			end
		end
	end
	
	return 0
end

function UseVoodooSwitcheroo()
	if not VoodooSwitcheroo:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= (AttackRange + 50) then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end
	
	return 0
end