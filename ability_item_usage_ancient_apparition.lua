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

local ColdFeet = bot:GetAbilityByName("ancient_apparition_cold_feet")
local IceVortex = bot:GetAbilityByName("ancient_apparition_ice_vortex")
local ChillingTouch = bot:GetAbilityByName("ancient_apparition_chilling_touch")
local IceBlast = bot:GetAbilityByName("ancient_apparition_ice_blast")
local IceBlastRelease = bot:GetAbilityByName("ancient_apparition_ice_blast_release")

local ColdFeetDesire = 0
local IceVortexDesire = 0
local ChillingTouchDesire = 0
local IceBlastDesire = 0
local IceBlastReleaseDesire = 0

local AttackRange
local BotTarget
local IceBlastLoc = Vector(-99999, -99999, -99999)

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	-- The order to use abilities in
	IceBlastReleaseDesire = UseIceBlastRelease()
	if IceBlastReleaseDesire > 0 then
		bot:Action_UseAbility(IceBlastRelease)
		return
	end
	
	IceVortexDesire, IceVortexTarget = UseIceVortex()
	if IceVortexDesire > 0 then
		bot:Action_UseAbilityOnLocation(IceVortex, IceVortexTarget)
		return
	end
	
	IceBlastDesire, IceBlastTarget = UseIceBlast()
	if IceBlastDesire > 0 then
		IceBlastLoc = IceBlastTarget
		bot:Action_UseAbilityOnLocation(IceBlast, IceBlastTarget)
		return
	end
	
	ColdFeetDesire, ColdFeetTarget = UseColdFeet()
	if ColdFeetDesire > 0 then
		bot:Action_UseAbilityOnEntity(ColdFeet, ColdFeetTarget)
		return
	end
	
	ChillingTouchDesire, ChillingTouchTarget = UseChillingTouch()
	if ChillingTouchDesire > 0 then
		bot:Action_UseAbilityOnEntity(ChillingTouch, ChillingTouchTarget)
		return
	end
end

function UseIceVortex()
	if not IceVortex:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = IceVortex:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
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

function UseColdFeet()
	if not ColdFeet:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = ColdFeet:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget) then
				return BOT_ACTION_DESIRE_HIGH, BotTarget
			end
		end
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

function UseChillingTouch()
	if not ChillingTouch:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CastRange = ChillingTouch:GetCastRange()
	
	local enemies = bot:GetNearbyHeroes(CastRange + 100, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(enemies)
	local target = PAF.GetWeakestUnit(FilteredEnemies)
	
	if P.IsInLaningPhase() then
		if target ~= nil then
			return BOT_ACTION_DESIRE_HIGH, target
		end
	end
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget) then
				return BOT_ACTION_DESIRE_HIGH, BotTarget
			end
		end
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

function UseIceBlast()
	if not IceBlast:IsFullyCastable() then return 0 end
	if IceBlast:IsHidden() then return 0 end
	if P.CantUseAbility(bot) then return 0 end

	local allies = GetUnitList(UNIT_LIST_ALLIED_HEROES)
	local FilteredAllies = PAF.FilterTrueUnits(allies)
	
	for v, ally in pairs(FilteredAllies) do
		if PAF.IsInTeamFight(ally) then
			local enemies = ally:GetNearbyHeroes(1000, true, BOT_MODE_NONE)
			local FilteredEnemies = PAF.FilterTrueUnits(enemies)
			local target = PAF.GetWeakestUnit(enemies)
			
			if target ~= nil then
				return BOT_ACTION_DESIRE_HIGH, target:GetLocation()
			end
		end
	end
	
	return 0
end

function UseIceBlastRelease()
	if not IceBlastRelease:IsFullyCastable() then return 0 end
	if IceBlastRelease:IsHidden() then return 0 end
	if P.CantUseAbility(bot) then return 0 end

	local projectiles = GetLinearProjectiles()
	
	for v, projectile in pairs(projectiles) do
		if projectile ~= nil and projectile.ability:GetName() == "ancient_apparition_ice_blast" then
			if P.GetDistance(IceBlastLoc, projectile.location) <= 100 then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end
	
	return 0
end