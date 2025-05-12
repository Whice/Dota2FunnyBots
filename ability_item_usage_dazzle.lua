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

local PoisonTouch = bot:GetAbilityInSlot(0)
local ShallowGrave = bot:GetAbilityInSlot(1)
local ShadowWave = bot:GetAbilityInSlot(2)
local NothlProjection = bot:GetAbilityInSlot(5)

local PoisonTouchDesire = 0
local ShallowGraveDesire = 0
local ShadowWaveDesire = 0
local NothlProjectionDesire = 0

local AttackRange
local BotTarget

function AbilityUsageThink()
	AttackRange = bot:GetAttackRange()
	BotTarget = bot:GetTarget()
	
	if bot:GetAbilityInSlot(5):GetName() == "dazzle_nothl_projection_end" then
		bot:ActionImmediate_Chat("I'm a clone", true)
	end
	
	-- The order to use abilities in
	if bot:GetAbilityInSlot(5):GetName() ~= "dazzle_nothl_projection_end" then
		NothlProjectionDesire, NothlProjectionTarget = UseNothlProjection()
		if NothlProjectionDesire > 0 then
			bot:Action_UseAbilityOnLocation(NothlProjection, NothlProjectionTarget)
			return
		end
	end
	
	ShallowGraveDesire, ShallowGraveTarget = UseShallowGrave()
	if ShallowGraveDesire > 0 then
		bot:Action_UseAbilityOnEntity(ShallowGrave, ShallowGraveTarget)
		return
	end
	
	PoisonTouchDesire, PoisonTouchTarget = UsePoisonTouch()
	if PoisonTouchDesire > 0 then
		bot:Action_UseAbilityOnEntity(PoisonTouch, PoisonTouchTarget)
		return
	end
	
	ShadowWaveDesire, ShadowWaveTarget = UseShadowWave()
	if ShadowWaveDesire > 0 then
		bot:Action_UseAbilityOnEntity(ShadowWave, ShadowWaveTarget)
		return
	end
end

function UsePoisonTouch()
	if not PoisonTouch:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = PoisonTouch:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	local Radius = PoisonTouch:GetSpecialValueInt("end_radius")
	
	local EnemiesWithinRange = bot:GetNearbyHeroes(CastRange, true, BOT_MODE_NONE)
	local FilteredEnemies = PAF.FilterTrueUnits(EnemiesWithinRange)
	
	if PAF.IsEngaging(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange
			and not PAF.IsMagicImmune(BotTarget) then
				return BOT_ACTION_DESIRE_HIGH, BotTarget
			end
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_LANING then
		for v, Enemy in pairs(FilteredEnemies) do
			local EnemyAllies = Enemy:GetNearbyHeroes(Radius, false, BOT_MODE_NONE)
			local FilteredEnemyAllies = PAF.FilterTrueUnits(EnemyAllies)
			
			if #FilteredEnemyAllies >= 2 then
				return BOT_ACTION_DESIRE_HIGH, Enemy
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

function UseShallowGrave()
	if not ShallowGrave:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = ShallowGrave:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local AlliesWithinRange = bot:GetNearbyHeroes(CastRange, false, BOT_MODE_NONE)
	local FilteredAllies = PAF.FilterTrueUnits(AlliesWithinRange)
	
	local WeakestAlly = PAF.GetWeakestUnit(FilteredAllies)
	
	if WeakestAlly ~= nil then
		if WeakestAlly:GetHealth() <= (WeakestAlly:GetMaxHealth() * 0.25)
		and WeakestAlly:WasRecentlyDamagedByAnyHero(1) then
			return BOT_ACTION_DESIRE_VERYHIGH, WeakestAlly
		end
	end
	
	return 0
end

function UseShadowWave()
	if not ShadowWave:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = ShadowWave:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	local AlliesWithinRange = bot:GetNearbyHeroes(CastRange, false, BOT_MODE_NONE)
	local FilteredAllies = PAF.FilterTrueUnits(AlliesWithinRange)
	
	local WeakestAlly = PAF.GetWeakestUnit(FilteredAllies)
	
	if WeakestAlly ~= nil then
		if WeakestAlly:GetHealth() <= (WeakestAlly:GetMaxHealth() * 0.8) then
			return BOT_ACTION_DESIRE_VERYHIGH, WeakestAlly
		end
	end
	
	return 0
end

function UseNothlProjection()
	if not NothlProjection:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CR = NothlProjection:GetCastRange()
	local CastRange = PAF.GetProperCastRange(CR)
	
	if PAF.IsInTeamFight(bot) then
		if PAF.IsValidHeroAndNotIllusion(BotTarget) then
			if GetUnitToUnitDistance(bot, BotTarget) <= CastRange then
				return BOT_ACTION_DESIRE_HIGH, BotTarget:GetLocation()
			end
		end
	end
	
	return 0
end

function UseBadJuju()
	if not BadJuju:IsFullyCastable() then return 0 end
	if P.CantUseAbility(bot) then return 0 end
	
	local CooldownReduction = BadJuju:GetSpecialValueInt("cooldown_reduction")
	
	if PAF.IsInTeamFight(bot) then
		if not PoisonTouch:IsFullyCastable()
		and not ShadowWave:IsFullyCastable() then
			return BOT_ACTION_DESIRE_VERYHIGH
		end
	end
	
	if not ShallowGrave:IsFullyCastable() then
		local AlliesWithinRange = bot:GetNearbyHeroes(ShallowGrave:GetCastRange(), false, BOT_MODE_NONE)
		local FilteredAllies = PAF.FilterTrueUnits(AlliesWithinRange)
			
		local WeakestAlly = PAF.GetWeakestUnit(FilteredAllies)
			
		if WeakestAlly ~= nil then
			if WeakestAlly:GetHealth() <= (WeakestAlly:GetMaxHealth() * 0.25)
			and WeakestAlly:WasRecentlyDamagedByAnyHero(1) then
				if ShallowGrave:GetCooldownTimeRemaining() <= CooldownReduction then
					return BOT_ACTION_DESIRE_VERYHIGH
				end
			end
		end
	end
	
	return 0
end