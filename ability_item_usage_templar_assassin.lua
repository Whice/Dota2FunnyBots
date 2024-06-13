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

local Refraction = bot:GetAbilityByName("templar_assassin_refraction")
local Meld = bot:GetAbilityByName("templar_assassin_meld")
local PsiBlades = bot:GetAbilityByName("templar_assassin_psi_blades")
local PsionicTrap = bot:GetAbilityByName("templar_assassin_psionic_trap")

local RefractionDesire = 0
local MeldDesire = 0
local PsionicTrapDesire = 0

local AttackRange
local BotTarget
local manathreshold = 0

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	manathreshold = 100
	manathreshold = manathreshold + Refraction:GetManaCost()
	manathreshold = manathreshold + Meld:GetManaCost()
	manathreshold = manathreshold + PsionicTrap:GetManaCost()
	
	-- The order to use abilities in
	PsionicTrapDesire, PsionicTrapTarget = UsePsionicTrap()
	if PsionicTrapDesire > 0 then
		bot:Action_UseAbilityOnLocation(PsionicTrap, PsionicTrapTarget)
		return
	end
	
	RefractionDesire = UseRefraction()
	if RefractionDesire > 0 then
		bot:Action_UseAbility(Refraction)
		return
	end
	
	MeldDesire = UseMeld()
	if MeldDesire > 0 then
		bot:Action_UseAbility(Meld)
		return
	end
end

function UseRefraction()
	if not Refraction:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	if bot:HasModifier("modifier_templar_assassin_meld") then return 0 end
	if bot:HasModifier("modifier_templar_assassin_refraction_absorb") then return 0 end
	
	local enemies = bot:GetNearbyHeroes(1000, true, BOT_MODE_NONE)
	
	if (PAF.IsEngaging(bot) or (P.IsRetreating(bot)) and #enemies >= 1) then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	local projectiles = bot:GetIncomingTrackingProjectiles()
	
	for v, proj in pairs(projectiles) do
		if GetUnitToLocationDistance(bot, proj.location) <= 300 then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	if bot:WasRecentlyDamagedByAnyHero(1) then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	if bot:GetActiveMode() == BOT_MODE_FARM then
		local AttackTarget = bot:GetAttackTarget()
		
		if AttackTarget ~= nil and AttackTarget:IsCreep() and GetUnitToUnitDistance(bot, AttackTarget) < AttackRange and (bot:GetMana() - Refraction:GetManaCost()) > manathreshold then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		local AttackTarget = bot:GetAttackTarget()
		
		if PAF.IsRoshan(AttackTarget) then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	return 0
end

function UseMeld()
	if not Meld:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local AttackTarget = bot:GetAttackTarget()
	
	if AttackTarget ~= nil and GetUnitToUnitDistance(bot, AttackTarget) <= AttackRange then
		if AttackTarget:IsHero() then
			return BOT_ACTION_DESIRE_HIGH
		end
		
		if PAF.IsRoshan(AttackTarget) and bot:GetActiveMode() == BOT_MODE_ROSHAN then
			return BOT_ACTION_DESIRE_HIGH
		end
		
		if AttackTarget:IsCreep() then
			if bot:GetActiveMode() == BOT_MODE_FARM and (bot:GetMana() - Meld:GetManaCost()) > manathreshold then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end
	
	return 0
end

function UsePsionicTrap()
	if not PsionicTrap:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	if bot:HasModifier("modifier_templar_assassin_meld") then return 0 end
	
	local CastRange = PsionicTrap:GetCastRange()
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange then
				return BOT_ACTION_DESIRE_HIGH, BotTarget:GetLocation()
			end
		end
	end
	
	return 0
end