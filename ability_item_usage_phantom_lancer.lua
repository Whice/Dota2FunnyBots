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

local SpiritLance = bot:GetAbilityByName("phantom_lancer_spirit_lance")
local DoppelGanger = bot:GetAbilityByName("phantom_lancer_doppelwalk")
local PhantomRush = bot:GetAbilityByName("phantom_lancer_phantom_edge")
local Juxtapose = bot:GetAbilityByName("phantom_lancer_juxtapose")

local SpiritLanceDesire = 0
local DoppelGangerDesire = 0

local AttackRange
local BotTarget
local AttackTarget
local ManaThreshold

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	AttackTarget = bot:GetAttackTarget()
	ManaThreshold = 0.5
	
	-- The order to use abilities in
	JuxtaposeDesire = UseJuxtapose()
	if JuxtaposeDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbility(Juxtapose)
		return
	end
	
	PhantomRushDesire = UsePhantomRush()
	if PhantomRushDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbility(PhantomRush)
		return
	end
	
	SpiritLanceDesire, SpiritLanceTarget = UseSpiritLance()
	if SpiritLanceDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbilityOnEntity(SpiritLance, SpiritLanceTarget)
		return
	end
	
	DoppelGangerDesire, DoppelGangerTarget = UseDoppelGanger()
	if DoppelGangerDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbilityOnLocation(DoppelGanger, DoppelGangerTarget)
		return
	end
end

function UseSpiritLance()
	if not SpiritLance:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = SpiritLance:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local EnemiesWithinCastRange = PAF.GetNearbyFilteredHeroes(bot, CastRange, true, BOT_MODE_NONE)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget)
			and not PAF.IsReflectingSpells(BotTarget) then
				return BOT_ACTION_DESIRE_HIGH, BotTarget
			end
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_LANING then
		local EnemiesWithinRange = PAF.GetNearbyFilteredHeroes(bot, 1600, true, BOT_MODE_NONE)
		
		local WeakestEnemy = PAF.GetWeakestUnit(EnemiesWithinRange)
		if WeakestEnemy ~= nil then
			if GetUnitToUnitDistance(bot, WeakestEnemy) <= CastRange
			and not PAF.IsMagicImmune(WeakestEnemy)
			and not PAF.IsReflectingSpells(WeakestEnemy) then
				return 1,  WeakestEnemy
			end
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

function UseDoppelGanger()
	if not DoppelGanger:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = DoppelGanger:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local projectiles = bot:GetIncomingTrackingProjectiles()
	
	for v, proj in pairs(projectiles) do
		if GetUnitToLocationDistance(bot, proj.location) <= 300
		and proj.is_attack == false
		and proj.caster ~= nil
		and proj.caster:GetTeam() ~= bot:GetTeam() then
			if PAF.IsEngaging(bot) then
				if PAF.IsValidHeroAndNotIllusion(BotTarget) then
					return 1, PAF.GetXUnitsTowardsLocation(bot:GetLocation(), BotTarget:GetLocation(), CastRange)
				else
					return 1, PAF.GetXUnitsTowardsLocation(bot:GetLocation(), bot:GetLocation(), CastRange)
				end
			else
				return 1, PAF.GetXUnitsTowardsLocation(bot:GetLocation(), PAF.GetFountainLocation(bot), CastRange)
			end
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_RETREAT then
		local EnemiesWithinRange = PAF.GetNearbyFilteredHeroes(bot, 1200, true, BOT_MODE_NONE)
		
		if #EnemiesWithinRange >= 1 then
			return 1, PAF.GetXUnitsTowardsLocation(bot:GetLocation(), PAF.GetFountainLocation(bot), CastRange)
		end
	end
	
	return 0
end

function UsePhantomRush()
	if not PhantomRush:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end

	if PAF.IsEngaging(bot) then
		if PhantomRush:GetToggleState() == false and not SpiritLance:IsFullyCastable() then
			return BOT_ACTION_DESIRE_HIGH
		else
			return 0
		end
	else
		if PhantomRush:GetToggleState() == true then
			return BOT_ACTION_DESIRE_HIGH
		else
			return 0
		end
	end
	
	return 0
end

function UseJuxtapose()
	if not Juxtapose:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	if Juxtapose:IsPassive() then return 0 end
	
	if bot:GetActiveMode() == BOT_MODE_RETREAT
	or bot:GetActiveMode() == BOT_MODE_ROAM then
		return 1
	end
	
	return 0
end