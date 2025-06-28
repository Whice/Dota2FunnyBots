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
local AttackTarget
local ManaThreshold

local LastShrapnelLoc = Vector(-99999, -99999, -99999)
local LastShrapnelTime = -90

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
	AssassinateDesire, AssassinateTarget = UseAssassinate()
	if AssassinateDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbilityOnEntity(Assassinate, AssassinateTarget)
		return
	end
	
	ConcussiveGrenadeDesire, ConcussiveGrenadeTarget = UseConcussiveGrenade()
	if ConcussiveGrenadeDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbilityOnLocation(ConcussiveGrenade, ConcussiveGrenadeTarget)
		return
	end
	
	ShrapnelDesire, ShrapnelTarget = UseShrapnel()
	if ShrapnelDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbilityOnLocation(Shrapnel, ShrapnelTarget)
		LastShrapnelTime = DotaTime()
		LastShrapnelLoc = ShrapnelTarget
		return
	end
	
	TakeAimDesire = UseTakeAim()
	if TakeAimDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbility(TakeAim)
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
	local RestoreTime = Shrapnel:GetSpecialValueInt("AbilityChargeRestoreTime")
	local ExtrapolateTime = (CastPoint + DamageDelay)
	local ManaCost = Shrapnel:GetManaCost()
	
	local EnemiesWithinCastRange = PAF.GetNearbyFilteredHeroes(bot, CastRange, true, BOT_MODE_NONE)
	
	if PAF.IsInTeamFight(bot) then
		local AoELocation = bot:FindAoELocation(true, true, bot:GetLocation(), CastRange, Radius, ExtrapolateTime, 0)
		
		if AoELocation.count >= 2
		and (DotaTime() - LastShrapnelTime) >= 3 then
			return 1, AoELocation.targetloc
		end
	elseif PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget) then
				local ExtrapolatedLocation = BotTarget:GetExtrapolatedLocation(ExtrapolateTime)
				
				if GetUnitToLocationDistance(bot, ExtrapolatedLocation) <= CastRange
				and GetUnitToLocationDistance(BotTarget, LastShrapnelLoc) > Radius
				and (DotaTime() - LastShrapnelTime) >= ExtrapolateTime then
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
				
				if AoELocation.count >= 3
				and (DotaTime() - LastShrapnelTime) >= RestoreTime then
					return 1, AoELocation.targetloc
				end
			end
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		if PAF.IsRoshan(AttackTarget)
		and (DotaTime() - LastShrapnelTime) >= RestoreTime then
			return 1, AttackTarget:GetLocation()
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_SIDE_SHOP then
		if PAF.IsTormentor(AttackTarget)
		and (DotaTime() - LastShrapnelTime) >= RestoreTime then
			return 1, AttackTarget:GetLocation()
		end
	end
	
	return 0
end

function UseTakeAim()
	if not TakeAim:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local BonusRange = TakeAim:GetSpecialValueInt("active_attack_range_bonus")
	local TotalAttackRange = (AttackRange + BonusRange)
	local ManaCost = TakeAim:GetManaCost()
	
	if PAF.IsInTeamFight(bot) then
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
				local CreepsWithinAttackRange = bot:GetNearbyCreeps(TotalAttackRange, true)
				
				if #CreepsWithinAttackRange >= 3 then
					return 1
				end
			end
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
	local Damage = Assassinate:GetSpecialValueInt("damage")
	
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
	local Radius = ConcussiveGrenade:GetSpecialValueInt("radius")
	
	local EnemiesWithinCastRange = PAF.GetNearbyFilteredHeroes(bot, CastRange, true, BOT_MODE_NONE)
	local ClosestEnemy = PAF.GetClosestUnit(bot, EnemiesWithinCastRange)
	
	if ClosestEnemy ~= nil then
		return 1, PAF.GetXUnitsTowardsLocation(ClosestEnemy:GetLocation(), bot:GetLocation(), (Radius / 2))
	end
	
	return 0
end