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
	PsionicTrapDesire, PsionicTrapTarget = UsePsionicTrap()
	if PsionicTrapDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbilityOnLocation(PsionicTrap, PsionicTrapTarget)
		return
	end
	
	RefractionDesire = UseRefraction()
	if RefractionDesire > 0 then
		PAF.SwitchTreadsToInt(bot)
		bot:ActionQueue_UseAbility(Refraction)
		return
	end
	
	MeldDesire = UseMeld()
	if MeldDesire > 0 then
		PAF.SwitchTreadsToAgi(bot)
		bot:ActionQueue_UseAbility(Meld)
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
		return 1
	end
	
	local projectiles = bot:GetIncomingTrackingProjectiles()
	
	for v, proj in pairs(projectiles) do
		if GetUnitToLocationDistance(bot, proj.location) <= 300
		and proj.caster ~= nil
		and proj.caster:GetTeam() ~= bot:GetTeam() then
			return 1
		end
	end
	
	if bot:WasRecentlyDamagedByAnyHero(1) then
		return 1
	end
	
	if bot:GetActiveMode() == BOT_MODE_FARM then
		local AttackTarget = bot:GetAttackTarget()
		
		if AttackTarget ~= nil and AttackTarget:IsCreep() and GetUnitToUnitDistance(bot, AttackTarget) < AttackRange and (bot:GetMana() - Refraction:GetManaCost()) > manathreshold then
			return 1
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN then
		local AttackTarget = bot:GetAttackTarget()
		
		if PAF.IsRoshan(AttackTarget) then
			return 1
		end
	end
	
	return 0
end

function UseMeld()
	if not Meld:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local ManaCost = Meld:GetManaCost()
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(AttackTarget) then
			return 1
		end
	end
	
	if PAF.IsInCreepAttackingMode(bot) then
		if PAF.IsValidCreepTarget(AttackTarget) then
			if AttackTarget:GetTeam() ~= bot:GetTeam()
			and PAF.ShouldCastAbilityToFarm(bot, ManaCost, ManaThreshold, false) then
				return 1
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

function UsePsionicTrap()
	if not PsionicTrap:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	if bot:HasModifier("modifier_templar_assassin_meld") then return 0 end
	
	local CastRange = PsionicTrap:GetCastRange()
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange then
				return 1, BotTarget:GetLocation()
			end
		end
	end
	
	return 0
end