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

local PlasmaField = bot:GetAbilityByName("razor_plasma_field")
local StaticLink = bot:GetAbilityByName("razor_static_link")
local UnstableCurrent = bot:GetAbilityByName("razor_storm_sturge")
local EyeOfTheStorm = bot:GetAbilityByName("razor_eye_of_the_storm")

local PlasmaFieldDesire = 0
local StaticLinkDesire = 0
local EyeOfTheStormDesire = 0

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
	EyeOfTheStormDesire = UseEyeOfTheStorm()
	if EyeOfTheStormDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbility(EyeOfTheStorm)
		return
	end
	
	PlasmaFieldDesire = UsePlasmaField()
	if PlasmaFieldDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbility(PlasmaField)
		return
	end
	
	StaticLinkDesire, StaticLinkTarget = UseStaticLink()
	if StaticLinkDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbilityOnEntity(StaticLink, StaticLinkTarget)
		return
	end
end

function UsePlasmaField()
	if not PlasmaField:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = PlasmaField:GetSpecialValueInt("radius")
	local MinDamage = PlasmaField:GetSpecialValueInt("damage_min")
	local MaxDamage = PlasmaField:GetSpecialValueInt("damage_max")
	local ManaCost = PlasmaField:GetManaCost()
	local DamageType = PlasmaField:GetDamageType()
	
	local EnemiesWithinCastRange = PAF.GetNearbyFilteredHeroes(bot, CastRange, true, BOT_MODE_NONE)
	
	for x, Enemy in pairs(EnemiesWithinCastRange) do
		local DistanceToEnemy = GetUnitToUnitDistance(bot, Enemy)
		local Damage = RemapValClamped(DistanceToEnemy, 0, CastRange, MinDamage, MaxDamage)
		
		if PAF.CanDamageKillEnemy(Enemy, Damage, DamageType) then
			return 1
		end
	end
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget) then
				return 1
			end
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_RETREAT then
		if #EnemiesWithinCastRange > 0 then
			return 1
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_LANING then
		local LaneCreepsWithinCastRange = bot:GetNearbyLaneCreeps(CastRange, true)
		
		for x, Creep in pairs(LaneCreepsWithinCastRange) do
			if string.find(Creep:GetUnitName(), "ranged") then
				local DistanceToCreep = GetUnitToUnitDistance(bot, Creep)
				local Damage = RemapValClamped(DistanceToCreep, 0, CastRange, MinDamage, MaxDamage)
				
				if PAF.CanDamageKillEnemy(Creep, Damage, DamageType)
				and GetUnitToUnitDistance(bot, Creep) > AttackRange then
					return 1
				end
			end
		end
	end
	
	if PAF.IsInCreepAttackingMode(bot) then
		if PAF.IsValidCreepTarget(AttackTarget) then
			if AttackTarget:GetTeam() ~= bot:GetTeam()
			and PAF.ShouldCastAbilityToFarm(bot, ManaCost, ManaThreshold, false) then
				local CreepsWithinCastRange = bot:GetNearbyCreeps(CastRange, true)
				
				if #CreepsWithinCastRange >= 3 then
					return 1
				end
			end
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		if PAF.IsRoshan(AttackTarget) then
			return 1
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_SIDE_SHOP then
		if PAF.IsTormentor(AttackTarget) then
			return 1
		end
	end
	
	return 0
end

function UseStaticLink()
	if not StaticLink:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = StaticLink:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local EnemiesWithinCastRange = PAF.GetNearbyFilteredHeroes(bot, CastRange, true, BOT_MODE_NONE)
	local EnemiesWithinRange = PAF.GetNearbyFilteredHeroes(bot, 1600, true, BOT_MODE_NONE)
	
	if PAF.IsEngaging(bot) then
		local StrongestEnemy = PAF.GetStrongestDPSUnit(EnemiesWithinRange)
		
		if StrongestEnemy ~= nil
		and not PAF.IsReflectingSpells(StrongestEnemy) then
			return 1, StrongestEnemy
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_RETREAT then
		local StrongestEnemy = PAF.GetStrongestDPSUnit(EnemiesWithinCastRange)
		
		if StrongestEnemy ~= nil
		and not PAF.IsReflectingSpells(StrongestEnemy) then
			return 1, StrongestEnemy
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_LANING then
		local ClosestEnemy = PAF.GetClosestUnit(bot, EnemiesWithinCastRange)
		
		if ClosestEnemy ~= nil
		and not PAF.IsReflectingSpells(ClosestEnemy) then
			return 1, ClosestEnemy
		end
	end
	
	return 0
end

function UseEyeOfTheStorm()
	if not EyeOfTheStorm:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local Radius = EyeOfTheStorm:GetSpecialValueInt("radius")
	local ManaCost = EyeOfTheStorm:GetManaCost()
	
	if PAF.IsInTeamFight(bot) then
		return 1
	end
	
	if PAF.IsInCreepAttackingMode(bot) then
		if PAF.IsValidCreepTarget(AttackTarget) then
			if AttackTarget:GetTeam() ~= bot:GetTeam() then
				local NeutralCreepsWithinCastRange = bot:GetNearbyNeutralCreeps(Radius)
				
				if #NeutralCreepsWithinCastRange >= 6
				and PAF.ShouldCastAbilityToFarm(bot, ManaCost, ManaThreshold, false) then
					return 1
				end
				
				if bot:HasScepter()
				and AttackTarget:IsBuilding() then
					return 1
				end
			end
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		if PAF.IsRoshan(AttackTarget) then
			return 1
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_SIDE_SHOP then
		if PAF.IsTormentor(AttackTarget) then
			return 1
		end
	end
	
	return 0
end