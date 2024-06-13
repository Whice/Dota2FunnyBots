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

local BreatheFire = bot:GetAbilityByName("dragon_knight_breathe_fire")
local DragonTail = bot:GetAbilityByName("dragon_knight_dragon_tail")
local DragonBlood = bot:GetAbilityByName("dragon_knight_dragon_blood")
local ElderDragonForm = bot:GetAbilityByName("dragon_knight_elder_dragon_form")
local Fireball = bot:GetAbilityByName("dragon_knight_fireball")

local BreatheFireDesire = 0
local DragonTailDesire = 0
local ElderDragonFormDesire = 0
local FireballDesire = 0

local AttackRange
local BotTarget
local manathreshold = 0

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()

	manathreshold = 100
	manathreshold = manathreshold + BreatheFire:GetManaCost()
	manathreshold = manathreshold + DragonTail:GetManaCost()
	manathreshold = manathreshold + ElderDragonForm:GetManaCost()
	manathreshold = manathreshold + Fireball:GetManaCost()
	
	-- The order to use abilities in
	ElderDragonFormDesire = UseElderDragonForm()
	if ElderDragonFormDesire > 0 then
		bot:Action_UseAbility(ElderDragonForm)
		return
	end
	
	DragonTailDesire, DragonTailTarget = UseDragonTail()
	if DragonTailDesire > 0 then
		bot:Action_UseAbilityOnEntity(DragonTail, DragonTailTarget)
		return
	end
	
	FireballDesire, FireballTarget = UseFireball()
	if FireballDesire > 0 then
		bot:Action_UseAbilityOnLocation(Fireball, FireballTarget)
		return
	end
	
	BreatheFireDesire, BreatheFireTarget = UseBreatheFire()
	if BreatheFireDesire > 0 then
		bot:Action_UseAbilityOnLocation(BreatheFire, BreatheFireTarget)
		return
	end
end

function UseBreatheFire()
	if not BreatheFire:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = BreatheFire:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange and not PAF.IsMagicImmune(BotTarget) then
				return BOT_ACTION_DESIRE_HIGH, BotTarget:GetLocation()
			end
		end
	end
	
	local AttackTarget = bot:GetAttackTarget()
	
	if bot:GetActiveMode() == BOT_MODE_FARM then
		local Neutrals = bot:GetNearbyNeutralCreeps(CastRange)
	
		if AttackTarget ~= nil 
		and AttackTarget:IsCreep() 
		and #Neutrals >= 2
		and (bot:GetMana() - BreatheFire:GetManaCost()) > manathreshold
		and GetUnitToUnitDistance(bot, AttackTarget) <= CastRange then
			return BOT_ACTION_DESIRE_HIGH, AttackTarget:GetLocation()
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		if AttackTarget ~= nil and PAF.IsRoshan(AttackTarget) then
			return BOT_ACTION_DESIRE_HIGH, AttackTarget:GetLocation()
		end
	end
	
	return 0
end

function UseDragonTail()
	if not DragonTail:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = 0
	
	if bot:HasModifier("modifier_dragon_knight_dragon_form") then
		CastRange = DragonTail:GetSpecialValueInt("dragon_cast_range")
	else
		CastRange = DragonTail:GetCastRange()
	end
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterUnitsForStun(EnemiesWithinRange)
	
	for v, enemy in pairs(FilteredEnemies) do
		if enemy:IsChanneling() then
			return BOT_ACTION_DESIRE_HIGH, enemy
		end
	end
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange then
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

function UseElderDragonForm()
	if not ElderDragonForm:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	
	if PAF.IsEngaging(bot) and #FilteredEnemies > 0 then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	local attacktarget = bot:GetAttackTarget()
	
	if attacktarget ~= nil then
		if attacktarget:IsBuilding() then
			return BOT_ACTION_DESIRE_HIGH
		end
		
		if bot:GetActiveMode() == BOT_MODE_ROSHAN and PAF.IsRoshan(attacktarget) then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	return 0
end

function UseFireball()
	if not Fireball:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = 0
	
	if bot:HasModifier("modifier_dragon_knight_dragon_form") then
		CastRange = Fireball:GetSpecialValueInt("dragon_form_cast_range")
	else
		CastRange = Fireball:GetCastRange()
	end
	
	local Radius = Fireball:GetSpecialValueInt("radius")
	
	if PAF.IsEngaging(bot) then
		local AoE = bot:FindAoELocation(true, true, bot:GetLocation(), CastRange, Radius/2, 0, 0)
		if (AoE.count >= 2) then
			return BOT_ACTION_DESIRE_HIGH, AoE.targetloc;
		end
	end
	
	return 0
end