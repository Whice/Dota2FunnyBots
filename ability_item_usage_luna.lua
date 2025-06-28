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

local LucentBeam = bot:GetAbilityByName("luna_lucent_beam")
local MoonGlaives = bot:GetAbilityByName("luna_moon_glaive")
local LunarOrbit = bot:GetAbilityByName("luna_lunar_orbit")
local Eclipse = bot:GetAbilityByName("luna_eclipse")

local LucentBeamDesire = 0
local EclipseDesire = 0
local LunarOrbitDesire = 0

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
	LunarOrbitDesire = UseLunarOrbit()
	if LunarOrbitDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbility(LunarOrbit)
		return
	end
	
	EclipseDesire = UseEclipse()
	if EclipseDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbility(Eclipse)
		return
	end
	
	LucentBeamDesire, LucentBeamTarget = UseLucentBeam()
	if LucentBeamDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbilityOnEntity(LucentBeam, LucentBeamTarget)
		return
	end
end

function UseLucentBeam()
	if not LucentBeam:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = LucentBeam:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	local Damage = LucentBeam:GetSpecialValueInt("beam_damage")
	local DamageType = LucentBeam:GetDamageType()
	
	local EnemiesWithinCastRange = PAF.GetNearbyFilteredHeroes(bot, CastRange, true, BOT_MODE_NONE)
	
	for x, Enemy in pairs(EnemiesWithinCastRange) do
		if (Enemy:IsChanneling() or PAF.CanDamageKillEnemy(Enemy, Damage, DamageType))
		and not PAF.IsReflectingSpells(Enemy) then
			return 1, Enemy
		end
	end
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget) then
				if not PAF.IsDisabled(BotTarget) then
					return 1, BotTarget
				else
					local EnemiesWithinRange = PAF.GetNearbyFilteredHeroesForStun(bot, 1600, true, BOT_MODE_NONE)
					local FilteredUnits = PAF.FilterExceptedUnit(EnemiesWithinRange, BotTarget)
					
					local StrongestEnemy = PAF.GetStrongestPowerUnit(FilteredUnits)
					
					if StrongestEnemy ~= nil
					and GetUnitToUnitDistance(bot, StrongestEnemy) <= CastRange then
						return 1, StrongestEnemy
					end
				end
			end
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_LANING then
		local CreepsWithinRange = bot:GetNearbyLaneCreeps(CastRange, true)
		
		for x, Creep in pairs(CreepsWithinRange) do
			if string.find(Creep:GetUnitName(), "ranged")
			and PAF.CanDamageKillEnemy(Creep, Damage, DamageType)
			and GetUnitToUnitDistance(bot, Creep) > AttackRange then
				return 1, Creep
			end
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_RETREAT then
		local StrongestEnemy = PAF.GetStrongestPowerUnit(EnemiesWithinCastRange)
		
		if StrongestEnemy ~= nil
		and not PAF.IsMagicImmune(StrongestEnemy)
		and not PAF.IsReflectingSpells(StrongestEnemy) then
			return 1, StrongestEnemy
		end
	end
	
	local NearbyAlliedTowers = bot:GetNearbyTowers(1600, false)
	
	for x, Tower in pairs(NearbyAlliedTowers) do
		local TowerTarget = Tower:GetAttackTarget()
		
		if PAF.IsValidHeroAndNotIllusion(TowerTarget)
		and not PAF.IsMagicImmune(TowerTarget)
		and not PAF.IsDisabled(TowerTarget)
		and not PAF.IsReflectingSpells(TowerTarget) then
			return 1, TowerTarget
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		if PAF.IsRoshan(AttackTarget) then
			return 1, AttackTarget
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_SIDE_SHOP then
		if PAF.IsTormentor(AttackTarget) then
			return 1, AttackTarget
		end
	end
	
	return 0
end

function UseEclipse()
	if not Eclipse:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local Radius = Eclipse:GetSpecialValueInt("radius")
	
	if PAF.IsInTeamFight(bot) then
		local EnemiesWithinCastRange = PAF.GetNearbyFilteredHeroes(bot, Radius, true, BOT_MODE_NONE)
		
		if #EnemiesWithinCastRange >= 1 then
			return 1
		end
	end
	
	return 0
end

function UseLunarOrbit()
	if not LunarOrbit:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local MovementRadius = LunarOrbit:GetSpecialValueInt("rotating_glaives_movement_radius")
	local CollisionRadius = LunarOrbit:GetSpecialValueInt("rotating_glaives_hit_radius")
	local Radius = (MovementRadius + CollisionRadius)
	
	local EnemiesWithinCastRange = PAF.GetNearbyFilteredHeroes(bot, Radius, true, BOT_MODE_NONE)
	
	if #EnemiesWithinCastRange >= 1 then
		return 1
	end
	
	if bot:GetHealth() < (bot:GetMaxHealth() * 0.8) and bot:WasRecentlyDamagedByAnyHero(1) then
		return 1
	end
	
	return 0
end