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

local Shrapnel = bot:GetAbilityByName("sniper_shrapnel")
local Headshot = bot:GetAbilityByName("sniper_headshot")
local TakeAim = bot:GetAbilityByName("sniper_take_aim")
local Assassinate = bot:GetAbilityByName("sniper_assassinate")
local ConcussiveGrenade = bot:GetAbilityByName("sniper_concussive_grenade")

local ShrapnelDesire = 0
local TakeAimDesire = 0
local AssassinateDesire = 0
local ConcussiveGrenadeDesire = 0

local AttackRange
local BotTarget

local LastShrapnelLoc = Vector(-99999, -99999, -99999)

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	-- The order to use abilities in
	AssassinateDesire, AssassinateTarget = UseAssassinate()
	if AssassinateDesire > 0 then
		bot:Action_UseAbilityOnEntity(Assassinate, AssassinateTarget)
		return
	end
	
	ConcussiveGrenadeDesire, ConcussiveGrenadeTarget = UseConcussiveGrenade()
	if ConcussiveGrenadeDesire > 0 then
		bot:Action_UseAbilityOnLocation(ConcussiveGrenade, ConcussiveGrenadeTarget)
		return
	end
	
	ShrapnelDesire, ShrapnelTarget = UseShrapnel()
	if ShrapnelDesire > 0 then
		bot:Action_UseAbilityOnLocation(Shrapnel, ShrapnelTarget)
		LastShrapnelLoc = ShrapnelTarget
		return
	end
	
	TakeAimDesire = UseTakeAim()
	if TakeAimDesire > 0 then
		bot:Action_UseAbility(TakeAim)
		return
	end
end

function UseShrapnel()
	if not Shrapnel:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = Shrapnel:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	local Radius = Shrapnel:GetSpecialValueInt("radius")
	local CastPoint = Shrapnel:GetCastPoint()
	local DamageDelay = Shrapnel:GetSpecialValueFloat("damage_delay")
	
	local ShouldCastShrapnel = false
	local target = nil
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange then
				target = BotTarget
			end
		end
	end
	
	if target == nil and bot:GetActiveMode() == BOT_MODE_ROSHAN then
		local AttackTarget = bot:GetAttackTarget()
		
		if PAF.IsRoshan(AttackTarget)
		and GetUnitToUnitDistance(bot, AttackTarget) <= CastRange then
			target = AttackTarget
		end
	end
	
	if target ~= nil then
		local distancediff = GetUnitToLocationDistance(target, LastShrapnelLoc)
		if distancediff > Radius then
			ShouldCastShrapnel = true
		end
	end
	
	if target ~= nil and ShouldCastShrapnel == true then
		return BOT_ACTION_DESIRE_HIGH, target:GetExtrapolatedLocation(CastPoint + DamageDelay)
	end
	
	return 0
end

function UseTakeAim()
	if not TakeAim:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local BonusRange = TakeAim:GetSpecialValueInt("bonus_attack_range")
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= (AttackRange + BonusRange) then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_FARM then
		local AttackTarget = bot:GetAttackTarget()
		
		if AttackTarget ~= nil and AttackTarget:IsCreep() then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		local AttackTarget = bot:GetAttackTarget()
		
		if PAF.IsRoshan(AttackTarget) then
			return BOT_ACTION_DESIRE_VERYHIGH
		end
	end
	
	return 0
end

function UseAssassinate()
	if not Assassinate:IsFullyCastable() then return 0 end
	if P.IsRetreating(bot) then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = Assassinate:GetCastRange()
	local CastPoint = Assassinate:GetCastPoint()
	local Damage = Assassinate:GetAbilityDamage()
	
	local Enemies = GetUnitList(UNIT_LIST_ENEMY_HEROES)
	local FilteredEnemies = PAF.FilterTrueUnits(Enemies)
	
	for v, Enemy in pairs(Enemies) do
		if GetUnitToUnitDistance(bot, Enemy) <= CastRange
		and not PAF.IsMagicImmune(Enemy) then
			local EstimatedDamage = Enemy:GetActualIncomingDamage(Damage, DAMAGE_TYPE_MAGICAL)
			
			if Enemy:GetHealth() <= EstimatedDamage then
				if GetUnitToUnitDistance(bot, Enemy) > AttackRange then
					return BOT_ACTION_DESIRE_HIGH, Enemy
				else
					if bot:IsDisarmed() then
						return BOT_ACTION_DESIRE_HIGH, Enemy
					end
				end
			end
		end
	end
	
	if PAF.IsEngaging(bot) then
		if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
		and not PAF.IsMagicImmune(BotTarget) then
			local EstimatedDamage = BotTarget:GetActualIncomingDamage(Damage, DAMAGE_TYPE_MAGICAL)
			
			if bot:IsDisarmed() then
				return BOT_ACTION_DESIRE_HIGH, BotTarget
			end
		end
	end
	
	return 0
end

function UseConcussiveGrenade()
	if not ConcussiveGrenade:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = ConcussiveGrenade:GetCastRange()
	
	local initenemies = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local enemies = PAF.FilterTrueUnits(initenemies)
	local target = PAF.GetWeakestUnit(enemies)
	
	if target ~= nil then
		return BOT_ACTION_DESIRE_HIGH, target:GetLocation()
	end
	
	return 0
end