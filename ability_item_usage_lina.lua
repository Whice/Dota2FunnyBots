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

local DragonSlave = bot:GetAbilityByName("lina_dragon_slave")
local LightStrikeArray = bot:GetAbilityByName("lina_light_strike_array")
local FierySoul = bot:GetAbilityByName("lina_fiery_soul")
local LagunaBlade = bot:GetAbilityByName("lina_laguna_blade")
local FlameCloak = bot:GetAbilityByName("lina_flame_cloak")

local DragonSlaveDesire = 0
local LightStrikeArrayDesire = 0
local LagunaBladeDesire = 0
local FlameCloakDesire = 0

local AttackRange
local BotTarget
local AttackTarget
local ManaThreshold

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
	FlameCloakDesire = UseFlameCloak()
	if FlameCloakDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbility(FlameCloak)
		return
	end
	
	LagunaBladeDesire, LagunaBladeTarget = UseLagunaBlade()
	if LagunaBladeDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbilityOnEntity(LagunaBlade, LagunaBladeTarget)
		return
	end
	
	LightStrikeArrayDesire, LightStrikeArrayTarget = UseLightStrikeArray()
	if LightStrikeArrayDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbilityOnLocation(LightStrikeArray, LightStrikeArrayTarget)
		return
	end
	
	DragonSlaveDesire, DragonSlaveTarget = UseDragonSlave()
	if DragonSlaveDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbilityOnLocation(DragonSlave, DragonSlaveTarget)
		return
	end
end

function UseDragonSlave()
	if not DragonSlave:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = DragonSlave:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	local CastPoint = DragonSlave:GetCastPoint()
	local Radius = DragonSlave:GetSpecialValueInt("dragon_slave_width_initial")
	local Damage = DragonSlave:GetSpecialValueInt("dragon_slave_damage")
	local Speed = DragonSlave:GetSpecialValueInt("dragon_slave_speed")
	local ManaCost = DragonSlave:GetManaCost()
	local DamageType = DragonSlave:GetDamageType()
	
	local EnemiesWithinCastRange = PAF.GetNearbyFilteredHeroes(bot, CastRange, true, BOT_MODE_NONE)
	
	for x, Enemy in pairs(EnemiesWithinCastRange) do
		if PAF.CanDamageKillEnemy(Enemy, Damage, DamageType) then
			local ExtrapolateTime = (CastPoint + (GetUnitToUnitDistance(bot, Enemy) / Speed))
			local ExtrapolatedLocation = Enemy:GetExtrapolatedLocation(ExtrapolateTime)
				
			if GetUnitToLocationDistance(bot, ExtrapolatedLocation) <= CastRange then
				return 1, ExtrapolatedLocation
			end
		end
	end
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget) then
				local ExtrapolateTime = (CastPoint + (GetUnitToUnitDistance(bot, BotTarget) / Speed))
				local ExtrapolatedLocation = BotTarget:GetExtrapolatedLocation(ExtrapolateTime)
				
				if GetUnitToLocationDistance(bot, ExtrapolatedLocation) <= CastRange then
					return 1, ExtrapolatedLocation
				end
			end
		end
	end
	
	if P.IsInLaningPhase()
	and bot:GetActiveMode() == BOT_MODE_LANING then
		local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
		local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	
		for v, enemy in pairs(FilteredEnemies) do
			if PAF.CanLastHitCreepAndHarass(bot, enemy, Radius, Damage, DAMAGE_TYPE_MAGICAL) then
				return BOT_ACTION_DESIRE_HIGH, enemy:GetLocation()
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

function UseLightStrikeArray()
	if not LightStrikeArray:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = LightStrikeArray:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	local CastPoint = LightStrikeArray:GetCastPoint()
	local Radius = LightStrikeArray:GetSpecialValueInt("light_strike_array_aoe")
	local Damage = LightStrikeArray:GetSpecialValueInt("light_strike_array_damage")
	local Delay = LightStrikeArray:GetSpecialValueFloat("light_strike_array_delay_time")
	local ManaCost = LightStrikeArray:GetManaCost()
	local DamageType = LightStrikeArray:GetDamageType()
	local ExtrapolateTime = (CastPoint + Delay)
	
	local EnemiesWithinCastRange = PAF.GetNearbyFilteredHeroes(bot, CastRange, true, BOT_MODE_NONE)
	
	for x, Enemy in pairs(EnemiesWithinCastRange) do
		if Enemy:IsChanneling() then
			return 1, Enemy
		end
		
		if PAF.CanDamageKillEnemy(Enemy, Damage, DamageType) then
			local ExtrapolatedLocation = Enemy:GetExtrapolatedLocation(ExtrapolateTime)
				
			if GetUnitToLocationDistance(bot, ExtrapolatedLocation) <= CastRange then
				return 1, ExtrapolatedLocation
			end
		end
	end
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget) then
				if not PAF.IsDisabled(BotTarget) then
					local ExtrapolatedLocation = BotTarget:GetExtrapolatedLocation(ExtrapolateTime)
			
					if GetUnitToLocationDistance(bot, ExtrapolatedLocation) <= CastRange then
						return 1, ExtrapolatedLocation
					end
				else
					local EnemiesWithinRange = PAF.GetNearbyFilteredHeroesForStun(bot, 1600, true, BOT_MODE_NONE)
					local FilteredUnits = PAF.FilterExceptedUnit(EnemiesWithinRange, BotTarget)
					
					local StrongestEnemy = PAF.GetStrongestPowerUnit(FilteredUnits)
					
					if StrongestEnemy ~= nil then
						local ExtrapolatedLocation = StrongestEnemy:GetExtrapolatedLocation(ExtrapolateTime)
			
						if GetUnitToLocationDistance(bot, ExtrapolatedLocation) <= CastRange then
							return 1, ExtrapolatedLocation
						end
					end
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
	
	local NearbyAlliedTowers = bot:GetNearbyTowers(1600, false)
	
	for x, Tower in pairs(NearbyAlliedTowers) do
		local TowerTarget = Tower:GetAttackTarget()
		
		if PAF.IsValidHeroAndNotIllusion(TowerTarget)
		and not PAF.IsMagicImmune(TowerTarget)
		and not PAF.IsDisabled(TowerTarget) then
			local ExtrapolatedLocation = TowerTarget:GetExtrapolatedLocation(ExtrapolateTime)
			
			if GetUnitToLocationDistance(bot, ExtrapolatedLocation) <= CastRange
			and GetUnitToLocationDistance(TowerTarget, ExtrapolatedLocation) then
				return 1, ExtrapolatedLocation
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

function UseLagunaBlade()
	if not LagunaBlade:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = LagunaBlade:GetCastRange()
	local Damage = LagunaBlade:GetSpecialValueInt("damage")
	local DamageType = LagunaBlade:GetDamageType()
	
	if PAF.IsInTeamFight(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget)
			and not PAF.IsReflectingSpells(BotTarget) then
				return 1, BotTarget
			end
		end
	elseif PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsReflectingSpells(BotTarget)
			and PAF.CanDamageKillEnemy(BotTarget, Damage, DamageType) then
				return 1, BotTarget
			end
		end
	end
	
	return 0
end

function UseFlameCloak()
	if not FlameCloak:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	if PAF.IsEngaging(bot) and GetUnitToUnitDistance(bot, BotTarget) <= 1200 then
		return 1
	end
	
	if P.IsRetreating(bot) then
		return 1
	end
	
	return 0
end